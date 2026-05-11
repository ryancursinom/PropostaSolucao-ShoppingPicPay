CREATE OR REPLACE FUNCTION fn_verifica_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    mcc_valido INTEGER;
    valor_cartao NUMERIC;
BEGIN
    SELECT
        fn_validar_mcc(
            NEW.id_estabelecimento,
            NEW.id_cartao_categoria
        ) INTO mcc_valido;

    IF mcc_valido = 1 THEN
        SELECT
            saldo INTO valor_cartao
        FROM cartao_categoria_beneficio
        WHERE id = NEW.id_cartao_categoria;

        IF valor_cartao >= NEW.valor THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION
                'Transação negada pois você não tem saldo suficiente no cartão!';
        END IF;
    ELSE
        RAISE EXCEPTION
            'Transação negada pois o código MCC do estabelecimento e do cartão não combinam!';
    END IF;
END;
$$;