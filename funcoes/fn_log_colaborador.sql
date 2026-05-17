CREATE OR REPLACE FUNCTION fn_log_colaborador()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_colaborador (
            id_colaborador,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            status,
            descricao
        )
        VALUES (
            NEW.id,
            TG_OP,
            NOW(),
            CURRENT_USER,
            NEW.status,
            'Registro ' || NEW.id || ' inserido com status ' || NEW.status || ' na tabela colaborador às ' || NOW()
        );

        RETURN NEW;


    ELSIF (TG_OP = 'UPDATE') THEN
        descricao_log := 'Registro ' || OLD.id || ' atualizado às ' || NOW() || '. Os seguintes campos foram atualizados:';

        FOR campo, valor_antigo IN
            SELECT *
            FROM json_each_text(row_to_json(OLD))
        LOOP

            valor_novo := row_to_json(NEW) ->> campo;

            IF valor_antigo IS DISTINCT FROM valor_novo THEN
                descricao_log := 
                    descricao_log || 
                    E'\n- Campo: ' || campo || 
                    ' -> Mudou de ' || valor_antigo || ' para ' || valor_novo || ' ';
            END IF;

        END LOOP;

        INSERT INTO log_colaborador (
            id_colaborador,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            status,
            descricao
        )
        VALUES (
            NEW.id,
            TG_OP,
            NOW(),
            CURRENT_USER,
            NEW.status,
            descricao_log

        );

        RETURN NEW;


    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO log_colaborador (
            id_colaborador,
            tipo_mudanca,
            data_hora_mudanca,
            usuario_responsavel,
            status,
            descricao
        )
        VALUES (
            OLD.id,
            TG_OP,
            NOW(),
            CURRENT_USER,
            OLD.status,
            'Registro ' || OLD.id || ' deletado da tabela colaborador às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;