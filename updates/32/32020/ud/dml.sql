/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;


--03/04/2019 - activate audit_cat_param_user for new visit
UPDATE audit_cat_param_user SET  isenabled=true where id='visitclass_vdefault_gully';

