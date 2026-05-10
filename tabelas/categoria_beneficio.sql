CREATE TABLE categoria_beneficio (
    id          SERIAL      PRIMARY KEY,
    nome        VARCHAR(50) UNIQUE NOT NULL,
    descricao   VARCHAR(255)
);