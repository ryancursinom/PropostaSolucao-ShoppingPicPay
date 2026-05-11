CREATE OR REPLACE TRIGGER trg_valida_transacao
BEFORE INSERT ON transacao
FOR EACH ROW
EXECUTE FUNCTION fn_verifica_transacao();