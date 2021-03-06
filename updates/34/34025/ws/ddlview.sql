/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/11/20
CREATE OR REPLACE VIEW v_edit_inp_valve AS 
 SELECT DISTINCT ON (a.node_id) a.node_id,
    a.elevation,
    a.depth,
    a.nodecat_id,
    a.sector_id,
    a.macrosector_id,
    a.state,
    a.state_type,
    a.annotation,
    a.expl_id,
    a.valv_type,
    a.pressure,
    a.flow,
    a.coef_loss,
    a.curve_id,
    a.minorloss,
    a.to_arc,
    a.status,
    a.the_geom,
	a.custom_dint
   FROM ( SELECT v_node.node_id,
            v_node.elevation,
            v_node.depth,
            v_node.nodecat_id,
            v_node.sector_id,
            v_node.macrosector_id,
            v_node.state,
            v_node.state_type,
            v_node.annotation,
            v_node.expl_id,
            inp_valve.valv_type,
            inp_valve.pressure,
            inp_valve.flow,
            inp_valve.coef_loss,
            inp_valve.curve_id,
            inp_valve.minorloss,
            inp_valve.to_arc,
            inp_valve.status,
            v_node.the_geom,
            inp_valve.custom_dint
           FROM v_node
             JOIN inp_valve USING (node_id)
             JOIN vi_parent_arc a_1 ON a_1.node_1::text = v_node.node_id::text
        UNION
         SELECT v_node.node_id,
            v_node.elevation,
            v_node.depth,
            v_node.nodecat_id,
            v_node.sector_id,
            v_node.macrosector_id,
            v_node.state,
            v_node.state_type,
            v_node.annotation,
            v_node.expl_id,
            inp_valve.valv_type,
            inp_valve.pressure,
            inp_valve.flow,
            inp_valve.coef_loss,
            inp_valve.curve_id,
            inp_valve.minorloss,
            inp_valve.to_arc,
            inp_valve.status,
            v_node.the_geom,
            inp_valve.custom_dint
           FROM v_node
             JOIN inp_valve USING (node_id)
             JOIN vi_parent_arc a_1 ON a_1.node_2::text = v_node.node_id::text) a;
             
--2020/12/01
CREATE OR REPLACE VIEW v_edit_node AS 
 SELECT v_node.node_id,
    v_node.code,
    v_node.elevation,
    v_node.depth,
    v_node.node_type,
    v_node.sys_type,
    v_node.nodecat_id,
    v_node.cat_matcat_id,
    v_node.cat_pnom,
    v_node.cat_dnom,
    v_node.epa_type,
    v_node.expl_id,
    v_node.macroexpl_id,
    v_node.sector_id,
    v_node.sector_name,
    v_node.macrosector_id,
    v_node.arc_id,
    v_node.parent_id,
    v_node.state,
    v_node.state_type,
    v_node.annotation,
    v_node.observ,
    v_node.comment,
    v_node.minsector_id,
    v_node.dma_id,
    v_node.dma_name,
    v_node.macrodma_id,
    v_node.presszone_id,
    v_node.presszone_name,
    v_node.staticpressure,
    v_node.dqa_id,
    v_node.dqa_name,
    v_node.macrodqa_id,
    v_node.soilcat_id,
    v_node.function_type,
    v_node.category_type,
    v_node.fluid_type,
    v_node.location_type,
    v_node.workcat_id,
    v_node.workcat_id_end,
    v_node.builtdate,
    v_node.enddate,
    v_node.buildercat_id,
    v_node.ownercat_id,
    v_node.muni_id,
    v_node.postcode,
    v_node.district_id,
    v_node.streetname,
    v_node.postnumber,
    v_node.postcomplement,
    v_node.streetname2,
    v_node.postnumber2,
    v_node.postcomplement2,
    v_node.descript,
    v_node.svg,
    v_node.rotation,
    v_node.link,
    v_node.verified,
    v_node.undelete,
    v_node.label,
    v_node.label_x,
    v_node.label_y,
    v_node.label_rotation,
    v_node.publish,
    v_node.inventory,
    v_node.hemisphere,
    v_node.num_value,
    v_node.nodetype_id,
    v_node.tstamp,
    v_node.insert_user,
    v_node.lastupdate,
    v_node.lastupdate_user,
    v_node.the_geom,
    v_node.adate,
    v_node.adescript,
    v_node.accessibility,
    v_node.dma_style,
    v_node.presszone_style,
    man_valve.closed AS closed_valve,
    man_valve.broken AS broken_valve
   FROM v_node
   LEFT JOIN man_valve USING (node_id);
   
   
   
CREATE OR REPLACE VIEW v_om_mincut_selected_valve AS 
 SELECT v_node.node_id,
    v_node.nodetype_id,
    man_valve.closed,
    man_valve.broken,
    v_node.the_geom
   FROM v_node
     JOIN man_valve ON v_node.node_id::text = man_valve.node_id::text
     JOIN config_mincut_valve ON v_node.nodetype_id::text = config_mincut_valve.id::text
  WHERE config_mincut_valve.active IS TRUE;