CREATE OR REPLACE VIEW vw_empresas AS (
    SELECT
        e.id AS id_empresa,
        e.nome AS empresa,
        SUM(t.valor) AS valor_total_transacoes,
        COUNT(DISTINCT t.id) AS quantidade_transacoes,
        AVG(t.valor) OVER(
            PARTITION BY e.id
        ) AS media_valor_transacoes,
        COUNT(DISTINCT es.id) AS quantidade_estabelecimentos
    FROM
        empresa e
    JOIN
        estabelecimento es
        ON es.id_empresa = e.id
    JOIN
        transacao t
        ON t.id_estabelecimento = es.id

    WHERE
        t.status = 'concluida'

    GROUP BY e.id, e.nome
    ORDER BY e.nome ASC
);