CREATE TABLE IF NOT EXISTS log_endereco_colaborador (
	id serial PRIMARY KEY,
	tipo_mudanca varchar(10) NOT NULL,
	id_colaborador integer NOT NULL,
	id_endereco integer NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);