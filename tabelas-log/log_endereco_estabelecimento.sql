CREATE TABLE IF NOT EXISTS log_endereco_estabelecimento (
	id serial NOT NULL UNIQUE,
	tipo_mudanca varchar(10) NOT NULL,
	id_estabelecimento integer NOT NULL,
	id_endereco integer NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	PRIMARY KEY (id)
);