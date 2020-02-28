/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


DROP TRIGGER IF EXISTS gw_trg_edit_config_sys_fields ON "SCHEMA_NAME".ve_config_sys_fields;
CREATE TRIGGER gw_trg_edit_config_sys_fields INSTEAD OF UPDATE ON "SCHEMA_NAME".ve_config_sys_fields 
FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_config_sysfields();