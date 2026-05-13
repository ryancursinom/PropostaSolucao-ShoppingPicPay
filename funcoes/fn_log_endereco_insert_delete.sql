CREATE OR REPLACE FUNCTION fn_log_endereco_insert_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF (TG_OP = 'INSERT') THEN

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
            'Registro ' || NEW.id ||
            ' inserido na tabela endereco às ' || NOW()
        );

        RETURN NEW;
        
    ELSE

        INSERT INTO log_endereco (
            id_endereco,
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
            'Registro ' || OLD.id ||
            ' deletado da tabela endereco às ' || NOW()
        );

        RETURN OLD;

    END IF;

END;
$$;