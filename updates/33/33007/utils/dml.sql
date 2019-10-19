/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 19/10/2019
UPDATE audit_cat_table SET isdeprecated=true WHERE id='v_rtc_hydrometer_x_connec';

-- harmonize context for pivot tables (in case those have been changed to 'view from external schema' nothing will change here
UPDATE audit_cat_table SET context='table to external'  WHERE context IN ('external table','ext','Streeter');

