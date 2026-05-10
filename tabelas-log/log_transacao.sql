CREATE TABLE IF NOT EXISTS log_transacao (
	id serial PRIMARY KEY,
	id_transacao integer NOT NULL,
	tipo_mudanca varchar(255) NOT NULL,
	data_hora_mudanca timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
	usuario_responsavel varchar(20) NOT NULL,
	status varchar(20) NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT constraint_status CHECK (lower(status) IN ('aprovada', 'negada', 'estornada')),
	CONSTRAINT constraint_tipo_mudanca CHECK (lower(tipo_mudanca) IN ('insert', 'update', 'delete', 'truncate'))
);