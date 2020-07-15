/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

ALTER TABLE om_visit_lot_x_arc ADD CONSTRAINT om_visit_lot_x_arc_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE om_visit_lot_x_connec ADD CONSTRAINT om_visit_lot_x_connec_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE om_visit_lot_x_node ADD CONSTRAINT om_visit_lot_x_node_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_vehicle_x_parameters ADD CONSTRAINT om_vehicle_x_parameters_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE om_vehicle_x_parameters ADD CONSTRAINT om_vehicle_x_parameters_team_id_fkey FOREIGN KEY (team_id) REFERENCES cat_team (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE om_vehicle_x_parameters ADD CONSTRAINT om_vehicle_x_parameters_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES ext_cat_vehicle (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_team_x_vehicle ADD CONSTRAINT om_team_x_vehicle_team_id_fkey FOREIGN KEY (team_id) REFERENCES cat_team (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE om_team_x_vehicle ADD CONSTRAINT om_team_x_vehicle_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES ext_cat_vehicle (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit_class_x_parameter ADD CONSTRAINT om_visit_class_x_parameter_class_fkey FOREIGN KEY (class_id) REFERENCES om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE om_visit_class_x_parameter ADD CONSTRAINT om_visit_class_x_parameter_parameter_fkey FOREIGN KEY (parameter_id) REFERENCES om_visit_parameter (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE selector_lot ADD CONSTRAINT selector_lot_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE selector_lot ADD CONSTRAINT selector_lot_lot_id_cur_user_unique UNIQUE (lot_id, cur_user);

ALTER TABLE om_visit_parameter DROP CONSTRAINT om_visit_parameter_feature_type_fkey;
ALTER TABLE om_visit_parameter ADD CONSTRAINT om_visit_parameter_feature_type_check CHECK (feature_type IN ('NODE','ARC','CONNEC','GULLY','ALL','UNDEFINED'));


ALTER TABLE om_team_x_visitclass ADD CONSTRAINT om_team_x_visitclass_team_id_fkey FOREIGN KEY (team_id) REFERENCES cat_team (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE om_team_x_visitclass ADD CONSTRAINT om_team_x_visitclass_visitclass_id_fkey FOREIGN KEY (visitclass_id) REFERENCES om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit ADD CONSTRAINT om_visit_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_lot_x_user ADD CONSTRAINT om_visit_lot_x_user_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;