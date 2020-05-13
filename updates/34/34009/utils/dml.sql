/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2020/05/09
SELECT gw_fct_admin_manage_triggers('notify',null);

-- 13/11/2019
UPDATE config_typevalue_fk SET target_table='ext_cat_raster' WHERE target_table='cat_raster';

UPDATE sys_fprocess SET iscustom=false;
UPDATE sys_function SET iscustom=false;

UPDATE sys_function SET function_type = 'function' WHERE function_type IN ('api function','Function to manage messages');

INSERT INTO sys_function VALUES (2866, 'gw_fct_get_combochilds', 'utils', 'function',null, null, 'Function to manage combos', 'role_basic', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2868, 'gw_fct_getinsertformdisabled', 'utils', 'function',null, null, 'Function to manage disabled forms', 'role_basic', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2870, 'gw_fct_setselectors', 'utils', 'function',null, null, 'Function to manage selectors', 'role_basic', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2872, 'gw_fct_get_filtervaluesvdef', 'utils', 'function',null, null, 'Function to manage vdefault of filters', 'role_basic', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2874, 'gw_fct_getcolumnsfromid', 'utils', 'function',null, null, 'Function to manage colmuns from id', 'role_basic', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2876, 'gw_api_getunexpected', 'utils', 'function',null, null, 'Function to manage unspected visits', 'role_om', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2878, 'gw_fct_getvisitsfromfeature', 'utils', 'function',null, null, 'Function to manage visit from feature', 'role_om', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2880, 'gw_fct_setdimensioning', 'utils', 'function',null, null, 'Function to manage dimensioning', 'role_edit', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2882, 'gw_api_setvisitmanager', 'utils', 'function',null, null, 'Function to manage visit manager', 'role_om', FALSE, null, TRUE);
INSERT INTO sys_function VALUES (2884, 'gw_fct_import_omvisitlot', 'utils', 'function',null, null, 'Function to manage lots', 'role_om', FALSE, null, TRUE);


UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_addfields' WHERE functionname = 'gw_fct_import_addfields';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_dbprices' WHERE functionname = 'gw_fct_import_dbprices';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_elements' WHERE functionname = 'gw_fct_import_elements';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_omvisit' WHERE functionname = 'gw_fct_import_omvisit';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_omvisitlot' WHERE functionname = 'gw_fct_import_omvisitlot';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_import_timeseries' WHERE functionname = 'gw_fct_import_timeseries';
UPDATE config_csv SET functionname = 'gw_fct_utils_csv2pg_importblock' WHERE functionname = 'gw_fct_importblock';
UPDATE config_csv SET functionname = 'gw_fct_utils_export_ui_xml' WHERE functionname = 'gw_fct_export_ui_xml';
UPDATE config_csv SET functionname = 'gw_fct_utils_import_ui_xml' WHERE functionname = 'gw_fct_import_ui_xml';

UPDATE sys_function SET isdeprecated  = true WHERE id = 2502;

INSERT INTO sys_table (id, context, descript, sys_role_id, sys_criticity, qgis_criticity,  isdeprecated)
    VALUES ('config_visit_x_feature', 'visit', 'Table to configure visit class related to feature', 'role_om', 0, 0, false)
    ON CONFLICT (id) DO NOTHING;

UPDATE config_param_system SET value =
 '{"table":"exploitation", "selector":"selector_expl", "table_id":"expl_id",  "selector_id":"expl_id",  "label":"expl_id, '' - '', name, '''', CASE WHEN descript IS NULL THEN '''' ELSE concat('' - '', descript) END", 
 "manageAll":true, "query_filter":"AND expl_id > 0", "typeaheadFilter":{"queryText":"SELECT expl_id as id, name AS idval FROM v_edit_exploitation WHERE expl_id > 0"}}'
 WHERE parameter = 'api_selector_exploitation';
 
  
UPDATE sys_param_user SET dv_querytext = replace (dv_querytext, 'user_name', 'cur_user') where dv_querytext like '%user_name%';

UPDATE sys_function set function_name = 'gw_fct_mincut_inlet_flowtrace' where function_name like 'gw_fct_inlet_flowtrace';

UPDATE sys_function SET return_type = null, input_params = null;

DELETE FROM sys_function where function_name like '%trg_review_audit%';
DELETE FROM sys_function WHERE id IN (1322, 1224, 1326, 1230, 1324, 1226, 1228, 2856, 2442);