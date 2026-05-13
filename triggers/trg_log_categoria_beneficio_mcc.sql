CREATE OR REPLACE TRIGGER trg_log_categoria_beneficio_mcc
AFTER INSERT OR UPDATE OR DELETE ON categoria_beneficio_mcc
FOR EACH ROW EXECUTE FUNCTION fn_log_categoria_beneficio_mcc();