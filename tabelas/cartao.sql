CREATE TABLE cartao(
	id SERIAL PRIMARY KEY,
	id_colaborador INTEGER NOT NULL REFERENCES colaborador(id) ON DELETE CASCADE,
	numero_cartao VARCHAR(19) UNIQUE NOT NULL,
	validade DATE NOT NULL,
	bandeira VARCHAR(50) NOT NULL,
	tipo_pagamento VARCHAR(50) DEFAULT 'credito',
	cvv char(4) NOT NULL
);