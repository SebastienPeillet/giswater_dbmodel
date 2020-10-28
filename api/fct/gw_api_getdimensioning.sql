/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- Function code: XXXX

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_getdimensioning(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_api_getdimensioning($${
    "client":{"device":4, "infoType":1, "lang":"ES"}, 
    "form":{}, "feature":{}, 
    "data":{"filterFields":{}, "pageInfo":{}, 
        "coordinates":{"x1":418482.9909557662, "y1":4577973.008625593, "x2":418513.4491390207, "y2":4577971.030821485}}}$$)
*/

DECLARE

--    Variables
	
	v_status text ='Accepted';
	v_message json;
	v_apiversion json;
	v_forminfo json;
	v_featureinfo json;
	v_linkpath json;
	v_parentfields text;
	v_fields_array json[];
	schemas_array name[];
	v_project_type text;
	aux_json json;
	v_fields json;
	field json;
	v_id int8;
    v_expl integer;
	v_epsg integer;
	v_input_geometry public.geometry;
	v_x1 double precision;
	v_y1 double precision;
	v_x2 double precision;
	v_y2 double precision;
	count_aux integer;


BEGIN

--  Get,check and set parameteres
----------------------------
--    	Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	schemas_array := current_schemas(FALSE);

-- 	Get srid
	v_epsg = (SELECT epsg FROM version LIMIT 1);

--      Get values from config
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO v_apiversion;
		
--  	Get project type
	SELECT wsoftware INTO v_project_type FROM version LIMIT 1;


	-- mandantory set due complex interaction againts QGIS and database when on qgis is feature interted value is updated, transaction is opened....
	PERFORM setval('SCHEMA_NAME.dimensions_id_seq', (SELECT max(id) FROM dimensions), true);

	v_id = (SELECT nextval('SCHEMA_NAME.dimensions_id_seq'::regclass));

	v_featureinfo = '{"tableName":"v_edit_dimensions", "idName":"id", "id":'||v_id||'}';
    
--	getting input data 
	v_x1 := (((p_data ->>'data')::json->>'coordinates')::json->>'x1')::float;
	v_y1 := (((p_data ->>'data')::json->>'coordinates')::json->>'y1')::float;
	v_x2 := (((p_data ->>'data')::json->>'coordinates')::json->>'x2')::float;
	v_y2 := (((p_data ->>'data')::json->>'coordinates')::json->>'y2')::float;
    
 --	Geometry column
	IF v_x2 IS NULL THEN
        v_input_geometry:= ST_SetSRID(ST_MakePoint(v_x1, v_y1),v_epsg);
	ELSIF v_x2 IS NOT NULL THEN
        v_input_geometry:= ST_SetSRID(ST_MakeLine(ST_MakePoint(v_x1, v_y1), ST_MakePoint(v_x2, v_y2)), v_epsg);
	END IF;

--	USE reduced geometry to intersect with expl mapzone in order to enhance the selectedId expl
	SELECT count(*) into count_aux FROM exploitation WHERE ST_DWithin(v_input_geometry, exploitation.the_geom,0.001);
	IF count_aux = 1 THEN
		v_expl = (SELECT expl_id FROM exploitation WHERE ST_DWithin(v_input_geometry, exploitation.the_geom,0.001)  AND active=true LIMIT 1);
	ELSE
		SELECT expl_id INTO v_expl FROM selector_expl WHERE cur_user = current_user LIMIT 1;
	END IF;
	
    
	EXECUTE 'SELECT gw_api_get_formfields($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)'
	INTO v_fields_array
	USING 'v_edit_dimensions', 'feature', '', NULL, NULL, NULL, NULL, 'SELECT', null, 3;

	-- Set widget_name without tabname for widgets
	FOREACH field IN ARRAY v_fields_array
	LOOP
		v_fields_array[(field->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(field->>'orderby')::INT], 'widgetname', field->>'column_id');
        IF (field->>'column_id') = 'expl_id' THEN
			v_fields_array[(field->>'orderby')::INT] := gw_fct_json_object_set_key(field, 'selectedId', v_expl::text);
		END IF;
	END LOOP;

	v_fields := array_to_json(v_fields_array);

	

--    Control NULL's
----------------------

	v_status := COALESCE(v_status, '{}');    
	v_message := COALESCE(v_message, '{}');    
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_forminfo := COALESCE(v_forminfo, '{}');
	v_featureinfo := COALESCE(v_featureinfo, '{}');
	v_linkpath := COALESCE(v_linkpath, '{}');
	v_parentfields := COALESCE(v_parentfields, '{}');
	v_fields := COALESCE(v_fields, '{}');

--    Return
-----------------------
     RETURN ('{"status":"'||v_status||'", "message":'||v_message||', "apiVersion":' || v_apiversion ||
	      ',"body":{"form":' || v_forminfo ||
		     ', "feature":'|| v_featureinfo ||
		      ',"data":{"linkPath":' || v_linkpath ||
			      ',"parentFields":' || v_parentfields ||
			      ',"fields":' || v_fields || 
			      '}'||
			'}'||
		'}')::json;

--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","message":' || to_json(SQLERRM) || ', "apiVersion":'|| v_apiversion ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

