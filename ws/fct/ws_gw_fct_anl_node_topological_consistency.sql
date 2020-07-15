/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2302

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_anl_node_topological_consistency(p_data json) ;
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_anl_node_topological_consistency(p_data json) 
RETURNS json AS 
$BODY$

/*EXAMPLE

SELECT SCHEMA_NAME.gw_fct_anl_node_topological_consistency($${
"client":{"device":4, "infoType":1, "lang":"ES"},
"feature":{"tableName":"v_edit_node", "id":["18","1101"]},
"data":{"selectionMode":"previousSelection", "parameters":{"saveOnDatabase":true}}}$$)

--fid: 108
*/

DECLARE

rec_node record;
rec record;

v_version text;
v_saveondatabase boolean;
v_result json;
v_id json;
v_result_info json;
v_result_point json;
v_selectionmode text;
v_worklayer text;
v_array text;
v_node_aux record;
v_qmlpointpath text;
v_error_context text;

BEGIN

	SET search_path = "SCHEMA_NAME", public;

	-- select version
	SELECT giswater INTO v_version FROM sys_version order by 1 desc limit 1;

	-- Reset values
	DELETE FROM anl_node WHERE cur_user="current_user"() AND anl_node.fid=108;

	-- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  (((p_data ->>'data')::json->>'parameters')::json->>'saveOnDatabase')::boolean;

	--select default geometry style
	SELECT regexp_replace(row(value)::text, '["()"]', '', 'g')  INTO v_qmlpointpath FROM config_param_user WHERE parameter='qgis_qml_pointlayer_path' AND cur_user=current_user;

	-- Computing process
	IF v_array != '()' THEN
		EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, state, num_arcs, expl_id, fid, the_geom)
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id 
				WHERE num_arcs=4 AND node_id IN '||v_array ||'
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 4
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id 
				WHERE num_arcs=3 AND node_id IN '||v_array ||'
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 3
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id 
				WHERE num_arcs=2 AND node_id IN '||v_array ||'
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 2
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id 
				WHERE num_arcs=1 AND node_id IN '||v_array ||'
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 1;';
	ELSE
		EXECUTE 'INSERT INTO anl_node (node_id, nodecat_id, state, num_arcs, expl_id, fid, the_geom)
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id WHERE num_arcs=4
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 4
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id WHERE num_arcs=3
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 3
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id WHERE num_arcs=2
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 2
				UNION
				SELECT node_id, nodecat_id, '||v_worklayer||'.state, COUNT(*), '||v_worklayer||'.expl_id, 108, '||v_worklayer||'.the_geom 
				FROM '||v_worklayer||' 
				JOIN v_edit_arc ON v_edit_arc.node_1 = '||v_worklayer||'.node_id OR v_edit_arc.node_2 = '||v_worklayer||'.node_id
				JOIN cat_feature_node ON nodetype_id=id WHERE num_arcs=1
				GROUP BY '||v_worklayer||'.node_id, nodecat_id, '||v_worklayer||'.state, '||v_worklayer||'.expl_id, '||v_worklayer||'.the_geom 
				HAVING COUNT(*) != 1;';
	END IF;

	
	DELETE FROM selector_audit WHERE fid=108 AND cur_user=current_user;
	INSERT INTO selector_audit (fid,cur_user) VALUES (108, current_user);

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT * FROM audit_check_data WHERE cur_user="current_user"() AND fid=108) row;
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--points
	v_result = null;
  	SELECT jsonb_agg(features.feature) INTO v_result
 	FROM (
    SELECT jsonb_build_object(
     'type',       'Feature',
    'geometry',   ST_AsGeoJSON(the_geom)::jsonb,
    'properties', to_jsonb(row) - 'the_geom'
    ) AS feature
    FROM (SELECT id, node_id, nodecat_id, state, expl_id, descript,fid, the_geom
    FROM  anl_node WHERE cur_user="current_user"() AND fid=108) row) features;

  	v_result := COALESCE(v_result, '{}'); 
  	v_result_point = concat ('{"geometryType":"Point", "qmlPath":"',v_qmlpointpath,'", "features":',v_result, '}'); 

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM audit_check_data WHERE cur_user="current_user"() AND fid=108;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fid=108 AND cur_user=current_user;
		INSERT INTO selector_audit (fid,cur_user) VALUES (108, current_user);
	END IF;
		
	-- Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 

	-- Return
	RETURN gw_fct_json_create_return(('{"status":"Accepted", "message":{"level":1, "text":"Analysis done successfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"setVisibleLayers":[]'||
			'}}'||
	    '}')::json, 2302);

	EXCEPTION WHEN OTHERS THEN
	GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;