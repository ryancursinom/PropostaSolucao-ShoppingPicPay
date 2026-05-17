-- View: vw_categoria_mcc
-- Explicação: View que relaciona categorias de benefício aos códigos MCC permitidos, auxiliando na validação das regras de utilização dos benefícios.

CREATE VIEW vw_categoria_mcc AS (
    SELECT
        cb.nome AS categoria,
        m.codigo,
        m.descricao
    FROM categoria_beneficio_mcc cbm

    JOIN categoria_beneficio cb
    ON cbm.id_categoria = cb.id

    JOIN mcc m
    ON cbm.id_mcc = m.id
);
