CREATE OR REPLACE TRIGGER trg_log_estabelecimento
AFTER INSERT OR UPDATE OR DELETE ON estabelecimento
FOR EACH ROW EXECUTE FUNCTION fn_log_estabelecimento();