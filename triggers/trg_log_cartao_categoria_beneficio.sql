CREATE OR REPLACE TRIGGER trg_log_cartao_categoria_beneficio
AFTER INSERT OR UPDATE OR DELETE ON cartao_categoria_beneficio
FOR EACH ROW EXECUTE FUNCTION fn_log_cartao_categoria_beneficio();