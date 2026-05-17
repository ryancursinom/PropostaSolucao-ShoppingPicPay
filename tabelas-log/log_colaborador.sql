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
