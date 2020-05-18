/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2870

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_api_setselectors (json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_setselectors(p_data json)
  RETURNS json AS
$BODY$

/*example
SELECT SCHEMA_NAME.gw_fct_setselectors($${"client":{"device":9, "infoType":100, "lang":"ES"},"feature":{},"data":{"selector_type":"exploitation", "id":1, "check":true, "onlyone":true}}$$)
*/

DECLARE
--	Variables
	api_version json;
	v_selector_type text;
	v_id text;
	v_check boolean;
	v_onlyone boolean;
	v_tablename text;
	
BEGIN

	-- Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	
	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO api_version;

	-- get input parameters:
	v_selector_type := (p_data ->> 'data')::json->> 'selector_type';
	v_id := (p_data ->> 'data')::json->> 'id';
	v_check := (p_data ->> 'data')::json->> 'check';
	v_onlyone := (p_data ->> 'data')::json->> 'onlyone';

	IF v_onlyone THEN
		EXECUTE 'DELETE FROM selector_expl WHERE cur_user = current_user';
	END IF;
	
	IF v_check THEN
		EXECUTE 'INSERT INTO selector_expl (expl_id, cur_user) VALUES('|| v_id ||', '''|| current_user ||''')';
	ELSE
		EXECUTE 'DELETE FROM selector_expl WHERE expl_id = '|| v_id ||'';
	END IF;
	
	-- Return
	RETURN ('{"status":"Accepted", "apiVersion":'||api_version||
			',"body":{"message":{"priority":1, "text":"This is a test message"}'||
			',"form":{"formName":"", "formLabel":"", "formText":""'||
			',"formActions":[]}'||
			',"feature":{}'||
			',"data":{"indexingLayers": {"exploitation": ["v_edit_arc", "v_edit_node", "v_edit_connec", "v_edit_element"] }}}'||'}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  