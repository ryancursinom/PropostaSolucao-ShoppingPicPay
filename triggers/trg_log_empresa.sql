CREATE OR REPLACE TRIGGER trg_log_empresa_insert_delete
AFTER INSERT OR DELETE ON empresa
FOR EACH ROW EXECUTE FUNCTION fn_log_empresa_insert_delete();

CREATE OR REPLACE TRIGGER trg_log_empresa_update
AFTER UPDATE ON empresa
FOR EACH ROW EXECUTE FUNCTION fn_log_empresa_update();