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