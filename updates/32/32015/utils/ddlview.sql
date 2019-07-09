/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


  
CREATE OR REPLACE VIEW v_price_compost AS
SELECT price_compost.id,
   price_compost.unit,
   price_compost.descript,
       CASE
           WHEN price_compost.price IS NOT NULL THEN price_compost.price::numeric(14,2)
           ELSE  sum(a.price * price_compost_value.value)::numeric(14,2)
       END AS price
  FROM price_compost
    LEFT JOIN price_compost_value ON price_compost.id::text = price_compost_value.compost_id::text
    LEFT JOIN price_compost a ON a.id::text = price_compost_value.simple_id::text
 GROUP BY price_compost.id, price_compost.unit, price_compost.descript;
 
 --28/06/2019
 CREATE OR REPLACE VIEW v_ui_event_x_arc AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_arc.arc_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_arc ON om_visit_x_arc.visit_id = om_visit.id
     LEFT JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     JOIN arc ON arc.arc_id::text = om_visit_x_arc.arc_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_arc.arc_id;
  
  
CREATE OR REPLACE VIEW v_ui_event_x_connec AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_connec.connec_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_connec ON om_visit_x_connec.visit_id = om_visit.id
     JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     LEFT JOIN connec ON connec.connec_id::text = om_visit_x_connec.connec_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_connec.connec_id;
 
 
 CREATE OR REPLACE VIEW v_ui_event_x_node AS 
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    date_trunc('second'::text, om_visit_event.tstamp) AS tstamp,
    om_visit_x_node.node_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_parameter.descript,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.event_code,
        CASE
            WHEN a.event_id IS NULL THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN b.visit_id IS NULL THEN false
            ELSE true
        END AS document
   FROM om_visit
     JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     JOIN om_visit_x_node ON om_visit_x_node.visit_id = om_visit.id
     LEFT JOIN om_visit_parameter ON om_visit_parameter.id::text = om_visit_event.parameter_id::text
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON a.event_id = om_visit_event.id
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON b.visit_id = om_visit.id
  ORDER BY om_visit_x_node.node_id;


--01/07/2019
CREATE OR REPLACE VIEW v_ui_hydroval_x_connec AS 
 SELECT ext_rtc_hydrometer_x_data.id,
    rtc_hydrometer_x_connec.connec_id,
    connec.arc_id,
    ext_rtc_hydrometer_x_data.hydrometer_id,
    ext_rtc_hydrometer.cat_hydrometer_id,
    ext_cat_hydrometer.madeby,
    ext_cat_hydrometer.class,
    ext_rtc_hydrometer_x_data.cat_period_id,
    ext_rtc_hydrometer_x_data.sum,
    ext_rtc_hydrometer_x_data.custom_sum
   FROM ext_rtc_hydrometer_x_data
     JOIN ext_rtc_hydrometer ON ext_rtc_hydrometer_x_data.hydrometer_id::text = ext_rtc_hydrometer.id::text
     LEFT JOIN ext_cat_hydrometer ON ext_cat_hydrometer.id::text = ext_rtc_hydrometer.cat_hydrometer_id
     JOIN rtc_hydrometer_x_connec ON rtc_hydrometer_x_connec.hydrometer_id::text = ext_rtc_hydrometer_x_data.hydrometer_id::text
     JOIN connec ON rtc_hydrometer_x_connec.connec_id::text = connec.connec_id::text
  ORDER BY ext_rtc_hydrometer_x_data.id;
  
CREATE OR REPLACE VIEW v_ui_doc AS
SELECT doc.id,
   doc.doc_type,
   doc.path,
   doc.observ,
   doc.date,
   doc.user_name,
   doc.tstamp
  FROM doc;
  
--09/07/2019
CREATE OR REPLACE VIEW v_plan_current_psector AS
 SELECT plan_psector.psector_id,
    plan_psector.name,
    plan_psector.psector_type,
    plan_psector.descript,
    plan_psector.priority,
    a.suma::numeric(14,2) AS total_arc,
    b.suma::numeric(14,2) AS total_node,
    c.suma::numeric(14,2) AS total_other,
    plan_psector.text1,
    plan_psector.text2,
    plan_psector.observ,
    plan_psector.rotation,
    plan_psector.scale,
    plan_psector.sector_id,
    plan_psector.active,
    ((CASE WHEN a.suma IS NULL THEN 0 ELSE a.suma END)+ 
    (CASE WHEN b.suma IS NULL THEN 0 ELSE b.suma END)+ 
    (CASE WHEN c.suma IS NULL THEN 0 ELSE c.suma END))::numeric(14,2) AS pem,
    gexpenses,
    ((100::numeric + plan_psector.gexpenses) / 100::numeric)::numeric(14,2) * 
    ((CASE WHEN a.suma IS NULL THEN 0 ELSE a.suma END)+ 
    (CASE WHEN b.suma IS NULL THEN 0 ELSE b.suma END)+ 
    (CASE WHEN c.suma IS NULL THEN 0 ELSE c.suma END))::numeric(14,2) AS pec,
    plan_psector.vat,
    (((100::numeric + plan_psector.gexpenses) / 100::numeric) * ((100::numeric + plan_psector.vat) / 100::numeric))::numeric(14,2) * 
    ((CASE WHEN a.suma IS NULL THEN 0 ELSE a.suma END)+ 
    (CASE WHEN b.suma IS NULL THEN 0 ELSE b.suma END)+ 
    (CASE WHEN c.suma IS NULL THEN 0 ELSE c.suma END))::numeric(14,2) AS pec_vat,
    plan_psector.other,
    (((100::numeric + plan_psector.gexpenses) / 100::numeric) * ((100::numeric + plan_psector.vat) / 100::numeric) * ((100::numeric + plan_psector.other) / 100::numeric))::numeric(14,2) * 
    ((CASE WHEN a.suma IS NULL THEN 0 ELSE a.suma END)+ 
    (CASE WHEN b.suma IS NULL THEN 0 ELSE b.suma END)+ 
    (CASE WHEN c.suma IS NULL THEN 0 ELSE c.suma END))::numeric(14,2) AS pca,
    plan_psector.the_geom,
    d.suma AS affec_length,
    e.suma As plan_length
   FROM plan_psector
     JOIN plan_psector_selector ON plan_psector.psector_id = plan_psector_selector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_arc.total_budget) AS suma,
            v_plan_psector_x_arc.psector_id
           FROM v_plan_psector_x_arc
          GROUP BY v_plan_psector_x_arc.psector_id) a ON a.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_node.total_budget) AS suma,
            v_plan_psector_x_node.psector_id
           FROM v_plan_psector_x_node
          GROUP BY v_plan_psector_x_node.psector_id) b ON b.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(v_plan_psector_x_other.total_budget) AS suma,
            v_plan_psector_x_other.psector_id
           FROM v_plan_psector_x_other
          GROUP BY v_plan_psector_x_other.psector_id) c ON c.psector_id = plan_psector.psector_id     
     LEFT JOIN ( SELECT sum(st_length2d(arc.the_geom)::numeric(12,2)) AS suma, 
             psector_id 
            FROM arc JOIN plan_psector_x_arc USING (arc_id) WHERE plan_psector_x_arc.state=0 
            GROUP BY plan_psector_x_arc.psector_id) d ON d.psector_id = plan_psector.psector_id
     LEFT JOIN ( SELECT sum(st_length2d(arc.the_geom)::numeric(12,2)) AS suma, 
             psector_id 
            FROM arc JOIN plan_psector_x_arc USING (arc_id) WHERE plan_psector_x_arc.state=1 AND plan_psector_x_arc.doable=TRUE
            GROUP BY plan_psector_x_arc.psector_id) e ON d.psector_id = plan_psector.psector_id
  WHERE plan_psector_selector.cur_user = "current_user"()::text;
