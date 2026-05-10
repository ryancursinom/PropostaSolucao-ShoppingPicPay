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