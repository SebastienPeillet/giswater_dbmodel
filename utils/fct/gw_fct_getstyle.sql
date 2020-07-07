﻿-- Funcion: ws_sample_json.gw_fct_getstyle(json)

-- DROP FUNCTION ws_sample_json.gw_fct_getstyle(json);

CREATE OR REPLACE FUNCTION ws_sample_json.gw_fct_getstyle(p_data json)
  RETURNS json AS
$BODY$

/*

SELECT ws_sample_json.gw_fct_getstyle($${"client":{"device":4, "infoType":1, "lang":"ES"}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "layers":[ "v_edit_arc",  "v_edit_connec","v_edit_node"], "function_id":"2431"}}$$);

*/
 
DECLARE
v_addtoc json[];
v_value json;
v_layer text;
v_layers json;
v_return json;
v_funtion_id text;
v_style text;
v_version json;
v_layers_array text[];


BEGIN

	-- Search path
	SET search_path = 'ws_sample_json', public;	
	
	v_layers = ((p_data ->>'data')::json->>'layers')::json;
	v_funtion_id =((p_data ->>'data')::json->>'function_id')::text;
	v_layers_array = ARRAY(SELECT json_array_elements_text(v_layers::json)); 

	FOREACH v_layer IN ARRAY v_layers_array LOOP
		EXECUTE 'SELECT addtoc FROM sys_table WHERE id='||quote_literal(v_layer)||''
		into v_value; 
		if v_value is null then
			continue;
		end if;
		if v_value->>'style' = 'qml' then
			EXECUTE 'SELECT sytelvalue from sys_style WHERE idval ='||quote_literal(v_funtion_id)||''
			into v_style;
			if v_style is not null then			
				v_value=gw_fct_json_object_set_key((v_value)::json, 'style', v_style);			
			end if;
		end if;
		v_addtoc=array_append(v_addtoc,v_value);		
	END LOOP;
	
	v_return = gw_fct_json_object_set_key((p_data->>'body')::json, 'layers', v_addtoc);
	
	v_version := COALESCE(v_version, '{}');
	v_return := COALESCE(v_return, '{}');

	 
	-- Return
		RETURN ('{"status":"Accepted", "message":{"level":1, "text":"Executed successfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{"addToc":'||v_return||'}'||
	    '}}')::json;
	    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws_sample_json.gw_fct_getstyle(json)
  OWNER TO postgres;
