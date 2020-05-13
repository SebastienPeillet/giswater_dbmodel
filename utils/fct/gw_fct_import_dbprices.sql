/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2510

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_utils_csv2pg_import_dbprices(integer, text);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_utils_csv2pg_import_dbprices(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_import_dbprices(p_data json)
RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_import_dbprices($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{},"data":{}}$$)
*/

DECLARE
	v_units record;
	v_result_id text= 'import db prices';
	v_result json;
	v_result_info json;
	v_project_type text;
	v_version text;
	v_count integer;
	v_label text;
	v_error_context text;
	v_level integer;
	v_status text;
	v_message text;
	v_audit_result text;

BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get system parameters
	SELECT wsoftware, giswater  INTO v_project_type, v_version FROM version order by 1 desc limit 1;

    --set current process as users parameter
    DELETE FROM config_param_user  WHERE  parameter = 'cur_trans' AND cur_user =current_user;

    INSERT INTO config_param_user (value, parameter, cur_user)
    VALUES (txid_current(),'cur_trans',current_user );
    
   	v_label = ((p_data ->>'data')::json->>'importParam')::text;
   	
	-- manage log (fprocesscat = 42)
	DELETE FROM audit_check_data WHERE fprocesscat_id=42 AND cur_user=current_user;
	INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('IMPORT DB PRICES FILE'));
	INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('------------------------------'));

	
	-- control of rows
	SELECT count(*) INTO v_count FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1;

	IF v_count =0 THEN
		INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('Nothing to import'));
	ELSE

		-- control of price code (csv1)
		SELECT csv1 INTO v_units FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1;

		IF v_units IS NULL THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{}, 
			"data":{"error":"2086", "function":"2440","debug_msg":null}}$$);'INTO v_audit_result;
		END IF;
	
		-- control of price units (csv2)
		SELECT csv2 INTO v_units FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1
		AND csv2 IS NOT NULL AND csv2 NOT IN (SELECT id FROM price_value_unit);

		IF v_units IS NOT NULL THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{}, 
			"data":{"error":"2088", "function":"2440","debug_msg":"'||v_units||'"}}$$);'INTO v_audit_result;
		END IF;

		-- control of price descript (csv3)
		SELECT csv3 INTO v_units FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1;

		IF v_units IS NULL THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{}, 
			"data":{"error":"2090", "function":"2440","debug_msg":null}}$$);'INTO v_audit_result;
		END IF;

		-- control of null prices(csv5)
		SELECT csv5 INTO v_units FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1;

		IF v_units IS NULL THEN
			EXECUTE 'SELECT gw_fct_getmessage($${"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{}, 
			"data":{"error":"2092", "function":"2440","debug_msg":null}}$$);'INTO v_audit_result;
		END IF;
	
		-- Insert into price_cat_simple table
		IF v_label NOT IN (SELECT id FROM price_cat_simple) THEN
			INSERT INTO price_cat_simple (id) VALUES (v_label);
		END IF;

		-- Insert into price_compost table
		INSERT INTO price_compost (id, pricecat_id, unit, descript, text, price)
		SELECT csv1, v_label, csv2, csv3, csv4, csv5::numeric(12,4)
		FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1
		ON CONFLICT (id) DO NOTHING;
	
		-- update if price exists
		UPDATE price_simple SET pricecat_id=v_label, price=csv5::numeric(12,4) FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1 AND price_simple.id=csv1;
			
		-- Delete values on temporal table
		DELETE FROM temp_csv2pg WHERE cur_user=current_user AND csv2pgcat_id=1;	
	
		-- manage log (fprocesscat 42)
		INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('Reading values from temp_csv2pg table -> Done'));
		INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('Inserting values on price_simple table -> Done'));
		INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('Deleting values from temp_csv2pg -> Done'));
		INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (42, v_result_id, concat('Process finished'));

	END IF;

	-- get log (fprocesscat 42)
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message AS message FROM audit_check_data WHERE cur_user="current_user"() AND fprocesscat_id=42) row; 

	IF v_audit_result is null THEN
        v_status = 'Accepted';
        v_level = 3;
        v_message = 'Process done successfully';
    ELSE

        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'status')::text INTO v_status; 
        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'level')::integer INTO v_level;
        SELECT ((((v_audit_result::json ->> 'body')::json ->> 'data')::json ->> 'info')::json ->> 'message')::text INTO v_message;

    END IF;


	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
				
	-- Control nulls
	v_version := COALESCE(v_version, '{}'); 
	v_result_info := COALESCE(v_result_info, '{}'); 
	
	-- Return
	RETURN ('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
            ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||'}}'||
	    '}')::json;
	    
	EXCEPTION WHEN OTHERS THEN
	 GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	 RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;

 
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;