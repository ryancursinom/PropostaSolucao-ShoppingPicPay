SELECT cron.schedule( 
	'debito_vale_alimentacao', 
	'30 5  * * 1-5',
	'CALL prc_quinto_dia_util())' 
);