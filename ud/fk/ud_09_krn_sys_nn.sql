/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

--DROP
ALTER TABLE gully_type ALTER COLUMN "type" DROP NOT NULL;
ALTER TABLE gully_type ALTER COLUMN man_table DROP NOT NULL;

ALTER TABLE cat_arc_shape ALTER COLUMN epa DROP NOT NULL;

ALTER TABLE macrodma ALTER COLUMN name DROP NOT NULL;
ALTER TABLE macrodma ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE dma ALTER COLUMN name DROP NOT NULL;
ALTER TABLE dma ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE sector ALTER COLUMN name DROP NOT NULL;

ALTER TABLE node ALTER COLUMN nodecat_id DROP NOT NULL;
ALTER TABLE node ALTER COLUMN node_type DROP NOT NULL;
ALTER TABLE node ALTER COLUMN epa_type DROP NOT NULL;
ALTER TABLE node ALTER COLUMN sector_id DROP NOT NULL;
ALTER TABLE node ALTER COLUMN "state" DROP NOT NULL;
ALTER TABLE node ALTER COLUMN dma_id DROP NOT NULL;
ALTER TABLE node ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE arc ALTER COLUMN arccat_id DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN arc_type DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN epa_type DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN sector_id DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN "state" DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN dma_id DROP NOT NULL;
ALTER TABLE arc ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE connec ALTER COLUMN connecat_id DROP NOT NULL;
ALTER TABLE connec ALTER COLUMN connec_type DROP NOT NULL;
ALTER TABLE connec ALTER COLUMN sector_id DROP NOT NULL;
ALTER TABLE connec ALTER COLUMN "state" DROP NOT NULL;
ALTER TABLE connec ALTER COLUMN dma_id DROP NOT NULL;
ALTER TABLE connec ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE gully ALTER COLUMN gully_type DROP NOT NULL;
ALTER TABLE gully ALTER COLUMN sector_id DROP NOT NULL;
ALTER TABLE gully ALTER COLUMN "state" DROP NOT NULL;
ALTER TABLE gully ALTER COLUMN dma_id DROP NOT NULL;
ALTER TABLE gully ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE samplepoint ALTER COLUMN "state" DROP NOT NULL;
ALTER TABLE samplepoint ALTER COLUMN expl_id DROP NOT NULL;

ALTER TABLE element_x_gully ALTER COLUMN element_id DROP NOT NULL;
ALTER TABLE element_x_gully ALTER COLUMN gully_id DROP NOT NULL;


--EXTRA NOT NULLS

--ALTER TABLE node ALTER COLUMN inventory DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN state_type DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN workcat_id DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN builtdate DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN verified DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN code DROP NOT NULL;
--ALTER TABLE node ALTER COLUMN the_geom DROP NOT NULL;

--ALTER TABLE arc ALTER COLUMN inventory DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN state_type DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN workcat_id DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN builtdate DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN verified DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN code DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN node_1 DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN node_2 DROP NOT NULL;
--ALTER TABLE arc ALTER COLUMN the_geom DROP NOT NULL;


--ALTER TABLE connec ALTER COLUMN inventory DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN state_type DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN workcat_id DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN builtdate DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN verified DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN code DROP NOT NULL;
--ALTER TABLE connec ALTER COLUMN the_geom DROP NOT NULL;


--SET

ALTER TABLE gully_type ALTER COLUMN "type" SET NOT NULL;
ALTER TABLE gully_type ALTER COLUMN man_table SET NOT NULL;

ALTER TABLE cat_arc_shape ALTER COLUMN epa SET NOT NULL;

ALTER TABLE macrodma ALTER COLUMN name SET NOT NULL;
ALTER TABLE macrodma ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE dma ALTER COLUMN name SET NOT NULL;
ALTER TABLE dma ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE macrosector ALTER COLUMN name SET NOT NULL;

ALTER TABLE node ALTER COLUMN nodecat_id SET NOT NULL;
ALTER TABLE node ALTER COLUMN node_type SET NOT NULL;
ALTER TABLE node ALTER COLUMN epa_type SET NOT NULL;
ALTER TABLE node ALTER COLUMN sector_id SET NOT NULL;
ALTER TABLE node ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE node ALTER COLUMN dma_id SET NOT NULL;
ALTER TABLE node ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE arc ALTER COLUMN arccat_id SET NOT NULL;
ALTER TABLE arc ALTER COLUMN arc_type SET NOT NULL;
ALTER TABLE arc ALTER COLUMN epa_type SET NOT NULL;
ALTER TABLE arc ALTER COLUMN sector_id SET NOT NULL;
ALTER TABLE arc ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE arc ALTER COLUMN dma_id SET NOT NULL;
ALTER TABLE arc ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE connec ALTER COLUMN connecat_id SET NOT NULL;
ALTER TABLE connec ALTER COLUMN connec_type SET NOT NULL;
ALTER TABLE connec ALTER COLUMN sector_id SET NOT NULL;
ALTER TABLE connec ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE connec ALTER COLUMN dma_id SET NOT NULL;
ALTER TABLE connec ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE gully ALTER COLUMN gully_type SET NOT NULL;
ALTER TABLE gully ALTER COLUMN sector_id SET NOT NULL;
ALTER TABLE gully ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE gully ALTER COLUMN dma_id SET NOT NULL;
ALTER TABLE gully ALTER COLUMN expl_id SET NOT NULL;


ALTER TABLE samplepoint ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE samplepoint ALTER COLUMN expl_id SET NOT NULL;

ALTER TABLE element_x_gully ALTER COLUMN element_id SET NOT NULL;
ALTER TABLE element_x_gully ALTER COLUMN gully_id SET NOT NULL;


--EXTRA NOT NULLS

--ALTER TABLE node ALTER COLUMN inventory SET NOT NULL;
--ALTER TABLE node ALTER COLUMN state_type SET NOT NULL;
--ALTER TABLE node ALTER COLUMN workcat_id SET NOT NULL;
--ALTER TABLE node ALTER COLUMN builtdate SET NOT NULL;
--ALTER TABLE node ALTER COLUMN verified SET NOT NULL;
--ALTER TABLE node ALTER COLUMN code SET NOT NULL;
--ALTER TABLE node ALTER COLUMN the_geom SET NOT NULL;

--ALTER TABLE arc ALTER COLUMN inventory SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN state_type SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN workcat_id SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN builtdate SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN verified SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN code SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN node_1 SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN node_2 SET NOT NULL;
--ALTER TABLE arc ALTER COLUMN the_geom SET NOT NULL;


--ALTER TABLE connec ALTER COLUMN inventory SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN state_type SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN workcat_id SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN builtdate SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN verified SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN code SET NOT NULL;
--ALTER TABLE connec ALTER COLUMN the_geom SET NOT NULL;