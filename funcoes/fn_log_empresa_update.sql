CREATE OR REPLACE FUNCTION fn_log_empresa_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$

DECLARE
    campo                     VARCHAR(50);
    valor_antigo              VARCHAR(50);
    valor_novo                VARCHAR(50);
    descricao_log             TEXT;
    lista_ids_estabelecimento INTEGER[];
    i                         INTEGER;

BEGIN

    descricao_log :=
        'Registro ' || OLD.id ||
        ' atualizado às ' || NOW() ||
        '. Os seguintes campos foram atualizados:';


    FOR campo, valor_antigo IN
        SELECT *
        FROM json_each_text(row_to_json(OLD))
    LOOP

        valor_novo := row_to_json(NEW) ->> campo;

        IF valor_antigo IS DISTINCT FROM valor_novo THEN

            descricao_log :=
                descricao_log ||
                E'\n- Campo: ' || campo ||
                ' -> Mudou de ' || valor_antigo ||
                ' para ' || valor_novo;

        END IF;

    END LOOP;


    SELECT
        ARRAY_AGG(id)
    INTO lista_ids_estabelecimento
    FROM estabelecimento
    WHERE id_estabelecimento = OLD.id;


    IF lista_ids_estabelecimento IS NOT NULL THEN

        FOR i IN 1..array_length(lista_ids_estabelecimento, 1)
        LOOP

            INSERT INTO log_empresa_estabelecimento (
                id_empresa,
                id_estabelecimento,
                tipo_mudanca,
                data_hora_mudanca,
                usuario_responsavel,
                descricao
            )
            VALUES (
                OLD.id,
                lista_ids_estabelecimento[i],
                TG_OP,
                NOW(),
                CURRENT_USER,
                descricao_log
            );

        END LOOP;

    END IF;


    IF id_estabelecimento IS NULL
    AND lista_ids_estabelecimento IS NULL THEN

        INSERT INTO log_empresa (
            id_empresa,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            descricao
        )
        VALUES (
            OLD.id,
            TG_OP,
            NOW(),
            CURRENT_USER,
            descricao_log
        );

    END IF;


    RETURN NEW;

END;
$$;