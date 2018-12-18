/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--om_visit_class_x_parameter
----------------------------
drop table if exists SCHEMA_NAME.om_visit_class_x_parameter;
CREATE TABLE SCHEMA_NAME.om_visit_class_x_parameter (
    id serial primary key,
    class_id integer NOT NULL,
    parameter_id character varying(50) NOT NULL
);


INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (2, 2, 'neteja_connec');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (3, 2, 'desperfectes_connec');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (5, 5, 'desperfectes_arc');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (6, 5, 'neteja_arc');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (4, 2, 'sediments_connec');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (7, 5, 'sediments_arc');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (8, 6, 'desperfectes_node');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (9, 6, 'neteja_node');
INSERT INTO SCHEMA_NAME.om_visit_class_x_parameter VALUES (10, 6, 'sediments_node');


ALTER TABLE ONLY SCHEMA_NAME.om_visit_class_x_parameter
    ADD CONSTRAINT om_visit_class_x_parameter_class_fkey FOREIGN KEY (class_id) REFERENCES SCHEMA_NAME.om_visit_class(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ONLY SCHEMA_NAME.om_visit_class_x_parameter
    ADD CONSTRAINT om_visit_class_x_parameter_parameter_fkey FOREIGN KEY (parameter_id) REFERENCES SCHEMA_NAME.om_visit_parameter(id) ON UPDATE CASCADE ON DELETE RESTRICT;

