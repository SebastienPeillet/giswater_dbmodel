/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- Function: gw_api_setdimensioning(json)

-- DROP FUNCTION gw_api_setdimensioning(json);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_setdimensioning(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_api_setdimensioning($${
		"client":{"device":9, "infoType":100, "lang":"ES"},
		"form":{},
		"feature":{"tableName":"dimensions"},
		"data":{"filterFields":{"distance":"9.9974"}}}$$)
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
	v_schemaname  text;
	v_device integer;
	v_infotype integer;
	v_tablename text;
	v_text text[];
	v_querytext varchar;
	i integer=1;
	v_first boolean;
	v_jsonfield json;
	v_field text;
	v_value text;
	text text;
	v_columntype character varying;
	v_newid integer;
	v_geometry geometry;

BEGIN

--    Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO v_apiversion;
       
	-- Get input parameters:
	v_device := (p_data ->> 'client')::json->> 'device';
	v_infotype := (p_data ->> 'client')::json->> 'infoType';
	v_tablename := (p_data ->> 'feature')::json->> 'tableName';
	v_fields := ((p_data ->> 'data')::json->> 'filterFields')::json;

	select array_agg(row_to_json(a)) into v_text from json_each(v_fields)a;

	-- query text, step1
	v_querytext := 'UPDATE ' || quote_ident(v_tablename) ||' SET (';

	-- query text, step2
	i=1;
	v_first=FALSE;
	
	FOREACH text IN ARRAY v_text 
	LOOP
		
		SELECT v_text [i] into v_jsonfield;
		v_field:= (SELECT (v_jsonfield ->> 'key')) ;
		v_value := (SELECT (v_jsonfield ->> 'value')) ; -- getting v_value in order to prevent null values
	
		IF v_value !='null' OR v_value !='NULL' OR v_value IS NOT NULL THEN 
			
			--building the query text
			IF i=1 OR v_first IS FALSE THEN
				v_querytext := concat (v_querytext, v_field);
				v_first = TRUE;
			ELSIF i>1 THEN
				v_querytext := concat (v_querytext, ', ', quote_ident(v_field));
			END IF;
		
		END IF;
		i=i+1;	
	END LOOP;

	-- query text, step3
	v_querytext := concat (v_querytext, ') = (');
	
	-- query text, step4
	i=1;
	v_first=FALSE;
	FOREACH text IN ARRAY v_text 
	LOOP
		SELECT v_text [i] into v_jsonfield;
		v_field:= (SELECT (v_jsonfield ->> 'key')) ;
		v_value := (SELECT (v_jsonfield ->> 'value')) ;

		-- Get column type
		EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(v_tablename) || ' AND column_name = $2'
			USING v_schemaname, v_field
			INTO v_columntype;
			
		-- control column_type
		IF v_columntype IS NULL THEN
			v_columntype='text';
		ELSIF v_columntype = 'USER-DEFINED' THEN
			v_columntype='geometry';
		END IF;

		IF v_value !='null' OR v_value !='NULL' THEN 
		
			--building the query text
			IF i=1 OR v_first IS FALSE THEN
				v_querytext := concat (v_querytext, quote_literal(v_value),'::',v_columntype);
				v_first = TRUE;
			ELSIF i>1 THEN
				v_querytext := concat (v_querytext, ', ',  quote_literal(v_value),'::',v_columntype);
			END IF;

		END IF;
		i=i+1;

	END LOOP;

	-- query text, final step
	v_querytext := concat ((v_querytext),' )WHERE id = ' || (((p_data ->> 'data')::json->> 'filterFields')::json->>'id') || ' RETURNING id');

	-- execute query text
	EXECUTE v_querytext into v_newid;


--    Return
    RETURN ('{"status":"Accepted", "message":"Dimensioning udpate successfully", "apiVersion":'|| v_apiversion ||
	    ', "body": {"feature":{"tableName":"'||v_tablename||'", "id":"'||v_newid||'"}}}')::json;    

--    Exception handling
  --  EXCEPTION WHEN OTHERS THEN 
    --    RETURN ('{"status":"Failed","message":' || (to_json(SQLERRM)) || ', "apiVersion":'|| v_apiversion ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;    

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


