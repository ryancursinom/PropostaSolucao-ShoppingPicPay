CREATE TABLE IF NOT EXISTS log_cartao_categoria_beneficio (
	id serial NOT NULL UNIQUE,
	id_cartao_categoria_beneficio integer NOT NULL,
	tipo_mudanca varchar(10) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	PRIMARY KEY (id)
);