CREATE OR REPLACE FUNCTION fn_validar_mcc(
    id_estabelecimento_transacao INTEGER,
    id_cartao_transacao INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    estabelecimento_mcc INTEGER;
    categoria_mcc INTEGER;
BEGIN
    SELECT
        codigo INTO estabelecimento_mcc
    FROM estabelecimento e
    JOIN mcc m ON m.id = e.id_mcc
    WHERE e.id = id_estabelecimento_transacao;

    SELECT
        codigo INTO categoria_mcc
    FROM cartao_categoria_beneficio cc
    JOIN categoria_beneficio cb
        ON cb.id = cc.id_categoria_beneficio
    JOIN categoria_beneficio_mcc cbm
        ON cbm.id_categoria = cb.id
    JOIN mcc m
        ON m.id = cbm.id_mcc
       AND m.codigo = estabelecimento_mcc
    WHERE cc.id = id_cartao_transacao;

    IF categoria_mcc IS NOT NULL THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$$;