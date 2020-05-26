/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/02/06
DROP VIEW v_minsector;
ALTER TABLE minsector ALTER COLUMN the_geom TYPE geometry (multipolygon, SRID_VALUE) USING ST_Multi(the_geom);

ALTER TABLE arc RENAME presszonecat_id TO presszone_id;
ALTER TABLE node RENAME presszonecat_id TO presszone_id;
ALTER TABLE connec RENAME presszonecat_id TO presspzone_id;
