CREATE OR REPLACE FUNCTION fn_log_cartao_categoria_beneficio()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_cartao_categoria_beneficio (
            id_cartao_categoria_beneficio,
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
            'PROCESSADO',
            'Registro ' || NEW.id || ' inserido com status ' || NEW.ativo || ' na tabela cartao_categoria_beneficio às ' || NOW()
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

        INSERT INTO log_cartao_categoria_beneficio (
            id_cartao_categoria_beneficio,
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
            'PROCESSADO',
            descricao_log

        );

        RETURN NEW;


    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO log_cartao_categoria_beneficio (
            id_cartao_categoria_beneficio,
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
            'PROCESSADO',
            'Registro ' || OLD.id || ' deletado da tabela cartao_categoria_beneficio às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;