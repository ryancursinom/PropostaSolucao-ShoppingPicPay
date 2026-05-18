CREATE VIEW vw_dashboard_gestor AS (
    SELECT
        cb.nome AS categoria_beneficio,

        COUNT(DISTINCT ccb.id_cartao) AS total_cartoes_ativos,
        COUNT(DISTINCT c.id_colaborador) AS total_colaboradores_utilizando,

        COALESCE(SUM(ccb.saldo), 0) AS saldo_total_disponivel,

        COUNT(t.id) AS quantidade_transacoes,
        COALESCE(SUM(t.valor), 0) AS valor_total_transacionado,
        COALESCE(AVG(t.valor), 0) AS ticket_medio,

        COUNT(DISTINCT e.id) AS estabelecimentos_utilizados,

        MAX(t.data_tempo_transacao) AS ultima_transacao,

        CASE
            WHEN COALESCE(SUM(ccb.saldo), 0) + COALESCE(SUM(t.valor), 0) > 0
            THEN ROUND(
                (
                    COALESCE(SUM(t.valor), 0) /
                    (
                        COALESCE(SUM(ccb.saldo), 0) +
                        COALESCE(SUM(t.valor), 0)
                    )
                ) * 100,
                2
            )
            ELSE 0
        END AS percentual_utilizado

    FROM categoria_beneficio cb

    LEFT JOIN cartao_categoria_beneficio ccb
    ON ccb.id_categoria_beneficio = cb.id
    AND ccb.ativo = TRUE

    LEFT JOIN cartao c
    ON c.id = ccb.id_cartao

    LEFT JOIN transacao t
    ON t.id_cartao_categoria = ccb.id

    LEFT JOIN estabelecimento e
    ON e.id = t.id_estabelecimento

    GROUP BY
        cb.nome
);