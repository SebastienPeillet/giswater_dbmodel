/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


-- DROP FUNCTION SCHEMA_NAME.gw_fct_built_nodefromarc();

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_built_nodefromarc() RETURNS integer AS
$BODY$

DECLARE 


BEGIN 

    SET search_path = "SCHEMA_NAME", public;

	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
