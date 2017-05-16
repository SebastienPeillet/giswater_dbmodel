/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_node2arc(character varying);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_node2arc(node_id_arg character varying)
  RETURNS smallint AS
$BODY$
DECLARE
    node_geom    geometry;
    arc_id_aux    varchar;
    arc_geom    geometry;
    epa_type_aux    varchar;
    line1        geometry;
    line2        geometry;
    rec_aux        record;
    rec_aux2    "SCHEMA_NAME".arc;
    intersect_loc    double precision;
    numArcs    integer;
	rec_doc record;
	rec_visit record;
	
BEGIN

    --    Search path
    SET search_path = "SCHEMA_NAME", public;

    --    Looking for disconnected node
    /*
    SELECT count(*) INTO numArcs FROM arc WHERE node_1 = node_id OR node_2 = node_id;
        IF numArcs > 0 THEN
            RETURN audit_function(518,90);
        END IF;
    */

    --    Get node geometry
    SELECT the_geom INTO node_geom FROM node WHERE node_id = node_id_arg;

    --    Get node tolerance from config table
    SELECT node2arc INTO rec_aux FROM config;

     --    Find closest pipe inside tolerance
    SELECT arc_id, the_geom, epa_type INTO arc_id_aux, arc_geom, epa_type_aux  FROM arc AS a WHERE ST_DWithin(node_geom, a.the_geom, rec_aux.node2arc) ORDER BY ST_Distance(node_geom, a.the_geom) LIMIT 1;

	
    --    Compute cut
    IF arc_geom IS NOT NULL AND (epa_type_aux = 'PIPE' OR epa_type_aux = 'CONDUIT') THEN

        --    Locate position of the nearest point
        intersect_loc := ST_LineLocatePoint(arc_geom, node_geom);

        --    Compute pieces
        line1 := ST_LineSubstring(arc_geom, 0.0, intersect_loc);
        line2 := ST_LineSubstring(arc_geom, intersect_loc, 1.0);

        -- Check if any of the 'lines' are in fact a point
        IF (ST_GeometryType(line1) = 'ST_Point') OR (ST_GeometryType(line2) = 'ST_Point') THEN
            RETURN 1;
        END IF;

        --    Get arc data
        SELECT * INTO rec_aux2 FROM arc WHERE arc_id = arc_id_aux;

        --    New arc_id
        rec_aux2.arc_id := nextval('SCHEMA_NAME.arc_id_seq');

        -- Check id
        WHILE EXISTS(SELECT 1 FROM arc WHERE arc_id = rec_aux2.arc_id) LOOP
                rec_aux2.arc_id := nextval('SCHEMA_NAME.arc_id_seq');
        END LOOP;

        --    Check longest
        IF ST_Length(line1) > ST_Length(line2) THEN

            --    Update pipe
            UPDATE arc SET (node_2, the_geom) = (node_id_arg, line1) WHERE arc_id = arc_id_aux;

            --    Insert new
            rec_aux2.the_geom := line2;
            rec_aux2.node_1 := node_id_arg;

        ELSE

            --    Update pipe
            UPDATE arc SET (node_1, the_geom) = (node_id_arg, line2) WHERE arc_id = arc_id_aux;

            --    Insert new
            rec_aux2.the_geom := line1;
            rec_aux2.node_2 := node_id_arg;

        END IF;

        --    Insert new record into arc table
        INSERT INTO arc SELECT rec_aux2.*;

    IF epa_type_aux = 'PIPE' THEN
        INSERT INTO inp_pipe SELECT rec_aux2.arc_id;
        INSERT INTO man_pipe SELECT rec_aux2.arc_id;
    ELSIF epa_type_aux = 'CONDUIT' THEN
        INSERT INTO inp_conduit SELECT rec_aux2.arc_id;
        INSERT INTO man_conduit SELECT rec_aux2.arc_id;
    END IF;


    END IF;
	
--INSERT DATA INTO OM_TRACEABILITY
	INSERT INTO om_traceability ("type", arc_id, arc_id1, arc_id2, node_id, "tstamp", "user") VALUES ('DIVIDE ARC',  arc_id_aux, arc_id_aux, rec_aux2.arc_id, node_id_arg,CURRENT_TIMESTAMP,CURRENT_USER);
			
			
			--PASSING DOCUMENTS FROM DIVIDED ARC TO NODE
	
			FOR rec_doc IN SELECT * FROM doc_x_arc WHERE arc_id=arc_id_aux LOOP
				INSERT INTO doc_x_node (id,doc_id, node_id) VALUES (nextval('doc_x_node_seq'),rec_doc.doc_id, node_id_arg);
			END LOOP;
			
			--PASSING DOCUMENTS FROM DIVIDED ARC TO THE NEW ARC
					
			FOR rec_doc IN SELECT * FROM doc_x_arc WHERE arc_id=arc_id_aux  LOOP
				INSERT INTO doc_x_arc (id,doc_id, arc_id) VALUES (nextval('doc_x_arc_seq'),rec_doc.doc_id, rec_aux2.arc_id);
			END LOOP;

			--PASSING VISITS FROM DIVIDED ARC TO NODE
			
			FOR rec_visit IN SELECT * FROM om_visit_x_arc WHERE arc_id=arc_id_aux LOOP
				INSERT INTO om_visit_x_node (id,visit_id, node_id) VALUES (nextval('om_visit_id_seq'),rec_visit.visit_id, node_id_arg);
			END LOOP;		
						
			--PASSING VISITS FROM DELETED ARC TO THE NEW ARC

			FOR rec_visit IN SELECT * FROM om_visit_x_arc WHERE arc_id=arc_id_aux LOOP
				INSERT INTO om_visit_x_arc (id,visit_id, arc_id) VALUES (nextval('om_visit_id_seq'),rec_visit.visit_id, rec_aux2.arc_id);
			END LOOP;

    RETURN audit_function(0,90);

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.gw_fct_node2arc(character varying)
  OWNER TO postgres;
