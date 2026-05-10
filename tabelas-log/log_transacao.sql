CREATE TABLE IF NOT EXISTS log_transacao (
	id serial NOT NULL UNIQUE,
	id_transacao integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	PRIMARY KEY (id)
);