-- View: vw_gasto_categoria
-- Explicação: View responsável por consolidar os gastos realizados em cada categoria de benefício com base nos MCCs associados.

CREATE VIEW vw_gasto_categoria AS (
    SELECT
        cb.nome AS categoria,
        SUM(t.valor) AS total_gasto
    FROM transacao t

    JOIN estabelecimento e
    ON t.id_estabelecimento = e.id

    JOIN mcc m
    ON e.id_mcc = m.id

    JOIN categoria_beneficio_mcc cbm
    ON cbm.id_mcc = m.id

    JOIN categoria_beneficio cb
    ON cbm.id_categoria = cb.id

    GROUP BY cb.nome;
);
