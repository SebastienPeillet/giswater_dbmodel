/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2725


--DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_get_feature_relation(json);


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_get_feature_relation(p_data json)
RETURNS json AS

/*
SELECT SCHEMA_NAME.gw_fct_get_feature_relation($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"type":"ARC"},
"data":{"feature_id":"2098" }}$$);

SELECT SCHEMA_NAME.gw_fct_get_feature_relation($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"type":"NODE"},
"data":{"feature_id":"1051"}}$$);

SELECT SCHEMA_NAME.gw_fct_get_feature_relation($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"type":"CONNEC"},
"data":{"feature_id":"3254" }}$$);
*/
 

$BODY$
DECLARE
v_feature_type text;
v_feature_id text;
v_workcat_id_end text;
v_enddate text;
v_descript text;
v_project_type text;
v_version text;
v_connect_connec text;
v_connect_gully text;
v_connect_node text;
v_element text;
v_visit text;
v_doc text;
v_connect_arc text;
api_version json;
v_result_id text= 'feature relations';
v_result_info text;
v_result text;

BEGIN

	SET search_path = "SCHEMA_NAME", public;
	SELECT wsoftware, giswater  INTO v_project_type, v_version FROM version order by 1 desc limit 1;

	-- manage log (fprocesscat = 51)
	DELETE FROM audit_check_data WHERE fprocesscat_id=51 AND user_name=current_user;
	INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('FEATURE RELATIONS'));
	INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('------------------------------'));

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;
        
	v_feature_type = lower(((p_data ->>'feature')::json->>'type'))::text;
	v_feature_id = ((p_data ->>'data')::json->>'feature_id')::text;

	IF v_feature_type='arc' THEN
	--check connec& gully related to arc
		SELECT array_to_json(array_agg(feature_id)) INTO v_connect_connec FROM v_ui_arc_x_relations 
		JOIN sys_feature_cat on sys_feature_cat.id=v_ui_arc_x_relations.sys_type WHERE type='CONNEC' AND  arc_id = v_feature_id;

		SELECT array_to_json(array_agg(feature_id)) INTO v_connect_gully FROM v_ui_arc_x_relations 
		JOIN sys_feature_cat on sys_feature_cat.id=v_ui_arc_x_relations.sys_type WHERE type='GULLY' AND  arc_id = v_feature_id;
	
	--check final nodes related to arc
		SELECT array_to_json(array[node_1, node_2]) INTO v_connect_node FROM v_ui_arc_x_node WHERE arc_id = v_feature_id;
		
	ELSIF v_feature_type='node' THEN
	--check nodes childs related to node
		SELECT array_to_json(array_agg(child_id)) INTO v_connect_node FROM v_ui_node_x_relations WHERE node_id = v_feature_id;
	--check arcs related to node
		SELECT array_to_json(array_agg(arc_id)) INTO v_connect_arc FROM v_ui_arc_x_node WHERE (node_1 = v_feature_id OR node_2 = v_feature_id);
		
	ELSIF v_feature_type='connec' OR v_feature_type='gully' THEN
		EXECUTE 'SELECT array_to_json(array[feature_id]) FROM link where exit_type=''CONNEC''  AND  exit_id = '''||v_feature_id||'''::text'
		INTO v_connect_connec;
		EXECUTE 'SELECT array_to_json(array[feature_id]) FROM link where exit_type=''GULLY''  AND  exit_id = '''||v_feature_id||'''::text'
		INTO v_connect_gully;
	END IF;
	
	
	--check elements related to feature
	EXECUTE 'SELECT array_to_json(array[element_id]) FROM element_x_'||v_feature_type||' where '||v_feature_type||'_id = '''||v_feature_id||'''::text'
	INTO v_element;

	--check visits related to feature
	EXECUTE 'SELECT array_to_json(array[visit_id::text]) FROM om_visit_x_'||v_feature_type||' where '||v_feature_type||'_id = '''||v_feature_id||'''::text'
	INTO v_visit;

	--check visits related to feature
	EXECUTE 'SELECT array_to_json(array[doc_id::text]) FROM doc_x_'||v_feature_type||' where '||v_feature_type||'_id = '''||v_feature_id||'''::text'
	INTO v_doc;



INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Arcs connected with the featue -> ',v_connect_arc ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Nodes connected with the featue -> ',v_connect_node ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Connecs connected with the featue -> ',v_connect_connec ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Gullies connected with the featue -> ',v_connect_gully ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Elements connected with the featue -> ',v_element ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Documents connected with the featue -> ',v_doc ));
INSERT INTO audit_check_data (fprocesscat_id, result_id, error_message) VALUES (51, v_result_id, concat('Visits connected with the featue -> ',v_visit ));


v_connect_node := COALESCE(v_connect_node, '[]');  
v_connect_arc := COALESCE(v_connect_arc, '[]');  
v_connect_connec := COALESCE(v_connect_connec, '[]');  
v_connect_gully := COALESCE(v_connect_gully, '[]');  
v_element := COALESCE(v_element, '[]');  
v_visit := COALESCE(v_visit, '[]');  
v_doc := COALESCE(v_doc, '[]');  

SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
FROM (SELECT id, error_message AS message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=49) row; 

v_result := COALESCE(v_result, '{}'); 
v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	-- Control nulls
	v_version := COALESCE(v_version, '{}'); 
	v_result_info := COALESCE(v_result_info, '{}'); 

    RETURN ('{"status":"Accepted", "apiVersion":'||api_version||
             ',"body":{"message":{"priority":1, "text":'||v_result_info||'}'||
			',"form":{}'||
			',"feature":'||(p_data ->>'feature')||
			',"data":'||(p_data ->>'data')||
			',"relation":{"node":'|| v_connect_node ||',"arc":'|| v_connect_arc ||',"connec":'|| v_connect_connec ||',"gully":'|| v_connect_gully ||
			',"element":'|| v_element ||',"visit":'|| v_visit ||',"document":'|| v_doc ||'}'||'}'
	    '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;






