CREATE TABLE IF NOT EXISTS log_categoria_beneficio_mcc (
	id serial NOT NULL UNIQUE,
	id_categoria_beneficio_mcc integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	PRIMARY KEY (id)
);