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

CREATE TABLE empresa (
    id     SERIAL       PRIMARY KEY
    ,nome   VARCHAR(60) NOT NULL
)

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
    id             SERIAL                   PRIMARY KEY,
    nome           VARCHAR(120)             NOT NULL,
    cnpj           VARCHAR(14)              UNIQUE NOT NULL,
    telefone       VARCHAR(11)              NOT NULL,
    email          VARCHAR(255)             NOT NULL,
    status         BOOLEAN                  DEFAULT TRUE,
    data_cadastro  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    id_mcc         INTEGER                  NOT NULL REFERENCES mcc(id),
    id_endereco    INTEGER                  NOT NULL REFERENCES endereco(id),
    id_empresa     INTEGER                  NOT NULL REFERENCES empresa(id)
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

CREATE TABLE log_empresa (
    id                    SERIAL                    PRIMARY KEY,
    id_empresa            INTEGER                   NOT NULL,
    tipo_mudanca          VARCHAR(255)              NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
    CONSTRAINT constraint_tipo_mudanca
        CHECK (LOWER(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE log_empresa_estabelecimento (
    id                    SERIAL                    PRIMARY KEY,
    tipo_mudanca          VARCHAR(10)               NOT NULL,
    id_estabelecimento    INTEGER                   NOT NULL,
    id_empresa            INTEGER                   NOT NULL,
    data_hora_mudanca     TIMESTAMP WITH TIME ZONE  DEFAULT CURRENT_TIMESTAMP,
    usuario_responsavel   VARCHAR(20)               NOT NULL,
    descricao             TEXT                      NOT NULL,
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

CREATE OR REPLACE FUNCTION fn_log_empresa_insert_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF (TG_OP = 'INSERT') THEN

        INSERT INTO log_empresa (
            id_empresa,
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
            ' inserido na tabela empresa às ' || NOW()
        );

        RETURN NEW;
        
    ELSE

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
            'Registro ' || OLD.id ||
            ' deletado da tabela empresa às ' || NOW()
        );

        RETURN OLD;

    END IF;

END;
$$;

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

CREATE OR REPLACE TRIGGER trg_log_empresa
AFTER INSERT OR DELETE ON empresa
FOR EACH ROW EXECUTE FUNCTION fn_log_empresa_insert_delete();

CREATE OR REPLACE TRIGGER trg_log_empresa
AFTER UPDATE ON empresa
FOR EACH ROW EXECUTE FUNCTION fn_log_empresa_update();

BEGIN;

INSERT INTO mcc (codigo, descricao) VALUES (5411, 'supermercados e mercearias');
INSERT INTO mcc (codigo, descricao) VALUES (5412, 'lojas de conveniencia e mini mercados');
INSERT INTO mcc (codigo, descricao) VALUES (5499, 'lojas de alimentos e bebidas');
INSERT INTO mcc (codigo, descricao) VALUES (5451, 'laticinios e produtos de laticinio');
INSERT INTO mcc (codigo, descricao) VALUES (5422, 'freezer e acougues');
INSERT INTO mcc (codigo, descricao) VALUES (5812, 'restaurantes e lanchonetes');
INSERT INTO mcc (codigo, descricao) VALUES (5814, 'fast food');
INSERT INTO mcc (codigo, descricao) VALUES (5811, 'estabelecimentos alimenticios');
INSERT INTO mcc (codigo, descricao) VALUES (5441, 'docerias e confeitarias');
INSERT INTO mcc (codigo, descricao) VALUES (5462, 'padarias');
INSERT INTO mcc (codigo, descricao) VALUES (5541, 'postos de combustivel');
INSERT INTO mcc (codigo, descricao) VALUES (5542, 'abastecimento automatizado de combustivel');
INSERT INTO mcc (codigo, descricao) VALUES (4111, 'transporte urbano e suburbano');
INSERT INTO mcc (codigo, descricao) VALUES (4131, 'empresas de onibus');
INSERT INTO mcc (codigo, descricao) VALUES (7523, 'estacionamentos e garagens');

INSERT INTO categoria_beneficio (nome, descricao) VALUES ('alimentacao', 'vale alimentacao para uso em supermercados e mercearias');
INSERT INTO categoria_beneficio (nome, descricao) VALUES ('refeicao', 'vale refeicao para uso em restaurantes e lanchonetes');
INSERT INTO categoria_beneficio (nome, descricao) VALUES ('transporte', 'vale transporte para uso em postos e transporte publico');

INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (1, 1);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (1, 2);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (1, 3);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (1, 4);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (1, 5);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (2, 6);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (2, 7);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (2, 8);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (2, 9);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (2, 10);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (3, 11);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (3, 12);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (3, 13);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (3, 14);
INSERT INTO categoria_beneficio_mcc (id_categoria, id_mcc) VALUES (3, 15);

INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39256-242', '4507', 'rua botucatu', 'centro', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87397-532', '8936', 'rua botucatu', 'batel', 'cidade rn', 'RN', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83563-303', '3812', 'rua augusta', 'vila nova', 'rio de janeiro', 'RJ', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('10851-877', '9655', 'rua funchal', 'lapa', 'cidade pi', 'PI', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('30379-320', '5575', 'avenida ibirapuera', 'portao', 'cidade al', 'AL', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57052-967', '6225', 'rua sao joao', 'santa cruz', 'cidade pb', 'PB', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59615-180', '7528', 'avenida brasil', 'mooca', 'rondonopolis', 'MT', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19116-146', '5926', 'travessa das acasias', 'petropolis', 'cidade ap', 'AP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23238-489', '1308', 'rua haddock lobo', 'ahus', 'cidade ma', 'MA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56566-314', '2665', 'rua pamplona', 'agua verde', 'olinda', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80010-846', '1170', 'rua das palmeiras', 'portao', 'cidade ma', 'MA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('99733-432', '4423', 'rua pe mario', 'barra da tijuca', 'salvador', 'BA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45093-167', '5169', 'avenida brasil', 'lapa', 'cidade se', 'SE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94259-569', '8180', 'travessa das acasias', 'vila mariana', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86622-538', '9198', 'avenida brigadeiro', 'bela vista', 'maringa', 'PR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21915-873', '2267', 'avenida brigadeiro', 'copacabana', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88172-165', '2622', 'travessa das acasias', 'bela vista', 'rio de janeiro', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82512-981', '8670', 'rua funchal', 'floresta', 'dourados', 'MS', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24621-400', '4372', 'avenida dom pedro', 'batel', 'sao paulo', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76542-208', '4316', 'rua das flores', 'barra da tijuca', 'taguatinga', 'DF', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('30032-482', '8318', 'travessa das acasias', 'petropolis', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88504-431', '8690', 'rua ana costa', 'pampulha', 'cidade pb', 'PB', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17592-346', '5039', 'rua pamplona', 'santa cruz', 'cidade pa', 'PA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79822-884', '7963', 'rua botucatu', 'vila nova', 'cidade ro', 'RO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('44741-640', '9008', 'avenida berrini', 'batel', 'londrina', 'PR', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62296-787', '3296', 'avenida dom pedro', 'vila mariana', 'cidade rr', 'RR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42493-330', '7398', 'rua vergueiro', 'barra da tijuca', 'cidade to', 'TO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87128-325', '9076', 'rua liberdade', 'centro', 'contagem', 'MG', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18834-132', '965', 'travessa das acasias', 'portao', 'sao paulo', 'SP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38080-652', '4563', 'avenida brigadeiro', 'funcionarios', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22363-199', '6670', 'avenida berrini', 'lapa', 'ponta grossa', 'PR', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17100-789', '6736', 'avenida ibirapuera', 'copacabana', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42591-296', '5560', 'rua pe mario', 'jardim america', 'cidade to', 'TO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70637-355', '3007', 'avenida ibirapuera', 'bela vista', 'santa maria', 'RS', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('95477-653', '1605', 'avenida dom pedro', 'moinhos de vento', 'juiz de fora', 'MG', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63269-597', '3873', 'rua ana costa', 'vila nova', 'cidade se', 'SE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59672-102', '961', 'rua pe mario', 'menino deus', 'cidade pa', 'PA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82845-777', '4674', 'rua funchal', 'jardim botanico', 'dourados', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17665-693', '4862', 'rua augusta', 'bela vista', 'cidade pi', 'PI', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86569-588', '937', 'avenida reboucas', 'boa vista', 'cidade rn', 'RN', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18981-709', '1313', 'rua vergueiro', 'jardim america', 'cidade ac', 'AC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85880-708', '9334', 'rua quinze de novembro', 'flamengo', 'uberlandia', 'MG', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('44179-309', '9563', 'rua das palmeiras', 'botafogo', 'rio de janeiro', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98039-760', '6485', 'rua oscar freire', 'lapa', 'cidade ma', 'MA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70068-736', '1189', 'rua ana costa', 'ipanema', 'juazeiro do norte', 'CE', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('27361-457', '3493', 'avenida dom pedro', 'vila nova', 'cidade ro', 'RO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81200-820', '2585', 'rua haddock lobo', 'copacabana', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('27601-370', '4906', 'avenida dom pedro', 'batel', 'fortaleza', 'CE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46930-719', '2547', 'avenida dom pedro', 'boa vista', 'vitoria', 'ES', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42914-966', '4326', 'rua das palmeiras', 'vila mariana', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('10464-441', '4534', 'avenida ibirapuera', 'agua verde', 'rio de janeiro', 'RJ', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82309-822', '2648', 'rua oscar freire', 'agua verde', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58393-696', '2443', 'rua sao joao', 'santa cruz', 'brasilia', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57795-915', '686', 'avenida paulista', 'botafogo', 'cidade ap', 'AP', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56357-898', '4089', 'rua das palmeiras', 'vila mariana', 'petropolis', 'RJ', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31299-919', '2533', 'rua botucatu', 'floresta', 'cidade ap', 'AP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53540-901', '407', 'avenida ibirapuera', 'santana', 'cidade al', 'AL', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('15075-979', '1772', 'rua da consolacao', 'mooca', 'taguatinga', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39831-328', '5729', 'rua funchal', 'vila mariana', 'cidade pa', 'PA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46585-459', '4565', 'avenida reboucas', 'flamengo', 'campinas', 'SP', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25118-998', '5426', 'avenida dom pedro', 'batel', 'cidade to', 'TO', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88193-544', '627', 'rua oscar freire', 'lourdes', 'caruaru', 'PE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60488-690', '7150', 'avenida reboucas', 'moinhos de vento', 'rondonopolis', 'MT', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78146-925', '7145', 'avenida atlantica', 'jardim america', 'pelotas', 'RS', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('91678-421', '1147', 'avenida ibirapuera', 'copacabana', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97410-518', '8309', 'rua haddock lobo', 'boa vista', 'cidade ma', 'MA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('35144-530', '9084', 'rua haddock lobo', 'portao', 'aparecida de goiania', 'GO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63225-661', '2852', 'rua botucatu', 'batel', 'cidade ma', 'MA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86019-721', '3444', 'rua haddock lobo', 'tatuape', 'cidade se', 'SE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77000-584', '7245', 'rua funchal', 'barra da tijuca', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22240-938', '4650', 'rua sao joao', 'batel', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29313-125', '3681', 'rua haddock lobo', 'batel', 'cidade pb', 'PB', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64321-744', '1194', 'avenida da saude', 'savassi', 'niteroi', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62383-349', '6292', 'avenida atlantica', 'portao', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38683-280', '1747', 'rua ana costa', 'santana', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69829-236', '4083', 'avenida dom pedro', 'jardim america', 'cidade al', 'AL', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68008-727', '9158', 'rua vergueiro', 'batel', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72216-560', '7306', 'avenida dom pedro', 'petropolis', 'cidade se', 'SE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92149-344', '4544', 'travessa das acasias', 'petropolis', 'caruaru', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45614-443', '4682', 'avenida atlantica', 'vila nova', 'olinda', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60205-810', '2472', 'avenida paulista', 'vila nova', 'anapolis', 'GO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81121-577', '6679', 'avenida ibirapuera', 'vila nova', 'londrina', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85456-489', '6382', 'avenida ibirapuera', 'vila mariana', 'brasilia', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80545-865', '6390', 'rua haddock lobo', 'copacabana', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('73654-129', '4472', 'avenida brigadeiro', 'savassi', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('71261-230', '6625', 'rua das palmeiras', 'batel', 'dourados', 'MS', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21003-758', '9698', 'rua pe mario', 'jardim botanico', 'cidade rr', 'RR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('44099-488', '2978', 'rua funchal', 'menino deus', 'taguatinga', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46471-870', '5530', 'avenida reboucas', 'barra da tijuca', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80702-153', '7706', 'rua sao joao', 'mooca', 'cidade se', 'SE', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42411-304', '660', 'rua sao joao', 'agua verde', 'cuiaba', 'MT', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72070-785', '3909', 'avenida paulista', 'floresta', 'cidade se', 'SE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31992-720', '4199', 'avenida atlantica', 'barra da tijuca', 'vila velha', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85849-126', '5097', 'rua da consolacao', 'ahus', 'cidade rr', 'RR', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87607-807', '3250', 'avenida atlantica', 'flamengo', 'juazeiro do norte', 'CE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84177-901', '4942', 'avenida atlantica', 'santa cruz', 'cidade se', 'SE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76317-763', '6072', 'avenida ibirapuera', 'pampulha', 'petropolis', 'RJ', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66822-470', '8032', 'avenida ibirapuera', 'menino deus', 'goiania', 'GO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78386-766', '7136', 'avenida paulista', 'portao', 'cidade to', 'TO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52245-972', '9708', 'avenida ibirapuera', 'barra da tijuca', 'olinda', 'PE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84691-724', '3996', 'rua funchal', 'mooca', 'salvador', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33834-599', '8099', 'rua das flores', 'ipanema', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88139-818', '5577', 'rua oscar freire', 'moinhos de vento', 'pelotas', 'RS', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63271-600', '1403', 'rua augusta', 'funcionarios', 'recife', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12260-195', '8042', 'avenida berrini', 'portao', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97026-695', '3987', 'avenida atlantica', 'flamengo', 'sobral', 'CE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82140-438', '5633', 'rua vergueiro', 'pampulha', 'varzea grande', 'MT', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40217-223', '5024', 'rua oscar freire', 'barra da tijuca', 'rondonopolis', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('35105-321', '8780', 'rua quinze de novembro', 'ipanema', 'cidade rn', 'RN', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23176-952', '9660', 'rua botucatu', 'mooca', 'cidade rn', 'RN', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11854-825', '2940', 'rua pamplona', 'lapa', 'pelotas', 'RS', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26551-753', '894', 'avenida brasil', 'mooca', 'cidade ap', 'AP', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('71524-590', '9406', 'rua das flores', 'santa cruz', 'cidade pb', 'PB', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24953-941', '4137', 'avenida brasil', 'jardim paulista', 'parintins', 'AM', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29887-252', '9454', 'rua sao joao', 'savassi', 'juiz de fora', 'MG', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('89471-710', '1941', 'avenida brigadeiro', 'vila nova', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68028-404', '6233', 'rua vergueiro', 'ahus', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('37235-740', '987', 'rua liberdade', 'tatuape', 'cidade ro', 'RO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32782-665', '2574', 'rua sao joao', 'batel', 'pelotas', 'RS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('48175-133', '7382', 'avenida ibirapuera', 'centro', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40595-370', '7439', 'rua haddock lobo', 'portao', 'feira de santana', 'BA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94886-252', '8923', 'rua quinze de novembro', 'botafogo', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87993-866', '2719', 'avenida brasil', 'vila nova', 'caruaru', 'PE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62757-378', '7680', 'rua quinze de novembro', 'barra da tijuca', 'cidade se', 'SE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66626-852', '9799', 'rua sao joao', 'barra da tijuca', 'cidade ac', 'AC', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98381-956', '1497', 'rua das flores', 'mooca', 'anapolis', 'GO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32962-581', '4416', 'rua das palmeiras', 'ahus', 'cidade ro', 'RO', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('93202-933', '2974', 'rua oscar freire', 'jardim botanico', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52081-786', '6691', 'rua pamplona', 'savassi', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96846-510', '8118', 'avenida ibirapuera', 'ipanema', 'vila velha', 'ES', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52372-218', '5154', 'rua sao joao', 'barra da tijuca', 'cidade se', 'SE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64165-155', '19', 'rua vergueiro', 'menino deus', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('16764-308', '8168', 'rua ana costa', 'floresta', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25915-129', '7179', 'rua haddock lobo', 'jardim botanico', 'caruaru', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82384-517', '5092', 'rua da consolacao', 'portao', 'cidade to', 'TO', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94896-952', '7561', 'rua quinze de novembro', 'petropolis', 'uberlandia', 'MG', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64459-954', '4782', 'avenida atlantica', 'jardim botanico', 'ponta grossa', 'PR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60277-295', '9032', 'rua funchal', 'lapa', 'cidade pa', 'PA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54548-906', '4527', 'rua sao joao', 'menino deus', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86931-693', '4635', 'rua das flores', 'petropolis', 'cidade ac', 'AC', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55236-440', '7317', 'avenida paulista', 'menino deus', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84946-492', '3091', 'avenida reboucas', 'barra da tijuca', 'cidade ap', 'AP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60604-779', '7750', 'avenida reboucas', 'jardim america', 'feira de santana', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23154-995', '2069', 'avenida brasil', 'savassi', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63736-991', '252', 'rua funchal', 'funcionarios', 'manaus', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('91691-809', '4343', 'avenida berrini', 'vila nova', 'cidade to', 'TO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51505-741', '8743', 'avenida reboucas', 'vila nova', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40771-746', '589', 'avenida dom pedro', 'menino deus', 'cidade pi', 'PI', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22903-878', '1481', 'rua botucatu', 'lapa', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('16028-432', '4907', 'rua da consolacao', 'barra da tijuca', 'cidade to', 'TO', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29080-350', '6142', 'rua pamplona', 'tatuape', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32946-180', '2951', 'rua das palmeiras', 'lourdes', 'cidade ac', 'AC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86435-246', '3946', 'rua das palmeiras', 'floresta', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97404-109', '7530', 'rua oscar freire', 'agua verde', 'feira de santana', 'BA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19681-552', '8956', 'rua haddock lobo', 'santana', 'cidade al', 'AL', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69878-965', '6952', 'travessa das acasias', 'tatuape', 'rondonopolis', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59986-685', '1748', 'avenida berrini', 'flamengo', 'sobral', 'CE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96275-505', '4838', 'avenida atlantica', 'tatuape', 'rondonopolis', 'MT', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('47512-894', '804', 'rua das palmeiras', 'lourdes', 'recife', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('91381-356', '3589', 'rua pamplona', 'floresta', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('67779-134', '646', 'rua quinze de novembro', 'agua verde', 'cidade ma', 'MA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52823-865', '1477', 'avenida paulista', 'boa vista', 'cidade ro', 'RO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79579-613', '8838', 'avenida paulista', 'vila mariana', 'taguatinga', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25095-579', '4836', 'avenida berrini', 'mooca', 'caruaru', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21836-909', '6512', 'avenida brigadeiro', 'ahus', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58311-788', '2025', 'avenida dom pedro', 'mooca', 'campo grande', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98452-339', '6087', 'rua pe mario', 'lourdes', 'cidade rn', 'RN', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94889-164', '5375', 'avenida dom pedro', 'floresta', 'cidade pa', 'PA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25292-243', '4952', 'avenida atlantica', 'jardim botanico', 'cidade to', 'TO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40775-650', '1903', 'avenida berrini', 'tatuape', 'rio de janeiro', 'RJ', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86983-860', '8851', 'rua pamplona', 'barra da tijuca', 'ponta grossa', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('90694-517', '1623', 'avenida ibirapuera', 'santana', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68287-341', '3560', 'rua pamplona', 'portao', 'recife', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17936-507', '8921', 'rua pamplona', 'batel', 'cuiaba', 'MT', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94109-754', '1502', 'rua funchal', 'santa cruz', 'caruaru', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84000-310', '3991', 'avenida reboucas', 'jardim america', 'cidade rr', 'RR', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29340-907', '3818', 'rua augusta', 'lourdes', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32871-212', '2130', 'avenida paulista', 'mooca', 'cidade rr', 'RR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87182-431', '5870', 'rua das flores', 'bela vista', 'cidade ma', 'MA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78955-216', '2077', 'avenida brasil', 'mooca', 'campinas', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69245-615', '5932', 'rua funchal', 'savassi', 'cidade rn', 'RN', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70036-758', '8544', 'rua botucatu', 'jardim america', 'vitoria da conquista', 'BA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('74260-829', '6985', 'rua pe mario', 'savassi', 'sao paulo', 'SP', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18609-229', '5278', 'rua sao joao', 'santana', 'manaus', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69469-617', '8693', 'avenida da saude', 'flamengo', 'petrolina', 'PE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66370-562', '1875', 'avenida atlantica', 'santa cruz', 'cidade rr', 'RR', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22463-420', '6533', 'rua funchal', 'ipanema', 'feira de santana', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72163-168', '6133', 'rua oscar freire', 'batel', 'ceilandia', 'DF', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('27054-669', '1583', 'avenida ibirapuera', 'vila nova', 'belo horizonte', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97207-868', '6731', 'rua quinze de novembro', 'batel', 'petropolis', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23579-691', '5120', 'avenida da saude', 'tatuape', 'brasilia', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24184-458', '7901', 'rua das palmeiras', 'bela vista', 'cidade ac', 'AC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66244-965', '4565', 'rua ana costa', 'santa cruz', 'cidade ap', 'AP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33647-379', '4382', 'rua das palmeiras', 'floresta', 'cidade ap', 'AP', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33777-990', '5752', 'avenida reboucas', 'jardim botanico', 'cidade pi', 'PI', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79531-320', '503', 'avenida paulista', 'vila nova', 'ponta grossa', 'PR', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('50846-838', '2579', 'avenida reboucas', 'barra da tijuca', 'dourados', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('30632-872', '862', 'rua sao joao', 'floresta', 'anapolis', 'GO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96761-534', '4459', 'rua sao joao', 'batel', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55242-540', '3532', 'rua oscar freire', 'botafogo', 'cidade pa', 'PA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79066-783', '9718', 'rua das palmeiras', 'batel', 'cariacica', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11007-309', '9820', 'rua pe mario', 'lapa', 'fortaleza', 'CE', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53007-222', '4187', 'avenida paulista', 'ahus', 'sobral', 'CE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59834-645', '2879', 'avenida ibirapuera', 'boa vista', 'sorocaba', 'SP', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62044-982', '5803', 'avenida dom pedro', 'funcionarios', 'cidade pi', 'PI', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51033-689', '7533', 'rua das flores', 'botafogo', 'cidade rn', 'RN', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25096-514', '6844', 'travessa das acasias', 'portao', 'samambaia', 'DF', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21551-547', '7539', 'avenida da saude', 'jardim paulista', 'santos', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('61873-991', '6561', 'rua liberdade', 'botafogo', 'vila velha', 'ES', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76910-748', '2755', 'avenida reboucas', 'lapa', 'caucaia', 'CE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94599-934', '5725', 'rua ana costa', 'santana', 'vila velha', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32740-716', '4194', 'avenida paulista', 'santa cruz', 'londrina', 'PR', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83889-878', '8096', 'rua ana costa', 'jardim paulista', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29786-550', '5296', 'rua liberdade', 'batel', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87518-157', '4962', 'travessa das acasias', 'barra da tijuca', 'juiz de fora', 'MG', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('14929-158', '7566', 'rua haddock lobo', 'vila nova', 'rondonopolis', 'MT', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70648-694', '1480', 'travessa das acasias', 'vila nova', 'varzea grande', 'MT', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('89299-587', '3085', 'rua liberdade', 'barra da tijuca', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21053-616', '1696', 'rua funchal', 'jardim america', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78690-635', '7173', 'avenida brigadeiro', 'jardim america', 'cidade to', 'TO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63578-893', '4635', 'rua pamplona', 'copacabana', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53213-196', '5483', 'avenida brasil', 'floresta', 'anapolis', 'GO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53694-183', '9875', 'rua oscar freire', 'tatuape', 'cidade ap', 'AP', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26901-709', '5083', 'rua pamplona', 'jardim botanico', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26750-786', '6172', 'avenida dom pedro', 'tatuape', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12389-471', '6938', 'rua das palmeiras', 'agua verde', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39693-240', '7968', 'avenida reboucas', 'vila mariana', 'sobral', 'CE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96760-444', '8318', 'rua quinze de novembro', 'tatuape', 'curitiba', 'PR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33703-951', '2528', 'rua pe mario', 'floresta', 'cidade pb', 'PB', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57749-792', '716', 'rua funchal', 'boa vista', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40671-646', '4669', 'avenida da saude', 'barra da tijuca', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98907-684', '3179', 'avenida berrini', 'moinhos de vento', 'feira de santana', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31241-936', '6257', 'rua haddock lobo', 'ahus', 'parintins', 'AM', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58655-667', '855', 'rua oscar freire', 'menino deus', 'caxias do sul', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68893-625', '2627', 'rua sao joao', 'tatuape', 'vitoria', 'ES', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('13495-524', '7392', 'avenida brigadeiro', 'vila nova', 'ponta grossa', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('20696-483', '3863', 'rua pamplona', 'funcionarios', 'volta redonda', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28035-139', '5494', 'rua quinze de novembro', 'ipanema', 'salvador', 'BA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('90654-105', '7686', 'avenida paulista', 'portao', 'juazeiro do norte', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24573-894', '2450', 'rua augusta', 'mooca', 'belo horizonte', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('65027-754', '783', 'rua quinze de novembro', 'tatuape', 'sobral', 'CE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92831-627', '8190', 'rua quinze de novembro', 'vila nova', 'cidade al', 'AL', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('10205-729', '4773', 'avenida paulista', 'portao', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78614-469', '3069', 'avenida ibirapuera', 'lourdes', 'cuiaba', 'MT', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58929-359', '714', 'avenida berrini', 'flamengo', 'belo horizonte', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96127-743', '5650', 'rua sao joao', 'copacabana', 'cidade rn', 'RN', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94252-279', '5773', 'avenida brasil', 'bela vista', 'cariacica', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18270-833', '2987', 'avenida berrini', 'portao', 'cidade se', 'SE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36144-142', '3303', 'rua haddock lobo', 'jardim america', 'cidade pb', 'PB', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('43202-137', '8898', 'rua pe mario', 'funcionarios', 'aparecida de goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45811-227', '784', 'rua pamplona', 'tatuape', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54438-291', '7205', 'rua pe mario', 'botafogo', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('65640-180', '4370', 'rua vergueiro', 'copacabana', 'cidade pa', 'PA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('20494-435', '5263', 'rua haddock lobo', 'pampulha', 'taguatinga', 'DF', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31842-806', '9874', 'rua funchal', 'tatuape', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45986-754', '5777', 'avenida brasil', 'barra da tijuca', 'parintins', 'AM', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77251-920', '6656', 'rua das palmeiras', 'vila nova', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('14561-229', '9955', 'avenida paulista', 'centro', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60181-680', '6002', 'travessa das acasias', 'ahus', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68188-881', '6078', 'rua funchal', 'batel', 'niteroi', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('95139-385', '6522', 'rua pamplona', 'funcionarios', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77861-496', '3049', 'rua botucatu', 'centro', 'salvador', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38124-726', '4265', 'rua ana costa', 'mooca', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69250-276', '2224', 'rua quinze de novembro', 'vila mariana', 'juazeiro do norte', 'CE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18511-663', '5237', 'rua das palmeiras', 'vila nova', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57381-620', '2581', 'rua haddock lobo', 'santana', 'cidade ap', 'AP', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('13445-469', '3879', 'avenida paulista', 'vila mariana', 'salvador', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18617-416', '2127', 'avenida dom pedro', 'barra da tijuca', 'cidade ap', 'AP', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63665-943', '8613', 'avenida berrini', 'boa vista', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('71057-796', '1216', 'avenida reboucas', 'bela vista', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26912-543', '9033', 'rua ana costa', 'bela vista', 'cidade ac', 'AC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('49862-268', '8489', 'rua quinze de novembro', 'petropolis', 'cidade ac', 'AC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78012-390', '3695', 'avenida atlantica', 'jardim botanico', 'blumenau', 'SC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26406-740', '9025', 'travessa das acasias', 'vila mariana', 'contagem', 'MG', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32439-774', '2763', 'travessa das acasias', 'funcionarios', 'fortaleza', 'CE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('20646-146', '675', 'rua liberdade', 'petropolis', 'cidade rr', 'RR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('91016-754', '9374', 'rua augusta', 'agua verde', 'cidade to', 'TO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94136-409', '8939', 'travessa das acasias', 'santana', 'sorocaba', 'SP', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69446-174', '6654', 'rua das palmeiras', 'moinhos de vento', 'cidade pa', 'PA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70875-308', '6810', 'rua funchal', 'jardim paulista', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62260-233', '5232', 'avenida reboucas', 'bela vista', 'anapolis', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41685-577', '1740', 'avenida dom pedro', 'funcionarios', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('16632-397', '2309', 'avenida brigadeiro', 'barra da tijuca', 'cariacica', 'ES', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85718-838', '2617', 'avenida brigadeiro', 'botafogo', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('75373-415', '8164', 'rua da consolacao', 'ahus', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41552-320', '8282', 'rua pe mario', 'vila nova', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88317-963', '4610', 'avenida brasil', 'jardim america', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66482-237', '134', 'avenida dom pedro', 'tatuape', 'cidade to', 'TO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62505-152', '5996', 'rua pe mario', 'ahus', 'petrolina', 'PE', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60639-616', '4729', 'avenida dom pedro', 'copacabana', 'cidade ro', 'RO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22672-503', '1947', 'avenida da saude', 'mooca', 'itacoatiara', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('88966-621', '2364', 'rua pamplona', 'pampulha', 'varzea grande', 'MT', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53652-923', '638', 'avenida brasil', 'jardim america', 'tres lagoas', 'MS', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52987-727', '8447', 'avenida da saude', 'bela vista', 'cidade pa', 'PA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76494-948', '4903', 'avenida da saude', 'flamengo', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12180-477', '4912', 'rua liberdade', 'portao', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92478-127', '9564', 'avenida ibirapuera', 'santa cruz', 'anapolis', 'GO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('16731-697', '9478', 'travessa das acasias', 'mooca', 'cidade rr', 'RR', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('99224-348', '6230', 'travessa das acasias', 'funcionarios', 'cidade pa', 'PA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64890-255', '7226', 'rua das flores', 'vila mariana', 'rio de janeiro', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28098-631', '7727', 'rua vergueiro', 'botafogo', 'taguatinga', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51124-277', '8610', 'avenida berrini', 'batel', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('89963-595', '5805', 'avenida dom pedro', 'ipanema', 'itacoatiara', 'AM', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('49008-889', '4891', 'avenida dom pedro', 'mooca', 'caxias do sul', 'RS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72888-457', '8012', 'avenida atlantica', 'portao', 'sobral', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('61712-938', '9396', 'rua quinze de novembro', 'tatuape', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55398-552', '4713', 'avenida brasil', 'tatuape', 'cuiaba', 'MT', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80592-377', '3506', 'avenida berrini', 'boa vista', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41779-151', '9615', 'rua quinze de novembro', 'bela vista', 'cidade ap', 'AP', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64172-438', '861', 'avenida brigadeiro', 'agua verde', 'cidade ma', 'MA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82135-261', '2253', 'rua das palmeiras', 'santa cruz', 'cidade pi', 'PI', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52096-392', '3268', 'travessa das acasias', 'savassi', 'samambaia', 'DF', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80143-856', '1466', 'rua ana costa', 'jardim botanico', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('14763-956', '6847', 'rua da consolacao', 'jardim botanico', 'cidade rn', 'RN', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11214-405', '4743', 'rua botucatu', 'jardim paulista', 'dourados', 'MS', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94058-656', '4663', 'avenida reboucas', 'jardim botanico', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45761-297', '8262', 'avenida paulista', 'santana', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('34405-114', '7519', 'rua da consolacao', 'ipanema', 'cidade al', 'AL', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33002-725', '9303', 'rua haddock lobo', 'moinhos de vento', 'cidade rn', 'RN', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21368-510', '8443', 'avenida ibirapuera', 'petropolis', 'cidade to', 'TO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42512-106', '7823', 'avenida paulista', 'jardim paulista', 'cidade ma', 'MA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('49576-696', '4375', 'rua funchal', 'lapa', 'olinda', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18142-783', '5891', 'travessa das acasias', 'mooca', 'cidade rn', 'RN', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25389-754', '6643', 'rua da consolacao', 'tatuape', 'serra', 'ES', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72676-256', '3591', 'avenida brigadeiro', 'floresta', 'caucaia', 'CE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80453-921', '6814', 'rua pamplona', 'floresta', 'itacoatiara', 'AM', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78879-557', '9762', 'avenida brigadeiro', 'ahus', 'cidade ma', 'MA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81781-617', '1839', 'rua liberdade', 'vila nova', 'cidade ac', 'AC', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25235-796', '8526', 'avenida reboucas', 'jardim paulista', 'caxias do sul', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69432-235', '7299', 'rua vergueiro', 'vila nova', 'santa maria', 'RS', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98181-926', '946', 'rua liberdade', 'barra da tijuca', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85800-174', '50', 'rua oscar freire', 'flamengo', 'fortaleza', 'CE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19046-583', '1045', 'avenida atlantica', 'copacabana', 'volta redonda', 'RJ', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59081-491', '2219', 'rua da consolacao', 'botafogo', 'petropolis', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('95660-980', '8836', 'rua sao joao', 'flamengo', 'parintins', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39188-954', '6440', 'avenida dom pedro', 'jardim paulista', 'cuiaba', 'MT', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79721-488', '8921', 'rua funchal', 'tatuape', 'sao paulo', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46129-293', '5672', 'rua funchal', 'lapa', 'cidade se', 'SE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41544-311', '6869', 'rua das palmeiras', 'jardim america', 'cidade rn', 'RN', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42077-858', '7315', 'avenida brasil', 'floresta', 'belo horizonte', 'MG', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17398-243', '8844', 'avenida brigadeiro', 'barra da tijuca', 'volta redonda', 'RJ', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85690-712', '9439', 'rua botucatu', 'lapa', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64206-407', '2348', 'rua haddock lobo', 'lapa', 'cidade pb', 'PB', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82856-607', '2870', 'rua liberdade', 'pampulha', 'recife', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64568-518', '6245', 'rua das palmeiras', 'agua verde', 'petropolis', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41584-969', '8814', 'rua da consolacao', 'flamengo', 'maringa', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('17552-675', '2366', 'avenida atlantica', 'menino deus', 'feira de santana', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41831-361', '2197', 'rua vergueiro', 'pampulha', 'samambaia', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22119-648', '7370', 'rua sao joao', 'agua verde', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19539-292', '6180', 'rua oscar freire', 'jardim america', 'cidade rn', 'RN', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12009-316', '5456', 'rua augusta', 'savassi', 'cidade al', 'AL', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('89220-820', '7847', 'rua ana costa', 'boa vista', 'porto alegre', 'RS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('47101-489', '9046', 'avenida brigadeiro', 'jardim botanico', 'santa maria', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57139-625', '5054', 'rua pamplona', 'agua verde', 'itacoatiara', 'AM', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36624-479', '7693', 'rua botucatu', 'santa cruz', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12125-367', '3626', 'rua liberdade', 'jardim america', 'aparecida de goiania', 'GO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40149-488', '3215', 'avenida paulista', 'tatuape', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('74044-840', '5531', 'avenida dom pedro', 'savassi', 'cidade ro', 'RO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28344-837', '5771', 'rua da consolacao', 'barra da tijuca', 'cidade to', 'TO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19742-937', '963', 'avenida dom pedro', 'jardim paulista', 'cidade ap', 'AP', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92667-336', '6757', 'rua das flores', 'ahus', 'cidade ma', 'MA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58916-161', '8286', 'rua augusta', 'centro', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79758-664', '258', 'avenida berrini', 'batel', 'cidade rr', 'RR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12246-614', '4502', 'rua vergueiro', 'centro', 'brasilia', 'DF', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('78732-252', '1754', 'rua da consolacao', 'moinhos de vento', 'cidade se', 'SE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45038-914', '4136', 'rua vergueiro', 'floresta', 'salvador', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39603-407', '7521', 'rua pe mario', 'copacabana', 'campo grande', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63120-488', '520', 'travessa das acasias', 'agua verde', 'cidade ma', 'MA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('20837-611', '155', 'avenida brasil', 'savassi', 'tres lagoas', 'MS', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40115-316', '8654', 'rua quinze de novembro', 'lourdes', 'ceilandia', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81176-677', '1219', 'avenida brasil', 'mooca', 'cidade pi', 'PI', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86943-247', '257', 'avenida reboucas', 'jardim paulista', 'cidade ma', 'MA', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83919-346', '4904', 'rua sao joao', 'jardim botanico', 'cidade pb', 'PB', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28343-909', '5436', 'avenida dom pedro', 'batel', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22803-547', '5667', 'rua botucatu', 'funcionarios', 'cidade pi', 'PI', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52778-130', '9759', 'avenida da saude', 'ipanema', 'salvador', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56636-666', '8039', 'rua funchal', 'moinhos de vento', 'cidade to', 'TO', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21232-890', '9599', 'rua das palmeiras', 'jardim paulista', 'dourados', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45123-257', '1205', 'avenida brigadeiro', 'moinhos de vento', 'cidade rr', 'RR', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51507-469', '2528', 'travessa das acasias', 'moinhos de vento', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45358-204', '7287', 'rua haddock lobo', 'centro', 'vitoria', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23538-126', '7354', 'avenida ibirapuera', 'jardim paulista', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60493-112', '9781', 'rua sao joao', 'pampulha', 'contagem', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84967-633', '1388', 'rua ana costa', 'flamengo', 'juazeiro do norte', 'CE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45180-604', '4406', 'avenida paulista', 'jardim paulista', 'chapeco', 'SC', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('49289-595', '4522', 'avenida ibirapuera', 'jardim paulista', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87831-731', '4041', 'rua oscar freire', 'copacabana', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('61864-440', '4992', 'avenida paulista', 'santa cruz', 'santa maria', 'RS', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66441-935', '7213', 'avenida reboucas', 'moinhos de vento', 'cidade se', 'SE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72784-421', '9884', 'avenida reboucas', 'tatuape', 'cidade se', 'SE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52714-485', '8045', 'rua haddock lobo', 'ipanema', 'chapeco', 'SC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87624-658', '9239', 'rua quinze de novembro', 'copacabana', 'olinda', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('48185-951', '3435', 'rua funchal', 'boa vista', 'florianopolis', 'SC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('93012-410', '8181', 'avenida ibirapuera', 'petropolis', 'cidade pi', 'PI', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('19694-559', '6933', 'avenida paulista', 'batel', 'feira de santana', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81256-137', '8756', 'rua pe mario', 'lourdes', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24335-887', '9730', 'avenida dom pedro', 'portao', 'cidade al', 'AL', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83822-760', '2726', 'rua pamplona', 'batel', 'vitoria da conquista', 'BA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11382-200', '7053', 'avenida reboucas', 'ahus', 'cidade ma', 'MA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('68429-483', '8500', 'rua botucatu', 'funcionarios', 'caruaru', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55215-125', '9644', 'rua das palmeiras', 'ahus', 'dourados', 'MS', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28569-456', '1407', 'avenida ibirapuera', 'tatuape', 'cidade pa', 'PA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55652-587', '8538', 'rua augusta', 'barra da tijuca', 'caucaia', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18804-407', '7413', 'avenida atlantica', 'boa vista', 'serra', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41970-628', '1792', 'avenida reboucas', 'centro', 'rio de janeiro', 'RJ', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40389-916', '6986', 'avenida dom pedro', 'ipanema', 'joinville', 'SC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('13826-855', '7081', 'rua da consolacao', 'jardim paulista', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('10583-821', '7038', 'rua liberdade', 'barra da tijuca', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80371-291', '1026', 'rua ana costa', 'mooca', 'caxias do sul', 'RS', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97910-983', '1868', 'rua funchal', 'vila mariana', 'varzea grande', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55603-460', '6432', 'rua pe mario', 'floresta', 'cidade pa', 'PA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98094-237', '4874', 'rua das palmeiras', 'jardim paulista', 'itacoatiara', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58929-810', '1917', 'rua haddock lobo', 'lapa', 'goiania', 'GO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('65448-290', '2259', 'avenida da saude', 'botafogo', 'ponta grossa', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28388-291', '8023', 'rua da consolacao', 'pampulha', 'cidade pa', 'PA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('73518-239', '5883', 'avenida brasil', 'floresta', 'aparecida de goiania', 'GO', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('99744-603', '8110', 'rua vergueiro', 'pampulha', 'santa maria', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38905-399', '1355', 'rua da consolacao', 'savassi', 'samambaia', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69942-679', '4730', 'avenida dom pedro', 'lapa', 'petropolis', 'RJ', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45112-893', '1855', 'rua vergueiro', 'pampulha', 'cidade rn', 'RN', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81611-323', '682', 'rua ana costa', 'pampulha', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('14224-560', '4056', 'travessa das acasias', 'boa vista', 'brasilia', 'DF', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41056-314', '7194', 'rua sao joao', 'menino deus', 'petrolina', 'PE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31755-730', '9999', 'avenida atlantica', 'menino deus', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79767-387', '973', 'rua augusta', 'petropolis', 'londrina', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('85069-373', '4795', 'avenida atlantica', 'ipanema', 'cidade rr', 'RR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46349-987', '6744', 'rua ana costa', 'bela vista', 'cidade ac', 'AC', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52217-948', '4091', 'avenida paulista', 'portao', 'cidade to', 'TO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92288-524', '2330', 'avenida berrini', 'flamengo', 'vitoria da conquista', 'BA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77582-867', '1526', 'travessa das acasias', 'vila nova', 'dourados', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22208-848', '5363', 'avenida berrini', 'barra da tijuca', 'petrolina', 'PE', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('80048-507', '5870', 'avenida atlantica', 'batel', 'itacoatiara', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52318-948', '8106', 'rua augusta', 'petropolis', 'santa maria', 'RS', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55054-798', '2140', 'rua liberdade', 'pampulha', 'caucaia', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26284-978', '7530', 'rua quinze de novembro', 'jardim america', 'cidade pb', 'PB', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('27290-765', '7010', 'rua das flores', 'barra da tijuca', 'chapeco', 'SC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42819-184', '1530', 'rua oscar freire', 'menino deus', 'sobral', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('61949-740', '2712', 'travessa das acasias', 'santana', 'rondonopolis', 'MT', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('10142-318', '1495', 'travessa das acasias', 'botafogo', 'sobral', 'CE', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11217-108', '3706', 'rua liberdade', 'bela vista', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72613-172', '6920', 'rua quinze de novembro', 'petropolis', 'cidade pi', 'PI', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51071-476', '1679', 'rua botucatu', 'vila nova', 'feira de santana', 'BA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18966-643', '2182', 'rua ana costa', 'flamengo', 'sobral', 'CE', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56030-839', '2689', 'travessa das acasias', 'floresta', 'cidade ro', 'RO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21362-202', '7249', 'avenida ibirapuera', 'jardim botanico', 'caxias do sul', 'RS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66280-422', '6292', 'rua botucatu', 'lourdes', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82534-715', '1381', 'rua oscar freire', 'lapa', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36928-630', '440', 'avenida atlantica', 'ahus', 'cidade rr', 'RR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41370-606', '4843', 'rua pe mario', 'boa vista', 'cidade rr', 'RR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('79243-112', '9731', 'avenida berrini', 'lapa', 'campo grande', 'MS', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57895-659', '9313', 'rua pe mario', 'bela vista', 'varzea grande', 'MT', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86986-169', '1196', 'avenida berrini', 'ahus', 'cidade ma', 'MA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76402-393', '991', 'avenida brasil', 'vila mariana', 'santos', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('93956-649', '6591', 'avenida atlantica', 'botafogo', 'cidade to', 'TO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77017-308', '5078', 'rua sao joao', 'mooca', 'cidade ap', 'AP', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('50654-815', '6402', 'avenida reboucas', 'pampulha', 'cidade al', 'AL', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25202-564', '1413', 'avenida brigadeiro', 'jardim america', 'taguatinga', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11660-824', '2878', 'rua das palmeiras', 'tatuape', 'cidade rr', 'RR', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31884-480', '5681', 'avenida berrini', 'jardim paulista', 'curitiba', 'PR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66272-378', '481', 'rua quinze de novembro', 'boa vista', 'maringa', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('75031-566', '9448', 'avenida atlantica', 'mooca', 'cidade ac', 'AC', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58193-261', '9288', 'avenida berrini', 'jardim america', 'cidade ac', 'AC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76692-102', '1890', 'rua liberdade', 'santana', 'recife', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60197-253', '7730', 'avenida brasil', 'lapa', 'rio de janeiro', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52179-354', '6871', 'avenida atlantica', 'pampulha', 'florianopolis', 'SC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25650-614', '9365', 'rua sao joao', 'mooca', 'ceilandia', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62550-170', '8451', 'avenida brigadeiro', 'jardim paulista', 'cidade ma', 'MA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82494-567', '5363', 'rua haddock lobo', 'ahus', 'parintins', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('91620-348', '9238', 'rua haddock lobo', 'vila mariana', 'santos', 'SP', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29735-106', '3202', 'avenida berrini', 'lourdes', 'parintins', 'AM', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53911-101', '5676', 'avenida dom pedro', 'lapa', 'brasilia', 'DF', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36895-642', '5039', 'rua botucatu', 'menino deus', 'cidade pb', 'PB', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22193-144', '2333', 'avenida brasil', 'savassi', 'feira de santana', 'BA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21128-694', '6103', 'avenida atlantica', 'botafogo', 'vitoria da conquista', 'BA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('67014-778', '1227', 'rua pe mario', 'agua verde', 'vila velha', 'ES', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52762-425', '5162', 'rua oscar freire', 'tatuape', 'londrina', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86638-211', '3322', 'rua sao joao', 'lapa', 'parintins', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63282-223', '7636', 'rua funchal', 'jardim paulista', 'curitiba', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('70731-371', '7405', 'rua augusta', 'ahus', 'cidade ap', 'AP', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38183-955', '4985', 'rua das palmeiras', 'jardim paulista', 'vitoria', 'ES', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('61936-625', '4067', 'avenida atlantica', 'vila nova', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('69270-669', '510', 'rua da consolacao', 'mooca', 'petropolis', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25919-112', '1670', 'rua funchal', 'santa cruz', 'cidade rn', 'RN', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('99952-745', '6564', 'rua augusta', 'bela vista', 'niteroi', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12857-166', '4241', 'rua liberdade', 'lourdes', 'cidade to', 'TO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('26059-143', '1507', 'avenida paulista', 'moinhos de vento', 'santa maria', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('75028-130', '7097', 'rua liberdade', 'jardim paulista', 'manaus', 'AM', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('34530-381', '5800', 'rua da consolacao', 'botafogo', 'tres lagoas', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94840-402', '568', 'avenida paulista', 'santana', 'olinda', 'PE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21497-386', '7849', 'avenida dom pedro', 'santana', 'cidade pa', 'PA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92674-921', '8615', 'rua augusta', 'botafogo', 'campo grande', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81371-900', '5884', 'avenida atlantica', 'flamengo', 'cidade ap', 'AP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60905-376', '8232', 'rua liberdade', 'jardim botanico', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('46822-159', '3589', 'avenida da saude', 'ipanema', 'florianopolis', 'SC', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('30922-202', '9569', 'rua pamplona', 'funcionarios', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('38758-689', '8744', 'rua oscar freire', 'lapa', 'vitoria da conquista', 'BA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('87662-425', '2886', 'rua da consolacao', 'copacabana', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84403-677', '463', 'rua liberdade', 'jardim botanico', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('33010-602', '8883', 'avenida berrini', 'petropolis', 'londrina', 'PR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12612-639', '9858', 'avenida brigadeiro', 'jardim america', 'rio de janeiro', 'RJ', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54663-834', '3301', 'avenida da saude', 'ipanema', 'cidade pa', 'PA', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24538-966', '2421', 'rua das flores', 'jardim america', 'blumenau', 'SC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54113-409', '6482', 'rua pamplona', 'vila nova', 'cidade ac', 'AC', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('95089-424', '7158', 'rua botucatu', 'jardim paulista', 'goiania', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59595-414', '9650', 'rua das palmeiras', 'lapa', 'blumenau', 'SC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('84381-133', '30', 'rua da consolacao', 'bela vista', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('75035-244', '3620', 'avenida da saude', 'jardim botanico', 'blumenau', 'SC', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32005-751', '5683', 'avenida brigadeiro', 'vila nova', 'anapolis', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42707-809', '4346', 'rua das flores', 'barra da tijuca', 'contagem', 'MG', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60585-548', '21', 'rua quinze de novembro', 'mooca', 'contagem', 'MG', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56036-659', '8079', 'avenida ibirapuera', 'jardim paulista', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31319-562', '9471', 'avenida berrini', 'petropolis', 'campo grande', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23726-175', '5222', 'rua das flores', 'tatuape', 'belo horizonte', 'MG', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('81702-195', '2637', 'rua pe mario', 'santana', 'goiania', 'GO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('95673-268', '508', 'avenida berrini', 'floresta', 'anapolis', 'GO', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36941-294', '1660', 'avenida brasil', 'jardim paulista', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('22571-150', '4873', 'rua haddock lobo', 'batel', 'ceilandia', 'DF', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('57294-103', '2517', 'avenida berrini', 'pampulha', 'tres lagoas', 'MS', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36171-199', '9834', 'rua das palmeiras', 'tatuape', 'brasilia', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72071-964', '4782', 'travessa das acasias', 'jardim paulista', 'campinas', 'SP', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96643-371', '7716', 'rua pe mario', 'moinhos de vento', 'cariacica', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('34455-556', '6250', 'rua pamplona', 'jardim paulista', 'juiz de fora', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('45200-677', '4316', 'rua funchal', 'barra da tijuca', 'petropolis', 'RJ', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('97574-452', '1585', 'avenida atlantica', 'ahus', 'niteroi', 'RJ', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('60738-938', '3728', 'rua liberdade', 'ahus', 'cidade al', 'AL', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72424-406', '7780', 'rua das palmeiras', 'pampulha', 'cidade ac', 'AC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25765-875', '569', 'avenida atlantica', 'santana', 'juiz de fora', 'MG', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('15593-533', '3158', 'rua augusta', 'jardim paulista', 'manaus', 'AM', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('51910-844', '2423', 'travessa das acasias', 'vila mariana', 'juiz de fora', 'MG', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('82358-433', '9116', 'rua pe mario', 'vila nova', 'cidade al', 'AL', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('24748-524', '9627', 'rua das flores', 'jardim botanico', 'olinda', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23845-676', '9547', 'rua liberdade', 'lourdes', 'londrina', 'PR', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63856-370', '8776', 'rua haddock lobo', 'moinhos de vento', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('14910-276', '9978', 'rua liberdade', 'savassi', 'tres lagoas', 'MS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('15083-505', '9973', 'avenida da saude', 'bela vista', 'olinda', 'PE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58816-120', '7786', 'avenida brasil', 'lapa', 'anapolis', 'GO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39878-237', '8055', 'rua oscar freire', 'tatuape', 'aparecida de goiania', 'GO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('89295-761', '4415', 'avenida reboucas', 'ahus', 'juazeiro do norte', 'CE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('77698-988', '6672', 'rua augusta', 'barra da tijuca', 'uberlandia', 'MG', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76426-513', '1076', 'rua da consolacao', 'funcionarios', 'cuiaba', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('42701-133', '3289', 'rua augusta', 'jardim paulista', 'curitiba', 'PR', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('58280-943', '3263', 'rua pamplona', 'jardim botanico', 'manaus', 'AM', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('41711-481', '2030', 'travessa das acasias', 'flamengo', 'itacoatiara', 'AM', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('55121-267', '9616', 'avenida berrini', 'jardim paulista', 'cidade pa', 'PA', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('13597-495', '1481', 'avenida atlantica', 'boa vista', 'cidade se', 'SE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94853-330', '3512', 'rua liberdade', 'menino deus', 'niteroi', 'RJ', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('99417-109', '6710', 'travessa das acasias', 'mooca', 'cidade ma', 'MA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39329-358', '9850', 'rua da consolacao', 'agua verde', 'cidade pa', 'PA', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('59345-972', '4512', 'avenida atlantica', 'portao', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('98761-633', '7647', 'rua augusta', 'mooca', 'varzea grande', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83591-762', '121', 'rua quinze de novembro', 'lourdes', 'cidade se', 'SE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('18367-444', '1772', 'rua das palmeiras', 'tatuape', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('34688-253', '4279', 'rua oscar freire', 'menino deus', 'petrolina', 'PE', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('96577-427', '9831', 'avenida brasil', 'santana', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('44003-528', '8149', 'rua das flores', 'boa vista', 'cidade ma', 'MA', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54979-843', '9553', 'avenida brasil', 'boa vista', 'dourados', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76494-407', '7795', 'avenida dom pedro', 'batel', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('43902-842', '7714', 'rua quinze de novembro', 'tatuape', 'joinville', 'SC', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56567-328', '1464', 'avenida reboucas', 'batel', 'cidade al', 'AL', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('86751-401', '6090', 'avenida reboucas', 'botafogo', 'cidade rn', 'RN', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('71894-299', '9562', 'avenida brasil', 'savassi', 'manaus', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('64146-155', '6254', 'rua das palmeiras', 'menino deus', 'cidade ac', 'AC', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('28772-423', '6705', 'avenida reboucas', 'vila mariana', 'londrina', 'PR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('92710-281', '7989', 'rua sao joao', 'ahus', 'cidade pi', 'PI', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('37444-879', '7407', 'rua das flores', 'jardim america', 'anapolis', 'GO', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('21539-232', '2596', 'rua ana costa', 'lourdes', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72573-492', '6610', 'avenida ibirapuera', 'agua verde', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('52233-875', '6113', 'rua augusta', 'pampulha', 'sao paulo', 'SP', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('39657-810', '68', 'rua das palmeiras', 'centro', 'cidade se', 'SE', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31891-166', '6285', 'rua quinze de novembro', 'bela vista', 'varzea grande', 'MT', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66841-803', '7470', 'rua haddock lobo', 'tatuape', 'cidade se', 'SE', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('31611-931', '5886', 'avenida berrini', 'santana', 'maringa', 'PR', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('12872-703', '2150', 'avenida brigadeiro', 'lapa', 'campo grande', 'MS', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('93928-361', '613', 'rua pamplona', 'santa cruz', 'cidade ac', 'AC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('16322-806', '1772', 'avenida brasil', 'floresta', 'cidade pb', 'PB', 'apto 101');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72180-818', '2025', 'rua pe mario', 'barra da tijuca', 'serra', 'ES', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('65164-777', '153', 'rua das palmeiras', 'portao', 'londrina', 'PR', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23751-623', '2248', 'avenida da saude', 'floresta', 'cariacica', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('36037-723', '1742', 'rua quinze de novembro', 'tatuape', 'cidade rn', 'RN', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('63707-402', '3305', 'rua vergueiro', 'petropolis', 'pelotas', 'RS', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53332-340', '3403', 'avenida berrini', 'pampulha', 'florianopolis', 'SC', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('29548-192', '1810', 'rua sao joao', 'batel', 'sao paulo', 'SP', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('94454-336', '1660', 'rua botucatu', 'boa vista', 'cidade pb', 'PB', 'sala 3');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('32898-995', '821', 'rua funchal', 'mooca', 'parintins', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('25191-197', '5124', 'rua das palmeiras', 'copacabana', 'petropolis', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('56861-548', '2794', 'avenida paulista', 'centro', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('54921-287', '1523', 'rua botucatu', 'santana', 'cidade rr', 'RR', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('72684-919', '4454', 'rua funchal', 'flamengo', 'serra', 'ES', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('23593-526', '961', 'avenida paulista', 'santa cruz', 'taguatinga', 'DF', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('90127-488', '7179', 'rua liberdade', 'moinhos de vento', 'cidade ro', 'RO', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('73979-215', '2141', 'rua das flores', 'floresta', 'cidade pb', 'PB', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('11620-821', '4287', 'rua sao joao', 'jardim america', 'samambaia', 'DF', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('66734-777', '8505', 'avenida reboucas', 'batel', 'cidade ma', 'MA', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('83183-727', '6306', 'rua pamplona', 'savassi', 'cidade rn', 'RN', 'casa');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('74990-990', '8284', 'rua da consolacao', 'agua verde', 'rio de janeiro', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('53371-384', '5254', 'avenida berrini', 'ahus', 'florianopolis', 'SC', 'bloco a apto 5');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('40801-180', '6204', 'travessa das acasias', 'pampulha', 'niteroi', 'RJ', NULL);
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('75333-557', '7342', 'rua liberdade', 'moinhos de vento', 'parintins', 'AM', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('62879-522', '292', 'rua botucatu', 'savassi', 'goiania', 'GO', 'apto 202');
INSERT INTO endereco (cep, numero, rua, bairro, cidade, estado, complemento) VALUES ('76628-675', '9900', 'rua sao joao', 'petropolis', 'rio de janeiro', 'RJ', 'sala 3');

INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37550375800', 'alan borges', '61711305548', 'alan.borges673@email.com', '1983-06-01', 'ativo', 1);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('10272614932', 'patricia martins', '71373516091', 'patricia.martins124@email.com', '1994-08-20', 'ativo', 2);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79827080805', 'luciana vieira', '81829221699', 'luciana.vieira600@email.com', '1999-08-06', 'ativo', 3);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66934654717', 'isabela carvalho', '91485833394', 'isabela.carvalho423@email.com', '1990-10-19', 'ativo', 4);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('22885158724', 'alessandra azevedo', '91460810620', 'alessandra.azevedo766@email.com', '1990-01-24', 'ativo', 5);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42442043853', 'lucas teixeira', '81198386384', 'lucas.teixeira834@email.com', '1991-01-31', 'ativo', 6);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66658004316', 'caio vieira', '61989334721', 'caio.vieira231@email.com', '1968-05-21', 'inativo', 7);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('81606484217', 'thiago andrade', '51057202590', 'thiago.andrade867@email.com', '1994-09-14', 'inativo', 8);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94798515800', 'marcelo reis', '91182688615', 'marcelo.reis189@email.com', '1969-12-03', 'ativo', 9);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('55543987821', 'joao costa', '61739930561', 'joao.costa685@email.com', '1977-04-23', 'ativo', 10);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('40858877002', 'mariana fonseca', '41581128801', 'mariana.fonseca668@email.com', '1969-06-15', 'ativo', 11);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36138612085', 'murilo borges', '11110248193', 'murilo.borges340@email.com', '2000-11-11', 'ativo', 12);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('67665061801', 'ana xavier', '21901581449', 'ana.xavier738@email.com', '1963-11-18', 'ativo', 13);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76607283263', 'diego dantas', '91424508821', 'diego.dantas817@email.com', '1961-11-15', 'ativo', 14);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('96881435370', 'marco fonseca', '91222394312', 'marco.fonseca662@email.com', '1990-02-05', 'ativo', 15);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08781414134', 'patricia ramos', '81552314913', 'patricia.ramos595@email.com', '1974-04-03', 'ativo', 16);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('59492995580', 'renan nascimento', '61336452577', 'renan.nascimento5@email.com', '1979-12-23', 'ativo', 17);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47812914227', 'otavio martins', '21108099693', 'otavio.martins270@email.com', '2000-08-26', 'ativo', 18);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('48872563963', 'mariana carvalho', '91816580392', 'mariana.carvalho476@email.com', '1993-12-19', 'ativo', 19);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72299275010', 'marcelo rezende', '41145303856', 'marcelo.rezende500@email.com', '1981-01-25', 'inativo', 20);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('00518449828', 'vinicius dias', '71591846386', 'vinicius.dias670@email.com', '1975-10-30', 'ativo', 21);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('57790827236', 'aline lima', '51322259136', 'aline.lima527@email.com', '1996-05-21', 'ativo', 22);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17773926086', 'simone oliveira', '31280920242', 'simone.oliveira131@email.com', '1983-03-05', 'inativo', 23);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('99041379782', 'viviane nascimento', '71929298425', 'viviane.nascimento225@email.com', '2001-05-16', 'ativo', 24);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91366210308', 'willian leite', '91629127990', 'willian.leite932@email.com', '1999-05-17', 'ativo', 25);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('81172980664', 'willian cavalcanti', '11863765991', 'willian.cavalcanti380@email.com', '1979-02-01', 'ativo', 26);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('73149864367', 'ana borges', '11981806356', 'ana.borges762@email.com', '1976-04-01', 'ativo', 27);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69448695949', 'priscila azevedo', '41688725887', 'priscila.azevedo407@email.com', '1971-05-20', 'inativo', 28);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95621372102', 'renata batista', '61890260127', 'renata.batista411@email.com', '2001-07-13', 'ativo', 29);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('11435190607', 'juliana vasconcelos', '91490277038', 'juliana.vasconcelos672@email.com', '1972-10-29', 'ativo', 30);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98839205391', 'ana queiroz', '21465669380', 'ana.queiroz162@email.com', '1993-01-20', 'ativo', 31);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18489554302', 'leandro cardoso', '71904268181', 'leandro.cardoso953@email.com', '1982-07-27', 'ativo', 32);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18489476901', 'viviane pinto', '61779071416', 'viviane.pinto250@email.com', '1988-06-03', 'ativo', 33);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('33565880442', 'simone rocha', '71518275539', 'simone.rocha96@email.com', '1972-01-26', 'ativo', 34);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37333433365', 'simone vieira', '61211179080', 'simone.vieira634@email.com', '1998-01-14', 'ativo', 35);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95794728400', 'diego melo', '31086780856', 'diego.melo769@email.com', '1998-08-05', 'ativo', 36);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27187500300', 'leonardo andrade', '61594284347', 'leonardo.andrade104@email.com', '2002-12-30', 'ativo', 37);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52763655634', 'priscila moreira', '31931438663', 'priscila.moreira185@email.com', '1966-07-17', 'ativo', 38);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27026728842', 'sergio dantas', '51489061203', 'sergio.dantas499@email.com', '1996-07-03', 'ativo', 39);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17545588447', 'fabio santos', '21593998245', 'fabio.santos422@email.com', '1974-08-01', 'ativo', 40);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('77169472223', 'cristiane cavalcanti', '71112535544', 'cristiane.cavalcanti647@email.com', '1987-02-26', 'ativo', 41);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47598762272', 'maria carvalho', '41413261117', 'maria.carvalho746@email.com', '1984-08-07', 'ativo', 42);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('68114921638', 'ligia melo', '51722820055', 'ligia.melo254@email.com', '1998-10-07', 'ativo', 43);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('84872829979', 'murilo leal', '71884578317', 'murilo.leal767@email.com', '1973-10-23', 'ativo', 44);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42400825440', 'alan lacerda', '81740649308', 'alan.lacerda9@email.com', '1976-10-04', 'ativo', 45);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('86632663400', 'rafael nunes', '41894484631', 'rafael.nunes641@email.com', '1968-03-07', 'ativo', 46);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17974973596', 'maria almeida', '91021442703', 'maria.almeida51@email.com', '1964-01-17', 'ativo', 47);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('73564757077', 'roberto ferreira', '31046187234', 'roberto.ferreira864@email.com', '1996-08-28', 'ativo', 48);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01367303707', 'felipe bezerra', '41764520881', 'felipe.bezerra682@email.com', '1971-05-13', 'ativo', 49);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('43503136563', 'joao nascimento', '51916300979', 'joao.nascimento814@email.com', '1966-12-14', 'ativo', 50);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13271950039', 'claudia xavier', '91127358573', 'claudia.xavier158@email.com', '1960-12-15', 'ativo', 51);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52407784856', 'ruan martins', '31855749821', 'ruan.martins581@email.com', '1983-10-29', 'ativo', 52);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44857086244', 'maria vasconcelos', '61935186387', 'maria.vasconcelos878@email.com', '1994-05-07', 'ativo', 53);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94565118129', 'julia vieira', '31203173109', 'julia.vieira961@email.com', '1988-10-14', 'ativo', 54);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('78994053943', 'larissa silva', '41717058650', 'larissa.silva953@email.com', '1996-12-11', 'ativo', 55);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80141381127', 'aline lacerda', '41383928861', 'aline.lacerda395@email.com', '1994-05-16', 'ativo', 56);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('57612286889', 'cristiane brito', '91975585566', 'cristiane.brito162@email.com', '1997-01-21', 'ativo', 57);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('93983684555', 'eliane moreira', '71004908240', 'eliane.moreira983@email.com', '1973-06-21', 'inativo', 58);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35048889976', 'natalia pereira', '81522459334', 'natalia.pereira39@email.com', '1996-05-19', 'ativo', 59);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('96931572738', 'felipe machado', '51096105566', 'felipe.machado658@email.com', '2001-09-23', 'ativo', 60);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('39060480557', 'erica figueiredo', '61832067998', 'erica.figueiredo154@email.com', '1964-01-15', 'ativo', 61);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('46225179069', 'juliana ribeiro', '71862278376', 'juliana.ribeiro88@email.com', '1989-04-04', 'ativo', 62);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89833146569', 'camila costa', '71655355904', 'camila.costa688@email.com', '1967-08-05', 'inativo', 63);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97927033578', 'natalia rezende', '21103924051', 'natalia.rezende746@email.com', '1973-09-08', 'ativo', 64);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05383388497', 'viviane vasconcelos', '31069804204', 'viviane.vasconcelos748@email.com', '1969-01-01', 'ativo', 65);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94070164558', 'leticia santos', '71368157981', 'leticia.santos300@email.com', '1968-05-12', 'ativo', 66);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('78003845786', 'diego moraes', '11555438404', 'diego.moraes161@email.com', '1999-06-01', 'ativo', 67);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08432562142', 'leonardo bezerra', '41639264957', 'leonardo.bezerra984@email.com', '1984-04-27', 'ativo', 68);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29832482677', 'henrique xavier', '31518812520', 'henrique.xavier956@email.com', '1994-05-02', 'ativo', 69);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66474231257', 'carolina santos', '51999393305', 'carolina.santos781@email.com', '1963-07-26', 'ativo', 70);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72897526786', 'alan carvalho', '41306046333', 'alan.carvalho168@email.com', '1962-12-19', 'ativo', 71);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79757366006', 'leonardo ramos', '71999880817', 'leonardo.ramos321@email.com', '1980-06-29', 'ativo', 72);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('03886086847', 'gabriel martins', '81644726490', 'gabriel.martins299@email.com', '1990-12-13', 'ativo', 73);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27718129834', 'isabela campos', '61702793714', 'isabela.campos424@email.com', '1974-07-15', 'ativo', 74);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21117518632', 'katia vasconcelos', '31686025922', 'katia.vasconcelos973@email.com', '1998-12-21', 'ativo', 75);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06447421274', 'patricia silva', '51077780973', 'patricia.silva638@email.com', '1969-09-23', 'ativo', 76);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('77671990371', 'priscila vasconcelos', '91302205020', 'priscila.vasconcelos644@email.com', '1989-12-02', 'ativo', 77);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94510162285', 'daniel vasconcelos', '91279501455', 'daniel.vasconcelos677@email.com', '2000-04-05', 'ativo', 78);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('16814721478', 'roberto bezerra', '91339019817', 'roberto.bezerra424@email.com', '1992-06-24', 'ativo', 79);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('46954899537', 'gustavo vasconcelos', '81877293430', 'gustavo.vasconcelos577@email.com', '1965-04-20', 'ativo', 80);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13966055843', 'renata silva', '41441448850', 'renata.silva656@email.com', '1965-02-08', 'ativo', 81);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('56990235500', 'viviane marques', '11272785760', 'viviane.marques486@email.com', '1997-06-17', 'ativo', 82);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95880395507', 'matheus queiroz', '51056829962', 'matheus.queiroz153@email.com', '1986-09-12', 'ativo', 83);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('45046173580', 'eliane vieira', '51384215031', 'eliane.vieira974@email.com', '1979-11-27', 'ativo', 84);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('78235784504', 'henrique pinto', '21823076810', 'henrique.pinto893@email.com', '1973-12-13', 'inativo', 85);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91570184057', 'ligia leal', '41533448571', 'ligia.leal914@email.com', '1972-03-25', 'ativo', 86);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41098813820', 'fabio pinheiro', '51249321495', 'fabio.pinheiro327@email.com', '1984-03-31', 'ativo', 87);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('20701601656', 'diego rodrigues', '81954538179', 'diego.rodrigues722@email.com', '1965-11-29', 'ativo', 88);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71747733207', 'vanessa marques', '71255770171', 'vanessa.marques373@email.com', '1975-10-07', 'ativo', 89);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24599281657', 'leticia monteiro', '21487696393', 'leticia.monteiro570@email.com', '1984-07-30', 'ativo', 90);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76153966974', 'cristiane lacerda', '41219719975', 'cristiane.lacerda711@email.com', '1984-11-24', 'ativo', 91);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72461919689', 'tatiana medeiros', '11132902278', 'tatiana.medeiros661@email.com', '1973-01-27', 'ativo', 92);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97335494606', 'fabio ferreira', '11986240580', 'fabio.ferreira597@email.com', '1960-01-14', 'ativo', 93);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('51403696561', 'leonardo campos', '71832723865', 'leonardo.campos391@email.com', '1997-09-04', 'ativo', 94);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42201027602', 'isabela ferreira', '71796927868', 'isabela.ferreira141@email.com', '1996-10-14', 'ativo', 95);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('53269097311', 'erick gomes', '91950097519', 'erick.gomes421@email.com', '1981-08-07', 'inativo', 96);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('12847818959', 'camila barbosa', '21894905807', 'camila.barbosa484@email.com', '1980-05-13', 'ativo', 97);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79565442031', 'paulo ramos', '51079290490', 'paulo.ramos804@email.com', '1972-11-12', 'ativo', 98);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('28144294427', 'alexandre silva', '21929275243', 'alexandre.silva760@email.com', '1981-10-01', 'ativo', 99);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80512927662', 'sabrina barbosa', '81239504102', 'sabrina.barbosa677@email.com', '1980-10-24', 'ativo', 100);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47836674202', 'nadia leite', '11476580185', 'nadia.leite446@email.com', '2002-11-22', 'ativo', 101);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94544149680', 'denise pinto', '41938525800', 'denise.pinto692@email.com', '1997-04-22', 'ativo', 102);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('61817534439', 'leandro oliveira', '21093911192', 'leandro.oliveira25@email.com', '1976-11-11', 'ativo', 103);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92124471715', 'priscila pinto', '61421406650', 'priscila.pinto438@email.com', '1971-08-01', 'inativo', 104);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42717396263', 'ruan pereira', '91639174101', 'ruan.pereira148@email.com', '1963-02-27', 'ativo', 105);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47072006485', 'natalia cunha', '71908776618', 'natalia.cunha338@email.com', '1970-02-17', 'ativo', 106);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71985546012', 'camila freitas', '61174328063', 'camila.freitas548@email.com', '1973-05-28', 'ativo', 107);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('15717320395', 'pedro ramos', '41761847870', 'pedro.ramos608@email.com', '1961-08-29', 'ativo', 108);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('50613878218', 'aline duarte', '11270790320', 'aline.duarte74@email.com', '1967-09-23', 'ativo', 109);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41792911180', 'suelen machado', '41136565198', 'suelen.machado819@email.com', '1966-02-28', 'ativo', 110);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('30925114250', 'alessandra nascimento', '61827390219', 'alessandra.nascimento714@email.com', '1976-11-14', 'ativo', 111);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('07100219413', 'alessandra cunha', '81232487632', 'alessandra.cunha827@email.com', '1987-05-22', 'ativo', 112);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92791456065', 'carlos martins', '91195883734', 'carlos.martins121@email.com', '1962-05-19', 'ativo', 113);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27722005406', 'andre nunes', '61970108220', 'andre.nunes258@email.com', '1981-10-04', 'ativo', 114);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13799563581', 'aline pinto', '61313636317', 'aline.pinto113@email.com', '1986-03-31', 'ativo', 115);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('62397265242', 'murilo ramos', '61435209042', 'murilo.ramos199@email.com', '1964-12-25', 'ativo', 116);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76253492925', 'amanda figueiredo', '91316873977', 'amanda.figueiredo994@email.com', '1972-07-09', 'ativo', 117);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('63356939257', 'ana cavalcanti', '11780686717', 'ana.cavalcanti46@email.com', '1982-03-20', 'ativo', 118);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80632543176', 'maria correia', '51279907726', 'maria.correia686@email.com', '1968-04-18', 'ativo', 119);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('57016580402', 'renan rezende', '91931950850', 'renan.rezende277@email.com', '1964-12-23', 'ativo', 120);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79055281890', 'andre carvalho', '41817933554', 'andre.carvalho343@email.com', '1982-08-03', 'ativo', 121);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('40155778845', 'fernanda correia', '91847951371', 'fernanda.correia727@email.com', '1963-08-06', 'ativo', 122);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24112412757', 'natalia leite', '91046827567', 'natalia.leite210@email.com', '1993-02-02', 'ativo', 123);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('43103856994', 'cristiane xavier', '61798877492', 'cristiane.xavier662@email.com', '2000-04-17', 'ativo', 124);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24375402532', 'daniel cardoso', '31928422223', 'daniel.cardoso980@email.com', '1965-03-30', 'ativo', 125);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('59274523889', 'lucas brito', '61257828410', 'lucas.brito325@email.com', '1978-02-23', 'inativo', 126);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27520885407', 'alan fonseca', '31975170281', 'alan.fonseca297@email.com', '1973-10-26', 'ativo', 127);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('93751509331', 'nadia melo', '51301871863', 'nadia.melo801@email.com', '1981-12-31', 'ativo', 128);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98056265636', 'bruna silva', '61547813767', 'bruna.silva292@email.com', '1972-12-11', 'ativo', 129);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66299123497', 'alan leite', '61196106462', 'alan.leite538@email.com', '1984-12-06', 'ativo', 130);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92326487096', 'paulo vieira', '51787300244', 'paulo.vieira600@email.com', '2002-11-19', 'ativo', 131);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71462730164', 'priscila medeiros', '21959796471', 'priscila.medeiros994@email.com', '1976-09-27', 'ativo', 132);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('90429025749', 'isabela teixeira', '11456504481', 'isabela.teixeira168@email.com', '1983-01-19', 'ativo', 133);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21928554430', 'eduardo pereira', '61202845765', 'eduardo.pereira548@email.com', '2001-04-23', 'inativo', 134);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13283389834', 'otavio borges', '21671120754', 'otavio.borges565@email.com', '1990-12-31', 'ativo', 135);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79852401361', 'gustavo miranda', '31342321611', 'gustavo.miranda711@email.com', '1960-11-04', 'ativo', 136);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('60310890767', 'fernanda marques', '11140119393', 'fernanda.marques260@email.com', '1968-04-15', 'ativo', 137);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01249552825', 'carlos batista', '21190833428', 'carlos.batista584@email.com', '1960-03-11', 'inativo', 138);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13875927187', 'carolina vieira', '71638361517', 'carolina.vieira364@email.com', '1964-12-12', 'ativo', 139);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('75480157127', 'sabrina rocha', '51738646317', 'sabrina.rocha468@email.com', '2002-02-14', 'ativo', 140);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('20716781177', 'henrique campos', '21215353961', 'henrique.campos411@email.com', '1970-06-12', 'ativo', 141);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('74994657993', 'juliana medeiros', '51271147732', 'juliana.medeiros524@email.com', '1961-05-01', 'ativo', 142);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01702695232', 'paulo vasconcelos', '21187734778', 'paulo.vasconcelos639@email.com', '1971-09-27', 'ativo', 143);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('88006167552', 'leonardo moreira', '11028427624', 'leonardo.moreira471@email.com', '1992-02-08', 'ativo', 144);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('19788977820', 'thiago batista', '71479695450', 'thiago.batista58@email.com', '1961-04-06', 'ativo', 145);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('25590561605', 'fabio teixeira', '61033349114', 'fabio.teixeira422@email.com', '1965-02-18', 'ativo', 146);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08507698682', 'igor santos', '81905696591', 'igor.santos713@email.com', '1996-04-04', 'ativo', 147);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35785294515', 'luciana martins', '21834404963', 'luciana.martins509@email.com', '1988-01-06', 'ativo', 148);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('19195419858', 'alan nunes', '61148468536', 'alan.nunes215@email.com', '1978-01-17', 'ativo', 149);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87820829795', 'renata brito', '81489690835', 'renata.brito986@email.com', '1980-09-29', 'ativo', 150);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24665136415', 'daniel xavier', '51936312303', 'daniel.xavier165@email.com', '1995-10-02', 'ativo', 151);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('77866032476', 'isabela santos', '51820700159', 'isabela.santos265@email.com', '1973-05-14', 'ativo', 152);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65162319820', 'fernanda bezerra', '91471391559', 'fernanda.bezerra681@email.com', '1993-01-25', 'ativo', 153);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36321234709', 'marco ribeiro', '11785158673', 'marco.ribeiro884@email.com', '1972-06-16', 'ativo', 154);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('25754090043', 'carlos ribeiro', '71451837606', 'carlos.ribeiro566@email.com', '2001-08-09', 'inativo', 155);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44134327544', 'marco dantas', '51177656124', 'marco.dantas35@email.com', '1982-09-17', 'ativo', 156);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69857002766', 'isabela silva', '41459112382', 'isabela.silva411@email.com', '1997-12-28', 'ativo', 157);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65772429502', 'daniel martins', '71526693008', 'daniel.martins87@email.com', '1989-01-10', 'ativo', 158);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('31734206913', 'renan machado', '31152910867', 'renan.machado267@email.com', '1997-02-08', 'ativo', 159);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13334476200', 'luciana miranda', '41436262044', 'luciana.miranda212@email.com', '1970-07-25', 'ativo', 160);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35971072572', 'diego azevedo', '71694118005', 'diego.azevedo218@email.com', '2001-10-06', 'ativo', 161);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('59900489639', 'paulo queiroz', '61280924287', 'paulo.queiroz405@email.com', '2001-09-24', 'ativo', 162);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72158624103', 'sergio oliveira', '81456449485', 'sergio.oliveira131@email.com', '1979-07-19', 'ativo', 163);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('57287032089', 'aline rodrigues', '81427617075', 'aline.rodrigues37@email.com', '1991-10-21', 'ativo', 164);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('77121513420', 'carolina vieira', '91499390892', 'carolina.vieira173@email.com', '1978-09-05', 'inativo', 165);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37150416509', 'leticia vieira', '31017774905', 'leticia.vieira332@email.com', '1961-12-19', 'ativo', 166);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('75923045035', 'larissa pinheiro', '71164236103', 'larissa.pinheiro975@email.com', '1967-04-23', 'ativo', 167);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64214764909', 'gustavo teixeira', '21583776749', 'gustavo.teixeira682@email.com', '1986-12-05', 'ativo', 168);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65926610898', 'cristiane queiroz', '41278814761', 'cristiane.queiroz475@email.com', '2000-09-10', 'ativo', 169);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42243864964', 'gabriel pinheiro', '11818661794', 'gabriel.pinheiro79@email.com', '1975-12-11', 'ativo', 170);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18017226093', 'rafael cavalcanti', '51597794523', 'rafael.cavalcanti898@email.com', '1968-04-20', 'ativo', 171);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94168006190', 'joao nascimento', '81769749956', 'joao.nascimento672@email.com', '1996-02-04', 'ativo', 172);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('22031030358', 'viviane xavier', '41683147276', 'viviane.xavier149@email.com', '1960-12-23', 'ativo', 173);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27770793312', 'mariana figueiredo', '71050166799', 'mariana.figueiredo850@email.com', '1992-10-16', 'ativo', 174);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('40767899702', 'aline borges', '91069581467', 'aline.borges63@email.com', '1965-03-30', 'ativo', 175);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('57602437561', 'caio melo', '41959724665', 'caio.melo520@email.com', '1995-09-15', 'ativo', 176);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29341722366', 'thiago machado', '21674338005', 'thiago.machado504@email.com', '1999-07-07', 'ativo', 177);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('22801561990', 'aline costa', '41745508428', 'aline.costa576@email.com', '1987-02-08', 'ativo', 178);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('07711991809', 'julia batista', '31135247871', 'julia.batista108@email.com', '1966-12-02', 'ativo', 179);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52137603767', 'cristiane rocha', '31145653286', 'cristiane.rocha518@email.com', '1995-04-24', 'ativo', 180);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66678507202', 'joao borges', '91115562606', 'joao.borges826@email.com', '1994-01-20', 'ativo', 181);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29084668480', 'sergio marques', '11489267389', 'sergio.marques353@email.com', '1995-05-13', 'ativo', 182);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('75634108561', 'sabrina ramos', '31884318848', 'sabrina.ramos737@email.com', '1975-04-14', 'ativo', 183);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('20089434614', 'erick costa', '11548510174', 'erick.costa750@email.com', '1985-09-04', 'ativo', 184);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('75399893514', 'paulo rocha', '31683158935', 'paulo.rocha683@email.com', '1980-05-18', 'ativo', 185);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66110627343', 'eliane lima', '91698864976', 'eliane.lima379@email.com', '1979-09-28', 'ativo', 186);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76228277209', 'katia leite', '21377028519', 'katia.leite542@email.com', '1998-03-26', 'ativo', 187);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('15940821546', 'ligia freitas', '51702296044', 'ligia.freitas311@email.com', '1969-09-02', 'ativo', 188);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('70185106780', 'ligia figueiredo', '61679228777', 'ligia.figueiredo464@email.com', '1966-09-06', 'ativo', 189);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('51996636583', 'erica oliveira', '81412094818', 'erica.oliveira982@email.com', '1963-10-27', 'ativo', 190);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98909837883', 'maria costa', '91204339718', 'maria.costa675@email.com', '1987-03-22', 'ativo', 191);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('90705626001', 'nadia monteiro', '51111824224', 'nadia.monteiro392@email.com', '1994-06-18', 'ativo', 192);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('46209520017', 'paulo dias', '61265461033', 'paulo.dias102@email.com', '1993-09-26', 'ativo', 193);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37886140564', 'denise pinheiro', '21706304891', 'denise.pinheiro417@email.com', '1971-01-18', 'ativo', 194);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24967183220', 'bruna lacerda', '41868700794', 'bruna.lacerda173@email.com', '1989-04-17', 'inativo', 195);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('00749465360', 'katia rocha', '31891416128', 'katia.rocha47@email.com', '1972-07-14', 'ativo', 196);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('39855474326', 'tatiana mendes', '81950209700', 'tatiana.mendes216@email.com', '1990-03-05', 'ativo', 197);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87681180746', 'fernanda teixeira', '71956201753', 'fernanda.teixeira996@email.com', '1979-12-10', 'ativo', 198);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('04531943387', 'suelen reis', '11479303614', 'suelen.reis372@email.com', '1985-07-12', 'ativo', 199);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('28399921919', 'gustavo moraes', '31493843089', 'gustavo.moraes67@email.com', '1971-05-06', 'ativo', 200);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('70605664146', 'willian cardoso', '61803046875', 'willian.cardoso508@email.com', '1960-03-25', 'ativo', 201);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('51903613309', 'amanda mendes', '21107609543', 'amanda.mendes319@email.com', '1964-11-01', 'ativo', 202);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('50583199770', 'felipe leal', '21100651207', 'felipe.leal458@email.com', '1962-06-16', 'ativo', 203);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('61108046654', 'felipe vasconcelos', '71399076769', 'felipe.vasconcelos771@email.com', '1987-10-11', 'ativo', 204);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('07859311045', 'matheus andrade', '41928456797', 'matheus.andrade809@email.com', '1968-05-04', 'ativo', 205);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('00249685449', 'erica pinto', '31749545089', 'erica.pinto150@email.com', '1989-07-02', 'ativo', 206);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('03880653380', 'patricia dantas', '61377959959', 'patricia.dantas71@email.com', '1973-06-10', 'ativo', 207);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21707303381', 'denise vasconcelos', '41756362050', 'denise.vasconcelos219@email.com', '1963-04-23', 'ativo', 208);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('81247395017', 'pedro martins', '51234258323', 'pedro.martins203@email.com', '1960-12-18', 'ativo', 209);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41026153426', 'murilo barbosa', '61289611223', 'murilo.barbosa379@email.com', '1968-08-06', 'ativo', 210);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('55963099316', 'otavio rocha', '31530428973', 'otavio.rocha809@email.com', '1992-08-16', 'ativo', 211);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79128685775', 'willian cardoso', '61587774969', 'willian.cardoso184@email.com', '1989-02-22', 'ativo', 212);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('33736346608', 'thiago duarte', '61481214785', 'thiago.duarte863@email.com', '1970-04-29', 'ativo', 213);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('78956776672', 'bruna tavares', '61460273415', 'bruna.tavares510@email.com', '2000-06-08', 'ativo', 214);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('88814311146', 'eduardo oliveira', '41535444392', 'eduardo.oliveira560@email.com', '1998-05-09', 'ativo', 215);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('84044566902', 'joao correia', '91263337389', 'joao.correia670@email.com', '1995-04-04', 'ativo', 216);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('77515366321', 'caio moreira', '91052924075', 'caio.moreira874@email.com', '1975-03-30', 'ativo', 217);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66845909003', 'isabela almeida', '61999966361', 'isabela.almeida976@email.com', '1983-12-23', 'ativo', 218);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71597412181', 'vinicius oliveira', '81023164334', 'vinicius.oliveira847@email.com', '1989-08-02', 'ativo', 219);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('70580256650', 'thiago costa', '91671632346', 'thiago.costa133@email.com', '1996-09-08', 'ativo', 220);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72994938702', 'priscila martins', '31716938597', 'priscila.martins8@email.com', '1980-08-22', 'ativo', 221);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01475469238', 'alessandra barbosa', '71762916032', 'alessandra.barbosa184@email.com', '1972-04-12', 'ativo', 222);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('84137681521', 'larissa rezende', '91567243807', 'larissa.rezende108@email.com', '1961-03-13', 'ativo', 223);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76563600426', 'rodrigo borges', '31577711837', 'rodrigo.borges940@email.com', '1966-04-16', 'ativo', 224);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42209124102', 'otavio moraes', '31104275230', 'otavio.moraes401@email.com', '2000-01-16', 'ativo', 225);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37081647091', 'ana souza', '71335331060', 'ana.souza791@email.com', '1960-08-26', 'ativo', 226);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('31312206860', 'leticia guimaraes', '61839386613', 'leticia.guimaraes335@email.com', '1969-08-03', 'ativo', 227);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52065063701', 'marcelo lima', '51950136497', 'marcelo.lima674@email.com', '1964-07-26', 'ativo', 228);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92419562598', 'vinicius leal', '61715099768', 'vinicius.leal780@email.com', '1988-09-25', 'ativo', 229);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89030914348', 'renan rezende', '21025743263', 'renan.rezende250@email.com', '1988-10-19', 'ativo', 230);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97524508657', 'daniel rezende', '41553380339', 'daniel.rezende25@email.com', '1999-02-23', 'ativo', 231);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52701713092', 'henrique coelho', '31129833816', 'henrique.coelho210@email.com', '1992-07-09', 'ativo', 232);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23362934470', 'eliane reis', '41471566277', 'eliane.reis651@email.com', '1978-12-17', 'ativo', 233);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('62706614985', 'otavio almeida', '31467474689', 'otavio.almeida567@email.com', '1981-07-27', 'ativo', 234);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27323008530', 'ruan campos', '71656749160', 'ruan.campos948@email.com', '2001-05-04', 'ativo', 235);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92364587505', 'beatriz xavier', '71337050249', 'beatriz.xavier395@email.com', '1980-06-06', 'inativo', 236);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24399201186', 'sabrina campos', '21836264488', 'sabrina.campos724@email.com', '1989-07-15', 'ativo', 237);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94611952496', 'andre duarte', '71402701168', 'andre.duarte767@email.com', '1978-09-12', 'ativo', 238);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('62252237208', 'erick coelho', '81932302346', 'erick.coelho113@email.com', '1979-10-08', 'ativo', 239);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91214161418', 'matheus mendes', '41771004090', 'matheus.mendes31@email.com', '1964-05-05', 'ativo', 240);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06984775966', 'renan mendes', '61535669055', 'renan.mendes380@email.com', '1996-03-01', 'ativo', 241);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('76209184340', 'bruna moreira', '81863050505', 'bruna.moreira634@email.com', '1990-05-30', 'ativo', 242);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97691567106', 'sabrina rocha', '41289802714', 'sabrina.rocha622@email.com', '1997-05-03', 'ativo', 243);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87271783313', 'renata nascimento', '21160256434', 'renata.nascimento772@email.com', '1989-11-14', 'ativo', 244);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('12871539923', 'matheus xavier', '71686334141', 'matheus.xavier352@email.com', '1964-12-29', 'ativo', 245);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('93195256927', 'ana alves', '91366552899', 'ana.alves64@email.com', '1969-12-18', 'ativo', 246);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08752437700', 'henrique machado', '31095481497', 'henrique.machado291@email.com', '1988-04-22', 'ativo', 247);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('74605233052', 'vinicius miranda', '71420865675', 'vinicius.miranda500@email.com', '1993-12-27', 'ativo', 248);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18443861204', 'tatiana rezende', '11472927742', 'tatiana.rezende811@email.com', '1969-05-29', 'ativo', 249);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('30591266234', 'beatriz pereira', '81201859626', 'beatriz.pereira365@email.com', '1970-12-28', 'ativo', 250);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36749261723', 'leonardo gomes', '81501111783', 'leonardo.gomes648@email.com', '1961-01-12', 'ativo', 251);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97419267662', 'paulo figueiredo', '21518260688', 'paulo.figueiredo129@email.com', '1995-02-22', 'ativo', 252);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71898131284', 'carolina silva', '81510293218', 'carolina.silva569@email.com', '1971-07-08', 'ativo', 253);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01184582646', 'ana barbosa', '11848729758', 'ana.barbosa308@email.com', '2000-11-08', 'inativo', 254);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('59883103037', 'leandro almeida', '41298395429', 'leandro.almeida307@email.com', '1978-12-06', 'ativo', 255);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44626714651', 'henrique lacerda', '21435989262', 'henrique.lacerda209@email.com', '1974-03-11', 'inativo', 256);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66093141871', 'rodrigo azevedo', '71151554234', 'rodrigo.azevedo562@email.com', '1960-06-10', 'ativo', 257);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36112849719', 'felipe bezerra', '51849102562', 'felipe.bezerra358@email.com', '1975-06-26', 'ativo', 258);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('88967924010', 'katia borges', '31269405396', 'katia.borges160@email.com', '1991-09-14', 'ativo', 259);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('75784468352', 'ligia leal', '21465111312', 'ligia.leal879@email.com', '1985-10-21', 'ativo', 260);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('48706827704', 'katia azevedo', '91160930685', 'katia.azevedo694@email.com', '1970-12-15', 'inativo', 261);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89097283292', 'larissa freitas', '31850676251', 'larissa.freitas860@email.com', '1975-02-28', 'inativo', 262);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('38144744305', 'ana moraes', '71348079705', 'ana.moraes647@email.com', '1960-04-06', 'ativo', 263);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('54510526544', 'joao pereira', '81318826170', 'joao.pereira442@email.com', '1966-12-24', 'ativo', 264);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('43765456275', 'otavio tavares', '21772256053', 'otavio.tavares276@email.com', '1964-12-18', 'ativo', 265);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('02665023775', 'igor costa', '81872568621', 'igor.costa432@email.com', '2002-12-16', 'ativo', 266);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('02258030547', 'renan queiroz', '11674471639', 'renan.queiroz612@email.com', '1966-11-03', 'ativo', 267);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23414363744', 'leticia cunha', '91923923126', 'leticia.cunha748@email.com', '1961-09-20', 'ativo', 268);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('32609310663', 'marco bezerra', '41356708604', 'marco.bezerra314@email.com', '1964-12-08', 'ativo', 269);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('45635020069', 'gabriel brito', '61347491624', 'gabriel.brito763@email.com', '2002-07-16', 'ativo', 270);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('54110825520', 'eduardo moraes', '91953439611', 'eduardo.moraes798@email.com', '1965-11-07', 'ativo', 271);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91093371134', 'erica vasconcelos', '51738202368', 'erica.vasconcelos352@email.com', '1991-12-02', 'ativo', 272);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('85571617601', 'nadia duarte', '91029424090', 'nadia.duarte976@email.com', '1995-08-20', 'inativo', 273);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36788127839', 'sabrina pinheiro', '71694320293', 'sabrina.pinheiro799@email.com', '1986-07-24', 'ativo', 274);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87884434428', 'fernanda nascimento', '11834024240', 'fernanda.nascimento230@email.com', '1988-10-25', 'inativo', 275);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('38105955192', 'vanessa ramos', '71945005342', 'vanessa.ramos137@email.com', '1971-06-26', 'inativo', 276);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89164983766', 'marcelo monteiro', '41962736527', 'marcelo.monteiro276@email.com', '1964-03-15', 'ativo', 277);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('72239724080', 'ligia nascimento', '31693121637', 'ligia.nascimento907@email.com', '2000-10-12', 'ativo', 278);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('61820916650', 'maria costa', '11023142900', 'maria.costa847@email.com', '2002-12-15', 'ativo', 279);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('85132797222', 'ligia mendes', '31308481001', 'ligia.mendes491@email.com', '1984-06-06', 'ativo', 280);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('86203036600', 'henrique teixeira', '51361721314', 'henrique.teixeira672@email.com', '1976-01-11', 'ativo', 281);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('51510922608', 'nadia mendes', '31624945147', 'nadia.mendes615@email.com', '1989-09-06', 'ativo', 282);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41022526730', 'viviane guimaraes', '21964215226', 'viviane.guimaraes69@email.com', '1975-10-26', 'ativo', 283);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('67695236639', 'suelen lacerda', '81883619689', 'suelen.lacerda547@email.com', '1994-11-01', 'ativo', 284);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('31350305805', 'alan reis', '21055247286', 'alan.reis137@email.com', '1970-11-17', 'ativo', 285);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('30212606591', 'gabriel cunha', '21792025213', 'gabriel.cunha109@email.com', '1963-06-16', 'ativo', 286);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('62272847699', 'cristiane moreira', '11412009282', 'cristiane.moreira801@email.com', '1960-06-27', 'ativo', 287);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('67849843666', 'thiago gomes', '21862369036', 'thiago.gomes997@email.com', '1968-03-28', 'ativo', 288);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89177566206', 'gabriel tavares', '71341115950', 'gabriel.tavares381@email.com', '1970-09-29', 'ativo', 289);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('81139043870', 'patricia leal', '11341990970', 'patricia.leal952@email.com', '1962-02-26', 'ativo', 290);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('40546835685', 'claudia queiroz', '21568182096', 'claudia.queiroz133@email.com', '1981-05-24', 'ativo', 291);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('04227113301', 'henrique pinto', '31889857254', 'henrique.pinto736@email.com', '1976-02-29', 'ativo', 292);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('60633991272', 'suelen pereira', '11248171752', 'suelen.pereira825@email.com', '2001-11-24', 'ativo', 293);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('14955112780', 'vanessa correia', '81219705466', 'vanessa.correia263@email.com', '1998-06-11', 'ativo', 294);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27589551648', 'erick moreira', '11903802146', 'erick.moreira270@email.com', '1967-02-05', 'ativo', 295);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13671577812', 'denise pereira', '31166365155', 'denise.pereira88@email.com', '1987-02-09', 'ativo', 296);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71470827293', 'renata monteiro', '11960567303', 'renata.monteiro582@email.com', '1998-12-08', 'ativo', 297);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64421214619', 'rafael alves', '81683420165', 'rafael.alves895@email.com', '1993-10-14', 'ativo', 298);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35677826571', 'sabrina guimaraes', '91931992550', 'sabrina.guimaraes11@email.com', '1966-10-01', 'ativo', 299);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27516480706', 'gustavo leal', '21033682963', 'gustavo.leal461@email.com', '1975-08-13', 'ativo', 300);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('39055044805', 'fernanda cunha', '81665586851', 'fernanda.cunha512@email.com', '2001-07-21', 'ativo', 301);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65289286652', 'daniel miranda', '71491111096', 'daniel.miranda676@email.com', '1964-08-25', 'ativo', 302);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98178904652', 'renata melo', '81861371576', 'renata.melo796@email.com', '2000-09-23', 'ativo', 303);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('60538444460', 'alessandra azevedo', '11600025895', 'alessandra.azevedo248@email.com', '1975-01-12', 'ativo', 304);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('96386396017', 'renan carvalho', '71265826312', 'renan.carvalho962@email.com', '1982-08-14', 'ativo', 305);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('96482531106', 'pedro nunes', '31098196027', 'pedro.nunes12@email.com', '1988-06-17', 'ativo', 306);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52334383648', 'vanessa brito', '51120911791', 'vanessa.brito53@email.com', '1964-10-20', 'ativo', 307);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('42117536141', 'ruan dantas', '71171366572', 'ruan.dantas23@email.com', '1968-01-24', 'ativo', 308);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29901557914', 'erica silva', '91413908088', 'erica.silva163@email.com', '1994-02-18', 'ativo', 309);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('51305231211', 'igor gomes', '41158477686', 'igor.gomes494@email.com', '2001-05-16', 'ativo', 310);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23461994273', 'andre reis', '81676945919', 'andre.reis740@email.com', '1977-03-07', 'ativo', 311);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95517208496', 'marco rocha', '91560125625', 'marco.rocha619@email.com', '1971-01-02', 'ativo', 312);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('55251050550', 'renata cardoso', '61381649383', 'renata.cardoso582@email.com', '1964-08-13', 'ativo', 313);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91966553302', 'gabriel tavares', '81046117295', 'gabriel.tavares506@email.com', '1986-07-08', 'ativo', 314);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('90409074202', 'juliana oliveira', '91805017164', 'juliana.oliveira918@email.com', '1972-04-27', 'ativo', 315);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('56185790658', 'paulo cunha', '81159103002', 'paulo.cunha466@email.com', '1964-09-18', 'inativo', 316);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('63213580028', 'vanessa bernardes', '11104145964', 'vanessa.bernardes804@email.com', '1991-05-04', 'ativo', 317);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29712529654', 'eliane brito', '91839774573', 'eliane.brito126@email.com', '1964-02-13', 'ativo', 318);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41583311700', 'beatriz araujo', '41763715398', 'beatriz.araujo14@email.com', '1983-01-20', 'ativo', 319);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47281235616', 'eliane leite', '91363146249', 'eliane.leite636@email.com', '1989-01-31', 'ativo', 320);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71130724025', 'alan brito', '81541815632', 'alan.brito544@email.com', '1977-10-21', 'ativo', 321);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('85074510636', 'renan martins', '41629489786', 'renan.martins302@email.com', '1964-11-23', 'ativo', 322);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('31310094380', 'matheus lacerda', '51396661347', 'matheus.lacerda104@email.com', '1969-03-24', 'ativo', 323);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35494012803', 'viviane moraes', '41251225720', 'viviane.moraes313@email.com', '1989-11-16', 'ativo', 324);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('50241209572', 'alan andrade', '81371009438', 'alan.andrade2@email.com', '1982-07-27', 'ativo', 325);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21145775895', 'alexandre brito', '51570545897', 'alexandre.brito499@email.com', '1965-01-21', 'ativo', 326);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80263257022', 'simone figueiredo', '71531361487', 'simone.figueiredo759@email.com', '2002-12-26', 'ativo', 327);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24556964489', 'leandro oliveira', '91591679541', 'leandro.oliveira594@email.com', '1960-05-16', 'ativo', 328);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27284982457', 'ruan rocha', '51070349107', 'ruan.rocha67@email.com', '1973-09-19', 'ativo', 329);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('50042548858', 'natalia reis', '51236914307', 'natalia.reis89@email.com', '2001-11-06', 'ativo', 330);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('66614494208', 'luciana azevedo', '61923426834', 'luciana.azevedo897@email.com', '1973-09-06', 'ativo', 331);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97826612871', 'caio cunha', '91575676670', 'caio.cunha321@email.com', '2000-12-07', 'ativo', 332);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('61294398570', 'gustavo vasconcelos', '51062607870', 'gustavo.vasconcelos557@email.com', '1963-10-19', 'ativo', 333);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('15914975074', 'fernanda moraes', '91038287232', 'fernanda.moraes599@email.com', '1973-06-30', 'ativo', 334);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('07931102976', 'fernanda bezerra', '41317087601', 'fernanda.bezerra100@email.com', '1973-06-14', 'ativo', 335);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23849791671', 'henrique leal', '31232883774', 'henrique.leal23@email.com', '1972-12-25', 'ativo', 336);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97546617662', 'renan almeida', '51719609409', 'renan.almeida29@email.com', '1979-12-09', 'ativo', 337);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('52774025862', 'erick araujo', '91681225957', 'erick.araujo358@email.com', '1992-01-30', 'ativo', 338);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24461767980', 'carolina figueiredo', '91842599599', 'carolina.figueiredo726@email.com', '1997-03-23', 'ativo', 339);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('00231177537', 'aline queiroz', '41126610941', 'aline.queiroz791@email.com', '1961-09-05', 'ativo', 340);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17590251781', 'leonardo carvalho', '91334774332', 'leonardo.carvalho653@email.com', '1979-06-21', 'ativo', 341);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('31901302052', 'eduardo pinto', '91152873397', 'eduardo.pinto418@email.com', '1982-06-19', 'ativo', 342);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98217661960', 'rafael carvalho', '91411730985', 'rafael.carvalho802@email.com', '1961-01-04', 'ativo', 343);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44651241801', 'carlos miranda', '91469081974', 'carlos.miranda531@email.com', '1989-04-20', 'ativo', 344);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('56435023803', 'roberto duarte', '11371990516', 'roberto.duarte776@email.com', '1986-10-31', 'ativo', 345);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18724010741', 'erick melo', '61674300038', 'erick.melo666@email.com', '1987-04-12', 'ativo', 346);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08706626607', 'isabela costa', '21955356033', 'isabela.costa449@email.com', '1964-02-16', 'ativo', 347);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36890030163', 'beatriz carvalho', '31405593429', 'beatriz.carvalho450@email.com', '1977-11-04', 'ativo', 348);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('11148375399', 'caio borges', '61843845881', 'caio.borges310@email.com', '1962-06-03', 'ativo', 349);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69741328321', 'ligia moraes', '41152037710', 'ligia.moraes567@email.com', '1982-05-19', 'ativo', 350);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44964104941', 'sabrina medeiros', '71670336268', 'sabrina.medeiros20@email.com', '1962-05-06', 'ativo', 351);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08509549321', 'pedro mendes', '71601864876', 'pedro.mendes744@email.com', '1985-09-07', 'ativo', 352);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('84267320469', 'priscila ferreira', '91459609454', 'priscila.ferreira256@email.com', '1989-07-27', 'ativo', 353);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('90149542719', 'denise santos', '11705783609', 'denise.santos451@email.com', '2002-02-10', 'ativo', 354);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('98517244400', 'suelen carvalho', '31290310287', 'suelen.carvalho233@email.com', '1986-01-04', 'ativo', 355);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('83044058065', 'carlos teixeira', '21871813359', 'carlos.teixeira112@email.com', '1976-08-28', 'ativo', 356);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('61642059560', 'roberto queiroz', '61749025042', 'roberto.queiroz418@email.com', '2000-11-26', 'ativo', 357);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('19358895329', 'leonardo vieira', '11261139898', 'leonardo.vieira597@email.com', '1992-12-03', 'ativo', 358);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18097887575', 'igor martins', '51353537513', 'igor.martins857@email.com', '1979-12-18', 'ativo', 359);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65158815768', 'aline moreira', '71392836929', 'aline.moreira806@email.com', '1971-09-04', 'ativo', 360);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('55116682909', 'suelen leal', '41270216487', 'suelen.leal903@email.com', '1993-04-27', 'ativo', 361);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06021288622', 'renan teixeira', '71834155999', 'renan.teixeira131@email.com', '1964-10-31', 'inativo', 362);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('01576764710', 'isabela ramos', '91120995765', 'isabela.ramos188@email.com', '1979-09-03', 'ativo', 363);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('94134750910', 'willian fonseca', '91645652203', 'willian.fonseca538@email.com', '1979-04-24', 'ativo', 364);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('99515421406', 'priscila medeiros', '41244913421', 'priscila.medeiros450@email.com', '1969-04-11', 'ativo', 365);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('82090883005', 'ruan vieira', '11534967827', 'ruan.vieira843@email.com', '1973-03-25', 'inativo', 366);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17674124100', 'claudia tavares', '41152854781', 'claudia.tavares81@email.com', '1991-09-15', 'ativo', 367);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06185380031', 'simone carvalho', '71334727274', 'simone.carvalho601@email.com', '1965-11-29', 'ativo', 368);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18306178932', 'andre borges', '11649693578', 'andre.borges183@email.com', '1989-06-20', 'inativo', 369);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('43477695808', 'viviane rocha', '41146753612', 'viviane.rocha99@email.com', '1980-11-05', 'inativo', 370);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('15627796301', 'pedro rocha', '91360854566', 'pedro.rocha275@email.com', '1996-04-16', 'ativo', 371);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64047350400', 'eliane cavalcanti', '31831995298', 'eliane.cavalcanti227@email.com', '1960-11-22', 'inativo', 372);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06155810801', 'andre freitas', '41286342556', 'andre.freitas549@email.com', '1969-09-02', 'ativo', 373);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('30008186777', 'julia nascimento', '51033041662', 'julia.nascimento290@email.com', '1996-09-14', 'ativo', 374);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41118600873', 'natalia pereira', '71394568044', 'natalia.pereira754@email.com', '1980-08-01', 'ativo', 375);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('49764613601', 'priscila correia', '91836076581', 'priscila.correia292@email.com', '1980-04-14', 'ativo', 376);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06375791431', 'roberto almeida', '21182379312', 'roberto.almeida830@email.com', '1978-01-31', 'ativo', 377);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('78930746470', 'cristiane vieira', '11599604387', 'cristiane.vieira155@email.com', '1984-06-21', 'ativo', 378);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35778811601', 'larissa dias', '11281237106', 'larissa.dias131@email.com', '1982-03-19', 'ativo', 379);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87286604120', 'luciana rocha', '51859592248', 'luciana.rocha738@email.com', '1990-09-23', 'ativo', 380);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95894773568', 'isabela nascimento', '81056227104', 'isabela.nascimento537@email.com', '1991-06-19', 'ativo', 381);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18751097902', 'thiago lima', '91350344694', 'thiago.lima359@email.com', '1976-06-22', 'ativo', 382);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64883192131', 'renata gomes', '51912896599', 'renata.gomes183@email.com', '1987-02-16', 'ativo', 383);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97320331937', 'henrique almeida', '81051028767', 'henrique.almeida169@email.com', '1974-09-03', 'ativo', 384);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13866675446', 'willian monteiro', '21932426877', 'willian.monteiro544@email.com', '1991-03-07', 'ativo', 385);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18652057539', 'renan araujo', '91365203758', 'renan.araujo632@email.com', '1968-09-28', 'ativo', 386);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('45154809440', 'lucas xavier', '81604409079', 'lucas.xavier282@email.com', '1988-05-11', 'ativo', 387);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27810509200', 'vinicius leite', '31161070518', 'vinicius.leite872@email.com', '1972-06-12', 'inativo', 388);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('39055295802', 'joao coelho', '71601382412', 'joao.coelho681@email.com', '1979-11-21', 'ativo', 389);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('93862044877', 'fabio costa', '81919711121', 'fabio.costa350@email.com', '1968-04-29', 'ativo', 390);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('02035713470', 'leandro moraes', '31406424295', 'leandro.moraes774@email.com', '1978-07-27', 'ativo', 391);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('34324474187', 'ruan teixeira', '61587209628', 'ruan.teixeira593@email.com', '1985-07-05', 'ativo', 392);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('65435884111', 'katia pinto', '51374018272', 'katia.pinto216@email.com', '1980-12-16', 'ativo', 393);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('59690515007', 'thiago cavalcanti', '61512542782', 'thiago.cavalcanti487@email.com', '1993-09-25', 'ativo', 394);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('97996673482', 'bruna machado', '81640381664', 'bruna.machado346@email.com', '2002-10-17', 'ativo', 395);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('90282498345', 'isabela carvalho', '61014257627', 'isabela.carvalho680@email.com', '1960-01-14', 'ativo', 396);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('32441233683', 'camila ramos', '31850725178', 'camila.ramos251@email.com', '1990-10-22', 'ativo', 397);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('37673162507', 'isabela campos', '61469681579', 'isabela.campos792@email.com', '1961-03-16', 'ativo', 398);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92355580935', 'diego marques', '41273034615', 'diego.marques80@email.com', '1977-03-24', 'ativo', 399);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('62446704694', 'vinicius nascimento', '91171516025', 'vinicius.nascimento408@email.com', '1965-10-10', 'ativo', 400);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('67076604620', 'vanessa moraes', '21978575851', 'vanessa.moraes650@email.com', '1995-03-27', 'ativo', 401);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('68612059407', 'patricia batista', '81607401775', 'patricia.batista833@email.com', '1962-03-31', 'ativo', 402);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('54654084216', 'mariana teixeira', '11754091508', 'mariana.teixeira428@email.com', '1993-02-18', 'ativo', 403);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21812276400', 'fabio queiroz', '41897015502', 'fabio.queiroz470@email.com', '1987-05-02', 'inativo', 404);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('16815466048', 'carolina coelho', '51161394498', 'carolina.coelho765@email.com', '1984-03-08', 'ativo', 405);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('30597364217', 'priscila batista', '11962440630', 'priscila.batista688@email.com', '1995-01-30', 'ativo', 406);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('24479513371', 'maria borges', '41194979695', 'maria.borges333@email.com', '1984-04-15', 'ativo', 407);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80555572766', 'suelen araujo', '31646091785', 'suelen.araujo546@email.com', '1963-09-23', 'ativo', 408);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('85445770242', 'amanda vasconcelos', '71604873682', 'amanda.vasconcelos361@email.com', '1976-12-22', 'ativo', 409);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('11633194220', 'thiago pinto', '71865369455', 'thiago.pinto797@email.com', '1988-04-09', 'ativo', 410);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('58886367703', 'daniel guimaraes', '81226408572', 'daniel.guimaraes947@email.com', '1990-08-27', 'inativo', 411);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69666309348', 'isabela vasconcelos', '91199605932', 'isabela.vasconcelos635@email.com', '1985-07-15', 'ativo', 412);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('15096883231', 'murilo freitas', '41273524103', 'murilo.freitas741@email.com', '1985-11-28', 'ativo', 413);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('39732781993', 'roberto leite', '31371006876', 'roberto.leite943@email.com', '1963-02-26', 'ativo', 414);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('48198077066', 'mariana tavares', '11568761124', 'mariana.tavares408@email.com', '1993-12-31', 'ativo', 415);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('12565237390', 'vanessa pereira', '21773454757', 'vanessa.pereira338@email.com', '1991-05-19', 'ativo', 416);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('49022840300', 'bruna figueiredo', '51429477422', 'bruna.figueiredo372@email.com', '1966-07-28', 'ativo', 417);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64303942984', 'joao ribeiro', '91867925298', 'joao.ribeiro373@email.com', '1974-02-05', 'ativo', 418);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('67287276045', 'matheus mendes', '51332491357', 'matheus.mendes231@email.com', '1980-08-08', 'ativo', 419);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08335061531', 'erick lima', '91881079833', 'erick.lima278@email.com', '1971-06-27', 'ativo', 420);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23372094827', 'priscila ferreira', '41128403339', 'priscila.ferreira761@email.com', '1994-03-02', 'ativo', 421);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('71805137177', 'caio ferreira', '41189397490', 'caio.ferreira488@email.com', '1986-02-03', 'ativo', 422);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('17399704624', 'igor medeiros', '31587844483', 'igor.medeiros647@email.com', '1975-04-21', 'ativo', 423);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('88471270508', 'katia correia', '31216417582', 'katia.correia508@email.com', '1968-09-06', 'ativo', 424);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('33484587143', 'paulo duarte', '41925236229', 'paulo.duarte625@email.com', '1989-09-20', 'ativo', 425);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87964347408', 'bruna almeida', '61557469660', 'bruna.almeida314@email.com', '1994-03-11', 'inativo', 426);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('06527403320', 'alexandre rocha', '61056658833', 'alexandre.rocha853@email.com', '1987-09-14', 'ativo', 427);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('41132579739', 'julia pinto', '71734996010', 'julia.pinto676@email.com', '1988-09-09', 'ativo', 428);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('85741721540', 'marco guimaraes', '31949381735', 'marco.guimaraes156@email.com', '1985-09-09', 'ativo', 429);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('48840215503', 'eliane moraes', '41257375534', 'eliane.moraes906@email.com', '1971-06-15', 'ativo', 430);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('02166670891', 'beatriz marques', '61096085874', 'beatriz.marques525@email.com', '1985-10-13', 'ativo', 431);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('11918182840', 'camila figueiredo', '81931647725', 'camila.figueiredo945@email.com', '1963-04-11', 'ativo', 432);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('95786069409', 'ana vasconcelos', '71003562439', 'ana.vasconcelos849@email.com', '1990-04-04', 'ativo', 433);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87395923248', 'andre alves', '21089028515', 'andre.alves186@email.com', '1999-01-19', 'ativo', 434);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('33342643353', 'claudia santos', '81160736077', 'claudia.santos141@email.com', '1977-11-27', 'ativo', 435);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69112898156', 'thiago rezende', '21795563318', 'thiago.rezende215@email.com', '1976-02-21', 'ativo', 436);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('81700666113', 'claudia freitas', '51164316704', 'claudia.freitas969@email.com', '1992-09-23', 'ativo', 437);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('50232902808', 'natalia carvalho', '81009345962', 'natalia.carvalho712@email.com', '1978-10-21', 'ativo', 438);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('82251207363', 'ligia campos', '61495005070', 'ligia.campos641@email.com', '1992-12-19', 'ativo', 439);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('60869822108', 'joao teixeira', '41161177687', 'joao.teixeira919@email.com', '1966-01-11', 'ativo', 440);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('04774258520', 'felipe correia', '41238223116', 'felipe.correia505@email.com', '1972-08-30', 'ativo', 441);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13342457971', 'willian bezerra', '51256529060', 'willian.bezerra592@email.com', '1995-08-17', 'ativo', 442);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('20203265075', 'viviane correia', '61396737948', 'viviane.correia879@email.com', '1979-09-24', 'ativo', 443);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('48552457803', 'murilo brito', '61841560821', 'murilo.brito99@email.com', '1970-03-10', 'inativo', 444);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('11842547616', 'rafael reis', '91268323035', 'rafael.reis888@email.com', '1983-07-30', 'ativo', 445);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29880858384', 'nadia nascimento', '31129328963', 'nadia.nascimento384@email.com', '1972-06-27', 'ativo', 446);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('64686775218', 'paulo silva', '51843991062', 'paulo.silva77@email.com', '1966-06-13', 'ativo', 447);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('23626693351', 'fabio lima', '51261923724', 'fabio.lima232@email.com', '1994-02-12', 'ativo', 448);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('18481973737', 'paulo guimaraes', '91972154064', 'paulo.guimaraes128@email.com', '1965-01-22', 'ativo', 449);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('69274381141', 'eduardo barbosa', '81660144485', 'eduardo.barbosa891@email.com', '1978-10-28', 'ativo', 450);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('45101739704', 'marcelo andrade', '51178996986', 'marcelo.andrade445@email.com', '1961-11-20', 'ativo', 451);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91911359903', 'alessandra guimaraes', '11577980660', 'alessandra.guimaraes404@email.com', '1969-09-09', 'ativo', 452);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05146074598', 'fabio teixeira', '41470574238', 'fabio.teixeira997@email.com', '1994-07-29', 'ativo', 453);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('56527155967', 'otavio moraes', '41541165972', 'otavio.moraes825@email.com', '1993-12-08', 'ativo', 454);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47557522564', 'maria costa', '51884882691', 'maria.costa195@email.com', '1968-11-28', 'ativo', 455);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('96425856269', 'sabrina pereira', '51991537038', 'sabrina.pereira866@email.com', '1966-12-14', 'ativo', 456);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('40733337399', 'henrique silva', '41097768893', 'henrique.silva304@email.com', '1978-06-30', 'ativo', 457);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('89696454624', 'bruna freitas', '41585125389', 'bruna.freitas922@email.com', '1965-10-10', 'ativo', 458);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('87851935854', 'marcelo cardoso', '11797796120', 'marcelo.cardoso276@email.com', '1985-02-12', 'ativo', 459);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05721514978', 'alexandre coelho', '11976263748', 'alexandre.coelho919@email.com', '1991-04-11', 'ativo', 460);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('53986289500', 'ana queiroz', '11591191862', 'ana.queiroz625@email.com', '1992-11-10', 'ativo', 461);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92207151128', 'juliana figueiredo', '71667252145', 'juliana.figueiredo718@email.com', '1967-12-16', 'ativo', 462);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('47124633501', 'rafael mendes', '21840908051', 'rafael.mendes463@email.com', '1967-07-23', 'ativo', 463);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('80056409941', 'bruna miranda', '31397283512', 'bruna.miranda72@email.com', '1986-11-25', 'ativo', 464);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27282709026', 'otavio bernardes', '21441529821', 'otavio.bernardes982@email.com', '1982-04-28', 'ativo', 465);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('29578671842', 'matheus mendes', '61237360507', 'matheus.mendes253@email.com', '1996-05-16', 'ativo', 466);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91815899803', 'willian campos', '91345273466', 'willian.campos776@email.com', '1979-07-09', 'ativo', 467);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('70715879650', 'ligia medeiros', '51080314998', 'ligia.medeiros806@email.com', '1967-10-11', 'ativo', 468);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('08004635878', 'gabriel guimaraes', '71882850317', 'gabriel.guimaraes846@email.com', '2002-08-12', 'ativo', 469);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35137399073', 'julia duarte', '41140352635', 'julia.duarte391@email.com', '2001-02-27', 'ativo', 470);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('02293946988', 'ligia araujo', '51606664374', 'ligia.araujo963@email.com', '1986-12-02', 'ativo', 471);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('60723111212', 'ruan lima', '91524648449', 'ruan.lima188@email.com', '1971-09-24', 'ativo', 472);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('16318732883', 'lucas correia', '21130621136', 'lucas.correia491@email.com', '1987-08-08', 'ativo', 473);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('27908335081', 'joao coelho', '61425730662', 'joao.coelho157@email.com', '2002-06-21', 'ativo', 474);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('13235707130', 'simone machado', '51822850116', 'simone.machado542@email.com', '1983-03-28', 'ativo', 475);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92550213038', 'leonardo silva', '11691309810', 'leonardo.silva577@email.com', '1989-02-07', 'ativo', 476);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('79649673714', 'alexandre teixeira', '81727853242', 'alexandre.teixeira652@email.com', '1977-06-04', 'inativo', 477);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('25064207621', 'erica miranda', '71253666777', 'erica.miranda233@email.com', '2002-09-20', 'ativo', 478);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('55562833384', 'leandro figueiredo', '61786543627', 'leandro.figueiredo200@email.com', '1964-11-15', 'ativo', 479);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('74960335889', 'thiago brito', '91627036924', 'thiago.brito394@email.com', '1993-06-18', 'ativo', 480);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('26932657387', 'gustavo rezende', '81599801110', 'gustavo.rezende954@email.com', '1960-05-22', 'inativo', 481);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05155323472', 'matheus freitas', '61977524418', 'matheus.freitas639@email.com', '1967-03-03', 'inativo', 482);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('22618962800', 'alan cunha', '41127102676', 'alan.cunha288@email.com', '1981-05-23', 'ativo', 483);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('09579927003', 'ruan coelho', '61515122946', 'ruan.coelho688@email.com', '2001-02-14', 'ativo', 484);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('35415970976', 'alessandra nascimento', '51384807520', 'alessandra.nascimento374@email.com', '1989-02-16', 'ativo', 485);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('44765047104', 'roberto pinheiro', '31909046376', 'roberto.pinheiro33@email.com', '1977-06-03', 'ativo', 486);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('46558665270', 'fabio ramos', '91374417158', 'fabio.ramos268@email.com', '2000-03-08', 'ativo', 487);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('21312512970', 'carlos pinto', '21005912975', 'carlos.pinto90@email.com', '1995-04-06', 'ativo', 488);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('91023121153', 'ana nunes', '41301658373', 'ana.nunes811@email.com', '1991-10-08', 'inativo', 489);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('92749072815', 'ana ferreira', '41428931132', 'ana.ferreira181@email.com', '1998-01-24', 'ativo', 490);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('32694968429', 'renata nunes', '61380442101', 'renata.nunes257@email.com', '1982-02-26', 'ativo', 491);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('09617015950', 'eduardo cunha', '21945757574', 'eduardo.cunha698@email.com', '1994-03-30', 'ativo', 492);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('83392056765', 'denise monteiro', '71777226602', 'denise.monteiro946@email.com', '1995-05-11', 'ativo', 493);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('26506229200', 'renata pereira', '71724530762', 'renata.pereira17@email.com', '1973-08-12', 'ativo', 494);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('84337976620', 'thiago medeiros', '11511579423', 'thiago.medeiros993@email.com', '1983-04-09', 'inativo', 495);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36704254973', 'renan vasconcelos', '31845525971', 'renan.vasconcelos125@email.com', '1960-10-17', 'ativo', 496);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('63353574888', 'cristiane figueiredo', '61325939933', 'cristiane.figueiredo813@email.com', '1981-12-01', 'ativo', 497);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05816295159', 'nadia medeiros', '51176342507', 'nadia.medeiros474@email.com', '1971-01-23', 'ativo', 498);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('05597824545', 'ruan monteiro', '91339914038', 'ruan.monteiro620@email.com', '1995-11-01', 'ativo', 499);
INSERT INTO colaborador (cpf, nome, telefone, email, data_nascimento, status, id_endereco) VALUES ('36604432476', 'pedro santos', '71157276829', 'pedro.santos668@email.com', '1979-12-03', 'ativo', 500);

INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (1, '0370 0332 2855 6608', '2028-04-01', 'hipercard', 'credito', '6810');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (2, '3903 3970 5195 8263', '2026-09-16', 'american express', 'credito', '9448');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (3, '5862 3945 3546 1470', '2029-12-30', 'american express', 'pre-pago', '8632');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (4, '1061 3394 3945 7039', '2027-10-31', 'mastercard', 'pre-pago', '0403');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (5, '2537 6576 9277 8943', '2025-11-15', 'american express', 'credito', '0090');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (6, '0404 7692 1053 3651', '2028-02-21', 'hipercard', 'pre-pago', '0401');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (7, '4247 3107 2011 3798', '2028-01-24', 'elo', 'credito', '9712');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (8, '3166 0076 7620 9014', '2028-02-28', 'hipercard', 'credito', '4043');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (9, '3700 9687 3045 1957', '2030-04-20', 'american express', 'credito', '5588');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (9, '2556 2965 7542 7865', '2029-11-04', 'visa', 'pre-pago', '4255');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (10, '7782 0582 9582 9236', '2025-12-01', 'hipercard', 'credito', '8808');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (11, '1904 8235 7155 8686', '2027-06-17', 'american express', 'debito', '6137');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (12, '2308 1721 4364 3813', '2025-04-07', 'visa', 'credito', '4132');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (13, '1147 1656 0945 6534', '2029-10-22', 'american express', 'pre-pago', '7990');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (13, '7075 5047 6816 9957', '2025-04-22', 'hipercard', 'credito', '7174');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (14, '8113 1765 3970 5487', '2027-06-07', 'american express', 'debito', '1029');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (14, '0871 8274 9680 4918', '2030-07-05', 'mastercard', 'debito', '4204');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (15, '9561 2137 7306 2604', '2027-01-19', 'mastercard', 'debito', '9737');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (16, '1122 2990 7756 0858', '2026-03-12', 'hipercard', 'debito', '0468');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (17, '6111 4576 8321 0219', '2027-02-05', 'mastercard', 'debito', '8584');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (18, '7129 6180 3324 2605', '2025-09-03', 'american express', 'credito', '1849');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (18, '8042 5373 3777 3126', '2025-10-18', 'mastercard', 'pre-pago', '2821');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (19, '7819 2365 3460 6056', '2025-04-24', 'mastercard', 'pre-pago', '5679');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (20, '3279 8623 9847 1690', '2029-09-06', 'visa', 'pre-pago', '1205');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (21, '4647 5489 5478 7698', '2026-07-17', 'hipercard', 'debito', '1758');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (21, '8914 4449 8355 3935', '2028-06-08', 'mastercard', 'debito', '8644');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (22, '9639 2435 8853 7982', '2026-04-26', 'elo', 'pre-pago', '3395');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (23, '2753 6749 7852 4914', '2026-05-25', 'hipercard', 'pre-pago', '6013');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (24, '4778 9489 6340 6791', '2030-05-06', 'hipercard', 'debito', '5122');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (25, '1500 1418 8421 6309', '2025-09-03', 'visa', 'credito', '5944');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (26, '6333 9994 8532 0895', '2027-06-20', 'mastercard', 'debito', '3890');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (27, '2199 4711 3633 7922', '2027-06-22', 'elo', 'credito', '0346');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (27, '9967 3311 6772 6960', '2028-01-18', 'mastercard', 'pre-pago', '7685');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (28, '5078 9679 3521 9626', '2027-04-29', 'mastercard', 'debito', '5643');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (29, '4369 7093 1706 9556', '2025-03-25', 'hipercard', 'debito', '7616');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (29, '4534 5472 2398 9830', '2029-04-12', 'elo', 'credito', '3121');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (30, '9804 1847 2426 4236', '2028-06-30', 'mastercard', 'pre-pago', '1319');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (31, '0924 8762 3039 1114', '2027-01-03', 'american express', 'credito', '7852');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (32, '2823 0524 8088 0622', '2025-07-18', 'hipercard', 'credito', '2395');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (32, '9473 7213 2901 6204', '2030-03-03', 'american express', 'debito', '6886');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (33, '8785 9964 8628 7203', '2025-10-28', 'american express', 'debito', '4196');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (33, '6645 0573 0362 7924', '2029-06-12', 'mastercard', 'credito', '0374');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (34, '7677 5372 6032 1450', '2028-12-06', 'hipercard', 'debito', '6194');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (35, '5887 0715 5348 2012', '2028-01-10', 'visa', 'credito', '8385');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (35, '0765 9759 5450 8917', '2030-06-20', 'hipercard', 'pre-pago', '0898');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (36, '1265 7422 3196 4630', '2025-06-30', 'elo', 'credito', '2369');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (36, '3626 8943 0120 4713', '2030-04-03', 'mastercard', 'pre-pago', '7117');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (37, '5957 4988 5582 9849', '2027-10-02', 'mastercard', 'credito', '6745');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (38, '8476 0944 1283 3372', '2026-02-08', 'american express', 'pre-pago', '5666');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (39, '9541 3297 1506 6626', '2030-04-23', 'visa', 'debito', '5143');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (40, '7769 3663 4392 5295', '2029-03-24', 'visa', 'credito', '1102');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (41, '8671 2007 2024 5591', '2025-06-15', 'mastercard', 'debito', '5109');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (42, '1090 3267 1494 9819', '2028-03-11', 'mastercard', 'credito', '7942');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (42, '8179 3406 5277 5844', '2029-07-01', 'hipercard', 'credito', '4533');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (43, '7220 1091 2172 2145', '2028-08-03', 'american express', 'credito', '7661');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (44, '8943 7052 6351 0046', '2027-02-04', 'hipercard', 'debito', '6572');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (45, '5659 2024 6175 2023', '2030-10-02', 'american express', 'debito', '4326');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (46, '0055 9550 1783 3258', '2028-01-26', 'american express', 'debito', '8999');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (46, '3607 9848 7045 0691', '2030-04-28', 'hipercard', 'debito', '9935');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (47, '9374 4039 4640 8303', '2030-01-15', 'mastercard', 'debito', '0601');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (48, '4886 0849 0793 8841', '2027-08-20', 'hipercard', 'pre-pago', '5283');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (48, '0615 3701 2424 4626', '2027-04-16', 'mastercard', 'debito', '1448');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (49, '8112 1031 4217 5188', '2030-03-21', 'american express', 'credito', '7941');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (50, '5152 6384 0911 2252', '2030-11-09', 'american express', 'credito', '7505');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (51, '6618 6323 9791 3787', '2029-05-06', 'elo', 'pre-pago', '5300');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (52, '7309 5055 6057 1219', '2030-11-03', 'american express', 'credito', '9277');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (53, '8851 9053 4864 0104', '2026-07-15', 'elo', 'debito', '2456');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (53, '1851 7446 0045 2128', '2026-02-15', 'elo', 'credito', '1455');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (54, '1293 9130 4488 1898', '2028-05-02', 'american express', 'pre-pago', '4160');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (55, '4615 4021 1901 7075', '2029-07-21', 'american express', 'credito', '4298');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (56, '3152 2910 7322 8360', '2030-11-13', 'elo', 'pre-pago', '3783');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (56, '0639 6384 5269 6944', '2027-10-18', 'american express', 'credito', '6497');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (57, '0169 3429 2913 2033', '2025-07-10', 'visa', 'pre-pago', '6234');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (58, '1903 1061 5372 2155', '2029-08-11', 'hipercard', 'pre-pago', '8473');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (59, '2365 3377 4604 0672', '2025-09-09', 'visa', 'pre-pago', '7843');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (60, '6142 4426 0781 9754', '2027-07-08', 'hipercard', 'credito', '4764');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (60, '2737 2037 6388 2145', '2030-11-09', 'elo', 'pre-pago', '1484');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (61, '6019 1344 3899 8278', '2025-01-14', 'mastercard', 'credito', '5869');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (62, '5073 2146 4493 6999', '2029-01-01', 'visa', 'debito', '7933');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (63, '5055 7385 7368 0119', '2026-07-16', 'mastercard', 'debito', '0376');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (64, '8118 7233 3510 4096', '2026-05-08', 'elo', 'pre-pago', '9731');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (64, '5391 1498 3074 8207', '2027-06-06', 'hipercard', 'debito', '1189');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (65, '3940 6557 8201 9043', '2026-12-06', 'mastercard', 'credito', '0233');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (66, '3247 0739 2013 5462', '2025-09-17', 'mastercard', 'debito', '6025');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (66, '0826 1123 1261 6324', '2030-11-01', 'american express', 'pre-pago', '8995');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (67, '7298 9376 2974 5493', '2025-03-24', 'mastercard', 'debito', '4687');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (68, '1912 0381 8769 2082', '2027-08-08', 'mastercard', 'credito', '0898');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (68, '1388 1588 1445 8220', '2029-10-18', 'hipercard', 'credito', '2318');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (69, '2971 6815 7245 0000', '2025-04-10', 'visa', 'credito', '5291');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (70, '1371 7850 9025 5618', '2028-04-02', 'elo', 'debito', '2182');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (71, '9987 4781 2248 9056', '2030-04-05', 'visa', 'pre-pago', '6700');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (72, '9004 3655 1584 8266', '2026-05-19', 'mastercard', 'debito', '2483');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (72, '5505 4296 0807 0633', '2029-08-08', 'american express', 'pre-pago', '8795');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (73, '0982 2104 0164 8188', '2025-01-21', 'elo', 'pre-pago', '4287');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (73, '7383 6381 6432 1269', '2028-04-23', 'mastercard', 'pre-pago', '9464');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (74, '2036 2586 3144 1706', '2028-04-09', 'hipercard', 'credito', '5540');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (75, '2635 5824 3017 6464', '2028-04-05', 'american express', 'pre-pago', '8803');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (76, '1538 8824 5279 0504', '2025-08-24', 'elo', 'credito', '3335');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (77, '3849 5163 2111 9787', '2026-05-22', 'american express', 'credito', '9339');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (78, '1373 2653 0601 1987', '2028-09-03', 'hipercard', 'credito', '7868');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (78, '8002 3009 1561 8298', '2025-02-23', 'mastercard', 'pre-pago', '6577');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (79, '4491 6093 6595 2014', '2025-10-18', 'visa', 'pre-pago', '9418');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (80, '4336 8750 9263 2239', '2030-09-03', 'mastercard', 'credito', '3745');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (80, '5611 4042 8860 5053', '2030-07-10', 'hipercard', 'debito', '6081');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (81, '1260 0308 3566 9106', '2026-09-23', 'hipercard', 'credito', '5312');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (82, '3455 0688 2691 7768', '2026-08-08', 'american express', 'credito', '8440');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (82, '1348 0873 5437 8826', '2025-07-08', 'mastercard', 'credito', '5910');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (83, '1570 9085 9914 4920', '2030-01-30', 'elo', 'pre-pago', '2699');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (84, '9699 6489 9718 4285', '2029-04-23', 'american express', 'credito', '2591');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (84, '4084 9932 3123 4266', '2025-08-13', 'hipercard', 'pre-pago', '0872');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (85, '6176 0723 4838 9359', '2029-01-21', 'mastercard', 'pre-pago', '2804');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (86, '0561 2996 5082 6958', '2026-08-24', 'hipercard', 'pre-pago', '4186');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (87, '9656 1308 7612 3859', '2028-10-11', 'visa', 'debito', '3468');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (88, '2394 8400 2730 0869', '2029-05-20', 'hipercard', 'credito', '0168');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (89, '3113 9500 1680 9414', '2025-10-27', 'elo', 'credito', '7628');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (90, '3976 2053 4407 7794', '2029-05-20', 'mastercard', 'credito', '7266');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (91, '2925 0817 7602 9914', '2025-04-04', 'hipercard', 'pre-pago', '8413');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (92, '3373 1255 2356 1781', '2030-03-17', 'visa', 'credito', '2119');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (92, '2061 3638 5277 8956', '2026-05-12', 'mastercard', 'credito', '7184');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (93, '4490 2950 2648 0164', '2028-03-12', 'visa', 'credito', '7341');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (94, '6781 2778 2210 2179', '2027-01-18', 'visa', 'pre-pago', '3486');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (95, '2985 7973 6383 1828', '2028-07-28', 'hipercard', 'credito', '5397');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (96, '0798 6617 7067 3682', '2025-03-05', 'elo', 'credito', '6821');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (97, '2235 5216 5058 7146', '2026-09-08', 'visa', 'pre-pago', '2192');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (98, '5967 9089 8436 9984', '2025-03-08', 'mastercard', 'credito', '0509');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (99, '3869 4842 4959 8811', '2028-03-07', 'elo', 'debito', '8870');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (100, '7152 3867 6738 2097', '2028-01-31', 'hipercard', 'credito', '9177');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (101, '9876 8299 6872 2589', '2027-03-15', 'hipercard', 'pre-pago', '0858');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (102, '0623 5040 5669 5790', '2025-05-06', 'visa', 'credito', '4825');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (102, '5442 8679 6325 9423', '2026-06-30', 'american express', 'pre-pago', '9463');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (103, '3891 5624 1528 5725', '2029-05-13', 'mastercard', 'pre-pago', '2693');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (104, '3589 5138 1865 5078', '2027-12-13', 'hipercard', 'pre-pago', '5095');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (105, '7443 0349 1891 1797', '2026-11-07', 'visa', 'credito', '8593');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (106, '4015 3641 5471 5531', '2027-06-07', 'mastercard', 'debito', '9367');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (107, '8136 7500 9421 4105', '2026-12-28', 'hipercard', 'debito', '9819');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (107, '8780 9270 4523 8885', '2029-07-06', 'mastercard', 'credito', '5866');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (108, '0598 6787 4422 7585', '2028-02-20', 'american express', 'pre-pago', '5965');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (109, '5942 8249 1165 0200', '2025-06-25', 'mastercard', 'debito', '5393');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (110, '1321 5513 0557 0836', '2027-01-17', 'visa', 'debito', '4488');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (111, '9669 9727 3677 4620', '2026-06-16', 'elo', 'pre-pago', '2543');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (112, '1832 8123 1239 2049', '2026-01-15', 'visa', 'debito', '0183');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (113, '6472 3875 0827 6817', '2026-12-26', 'mastercard', 'debito', '7754');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (114, '5847 2629 0529 1876', '2027-09-15', 'visa', 'debito', '0827');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (115, '1721 7337 3992 0522', '2026-09-28', 'american express', 'pre-pago', '9362');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (116, '1659 1438 8232 5539', '2027-04-13', 'elo', 'pre-pago', '4461');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (117, '7773 2643 0954 4979', '2026-04-23', 'mastercard', 'debito', '9970');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (117, '2927 1205 3978 7137', '2028-08-31', 'mastercard', 'pre-pago', '8832');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (118, '2012 5608 3200 4879', '2030-03-23', 'american express', 'pre-pago', '8975');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (119, '3585 2386 0030 4436', '2025-12-02', 'american express', 'pre-pago', '5171');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (120, '5239 1029 2950 1437', '2028-02-10', 'american express', 'credito', '0930');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (121, '9671 3971 9126 0221', '2027-04-29', 'mastercard', 'credito', '7672');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (121, '0191 1166 1220 1907', '2026-07-12', 'elo', 'pre-pago', '8733');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (122, '9304 9366 5380 2748', '2026-03-01', 'mastercard', 'debito', '2114');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (123, '0868 2509 5229 4620', '2027-03-05', 'elo', 'debito', '6103');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (123, '9952 9701 3712 4365', '2028-08-30', 'american express', 'debito', '6423');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (124, '0412 0270 6159 2738', '2030-07-20', 'elo', 'credito', '2990');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (125, '7166 9063 2248 1554', '2026-10-12', 'visa', 'credito', '4030');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (126, '1095 6797 5649 1579', '2028-11-26', 'elo', 'debito', '6234');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (127, '7124 7601 0801 8103', '2025-04-20', 'hipercard', 'pre-pago', '3176');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (128, '4172 6808 0815 7129', '2025-05-05', 'visa', 'debito', '0713');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (129, '8067 1307 3510 4584', '2030-07-09', 'elo', 'credito', '6213');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (130, '0096 2588 5766 9470', '2027-04-18', 'visa', 'pre-pago', '0533');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (131, '9627 4666 2159 1832', '2030-04-30', 'visa', 'credito', '0466');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (132, '6145 9011 0797 7140', '2025-03-22', 'elo', 'pre-pago', '3881');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (133, '9490 5315 2049 9809', '2028-05-04', 'american express', 'debito', '6987');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (134, '3137 9716 6984 1661', '2026-09-01', 'mastercard', 'debito', '4077');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (134, '9433 2562 3899 4991', '2030-01-02', 'visa', 'credito', '4262');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (135, '0370 8782 1160 2041', '2025-12-09', 'mastercard', 'debito', '9989');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (136, '8972 1170 8894 8018', '2029-06-23', 'elo', 'debito', '8221');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (137, '7588 3978 5708 2004', '2025-07-11', 'hipercard', 'debito', '5712');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (138, '3691 4961 1287 9429', '2029-10-01', 'american express', 'pre-pago', '2769');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (139, '7040 9531 4196 1560', '2030-07-18', 'american express', 'pre-pago', '3274');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (140, '8835 6517 9624 0964', '2029-03-22', 'hipercard', 'pre-pago', '3496');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (141, '0478 4217 0285 1622', '2028-12-27', 'american express', 'credito', '6488');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (141, '2089 3486 8839 0624', '2029-06-07', 'hipercard', 'credito', '8799');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (142, '1609 1141 3193 5923', '2029-07-27', 'visa', 'credito', '3760');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (142, '5230 4588 1650 2544', '2030-07-23', 'mastercard', 'debito', '1916');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (143, '5034 4096 6177 1824', '2025-06-21', 'american express', 'pre-pago', '0678');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (144, '2141 7468 1359 2664', '2029-09-26', 'american express', 'pre-pago', '8939');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (145, '6987 4869 4155 9450', '2026-03-30', 'visa', 'pre-pago', '2920');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (145, '7536 0511 7160 3988', '2029-06-06', 'mastercard', 'debito', '5362');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (146, '1894 5590 6700 0994', '2026-07-11', 'elo', 'pre-pago', '9420');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (146, '4664 8966 7605 6420', '2028-06-26', 'elo', 'debito', '5775');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (147, '8097 4533 8906 2354', '2029-07-15', 'hipercard', 'credito', '2654');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (148, '0165 9953 0062 2122', '2028-04-19', 'mastercard', 'debito', '6774');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (149, '6259 1601 1241 1584', '2030-12-25', 'american express', 'pre-pago', '6008');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (150, '0179 8677 8231 2995', '2029-12-24', 'visa', 'debito', '7264');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (151, '2612 1203 8437 5365', '2029-04-30', 'american express', 'credito', '7852');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (152, '5482 4218 3854 5400', '2029-10-25', 'elo', 'debito', '5475');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (153, '2311 2327 4897 9177', '2029-06-19', 'mastercard', 'credito', '4272');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (154, '0388 6217 5080 1963', '2025-06-20', 'elo', 'debito', '3069');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (155, '3588 2493 5340 0181', '2029-06-12', 'hipercard', 'debito', '8481');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (156, '6524 4454 4608 3851', '2030-05-01', 'american express', 'pre-pago', '3781');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (157, '0539 1287 8848 6999', '2029-10-10', 'american express', 'pre-pago', '8290');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (158, '4579 2714 7246 3019', '2029-04-11', 'elo', 'credito', '4238');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (159, '3972 8339 1218 7062', '2027-05-11', 'mastercard', 'pre-pago', '8098');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (160, '3221 0102 3200 1867', '2029-11-13', 'hipercard', 'credito', '0089');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (161, '8761 0814 3561 4038', '2028-03-31', 'elo', 'pre-pago', '3198');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (162, '0746 8235 4695 1003', '2025-03-11', 'hipercard', 'debito', '2054');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (162, '5967 1500 6666 4110', '2029-05-29', 'elo', 'debito', '1134');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (163, '0785 1699 4970 8905', '2027-03-09', 'hipercard', 'debito', '8348');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (164, '2689 9962 6970 8386', '2030-11-01', 'american express', 'credito', '7879');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (165, '1505 9625 7197 6093', '2026-06-03', 'visa', 'credito', '2657');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (166, '8982 6041 8095 2175', '2028-10-06', 'american express', 'debito', '1777');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (166, '4127 4692 1188 2419', '2029-07-08', 'mastercard', 'debito', '4222');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (167, '9758 9170 4542 1854', '2029-03-08', 'hipercard', 'credito', '5682');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (168, '0922 5709 0016 3564', '2025-08-05', 'hipercard', 'credito', '3247');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (168, '2828 9540 0178 8224', '2030-01-28', 'mastercard', 'credito', '2616');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (169, '8507 1058 0119 5092', '2030-03-15', 'visa', 'pre-pago', '1526');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (170, '1053 7092 3007 1695', '2025-03-02', 'visa', 'debito', '4189');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (171, '4854 3298 7698 9365', '2026-06-23', 'american express', 'debito', '4716');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (172, '1982 7348 1310 4502', '2028-12-11', 'american express', 'pre-pago', '9632');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (173, '1743 5748 3526 8064', '2029-11-19', 'visa', 'pre-pago', '6739');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (174, '8344 8838 4253 6462', '2025-07-14', 'elo', 'debito', '0774');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (174, '0657 9551 5623 9209', '2025-05-20', 'american express', 'debito', '5107');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (175, '4091 3111 7861 9025', '2028-04-23', 'hipercard', 'pre-pago', '6022');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (176, '0695 3541 2012 2759', '2029-01-03', 'visa', 'credito', '2601');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (176, '5153 2594 7950 7407', '2026-02-14', 'hipercard', 'pre-pago', '3279');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (177, '8059 5031 0064 9340', '2027-04-13', 'american express', 'credito', '0452');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (178, '0360 8941 1849 1359', '2026-12-15', 'american express', 'debito', '5359');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (179, '5205 6100 6799 0069', '2029-10-22', 'american express', 'credito', '1867');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (180, '7403 7842 3394 4953', '2025-03-26', 'visa', 'debito', '7762');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (181, '5503 2501 7365 4262', '2028-03-16', 'visa', 'debito', '8429');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (182, '0292 3345 1100 9060', '2028-12-29', 'mastercard', 'credito', '8868');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (183, '4302 1166 7329 0457', '2028-09-30', 'american express', 'pre-pago', '8759');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (183, '2129 9642 6033 6202', '2030-02-18', 'elo', 'debito', '8214');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (184, '7709 2071 1523 8023', '2029-11-03', 'mastercard', 'credito', '9215');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (185, '8189 7059 1611 8638', '2029-03-02', 'elo', 'pre-pago', '8195');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (185, '9772 1688 0053 7893', '2025-10-03', 'american express', 'debito', '9289');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (186, '7284 5401 8227 2002', '2027-05-26', 'american express', 'debito', '8232');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (187, '2041 4474 3281 1659', '2027-03-15', 'visa', 'pre-pago', '2020');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (188, '3042 3227 7521 3530', '2026-06-20', 'american express', 'credito', '6506');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (189, '4630 0593 7775 6919', '2027-07-08', 'mastercard', 'credito', '0291');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (189, '6174 6902 9831 0438', '2028-02-05', 'visa', 'pre-pago', '6622');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (190, '9131 6708 0568 5667', '2025-06-16', 'hipercard', 'credito', '6219');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (191, '8655 0494 4407 6634', '2027-02-12', 'mastercard', 'pre-pago', '6504');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (192, '9627 3226 2611 4243', '2029-08-11', 'mastercard', 'pre-pago', '5854');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (193, '2188 0879 9196 2341', '2029-04-07', 'elo', 'credito', '3853');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (193, '2472 5058 3334 3031', '2025-11-19', 'elo', 'pre-pago', '8760');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (194, '5457 6947 5769 4535', '2027-09-10', 'hipercard', 'debito', '9746');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (195, '6986 1634 2125 4508', '2025-02-02', 'american express', 'debito', '9481');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (196, '5269 2559 6647 2130', '2030-01-31', 'elo', 'credito', '3591');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (197, '4261 4048 9332 6145', '2028-06-19', 'mastercard', 'pre-pago', '0796');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (198, '3731 0081 7852 2115', '2030-01-04', 'visa', 'pre-pago', '4523');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (199, '5426 8744 7017 3208', '2029-08-11', 'elo', 'pre-pago', '2377');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (200, '7296 6563 3701 4005', '2026-09-17', 'hipercard', 'pre-pago', '1055');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (201, '8000 2722 1425 7316', '2025-04-19', 'american express', 'debito', '3913');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (202, '6817 2031 3695 5286', '2026-12-22', 'visa', 'pre-pago', '2973');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (203, '5259 5332 2273 9389', '2026-12-15', 'visa', 'debito', '5735');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (203, '3236 6185 0761 0870', '2030-09-26', 'mastercard', 'debito', '9718');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (204, '2360 1071 2615 8388', '2027-01-20', 'visa', 'debito', '6484');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (205, '6735 7422 3322 2801', '2028-04-11', 'elo', 'credito', '5892');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (206, '2256 0629 5350 6373', '2025-10-01', 'visa', 'pre-pago', '0467');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (206, '4130 7538 4185 2013', '2029-04-28', 'mastercard', 'debito', '0846');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (207, '3975 6154 7055 4912', '2025-10-03', 'elo', 'credito', '6411');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (208, '9556 4091 9693 9578', '2030-07-28', 'elo', 'credito', '0702');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (209, '0426 2019 7121 2413', '2027-09-25', 'hipercard', 'pre-pago', '6789');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (210, '7609 8731 2677 3192', '2026-06-25', 'hipercard', 'pre-pago', '6075');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (211, '9889 7865 3394 3191', '2029-04-15', 'elo', 'debito', '3089');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (212, '5231 2021 9150 5764', '2028-03-04', 'american express', 'pre-pago', '7470');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (212, '0026 8764 4867 6497', '2030-01-18', 'elo', 'credito', '6365');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (213, '6045 0063 5537 3096', '2028-01-21', 'american express', 'debito', '9277');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (214, '1195 2963 5305 9702', '2029-02-16', 'elo', 'credito', '2827');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (214, '6364 3159 4898 9596', '2028-11-29', 'elo', 'debito', '6345');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (215, '4434 4149 1699 9393', '2027-11-25', 'elo', 'pre-pago', '7439');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (216, '4640 8822 3095 8629', '2030-05-08', 'mastercard', 'pre-pago', '8894');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (217, '1321 0972 0217 0754', '2030-10-26', 'elo', 'credito', '4655');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (218, '7922 0300 4496 4612', '2027-07-05', 'american express', 'credito', '0251');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (219, '2137 5658 9635 9570', '2029-10-29', 'visa', 'pre-pago', '9314');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (220, '5843 4566 3113 8850', '2027-04-19', 'elo', 'credito', '3622');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (221, '0334 7424 6310 4379', '2029-08-30', 'american express', 'pre-pago', '6800');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (222, '8529 4690 2177 4174', '2027-02-11', 'visa', 'debito', '3502');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (223, '3850 2289 4665 2752', '2027-03-26', 'mastercard', 'credito', '8293');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (223, '0202 5691 3303 0334', '2029-07-31', 'hipercard', 'debito', '1167');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (224, '5076 2799 5530 2453', '2025-08-18', 'visa', 'credito', '3984');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (225, '7230 3420 2847 1901', '2030-02-04', 'mastercard', 'credito', '2405');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (226, '0764 8717 7546 1992', '2027-12-17', 'visa', 'debito', '5838');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (227, '7272 5812 2590 9566', '2030-12-27', 'elo', 'pre-pago', '4823');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (228, '7337 9121 2110 1878', '2025-06-21', 'mastercard', 'pre-pago', '5869');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (229, '0170 7403 9251 9994', '2028-12-24', 'mastercard', 'pre-pago', '5171');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (230, '2227 6433 8722 0542', '2026-08-15', 'visa', 'debito', '2654');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (230, '9633 0833 4447 0488', '2030-08-07', 'american express', 'pre-pago', '9504');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (231, '7020 5968 5195 3774', '2027-01-15', 'hipercard', 'debito', '3295');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (232, '6342 7775 2259 2061', '2029-06-24', 'elo', 'pre-pago', '1292');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (233, '0592 2941 1563 0295', '2028-07-17', 'american express', 'debito', '3637');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (233, '2629 4206 6154 9808', '2028-10-23', 'visa', 'credito', '3138');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (234, '0049 8321 1221 2154', '2030-09-26', 'visa', 'pre-pago', '5826');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (234, '8687 6401 9185 4880', '2029-05-15', 'elo', 'debito', '2006');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (235, '2987 7873 5856 6464', '2026-05-02', 'american express', 'debito', '2342');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (236, '1926 2213 2041 0429', '2027-11-03', 'american express', 'credito', '1478');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (237, '9117 9726 9999 4981', '2026-10-21', 'american express', 'pre-pago', '3180');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (238, '0366 6020 0053 2853', '2029-06-11', 'mastercard', 'credito', '0505');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (239, '2438 3805 8269 2990', '2025-09-02', 'hipercard', 'debito', '8627');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (240, '6332 8389 6337 6185', '2026-04-13', 'american express', 'debito', '2671');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (241, '3684 1013 2823 3921', '2030-09-13', 'mastercard', 'debito', '2791');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (242, '8750 6776 1065 9208', '2030-11-11', 'visa', 'pre-pago', '4319');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (243, '2797 6178 1596 9838', '2028-05-09', 'elo', 'pre-pago', '7202');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (244, '6656 8629 5912 5734', '2030-09-09', 'american express', 'pre-pago', '2553');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (245, '9460 7429 9074 7296', '2029-09-29', 'american express', 'debito', '1799');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (245, '6708 0897 4748 5994', '2029-07-20', 'elo', 'credito', '8398');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (246, '4167 3478 5369 8816', '2028-04-14', 'american express', 'pre-pago', '0445');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (247, '0928 6052 1026 2706', '2029-06-28', 'elo', 'pre-pago', '9008');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (248, '2484 5813 0889 8305', '2030-05-31', 'elo', 'pre-pago', '8839');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (249, '9741 8563 0275 0003', '2025-07-08', 'elo', 'pre-pago', '6619');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (250, '9530 5641 8493 7846', '2030-01-13', 'american express', 'credito', '8701');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (251, '8726 0013 6510 3444', '2027-10-30', 'mastercard', 'pre-pago', '9067');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (252, '4568 6524 0622 1559', '2029-11-22', 'hipercard', 'credito', '5622');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (253, '2190 5334 7047 4764', '2028-03-27', 'elo', 'debito', '9396');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (253, '5213 8350 7124 5531', '2026-11-12', 'american express', 'credito', '0362');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (254, '2117 3277 2648 8395', '2028-08-07', 'elo', 'pre-pago', '5229');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (255, '4252 5161 8575 9171', '2025-08-13', 'elo', 'credito', '8054');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (255, '9147 7447 3535 2478', '2028-04-26', 'visa', 'debito', '1594');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (256, '9734 4930 5378 8033', '2026-05-27', 'american express', 'credito', '6113');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (257, '3892 6087 8828 1527', '2030-05-01', 'mastercard', 'credito', '4862');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (258, '5152 1746 5353 7801', '2030-09-28', 'american express', 'credito', '5673');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (259, '4467 1776 2969 1433', '2029-06-11', 'mastercard', 'pre-pago', '9946');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (260, '6450 9999 0010 8985', '2030-05-19', 'mastercard', 'pre-pago', '0835');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (261, '2118 9684 4246 4884', '2030-02-19', 'american express', 'debito', '7285');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (262, '7595 8281 9022 1797', '2025-10-31', 'mastercard', 'debito', '8839');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (262, '7170 5984 4514 3672', '2030-11-13', 'hipercard', 'pre-pago', '1123');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (263, '0388 5681 1939 7814', '2028-10-10', 'american express', 'credito', '0992');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (264, '1779 0552 8669 3351', '2028-07-06', 'american express', 'pre-pago', '0705');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (265, '3260 1193 9103 8297', '2028-06-13', 'mastercard', 'pre-pago', '5513');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (266, '6090 8581 8104 5024', '2027-05-20', 'hipercard', 'credito', '6158');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (267, '7366 2713 5896 9335', '2027-09-19', 'american express', 'credito', '0585');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (268, '6154 7315 6639 7925', '2028-11-21', 'visa', 'credito', '6436');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (268, '9028 3772 7028 9666', '2025-01-20', 'elo', 'credito', '4281');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (269, '6441 6101 9753 5846', '2027-12-24', 'visa', 'debito', '1038');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (269, '8027 3042 7636 2814', '2027-11-28', 'elo', 'debito', '1893');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (270, '9530 9690 6764 9092', '2026-12-11', 'american express', 'pre-pago', '4987');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (271, '4551 3587 2717 4306', '2026-05-06', 'visa', 'debito', '4034');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (272, '3988 1873 8775 8333', '2029-07-16', 'elo', 'debito', '7041');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (273, '3090 9153 8602 8262', '2028-11-29', 'elo', 'credito', '0412');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (274, '3190 5772 0441 0079', '2028-01-20', 'visa', 'pre-pago', '3245');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (275, '3810 9794 1224 8709', '2030-04-29', 'mastercard', 'pre-pago', '6496');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (276, '3225 1742 2404 3261', '2026-03-18', 'american express', 'pre-pago', '0034');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (277, '6861 6307 0286 7202', '2025-05-24', 'visa', 'pre-pago', '5366');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (278, '2195 3689 0057 7950', '2025-09-03', 'visa', 'debito', '3259');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (279, '0073 9713 0722 1138', '2029-04-09', 'american express', 'credito', '8716');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (280, '7221 0454 6171 9281', '2030-04-26', 'visa', 'debito', '4436');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (280, '0234 4225 2160 2523', '2028-01-11', 'visa', 'credito', '0944');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (281, '7726 9032 6551 3276', '2025-11-20', 'hipercard', 'pre-pago', '4802');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (281, '4559 8516 0211 9158', '2026-01-08', 'mastercard', 'debito', '8649');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (282, '8647 8686 2376 0088', '2028-01-08', 'elo', 'debito', '4083');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (282, '7819 1907 4992 1640', '2025-07-26', 'hipercard', 'pre-pago', '8369');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (283, '2353 4848 6470 8213', '2030-12-02', 'hipercard', 'debito', '4622');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (283, '0212 3720 5503 3000', '2025-03-16', 'american express', 'pre-pago', '6346');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (284, '7391 9008 8991 1416', '2025-01-11', 'visa', 'pre-pago', '1692');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (285, '3273 7989 7906 0854', '2025-12-03', 'american express', 'debito', '7463');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (286, '0009 9843 3611 3711', '2030-11-14', 'visa', 'debito', '1985');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (286, '4582 9420 3401 5353', '2028-02-12', 'hipercard', 'debito', '0756');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (287, '9994 4946 6720 1082', '2027-12-30', 'visa', 'credito', '8182');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (288, '2387 9402 6208 5817', '2027-12-10', 'elo', 'credito', '7353');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (289, '6423 5700 4129 1828', '2028-09-21', 'visa', 'pre-pago', '1612');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (290, '5590 4610 0792 3046', '2029-07-31', 'visa', 'credito', '1283');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (290, '8271 0123 2961 5120', '2027-12-20', 'american express', 'pre-pago', '5076');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (291, '6534 4604 2276 3460', '2026-03-15', 'american express', 'credito', '5305');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (292, '7347 2435 8617 6822', '2028-07-25', 'visa', 'pre-pago', '2726');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (292, '7086 6656 2241 9768', '2029-12-16', 'american express', 'debito', '9477');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (293, '1290 3500 6184 8974', '2026-08-20', 'mastercard', 'credito', '5434');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (294, '0466 8212 1564 9525', '2027-11-18', 'american express', 'credito', '0644');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (295, '1119 7388 1827 3063', '2028-06-10', 'mastercard', 'debito', '9488');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (296, '2188 4968 0664 0511', '2025-06-29', 'mastercard', 'credito', '2543');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (297, '4123 0160 4986 0372', '2026-02-16', 'american express', 'debito', '0032');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (298, '0319 7899 9011 4003', '2028-05-04', 'hipercard', 'credito', '3171');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (299, '9786 0162 5908 4194', '2030-03-27', 'american express', 'debito', '5011');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (300, '3753 5821 0728 8780', '2030-04-16', 'mastercard', 'debito', '9037');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (301, '1616 0881 9722 3996', '2027-10-27', 'hipercard', 'debito', '1837');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (301, '5307 6810 2480 8557', '2030-08-13', 'visa', 'credito', '2443');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (302, '2362 2169 0696 8574', '2029-06-20', 'hipercard', 'credito', '6751');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (303, '6913 9521 5016 4261', '2025-01-19', 'hipercard', 'credito', '3350');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (304, '8424 3198 3924 8481', '2027-06-22', 'visa', 'credito', '4169');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (305, '1053 0215 1675 8646', '2027-10-01', 'mastercard', 'pre-pago', '9534');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (306, '8110 5014 7642 7896', '2026-05-16', 'elo', 'debito', '3855');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (307, '1281 7751 2395 9781', '2028-10-30', 'elo', 'debito', '2609');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (308, '7236 0244 6546 7720', '2029-01-06', 'visa', 'debito', '1073');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (309, '0871 5647 8370 3175', '2028-06-11', 'mastercard', 'pre-pago', '0274');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (310, '1485 7260 2925 4686', '2026-08-28', 'hipercard', 'credito', '8840');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (311, '7664 2076 3271 3538', '2029-07-01', 'hipercard', 'debito', '2592');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (311, '3868 7906 0488 6932', '2025-08-24', 'elo', 'debito', '3405');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (312, '0892 7396 1597 6405', '2027-02-25', 'elo', 'debito', '7078');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (313, '9775 5426 1903 8422', '2030-05-08', 'mastercard', 'debito', '2732');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (314, '0222 7111 7576 9171', '2029-09-29', 'mastercard', 'credito', '4298');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (314, '5144 8698 3052 1690', '2027-04-30', 'american express', 'credito', '2026');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (315, '9801 4264 7106 8017', '2030-03-18', 'visa', 'credito', '1637');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (316, '0500 4933 2672 4469', '2027-07-06', 'visa', 'debito', '2947');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (317, '6380 8390 6540 2599', '2028-08-24', 'visa', 'pre-pago', '9393');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (318, '2727 2812 9163 5049', '2029-10-25', 'visa', 'credito', '6676');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (319, '5272 8453 9749 9507', '2025-01-03', 'american express', 'pre-pago', '6406');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (320, '7560 2080 1929 0221', '2029-03-02', 'elo', 'credito', '9044');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (321, '8909 3225 3332 0235', '2025-10-03', 'visa', 'credito', '5550');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (322, '1935 4503 6988 8439', '2027-03-05', 'mastercard', 'credito', '2436');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (322, '2962 0805 9831 2441', '2026-10-25', 'american express', 'credito', '7596');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (323, '5999 2012 3763 1774', '2029-03-03', 'elo', 'credito', '1062');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (324, '9419 3759 1922 6713', '2026-02-14', 'hipercard', 'debito', '3626');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (325, '4752 8646 1209 6173', '2025-04-19', 'visa', 'pre-pago', '9284');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (326, '5240 3211 5355 0514', '2027-05-10', 'mastercard', 'credito', '9143');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (327, '0877 9724 7925 4221', '2030-08-18', 'american express', 'credito', '4581');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (328, '9204 8770 6769 3332', '2029-10-28', 'elo', 'credito', '5902');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (329, '5784 6408 5858 8382', '2028-08-06', 'hipercard', 'pre-pago', '7262');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (329, '0846 7292 5435 5196', '2026-11-23', 'american express', 'credito', '2250');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (330, '1825 6247 2863 9420', '2026-01-07', 'mastercard', 'credito', '3414');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (330, '9929 0096 6270 2660', '2027-12-11', 'elo', 'credito', '9563');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (331, '2174 0039 1019 3353', '2026-12-29', 'mastercard', 'credito', '4711');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (331, '9360 0608 2770 5646', '2026-03-31', 'hipercard', 'credito', '7626');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (332, '4385 0095 3723 4617', '2029-10-10', 'mastercard', 'credito', '1336');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (333, '1094 4164 2316 5441', '2027-03-17', 'hipercard', 'credito', '7768');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (334, '5760 6349 4290 4617', '2028-09-04', 'elo', 'credito', '8870');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (335, '1799 9324 2024 8374', '2027-12-29', 'elo', 'credito', '7234');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (336, '5653 8694 7902 5485', '2027-07-13', 'hipercard', 'credito', '6890');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (337, '4723 8641 0095 3855', '2030-05-28', 'elo', 'credito', '1643');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (338, '5990 0937 8146 0476', '2026-01-20', 'elo', 'credito', '7884');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (339, '4370 6618 7564 6726', '2027-08-16', 'hipercard', 'pre-pago', '1541');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (340, '8589 9002 7729 1084', '2028-10-02', 'visa', 'pre-pago', '7860');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (341, '4356 6050 3374 6983', '2027-05-16', 'visa', 'debito', '7730');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (342, '6718 2226 6794 1908', '2030-01-26', 'american express', 'pre-pago', '8653');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (343, '8590 6739 6342 8987', '2029-06-26', 'visa', 'pre-pago', '5504');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (344, '9221 7048 6186 7066', '2027-04-24', 'mastercard', 'credito', '1629');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (345, '0739 9289 1982 7182', '2029-09-11', 'elo', 'credito', '3717');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (346, '0864 9426 9420 3983', '2025-12-23', 'mastercard', 'debito', '4901');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (347, '4599 6706 9219 5873', '2025-01-09', 'elo', 'debito', '9824');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (348, '3884 3021 7816 7806', '2029-03-24', 'elo', 'pre-pago', '3158');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (349, '9016 4928 1503 7017', '2025-08-11', 'american express', 'credito', '6407');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (350, '0308 8081 7262 8296', '2026-12-14', 'elo', 'debito', '8500');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (350, '7288 9592 7411 6806', '2026-04-06', 'american express', 'debito', '1276');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (351, '6208 0820 3917 0263', '2027-12-20', 'elo', 'debito', '3596');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (352, '2458 7012 0424 2536', '2025-03-18', 'american express', 'credito', '2375');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (353, '3028 4976 0396 7024', '2027-09-20', 'hipercard', 'debito', '2405');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (354, '5364 8187 5403 6488', '2026-08-25', 'visa', 'debito', '9773');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (355, '8546 6232 3606 6799', '2030-12-07', 'hipercard', 'debito', '9125');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (356, '9497 2204 2986 2269', '2026-06-12', 'visa', 'debito', '6617');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (356, '9962 3569 9929 9833', '2028-08-06', 'american express', 'pre-pago', '7688');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (357, '7779 2560 4134 8208', '2027-10-28', 'american express', 'credito', '1539');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (358, '8391 2260 0014 4076', '2026-08-25', 'american express', 'pre-pago', '1430');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (359, '4913 4103 8975 2872', '2025-05-16', 'american express', 'pre-pago', '8656');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (360, '4224 0592 0823 5309', '2030-06-08', 'hipercard', 'debito', '9194');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (361, '8962 9805 6820 1753', '2025-01-12', 'hipercard', 'pre-pago', '6618');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (362, '6957 2404 3474 1253', '2025-10-25', 'mastercard', 'debito', '9561');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (362, '0077 7321 7503 6192', '2025-07-04', 'mastercard', 'pre-pago', '5999');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (363, '1938 7337 0342 4447', '2028-03-19', 'american express', 'pre-pago', '0476');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (364, '0786 2351 0765 1917', '2025-05-20', 'american express', 'debito', '1732');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (365, '8951 4563 4091 8580', '2028-11-11', 'elo', 'pre-pago', '1157');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (366, '4496 5391 6077 0040', '2027-10-04', 'visa', 'pre-pago', '4541');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (366, '8403 9822 1803 9662', '2025-06-13', 'mastercard', 'pre-pago', '5886');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (367, '4078 8026 5295 1646', '2027-04-27', 'mastercard', 'pre-pago', '3562');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (368, '3039 7440 8806 7089', '2030-06-02', 'visa', 'pre-pago', '2019');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (368, '9184 3113 2661 1584', '2028-10-18', 'american express', 'credito', '5263');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (369, '2119 6047 2205 3970', '2030-05-04', 'hipercard', 'debito', '5447');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (369, '0823 1714 6199 5394', '2029-09-22', 'hipercard', 'debito', '6262');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (370, '3596 0530 2618 4025', '2030-06-15', 'american express', 'debito', '0368');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (371, '6050 6306 6360 5028', '2025-12-26', 'hipercard', 'debito', '0989');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (371, '1039 0912 0302 5209', '2027-12-11', 'elo', 'credito', '3759');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (372, '7953 1926 0098 6027', '2028-11-29', 'hipercard', 'debito', '5449');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (373, '2054 8944 5381 1808', '2026-05-10', 'american express', 'pre-pago', '6558');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (374, '3445 6622 9521 7970', '2028-07-13', 'hipercard', 'debito', '0361');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (375, '6248 6070 4726 6023', '2028-12-18', 'visa', 'debito', '8501');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (376, '5301 7316 7156 0587', '2025-09-11', 'elo', 'credito', '2441');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (377, '3395 4794 0645 3157', '2025-08-11', 'elo', 'pre-pago', '7191');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (378, '8986 6469 3656 1833', '2028-08-13', 'american express', 'debito', '4876');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (379, '8057 0237 7184 3019', '2027-01-31', 'mastercard', 'credito', '9567');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (380, '3332 9732 3964 4028', '2026-07-01', 'elo', 'credito', '2676');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (381, '9924 2773 9238 5202', '2027-09-04', 'mastercard', 'credito', '9140');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (382, '1693 3284 4234 7199', '2030-11-22', 'mastercard', 'pre-pago', '0755');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (383, '1545 2607 5699 9138', '2027-06-25', 'visa', 'credito', '0643');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (384, '3226 2277 7733 1680', '2029-06-20', 'hipercard', 'debito', '7070');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (385, '3850 3605 9529 8424', '2025-12-14', 'visa', 'pre-pago', '7402');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (385, '7406 7582 6762 5906', '2026-10-17', 'visa', 'credito', '3638');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (386, '5646 1497 4597 9318', '2027-06-11', 'american express', 'pre-pago', '9798');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (387, '4914 9860 9955 0493', '2026-08-09', 'hipercard', 'debito', '4322');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (387, '3946 1212 8981 1594', '2028-10-22', 'mastercard', 'debito', '0012');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (388, '7622 3984 7422 5678', '2030-07-07', 'visa', 'pre-pago', '8822');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (388, '3788 7058 4168 0613', '2027-11-13', 'american express', 'pre-pago', '5647');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (389, '9984 6058 6794 9638', '2027-09-16', 'visa', 'pre-pago', '7236');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (390, '1080 9261 6620 1655', '2028-07-29', 'hipercard', 'pre-pago', '8645');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (390, '7865 5575 1247 6400', '2025-08-03', 'hipercard', 'pre-pago', '7586');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (391, '8240 5166 5451 2244', '2027-12-02', 'visa', 'pre-pago', '9974');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (391, '0233 8686 0835 7017', '2025-03-23', 'mastercard', 'debito', '3094');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (392, '4238 6020 5089 8309', '2028-02-13', 'visa', 'credito', '4909');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (393, '6197 9797 2452 8413', '2029-01-25', 'hipercard', 'pre-pago', '4804');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (394, '5073 5674 8095 7394', '2025-03-19', 'elo', 'pre-pago', '8026');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (395, '0294 4203 1589 2584', '2025-03-13', 'hipercard', 'credito', '4203');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (396, '1977 7486 7595 1418', '2029-10-09', 'elo', 'pre-pago', '8230');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (397, '8829 5868 4196 2332', '2029-10-25', 'visa', 'pre-pago', '5869');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (398, '4276 7483 1730 6629', '2027-05-26', 'visa', 'debito', '1817');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (399, '8824 2655 9469 8906', '2026-09-18', 'mastercard', 'credito', '7237');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (400, '1798 9022 3790 0654', '2030-01-10', 'visa', 'pre-pago', '8477');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (401, '9541 7675 5398 1889', '2025-06-12', 'hipercard', 'pre-pago', '3781');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (402, '5915 7908 9458 9626', '2027-05-11', 'american express', 'debito', '8876');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (403, '3802 0761 2396 1219', '2025-04-25', 'elo', 'pre-pago', '1881');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (404, '2988 6182 0706 6901', '2025-07-12', 'hipercard', 'pre-pago', '2372');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (405, '9826 8933 4864 9703', '2028-07-19', 'visa', 'debito', '7578');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (405, '9683 3557 0773 1231', '2028-08-15', 'elo', 'debito', '0570');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (406, '5218 7993 8444 0458', '2027-05-08', 'visa', 'credito', '4147');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (407, '0123 5036 8715 6891', '2025-06-03', 'american express', 'pre-pago', '7797');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (408, '8023 4456 8446 7940', '2027-08-08', 'hipercard', 'pre-pago', '6401');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (409, '6329 5737 8315 9757', '2026-10-19', 'american express', 'pre-pago', '2731');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (410, '8683 0291 5854 2332', '2028-05-14', 'visa', 'debito', '5185');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (411, '4839 6607 3446 7462', '2026-05-17', 'elo', 'pre-pago', '9584');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (412, '1749 1617 0502 2181', '2029-07-15', 'american express', 'pre-pago', '1413');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (413, '4476 0948 3774 0292', '2029-07-18', 'elo', 'pre-pago', '3302');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (414, '6509 9621 8366 7719', '2029-03-27', 'hipercard', 'debito', '6102');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (415, '5634 2022 2349 9801', '2027-05-06', 'hipercard', 'debito', '8367');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (416, '5901 7791 5244 6144', '2025-04-21', 'american express', 'credito', '3351');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (417, '7465 6426 0186 3726', '2027-06-13', 'visa', 'pre-pago', '9569');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (418, '5592 2776 4149 0038', '2028-08-17', 'visa', 'credito', '5513');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (419, '4448 6722 8839 0473', '2027-08-15', 'visa', 'debito', '5461');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (420, '5749 3251 1497 8879', '2028-07-21', 'mastercard', 'credito', '2040');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (421, '9543 7766 1830 8580', '2025-09-02', 'visa', 'pre-pago', '8731');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (422, '4391 5114 3678 6210', '2030-06-14', 'american express', 'credito', '8710');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (423, '9685 6425 7068 0269', '2027-03-22', 'mastercard', 'pre-pago', '1542');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (424, '3060 0230 2865 5052', '2026-11-20', 'elo', 'pre-pago', '1142');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (425, '0667 0151 4599 2016', '2029-10-05', 'mastercard', 'credito', '8222');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (426, '2400 5392 2205 6201', '2025-07-09', 'visa', 'credito', '3484');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (426, '3391 3325 2861 3239', '2027-11-08', 'elo', 'debito', '4523');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (427, '4286 4497 6024 9866', '2027-03-03', 'elo', 'credito', '0953');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (428, '6773 4985 2973 5615', '2026-12-29', 'hipercard', 'debito', '5591');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (429, '4762 5380 9664 1475', '2027-06-17', 'mastercard', 'debito', '9524');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (429, '7466 5353 8962 9853', '2026-09-24', 'elo', 'credito', '6792');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (430, '4157 1276 3835 4346', '2028-09-07', 'american express', 'pre-pago', '6390');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (431, '6168 2497 9399 8161', '2028-12-22', 'mastercard', 'pre-pago', '8116');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (432, '8371 0307 3726 0720', '2026-01-26', 'elo', 'pre-pago', '9678');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (433, '0826 4931 2146 3947', '2029-06-14', 'mastercard', 'debito', '4292');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (434, '6456 3391 7299 4036', '2027-12-11', 'american express', 'pre-pago', '1126');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (435, '6497 1967 0683 3539', '2026-03-31', 'visa', 'credito', '6125');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (436, '9016 3994 9013 3344', '2027-06-02', 'hipercard', 'pre-pago', '6734');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (437, '8140 9841 0167 9301', '2027-10-26', 'american express', 'credito', '1604');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (438, '9910 0420 2886 6168', '2025-05-16', 'visa', 'pre-pago', '9034');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (439, '2134 8548 4203 5316', '2025-09-09', 'hipercard', 'pre-pago', '1791');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (440, '3860 1571 1713 2194', '2025-03-08', 'mastercard', 'debito', '7028');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (441, '8141 1287 4527 1936', '2030-05-06', 'american express', 'debito', '7646');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (442, '3913 8107 4916 1942', '2027-10-19', 'mastercard', 'credito', '5401');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (443, '3153 5069 6261 6845', '2028-10-12', 'mastercard', 'debito', '2741');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (444, '0254 7179 8994 8856', '2029-05-19', 'american express', 'debito', '8993');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (445, '0051 9567 5635 5842', '2027-01-25', 'hipercard', 'pre-pago', '1726');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (445, '6256 5046 0700 1441', '2027-07-01', 'visa', 'debito', '8624');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (446, '0871 0066 8904 1728', '2026-07-31', 'visa', 'debito', '6238');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (447, '1152 2328 2228 2408', '2028-02-12', 'hipercard', 'debito', '2835');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (448, '9994 0041 0847 9135', '2026-02-21', 'visa', 'credito', '5053');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (448, '5722 8920 6415 7809', '2030-03-18', 'american express', 'credito', '0280');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (449, '1041 9453 4195 2814', '2028-03-25', 'hipercard', 'pre-pago', '6742');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (450, '8021 8893 0635 7803', '2030-03-19', 'american express', 'pre-pago', '1213');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (451, '9743 6990 5585 5759', '2028-06-07', 'visa', 'pre-pago', '4290');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (451, '6969 0452 8986 0610', '2029-05-11', 'elo', 'debito', '7337');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (452, '4570 1652 7613 6814', '2025-08-28', 'mastercard', 'debito', '3084');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (453, '3769 9296 4447 7250', '2030-12-18', 'elo', 'pre-pago', '2324');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (453, '2348 0041 7241 5536', '2026-03-19', 'elo', 'pre-pago', '5574');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (454, '9062 7960 2425 7033', '2027-06-27', 'mastercard', 'pre-pago', '5945');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (455, '2315 8286 3040 2966', '2027-01-23', 'american express', 'pre-pago', '1721');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (456, '7429 2204 1678 2153', '2026-12-23', 'hipercard', 'debito', '9370');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (457, '6325 0313 9280 4850', '2027-01-28', 'mastercard', 'credito', '6190');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (458, '1933 3593 7971 9000', '2025-03-30', 'mastercard', 'pre-pago', '9561');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (459, '6225 6471 8559 4079', '2026-08-08', 'mastercard', 'credito', '4532');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (460, '3167 7814 5647 4370', '2026-04-30', 'american express', 'debito', '5391');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (461, '1776 6650 5276 1209', '2026-10-18', 'american express', 'credito', '5780');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (462, '6190 2231 1678 7067', '2029-10-18', 'mastercard', 'debito', '3223');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (463, '7185 9212 6848 5637', '2025-12-10', 'visa', 'debito', '2943');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (464, '0003 7539 8923 1324', '2029-11-27', 'elo', 'pre-pago', '8669');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (465, '3278 4178 3765 9153', '2030-11-16', 'mastercard', 'credito', '1140');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (466, '6526 6426 7351 2724', '2028-07-18', 'elo', 'credito', '3756');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (467, '5697 6487 8496 2249', '2028-03-25', 'elo', 'credito', '0462');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (467, '5069 2965 6851 2062', '2030-01-07', 'hipercard', 'pre-pago', '7293');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (468, '5097 9344 2129 1465', '2025-01-18', 'mastercard', 'credito', '3477');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (468, '8045 7972 5184 0703', '2027-08-01', 'american express', 'pre-pago', '2147');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (469, '8233 7209 4516 7670', '2029-06-08', 'mastercard', 'debito', '3286');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (469, '3011 2200 8484 2648', '2027-04-14', 'mastercard', 'credito', '6796');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (470, '0828 9671 3605 4946', '2026-06-30', 'visa', 'pre-pago', '5649');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (471, '0132 4951 9350 0115', '2028-04-10', 'hipercard', 'credito', '7580');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (472, '8038 8904 4104 0431', '2028-11-28', 'hipercard', 'debito', '8513');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (473, '5381 4837 4755 8030', '2025-02-19', 'visa', 'debito', '8564');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (474, '7177 8401 9027 1698', '2027-04-17', 'hipercard', 'pre-pago', '1611');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (475, '5866 8611 9976 7598', '2027-04-08', 'mastercard', 'credito', '6170');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (476, '5058 3534 5819 5657', '2026-09-07', 'american express', 'debito', '3533');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (477, '9982 4266 2177 5801', '2028-09-14', 'american express', 'debito', '6687');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (478, '9303 0285 3272 7669', '2027-06-29', 'elo', 'debito', '1502');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (479, '5285 4613 0873 0897', '2026-05-28', 'visa', 'pre-pago', '7382');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (480, '7777 1184 2527 8630', '2025-09-09', 'visa', 'debito', '1210');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (480, '2423 4473 0577 7196', '2026-05-08', 'american express', 'pre-pago', '7165');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (481, '9656 6764 0996 8334', '2027-12-26', 'visa', 'credito', '9522');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (482, '4265 3793 2219 1439', '2025-02-24', 'hipercard', 'credito', '5473');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (482, '6015 7911 5010 1626', '2025-02-06', 'visa', 'pre-pago', '0265');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (483, '8934 7597 8335 4883', '2029-01-07', 'hipercard', 'credito', '9214');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (484, '9679 1463 8664 3203', '2026-01-11', 'hipercard', 'pre-pago', '2665');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (485, '2824 6854 9272 4000', '2026-08-02', 'visa', 'pre-pago', '6014');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (486, '6051 9085 4327 1630', '2027-03-23', 'mastercard', 'debito', '6369');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (487, '3010 0090 8993 1878', '2026-04-12', 'visa', 'debito', '8028');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (487, '3541 5892 9093 0437', '2029-09-05', 'hipercard', 'credito', '3662');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (488, '8081 2268 1594 7470', '2028-11-24', 'mastercard', 'credito', '1058');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (489, '3309 6739 7984 2189', '2026-05-27', 'elo', 'credito', '6937');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (490, '6501 6767 1877 6288', '2027-06-07', 'hipercard', 'credito', '6885');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (490, '0162 7629 2266 6788', '2025-02-15', 'american express', 'pre-pago', '3761');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (491, '6522 8989 0749 9359', '2026-03-11', 'mastercard', 'debito', '5977');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (492, '7265 9764 0838 5805', '2025-05-01', 'visa', 'pre-pago', '4171');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (493, '6578 9391 2956 5188', '2029-12-13', 'visa', 'pre-pago', '1486');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (494, '0050 0924 4928 7875', '2030-03-12', 'visa', 'pre-pago', '3029');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (495, '3011 2501 8607 4290', '2029-07-03', 'american express', 'debito', '2223');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (496, '3693 1806 2007 3024', '2026-12-09', 'hipercard', 'pre-pago', '6249');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (497, '7537 4057 1446 9567', '2027-11-14', 'visa', 'pre-pago', '6873');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (498, '5445 3451 4668 8658', '2027-03-25', 'elo', 'pre-pago', '3483');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (499, '5862 6736 6485 3207', '2030-04-21', 'elo', 'pre-pago', '7089');
INSERT INTO cartao (id_colaborador, numero_cartao, validade, bandeira, tipo_pagamento, cvv) VALUES (500, '4326 9834 4369 5805', '2025-04-08', 'elo', 'debito', '0509');

INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (1, 1, 262.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (2, 1, 695.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (3, 2, 4.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (4, 2, 168.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (5, 3, 303.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (6, 3, 226.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (7, 1, 670.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (8, 1, 735.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (9, 2, 583.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (10, 2, 380.96, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (11, 3, 266.78, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (12, 3, 1.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (13, 1, 42.87, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (14, 1, 502.62, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (15, 2, 65.96, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (16, 2, 79.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (17, 3, 1.95, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (18, 3, 9.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (19, 1, 843.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (20, 1, 515.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (21, 2, 83.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (22, 2, 158.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (23, 3, 268.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (24, 3, 89.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (25, 1, 1287.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (26, 1, 282.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (27, 2, 434.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (28, 2, 85.34, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (29, 3, 230.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (30, 3, 347.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (31, 1, 276.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (32, 1, 396.29, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (33, 2, 504.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (34, 2, 109.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (35, 3, 44.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (36, 3, 145.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (37, 1, 288.66, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (38, 1, 525.15, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (39, 2, 572.74, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (40, 2, 453.96, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (41, 3, 319.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (42, 3, 250.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (43, 1, 486.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (44, 1, 998.34, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (45, 2, 206.41, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (46, 2, 453.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (47, 3, 181.5, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (48, 3, 305.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (49, 1, 279.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (50, 1, 623.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (51, 2, 265.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (52, 2, 598.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (53, 3, 34.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (54, 3, 190.25, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (55, 1, 1078.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (56, 1, 1120.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (57, 2, 154.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (58, 2, 451.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (59, 3, 103.02, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (60, 3, 390.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (61, 1, 588.38, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (62, 1, 932.15, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (63, 2, 342.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (64, 2, 499.35, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (65, 3, 316.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (66, 3, 247.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (67, 1, 110.63, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (68, 1, 1411.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (69, 2, 19.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (70, 2, 369.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (71, 3, 57.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (72, 3, 365.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (73, 1, 628.16, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (74, 1, 1205.74, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (75, 2, 571.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (76, 2, 468.99, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (77, 3, 212.41, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (78, 3, 382.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (79, 1, 516.23, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (80, 1, 986.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (81, 2, 34.31, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (82, 2, 489.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (83, 3, 146.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (84, 3, 57.9, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (85, 1, 1083.53, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (86, 1, 383.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (87, 2, 460.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (88, 2, 279.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (89, 3, 25.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (90, 3, 117.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (91, 1, 427.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (92, 1, 1342.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (93, 2, 424.35, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (94, 2, 149.24, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (95, 3, 149.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (96, 3, 33.82, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (97, 1, 979.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (98, 1, 1471.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (99, 2, 71.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (100, 2, 192.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (101, 3, 273.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (102, 3, 269.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (103, 1, 189.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (104, 1, 1439.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (105, 2, 545.82, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (106, 2, 97.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (107, 3, 170.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (108, 3, 33.35, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (109, 1, 755.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (110, 1, 927.83, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (111, 2, 356.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (112, 2, 340.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (113, 3, 128.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (114, 3, 184.2, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (115, 1, 170.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (116, 1, 205.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (117, 2, 270.73, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (118, 2, 386.08, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (119, 3, 237.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (120, 3, 291.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (121, 1, 294.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (122, 1, 476.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (123, 2, 592.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (124, 2, 465.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (125, 3, 322.77, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (126, 3, 197.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (127, 1, 1330.58, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (128, 1, 464.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (129, 2, 33.17, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (130, 2, 301.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (131, 3, 158.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (132, 3, 311.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (133, 1, 906.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (134, 1, 308.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (135, 2, 413.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (136, 2, 178.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (137, 3, 284.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (138, 3, 315.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (139, 1, 144.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (140, 1, 365.38, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (141, 2, 79.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (142, 2, 29.08, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (143, 3, 40.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (144, 3, 150.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (145, 1, 465.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (146, 1, 147.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (147, 2, 328.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (148, 2, 141.63, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (149, 3, 220.07, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (150, 3, 292.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (151, 1, 1008.18, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (152, 1, 1085.5, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (153, 2, 133.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (154, 2, 142.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (155, 3, 267.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (156, 3, 375.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (157, 1, 368.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (158, 1, 18.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (159, 2, 355.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (160, 2, 291.66, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (161, 3, 18.47, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (162, 3, 51.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (163, 1, 1075.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (164, 1, 1449.79, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (165, 2, 274.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (166, 2, 161.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (167, 3, 317.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (168, 3, 268.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (169, 1, 480.96, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (170, 1, 688.17, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (171, 2, 48.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (172, 2, 468.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (173, 3, 248.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (174, 3, 121.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (175, 1, 545.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (176, 1, 212.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (177, 2, 203.06, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (178, 2, 360.02, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (179, 3, 199.41, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (180, 3, 178.46, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (181, 1, 174.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (182, 1, 751.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (183, 2, 84.82, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (184, 2, 350.79, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (185, 3, 53.79, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (186, 3, 331.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (187, 1, 660.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (188, 1, 37.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (189, 2, 124.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (190, 2, 326.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (191, 3, 191.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (192, 3, 397.1, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (193, 1, 209.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (194, 1, 1391.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (195, 2, 173.21, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (196, 2, 41.31, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (197, 3, 156.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (198, 3, 197.7, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (199, 1, 327.62, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (200, 1, 1019.97, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (201, 2, 274.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (202, 2, 410.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (203, 3, 268.38, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (204, 3, 118.21, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (205, 1, 901.45, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (206, 1, 1105.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (207, 2, 553.85, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (208, 2, 16.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (209, 3, 125.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (210, 3, 226.15, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (211, 1, 1353.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (212, 1, 324.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (213, 2, 467.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (214, 2, 16.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (215, 3, 194.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (216, 3, 256.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (217, 1, 340.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (218, 1, 1148.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (219, 2, 108.67, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (220, 2, 467.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (221, 3, 379.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (222, 3, 257.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (223, 1, 86.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (224, 1, 334.58, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (225, 2, 544.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (226, 2, 445.7, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (227, 3, 231.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (228, 3, 180.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (229, 1, 235.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (230, 1, 777.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (231, 2, 321.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (232, 2, 350.03, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (233, 3, 160.19, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (234, 3, 330.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (235, 1, 672.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (236, 1, 1185.09, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (237, 2, 393.7, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (238, 2, 286.24, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (239, 3, 245.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (240, 3, 22.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (241, 1, 1302.37, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (242, 1, 186.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (243, 2, 512.2, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (244, 2, 592.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (245, 3, 295.11, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (246, 3, 213.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (247, 1, 1410.73, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (248, 1, 649.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (249, 2, 379.11, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (250, 2, 574.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (251, 3, 162.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (252, 3, 397.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (253, 1, 141.18, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (254, 1, 1471.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (255, 2, 211.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (256, 2, 446.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (257, 3, 41.34, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (258, 3, 243.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (259, 1, 1370.78, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (260, 1, 133.02, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (261, 2, 126.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (262, 2, 426.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (263, 3, 354.82, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (264, 3, 212.16, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (265, 1, 1046.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (266, 1, 310.77, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (267, 2, 299.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (268, 2, 296.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (269, 3, 273.31, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (270, 3, 155.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (271, 1, 1036.58, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (272, 1, 180.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (273, 2, 46.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (274, 2, 316.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (275, 3, 14.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (276, 3, 124.19, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (277, 1, 84.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (278, 1, 245.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (279, 2, 177.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (280, 2, 199.74, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (281, 3, 277.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (282, 3, 328.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (283, 1, 896.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (284, 1, 1137.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (285, 2, 289.1, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (286, 2, 439.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (287, 3, 61.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (288, 3, 310.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (289, 1, 158.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (290, 1, 104.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (291, 2, 443.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (292, 2, 528.35, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (293, 3, 295.62, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (294, 3, 379.47, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (295, 1, 740.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (296, 1, 269.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (297, 2, 491.34, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (298, 2, 424.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (299, 3, 14.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (300, 3, 158.07, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (301, 1, 391.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (302, 1, 1237.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (303, 2, 332.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (304, 2, 56.29, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (305, 3, 310.39, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (306, 3, 3.47, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (307, 1, 705.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (308, 1, 992.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (309, 2, 574.76, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (310, 2, 352.29, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (311, 3, 122.34, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (312, 3, 231.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (313, 1, 944.46, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (314, 1, 48.17, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (315, 2, 366.77, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (316, 2, 421.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (317, 3, 254.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (318, 3, 131.45, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (319, 1, 1388.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (320, 1, 762.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (321, 2, 123.72, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (322, 2, 282.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (323, 3, 181.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (324, 3, 54.43, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (325, 1, 339.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (326, 1, 16.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (327, 2, 183.38, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (328, 2, 387.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (329, 3, 378.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (330, 3, 246.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (331, 1, 1259.23, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (332, 1, 1214.07, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (333, 2, 547.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (334, 2, 140.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (335, 3, 360.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (336, 3, 217.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (337, 1, 465.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (338, 1, 444.8, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (339, 2, 523.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (340, 2, 401.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (341, 3, 62.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (342, 3, 323.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (343, 1, 10.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (344, 1, 658.83, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (345, 2, 536.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (346, 2, 400.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (347, 3, 262.95, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (348, 3, 166.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (349, 1, 919.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (350, 1, 154.58, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (351, 2, 115.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (352, 2, 424.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (353, 3, 186.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (354, 3, 332.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (355, 1, 1258.16, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (356, 1, 1026.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (357, 2, 305.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (358, 2, 231.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (359, 3, 360.73, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (360, 3, 10.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (361, 1, 575.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (362, 1, 271.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (363, 2, 594.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (364, 2, 574.09, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (365, 3, 152.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (366, 3, 233.23, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (367, 1, 635.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (368, 1, 251.82, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (369, 2, 139.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (370, 2, 341.21, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (371, 3, 26.17, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (372, 3, 312.97, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (373, 1, 1015.21, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (374, 1, 1189.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (375, 2, 183.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (376, 2, 378.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (377, 3, 0.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (378, 3, 71.07, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (379, 1, 405.24, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (380, 1, 1208.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (381, 2, 323.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (382, 2, 142.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (383, 3, 148.37, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (384, 3, 295.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (385, 1, 1353.79, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (386, 1, 55.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (387, 2, 485.02, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (388, 2, 105.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (389, 3, 224.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (390, 3, 248.09, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (391, 1, 494.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (392, 1, 403.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (393, 2, 499.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (394, 2, 208.44, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (395, 3, 341.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (396, 3, 374.38, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (397, 1, 1483.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (398, 1, 1318.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (399, 2, 506.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (400, 2, 149.24, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (401, 3, 361.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (402, 3, 168.78, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (403, 1, 484.07, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (404, 1, 1292.83, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (405, 2, 26.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (406, 2, 481.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (407, 3, 1.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (408, 3, 319.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (409, 1, 204.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (410, 1, 682.99, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (411, 2, 591.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (412, 2, 366.31, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (413, 3, 150.92, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (414, 3, 171.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (415, 1, 916.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (416, 1, 24.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (417, 2, 274.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (418, 2, 385.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (419, 3, 346.61, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (420, 3, 20.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (421, 1, 931.84, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (422, 1, 121.19, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (423, 2, 128.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (424, 2, 477.67, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (425, 3, 372.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (426, 3, 134.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (427, 1, 537.74, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (428, 1, 488.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (429, 2, 45.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (430, 2, 253.43, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (431, 3, 38.37, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (432, 3, 117.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (433, 1, 1084.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (434, 1, 426.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (435, 2, 579.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (436, 2, 383.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (437, 3, 206.85, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (438, 3, 390.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (439, 1, 486.31, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (440, 1, 968.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (441, 2, 245.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (442, 2, 474.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (443, 3, 137.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (444, 3, 329.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (445, 1, 396.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (446, 1, 841.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (447, 2, 498.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (448, 2, 100.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (449, 3, 178.28, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (450, 3, 13.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (451, 1, 83.55, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (452, 1, 1288.9, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (453, 2, 522.78, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (454, 2, 256.7, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (455, 3, 150.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (456, 3, 205.66, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (457, 1, 943.78, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (458, 1, 374.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (459, 2, 343.78, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (460, 2, 244.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (461, 3, 20.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (462, 3, 129.23, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (463, 1, 28.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (464, 1, 32.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (465, 2, 458.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (466, 2, 346.86, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (467, 3, 33.62, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (468, 3, 259.41, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (469, 1, 440.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (470, 1, 1289.48, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (471, 2, 520.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (472, 2, 275.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (473, 3, 303.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (474, 3, 86.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (475, 1, 220.02, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (476, 1, 1121.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (477, 2, 182.43, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (478, 2, 377.32, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (479, 3, 203.47, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (480, 3, 298.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (481, 1, 348.94, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (482, 1, 1011.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (483, 2, 133.41, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (484, 2, 253.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (485, 3, 336.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (486, 3, 179.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (487, 1, 186.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (488, 1, 419.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (489, 2, 276.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (490, 2, 405.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (491, 3, 155.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (492, 3, 177.8, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (493, 1, 61.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (494, 1, 1364.23, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (495, 2, 363.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (496, 2, 158.98, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (497, 3, 309.35, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (498, 3, 109.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (499, 1, 359.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (500, 1, 753.65, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (501, 2, 352.46, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (502, 2, 267.68, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (503, 3, 101.5, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (504, 3, 11.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (505, 1, 360.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (506, 1, 629.84, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (507, 2, 15.01, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (508, 2, 13.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (509, 3, 168.5, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (510, 3, 123.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (511, 1, 299.58, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (512, 1, 475.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (513, 2, 124.62, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (514, 2, 35.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (515, 3, 315.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (516, 3, 18.6, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (517, 1, 1107.71, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (518, 1, 558.9, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (519, 2, 303.74, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (520, 2, 174.3, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (521, 3, 97.67, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (522, 3, 320.2, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (523, 1, 634.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (524, 1, 1430.75, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (525, 2, 518.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (526, 2, 246.97, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (527, 3, 252.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (528, 3, 268.44, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (529, 1, 1436.97, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (530, 1, 43.35, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (531, 2, 442.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (532, 2, 441.37, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (533, 3, 233.97, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (534, 3, 144.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (535, 1, 118.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (536, 1, 896.78, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (537, 2, 441.36, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (538, 2, 596.17, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (539, 3, 40.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (540, 3, 200.95, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (541, 1, 671.73, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (542, 1, 602.69, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (543, 2, 438.1, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (544, 2, 255.03, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (545, 3, 257.13, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (546, 3, 204.45, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (547, 1, 421.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (548, 1, 875.33, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (549, 2, 390.54, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (550, 2, 230.04, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (551, 3, 283.27, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (552, 3, 149.15, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (553, 1, 606.17, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (554, 1, 879.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (555, 2, 385.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (556, 2, 431.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (557, 3, 276.66, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (558, 3, 72.19, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (559, 1, 744.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (560, 1, 1283.05, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (561, 2, 502.91, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (562, 2, 373.89, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (563, 3, 365.85, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (564, 3, 21.92, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (565, 1, 1313.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (566, 1, 564.14, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (567, 2, 184.52, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (568, 2, 127.93, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (569, 3, 36.12, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (570, 3, 296.26, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (571, 1, 391.73, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (572, 1, 453.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (573, 2, 112.79, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (574, 2, 169.22, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (575, 3, 358.88, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (576, 3, 66.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (577, 1, 1174.64, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (578, 1, 338.49, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (579, 2, 49.25, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (580, 2, 409.18, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (581, 3, 162.51, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (582, 3, 346.83, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (583, 1, 453.67, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (584, 1, 1454.06, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (585, 2, 45.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (586, 2, 5.2, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (587, 3, 149.56, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (588, 3, 377.87, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (589, 1, 477.42, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (590, 1, 523.89, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (591, 2, 561.4, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (592, 2, 218.81, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (593, 3, 47.57, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (594, 3, 131.15, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (595, 1, 1210.1, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (596, 1, 866.0, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (597, 2, 531.72, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (598, 2, 45.59, TRUE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (599, 3, 399.18, FALSE);
INSERT INTO cartao_categoria_beneficio (id_cartao, id_categoria_beneficio, saldo, ativo) VALUES (600, 3, 132.12, TRUE);

INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 1', '16759238319387', '21800381463', 'contato1@atacadao1.com.br', TRUE, 3, 501);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('extra supermercados 2', '92421959730940', '21852734114', 'contato2@extrasuperme.com.br', TRUE, 1, 502);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('carrefour market 3', '13315553015379', '11440778110', 'contato3@carrefourmar.com.br', TRUE, 1, 503);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pao de acucar 4', '65984557663426', '21829912699', 'contato4@paodeacucar4.com.br', TRUE, 3, 504);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('mercado sao jorge 5', '20641910616609', '11082242168', 'contato5@mercadosaojo.com.br', TRUE, 5, 505);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado bom preco 6', '82217562699613', '91347910059', 'contato6@supermercado.com.br', TRUE, 2, 506);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pao de acucar 7', '57228703220040', '91597243871', 'contato7@paodeacucar7.com.br', TRUE, 4, 507);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('mercado familia 8', '51452058028621', '11480224065', 'contato8@mercadofamil.com.br', TRUE, 1, 508);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 9', '74769509041839', '61664301655', 'contato9@atacadao9.com.br', TRUE, 5, 509);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('assai atacadista 10', '23887888765667', '41136062290', 'contato10@assaiatacadi.com.br', TRUE, 5, 510);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado bom preco 11', '13860479471970', '41803514895', 'contato11@supermercado.com.br', TRUE, 5, 511);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('carrefour market 12', '82944191479043', '51728395167', 'contato12@carrefourmar.com.br', TRUE, 3, 512);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 13', '09532670848874', '71562925822', 'contato13@atacadao13.com.br', TRUE, 4, 513);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 14', '28018323530600', '61684676780', 'contato14@atacadao14.com.br', TRUE, 5, 514);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('extra supermercados 15', '64583744959717', '21353175559', 'contato15@extrasuperme.com.br', TRUE, 3, 515);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('mercado familia 16', '89748741148662', '81511997645', 'contato16@mercadofamil.com.br', TRUE, 2, 516);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('assai atacadista 17', '96551564196746', '71300935820', 'contato17@assaiatacadi.com.br', TRUE, 5, 517);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pao de acucar 18', '63015972242262', '91349276680', 'contato18@paodeacucar1.com.br', TRUE, 5, 518);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado bom preco 19', '84601804033492', '21537358667', 'contato19@supermercado.com.br', TRUE, 5, 519);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('mercado familia 20', '55446053926009', '81462720536', 'contato20@mercadofamil.com.br', TRUE, 5, 520);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hortifruti natural da terra 21', '49911928567265', '11215538307', 'contato21@hortifrutina.com.br', TRUE, 5, 521);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado ideal 22', '58212626439534', '91446078907', 'contato22@supermercado.com.br', TRUE, 4, 522);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('assai atacadista 23', '19919817755154', '51414925316', 'contato23@assaiatacadi.com.br', TRUE, 2, 523);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hortifruti natural da terra 24', '98283859747794', '71590705549', 'contato24@hortifrutina.com.br', TRUE, 4, 524);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado bom preco 25', '34368771569240', '51907634153', 'contato25@supermercado.com.br', TRUE, 2, 525);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('assai atacadista 26', '77100115477310', '51314872255', 'contato26@assaiatacadi.com.br', TRUE, 3, 526);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hortifruti natural da terra 27', '85641354741690', '61739523285', 'contato27@hortifrutina.com.br', FALSE, 5, 527);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('mercado familia 28', '58095794758188', '11284136233', 'contato28@mercadofamil.com.br', TRUE, 4, 528);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado ideal 29', '47040714697104', '81341855950', 'contato29@supermercado.com.br', TRUE, 3, 529);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('supermercado bom preco 30', '37456017039617', '21759001706', 'contato30@supermercado.com.br', TRUE, 1, 530);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('extra supermercados 31', '49078692855100', '21593896763', 'contato31@extrasuperme.com.br', TRUE, 4, 531);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('extra supermercados 32', '36735589607077', '31883413351', 'contato32@extrasuperme.com.br', TRUE, 4, 532);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('carrefour market 33', '90143097427480', '71635796714', 'contato33@carrefourmar.com.br', TRUE, 5, 533);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 34', '03007356582683', '31526379412', 'contato34@atacadao34.com.br', TRUE, 1, 534);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hortifruti natural da terra 35', '86691122321406', '31611978925', 'contato35@hortifrutina.com.br', TRUE, 2, 535);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pao de acucar 36', '46574465325536', '21181851367', 'contato36@paodeacucar3.com.br', TRUE, 3, 536);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pao de acucar 37', '05203881937660', '21847146220', 'contato37@paodeacucar3.com.br', TRUE, 5, 537);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('atacadao 38', '48333540112779', '41603087647', 'contato38@atacadao38.com.br', TRUE, 2, 538);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hortifruti natural da terra 39', '09067618376275', '11767162172', 'contato39@hortifrutina.com.br', TRUE, 5, 539);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('carrefour market 40', '88868041869389', '31645649674', 'contato40@carrefourmar.com.br', TRUE, 1, 540);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hamburgueria urban 41', '91605390649037', '11342519701', 'contato41@hamburgueria.com.br', TRUE, 10, 541);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('sushi express 42', '58913682967004', '31153193625', 'contato42@sushiexpress.com.br', FALSE, 9, 542);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cantina italiana 43', '60221690887518', '11293358384', 'contato43@cantinaitali.com.br', TRUE, 8, 543);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('bistro central 44', '91065735174572', '41510214012', 'contato44@bistrocentra.com.br', TRUE, 8, 544);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cafe da manha 45', '33195589799005', '81177170305', 'contato45@cafedamanha4.com.br', TRUE, 7, 545);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cantina italiana 46', '70941246051643', '41895337684', 'contato46@cantinaitali.com.br', TRUE, 8, 546);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 47', '87677600643418', '81317303324', 'contato47@padariacolon.com.br', TRUE, 8, 547);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 48', '67574510484833', '51731815605', 'contato48@padariacolon.com.br', TRUE, 6, 548);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('lanchonete do ze 49', '27079959476115', '11797647545', 'contato49@lanchonetedo.com.br', TRUE, 6, 549);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('sushi express 50', '72897226934892', '11390984685', 'contato50@sushiexpress.com.br', TRUE, 8, 550);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hamburgueria urban 51', '06699261382659', '11977779570', 'contato51@hamburgueria.com.br', TRUE, 10, 551);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('lanchonete do ze 52', '39962637792793', '11735128962', 'contato52@lanchonetedo.com.br', TRUE, 6, 552);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 53', '06824323330216', '41446060694', 'contato53@padariacolon.com.br', TRUE, 7, 553);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('sushi express 54', '06952357865211', '21285370064', 'contato54@sushiexpress.com.br', TRUE, 10, 554);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('pizzaria bella napoli 55', '85487531198035', '61542805376', 'contato55@pizzariabell.com.br', TRUE, 8, 555);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('restaurante sabor caseiro 56', '42550786887890', '31039221317', 'contato56@restaurantes.com.br', TRUE, 9, 556);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cantina italiana 57', '19586639928717', '81287314249', 'contato57@cantinaitali.com.br', TRUE, 10, 557);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('churrascaria tres irmaos 58', '62917964416093', '31888070051', 'contato58@churrascaria.com.br', TRUE, 7, 558);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cafe da manha 59', '28745120220170', '51541648792', 'contato59@cafedamanha5.com.br', TRUE, 9, 559);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 60', '10466275015281', '81442036078', 'contato60@padariacolon.com.br', TRUE, 9, 560);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('churrascaria tres irmaos 61', '54833095872347', '71806014579', 'contato61@churrascaria.com.br', TRUE, 10, 561);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cafe da manha 62', '26714858197061', '11196797209', 'contato62@cafedamanha6.com.br', TRUE, 6, 562);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 63', '19201828523317', '81049379582', 'contato63@padariacolon.com.br', TRUE, 7, 563);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('padaria colonial 64', '15855116397128', '31075741424', 'contato64@padariacolon.com.br', TRUE, 8, 564);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('lanchonete do ze 65', '73962625918814', '31497736772', 'contato65@lanchonetedo.com.br', TRUE, 7, 565);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('bistro central 66', '44343549787235', '61715643802', 'contato66@bistrocentra.com.br', TRUE, 10, 566);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('restaurante sabor caseiro 67', '90348042479635', '11940916573', 'contato67@restaurantes.com.br', TRUE, 6, 567);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('bistro central 68', '24266225492004', '41091401527', 'contato68@bistrocentra.com.br', TRUE, 7, 568);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('restaurante sabor caseiro 69', '17226414756923', '21842933598', 'contato69@restaurantes.com.br', FALSE, 6, 569);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hamburgueria urban 70', '47422983596606', '21539022624', 'contato70@hamburgueria.com.br', TRUE, 9, 570);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('bistro central 71', '36500329909027', '51761442787', 'contato71@bistrocentra.com.br', TRUE, 6, 571);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('restaurante sabor caseiro 72', '55404231697919', '71754939343', 'contato72@restaurantes.com.br', TRUE, 7, 572);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('churrascaria tres irmaos 73', '69045392528785', '61733813307', 'contato73@churrascaria.com.br', TRUE, 10, 573);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('sushi express 74', '53302364122468', '11985372033', 'contato74@sushiexpress.com.br', TRUE, 9, 574);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cafe da manha 75', '51602325107141', '61870940422', 'contato75@cafedamanha7.com.br', TRUE, 8, 575);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('cafe da manha 76', '45641199255165', '41807819135', 'contato76@cafedamanha7.com.br', TRUE, 7, 576);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hamburgueria urban 77', '53494197157532', '21663282463', 'contato77@hamburgueria.com.br', TRUE, 8, 577);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('hamburgueria urban 78', '61621856352016', '71150420598', 'contato78@hamburgueria.com.br', TRUE, 6, 578);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('restaurante sabor caseiro 79', '85697714336062', '11101461039', 'contato79@restaurantes.com.br', TRUE, 10, 579);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('churrascaria tres irmaos 80', '88881893046164', '91816878518', 'contato80@churrascaria.com.br', TRUE, 9, 580);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto estrela 81', '56905096568805', '81280072720', 'contato81@postoestrela.com.br', TRUE, 12, 581);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('auto posto cidade nova 82', '81472373564028', '41083069789', 'contato82@autopostocid.com.br', TRUE, 14, 582);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto estrela 83', '95145498367147', '81490668867', 'contato83@postoestrela.com.br', TRUE, 13, 583);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto estrela 84', '85711645605933', '41431807392', 'contato84@postoestrela.com.br', TRUE, 13, 584);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto shell 85', '02585653377713', '41167871926', 'contato85@postoshell85.com.br', TRUE, 12, 585);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('combustiveis express 86', '48720124025405', '11054908099', 'contato86@combustiveis.com.br', TRUE, 13, 586);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto estrela 87', '39767388724607', '41034383000', 'contato87@postoestrela.com.br', TRUE, 11, 587);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto sol nascente 88', '43529493074109', '71546628973', 'contato88@postosolnasc.com.br', TRUE, 14, 588);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto br distribuidora 89', '89622527560035', '41023405677', 'contato89@postobrdistr.com.br', TRUE, 12, 589);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto shell 90', '12515890418204', '61166608123', 'contato90@postoshell90.com.br', TRUE, 15, 590);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto ipiranga 91', '78844790986386', '61276958444', 'contato91@postoipirang.com.br', TRUE, 14, 591);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('auto posto central 92', '22482488631327', '81145031180', 'contato92@autopostocen.com.br', TRUE, 14, 592);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto shell 93', '66914193960688', '51718911992', 'contato93@postoshell93.com.br', TRUE, 11, 593);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto gasolina rapida 94', '69247688341018', '21413181181', 'contato94@postogasolin.com.br', TRUE, 12, 594);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('auto posto cidade nova 95', '51325179044721', '61609406714', 'contato95@autopostocid.com.br', TRUE, 11, 595);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto nordeste 96', '87831031456494', '31275794074', 'contato96@postonordest.com.br', TRUE, 13, 596);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto sol nascente 97', '37449998709310', '21369412641', 'contato97@postosolnasc.com.br', TRUE, 12, 597);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto estrela 98', '60326753180502', '41101089654', 'contato98@postoestrela.com.br', TRUE, 14, 598);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('auto posto cidade nova 99', '12536064004773', '71794869894', 'contato99@autopostocid.com.br', TRUE, 13, 599);
INSERT INTO estabelecimento (nome, cnpj, telefone, email, status, id_mcc, id_endereco) VALUES ('posto nordeste 100', '81703610077024', '81375949330', 'contato100@postonordest.com.br', TRUE, 11, 600);

INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (279.82, 85, 14, '2024-02-27 09:18:16', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (228.87, 543, 74, '2024-02-10 10:40:13', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (11.97, 470, 36, '2024-03-13 02:23:37', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (283.72, 67, 38, '2024-10-04 00:51:15', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (137.08, 327, 76, '2024-06-25 15:58:05', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (158.1, 510, 86, '2025-03-14 13:44:19', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (115.34, 264, 90, '2024-05-05 15:23:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (233.97, 367, 14, '2024-01-21 14:15:04', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (111.26, 180, 94, '2024-01-01 23:31:51', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (96.78, 47, 97, '2025-03-30 21:36:59', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (124.24, 483, 50, '2024-09-27 06:53:06', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (37.94, 550, 50, '2025-04-21 11:02:38', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (35.61, 183, 59, '2024-12-18 23:11:18', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (230.19, 232, 73, '2024-04-30 05:07:42', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (218.22, 550, 64, '2024-06-01 07:07:25', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (254.51, 268, 72, '2024-10-19 03:18:23', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (251.5, 191, 85, '2024-04-29 04:12:50', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (168.26, 300, 85, '2024-03-12 20:06:56', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (85.68, 182, 11, '2024-06-04 22:24:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (275.64, 372, 98, '2024-10-30 07:45:47', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (6.73, 331, 5, '2024-10-09 14:25:22', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (262.45, 367, 13, '2024-09-05 02:36:24', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (264.85, 91, 17, '2024-04-04 07:42:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (120.99, 21, 44, '2025-04-01 06:49:23', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (226.28, 283, 25, '2024-11-01 08:45:08', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (162.86, 452, 27, '2025-04-07 21:41:17', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (200.47, 224, 14, '2024-09-11 11:58:50', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (181.79, 176, 1, '2024-07-03 08:16:58', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (210.21, 362, 17, '2024-03-17 22:32:34', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (286.36, 304, 51, '2025-03-28 23:28:19', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (42.21, 249, 47, '2024-02-12 12:48:31', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (119.88, 135, 80, '2024-02-11 15:06:04', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (236.21, 65, 86, '2024-03-27 06:47:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (29.53, 47, 96, '2024-09-10 18:11:03', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (254.6, 57, 54, '2024-12-23 00:55:40', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (290.54, 193, 34, '2025-04-29 06:37:57', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (284.53, 104, 11, '2024-06-28 09:55:47', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (169.03, 570, 87, '2024-04-18 16:30:54', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (256.84, 404, 25, '2024-10-18 15:13:50', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (230.43, 40, 80, '2025-03-11 11:52:30', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (63.01, 99, 62, '2024-06-18 08:46:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (82.41, 511, 34, '2024-04-06 23:43:32', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (77.28, 483, 60, '2024-11-16 13:08:07', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (218.77, 244, 47, '2024-02-24 12:45:31', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (232.77, 55, 17, '2025-02-15 21:37:32', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (126.14, 14, 18, '2024-03-04 09:20:36', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (40.86, 220, 51, '2024-10-25 13:51:22', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (292.55, 485, 81, '2024-06-22 11:26:23', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (126.97, 145, 20, '2024-03-31 09:15:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (75.43, 466, 56, '2025-01-28 14:22:23', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (179.36, 473, 81, '2024-11-17 10:17:47', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (9.41, 213, 56, '2024-07-08 09:06:03', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (24.98, 513, 74, '2025-03-19 22:44:49', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (293.37, 138, 85, '2024-04-18 16:08:54', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (266.23, 117, 69, '2024-11-08 11:45:52', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (117.26, 133, 14, '2025-04-12 23:28:09', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (183.48, 201, 75, '2025-03-16 22:08:40', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (97.34, 140, 22, '2025-04-22 14:34:50', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (93.88, 199, 33, '2025-02-08 01:54:17', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (190.79, 572, 32, '2025-02-25 02:00:32', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (26.94, 86, 15, '2024-06-21 20:52:20', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (12.17, 196, 55, '2025-02-07 16:36:16', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (146.28, 382, 72, '2024-09-16 09:09:41', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (204.07, 459, 45, '2024-02-13 07:55:54', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (267.19, 537, 50, '2025-01-08 23:28:11', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (55.66, 40, 79, '2024-10-03 18:29:12', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (9.66, 119, 89, '2024-07-25 22:55:31', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (54.65, 356, 31, '2024-11-16 08:44:34', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (121.6, 306, 93, '2024-01-18 11:11:39', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (155.07, 247, 25, '2024-02-26 06:45:25', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (188.63, 133, 1, '2024-09-24 17:41:01', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (285.66, 436, 76, '2024-12-29 19:44:28', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (291.2, 353, 93, '2025-03-19 16:52:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (256.55, 376, 46, '2024-09-02 07:49:02', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (288.69, 433, 9, '2024-04-23 10:32:47', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (206.25, 207, 58, '2024-02-27 01:57:40', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (296.35, 168, 87, '2024-12-20 05:22:51', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (130.58, 408, 91, '2024-10-02 20:24:28', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (259.54, 359, 84, '2024-03-21 20:03:37', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (91.04, 429, 47, '2024-05-04 13:28:15', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (165.2, 8, 4, '2024-10-07 18:43:54', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (224.22, 25, 32, '2025-01-29 16:51:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (190.34, 129, 74, '2025-03-09 21:25:18', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (288.66, 172, 60, '2024-05-13 00:57:24', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (206.47, 361, 6, '2025-02-09 05:14:17', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (192.82, 128, 11, '2024-06-27 06:42:25', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (276.3, 586, 46, '2025-02-27 03:13:19', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (144.22, 1, 24, '2024-01-06 02:43:31', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (167.37, 16, 58, '2024-04-16 23:24:45', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (25.46, 517, 33, '2024-05-04 09:42:22', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (229.8, 335, 90, '2024-06-11 14:23:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (51.32, 51, 42, '2024-09-11 04:09:19', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (214.27, 524, 12, '2024-01-15 05:30:59', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (156.41, 25, 11, '2025-04-25 08:37:16', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (80.5, 591, 69, '2024-04-10 02:49:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (208.57, 158, 23, '2024-01-10 23:49:09', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (44.72, 344, 2, '2024-07-05 21:36:52', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (197.99, 571, 20, '2024-06-28 08:32:42', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (85.16, 512, 25, '2024-04-20 13:30:43', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (63.26, 215, 82, '2024-12-20 21:10:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (38.84, 440, 27, '2024-12-03 16:07:21', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (13.89, 428, 19, '2025-04-15 19:21:19', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (121.94, 544, 54, '2024-04-06 06:55:43', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (118.72, 471, 55, '2025-03-09 12:42:12', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (7.73, 239, 87, '2024-06-09 06:28:50', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (87.14, 284, 33, '2024-07-15 07:03:36', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (34.38, 296, 3, '2024-10-30 16:05:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (14.04, 4, 60, '2025-02-28 13:16:44', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (167.93, 257, 95, '2024-03-18 13:22:59', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (149.49, 77, 84, '2024-08-20 11:47:53', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (55.14, 532, 53, '2024-01-03 18:58:37', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (40.11, 73, 38, '2024-01-05 17:10:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (184.9, 500, 3, '2024-11-12 20:39:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (34.12, 323, 91, '2024-05-31 13:42:37', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (102.77, 542, 21, '2024-05-04 02:50:10', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (44.28, 126, 90, '2025-03-05 06:35:56', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (252.05, 387, 42, '2024-05-29 23:46:00', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (192.61, 342, 83, '2024-07-01 12:56:04', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (21.89, 566, 35, '2024-08-25 17:25:07', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (281.83, 135, 52, '2024-06-03 03:53:05', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (36.42, 590, 6, '2024-03-30 22:52:56', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (246.04, 125, 100, '2024-09-05 00:57:11', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (141.59, 141, 56, '2025-02-25 23:48:22', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (16.91, 307, 23, '2024-03-05 01:05:30', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (178.33, 409, 36, '2024-07-03 19:53:34', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (267.81, 411, 46, '2025-01-29 04:27:48', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (143.91, 456, 98, '2025-02-26 04:51:10', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (57.54, 98, 40, '2024-06-20 00:33:05', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (288.09, 257, 90, '2024-08-17 03:30:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (264.39, 459, 47, '2024-02-05 02:30:23', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (125.0, 435, 46, '2024-09-06 11:08:20', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (294.85, 466, 77, '2024-03-09 13:20:50', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (296.88, 343, 25, '2025-03-01 20:09:27', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (228.79, 239, 91, '2024-12-29 07:13:44', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (262.84, 338, 19, '2024-09-09 13:01:14', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (30.89, 83, 88, '2024-10-29 04:30:13', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (290.55, 274, 73, '2025-03-19 01:46:29', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (37.16, 578, 5, '2024-09-27 18:56:39', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (39.3, 139, 22, '2024-06-08 07:27:12', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (180.56, 402, 91, '2024-10-19 00:25:16', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (85.33, 153, 66, '2024-12-02 00:40:35', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (203.13, 98, 10, '2025-03-24 18:21:33', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (217.85, 477, 76, '2024-01-06 11:05:40', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (120.17, 214, 64, '2024-03-23 04:45:54', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (220.5, 192, 96, '2025-03-20 11:25:09', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (175.31, 371, 82, '2025-04-06 16:18:29', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (272.38, 487, 14, '2024-09-12 01:04:13', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (67.32, 169, 7, '2025-01-12 07:02:10', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (109.07, 520, 67, '2024-04-23 00:56:48', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (289.15, 497, 94, '2025-03-11 14:28:12', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (156.2, 304, 66, '2024-03-22 11:43:38', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (233.9, 203, 99, '2025-03-22 21:52:04', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (20.09, 191, 90, '2025-03-17 13:06:09', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (74.98, 361, 1, '2025-04-01 05:39:34', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (255.65, 471, 75, '2024-08-18 20:00:09', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (206.78, 357, 41, '2024-07-15 05:45:28', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (37.54, 211, 40, '2024-02-03 13:35:01', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (224.43, 130, 75, '2024-04-15 04:44:31', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (89.02, 264, 99, '2024-06-29 09:37:56', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (298.09, 273, 58, '2024-03-25 18:14:26', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (81.44, 560, 4, '2024-09-21 18:30:41', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (276.67, 160, 66, '2025-02-04 13:48:18', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (214.64, 492, 81, '2025-03-16 22:32:30', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (212.69, 466, 60, '2025-03-20 12:28:35', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (257.25, 388, 47, '2024-12-15 20:48:00', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (151.58, 517, 29, '2024-11-19 14:43:38', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (116.63, 57, 71, '2025-02-12 17:58:00', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (204.77, 235, 28, '2025-01-14 15:59:55', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (21.75, 162, 89, '2024-12-09 23:26:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (252.86, 524, 13, '2024-12-27 17:07:22', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (192.86, 524, 13, '2024-05-30 03:28:11', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (189.79, 493, 4, '2025-01-17 02:13:52', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (177.24, 296, 28, '2024-04-25 10:19:57', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (152.81, 551, 92, '2024-08-07 10:34:36', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (176.58, 313, 25, '2025-04-14 03:39:05', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (206.22, 256, 71, '2024-02-03 13:38:33', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (230.67, 67, 29, '2024-04-17 09:03:59', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (97.94, 305, 88, '2024-05-03 04:55:43', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (202.94, 532, 41, '2024-09-14 02:33:30', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (137.89, 476, 37, '2024-07-22 21:00:48', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (46.2, 145, 7, '2024-04-09 09:19:37', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (27.08, 375, 62, '2024-11-25 05:42:46', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (177.62, 27, 43, '2024-10-04 05:44:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (138.19, 532, 45, '2024-02-02 13:06:11', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (17.08, 26, 20, '2024-03-29 04:39:12', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (128.34, 146, 10, '2024-08-28 03:18:41', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (85.86, 435, 47, '2024-12-31 03:26:04', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (52.23, 589, 15, '2025-03-03 23:36:50', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (32.51, 461, 85, '2024-04-24 13:07:55', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (236.78, 582, 94, '2024-11-21 00:57:26', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (124.54, 567, 57, '2024-04-29 11:26:18', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (196.49, 415, 20, '2024-01-21 12:24:21', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (128.68, 217, 38, '2024-09-30 22:49:33', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (114.44, 194, 1, '2024-09-08 12:51:10', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (103.23, 447, 44, '2024-04-07 22:06:03', 'estornada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (103.18, 541, 28, '2024-01-06 03:20:56', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (163.99, 591, 63, '2024-08-30 00:53:43', 'negada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (195.62, 176, 28, '2025-01-14 03:56:10', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (218.34, 440, 25, '2024-02-17 22:28:39', 'aprovada');
INSERT INTO transacao (valor, id_cartao_categoria, id_estabelecimento, data_tempo_transacao, status) VALUES (13.62, 28, 53, '2024-05-18 05:06:07', 'aprovada');

COMMIT;

CREATE VIEW vw_cartao_colaborador AS (
    SELECT
        ca.id AS id_cartao,
        co.nome AS colaborador,
        co.cpf,
        ca.numero_cartao,
        ca.validade,
        ca.bandeira,
        ca.tipo_pagamento
    FROM cartao ca
    JOIN colaborador co
    ON ca.id_colaborador = co.id
);

CREATE VIEW vw_cartoes_vencidos AS (
    SELECT
        id,
        numero_cartao,
        validade
    FROM cartao
    WHERE validade < CURRENT_DATE
);

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

CREATE VIEW vw_colaborador_completo AS (
    SELECT
        c.id,
        c.nome,
        c.cpf,
        c.telefone,
        c.email,
        e.cep,
        e.rua,
        e.numero,
        e.bairro,
        e.cidade,
        e.estado,
        e.complemento
    FROM colaborador c
    JOIN endereco e
    ON c.id_endereco = e.id
);

CREATE VIEW vw_dashboard_gestor AS (
    SELECT
        cb.nome AS categoria_beneficio,

        cb.valor_recarga,

        COUNT(DISTINCT ccb.id_cartao) AS total_cartoes_ativos,
        COUNT(DISTINCT c.id_colaborador) AS total_colaboradores_utilizando,

        COALESCE(SUM(ccb.saldo), 0) AS saldo_total_disponivel,

        COUNT(t.id) AS quantidade_transacoes,
        COALESCE(SUM(t.valor), 0) AS valor_total_transacionado,
        COALESCE(AVG(t.valor), 0) AS ticket_medio,

        COUNT(DISTINCT e.id) AS estabelecimentos_utilizados,

        MAX(t.data_tempo_transacao) AS ultima_transacao,

        CASE
            WHEN COALESCE(SUM(ccb.saldo), 0) + COALESCE(SUM(t.valor), 0) > 0
            THEN ROUND(
                (
                    COALESCE(SUM(t.valor), 0) /
                    (
                        COALESCE(SUM(ccb.saldo), 0) +
                        COALESCE(SUM(t.valor), 0)
                    )
                ) * 100,
                2
            )
            ELSE 0
        END AS percentual_utilizado

    FROM categoria_beneficio cb

    LEFT JOIN cartao_categoria_beneficio ccb
    ON ccb.id_categoria_beneficio = cb.id
    AND ccb.ativo = TRUE

    LEFT JOIN cartao c
    ON c.id = ccb.id_cartao

    LEFT JOIN transacao t
    ON t.id_cartao = c.id

    LEFT JOIN estabelecimento e
    ON e.id = t.id_estabelecimento

    GROUP BY
        cb.nome,
        cb.valor_recarga
);

CREATE VIEW vw_estabelecimento_mcc AS (
    SELECT
        e.id,
        e.nome,
        e.cnpj,
        e.telefone,
        e.email,
        m.codigo AS codigo_mcc,
        m.descricao AS descricao_mcc,
        e.status,
        e.data_cadastro
    FROM estabelecimento e
    JOIN mcc m
    ON e.id_mcc = m.id
);

CREATE VIEW vw_estabelecimentos_ativos AS (
    SELECT *
    FROM estabelecimento
    WHERE status = TRUE
);

CREATE VIEW vw_gasto_categoria AS (
    SELECT
        cb.nome AS categoria,
        SUM(t.valor) AS total_gasto
    FROM transacao t

    JOIN estabelecimento e
    ON t.id_estabelecimento = e.id

    JOIN mcc m
    ON e.id_mcc = m.id

    JOIN categoria_beneficio_mcc cbm
    ON cbm.id_mcc = m.id

    JOIN categoria_beneficio cb
    ON cbm.id_categoria = cb.id

    GROUP BY cb.nome;
);

CREATE VIEW vw_ranking_estabelecimentos AS (
    SELECT
        e.nome,
        COUNT(t.id) AS qtd_transacoes,
        SUM(t.valor) AS faturamento
    FROM estabelecimento e

    JOIN transacao t
    ON t.id_estabelecimento = e.id

    GROUP BY e.nome
    ORDER BY faturamento DESC
);

CREATE VIEW vw_saldo_beneficio AS (
    SELECT
        ccb.id,
        co.nome AS colaborador,
        ca.numero_cartao,
        cb.nome AS categoria,
        ccb.saldo,
        ccb.ativo
    FROM cartao_categoria_beneficio ccb
    JOIN cartao ca
    ON ccb.id_cartao = ca.id
    JOIN colaborador co
    ON ca.id_colaborador = co.id
    JOIN categoria_beneficio cb
    ON ccb.id_categoria_beneficio = cb.id
);

CREATE VIEW vw_total_gasto_colaborador AS (
    SELECT
        co.id,
        co.nome,
        SUM(t.valor) AS total_gasto,
        COUNT(t.id) AS quantidade_transacoes
    FROM colaborador co

    JOIN cartao ca
    ON ca.id_colaborador = co.id

    JOIN transacao t
    ON t.id_cartao = ca.id

    GROUP BY co.id, co.nome
);

CREATE VIEW vw_transacoes_completas AS (
    SELECT
        t.id,
        t.valor,
        t.data_tempo_transacao,
        
        co.nome AS colaborador,
        ca.numero_cartao,

        es.nome AS estabelecimento,
        es.cnpj,

        m.codigo AS codigo_mcc,
        m.descricao AS descricao_mcc

    FROM transacao t

    JOIN cartao ca
    ON t.id_cartao = ca.id

    JOIN colaborador co
    ON ca.id_colaborador = co.id

    JOIN estabelecimento es
    ON t.id_estabelecimento = es.id

    JOIN mcc m
    ON es.id_mcc = m.id
);

CREATE VIEW vw_transacoes_mes AS (
      SELECT *
      FROM transacao
      WHERE DATE_TRUNC('month', data_tempo_transacao)
            = DATE_TRUNC('month', CURRENT_DATE)
);
