CREATE TABLE log_colaborador (
    id                    SERIAL                    PRIMARY KEY,
    id_colaborador        INTEGER                   NOT NULL,
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
