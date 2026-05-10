CREATE TABLE colaborador (
    id              SERIAL       PRIMARY KEY,
    cpf             CHAR(11)     UNIQUE NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    telefone        VARCHAR(20)  UNIQUE,
    email           VARCHAR(255) UNIQUE NOT NULL,
    data_nascimento DATE         NOT NULL,
    id_endereco     INTEGER      NOT NULL REFERENCES endereco(id)
);