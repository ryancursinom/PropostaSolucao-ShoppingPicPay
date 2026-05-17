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