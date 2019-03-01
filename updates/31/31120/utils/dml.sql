/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2019/02/27
SELECT setval('config_param_system_id_seq', (SELECT max(id) FROM config_param_system), true);
INSERT INTO config_param_system (parameter, value, data_type, context, descript) 
VALUES ('om_visit_duration_vdefault','{"class1":"1 hours","class2":"1 hours","class3":"1 hours","class4":"1 hours","class5":"1 hours","class6":"1 hours","class7":"1 hours","class8":"1 hours","class9":"1 hours","class10":"1 hours"}','json', 'om_visit', 'Parameters used for visits');




INSERT INTO sys_combo_cat VALUES (1, 'om_visit_clean');
INSERT INTO sys_combo_cat VALUES (2, 'om_visit_desperfect');
INSERT INTO sys_combo_cat VALUES (3, 'om_visit_status');
INSERT INTO sys_combo_cat VALUES (4, 'incidency');
INSERT INTO sys_combo_cat VALUES (5, 'om_lot_status');



-- add function gw_api_get_filtervalues_vdef