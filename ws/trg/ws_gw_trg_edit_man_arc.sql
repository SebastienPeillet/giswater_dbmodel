﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1314

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_man_arc()
  RETURNS trigger AS
$BODY$
DECLARE 

    inp_table varchar;
    man_table varchar;
    v_sql varchar;
    arc_id_seq int8;
	code_autofill_bool boolean;
	count_aux integer;
	promixity_buffer_aux double precision;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	        man_table:= TG_ARGV[0];
		
	promixity_buffer_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
	
	
    IF TG_OP = 'INSERT' THEN
    
        -- Arc ID
        IF (NEW.arc_id IS NULL) THEN
           -- PERFORM setval('urn_id_seq', gw_fct_urn(),true);
            NEW.arc_id:= (SELECT nextval('urn_id_seq'));
        END IF;

        
        -- Arc catalog ID
		IF (NEW.arccat_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
				RETURN audit_function(1020,1314); 
			END IF; 
			NEW.arccat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"='pipecat_vdefault' AND "cur_user"="current_user"());
			IF (NEW.arccat_id IS NULL) THEN
			NEW.arccat_id := (SELECT arccat_id from arc WHERE ST_DWithin(NEW.the_geom, arc.the_geom,0.001) LIMIT 1);
			IF (NEW.arccat_id IS NULL) THEN
				NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
			END IF;       
		END IF;
		END IF;
        
        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(1008,1314);  
			END IF;
				SELECT count(*)into count_aux FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;	
			IF (NEW.sector_id IS NULL) THEN
				NEW.sector_id := (SELECT "value" FROM config_param_user WHERE "parameter"='sector_vdefault' AND "cur_user"="current_user"());
			END IF;
			IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(1010,1314);          
            END IF;            
        END IF;
        
	-- Dma ID
        IF (NEW.dma_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM dma) = 0) THEN
                RETURN audit_function(1012,1314);  
            END IF;
				SELECT count(*)into count_aux FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;
			IF (NEW.dma_id IS NULL) THEN
				NEW.dma_id := (SELECT "value" FROM config_param_user WHERE "parameter"='dma_vdefault' AND "cur_user"="current_user"());
			END IF; 
            IF (NEW.dma_id IS NULL) THEN
                RETURN audit_function(1014,1314);  
            END IF;            
        END IF;
	
		-- Verified
        IF (NEW.verified IS NULL) THEN
            NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"());
            IF (NEW.verified IS NULL) THEN
                NEW.verified := (SELECT id FROM value_verified limit 1);
            END IF;
        END IF;
		
		-- Presszone
        IF (NEW.presszonecat_id IS NULL) THEN
            NEW.presszonecat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='presszone_vdefault' AND "cur_user"="current_user"());
            IF (NEW.presszonecat_id IS NULL) THEN
                NEW.presszonecat_id := (SELECT id FROM cat_presszone limit 1);
            END IF;
        END IF;

		-- State
        IF (NEW.state IS NULL) THEN
            NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"());
            IF (NEW.state IS NULL) THEN
                NEW.state := (SELECT id FROM value_state limit 1);
            END IF;
        END IF;

		-- State_type
		IF (NEW.state_type IS NULL) THEN
			NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='state_type_vdefault' AND "cur_user"="current_user"());
			IF (NEW.state_type IS NULL) THEN
                NEW.state_type := (SELECT id FROM value_state_type limit 1);
            END IF;
        END IF;
		
		--Inventory
		IF (NEW.inventory IS NULL) THEN
			NEW.inventory :='TRUE';
		END IF; 		
			
		-- Exploitation
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"());
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					PERFORM audit_function(2012,1314);
				END IF;		
			END IF;
		END IF;

		-- Municipality 
		IF (NEW.muni_id IS NULL) THEN
			NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"());
			IF (NEW.muni_id IS NULL) THEN
				NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
				IF (NEW.muni_id IS NULL) THEN
					PERFORM audit_function(2012,1314);
				END IF;	
			END IF;
		END IF;

        SELECT code_autofill INTO code_autofill_bool FROM arc JOIN cat_arc ON cat_arc.id =arc.arccat_id JOIN arc_type ON arc_type.id=cat_arc.arctype_id WHERE cat_arc.id=NEW.arccat_id;
	           
        -- Set EPA type
        NEW.epa_type = 'PIPE';        
    
		-- Workcat_id
		IF (NEW.workcat_id IS NULL) THEN
			NEW.workcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='workcat_vdefault' AND "cur_user"="current_user"());
			IF (NEW.workcat_id IS NULL) THEN
					NEW.workcat_id := (SELECT id FROM cat_work limit 1);
			END IF;
		END IF;
		
		-- Ownercat_id
        IF (NEW.ownercat_id IS NULL) THEN
            NEW.ownercat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='ownercat_vdefault' AND "cur_user"="current_user"());
            IF (NEW.ownercat_id IS NULL) THEN
                NEW.ownercat_id := (SELECT id FROM cat_owner limit 1);
            END IF;
        END IF;
		
		-- Soilcat_id
        IF (NEW.soilcat_id IS NULL) THEN
            NEW.soilcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='soilcat_vdefault' AND "cur_user"="current_user"());
            IF (NEW.soilcat_id IS NULL) THEN
                NEW.soilcat_id := (SELECT id FROM cat_soil limit 1);
            END IF;
        END IF;

		-- Builtdate
		IF (NEW.builtdate IS NULL) THEN
			NEW.builtdate :=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"());
		END IF;
				
		--Copy id to code field	
		IF (NEW.code IS NULL AND code_autofill_bool IS TRUE) THEN 
			NEW.code=NEW.arc_id;
		END IF;
		
		-- DEPENDENCES CONTROL
		-- dma
		IF (SELECT expl_id FROM dma WHERE dma_id=NEW.dma_id) != NEW.expl_id THEN
			RETURN audit_function(2042,1314);
		END IF;
		-- presszone
		IF (SELECT expl_id FROM cat_presszone WHERE id=NEW.presszonecat_id) != NEW.expl_id THEN
			RETURN audit_function(2044,1314);
		END IF;
		-- state type
		IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN	
			RETURN audit_function(2046,1314);
		END IF;
		
			
        -- FEATURE INSERT
		INSERT INTO arc (arc_id, code, node_1,node_2, arccat_id, epa_type, sector_id, "state", state_type, annotation, observ,"comment",custom_length,dma_id, presszonecat_id, soilcat_id, function_type, category_type, fluid_type, location_type,
					workcat_id, workcat_id_end, buildercat_id, builtdate,enddate, ownercat_id, muni_id, postcode, streetaxis_id, postnumber, postcomplement,
					streetaxis2_id,postnumber2, postcomplement2,descript,verified,the_geom,undelete,label_x,label_y,label_rotation,  publish, inventory, expl_id,num_value)
					VALUES (NEW.arc_id, NEW.code, null, null, NEW.arccat_id, NEW.epa_type, NEW.sector_id, NEW."state", NEW.state_type, NEW.annotation, NEW.observ, NEW.comment, NEW.custom_length,NEW.dma_id,NEW. presszonecat_id, 
					NEW.soilcat_id, NEW.function_type, NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, NEW.builtdate,NEW.enddate, NEW.ownercat_id,
					NEW.muni_id, NEW.postcode, NEW.streetaxis_id,NEW.postnumber, NEW.postcomplement, NEW.streetaxis2_id, NEW.postnumber2, NEW.postcomplement2, 
					NEW.descript, NEW.verified, NEW.the_geom,NEW.undelete,NEW.label_x,NEW.label_y,NEW.label_rotation, NEW.publish, NEW.inventory, NEW.expl_id, NEW.num_value);
		
		-- MAN INSERT
		IF man_table='man_pipe' THEN 			
				INSERT INTO man_pipe (arc_id) VALUES (NEW.arc_id);			
			
		ELSIF man_table='man_varc' THEN		
				INSERT INTO man_varc (arc_id) VALUES (NEW.arc_id);		
		END IF;
		
        -- EPA INSERT
        IF (NEW.epa_type = 'PIPE') THEN 
            inp_table:= 'inp_pipe';
            v_sql:= 'INSERT INTO '||inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
            EXECUTE v_sql;
        END IF;
		
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
	
		-- State
		IF (NEW.state != OLD.state) THEN
			UPDATE arc SET state=NEW.state WHERE arc_id = OLD.arc_id;
		END IF;
		
		-- State_type
		IF NEW.state=0 AND OLD.state=1 THEN
			IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN
			NEW.state_type=(SELECT "value" FROM config_param_user WHERE parameter='statetype_end_vdefault' AND "cur_user"="current_user"());
				IF NEW.state_type IS NULL THEN
				NEW.state_type=(SELECT id from value_state_type WHERE state=0 LIMIT 1);
					IF NEW.state_type IS NULL THEN
					RETURN audit_function(2110,1318);
					END IF;
				END IF;
			END IF;
		END IF;
			
		-- The geom
		IF (NEW.the_geom IS DISTINCT FROM OLD.the_geom)  THEN
			UPDATE arc SET the_geom=NEW.the_geom WHERE arc_id = OLD.arc_id;
		END IF;
			
		-- DEPENDENCES CONTROL
		-- dma
		IF (SELECT expl_id FROM dma WHERE dma_id=NEW.dma_id) != NEW.expl_id THEN
			RETURN audit_function(2042,1314);
		END IF;
		-- presszone
		IF (SELECT expl_id FROM cat_presszone WHERE id=NEW.presszonecat_id) != NEW.expl_id THEN
			RETURN audit_function(2044,1314);
		END IF;
		-- state type
		IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN	
			RETURN audit_function(2046,1314);
		END IF;
		
		
		UPDATE arc
		SET code=NEW.code, arccat_id=NEW.arccat_id, epa_type=NEW.epa_type, sector_id=NEW.sector_id,  state_type=NEW.state_type, annotation= NEW.annotation, "observ"=NEW.observ, 
				"comment"=NEW.comment, custom_length=NEW.custom_length, dma_id=NEW.dma_id, presszonecat_id=NEW.presszonecat_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type,
				category_type=NEW.category_type, fluid_type=NEW.fluid_type, location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end, 
				buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate, ownercat_id=NEW.ownercat_id, muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, 
				streetaxis2_id=NEW.streetaxis2_id,postcode=NEW.postcode, postnumber=NEW.postnumber, postnumber2=NEW.postnumber2,descript=NEW.descript, verified=NEW.verified, undelete=NEW.undelete, label_x=NEW.label_x,
				postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2,label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, expl_id=NEW.expl_id,num_value=NEW.num_value
			WHERE arc_id=OLD.arc_id;
			
        RETURN NEW;

     ELSIF TG_OP = 'DELETE' THEN 
	 
		PERFORM gw_fct_check_delete(OLD.arc_id, 'ARC');
	 
        DELETE FROM arc WHERE arc_id = OLD.arc_id;
        RETURN NULL;
     
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  

DROP TRIGGER IF EXISTS gw_trg_edit_man_pipe ON "SCHEMA_NAME".v_edit_man_pipe;
CREATE TRIGGER gw_trg_edit_man_pipe INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_pipe FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_pipe');

DROP TRIGGER IF EXISTS gw_trg_edit_man_varc ON "SCHEMA_NAME".v_edit_man_varc;
CREATE TRIGGER gw_trg_edit_man_varc INSTEAD OF INSERT OR DELETE OR UPDATE ON "SCHEMA_NAME".v_edit_man_varc FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".gw_trg_edit_man_arc('man_varc');
      