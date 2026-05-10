
CREATE TABLE categoria_beneficio_mcc (
    id              SERIAL   PRIMARY KEY,
    id_categoria    INTEGER  NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
    id_mcc          INTEGER  NOT NULL REFERENCES mcc(id)                 ON DELETE CASCADE,
    UNIQUE (id_categoria, id_mcc)
);