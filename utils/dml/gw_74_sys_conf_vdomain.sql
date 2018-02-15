/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


INSERT INTO cat_users VALUES ('postgres');


INSERT INTO config (id, node_proximity, arc_searchnodes, node2arc, connec_proximity, nodeinsert_arcendpoint, 
		orphannode_delete, vnode_update_tolerance, nodetype_change_enabled, 		
		samenode_init_end_control, node_proximity_control, connec_proximity_control, 
		node_duplicated_tolerance, connec_duplicated_tolerance, audit_function_control, arc_searchnodes_control, insert_double_geometry, buffer_value)
		VALUES ('1', 0.10000000000000001, 0.5, 0.5, 0.10000000000000001, false, false, 0.5, false, true, true, true, 0.001, 0.001, true, true, true, 1);




INSERT INTO config_param_system VALUES (42, 'inventory_update_date', '2017-01-01', 'date', 'om', NULL);
INSERT INTO config_param_system VALUES (43, 'geom_slp_direction', 'TRUE', 'boolean', 'topology', 'Ony for UD');
INSERT INTO config_param_system VALUES (40, 'state_topocontrol', 'TRUE', 'boolean', 'topology', 'Only for WS');
INSERT INTO config_param_system VALUES (44, 'link_search_button', '0,1', 'float', 'edit', NULL);
INSERT INTO config_param_system VALUES (47, 'rev_arc_y1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (49, 'rev_arc_geom1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (48, 'rev_arc_y2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (46, 'rev_node_depth_tol', '0', 'float', 'review', 'Only for WS');
INSERT INTO config_param_system VALUES (45, 'rev_node_elevation _tol', '0', 'float', 'review', 'Only for WS');
INSERT INTO config_param_system VALUES (50, 'rev_arc_geom2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (51, 'rev_node_top_elev_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (52, 'rev_node_ymax_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (53, 'rev_node_geom1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (54, 'rev_node_geom2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (55, 'rev_connec_y1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (57, 'rev_connec_geom1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (56, 'rev_connec_y2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (58, 'rev_connec_geom2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (59, 'rev_gully_top_elev_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (61, 'rev_gully_sandbox_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (63, 'rev_gully_connec_geom2_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (64, 'rev_gully_units_tol', '1', 'integer', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (62, 'rev_gully_connec_geom1_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (60, 'rev_gully_ymax_tol', '0', 'float', 'review', 'Only for UD');
INSERT INTO config_param_system VALUES (65, 'link_searchbuffer', 'true', 'boolean', 'topology', NULL);
INSERT INTO config_param_system VALUES (66, 'proximity_buffer', '50', 'double precision', NULL, NULL);
INSERT INTO config_param_system VALUES (31, 'street_layer', 'v_ext_streetaxis', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (32, 'street_field_code', 'id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (33, 'street_field_name', 'name', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (34, 'portal_layer', 'v_ext_address', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (35, 'portal_field_code', 'streetaxis_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (36, 'portal_field_number', 'postnumber', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (9, 'expl_field_name', 'name', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (7, 'expl_layer', 'ext_municipality', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (16, 'network_field_arc_code', 'code', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (13, 'network_layer_element', 'element', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (18, 'network_field_element_code', 'code', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (19, 'network_field_gully_code', 'code', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (22, 'hydrometer_urban_propierties_field_code', 'connec_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (11, 'network_layer_arc', 'v_edit_arc', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (12, 'network_layer_connec', 'v_edit_connec', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (25, 'hydrometer_field_urban_propierties_code', 'connec_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (15, 'network_layer_node', 'v_edit_node', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (24, 'hydrometer_field_code', 'hydrometer_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (17, 'network_field_connec_code', 'code', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (23, 'hydrometer_layer', 'v_rtc_hydrometer', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (20, 'network_field_node_code', 'code', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (14, 'network_layer_gully', 'v_edit_gully', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (21, 'hydrometer_urban_propierties_layer', 'v_edit_connec', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (10, 'scale_zoom', '500', 'integer', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (37, 'portal_field_postal', 'postcode', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (38, 'street_field_expl', 'muni_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (8, 'expl_field_code', 'muni_id', 'varchar', 'searchplus', NULL);
INSERT INTO config_param_system VALUES (41, 'mincut_conflict_map', 'FALSE', 'boolean', 'mincut', NULL);
INSERT INTO config_param_system VALUES (39, 'module_om_rehabit', 'TRUE', 'boolean', 'om', NULL);
INSERT INTO config_param_system VALUES (4, 'om_visit_absolute_path', 'https://www.', 'varchar', 'path', NULL);
INSERT INTO config_param_system VALUES (2, 'doc_absolute_path', 'c:', 'varchar', 'path', NULL);
INSERT INTO config_param_system VALUES (5, 'custom_giswater_folder', 'c:/', 'varchar', 'path', NULL);

	
--INSERT INTO config_client_forms VALUES (3867, 'v_ui_element_x_gully', true, 100, 5, NULL);
