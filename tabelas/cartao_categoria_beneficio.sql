CREATE TABLE cartao_categoria_beneficio(
	id SERIAL PRIMARY KEY,
	id_cartao INTEGER NOT NULL REFERENCES cartao(id) ON DELETE CASCADE,
	id_categoria_beneficio INTEGER NOT NULL REFERENCES categoria_beneficio(id) ON DELETE CASCADE,
	UNIQUE(id_cartao, id_categoria_beneficio),
	saldo NUMERIC(18,6) NOT NULL DEFAULT 0 CHECK (saldo >=0),
	ativo BOOLEAN DEFAULT TRUE
);