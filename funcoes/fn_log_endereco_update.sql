CREATE OR REPLACE FUNCTION fn_log_endereco_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$

DECLARE
    campo                     VARCHAR(50);
    valor_antigo              VARCHAR(50);
    valor_novo                VARCHAR(50);
    descricao_log             TEXT;
    id_estabelecimento        INTEGER;
    lista_ids_colaboradores   INTEGER[];
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
        id
    INTO id_estabelecimento
    FROM estabelecimento
    WHERE id_endereco = NEW.id;


    IF id_estabelecimento IS NOT NULL THEN

        INSERT INTO log_endereco_estabelecimento (
            id_endereco,
            id_estabelecimento,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            descricao
        )
        VALUES (
            NEW.id,
            id_estabelecimento,
            TG_OP,
            NOW(),
            CURRENT_USER,
            descricao_log
        );

    END IF;


    SELECT
        ARRAY_AGG(id)
    INTO lista_ids_colaboradores
    FROM colaborador
    WHERE id_endereco = NEW.id;


    IF lista_ids_colaboradores IS NOT NULL THEN

        FOR i IN 1..array_length(lista_ids_colaboradores, 1)
        LOOP

            INSERT INTO log_endereco_colaborador (
                id_endereco,
                id_colaborador,
                tipo_mudanca,
                data_hora_mudanca,
                usuario_responsavel,
                descricao
            )
            VALUES (
                NEW.id,
                lista_ids_colaboradores[i],
                TG_OP,
                NOW(),
                CURRENT_USER,
                descricao_log
            );

        END LOOP;

    END IF;


    IF id_estabelecimento IS NULL
    AND lista_ids_colaboradores IS NULL THEN

        INSERT INTO log_endereco (
            id_endereco,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            descricao
        )
        VALUES (
            NEW.id,
            TG_OP,
            NOW(),
            CURRENT_USER,
            descricao_log
        );

    END IF;


    RETURN NEW;

END;
$$;