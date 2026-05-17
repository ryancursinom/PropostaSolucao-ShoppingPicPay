-- View: vw_saldo_beneficio
-- Explicação: View utilizada para consultar os saldos disponíveis de cada categoria de benefício vinculada aos cartões dos colaboradores.

CREATE VIEW vw_saldo_beneficio AS
SELECT
    ccb.id,
    co.nome AS colaborador,
    ca.numero_cartao,
    cb.nome AS categoria,
    ccb.saldo,
    ccb.ativo
FROM cartao_categoria_beneficio ccb
JOIN cartao ca
ON ccb.id_cartao = ca.id
JOIN colaborador co
ON ca.id_colaborador = co.id
JOIN categoria_beneficio cb
ON ccb.id_categoria_beneficio = cb.id;
