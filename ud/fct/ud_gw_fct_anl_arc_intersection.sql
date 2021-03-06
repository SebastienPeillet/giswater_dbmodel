/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2202

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_arc_intersection(p_data json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_arc_intersection(p_data json) 
RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_arc_intersection($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"tableName":"v_edit_man_conduit", "id":["138","139"]},
"data":{"selectionMode":"previousSelection", "parameters":{"saveOnDatabase":true}
}}$$)

-- fid: 109

*/

DECLARE
	
v_version text;
v_result json;
v_result_info json;
v_result_line json;
v_id json;
v_selectionmode text;
v_saveondatabase boolean;
v_worklayer text;
v_array text;
v_error_context text;
v_qmllinepath text;

BEGIN

	SET search_path = "SCHEMA_NAME", public;

	-- select version
	SELECT giswater INTO v_version FROM sys_version order by 1 desc limit 1;

	-- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  (((p_data ->>'data')::json->>'parameters')::json->>'saveOnDatabase')::boolean;

	--select default geometry style
	SELECT regexp_replace(row(value)::text, '["()"]', '', 'g') INTO v_qmllinepath FROM config_param_user WHERE parameter='qgis_qml_linelayer_path' AND cur_user=current_user;

	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fid=109;
	    
	-- Computing process
	IF v_array != '()' THEN
		EXECUTE 'INSERT INTO anl_arc (arc_id, expl_id, fid, arc_id_aux, the_geom_p, the_geom, arccat_id, state)
		SELECT a.arc_id AS arc_id_1, a.expl_id, 109, b.arc_id AS arc_id_2, 
		(ST_Dumppoints(ST_Multi(ST_Intersection(a.the_geom, b.the_geom)))).geom AS the_geom_p,a.the_geom, a.arccat_id, a.state
		FROM '||v_worklayer||' AS a, '||v_worklayer||' AS b 
		WHERE a.state=1 AND b.state=1 AND ST_Intersects(a.the_geom, b.the_geom) AND a.arc_id != b.arc_id AND NOT ST_Touches(a.the_geom, b.the_geom)
		AND a.the_geom is not null and b.the_geom is not null AND a.arc_id IN '||v_array||';';
	ELSE
		EXECUTE 'INSERT INTO anl_arc (arc_id, expl_id, fid, arc_id_aux, the_geom_p,the_geom, arccat_id, state)
		SELECT a.arc_id AS arc_id_1, a.expl_id, 109, b.arc_id AS arc_id_2, 
		(ST_Dumppoints(ST_Multi(ST_Intersection(a.the_geom, b.the_geom)))).geom AS the_geom_p,a.the_geom, a.arccat_id, a.state
		FROM '||v_worklayer||' AS a, '||v_worklayer||' AS b 
		WHERE a.state=1 AND b.state=1 AND ST_Intersects(a.the_geom, b.the_geom) AND a.arc_id != b.arc_id AND NOT ST_Touches(a.the_geom, b.the_geom)
		AND a.the_geom is not null and b.the_geom is not null;';
	END IF;

	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE cur_user="current_user"() AND fid=109 order by id) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--lines
	v_result = null;
	SELECT jsonb_agg(features.feature) INTO v_result
	FROM (
  	SELECT jsonb_build_object(
     'type',       'Feature',
    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
    'properties', to_jsonb(row) - 'the_geom'
  	) AS feature
  	FROM (SELECT DISTINCT ON (arc_id,arc_id_aux) id, arc_id, arccat_id,arc_id_aux, state, expl_id, descript, the_geom, fid
  	FROM  anl_arc WHERE cur_user="current_user"() AND fid=109) row) features;

	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "qmlPath":"',v_qmllinepath,'", "features":',v_result,'}'); 

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM anl_arc WHERE cur_user="current_user"() AND fid=109;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fid=109 AND cur_user=current_user;
		INSERT INTO selector_audit (fid,cur_user) VALUES (109,current_user);
	END IF;
		
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 

	--  Return
	RETURN ('{"status":"Accepted", "message":{"level":1, "text":"Analysis done successfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"line":'||v_result_line||','||
				'"setVisibleLayers":[]'||
		       '}}'||
	    '}')::json; 

	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;