﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


CREATE OR REPLACE FUNCTION "SCHEMA_NAME"."gw_fct_insertfeature"(layer_id varchar, table_id varchar, srid int4, the_geom varchar, insert_data json) RETURNS pg_catalog.json AS 
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_insertfeature('Junction','v_edit_man_junction',25831,'POINT(419093.4610180535 4576608.050609055)',
'{"nodecat_id":"AIR VALVE DN50","builtdate":null,"state":1,"enddate":null,"undelete":"false","publish":"false","inventory":"false"}')
*/

DECLARE

--    Variables
    id_insert character varying;
    insert_geom geometry;
    SRID_var int;
    schemas_array name[];
    table_name character varying;
    inputstring text;
    api_version json;

BEGIN

--    Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;    
    
--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO api_version;

-- fix diferent ways to say null on client
	insert_data = REPLACE (insert_data::text, '"NULL"', 'null');
	insert_data = REPLACE (insert_data::text, '"null"', 'null');
	insert_data = REPLACE (insert_data::text, '""', 'null');
		
--    COMMON TASKS:

--    Construct geom in device coordinates
    insert_geom := ST_SetSRID(ST_GeomFromText(the_geom), srid);

--    Get table coordinates
    schemas_array := current_schemas(FALSE);
    SRID_var := Find_SRID(schemas_array[1]::TEXT, table_id, 'the_geom');

--    Transform from device EPSG to database EPSG
    insert_geom := ST_Transform(insert_geom , SRID_var);

--    Update geometry field
    insert_data := gw_fct_json_object_set_key(insert_data, 'the_geom', insert_geom);

--    Set table name
    table_name := table_id;

--    Get columns names
    SELECT string_agg(quote_ident(key),',') INTO inputstring FROM json_object_keys(insert_data) AS X (key);

--    Perform INSERT
    EXECUTE FORMAT('INSERT INTO %s (%s) SELECT %s FROM json_populate_record( NULL::%s , $1)' ,
		quote_ident(table_name), inputstring, inputstring, quote_ident(table_name))
		USING insert_data;

--    Control NULL's
    id_insert := COALESCE(id_insert, '');


--    Return
    RETURN ('{"status":"Accepted"' ||
        ', "apiVersion":'|| api_version ||
        '}')::json;

--    Exception handling
    EXCEPTION WHEN OTHERS THEN 
        RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE COST 100;

