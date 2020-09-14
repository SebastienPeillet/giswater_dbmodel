/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = 'SCHEMA_NAME', public;


DROP TRIGGER IF EXISTS gw_trg_vi_tanks ON vi_tanks;
CREATE TRIGGER gw_trg_vi_tanks
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_tanks
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_tanks');

DROP TRIGGER IF EXISTS gw_trg_vi_valves ON vi_valves;
CREATE TRIGGER gw_trg_vi_valves
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_valves
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_valves');

DROP TRIGGER IF EXISTS gw_trg_vi_curves ON vi_curves;
CREATE TRIGGER gw_trg_vi_curves
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON vi_curves
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_vi('vi_curves');