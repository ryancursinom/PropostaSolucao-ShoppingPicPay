DROP TABLE IF EXISTS transacao                  CASCADE;
DROP TABLE IF EXISTS cartao_categoria_beneficio CASCADE;
DROP TABLE IF EXISTS categoria_beneficio_mcc    CASCADE;
DROP TABLE IF EXISTS categoria_beneficio        CASCADE;
DROP TABLE IF EXISTS mcc                        CASCADE;
DROP TABLE IF EXISTS cartao                     CASCADE;
DROP TABLE IF EXISTS estabelecimento            CASCADE;
DROP TABLE IF EXISTS colaborador                CASCADE;
DROP TABLE IF EXISTS endereco                   CASCADE;

CREATE TABLE endereco (
    id           SERIAL PRIMARY KEY,
    cep          VARCHAR(9)  NOT NULL,
    numero       VARCHAR(10),
    rua          VARCHAR(30) NOT NULL,
    bairro       VARCHAR(30) NOT NULL,
    cidade       VARCHAR(25) NOT NULL,
    estado       CHAR(2)
                 CHECK (
                     estado IN (
                         'SP','RJ','MG','ES','PR','SC','RS',
                         'BA','PE','CE','GO','MT','MS',
                         'DF','AM','PA','AC','AP','RO',
                         'RR','TO','MA','PI','RN','PB',
                         'AL','SE'
                     )
                 ),
    complemento  VARCHAR(50)
);

CREATE TABLE colaborador (
    id              SERIAL       PRIMARY KEY,
    cpf             CHAR(11)     UNIQUE NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    telefone        VARCHAR(20)  UNIQUE,
    email           VARCHAR(255) UNIQUE NOT NULL,
    data_nascimento DATE         NOT NULL,
    status          VARCHAR(20)  DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
    id_endereco     INTEGER      NOT NULL REFERENCES endereco(id)
);

CREATE TABLE cartao (
    id              SERIAL       PRIMARY KEY,
    id_colaborador  INTEGER      NOT NULL REFERENCES colaborador(id) ON DELETE CASCADE,
    numero_cartao   VARCHAR(19)  UNIQUE NOT NULL,
    validade        DATE         NOT NULL,
    bandeira        VARCHAR(50)  NOT NULL,
    tipo_pagamento  VARCHAR(50)  DEFAULT 'credito',
    cvv             CHAR(4)      NOT NULL
);

CREATE TABLE categoria_beneficio (
    id          SERIAL      PRIMARY KEY,
    nome        VARCHAR(50) UNIQUE NOT NULL,
    descricao   VARCHAR(255)
);

CREATE TABLE cartao_categoria_beneficio (
    id                       SERIAL        PRIMARY KEY,
    id_cartao                INTEGER       NOT NULL REFERENCES cartao(id)              ON DELETE CASCADE,
    id_categoria_beneficio   INTEGER       NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
    saldo                    NUMERIC(18,6) NOT NULL DEFAULT 0  CHECK (saldo >= 0),
    ativo                    BOOLEAN       DEFAULT TRUE,
    UNIQUE (id_cartao, id_categoria_beneficio)
);

CREATE TABLE mcc (
    id          SERIAL       PRIMARY KEY,
    codigo      INTEGER      UNIQUE NOT NULL,
    descricao   VARCHAR(120)
);

CREATE TABLE categoria_beneficio_mcc (
    id              SERIAL   PRIMARY KEY,
    id_categoria    INTEGER  NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
    id_mcc          INTEGER  NOT NULL REFERENCES mcc(id)                 ON DELETE CASCADE,
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
    id_endereco    INTEGER                  NOT NULL REFERENCES endereco(id)
);

CREATE TABLE transacao (
    id                    SERIAL                   PRIMARY KEY,
    valor                 NUMERIC(18,6)            NOT NULL CHECK (valor > 0),
    id_cartao_categoria   INTEGER                  NOT NULL REFERENCES cartao_categoria_beneficio(id),
    id_estabelecimento    INTEGER                  NOT NULL REFERENCES estabelecimento(id),
    data_tempo_transacao  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status                VARCHAR(20)              DEFAULT 'aprovada'CHECK (status IN ('aprovada', 'negada', 'estornada'))
);


CREATE TABLE IF NOT EXISTS log_endereco_colaborador (
	id serial PRIMARY KEY,
	tipo_mudanca varchar(10) NOT NULL,
	id_colaborador integer NOT NULL,
	id_endereco integer NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_endereco_estabelecimento (
	id serial PRIMARY KEY,
	tipo_mudanca varchar(10) NOT NULL,
	id_estabelecimento integer NOT NULL,
	id_endereco integer NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_colaborador (
	id serial PRIMARY KEY,
	id_colaborador integer NOT NULL,
	tipo_mudanca varchar(10) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status boolean NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status::text) IN ('true', 'false')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_estabelecimento (
	id serial PRIMARY KEY,
	id_estabelecimento integer NOT NULL,
	tipo_mudanca varchar(10) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status boolean NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status::text) IN ('true', 'false')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_cartao (
	id serial PRIMARY KEY,
	id_cartao integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status) IN ('ativo', 'inativo')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_cartao_categoria_beneficio (
	id serial PRIMARY KEY,
	id_cartao_categoria_beneficio integer NOT NULL,
	tipo_mudanca varchar(10) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status) IN ('ativo', 'inativo')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_categoria_beneficio_mcc (
	id serial PRIMARY KEY,
	id_categoria_beneficio_mcc integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);

CREATE TABLE IF NOT EXISTS log_transacao (
	id serial PRIMARY KEY,
	id_transacao integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status) IN ('aprovada', 'negada', 'estornada')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);