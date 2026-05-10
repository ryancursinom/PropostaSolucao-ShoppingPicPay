CREATE TABLE transacao(
	id SERIAL PRIMARY KEY,
	valor NUMERIC(18,6) NOT NULL CHECK (valor > 0),
	id_cartao_categoria INTEGER NOT NULL REFERENCES cartao_categoria_beneficio(id),
	id_estabelecimento INTEGER NOT NULL REFERENCES estabelecimento(id),
	data_tempo_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR(20) DEFAULT 'aprovada' CHECK (status IN ('aprovada', 'negada', 'estornada'))
);