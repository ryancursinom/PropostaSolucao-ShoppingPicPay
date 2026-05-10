CREATE OR REPLACE PROCEDURE proc_recarga_va()
LANGUAGE plpgsql
AS $$
DECLARE
    id_vale_alimentacao INTEGER;
    v_id_cartao INTEGER;
BEGIN
    SELECT
        id INTO id_vale_alimentacao
    FROM categoria_beneficio
    WHERE nome LIKE '%alimenta__o%';

    FOR v_id_cartao IN
        (
            SELECT
                id
            FROM cartao_categoria_beneficio
            WHERE id_categoria_beneficio = id_vale_alimentacao
              AND ativo = TRUE
        )
    LOOP
        BEGIN
            UPDATE cartao_categoria_beneficio
            SET saldo = saldo + 548.00
            WHERE id = v_id_cartao;

            INSERT INTO log_cartao_categoria_beneficio(
                id_cartao_categoria_beneficio,
                tipo_mudanca,
                usuario_responsavel,
                status,
                descricao
            ) VALUES (
                v_id_cartao,
                'UPDATE',
                CURRENT_USER,
                'PROCESSADO',
                'Recarga do vale alimentação realizada.'
            );

        EXCEPTION
            WHEN OTHERS THEN
                INSERT INTO log_cartao_categoria_beneficio(
                    id_cartao_categoria_beneficio,
                    tipo_mudanca,
                    usuario_responsavel,
                    status,
                    descricao
                ) VALUES (
                    id_cartao,
                    'UPDATE',
                    CURRENT_USER,
                    'ERRO',
                    'Erro ao realizar recarga do vale alimentação.'
                );
        END;
    END LOOP;

    COMMIT;
END;
$$;