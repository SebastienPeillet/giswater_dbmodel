/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
SET search_path = "SCHEMA_NAME", public, pg_catalog;


/*
DROP VIEW IF EXISTS v_rtc_hydrometer CASCADE;
CREATE OR REPLACE VIEW v_rtc_hydrometer AS
SELECT
rtc_hydrometer.hydrometer_id,
rtc_hydrometer_x_connec.connec_id,
connec.code as urban_propierties_code,
    ext_rtc_hydrometer.code,
    ext_rtc_hydrometer.hydrometer_category,
    ext_rtc_hydrometer.house_number,
    ext_rtc_hydrometer.id_number,
    ext_rtc_hydrometer.cat_hydrometer_id,
    ext_rtc_hydrometer.hydrometer_number,
    ext_rtc_hydrometer.identif,

    ext_cat_hydrometer.id,
    ext_cat_hydrometer.madeby,
    ext_cat_hydrometer.class,
    ext_cat_hydrometer.ulmc,
    ext_cat_hydrometer.voltman_flow,
    ext_cat_hydrometer.multi_jet_flow,
    ext_cat_hydrometer.dnom

FROM rtc_hydrometer
LEFT JOIN ext_rtc_hydrometer ON ext_rtc_hydrometer.hydrometer_id::text = rtc_hydrometer.hydrometer_id
LEFT JOIN ext_cat_hydrometer ON ext_cat_hydrometer.id::text = ext_rtc_hydrometer.cat_hydrometer_id::text
JOIN rtc_hydrometer_x_connec ON rtc_hydrometer_x_connec.hydrometer_id::text = rtc_hydrometer.hydrometer_id
JOIN  connec ON rtc_hydrometer_x_connec.connec_id=connec.connec_id;




CREATE OR REPLACE VIEW v_rtc_hydrometer_period AS 
 SELECT ext_rtc_hydrometer.hydrometer_id,
    ext_cat_period.id AS period_id,
    connec.dma_id,
        CASE
            WHEN ext_rtc_hydrometer_x_data.custom_sum IS NOT NULL THEN ext_rtc_hydrometer_x_data.custom_sum
            ELSE ext_rtc_hydrometer_x_data.sum
        END AS m3_total_period,
        CASE
            WHEN ext_rtc_hydrometer_x_data.custom_sum IS NOT NULL THEN ext_rtc_hydrometer_x_data.custom_sum * 1000::double precision / ext_cat_period.period_seconds::double precision
            ELSE ext_rtc_hydrometer_x_data.sum * 1000::double precision / ext_cat_period.period_seconds::double precision
        END AS lps_avg
   FROM ext_rtc_hydrometer
     JOIN ext_rtc_hydrometer_x_data ON ext_rtc_hydrometer_x_data.hydrometer_id::integer = ext_rtc_hydrometer.hydrometer_id
     JOIN ext_cat_period ON ext_rtc_hydrometer_x_data.cat_period_id::text = ext_cat_period.id::text
     JOIN rtc_hydrometer_x_connec ON rtc_hydrometer_x_connec.hydrometer_id::integer = ext_rtc_hydrometer.hydrometer_id
     JOIN connec ON connec.connec_id::text = rtc_hydrometer_x_connec.connec_id::text
     JOIN rtc_options ON rtc_options.period_id::text = ext_cat_period.id::text;



DROP VIEW IF EXISTS v_rtc_dma_hydrometer_period CASCADE;
CREATE OR REPLACE VIEW v_rtc_dma_hydrometer_period AS 
 SELECT v_rtc_hydrometer_period.dma_id, 
    ext_cat_period.id AS period_id, 
    sum(v_rtc_hydrometer_period.m3_total_period) AS m3_total_period, 
    ext_cat_period.period_seconds
   FROM v_rtc_hydrometer_period
   JOIN ext_rtc_hydrometer_x_data ON ext_rtc_hydrometer_x_data.hydrometer_id::text = v_rtc_hydrometer_period.hydrometer_id::text
   JOIN rtc_options ON rtc_options.period_id::text = ext_rtc_hydrometer_x_data.cat_period_id::text
   JOIN ext_cat_period ON rtc_options.period_id::text = ext_cat_period.id::text
  GROUP BY v_rtc_hydrometer_period.dma_id, ext_cat_period.id, ext_cat_period.period_seconds;


DROP VIEW IF EXISTS v_rtc_dma_parameter_period CASCADE;
CREATE OR REPLACE VIEW v_rtc_dma_parameter_period AS 
 SELECT v_rtc_dma_hydrometer_period.dma_id, 
    v_rtc_dma_hydrometer_period.period_id, 
    v_rtc_dma_hydrometer_period.m3_total_period AS m3_total_hydrometer,
    ext_rtc_scada_dma_period.m3_total_period AS m3_total_scada, 
    (1::double precision - v_rtc_dma_hydrometer_period.m3_total_period / ext_rtc_scada_dma_period.m3_total_period)::numeric(5,4) AS losses, 
    ext_rtc_scada_dma_period.m3_min AS m3_min_scada, 
    ext_rtc_scada_dma_period.m3_max AS m3_max_scada, 
    ext_rtc_scada_dma_period.m3_avg AS m3_avg_scada, 
    ext_rtc_scada_dma_period.m3_min / ext_rtc_scada_dma_period.m3_avg AS cmin, 
    ext_rtc_scada_dma_period.m3_max / ext_rtc_scada_dma_period.m3_avg AS cmax
   FROM v_rtc_dma_hydrometer_period
  JOIN ext_rtc_scada_dma_period ON ext_rtc_scada_dma_period.cat_period_id::text = v_rtc_dma_hydrometer_period.period_id::text;


DROP VIEW IF EXISTS v_rtc_hydrometer_x_arc CASCADE;
CREATE OR REPLACE VIEW v_rtc_hydrometer_x_arc AS 
SELECT
rtc_hydrometer_x_connec.hydrometer_id,
rtc_hydrometer_x_connec.connec_id,
arc.arc_id,
arc.node_1,
arc.node_2
FROM rtc_hydrometer_x_connec
JOIN v_edit_connec ON v_edit_connec.connec_id::text = rtc_hydrometer_x_connec.connec_id::text
JOIN arc ON arc.arc_id::text = v_edit_connec.arc_id;



CREATE OR REPLACE VIEW v_inp_dwf_flow AS 
 SELECT node.node_id, 
    'FLOW'::text AS type_dwf,
    CASE 
        WHEN (rtc_options.status='OFF' OR rtc_options.status IS NULL) THEN v_rtc_hydrometer_period.lps_avg
        ELSE inp_dwf.value
    END as value,
    inp_dwf.pat1, 
    inp_dwf.pat2, 
    inp_dwf.pat3, 
    inp_dwf.pat4, 
    inp_selector_sector.sector_id
   FROM inp_selector_sector
   JOIN v_node node ON node.sector_id::text = inp_selector_sector.sector_id::text
   JOIN inp_dwf ON inp_dwf.node_id::text = node.node_id::text
   JOIN inp_selector_state ON node.state::text = inp_selector_state.id::text
   JOIN v_rtc_hydrometer_arc ON ¿?¿?¿?
   JOIN v_rtc_hydrometer_period ON v_rtc_hydrometer_period.hydrometer_id::text = v_rtc_hydrometer_x_arc.hydrometer_id::text
*/