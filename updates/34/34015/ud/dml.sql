/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/06/27
DELETE FROM config_fprocess WHERE target IN ('[ADJUSTMENTS]', '[GWF]');


UPDATE sys_param_user SET formname = 'epaoptions', project_type = 'ud', label, ='Default values', datatype = 'json', layoutorder = 16, layoutname = 'grl_general_2'
iseditable = 'true', epaversion = '{"from":"5.0.022", "to":null,"language":"english"}' , descript = 'Default values on go2epa generation inp file'
WHERE id = 'inp_options_vdefault';