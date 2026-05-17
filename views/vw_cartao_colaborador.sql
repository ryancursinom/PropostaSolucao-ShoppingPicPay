-- View: vw_cartao_colaborador
-- Explicação: View que relaciona cartões aos seus respectivos colaboradores, permitindo visualizar rapidamente quem é o titular de cada cartão.

CREATE VIEW vw_cartao_colaborador AS
SELECT
    ca.id AS id_cartao,
    co.nome AS colaborador,
    co.cpf,
    ca.numero_cartao,
    ca.validade,
    ca.bandeira,
    ca.tipo_pagamento
FROM cartao ca
JOIN colaborador co
ON ca.id_colaborador = co.id;
