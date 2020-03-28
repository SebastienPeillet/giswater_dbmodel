/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2832

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_getprofilevalues(p_data json)  
RETURNS json AS 
$BODY$


/*example
SELECT gw_fct_getprofilevalues($${"data":{"initNode":"111", "endNode":"116", "legendFactor":1, "linksDistance":1, "scale":{"scaleToFit":false, "eh":1000, "ev":200}}}$$)


SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"client":{},
	"data":{"initNode":"116", "endNode":"111", "composer":"mincutA4", "legendFactor":1, "linksDistance":1, "scale":{"scaleToFit":false, "eh":2000, "ev":50},	
		"ComposerTemplates":[{"ComposerTemplate":"mincutA4", "ComposerMap":[{"width":"179.0","height":"140.826","index":0, "name":"map0"},{"width":"77.729","height":"55.9066","index":1, "name":"map7"}]},
				     {"ComposerTemplate":"mincutA3","ComposerMap":[{"width":"53.44","height":"55.9066","index":0, "name":"map7"},{"width":"337.865","height":"275.914","index":1, "name":"map6"}]}]
				     }}$$);

SELECT SCHEMA_NAME.gw_fct_getprofilevalues($${"client":{},
	"data":{"initNode":"116", "endNode":"111", "composer":"mincutA4", "legendFactor":1, "linksDistance":1, "scale":{"scaleToFit":false, "eh":2000, "ev":500},	
		"ComposerTemplates":[{"ComposerTemplate":"mincutA4", "ComposerMap":[{"width":"179.0","height":"140.826","index":0, "name":"map0"},{"width":"77.729","height":"55.9066","index":1, "name":"map7"}]},
				     {"ComposerTemplate":"mincutA3","ComposerMap":[{"width":"53.44","height":"55.9066","index":0, "name":"map7"},{"width":"337.865","height":"275.914","index":1, "name":"map6"}]}]
				     }}$$); 

- Cal minimitzar peticions SQL. Haurien de desapareixer totes
- hi ha un nou dialeg principal (petit refactor) 
	- Si scale to fit -> groupbox scale deshabilitat
	- tot mes facil per usuari, més directe (icon de maptool per doble click en mapa)
	- Els widgets del composer haurien de ser dinàmics com els del getprint

Alhora de pintar:
- Hi ha quatre tipus de nodes
	- els que pugen fins dalt trencant (TOP-REAL) -> cal pintar normal
	- els que pugen fins dalt trencant (TOP-ESTIMATED) -> cal pintar les ratlles de pujada i baixada en discotinu
	- els que no puguen pero trenquen tram (BOTTOM) -> no puja
	- els que no puguen i no trenquen (son els sys_type  = 'LINK') 
	->>>>> PODEM FER EL QUE SIGUI MÉS FÀCIL PER CODI PYTHON. M'HA SEMBLAT QUE AIXÒ HO ERA PERO SEGUR QUE HI HA COSES MILLORS.. EN PARLEM....
	
- cal posar una fila més en la llegenda 
	longitud total (TOTAL LENGTH)

- S'evien configuració de tres tipus de text (llegenda, guitarra i escala)
		
- millorar llegenda
	- cal posar els valors d'escala sota del caixeti de la guitarra (scale)
	- cal usar el legend factor per pintar amb una alçada concreta la part fixa de la guitarra (per defecte 1)

- en cas de no tenir composer cal fer servir els valors de extension per generar el llençol
- en cas de tenir perfil no se que passa.......
*/


DECLARE
v_init  text;
v_end text;
v_hs integer;
v_vs integer;
v_arc json;
v_node json;
v_llegend json;
v_stylesheet json;
v_version text;
v_status text;
v_level integer;
v_message text;
v_audit_result text; 
v_guitarlegend json;
v_textarc text;
v_textnode text;
v_vdefault json;
v_leaflet json;
v_composer text;
v_templates json;
v_json json;
v_project_type text;
v_height float;
v_index integer;
v_mapcomposer_name text;
v_scaletofit boolean;
v_array_width float[];
v_scale text;
v_extension json;
v_vstext text;
v_hstext text;
v_legendfactor float;
v_linksdistance float;
v_arc_geom1 float;
v_node_geom1 float;
i integer = 0;
v_dist float[];
v_telev float[];
v_elev float[];
v_nid text[];
v_systype text[];
v_elevation float;
v_distance float;
v_compheight float;
v_compwidth float;
v_profheigtht float;
v_profwidth float;

BEGIN

	--  Get input data
	v_init = (p_data->>'data')::json->>'initNode';
	v_end = (p_data->>'data')::json->>'endNode';
	v_hs = ((p_data->>'data')::json->>'scale')::json->>'eh';
	v_vs = ((p_data->>'data')::json->>'scale')::json->>'ev';
	v_scaletofit := ((p_data->>'data')::json->>'scale')::json->>'scaleToFit';
	v_legendfactor = (p_data->>'data')::json->>'legendFactor';
	v_linksdistance = (p_data->>'data')::json->>'linksDistance';
	v_composer := (p_data ->> 'data')::json->> 'composer';
	v_templates := (p_data ->> 'data')::json->> 'ComposerTemplates';

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	-- get projectytpe
	SELECT wsoftware, giswater FROM version LIMIT 1 INTO v_project_type, v_version;

	-- get systemvalues
	SELECT value INTO v_guitarlegend FROM config_param_system WHERE parameter = 'profile_guitarlegend';
	SELECT value INTO v_stylesheet FROM config_param_system WHERE parameter = 'profile_stylesheet';
	SELECT value::json->>'arc' INTO v_textarc FROM config_param_system WHERE parameter = 'profile_guitartext';
	SELECT value::json->>'node' INTO v_textnode FROM config_param_system WHERE parameter = 'profile_guitartext';
	SELECT value INTO v_vdefault FROM config_param_system WHERE parameter = 'profile_vdefault';
	SELECT value::json->>'vs' INTO v_vstext FROM config_param_system WHERE parameter = 'profile_guitarlegend';
  	SELECT value::json->>'hs' INTO v_hstext FROM config_param_system WHERE parameter = 'profile_guitarlegend';
  	SELECT (value::json->>'arc')::json->>'cat_geom1' INTO v_arc_geom1 FROM config_param_system WHERE parameter = 'profile_vdefault';
  	SELECT (value::json->>'node')::json->>'cat_geom1' INTO v_node_geom1 FROM config_param_system WHERE parameter = 'profile_vdefault';

	-- start process
	DELETE FROM anl_arc WHERE fprocesscat_id=122 AND cur_user = current_user;
	DELETE FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user;
	
	-- insert edge values on anl_arc table
	EXECUTE 'INSERT INTO anl_arc (fprocesscat_id, arc_id, code, node_1, sys_type, arccat_id, cat_geom1, length, slope, total_length)
		SELECT  122, arc_id, code, node_id, sys_type, arccat_id, cat_geom1, gis_length, slope,total_length FROM v_edit_arc JOIN cat_arc ON arccat_id = id JOIN
		(SELECT edge::text AS arc_id, node::text AS node_id, agg_cost as total_length FROM pgr_dijkstra(''SELECT arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, gis_length::float as cost, 
		gis_length::float as reverse_cost FROM v_edit_arc'', '||v_init||','||v_end||'))a
		USING (arc_id)';

	-- insert node values on anl_node table
	EXECUTE 'INSERT INTO anl_node (fprocesscat_id, node_id, code, top_elev, ymax, elev, sys_type, nodecat_id, cat_geom1, arc_id, arc_distance, total_distance)
		SELECT  122, node_id, n.code, sys_top_elev, sys_ymax, sys_elev, n.sys_type, nodecat_id, cat_node.geom1, a.arc_id, 0, total_length FROM v_edit_node n JOIN cat_node ON nodecat_id = id JOIN
		(SELECT edge::text AS arc_id, node::text AS node_id, agg_cost as total_length FROM pgr_dijkstra(''SELECT arc_id::int8 as id, node_1::int8 as source, node_2::int8 as target, gis_length::float as cost, 
		gis_length::float as reverse_cost FROM v_edit_arc'', '||v_init||','||v_end||'))a
		USING (node_id)';
	
	IF v_linksdistance > 0 THEN
	
		-- get vnode values
		INSERT INTO anl_node (fprocesscat_id, sys_type, node_id, code, top_elev, ymax, elev, arc_id , arc_distance, total_distance)
		SELECT 122, feature_type, feature_id, link_id, vnode_topelev, vnode_ymax, vnode_elev, arc_id, dist, dist+total_length FROM (SELECT DISTINCT ON (dist) * FROM 
			(
			-- connec on same sense (pg_routing & arc)
			SELECT c.arc_id, vnode_id,link_id,'LINK' as feature_type, connec_id as feature_id,vnode_topelev, vnode_ymax, vnode_elev, vnode_distfromnode1 as dist, total_length
				FROM v_arc_x_vnode 
				JOIN anl_arc USING (arc_id)
				JOIN v_edit_connec c ON c.connec_id = v_arc_x_vnode.feature_id
				WHERE fprocesscat_id=122 AND cur_user = current_user
				AND anl_arc.node_1 = v_arc_x_vnode.node_1
			UNION
			-- gully on same sense (pg_routing & arc)
			SELECT 	c.arc_id, vnode_id,link_id,'LINK',gully_id, vnode_topelev, vnode_ymax, vnode_elev, vnode_distfromnode1, total_length
				FROM v_arc_x_vnode 
				JOIN anl_arc USING (arc_id)
				JOIN v_edit_gully c ON c.gully_id = v_arc_x_vnode.feature_id
				WHERE fprocesscat_id=122 AND cur_user = current_user
				AND anl_arc.node_1 = v_arc_x_vnode.node_1
			UNION
			-- connec on reverse sense (pg_routing & arc)
			SELECT c.arc_id, vnode_id,link_id,'LINK' as feature_type, connec_id as feature_id,vnode_topelev, vnode_ymax, vnode_elev, vnode_distfromnode2 as dist, total_length
				FROM v_arc_x_vnode 
				JOIN anl_arc USING (arc_id)
				JOIN v_edit_connec c ON c.connec_id = v_arc_x_vnode.feature_id
				WHERE fprocesscat_id=122 AND cur_user = current_user
				AND anl_arc.node_1 = v_arc_x_vnode.node_2
			UNION
			-- gully on reverse sense (pg_routing & arc)
			SELECT 	c.arc_id, vnode_id,link_id,'LINK',gully_id, vnode_topelev, vnode_ymax, vnode_elev, vnode_distfromnode2, total_length
				FROM v_arc_x_vnode 
				JOIN anl_arc USING (arc_id)
				JOIN v_edit_gully c ON c.gully_id = v_arc_x_vnode.feature_id
				WHERE fprocesscat_id=122 AND cur_user = current_user
				AND anl_arc.node_1 = v_arc_x_vnode.node_2
			)a
		)b 
		ORDER BY b.arc_id, dist;
			
		-- delete links overlaped with nodes using the user's parameter
		v_dist = (SELECT array_agg(total_distance) FROM (SELECT total_distance FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
		v_nid = (SELECT array_agg(node_id) FROM (SELECT node_id FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
		v_systype = (SELECT array_agg(sys_type) FROM (SELECT sys_type FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
		LOOP	
			i = i+1;
			EXIT WHEN v_nid[i] IS NULL;

			--distance values
			IF ((v_dist[i] < (v_dist[i-1]+ v_linksdistance)) OR (v_dist[i] > (v_dist[i+1]+ v_linksdistance))) AND v_systype[i] = 'LINK' THEN
				DELETE FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user AND node_id = v_nid[i];
			END IF;			
		END LOOP;
	END IF;

	-- update descript
	EXECUTE 'UPDATE anl_arc SET descript = a.descript FROM (SELECT arc_id, (row_to_json(row)) AS descript FROM ('||v_textarc||')row)a WHERE a.arc_id = anl_arc.arc_id';
	EXECUTE 'UPDATE anl_node SET descript = a.descript FROM (SELECT node_id, (row_to_json(row)) AS descript FROM ('||v_textnode||')row)a WHERE a.node_id = anl_node.node_id';
	UPDATE anl_node SET descript = a.descript FROM (SELECT node_id, (row_to_json(row)) AS descript FROM (SELECT node_id, top_elev, elev, ymax, code FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user)row)a
					WHERE fprocesscat_id=122 AND cur_user = current_user AND a.node_id = anl_node.node_id AND anl_node.descript IS NULL;

	-- delete not used keys
	UPDATE anl_arc SET descript = gw_fct_json_object_delete_keys(descript::json, 'arc_id') WHERE fprocesscat_id=122 AND cur_user = current_user ;
	UPDATE anl_node SET descript = gw_fct_json_object_delete_keys(descript::json, 'node_id') WHERE fprocesscat_id=122 AND cur_user = current_user ;

	-- update node table setting default values
	UPDATE anl_arc SET cat_geom1 = v_arc_geom1 WHERE cat_geom1 IS NULL AND fprocesscat_id=122 AND cur_user = current_user ;
	UPDATE anl_node SET cat_geom1 = v_node_geom1 WHERE cat_geom1 IS NULL AND fprocesscat_id=122 AND cur_user = current_user AND sys_type !='LINK';

	-- update node table when node has not values and need to be interpolated
	v_dist = (SELECT array_agg(total_distance) FROM (SELECT total_distance FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
	v_telev = (SELECT array_agg(top_elev) FROM (SELECT top_elev FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
	v_elev = (SELECT array_agg(elev) FROM (SELECT elev FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);
	v_nid = (SELECT array_agg(node_id) FROM (SELECT node_id FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user order by total_distance, arc_id)a);

	i = 0;
	LOOP	
		i = i+1;
		EXIT WHEN v_nid[i] IS NULL;
		
		--topelev values
		IF v_telev[i] IS NULL THEN
			IF v_telev[i+1] IS NOT NULL AND v_telev[i-1] IS NOT NULL THEN
				UPDATE anl_node SET top_elev = (v_telev[i-1]+ ((v_dist[i]-v_dist[i-1])*(v_telev[i+1]-v_telev[i-1])/(v_dist[i+1]-v_dist[i-1])))::numeric(12,3) WHERE node_id = v_nid[i];
			ELSIF v_telev[i+2] IS NOT NULL AND v_telev[i-2] IS NOT NULL THEN
				UPDATE anl_node SET top_elev = (v_telev[i-2]+ ((v_dist[i]-v_dist[i-2])*(v_telev[i+2]-v_telev[i-2])/(v_dist[i+2]-v_dist[i-2])))::numeric(12,3) WHERE node_id = v_nid[i];
			END IF;

			UPDATE anl_node SET result_id = 'estimated', descript = gw_fct_json_object_set_key(descript::json, 'top_elev', 'N/I'::text) 
			WHERE fprocesscat_id=122 AND cur_user = current_user AND node_id = v_nid[i];
		END IF;
		
		--elev values
		IF v_elev[i] IS NULL THEN
			IF v_elev[i+1] IS NOT NULL AND v_elev[i-1] IS NOT NULL THEN
				UPDATE anl_node SET elev = (v_elev[i-1]+ ((v_dist[i]-v_dist[i-1])*(v_elev[i+1]-v_elev[i-1])/(v_dist[i+1]-v_dist[i-1])))::numeric(12,3) WHERE node_id = v_nid[i];
			ELSIF v_elev[i+2] IS NOT NULL AND v_elev[i-2] IS NOT NULL THEN
				UPDATE anl_node SET elev = (v_elev[i-2]+ ((v_dist[i]-v_dist[i-2])*(v_elev[i+2]-v_elev[i-2])/(v_dist[i+2]-v_dist[i-2])))::numeric(12,3) WHERE node_id = v_nid[i];
			END IF;
			UPDATE anl_node SET  result_id = 'estimated', descript = gw_fct_json_object_set_key(descript::json, 'elev', 'N/I'::text) 
			WHERE fprocesscat_id=122 AND cur_user = current_user AND node_id = v_nid[i];
		END IF;		
	END LOOP;

	-- update node table those ymax nulls
	UPDATE anl_node SET descript = gw_fct_json_object_set_key(descript::json, 'ymax', 'N/I'::text),  ymax = top_elev-elev 
	WHERE fprocesscat_id=122 AND cur_user = current_user AND ymax IS NULL;

	-- update node table setting those nodes without manhole on surface (isprofilesurface IS FALSE)
	UPDATE anl_node SET sys_type = 'BOTTOM' FROM node_type WHERE type = sys_type AND isprofilesurface IS FALSE AND fprocesscat_id=122 AND cur_user = current_user;
	UPDATE anl_node SET sys_type = 'TOP-REAL' FROM node_type WHERE sys_type !='LINK' AND fprocesscat_id=122 AND cur_user = current_user;
	UPDATE anl_node SET sys_type = 'TOP-ESTIM' FROM node_type WHERE sys_type ='TOP-REAL' AND result_id = 'estimated' AND fprocesscat_id=122 AND cur_user = current_user;
	UPDATE anl_node SET sys_type = 'LINK' WHERE sys_type ='LINK' AND fprocesscat_id=122 AND cur_user = current_user;
	UPDATE anl_node SET result_id = null where result_id is not null AND fprocesscat_id=122 AND cur_user = current_user;

	-- get profile dimensions
	v_elevation = (SELECT max(top_elev)-min(elev) FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user);
	v_distance = (SELECT max(total_distance) FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user);
	
	-- get leaflet dimensions
	v_profheigtht = 1000*v_elevation/v_vs + v_legendfactor*50 + 10;
	v_profwidth = 1000*v_distance/v_hs + v_legendfactor*20 + 10; -- profile + guitar + margin

	-- get portrait extension
	IF v_composer !='' THEN
		SELECT * INTO v_json FROM json_array_elements(v_templates) AS a WHERE a->>'ComposerTemplate' = v_composer;

		-- select map with maximum width
		SELECT array_agg(a->>'width') INTO v_array_width FROM json_array_elements( v_json ->'ComposerMap') AS a;
		SELECT max (a) INTO v_compwidth FROM unnest(v_array_width) AS a;
		SELECT a->>'name' INTO v_mapcomposer_name FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE (a->>'width')::float = v_compwidth::float;
		SELECT a->>'height' INTO v_compheight FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE a->>'name' = v_mapcomposer_name;  
		SELECT a->>'index' INTO v_index FROM json_array_elements( v_json ->'ComposerMap') AS a WHERE a->>'name' = v_mapcomposer_name; 

		IF v_scaletofit THEN
			v_vs = (v_compheight - v_legendfactor*50 - 10)/(1000*v_elevation);
			v_hs = (v_compwidth - v_legendfactor*20 - 10)/(1000*v_distance);
		ELSE 
			IF v_compheight < v_profheigtht THEN
				v_level = 2;
				v_message = 'Profile too large. You need to modify the vertial scale or change the composer';
				RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
			END IF;
			IF v_compwidth < v_profwidth THEN
				v_level = 2;
				v_message = 'Profile too long. You need to modify the horitzontal scale or composer';
				RETURN (concat('{"status":"accepted", "message":{"level":',v_level,', "text":"',v_message,'"}}')::json);
			END IF;
		END IF;
	ELSE
		-- extension value
		v_extension = (concat('{"width":', v_profwidth,', "height":', v_profheigtht,'}'))::json;
	END IF;

	-- scale text
	v_scale = concat('1:',v_hs, '(',v_hstext,') - 1:',v_vs,'(',v_vstext,')');
	
	-- update values using scale factor
	v_hs = 200/v_hs;
	v_vs = 1000/v_vs;
	
	UPDATE anl_arc SET cat_geom1 = cat_geom1*v_hs, length = length*v_hs WHERE fprocesscat_id=122 AND cur_user = current_user;
	UPDATE anl_node SET cat_geom1 = cat_geom1*v_vs, top_elev = top_elev*v_vs, elev = elev*v_vs, ymax = ymax*v_vs WHERE fprocesscat_id=122 AND cur_user = current_user;

	-- recover values form temp table into response (filtering by spacing certain distance of length in order to not collapse profile)
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_arc
	FROM (SELECT arc_id, descript, cat_geom1, length FROM anl_arc WHERE fprocesscat_id=122 AND cur_user = current_user) row;

	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_node
	FROM (SELECT node_id, descript, sys_type, cat_geom1, top_elev, elev, ymax FROM anl_node WHERE fprocesscat_id=122 AND cur_user = current_user) row;

	-- control null values
	IF v_guitarlegend IS NULL THEN v_guitarlegend='{}'; END IF;
	IF v_stylesheet IS NULL THEN v_stylesheet='{}'; END IF;

	v_extension := COALESCE(v_extension, '{}'); 
	v_scale := COALESCE(v_scale, '{}'); 
	
	v_arc := COALESCE(v_arc, '{}'); 
	v_node := COALESCE(v_node, '{}'); 

	-- default values
	v_status = 'Accepted';	
        v_level = 3;
        v_message = 'Profile done successfully';

	--  Return
	RETURN ('{"status":"'||v_status||'", "message":{"level":'||v_level||', "text":"'||v_message||'"}, "version":"'||v_version||'"'||
               ',"body":{"form":{}'||
               ',"data":{"legend":'||v_guitarlegend||','||
			'"scale":"'||v_scale||'",'||
			'"extension":'||v_extension||','||
			'"stylesheet":'||v_stylesheet||','||
			'"node":'||v_node||','||
			'"arc":'||v_arc||'}}}')::json;

	--EXCEPTION WHEN OTHERS THEN
	--GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
	--RETURN ('{"status":"Failed","NOSQLERR":' || to_json(SQLERRM) || ',"SQLSTATE":' || to_json(SQLSTATE) ||',"SQLCONTEXT":' || to_json(v_error_context) || '}')::json;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;