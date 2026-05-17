-- View: vw_ranking_estabelecimentos
-- Explicação: View responsável por gerar um ranking de estabelecimentos com base na quantidade de transações e no faturamento movimentado.

CREATE VIEW vw_ranking_estabelecimentos AS
SELECT
    e.nome,
    COUNT(t.id) AS qtd_transacoes,
    SUM(t.valor) AS faturamento
FROM estabelecimento e

JOIN transacao t
ON t.id_estabelecimento = e.id

GROUP BY e.nome
ORDER BY faturamento DESC;
