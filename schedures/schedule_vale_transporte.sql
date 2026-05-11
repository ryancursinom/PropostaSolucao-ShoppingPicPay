SELECT cron.schedule( 
	'debito_vale_transporte', 
	'30 5  1 * *',
	'CALL prc_primeiro_dia_util()' 
);