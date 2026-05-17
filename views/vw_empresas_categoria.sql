CREATE VIEW vw_empresas_categoria AS (
    SELECT
        e.id AS id_empresa,
        e.nome AS empresa,
        cb.nome AS categoria,
        SUM(t.valor) AS valor_total_transacoes,
        COUNT(DISTINCT t.id) AS quantidade_transacoes,
        AVG(t.valor) OVER(
            PARTITION BY e.id, cb.id
        ) AS media_valor_transacoes,
    FROM
        empresa e
    JOIN
        estabelecimento es
        ON es.id_empresa = e.id
    JOIN
        transacao t
        ON t.id_estabelecimento = es.id
    JOIN
        cartao_categoria_beneficio ccb
        ON ccb.id = t.id_cartao_categoria
    JOIN
        categoria_beneficio cb
        ON cb.id = ccb.id_categoria_beneficio

    GROUP BY e.id, e.nome, cb.id, cb.nome
    ORDER BY e.nome ASC, cb.nome ASC
);