﻿DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_mincut_valve_unaccess(character varying ,integer);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_mincut_valve_unaccess(
    node_id_var character varying,
    result_id_var integer)
  RETURNS void AS
$BODY$
DECLARE 
feature_id_aux text;
feature_type_aux text;

BEGIN 
	-- set search_path
    SET search_path= 'SCHEMA_NAME','public';

	SELECT anl_feature_id INTO feature_id_aux FROM anl_mincut_result_cat WHERE id=result_id_var;
	SELECT anl_feature_type INTO feature_type_aux FROM anl_mincut_result_cat WHERE id=result_id_var;
	
	-- Computing process
  	IF (SELECT node_id FROM anl_mincut_result_valve_unaccess WHERE node_id=node_id_var and result_id=result_id_var) IS NULL THEN
		INSERT INTO anl_mincut_result_valve_unaccess (result_id, node_id) VALUES (result_id_var, node_id_var);
	ELSE
		DELETE FROM anl_mincut_result_valve_unaccess WHERE result_id=result_id_var AND node_id=node_id_var;
	END IF;

	PERFORM gw_fct_mincut(feature_id_aux, feature_type_aux, result_id_var);

RETURN;
    
END;  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;