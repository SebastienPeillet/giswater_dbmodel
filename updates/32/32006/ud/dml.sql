/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

INSERT INTO audit_cat_param_user VALUES ('inp_options_dwfscenario', 'epaoptions', NULL, 'role_epa', NULL, NULL, 'DWF scenario:', 'SELECT id, idval FROM cat_dwf_scenario WHERE', NULL, true, 9, 1, 'ud', NULL, NULL, NULL, NULL, NULL, 'string', 'combo', true, NULL, 'YES', 'grl_crm_9', NULL);

UPDATE audit_cat_param_user SET layout_order=2 WHERE id='inp_options_rtc_period_id';
