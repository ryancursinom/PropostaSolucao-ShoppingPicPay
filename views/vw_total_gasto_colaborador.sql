-- View: vw_total_gasto_colaborador
-- Explicação: View criada para calcular o total gasto e a quantidade de transações realizadas por cada colaborador.

CREATE VIEW vw_total_gasto_colaborador AS (
    SELECT
        co.id,
        co.nome,
        SUM(t.valor) AS total_gasto,
        COUNT(t.id) AS quantidade_transacoes
    FROM colaborador co

    JOIN cartao ca
    ON ca.id_colaborador = co.id

    JOIN transacao t
    ON t.id_cartao = ca.id

    GROUP BY co.id, co.nome
);
