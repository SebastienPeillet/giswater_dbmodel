/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = SCHEMA_NAME, public, pg_catalog;

DROP VIEW vi_patterns;
CREATE OR REPLACE VIEW vi_patterns AS 
 SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
   JOIN rpt_inp_node b ON inp_pattern_value.pattern_id=b.pattern_id
UNION
 SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
JOIN inp_reservoir b ON inp_pattern_value.pattern_id=b.pattern_id
UNION
   SELECT inp_pattern_value.id,
    inp_pattern_value.pattern_id, inp_pattern_value.factor_1, inp_pattern_value.factor_2, inp_pattern_value.factor_3, inp_pattern_value.factor_4, inp_pattern_value.factor_5, inp_pattern_value.factor_6,    
    inp_pattern_value.factor_7, inp_pattern_value.factor_8, inp_pattern_value.factor_9, inp_pattern_value.factor_10, inp_pattern_value.factor_11, inp_pattern_value.factor_12,    
    inp_pattern_value.factor_13, inp_pattern_value.factor_14, inp_pattern_value.factor_15, inp_pattern_value.factor_16, inp_pattern_value.factor_17, inp_pattern_value.factor_18
   FROM inp_pattern_value
   JOIN v_inp_demand b ON inp_pattern_value.pattern_id=b.pattern_id
  ORDER BY 1;
  