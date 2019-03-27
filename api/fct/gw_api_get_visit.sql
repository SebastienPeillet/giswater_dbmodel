﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX



CREATE OR REPLACE FUNCTION arbrat_viari_upgrade.gw_api_get_visit(p_visittype text, p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE:

-- unexpected first call
SELECT arbrat_viari_upgrade.gw_api_get_visit('unexpected', $${"client":{"device":3,"infoType":100,"lang":"es"},"form":{},"data":{"relatedFeature":{"type":"node", "id":"2074"},"fields":{},"pageInfo":null}}$$)

-- planned first call
SELECT arbrat_viari_upgrade.gw_api_get_visit('planned', $${"client":{"device":3,"infoType":100,"lang":"es"},"form":{},"data":{"relatedFeature":{"type":"node", "id":"2074"},"fields":{},"pageInfo":null}}$$)


	
MAIN ISSUES
-----------	

LOGICS
- On click after info feature	
	- Use the visit duration parameter from param user table to choose a new visit or use the last one
	- Identify if visits exist or not
		When visit is new, 
		- choose the visitclass vdefault of user	
		When visit exists		
		- Identify if class have been changed or not -> This is especially crictic because may it affect the editable view used to upsert data

- On click without previous info (no infraestucture visit)
	- New incidency visit is showed
	
ACTIONS COULD BE DONE
- get info from existing visit
- upsert class from multievent to singlevent
- insertfile action with insert visit (visit null or visit not existing yet on database)
- change from tab data to tab files (upserting data on tabData)
- tab files
- deletefile action
*/

DECLARE
	v_apiversion text;
	v_schemaname text;
	v_featuretype text;
	v_visitclass integer;
	v_id text;
	v_idname text;
	v_columntype text;
	v_device integer;
	v_formname text;
	v_tablename text;
	v_fields json [];
	v_fields_text text [];
	v_fields_json json;
	v_forminfo json;
	v_formheader text;
	v_formactions text;
	v_formtabs text;
	v_tabaux json;
	v_active boolean;
	v_featureid varchar ;
	aux_json json;
	v_tab record;
	v_projecttype varchar;
	v_list json;
	v_activedatatab boolean;
	v_activefilestab boolean;
	v_client json;
	v_pageinfo json;
	v_layermanager json;
	v_filterfields json;
	v_data json;
	isnewvisit boolean default false;
	v_feature json;
	v_addfile json;
	v_deletefile json;
	v_filefeature json;
	v_fileid text;
	v_message json;
	v_message1 text;
	v_message2 text;
	v_return json;
	v_currentactivetab text;
	v_values json;
	array_index integer DEFAULT 0;
	v_fieldvalue text;
	v_geometry json;
	v_noinfra boolean ;
	v_queryinfra text ;
	v_parameter text;
	v_ismultievent boolean;
	v_inputtablename text;
	v_inputformname text;
	v_isclasschanged boolean = false;  -- to identify if class of visit is changed. Important because in that case new form is reloaded with new widgets but nothing is upserted on database yet
	v_visitduration text; 	-- to fix the duration of visit. Important because if visit is active on feature, existing visit is showed
	arbrat_viari_upgrade int8;  -- to 
	v_status integer;  -- identifies the status of visit. Important because on status=0 visit is disabled
	v_class integer;  -- identifies class of visit. Important because each class needs a diferent form
	v_filterfeaturefield text;
	v_visitcat integer;
	v_visitextcode text;
	v_startdate text;
	v_enddate text;
	v_extvisitclass integer;
	v_existvisit_id integer;

BEGIN

	-- Set search path to local schema
	SET search_path = "arbrat_viari_upgrade", public;
	v_schemaname := 'arbrat_viari_upgrade';

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO v_apiversion;

	-- fix diferent ways to say null on client
	p_data = REPLACE (p_data::text, '"NULL"', 'null');
	p_data = REPLACE (p_data::text, '"null"', 'null');
	p_data = REPLACE (p_data::text, '""', 'null');
	p_data = REPLACE (p_data::text, '''''', 'null');

	-- get project type
	SELECT wsoftware INTO v_projecttype FROM version LIMIT 1;

	--  get parameters from input
	v_client = (p_data ->>'client')::json;
	v_device = ((p_data ->>'client')::json->>'device')::integer;
	v_id = ((p_data ->>'feature')::json->>'id')::integer;
	v_featureid = (((p_data ->>'data')::json->>'relatedFeature')::json->>'id');
	v_featuretype = (((p_data ->>'data')::json->>'relatedFeature')::json->>'type');
	v_activedatatab = (((p_data ->>'form')::json->>'tabData')::json->>'active')::boolean;
	v_activefilestab = (((p_data ->>'form')::json->>'tabFiles')::json->>'active')::boolean;
	v_addfile = ((p_data ->>'data')::json->>'newFile')::json;
	v_deletefile = ((p_data ->>'data')::json->>'deleteFile')::json;
	v_currentactivetab = (((p_data ->>'form')::json->>'navigation')::json->>'currentActiveTab')::text;
	v_visitclass = ((p_data ->>'data')::json->>'fields')::json->>'class_id';
	v_inputtablename = ((p_data ->>'feature')::json->>'tableName');

	--  get visitclass
	IF v_visitclass IS NULL THEN
	
		-- infraestructure visit
		IF v_featuretype IS NOT NULL THEN
		
			--new visit
			IF v_id IS NULL OR (SELECT id FROM om_visit WHERE id=v_id::bigint) IS NULL THEN

				-- getting dynamic value
				v_visitclass := (SELECT value FROM config_param_user WHERE parameter = 'visitclass_vdefault' AND cur_user=current_user)::integer;	

				IF p_visittype='planned' THEN
				
					IF ((SELECT visit_type FROM om_visit_class WHERE id=v_visitclass) = 1 AND (SELECT feature_type FROM om_visit_class WHERE id=v_visitclass) = upper(v_featuretype)) THEN
						-- planned visitclass is acording feature type and visit type
					ELSE
						v_visitclass := (SELECT value FROM config_param_user WHERE parameter = concat('visitclass_vdefault_', v_featuretype) AND cur_user=current_user)::integer;		
					END IF;

					IF v_visitclass IS NULL THEN
						v_visitclass := (SELECT id FROM om_visit_class WHERE feature_type=upper(v_featuretype) LIMIT 1);
					END IF;
					
				ELSE
					IF (SELECT visit_type FROM om_visit_class WHERE id=v_visitclass) = 2 AND (SELECT feature_type FROM om_visit_class WHERE id=v_visitclass) = upper(v_featuretype) THEN
						-- unexpected visitclass is acording feature type and visit type
					ELSE
						v_visitclass := (SELECT id FROM om_visit_class WHERE feature_type = upper(v_featuretype) AND visit_type=2 LIMIT 1);	
					END IF;

				END IF;
							
			-- existing visit
			ELSE 
				v_visitclass := (SELECT class_id FROM om_visit WHERE id=v_id::bigint);
				IF v_visitclass IS NULL THEN
					v_visitclass := 0;
				END IF;
			END IF;
			
		-- no infraestructure visit (only for unspected visits)
		ELSE 
			--new visit
			IF v_id IS NULL OR (SELECT id FROM om_visit WHERE id=v_id::bigint) IS NULL THEN
				v_visitclass := (SELECT id FROM om_visit_class WHERE feature_type IS NULL AND visit_type=2 LIMIT 1);
			
			-- existing visit
			ELSE 
				v_visitclass := (SELECT class_id FROM om_visit WHERE id=v_id::bigint);
				IF v_visitclass IS NULL THEN
					v_visitclass := 0;
				END IF;
			END IF;
		END IF;
	END IF;
	
	--  get formname and tablename
	v_formname := (SELECT formname FROM config_api_visit WHERE visitclass_id=v_visitclass);
	v_tablename := (SELECT tablename FROM config_api_visit WHERE visitclass_id=v_visitclass);
	v_ismultievent := (SELECT ismultievent FROM om_visit_class WHERE id=v_visitclass);
	
	-- getting if is new visit
	IF (SELECT id FROM om_visit WHERE id=v_id::int8) IS NULL OR v_id IS NULL THEN
		v_id := (SELECT max(id)+1 FROM om_visit);
		isnewvisit = true;		
	END IF;

	
	-- get if visit is related to some ifraestructure element or not
	IF v_projecttype ='WS' THEN
		v_queryinfra = (SELECT feature_id FROM (SELECT arc_id as feature_id, visit_id FROM om_visit_x_arc UNION SELECT node_id, visit_id 
				FROM om_visit_x_node UNION SELECT connec_id, visit_id FROM om_visit_x_connec LIMIT 1) a WHERE visit_id=v_id::int8);
	ELSE
		v_queryinfra = (SELECT feature_id FROM (SELECT arc_id as feature_id, visit_id FROM om_visit_x_arc UNION SELECT node_id, visit_id FROM om_visit_x_node 
				UNION SELECT connec_id, visit_id FROM om_visit_x_connec UNION SELECT gully, visit_id FROM om_visit_x_gully LIMIT 1) a WHERE visit_id=v_id::int8);
	END IF;

	IF v_queryinfra IS NOT NULL OR v_featureid IS NOT NULL THEN  -- for existing and for new visits
		v_noinfra = FALSE;
	ELSE
		v_noinfra = TRUE;
	END IF;
	
	
	-- Check if exists some open visit on related feature with the class configured as vdefault for user
	IF v_featuretype IS NOT NULL AND v_featureid IS NOT NULL AND v_visitclass IS NOT NULL THEN
		EXECUTE ('SELECT v.id FROM om_visit_x_'|| (v_featuretype) ||' a JOIN om_visit v ON v.id=a.visit_id '||
			' WHERE ' || (v_featuretype) || '_id = ' || quote_literal(v_featureid) || '::text AND (status > 0 OR status = 0 AND (now()- enddate) < ''8 hours'') ' ||
			' AND class_id = ' || quote_literal(v_visitclass) || 
			' ORDER BY startdate DESC LIMIT 1')
			INTO v_existvisit_id;
	END IF;

	IF v_existvisit_id IS NOT NULL THEN
		v_id = v_existvisit_id;
	END IF;

	IF isnewvisit IS FALSE THEN
		v_extvisitclass := (SELECT class_id FROM om_visit WHERE id=v_id::int8);
		v_formname := (SELECT formname FROM config_api_visit WHERE visitclass_id=v_visitclass);
		v_tablename := (SELECT tablename FROM config_api_visit WHERE visitclass_id=v_visitclass);
		v_ismultievent := (SELECT ismultievent FROM om_visit_class WHERE id=v_visitclass);
	END IF;

raise notice 'v_extvisitclass %', v_extvisitclass;

	-- get change class
	IF v_extvisitclass <> v_visitclass THEN
		v_isclasschanged = true;
		-- update change of class
		UPDATE om_visit SET class_id=v_visitclass WHERE id=v_id::int8;

		-- message
		SELECT gw_api_getmessage(v_feature, 60) INTO v_message;
	END IF;

	-- setting values default of new visit
	IF isnewvisit THEN
	
		-- dynamics (last user's choice)--
		-- excode
		v_visitextcode =  (SELECT value FROM config_param_user WHERE parameter = 'visitextcode_vdefault' AND cur_user=current_user)::text;		
		--visitcat
		v_visitcat = (SELECT value FROM config_param_user WHERE parameter = 'visitcat_vdefault' AND cur_user=current_user)::integer;		
	

		-- statics (configured on config_param_user forcing values)--
		--status
		v_status = (SELECT value FROM config_param_user WHERE parameter = 'visitstatus_vdefault' AND cur_user=current_user)::integer;
		IF v_status IS NULL THEN
			v_status = 1;
		END IF;
		-- startdate
		v_startdate = (SELECT value FROM config_param_user WHERE parameter = 'visitstartdate_vdefault_' AND cur_user=current_user)::integer;
		IF v_startdate IS NULL THEN
			v_startdate = left (date_trunc('minute', now())::text, 16);
		END IF;
		-- enddate
		v_enddate = (SELECT value FROM config_param_user WHERE parameter = 'visitenddate_vdefault_' AND cur_user=current_user)::integer;				
		-- parameter on singlevisit	
		v_parameter = (SELECT value FROM config_param_user WHERE parameter = concat('visit_parameter_vdefault_', v_featuretype) AND cur_user=current_user)::integer;			
		
	END IF;

	-- Get id column
	EXECUTE 'SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE  i.indrelid = $1::regclass AND i.indisprimary'
		INTO v_idname
		USING v_tablename;
	
	-- For views it suposse pk is the first column
	IF v_idname ISNULL THEN
		EXECUTE '
		SELECT a.attname FROM pg_attribute a   JOIN pg_class t on a.attrelid = t.oid  JOIN pg_namespace s on t.relnamespace = s.oid WHERE a.attnum > 0   AND NOT a.attisdropped
		AND t.relname = $1 
		AND s.nspname = $2
		ORDER BY a.attnum LIMIT 1'
		INTO v_idname
		USING v_tablename, v_schemaname;
	END IF;

	-- Get id column type
	EXECUTE 'SELECT pg_catalog.format_type(a.atttypid, a.atttypmod) FROM pg_attribute a
		JOIN pg_class t on a.attrelid = t.oid
		JOIN pg_namespace s on t.relnamespace = s.oid
		WHERE a.attnum > 0 
		AND NOT a.attisdropped
		AND a.attname = $3
		AND t.relname = $2 
		AND s.nspname = $1
		ORDER BY a.attnum'
			USING v_schemaname, v_tablename, v_idname
			INTO v_columntype;

	RAISE NOTICE '--- gw_api_getvisit : Visit parameters: noinfra % isnewvisit: % featuretype: %, feature_id % v_isclasschanged: % visitclass: %,  v_visit: %,  v_status %  formname: %,  tablename: %,  idname: %, columntype %, device: % ---',
							     v_noinfra, isnewvisit, v_featuretype, v_featureid, v_isclasschanged, v_visitclass, v_id, v_status, v_formname, v_tablename, v_idname, v_columntype, v_device;

	-- upserting data when change from tabData to tabFile
	IF v_currentactivetab = 'tabData' AND v_isclasschanged IS FALSE AND v_status > 0 THEN
--	IF v_currentactivetab = 'tabData' AND isnewvisit THEN

		RAISE NOTICE '--- gw_api_getvisit: Upsert visit calling ''gw_api_setvisit'' with : % ---', p_data;
		
		SELECT gw_api_setvisit (p_data) INTO v_return;
		v_id = ((v_return->>'body')::json->>'feature')::json->>'id';
		v_message = (v_return->>'message');

		RAISE NOTICE '--- UPSERT VISIT CALLED gw_api_setvisit WITH MESSAGE: % ---', v_message;
	END IF;

	-- manage actions
	v_filefeature = '{"featureType":"file", "tableName":"om_visit_event_photo", "idName": "id"}';	
 
	IF v_addfile IS NOT NULL THEN

		RAISE NOTICE '--- ACTION ADD FILE /PHOTO ---';

		-- setting input for insert files function
		v_fields_json = gw_fct_json_object_set_key((v_addfile->>'fileFields')::json,'visit_id', v_id::text);
		v_addfile = gw_fct_json_object_set_key(v_addfile, 'fileFields', v_fields_json);
		v_addfile = replace (v_addfile::text, 'fileFields', 'fields');
		v_addfile = concat('{"data":',v_addfile::text,'}');
		v_addfile = gw_fct_json_object_set_key(v_addfile, 'feature', v_filefeature);
		v_addfile = gw_fct_json_object_set_key(v_addfile, 'client', v_client);

		RAISE NOTICE '--- CALL gw_api_setfileinsert PASSING (v_addfile): % ---', v_addfile;
	
		-- calling insert files function
		SELECT gw_api_setfileinsert (v_addfile) INTO v_addfile;

		-- building message
		v_message1 = v_message::text;
		v_message = (v_addfile->>'message');
		v_message = gw_fct_json_object_set_key(v_message, 'hint', v_message1);

	ELSIF v_deletefile IS NOT NULL THEN

		-- setting input function
		v_fileid = ((v_deletefile ->>'feature')::json->>'id')::text;
		v_filefeature = gw_fct_json_object_set_key(v_filefeature, 'id', v_fileid);
		v_deletefile = gw_fct_json_object_set_key(v_deletefile, 'feature', v_filefeature);

		RAISE NOTICE '--- CALL gw_api_setdelete PASSING (v_deletefile): % ---', v_deletefile;

		-- calling input function
		SELECT gw_api_setdelete(v_deletefile) INTO v_deletefile;
		v_message = (v_deletefile ->>'message')::json;
		
	END IF;
   
	--  Create tabs array	
	v_formtabs := '[';
       
		-- Data tab
		-----------
		IF v_activedatatab OR v_activefilestab IS NOT TRUE THEN

			IF isnewvisit THEN

				IF v_formname IS NULL THEN
					RAISE EXCEPTION 'Api is bad configured. There is no form related to tablename';
				END IF;
				
				RAISE NOTICE ' --- GETTING tabData DEFAULT VALUES ON NEW VISIT ---';
				SELECT gw_api_get_formfields( v_formname, 'visit', 'data', null, null, null, null, 'INSERT', null, v_device) INTO v_fields;

				FOREACH aux_json IN ARRAY v_fields
				LOOP					
					-- setting feature id value
					IF (aux_json->>'column_id') = 'arc_id' OR (aux_json->>'column_id')='node_id' OR (aux_json->>'column_id')='connec_id' OR (aux_json->>'column_id') ='gully_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'value', v_featureid);
						RAISE NOTICE ' --- SETTING feature id VALUE % ---',v_featureid ;

					END IF;

					-- setting visit id value
					IF (aux_json->>'column_id') = 'visit_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'value', v_id);
						RAISE NOTICE ' --- SETTING visit id VALUE % ---',v_id ;
					END IF;

					-- setting visitclass value
					IF (aux_json->>'column_id') = 'class_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', v_visitclass::text);
						RAISE NOTICE ' --- SETTING visitclass VALUE % ---',v_visitclass ;
					END IF;

					-- setting visitextcode value
					IF (aux_json->>'column_id') = 'ext_code' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', v_visitextcode::text);
						RAISE NOTICE ' --- SETTING v_visitextcode VALUE % ---',v_visitextcode ;
					END IF;

					-- setting visitcat
					IF (aux_json->>'column_id') = 'visitcat_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', v_visitcat::text);
						RAISE NOTICE ' --- SETTING v_visitcat VALUE % ---',v_visitcat ;
					END IF;
									
					-- setting startdate
					IF (aux_json->>'column_id') = 'startdate' THEN		
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'value', v_startdate);	
						RAISE NOTICE ' --- SETTING startdate VALUE --- now()';
					END IF;

					-- setting status
					IF (aux_json->>'column_id') = 'status' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', '1'::text);	
						RAISE NOTICE ' --- SETTING status VALUE % ---', v_status;
					END IF;

					-- setting parameter in case of singleparameter visit
					IF v_ismultievent IS FALSE THEN
						IF (aux_json->>'column_id') = 'parameter_id' THEN
							v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', v_parameter::text);
							RAISE NOTICE ' --- SETTING v_parameter VALUE % ---',v_parameter ;
						END IF;
					END IF;
				END LOOP;
			ELSE 
				SELECT gw_api_get_formfields( v_formname, 'visit', 'data', null, null, null, null, 'INSERT', null, v_device) INTO v_fields;

				RAISE NOTICE ' --- GETTING tabData VALUES ON VISIT  ---';

				-- getting values from feature
				EXECUTE ('SELECT (row_to_json(a)) FROM 
					(SELECT * FROM ' || quote_ident(v_tablename) || ' WHERE ' || quote_ident(v_idname) || ' = CAST($1 AS ' || (v_columntype) || '))a')
					INTO v_values
					USING v_id;
	
				-- replace in case of om_visit table
				v_values = REPLACE (v_values::text, '"id":', '"visit_id":');

				raise notice 'v_values %', v_values;
			
				-- setting values
				FOREACH aux_json IN ARRAY v_fields 
				LOOP          
					array_index := array_index + 1;

					v_fieldvalue := (v_values->>(aux_json->>'column_id'));	
		
					IF (aux_json->>'widgettype')='combo' THEN 
						v_fields[array_index] := gw_fct_json_object_set_key(v_fields[array_index], 'selectedId', COALESCE(v_fieldvalue, ''));

						-- setting parameter in case of singleevent visit
						IF v_ismultievent IS FALSE AND (aux_json->>'column_id') = 'parameter_id' THEN
							v_parameter := (SELECT parameter_id FROM om_visit_class_x_parameter WHERE class_id=v_visitclass LIMIT 1);
							v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'selectedId', v_parameter::text);
						END IF;
					
					ELSE 
						v_fields[array_index] := gw_fct_json_object_set_key(v_fields[array_index], 'value', COALESCE(v_fieldvalue, ''));
					END IF;	

					-- formating dates
					IF (aux_json->>'widgettype')='datepickertime' THEN 
						v_fields[array_index] := gw_fct_json_object_set_key(v_fields[array_index], 'value', left (date_trunc('minute', v_fieldvalue::timestamp)::text, 16));
					END IF;

					-- dissable widgets if visit is status=0
					IF v_status = 0 AND (v_fields[(aux_json->>'orderby')::INT]->>'layout_id')::integer < 9 THEN 
						IF (v_fields[(aux_json->>'orderby')::INT]->>'column_id')!='status' THEN
							v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'iseditable', false);
							v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'disabled', true);
						END IF;
					END IF;									
				END LOOP;			
			END IF;	

			v_fields_json = array_to_json (v_fields);

			v_fields_json := COALESCE(v_fields_json, '{}');	

			RAISE NOTICE ' --- FILLING tabData with v_fields_json  ---';
	

		END IF;

		SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabData' and device = v_device LIMIT 1;

		IF v_tab IS NULL THEN 
			SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabData' LIMIT 1;
		END IF;

		IF v_status = 0 THEN
			v_tab.tabactions = '{}';
		END IF;
		
		v_tabaux := json_build_object('tabName',v_tab.tabname,'tabLabel',v_tab.tablabel, 'tabText',v_tab.tabtext, 'tabFunction', v_tab.tabfunction::json, 'tabActions', v_tab.tabactions::json, 'active',v_activedatatab);
		v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'fields', v_fields_json);
		v_formtabs := v_formtabs || v_tabaux::text;

		RAISE NOTICE ' --- BUILDING tabData with v_tabaux % ---', v_tabaux;

	
		-- Files tab
		------------
		--show tab only if it is not new visit
		--IF isnewvisit IS FALSE OR v_addfile IS NOT NULL OR v_status=0 THEN

			--filling tab (only if it's active)
			IF v_activefilestab THEN

				-- getting filterfields
				IF v_currentactivetab = 'tabFiles' THEN
					v_filterfields := ((p_data->>'data')::json->>'fields')::json;
				END IF;

				-- setting filterfields
				v_data := (p_data->>'data');
				v_data := gw_fct_json_object_set_key(v_data, 'filterFields', v_filterfields);

				-- setting filterfeaturefields using id
				v_filterfeaturefield = '{"visit_id":'||v_id||'}';
				v_data := gw_fct_json_object_set_key(v_data, 'filterFeatureField',v_filterfeaturefield);
				p_data := gw_fct_json_object_set_key(p_data, 'data', v_data);

				v_feature := '{"tableName":"om_visit_event_photo"}';		
						
				-- setting feature
				p_data := gw_fct_json_object_set_key(p_data, 'feature', v_feature);

				--refactor tabNames
				p_data := replace (p_data::text, 'tabFeature', 'feature');
			
				RAISE NOTICE '--- CALLING gw_api_getlist USING p_data: % ---', p_data;
				SELECT gw_api_getlist (p_data) INTO v_fields_json;

				-- getting pageinfo and list values
				v_pageinfo = ((v_fields_json->>'body')::json->>'data')::json->>'pageInfo';
				v_fields_json = ((v_fields_json->>'body')::json->>'data')::json->>'fields';

				-- setting backbutton
	
				
			END IF;
	
			v_fields_json := COALESCE(v_fields_json, '{}');

			-- building tab
			SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabFiles' and device = v_device LIMIT 1;
		
			IF v_tab IS NULL THEN 
				SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabFiles' LIMIT 1;
			END IF;

			IF v_status = 0 THEN
				v_tab.tabactions = '{}';
			END IF;
		
			v_tabaux := json_build_object('tabName',v_tab.tabname,'tabLabel',v_tab.tablabel, 'tabText',v_tab.tabtext, 'tabFunction', v_tab.tabfunction::json, 'tabActions', v_tab.tabactions::json, 'active', v_activefilestab);
			v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'fields', v_fields_json);

			RAISE NOTICE ' --- BUILDING tabFiles with v_tabaux  ---';

	 		-- setting pageInfo
			v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'pageInfo', v_pageinfo);
			v_formtabs := v_formtabs  || ',' || v_tabaux::text;
		--END IF; 		

	--closing tabs array
	v_formtabs := (v_formtabs ||']');

	-- header form
	IF v_noinfra IS TRUE THEN
		v_formheader :=concat('INCIDENCY - ',v_id);	
	ELSE
		v_formheader :=concat('VISIT - ',v_id);	
	END IF;

	-- getting geometry
	EXECUTE ('SELECT row_to_json(a) FROM (SELECT St_AsText(St_simplify(the_geom,0)) FROM om_visit WHERE id=' || quote_literal(v_id) || ')a')
            INTO v_geometry;

        IF isnewvisit IS FALSE THEN        
		IF v_geometry IS NULL AND v_featuretype IS NOT NULL AND v_featureid IS NOT NULL THEN
			EXECUTE ('SELECT row_to_json(a) FROM (SELECT St_AsText(St_simplify(the_geom,0)) FROM ' || quote_ident(v_featuretype) || ' WHERE ' || (v_featuretype) || '_id::text=' || quote_literal(v_featureid) || '::text)a')
				INTO v_geometry;
		END IF;
	END IF;
    		
	-- Create new form
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formId', 'F11'::text);
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formName', v_formheader);
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formTabs', v_formtabs::json);
	

	--  Control NULL's
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_id := COALESCE(v_id, '{}');
	v_message := COALESCE(v_message, '{}');
	v_forminfo := COALESCE(v_forminfo, '{}');
	v_tablename := COALESCE(v_tablename, '{}');
	v_layermanager := COALESCE(v_layermanager, '{}');
	v_geometry := COALESCE(v_geometry, '{}');

  
	-- Return
	RETURN ('{"status":"Accepted", "message":'||v_message||', "apiVersion":'||v_apiversion||
             ',"body":{"feature":{"featureType":"visit", "tableName":"'||v_tablename||'", "idName":"visit_id", "id":'||v_id||'}'||
		    ', "form":'||v_forminfo||
		    ', "data":{"layerManager":'||v_layermanager||
		               ',"geometry":'|| v_geometry ||'}}'||
		    '}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



