CREATE OR REPLACE TRIGGER trg_log_endereco_insert_delete
AFTER INSERT OR DELETE ON endereco
FOR EACH ROW EXECUTE FUNCTION fn_log_endereco_insert_delete();

CREATE OR REPLACE TRIGGER trg_log_endereco_update
AFTER UPDATE ON endereco
FOR EACH ROW EXECUTE FUNCTION fn_log_endereco_update();