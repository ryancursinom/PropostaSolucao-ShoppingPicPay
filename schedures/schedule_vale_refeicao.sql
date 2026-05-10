SELECT cron.schedule( 
	'debito_vale_refeicao', 
	'30 5  * * 1-5',
	'CALL proc_recarga_vr()' 
);