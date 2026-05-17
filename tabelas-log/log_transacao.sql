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