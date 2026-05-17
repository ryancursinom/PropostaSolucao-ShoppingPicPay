-- View: vw_cartoes_vencidos
-- Explicação: View utilizada para identificar cartões cuja validade já expirou, auxiliando no controle e manutenção do sistema.

CREATE VIEW vw_cartoes_vencidos AS
SELECT
    id,
    numero_cartao,
    validade
FROM cartao
WHERE validade < CURRENT_DATE;
