CREATE TABLE mcc (
    id          SERIAL       PRIMARY KEY,
    codigo      INTEGER      UNIQUE NOT NULL,
    descricao   VARCHAR(120)
);