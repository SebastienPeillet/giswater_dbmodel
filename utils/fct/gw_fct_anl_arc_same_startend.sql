﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2104

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_arc_same_startend();
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_arc_same_startend() RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_arc_same_startend()
*/

DECLARE
	v_version text;
	v_saveondatabase boolean = true;
	v_result json;
BEGIN

	SET search_path = "SCHEMA_NAME", public;

	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4;
	
	-- Computing process
	INSERT INTO anl_arc (arc_id, state, expl_id, fprocesscat_id, the_geom)
	SELECT arc_id, state, expl_id, 4, the_geom
	FROM v_edit_arc WHERE node_1::text=node_2::text;

	-- get results
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result FROM (SELECT * FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4) row; 

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=4 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (4, current_user);
	END IF;
		
	--    Control nulls
	v_result := COALESCE(v_result, '[]'); 

	--  Return
	RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
	     ',"body":{"form":{}'||
		     ',"data":{"result":' || v_result ||
			     '}'||
		       '}'||
	    '}')::json; 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

