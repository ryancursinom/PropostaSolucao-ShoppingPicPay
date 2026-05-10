CREATE TABLE IF NOT EXISTS log_categoria_beneficio_mcc (
	id serial PRIMARY KEY,
	id_categoria_beneficio_mcc integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);