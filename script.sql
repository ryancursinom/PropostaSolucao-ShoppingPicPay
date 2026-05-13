DROP TABLE IF EXISTS endereco                       CASCADE;
DROP TABLE IF EXISTS colaborador                    CASCADE;
DROP TABLE IF EXISTS estabelecimento                CASCADE;
DROP TABLE IF EXISTS cartao                         CASCADE;
DROP TABLE IF EXISTS mcc                            CASCADE;
DROP TABLE IF EXISTS categoria_beneficio            CASCADE;
DROP TABLE IF EXISTS categoria_beneficio_mcc        CASCADE;
DROP TABLE IF EXISTS cartao_categoria_beneficio     CASCADE;
DROP TABLE IF EXISTS transacao                      CASCADE;

DROP TABLE IF EXISTS log_endereco                   CASCADE;
DROP TABLE IF EXISTS log_endereco_colaborador       CASCADE;
DROP TABLE IF EXISTS log_endereco_estabelecimento   CASCADE;
DROP TABLE IF EXISTS log_colaborador                CASCADE;
DROP TABLE IF EXISTS log_estabelecimento            CASCADE;
DROP TABLE IF EXISTS log_cartao                     CASCADE;
DROP TABLE IF EXISTS log_cartao_categoria_beneficio CASCADE;
DROP TABLE IF EXISTS log_categoria_beneficio_mcc    CASCADE;
DROP TABLE IF EXISTS log_transacao                  CASCADE;

CREATE TABLE endereco (
    id              SERIAL       PRIMARY KEY,
    cep             VARCHAR(9)   NOT NULL,
    numero          VARCHAR(10),
    rua             VARCHAR(30)  NOT NULL,
    bairro          VARCHAR(30)  NOT NULL,
    cidade          VARCHAR(25)  NOT NULL,
    estado          CHAR(2)
                    CHECK (
                        estado IN (
                            'SP','RJ','MG','ES','PR','SC','RS',
                            'BA','PE','CE','GO','MT','MS',
                            'DF','AM','PA','AC','AP','RO',
                            'RR','TO','MA','PI','RN','PB',
                            'AL','SE'
                        )
                    ),
    complemento     VARCHAR(50)
);

CREATE TABLE colaborador (
    id              SERIAL        PRIMARY KEY,
    cpf             CHAR(11)      UNIQUE NOT NULL,
    nome            VARCHAR(120)  NOT NULL,
    telefone        VARCHAR(20)   UNIQUE,
    email           VARCHAR(255)  UNIQUE NOT NULL,
    data_nascimento DATE          NOT NULL,
    status          VARCHAR(20)   DEFAULT 'ativo'
                    CHECK (status IN ('ativo', 'inativo')),
    id_endereco     INTEGER       NOT NULL REFERENCES endereco(id)
);

CREATE TABLE cartao (
    id              SERIAL        PRIMARY KEY,
    id_colaborador  INTEGER       NOT NULL REFERENCES colaborador(id) ON DELETE CASCADE,
    numero_cartao   VARCHAR(19)   UNIQUE NOT NULL,
    validade        DATE          NOT NULL,
    bandeira        VARCHAR(50)   NOT NULL,
    tipo_pagamento  VARCHAR(50)   DEFAULT 'credito',
    cvv             CHAR(4)       NOT NULL
);

CREATE TABLE categoria_beneficio (
    id              SERIAL        PRIMARY KEY,
    nome            VARCHAR(50)   UNIQUE NOT NULL,
    descricao       VARCHAR(255)
);

CREATE TABLE cartao_categoria_beneficio (
    id                        SERIAL         PRIMARY KEY,
    id_cartao                INTEGER         NOT NULL REFERENCES cartao(id) ON DELETE CASCADE,
    id_categoria_beneficio   INTEGER         NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
    saldo                    NUMERIC(18,6)  NOT NULL DEFAULT 0
                             CHECK (saldo >= 0),
    ativo                    BOOLEAN         DEFAULT TRUE,
    UNIQUE (id_cartao, id_categoria_beneficio)
);

CREATE TABLE mcc (
    id              SERIAL        PRIMARY KEY,
    codigo          INTEGER       UNIQUE NOT NULL,
    descricao       VARCHAR(120)
);

CREATE TABLE categoria_beneficio_mcc (
    id              SERIAL        PRIMARY KEY,
    id_categoria    INTEGER       NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
    id_mcc          INTEGER       NOT NULL REFERENCES mcc(id) ON DELETE CASCADE,
    UNIQUE (id_categoria, id_mcc)
);

CREATE TABLE estabelecimento (
    id              SERIAL                    PRIMARY KEY,
    nome            VARCHAR(120)              NOT NULL,
    cnpj            VARCHAR(14)               UNIQUE NOT NULL,
    telefone        VARCHAR(11)               NOT NULL,
    email           VARCHAR(255)              NOT NULL,
    status          BOOLEAN                   DEFAULT TRUE,
    data_cadastro   TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    id_mcc          INTEGER                   NOT NULL REFERENCES mcc(id),
    id_endereco     INTEGER                   NOT NULL REFERENCES endereco(id)
);

CREATE TABLE transacao (
    id                      SERIAL                    PRIMARY KEY,
    valor                   NUMERIC(18,6)            NOT NULL
                            CHECK (valor > 0),
    id_cartao_categoria     INTEGER                   NOT NULL REFERENCES cartao_categoria_beneficio(id),
    id_estabelecimento      INTEGER                   NOT NULL REFERENCES estabelecimento(id),
    data_tempo_transacao    TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    status                  VARCHAR(20)               DEFAULT 'aprovada'
                            CHECK (status IN ('aprovada', 'negada', 'estornada'))
);

CREATE TABLE log_endereco (
    id                    SERIAL                    PRIMARY KEY,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    id_endereco           INTEGER                   NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_endereco_colaborador (
    id                    SERIAL                    PRIMARY KEY,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    id_colaborador        INTEGER                   NOT NULL,
    id_endereco           INTEGER                   NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_endereco_estabelecimento (
    id                    SERIAL                    PRIMARY KEY,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    id_estabelecimento    INTEGER                   NOT NULL,
    id_endereco           INTEGER                   NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_colaborador (
    id                    SERIAL                    PRIMARY KEY,
    id_colaborador        INTEGER                   NOT NULL,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    status                VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_status
        CHECK (status IN ('ativo', 'inativo')),
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);


CREATE TABLE log_estabelecimento (
    id                    SERIAL                    PRIMARY KEY,
    id_estabelecimento    INTEGER                   NOT NULL,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    status                BOOLEAN                   NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_status
        CHECK (LOWER(status::TEXT) IN ('true', 'false')),
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_cartao (
    id                    SERIAL                    PRIMARY KEY,
    id_cartao             INTEGER                   NOT NULL,
    tipo_mudanca          VARCHAR(255)              NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_cartao_categoria_beneficio (
    id                                SERIAL                    PRIMARY KEY,
    id_cartao_categoria_beneficio     INTEGER                   NOT NULL,
    tipo_mudanca                      VARCHAR(10)               NOT NULL,
    data_hora_mudanca                 TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel               VARCHAR(20)               NOT NULL,
    status                            VARCHAR(20)               NOT NULL,
    descricao                         TEXT                      NOT NULL,
    CONSTRAINT constraint_status
        CHECK (LOWER(status) IN ('processado', 'erro')),
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_categoria_beneficio_mcc (
    id                              SERIAL                    PRIMARY KEY,
    id_categoria_beneficio_mcc      INTEGER                   NOT NULL,
    tipo_mudanca                    VARCHAR(255)              NOT NULL,
    data_hora_mudanca               TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel             VARCHAR(20)               NOT NULL,
    descricao                       TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_transacao (
    id                    SERIAL                    PRIMARY KEY,
    id_transacao          INTEGER                   NOT NULL,
    tipo_mudanca          VARCHAR(255)              NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    status                VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_status
        CHECK (LOWER(status) IN ('aprovada', 'negada', 'estornada')),
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

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

CREATE OR REPLACE TRIGGER trg_valida_transacao
BEFORE INSERT ON transacao
FOR EACH ROW
EXECUTE FUNCTION fn_verifica_transacao();

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

CREATE OR REPLACE PROCEDURE proc_recarga_vr()
LANGUAGE plpgsql
AS $$
DECLARE
    id_vale_refeicao INTEGER;
    v_id_cartao INTEGER;
BEGIN
    SELECT
        id INTO id_vale_refeicao
    FROM categoria_beneficio
    WHERE nome LIKE '%refei__o%';

    FOR v_id_cartao IN
        (
            SELECT
                id
            FROM cartao_categoria_beneficio
            WHERE id_categoria_beneficio = id_vale_refeicao
              AND ativo = TRUE
        )
    LOOP
        BEGIN
            UPDATE cartao_categoria_beneficio
            SET saldo = saldo + 59.67
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
                'Recarga do vale refeição.'
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
                    'Erro ao realizar recarga do vale refeição.'
                );
        END;
    END LOOP;

    COMMIT;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_recarga_vt()
LANGUAGE plpgsql
AS $$
DECLARE
    id_vale_transporte INTEGER;
    v_id_cartao INTEGER;
BEGIN
    SELECT
        id INTO id_vale_transporte
    FROM categoria_beneficio
    WHERE nome LIKE '%transporte%';

    FOR v_id_cartao IN
        (
            SELECT
                id
            FROM cartao_categoria_beneficio
            WHERE id_categoria_beneficio = id_vale_transporte
              AND ativo = TRUE
        )
    LOOP
        BEGIN
            UPDATE cartao_categoria_beneficio
            SET saldo = saldo + 233.20
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
                'Recarga do vale transporte.'
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
                    'Erro ao realizar recarga do vale transporte.'
                );
        END;
    END LOOP;

    COMMIT;
END;
$$;

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

CREATE OR REPLACE FUNCTION fn_log_cartao()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_cartao (
            id_cartao,
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
            'Registro ' || NEW.id || ' inserido na tabela cartao às ' || NOW()
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

        INSERT INTO log_cartao (
            id_cartao,
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

        RETURN NEW;


    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO log_cartao (
            id_cartao,
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
            'Registro ' || OLD.id || ' deletado da tabela cartao às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;

CREATE OR REPLACE FUNCTION fn_log_categoria_beneficio_mcc()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_categoria_beneficio_mcc (
            id_categoria_beneficio_mcc,
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
            'Registro ' || NEW.id || ' inserido na tabela categoria_beneficio_mcc às ' || NOW()
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

        INSERT INTO log_categoria_beneficio_mcc (
            id_categoria_beneficio_mcc,
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

        RETURN NEW;


    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO log_categoria_beneficio_mcc (
            id_categoria_beneficio_mcc,
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
            'Registro ' || OLD.id || ' deletado da tabela categoria_beneficio_mcc às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;

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

CREATE OR REPLACE FUNCTION fn_log_estabelecimento()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_estabelecimento (
            id_estabelecimento,
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
            'Registro ' || NEW.id || ' inserido com status ' || NEW.status || ' na tabela estabelecimento às ' || NOW()
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

        INSERT INTO log_estabelecimento (
            id_estabelecimento,
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
        INSERT INTO log_estabelecimento (
            id_estabelecimento,
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
            'Registro ' || OLD.id || ' deletado da tabela estabelecimento às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;

CREATE OR REPLACE FUNCTION fn_log_transacao()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    campo VARCHAR(50);
    valor_antigo VARCHAR(50);
    valor_novo VARCHAR(50);
    descricao_log TEXT;
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_transacao (
            id_transacao,
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
            'Registro ' || NEW.id || ' inserido com status ' || NEW.status || ' na tabela transacao às ' || NOW()
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

        INSERT INTO log_transacao (
            id_transacao,
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
        INSERT INTO log_transacao (
            id_transacao,
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
            'Registro ' || OLD.id || ' deletado da tabela transacao às ' || NOW()
        );

        RETURN OLD;

    END IF;
END; $$;

CREATE OR REPLACE TRIGGER trg_log_cartao_categoria_beneficio
AFTER INSERT OR UPDATE OR DELETE ON cartao_categoria_beneficio
FOR EACH ROW EXECUTE FUNCTION fn_log_cartao_categoria_beneficio();

CREATE OR REPLACE TRIGGER trg_log_cartao
AFTER INSERT OR UPDATE OR DELETE ON cartao
FOR EACH ROW EXECUTE FUNCTION fn_log_cartao();

CREATE OR REPLACE TRIGGER trg_log_categoria_beneficio_mcc
AFTER INSERT OR UPDATE OR DELETE ON categoria_beneficio_mcc
FOR EACH ROW EXECUTE FUNCTION fn_log_categoria_beneficio_mcc();

CREATE OR REPLACE TRIGGER trg_log_colaborador
AFTER INSERT OR UPDATE OR DELETE ON colaborador
FOR EACH ROW EXECUTE FUNCTION fn_log_colaborador();

CREATE OR REPLACE TRIGGER trg_log_endereco_insert_delete
AFTER INSERT OR DELETE ON endereco
FOR EACH ROW EXECUTE FUNCTION fn_log_endereco_insert_delete();

CREATE OR REPLACE TRIGGER trg_log_endereco_update
AFTER UPDATE ON endereco
FOR EACH ROW EXECUTE FUNCTION fn_log_endereco_update();

CREATE OR REPLACE TRIGGER trg_log_estabelecimento
AFTER INSERT OR UPDATE OR DELETE ON estabelecimento
FOR EACH ROW EXECUTE FUNCTION fn_log_estabelecimento();

CREATE OR REPLACE TRIGGER trg_log_transacao
AFTER INSERT OR UPDATE OR DELETE ON transacao
FOR EACH ROW EXECUTE FUNCTION fn_log_transacao();