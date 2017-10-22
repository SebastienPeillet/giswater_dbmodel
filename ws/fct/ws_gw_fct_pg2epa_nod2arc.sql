﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/



DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_nod2arc(varchar);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_nod2arc(result_id_var varchar)  RETURNS integer AS $BODY$
DECLARE
    
    record_node SCHEMA_NAME.v_node%ROWTYPE;
    record_arc1 SCHEMA_NAME.v_arc_x_node%ROWTYPE;
    record_arc2 SCHEMA_NAME.v_arc_x_node%ROWTYPE;
    record_new_arc SCHEMA_NAME.v_arc_x_node%ROWTYPE;
    node_diameter double precision;
    valve_arc_geometry geometry;
    valve_arc_node_1_geom geometry;
    valve_arc_node_2_geom geometry;
    arc_reduced_geometry geometry;
    node_id_aux text;
    num_arcs integer;
    shortpipe_record record;
    to_arc_aux text;
    arc_id_aux text;
    

BEGIN

--  Search path
    SET search_path = "SCHEMA_NAME", public;

--  Looking for parameters
    SELECT * INTO rec_options FROM inp_options;
	
    
--  Move valves to arc
    RAISE NOTICE 'Start loop.....';

    FOR node_id_aux IN (SELECT node_id FROM v_node JOIN inp_selector_sector ON inp_selector_sector.sector_id=v_node.sector_id JOIN inp_valve ON v_node.node_id=inp_valve.node_id
			UNION 
			SELECT node_id FROM v_node JOIN inp_selector_sector ON inp_selector_sector.sector_id=v_node.sector_id JOIN inp_shortpipe ON v_node.node_id=inp_shortpipe.node_id 
			UNION 
			SELECT node_id FROM v_node JOIN inp_selector_sector ON inp_selector_sector.sector_id=v_node.sector_id JOIN inp_pump ON v_node.node_id=inp_pump.node_id)
    LOOP
	
--        RAISE NOTICE 'Process valve: %', node_id_aux;

        -- Get node data
        SELECT * INTO record_node FROM v_node WHERE node_id = node_id_aux;

        -- Get arc data
        SELECT COUNT(*) INTO num_arcs FROM v_arc_x_node WHERE node_1 = node_id_aux OR node_2 = node_id_aux;

        -- Get arcs
        SELECT * INTO record_arc1 FROM v_arc_x_node WHERE node_1 = node_id_aux;
        SELECT * INTO record_arc2 FROM v_arc_x_node WHERE node_2 = node_id_aux;

        -- Just 1 arcs
        IF num_arcs = 1 THEN

            -- Compute valve geometry
            IF record_arc2 ISNULL THEN

                -- Use arc 1 as reference
                record_new_arc = record_arc1;
    
                -- TODO: Control pipe shorter than 0.5 m!
                valve_arc_node_1_geom := ST_StartPoint(record_arc1.the_geom);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, (SELECT node2arc FROM config) / ST_Length(record_arc1.the_geom));

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE arc_id = record_arc1.arc_id; 
            
            ELSIF record_arc1 ISNULL THEN
 
                -- Use arc 2 as reference
                record_new_arc = record_arc2;

                valve_arc_node_2_geom := ST_EndPoint(record_arc2.the_geom);
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - (SELECT node2arc FROM config) / ST_Length(record_arc2.the_geom));

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE arc_id = record_arc2.arc_id;

            END IF;

        -- Two arcs
        ELSIF num_arcs = 2 THEN

            -- Two 'node_2' arcs
            IF record_arc1 ISNULL THEN

                -- Get arcs
                SELECT * INTO record_arc2 FROM v_arc_x_node WHERE node_2 = node_id_aux ORDER BY arc_id DESC LIMIT 1;
                SELECT * INTO record_arc1 FROM v_arc_x_node WHERE node_2 = node_id_aux ORDER BY arc_id ASC LIMIT 1;

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;
    
                -- TODO: Control pipe shorter than 0.5 m!
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - (SELECT node2arc FROM config) / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, 1 - (SELECT node2arc FROM config) / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,0,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom));
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id;


            -- Two 'node_1' arcs
            ELSIF record_arc2 ISNULL THEN

                -- Get arcs
                SELECT * INTO record_arc1 FROM v_arc_x_node WHERE node_1 = node_id_aux ORDER BY arc_id DESC LIMIT 1;
                SELECT * INTO record_arc2 FROM v_arc_x_node WHERE node_1 = node_id_aux ORDER BY arc_id ASC LIMIT 1;

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;
    
                -- TODO: Control arc shorter than 0.5 m!
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, (SELECT node2arc FROM config) / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, (SELECT node2arc FROM config) / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom),1);
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id;
                        

            -- One 'node_1' and one 'node_2'
            ELSE

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;
    
                -- TODO: Control pipe shorter than 0.5 m!
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - (SELECT node2arc FROM config) / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, (SELECT node2arc FROM config) / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(a.node_1, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(a.node_2, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id;
                        
            END IF;

        -- num_arcs 0 or > 2
        ELSE

            CONTINUE;
                        
        END IF;

        -- Create new arc geometry
        valve_arc_geometry := ST_MakeLine(valve_arc_node_1_geom, valve_arc_node_2_geom);

        -- Values to insert into arc table
        record_new_arc.arc_id := concat(node_id_aux, '_n2a');   
        record_new_arc.arctype_id:= node_id_aux.nodetype_id;
	record_new_arc.arccat_id := node_id_aux.nodecat_id;
	record_new_arc.epa_type := node_id_aux.epa_type;
        record_new_arc.sector_id := node_id_aux.sector_id;
        record_new_arc.state := node_id_aux.state;
        record_new_arc.state_type := node_id_aux.state_type;
        record_new_arc.annotation := node_id_aux.annotation;
        record_new_arc.length := ST_length2d(valve_arc_geometry);
        record_new_arc.the_geom := valve_arc_geometry;
        

        -- Identifing the right direction
	SELECT to_arc INTO to_arc_aux FROM (SELECT node_id,to_arc FROM SCHEMA_NAME.inp_valve UNION SELECT node_id,to_arc FROM SCHEMA_NAME.inp_shortpipe UNION SELECT node_id,to_arc FROM SCHEMA_NAME.inp_pump) A
					WHERE node_id=node_id_aux;


	SELECT arc_id INTO arc_id_aux FROM v_arc_x_node WHERE (ST_DWithin(ST_endpoint(record_new_arc.the_geom), arc.the_geom, rec.arc_searchnodes))
					ORDER BY ST_Distance(arc.the_geom, ST_endpoint(record_new_arc.the_geom)) LIMIT 1;

	IF arc_id_aux=to_arc_aux THEN
		record_new_arc.node_1 := concat(node_id_aux, '_n2a_1');
		record_new_arc.node_2 := concat(node_id_aux, '_n2a_2');
	ELSE
		record_new_arc.node_2 := concat(node_id_aux, '_n2a_1');
		record_new_arc.node_1 := concat(node_id_aux, '_n2a_2');
	END IF; 

        -- Inserting new arc into arc table
        INSERT INTO rpt_inp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, state, state_type, annotation, length, diameter, roughness, the_geom)
		VALUES(result_id_var, record_new_arc.*);

        -- Inserting new nodes into node table
        record_node.epa_type := 'JUNCTION';
        record_node.the_geom := valve_arc_node_1_geom;
        record_node.demand := 0;
        record_node.node_id := concat(node_id_aux, '_n2a_1');
        INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, the_geom) 
		VALUES(record_node.*);

        record_node.the_geom := valve_arc_node_2_geom;
        record_node.node_id := concat(node_id_aux, '_n2a_2');
        INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, the_geom) 
		VALUES(record_node.*);

        -- Deleting old node from node table
        DELETE FROM rpt_inp_node WHERE node_id =  node_id_aux AND result_id=result_id_var;


    END LOOP;



    RETURN 1;


		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;