/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;
-----------------------
-- remove all the views that are refactored in the v3.2
-----------------------
/*DROP VIEW IF EXISTS v_edit_inp_conduit;
DROP VIEW IF EXISTS v_edit_inp_junction;
DROP VIEW IF EXISTS v_edit_inp_divider;
DROP VIEW IF EXISTS v_edit_inp_orifice;
DROP VIEW IF EXISTS v_edit_inp_outfall;
DROP VIEW IF EXISTS v_edit_inp_outlet;
DROP VIEW IF EXISTS v_edit_inp_pump;
DROP VIEW IF EXISTS v_edit_inp_storage;
DROP VIEW IF EXISTS v_edit_inp_virtual;
DROP VIEW IF EXISTS v_edit_inp_weir;

DROP VIEW IF EXISTS v_edit_man_chamber;
DROP VIEW IF EXISTS v_edit_man_chamber_pol;
DROP VIEW IF EXISTS v_edit_man_conduit;
DROP VIEW IF EXISTS v_edit_man_connec;
DROP VIEW IF EXISTS v_edit_man_gully;
DROP VIEW IF EXISTS v_edit_man_gully_pol;
DROP VIEW IF EXISTS v_edit_man_junction;
DROP VIEW IF EXISTS v_edit_man_manhole;
DROP VIEW IF EXISTS v_edit_man_netelement;
DROP VIEW IF EXISTS v_edit_man_netgully_pol;
DROP VIEW IF EXISTS v_edit_man_netinit;
DROP VIEW IF EXISTS v_edit_man_outfall;
DROP VIEW IF EXISTS v_edit_man_siphon;
DROP VIEW IF EXISTS v_edit_man_storage;
DROP VIEW IF EXISTS v_edit_man_storage_pol;
DROP VIEW IF EXISTS v_edit_man_valve;
DROP VIEW IF EXISTS v_edit_man_varc;
DROP VIEW IF EXISTS v_edit_man_waccel;
DROP VIEW IF EXISTS v_edit_man_wjump;
DROP VIEW IF EXISTS v_edit_man_wwtp;
DROP VIEW IF EXISTS v_edit_man_wwtp_pol;
*/



DROP VIEW IF EXISTS vp_basic_arc;
CREATE OR REPLACE VIEW vp_basic_arc AS 
 SELECT v_edit_arc.arc_id AS nid,
    v_edit_arc.arc_type AS custom_type
   FROM v_edit_arc;
   
  
DROP VIEW IF EXISTS vp_basic_node;
CREATE OR REPLACE VIEW vp_basic_node AS 
 SELECT v_edit_node.node_id AS nid,
    v_edit_node.node_type AS custom_type
   FROM v_edit_node;
   
   
DROP VIEW IF EXISTS vp_basic_connec ;
CREATE OR REPLACE VIEW vp_basic_connec AS 
 SELECT .connec_id AS nid,
    v_edit_connec.connec_type AS custom_type
   FROM SCHEMA_NAME.v_edit_connec;
   

DROP VIEW IF EXISTS vp_basic_gully;
CREATE OR REPLACE VIEW vp_basic_gully AS 
 SELECT v_edit_arc.arc_id AS nid,
    v_edit_arc.arc_type AS custom_type
   FROM v_edit_arc;

	
	
DROP VIEW IF EXISTS ve_inp_junction;
CREATE OR REPLACE VIEW ve_inp_junction AS 
 SELECT v_node.node_id,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
        CASE
            WHEN v_node.sys_elev IS NOT NULL THEN v_node.sys_elev
            ELSE (v_node.sys_top_elev - v_node.sys_ymax)::numeric(12,3)
        END AS sys_elev,
    v_node.nodecat_id,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.the_geom,
    v_node.annotation,
    inp_junction.y0,
    inp_junction.ysur,
    inp_junction.apond
   FROM inp_selector_sector,
    v_node
     JOIN inp_junction ON inp_junction.node_id::text = v_node.node_id::text
  WHERE v_node.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text;
	
	
DROP VIEW IF EXISTS ve_inp_storage;
CREATE VIEW ve_inp_storage AS
SELECT 
v_node.node_id, 
top_elev,
custom_top_elev,
ymax,
custom_ymax,
elev,
custom_elev,
        CASE
            WHEN v_node.sys_elev IS NOT NULL THEN v_node.sys_elev
            ELSE (v_node.sys_top_elev - v_node.sys_ymax)::numeric(12,3)
        END AS sys_elev,
nodecat_id, 
v_node.sector_id, 
macrosector_id,"state", 
the_geom,
inp_storage.storage_type, 
inp_storage.curve_id, 
inp_storage.a1, 
inp_storage.a2,
inp_storage.a0, 
inp_storage.fevap, 
inp_storage.sh, 
inp_storage.hc, 
inp_storage.imd, 
inp_storage.y0, 
inp_storage.ysur
FROM inp_selector_sector, v_node
    JOIN inp_storage ON (((v_node.node_id) = (inp_storage.node_id)))
    WHERE ((v_node.sector_id)=(inp_selector_sector.sector_id) AND inp_selector_sector.cur_user="current_user"());



CREATE OR REPLACE VIEW v_edit_inp_divider AS 
 SELECT v_node.node_id,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
        CASE
            WHEN v_node.sys_elev IS NOT NULL THEN v_node.sys_elev
            ELSE (v_node.sys_top_elev - v_node.sys_ymax)::numeric(12,3)
        END AS sys_elev,
    v_node.nodecat_id,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.annotation,
    v_node.the_geom,
    inp_divider.divider_type,
    inp_divider.arc_id,
    inp_divider.curve_id,
    inp_divider.qmin,
    inp_divider.ht,
    inp_divider.cd,
    inp_divider.y0,
    inp_divider.ysur,
    inp_divider.apond
   FROM inp_selector_sector,
    v_node
     JOIN inp_divider ON v_node.node_id::text = inp_divider.node_id::text
  WHERE v_node.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text;



DROP VIEW ve_inp_outfall;

CREATE OR REPLACE VIEW ve_inp_outfall AS 
 SELECT v_node.node_id,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
        CASE
            WHEN v_node.sys_elev IS NOT NULL THEN v_node.sys_elev
            ELSE (v_node.sys_top_elev - v_node.sys_ymax)::numeric(12,3)
        END AS sys_elev,
    v_node.nodecat_id,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.the_geom,
    v_node.annotation,
    inp_outfall.outfall_type,
    inp_outfall.stage,
    inp_outfall.curve_id,
    inp_outfall.timser_id,
    inp_outfall.gate
   FROM inp_selector_sector,
    v_node
     JOIN inp_outfall ON v_node.node_id::text = inp_outfall.node_id::text
  WHERE v_node.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text;



-----------------------
-- create views ve
-----------------------
DROP VIEW IF EXISTS ve_arc;
CREATE OR REPLACE VIEW ve_arc AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.code,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.sys_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id AS cat_matcat_id,
    v_arc_x_node.shape AS cat_shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value
   FROM v_arc_x_node;


DROP VIEW IF EXISTS ve_node;
CREATE OR REPLACE VIEW ve_node AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.sys_type,
    v_node.nodecat_id,
    v_node.cat_matcat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.postcomplement2,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.descript,
    v_node.svg,
    v_node.rotation,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node;


DROP VIEW IF EXISTS ve_connec;
CREATE OR REPLACE VIEW ve_connec AS 
 SELECT connec.connec_id,
    connec.code,
    connec.customer_code,
    connec.top_elev,
    connec.y1,
    connec.y2,
    connec.connecat_id,
    connec.connec_type,
    connec_type.type AS sys_type,
    connec.private_connecat_id,
    cat_connec.matcat_id AS cat_matcat_id,
    connec.sector_id,
    sector.macrosector_id,
    connec.demand,
    connec.state,
    connec.state_type,
    connec.connec_depth,
    connec.connec_length,
    connec.arc_id,
    connec.annotation,
    connec.observ,
    connec.comment,
    connec.dma_id,
    connec.soilcat_id,
    connec.function_type,
    connec.category_type,
    connec.fluid_type,
    connec.location_type,
    connec.workcat_id,
    connec.workcat_id_end,
    connec.buildercat_id,
    connec.builtdate,
    connec.enddate,
    connec.ownercat_id,
    connec.muni_id,
    connec.postcode,
    connec.streetaxis_id,
    connec.postnumber,
    connec.postcomplement,
    connec.streetaxis2_id,
    connec.postnumber2,
    connec.postcomplement2,
    connec.descript,
    cat_connec.svg,
    connec.rotation,
    concat(connec_type.link_path, connec.link) AS link,
    connec.verified,
    connec.the_geom,
    connec.undelete,
    connec.featurecat_id,
    connec.feature_id,
    connec.label_x,
    connec.label_y,
    connec.label_rotation,
    connec.accessibility,
    connec.diagonal,
    connec.publish,
    connec.inventory,
    connec.uncertain,
    dma.macrodma_id,
    connec.expl_id,
    connec.num_value
   FROM connec
     JOIN v_state_connec ON connec.connec_id::text = v_state_connec.connec_id::text
     JOIN cat_connec ON connec.connecat_id::text = cat_connec.id::text
     LEFT JOIN ext_streetaxis ON connec.streetaxis_id::text = ext_streetaxis.id::text
     LEFT JOIN dma ON connec.dma_id = dma.dma_id
     LEFT JOIN sector ON connec.sector_id = sector.sector_id
     LEFT JOIN connec_type ON connec.connec_type::text = connec_type.id::text;


DROP VIEW IF EXISTS ve_gully;
CREATE OR REPLACE VIEW ve_gully AS 
 SELECT gully.gully_id,
    gully.code,
    gully.top_elev,
    gully.ymax,
    gully.sandbox,
    gully.matcat_id,
    gully.gully_type,
    gully_type.type AS sys_type,
    gully.gratecat_id,
    cat_grate.matcat_id AS cat_grate_matcat,
    gully.units,
    gully.groove,
    gully.siphon,
    gully.connec_arccat_id,
    gully.connec_length,
    gully.connec_depth,
    gully.arc_id,
    gully.sector_id,
    sector.macrosector_id,
    gully.state,
    gully.state_type,
    gully.annotation,
    gully.observ,
    gully.comment,
    gully.dma_id,
    gully.soilcat_id,
    gully.function_type,
    gully.category_type,
    gully.fluid_type,
    gully.location_type,
    gully.workcat_id,
    gully.workcat_id_end,
    gully.buildercat_id,
    gully.builtdate,
    gully.enddate,
    gully.ownercat_id,
    gully.muni_id,
    gully.postcode,
    gully.streetaxis_id,
    gully.postnumber,
    gully.postcomplement,
    gully.streetaxis2_id,
    gully.postnumber2,
    gully.postcomplement2,
    gully.descript,
    cat_grate.svg,
    gully.rotation,
    concat(gully_type.link_path, gully.link) AS link,
    gully.verified,
    gully.the_geom,
    gully.undelete,
    gully.featurecat_id,
    gully.feature_id,
    gully.label_x,
    gully.label_y,
    gully.label_rotation,
    gully.publish,
    gully.inventory,
    gully.expl_id,
    dma.macrodma_id,
    gully.uncertain,
    gully.num_value
   FROM gully
     JOIN v_state_gully ON gully.gully_id::text = v_state_gully.gully_id::text
     LEFT JOIN cat_grate ON gully.gratecat_id::text = cat_grate.id::text
     LEFT JOIN ext_streetaxis ON gully.streetaxis_id::text = ext_streetaxis.id::text
     LEFT JOIN dma ON gully.dma_id = dma.dma_id
     LEFT JOIN sector ON gully.sector_id = sector.sector_id
     LEFT JOIN gully_type ON gully.gully_type::text = gully_type.id::text;



-----------------------
-- create parent views
-----------------------
DROP VIEW IF EXISTS vp_arc;
CREATE OR REPLACE VIEW vp_arc AS 
 SELECT ve_arc.arc_id AS nid,
    ve_arc.arc_type AS custom_type
   FROM ve_arc;

DROP VIEW IF EXISTS vp_connec;
CREATE OR REPLACE VIEW vp_connec AS 
 SELECT ve_connec.connec_id AS nid,
    ve_connec.connec_type AS custom_type
   FROM ve_connec;

DROP VIEW IF EXISTS vp_node;
CREATE OR REPLACE VIEW vp_node AS 
 SELECT ve_node.node_id AS nid,
    ve_node.node_type AS custom_type
   FROM ve_node;

DROP VIEW IF EXISTS vp_gully;
CREATE OR REPLACE VIEW vp_gully AS 
 SELECT ve_gully.arc_id AS nid,
    ve_gully.gully_type AS custom_type
   FROM ve_gully;

-----------------------
-- create child views
-----------------------

DROP VIEW IF EXISTS ve_node_chamber;
CREATE OR REPLACE VIEW ve_node_chamber AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_chamber.pol_id,
    man_chamber.length,
    man_chamber.width,
    man_chamber.sander_depth,
    man_chamber.max_volume,
    man_chamber.util_volume,
    man_chamber.inlet,
    man_chamber.bottom_channel,
    man_chamber.accessibility,
    man_chamber.name,
    a.chamber_param_1,
    a.chamber_param_2,
    a.chamber_param_3
   FROM SCHEMA_NAME.v_node
     JOIN SCHEMA_NAME.man_chamber ON man_chamber.node_id::text = v_node.node_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.chamber_param_1,ct.chamber_param_2, ct.chamber_param_3
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''CHAMBER''
                    ORDER  BY 1,2'::text, ' VALUES (''3''),(''4''),(''5'')'::text) 
                    ct(feature_id character varying, chamber_param_1 text, chamber_param_2 text, chamber_param_3 text)) a ON a.feature_id::text = v_node.node_id::text
                    WHERE v_node.node_type::text = 'CHAMBER'::text;



DROP VIEW IF EXISTS ve_node_weir;
CREATE OR REPLACE VIEW ve_node_weir AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_chamber.pol_id,
    man_chamber.length,
    man_chamber.width,
    man_chamber.sander_depth,
    man_chamber.max_volume,
    man_chamber.util_volume,
    man_chamber.inlet,
    man_chamber.bottom_channel,
    man_chamber.accessibility,
    man_chamber.name
   FROM v_node
     JOIN man_chamber ON man_chamber.node_id::text = v_node.node_id::text
      WHERE node_type = 'WEIR';


DROP VIEW IF EXISTS ve_node_pumpstation;
CREATE OR REPLACE VIEW ve_node_pumpstation AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_chamber.pol_id,
    man_chamber.length,
    man_chamber.width,
    man_chamber.sander_depth,
    man_chamber.max_volume,
    man_chamber.util_volume,
    man_chamber.inlet,
    man_chamber.bottom_channel,
    man_chamber.accessibility,
    man_chamber.name
   FROM v_node
     JOIN man_chamber ON man_chamber.node_id::text = v_node.node_id::text
     WHERE node_type = 'PUMP-STATION';



DROP VIEW IF EXISTS ve_node_register;
CREATE OR REPLACE VIEW ve_node_register AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node
     JOIN man_junction ON man_junction.node_id::text = v_node.node_id::text
     WHERE node_type = 'REGISTER';


DROP VIEW IF EXISTS ve_node_change;
CREATE OR REPLACE VIEW ve_node_change AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node
     JOIN man_junction ON man_junction.node_id::text = v_node.node_id::text
     WHERE node_type = 'CHANGE';


DROP VIEW IF EXISTS ve_node_vnode;
CREATE OR REPLACE VIEW ve_node_vnode AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node
     JOIN man_junction ON man_junction.node_id::text = v_node.node_id::text
     WHERE node_type = 'VNODE';


DROP VIEW IF EXISTS ve_node_junction;
CREATE OR REPLACE VIEW ve_node_junction AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node
     JOIN man_junction ON man_junction.node_id::text = v_node.node_id::text
     WHERE node_type = 'JUNCTION';


DROP VIEW IF EXISTS ve_node_highpoint;
CREATE OR REPLACE VIEW ve_node_highpoint AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value
   FROM v_node
     JOIN man_junction ON man_junction.node_id::text = v_node.node_id::text
     WHERE node_type = 'HIGHPOINT';



DROP VIEW IF EXISTS ve_node_circmanhole;
CREATE OR REPLACE VIEW ve_node_circmanhole AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_manhole.length,
    man_manhole.width,
    man_manhole.sander_depth,
    man_manhole.prot_surface,
    man_manhole.inlet,
    man_manhole.bottom_channel,
    man_manhole.accessibility,
    a.circmanhole_param_1,
    a.circmanhole_param_2,
    a.circmanhole_param_3
   FROM SCHEMA_NAME.v_node
     JOIN SCHEMA_NAME.man_manhole ON man_manhole.node_id::text = v_node.node_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.circmanhole_param_1,ct.circmanhole_param_2, ct.circmanhole_param_3
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''CIRC-MANHOLE''
                    ORDER  BY 1,2'::text, ' VALUES (''10''),(''11''),(''12'')'::text) 
                    ct(feature_id character varying, circmanhole_param_1 text, circmanhole_param_2 text, circmanhole_param_3 text)) a ON a.feature_id::text = v_node.node_id::text
                    WHERE v_node.node_type::text = 'CIRC-MANHOLE'::text;


DROP VIEW IF EXISTS ve_node_rectmanhole;
CREATE OR REPLACE VIEW ve_node_rectmanhole AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_manhole.length,
    man_manhole.width,
    man_manhole.sander_depth,
    man_manhole.prot_surface,
    man_manhole.inlet,
    man_manhole.bottom_channel,
    man_manhole.accessibility,
    a.rectmanhole_param_1,
    a.rectmanhole_param_2
   FROM SCHEMA_NAME.v_node
     JOIN SCHEMA_NAME.man_manhole ON man_manhole.node_id::text = v_node.node_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.rectmanhole_param_1,ct.rectmanhole_param_2
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''RECT-MANHOLE''
                    ORDER  BY 1,2'::text, ' VALUES (''22''),(''23'')'::text) 
                    ct(feature_id character varying, rectmanhole_param_1 text, rectmanhole_param_2 text)) a ON a.feature_id::text = v_node.node_id::text
                    WHERE v_node.node_type::text = 'RECT-MANHOLE'::text;



DROP VIEW IF EXISTS ve_node_netelement;
CREATE OR REPLACE VIEW ve_node_netelement AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_netelement.serial_number
   FROM v_node
     JOIN man_netelement ON man_netelement.node_id::text = v_node.node_id::text
     WHERE node_type = 'NETELEMENT';



DROP VIEW IF EXISTS ve_node_netgully;
CREATE OR REPLACE VIEW ve_node_netgully AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_netgully.pol_id,
    man_netgully.sander_depth,
    man_netgully.gratecat_id,
    man_netgully.units,
    man_netgully.groove,
    man_netgully.siphon
   FROM v_node
     JOIN man_netgully ON man_netgully.node_id::text = v_node.node_id::text
     WHERE node_type = 'NETGULLY';



DROP VIEW IF EXISTS ve_node_sandbox;
CREATE OR REPLACE VIEW ve_node_sandbox AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_netinit.length,
    man_netinit.width,
    man_netinit.inlet,
    man_netinit.bottom_channel,
    man_netinit.accessibility,
    man_netinit.name,
    man_netinit.sander_depth
   FROM v_node
     JOIN man_netinit ON man_netinit.node_id::text = v_node.node_id::text
     WHERE node_type = 'SANDBOX';



DROP VIEW IF EXISTS ve_node_outfall;
CREATE OR REPLACE VIEW ve_node_outfall AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_outfall.name
   FROM v_node
     JOIN man_outfall ON man_outfall.node_id::text = v_node.node_id::text
     WHERE node_type = 'OUFALL';




DROP VIEW IF EXISTS ve_node_overflowstorage;
CREATE OR REPLACE VIEW ve_node_overflowstorage AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_storage.pol_id,
    man_storage.length,
    man_storage.width,
    man_storage.custom_area,
    man_storage.max_volume,
    man_storage.util_volume,
    man_storage.min_height,
    man_storage.accessibility,
    man_storage.name
   FROM v_node
     JOIN man_storage ON man_storage.node_id::text = v_node.node_id::text
     WHERE node_type = 'OWERFLOW-STORAGE';



DROP VIEW IF EXISTS ve_node_sewerstorage;
CREATE OR REPLACE VIEW ve_node_sewerstorage AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_storage.pol_id,
    man_storage.length,
    man_storage.width,
    man_storage.custom_area,
    man_storage.max_volume,
    man_storage.util_volume,
    man_storage.min_height,
    man_storage.accessibility,
    man_storage.name,
    a.sewerstorage_param_1,
    a.sewerstorage_param_2
   FROM SCHEMA_NAME.v_node
     JOIN SCHEMA_NAME.man_storage ON man_storage.node_id::text = v_node.node_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.sewerstorage_param_1,ct.sewerstorage_param_2
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''SEWER-STORAGE''
                    ORDER  BY 1,2'::text, ' VALUES (''24''),(''25'')'::text) 
                    ct(feature_id character varying, sewerstorage_param_1 text, sewerstorage_param_2 text)) a ON a.feature_id::text = v_node.node_id::text
                    WHERE v_node.node_type::text = 'SEWER-STORAGE'::text;



DROP VIEW IF EXISTS ve_node_valve;
CREATE OR REPLACE VIEW ve_node_valve AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_valve.name,
    a.valve_param_1,
    a.valve_param_2
   FROM SCHEMA_NAME.v_node
     JOIN SCHEMA_NAME.man_valve ON man_valve.node_id::text = v_node.node_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.valve_param_1,ct.valve_param_2
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''VALVE''
                    ORDER  BY 1,2'::text, ' VALUES (''26''),(''27'')'::text) 
                    ct(feature_id character varying, valve_param_1 text, valve_param_2 text)) a ON a.feature_id::text = v_node.node_id::text
                    WHERE v_node.node_type::text = 'VALVE'::text;



DROP VIEW IF EXISTS ve_node_jump;
CREATE OR REPLACE VIEW ve_node_jump AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_wjump.length,
    man_wjump.width,
    man_wjump.sander_depth,
    man_wjump.prot_surface,
    man_wjump.accessibility,
    man_wjump.name
   FROM v_node
     JOIN man_wjump ON man_wjump.node_id::text = v_node.node_id::text
     WHERE node_type = 'JUMP';



DROP VIEW IF EXISTS ve_node_wwtp;
CREATE OR REPLACE VIEW ve_node_wwtp AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.top_elev,
    v_node.custom_top_elev,
    v_node.ymax,
    v_node.custom_ymax,
    v_node.elev,
    v_node.custom_elev,
    v_node.sys_elev,
    v_node.node_type,
    v_node.nodecat_id,
    v_node.epa_type,
    v_node.sector_id,
    v_node.macrosector_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.dma_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.buildercat_id,
    v_node.builtdate,
    v_node.enddate,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.streetaxis_id,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetaxis2_id,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.rotation,
    v_node.svg,
    v_node.link,
    v_node.verified,
    v_node.the_geom,
    v_node.undelete,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.uncertain,
    v_node.xyz_date,
    v_node.unconnected,
    v_node.macrodma_id,
    v_node.expl_id,
    v_node.num_value,
    man_wwtp.pol_id,
    man_wwtp.name
   FROM v_node
     JOIN man_wwtp ON man_wwtp.node_id::text = v_node.node_id::text
     WHERE node_type = 'WWTP';


--arc

DROP VIEW IF EXISTS ve_arc_pumppipe;
CREATE OR REPLACE VIEW ve_arc_pumppipe AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.code,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id,
    v_arc_x_node.shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value
   FROM v_arc_x_node
     JOIN man_conduit ON man_conduit.arc_id::text = v_arc_x_node.arc_id::text
     WHERE arc_type = 'PUMP-PIPE';




DROP VIEW IF EXISTS ve_arc_conduit;
CREATE OR REPLACE VIEW ve_arc_conduit AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.code,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id,
    v_arc_x_node.shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value,
    a.conduit_param_1,
    a.conduit_param_2
   FROM SCHEMA_NAME.v_arc_x_node
     JOIN SCHEMA_NAME.man_conduit ON man_conduit.arc_id::text = v_arc_x_node.arc_id::text
     LEFT JOIN ( SELECT ct.feature_id, ct.conduit_param_1,ct.conduit_param_2
            FROM crosstab('SELECT feature_id, parameter_id, value_param
                    FROM SCHEMA_NAME.man_addfields_value JOIN SCHEMA_NAME.man_addfields_parameter on man_addfields_parameter.id=parameter_id where cat_feature_id=''CONDUIT''
                    ORDER  BY 1,2'::text, ' VALUES (''30''),(''31'')'::text) 
                    ct(feature_id character varying, conduit_param_1 text, conduit_param_2 text)) a ON a.feature_id::text = v_arc_x_node.arc_id::text
                    WHERE v_arc_x_node.arc_type::text = 'CONDUIT'::text;



DROP VIEW IF EXISTS ve_arc_siphon;
CREATE OR REPLACE VIEW ve_arc_siphon AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.code,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id,
    v_arc_x_node.shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value,
    man_siphon.name
   FROM v_arc_x_node
     JOIN man_siphon ON man_siphon.arc_id::text = v_arc_x_node.arc_id::text
     WHERE arc_type = 'SIPHON';




DROP VIEW IF EXISTS ve_arc_varc;
CREATE OR REPLACE VIEW ve_arc_varc AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.code,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id,
    v_arc_x_node.shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value
   FROM v_arc_x_node
     JOIN man_varc ON man_varc.arc_id::text = v_arc_x_node.arc_id::text
     WHERE arc_type = 'VARC';


DROP VIEW IF EXISTS ve_arc_waccel;
CREATE OR REPLACE VIEW ve_arc_waccel AS 
 SELECT v_arc_x_node.arc_id,
    v_arc_x_node.node_1,
    v_arc_x_node.node_2,
    v_arc_x_node.y1,
    v_arc_x_node.custom_y1,
    v_arc_x_node.elev1,
    v_arc_x_node.custom_elev1,
    v_arc_x_node.sys_elev1,
    v_arc_x_node.y2,
    v_arc_x_node.elev2,
    v_arc_x_node.custom_y2,
    v_arc_x_node.custom_elev2,
    v_arc_x_node.sys_elev2,
    v_arc_x_node.z1,
    v_arc_x_node.z2,
    v_arc_x_node.r1,
    v_arc_x_node.r2,
    v_arc_x_node.slope,
    v_arc_x_node.arc_type,
    v_arc_x_node.arccat_id,
    v_arc_x_node.matcat_id,
    v_arc_x_node.shape,
    v_arc_x_node.geom1 AS cat_geom1,
    v_arc_x_node.geom2 AS cat_geom2,
    v_arc_x_node.gis_length,
    v_arc_x_node.epa_type,
    v_arc_x_node.sector_id,
    v_arc_x_node.macrosector_id,
    v_arc_x_node.state,
    v_arc_x_node.state_type,
    v_arc_x_node.annotation,
    v_arc_x_node.observ,
    v_arc_x_node.comment,
    v_arc_x_node.inverted_slope,
    v_arc_x_node.custom_length,
    v_arc_x_node.dma_id,
    v_arc_x_node.soilcat_id,
    v_arc_x_node.function_type,
    v_arc_x_node.category_type,
    v_arc_x_node.fluid_type,
    v_arc_x_node.location_type,
    v_arc_x_node.workcat_id,
    v_arc_x_node.workcat_id_end,
    v_arc_x_node.buildercat_id,
    v_arc_x_node.builtdate,
    v_arc_x_node.enddate,
    v_arc_x_node.ownercat_id,
    v_arc_x_node.muni_id,
    v_arc_x_node.postcode,
    v_arc_x_node.streetaxis_id,
    v_arc_x_node.postnumber,
    v_arc_x_node.postcomplement,
    v_arc_x_node.streetaxis2_id,
    v_arc_x_node.postnumber2,
    v_arc_x_node.postcomplement2,
    v_arc_x_node.descript,
    v_arc_x_node.link,
    v_arc_x_node.verified,
    v_arc_x_node.the_geom,
    v_arc_x_node.undelete,
    v_arc_x_node.label_x,
    v_arc_x_node.label_y,
    v_arc_x_node.label_rotation,
    v_arc_x_node.code,
    v_arc_x_node.publish,
    v_arc_x_node.inventory,
    v_arc_x_node.uncertain,
    v_arc_x_node.macrodma_id,
    v_arc_x_node.expl_id,
    v_arc_x_node.num_value,
    man_waccel.sander_length,
    man_waccel.sander_depth,
    man_waccel.prot_surface,
    man_waccel.name,
    man_waccel.accessibility
   FROM v_arc_x_node
     JOIN man_waccel ON man_waccel.arc_id::text = v_arc_x_node.arc_id::text
     WHERE arc_type = 'WACCEL';


-----------------------
-- polygon views
-----------------------

DROP VIEW IF EXISTS ve_pol_chamber;
CREATE OR REPLACE VIEW ve_pol_chamber AS 
 SELECT man_chamber.pol_id,
    v_node.node_id,
    polygon.the_geom
   FROM v_node
     JOIN man_chamber ON man_chamber.node_id::text = v_node.node_id::text
     JOIN polygon ON polygon.pol_id::text = man_chamber.pol_id::text;

DROP VIEW IF EXISTS ve_pol_gully;
CREATE OR REPLACE VIEW ve_pol_gully AS 
 SELECT gully.pol_id,
    gully.gully_id,
    polygon.the_geom
   FROM gully
     JOIN v_state_gully ON gully.gully_id::text = v_state_gully.gully_id::text
     JOIN polygon ON polygon.pol_id::text = gully.pol_id::text;

DROP VIEW IF EXISTS ve_pol_netgully;
CREATE OR REPLACE VIEW ve_pol_netgully AS 
 SELECT man_netgully.pol_id,
    v_node.node_id,
    polygon.the_geom
   FROM v_node
     JOIN man_netgully ON man_netgully.node_id::text = v_node.node_id::text
     JOIN polygon ON polygon.pol_id::text = man_netgully.pol_id::text;

DROP VIEW IF EXISTS ve_pol_storage;
CREATE OR REPLACE VIEW ve_pol_storage AS 
 SELECT man_storage.pol_id,
    v_node.node_id,
    polygon.the_geom
   FROM v_node
     JOIN man_storage ON man_storage.node_id::text = v_node.node_id::text
     JOIN polygon ON polygon.pol_id::text = man_storage.pol_id::text;

DROP VIEW IF EXISTS ve_pol_wwtp;
CREATE OR REPLACE VIEW ve_pol_wwtp AS 
 SELECT man_wwtp.pol_id,
    v_node.node_id,
    polygon.the_geom
   FROM v_node
     JOIN man_wwtp ON man_wwtp.node_id::text = v_node.node_id::text
     JOIN polygon ON polygon.pol_id::text = man_wwtp.pol_id::text;

