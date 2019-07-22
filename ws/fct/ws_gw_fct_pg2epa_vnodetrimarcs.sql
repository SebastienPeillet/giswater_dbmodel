/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2728


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_vnodetrimarcs(result_id_var character varying)  RETURNS json AS 
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_pg2epa_vnodetrimarcs('r1')
*/

DECLARE

	v_count integer = 0;
	v_result integer = 0;
      
BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	RAISE NOTICE 'Starting pg2epa vnode trim arcs';

	-- step 1: for those that vnodes not overlaps node2arc
	
	DELETE FROM temp_table WHERE fprocesscat_id=50 and user_name=current_user;

	-- insert data on temp_table
	INSERT INTO temp_table (fprocesscat_id, text_column)
	SELECT  50, concat('{"arc_id":"',arc_id,'", "vnode_id":"' ,vnode_id, '", "locate":', locate,', "elevation":',
	(elevation1 - locate*(elevation1-elevation2))::numeric(12,3),
	', "depth":',
	(depth1 - locate*(depth1-depth2))::numeric (12,3),	
	'}')
	FROM (
		SELECT distinct on (vnode_id) concat('VN',vnode_id::text) as vnode_id, arc_id, 
		case 	
			when st_linelocatepoint (rpt_inp_arc.the_geom , vnode.the_geom)=1 then 0.9900 
			when st_linelocatepoint (rpt_inp_arc.the_geom , vnode.the_geom)=0 then 0.0100 
			else (st_linelocatepoint (rpt_inp_arc.the_geom , vnode.the_geom))::numeric(12,4) end as locate
		FROM rpt_inp_arc , vnode 
		JOIN v_edit_link a ON vnode_id=exit_id::integer
		WHERE st_dwithin ( rpt_inp_arc.the_geom, vnode.the_geom, 0.01) AND vnode.state > 0 AND rpt_inp_arc.arc_type != 'NODE2ARC'
		AND result_id=result_id_var
		UNION
		SELECT node_1, arc_id,  0 FROM rpt_inp_arc WHERE result_id=result_id_var AND arc_type != 'NODE2ARC'
		UNION 
		SELECT node_2, arc_id, 1 FROM rpt_inp_arc WHERE result_id=result_id_var AND arc_type != 'NODE2ARC'
		) a
	JOIN v_arc USING (arc_id)
	ORDER BY arc_id, locate;
	

	-- new nodes on rpt_inp_node table
	INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, the_geom)
	SELECT 
		result_id_var,
		text_column::json->>'vnode_id' as node_id, 
		text_column::json->>'elevation', 
		(text_column::json->>'elevation')::numeric(12,3) - (text_column::json->>'depth')::numeric(12,3),
		'VNODE',
		'VNODE',
		'JUNCTION',
		a.state,
		a.state_type,
		null,
		ST_LineInterpolatePoint (a.the_geom, (text_column::json->>'locate')::numeric(12,4)) as the_geom
		FROM temp_table
		JOIN rpt_inp_arc a ON arc_id=text_column::json->>'arc_id'
		WHERE result_id=result_id_var AND text_column::json->>'vnode_id' ilike 'VN%';


	-- new arcs on rpt_inp_arc table
	INSERT INTO rpt_inp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, state, state_type, annotation, diameter, roughness, length, the_geom)
	SELECT
		result_id_var,
		concat(arc_id,'P',a.id-min) as arc_id, 
		node_1,
		node_2,
		rpt_inp_arc.arc_type,
		rpt_inp_arc.arccat_id,
		rpt_inp_arc.epa_type,
		rpt_inp_arc.sector_id,
		rpt_inp_arc.state,
		rpt_inp_arc.state_type,
		concat ('From parent arc:', a.arc_id, '-',rpt_inp_arc.annotation),
		rpt_inp_arc.diameter,
		rpt_inp_arc.roughness,
		st_length(ST_LineSubstring(the_geom, locate_1, locate_2)),	
		ST_LineSubstring(the_geom, locate_1, locate_2) as the_geom
		FROM (
			SELECT a.id, a.text_column::json->>'arc_id' as arc_id, a.text_column::json->>'vnode_id' as node_1, (a.text_column::json->>'locate')::numeric(12,4) as locate_1 ,
			b.text_column::json->>'vnode_id' as node_2, (b.text_column::json->>'locate')::numeric(12,4) as locate_2
			FROM temp_table a
			JOIN temp_table b ON a.id=b.id-1
			WHERE a.fprocesscat_id=50 AND a.user_name=current_user
			AND a.text_column::json->>'arc_id' = b.text_column::json->>'arc_id'
			ORDER BY a.id) a
		JOIN (SELECT min(id), arc_id
			FROM(
				SELECT a.id, a.text_column::json->>'arc_id' as arc_id, a.text_column::json->>'vnode_id' as node_1, (a.text_column::json->>'locate')::numeric(12,4) as locate_1 ,
				b.text_column::json->>'vnode_id' as node_2, (b.text_column::json->>'locate')::numeric(12,4) as locate_2
				FROM temp_table a
				JOIN temp_table b ON a.id=b.id-1
				WHERE a.fprocesscat_id=50 AND a.user_name=current_user
				AND a.text_column::json->>'arc_id' = b.text_column::json->>'arc_id'
				ORDER BY a.id) a group by arc_id) b USING (arc_id)
		JOIN rpt_inp_arc USING (arc_id)
		WHERE result_id=result_id_var AND (a.node_1 ilike 'VN%' OR a.node_2 ilike 'VN%')
		ORDER BY arc_id, a.id;
	
	--delete old arc on rpt_inp_arc table
	DELETE FROM rpt_inp_arc WHERE arc_id IN (SELECT DISTINCT text_column::json->>'arc_id' as arc_id FROM temp_table WHERE fprocesscat_id=50 AND user_name=current_user);

	-- step 2 message to user to repair it for those vnodes over node2arc features
	EXECUTE 'SELECT count(vnode_id) FROM rpt_inp_arc , vnode 
		JOIN v_edit_link a ON vnode_id=exit_id::integer
		WHERE st_dwithin ( rpt_inp_arc.the_geom, vnode.the_geom, 0.01) AND vnode.state > 0 AND arc_type = ''NODE2ARC''
		AND result_id='||result_id_var
		INTO v_result;
	
RETURN v_result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;