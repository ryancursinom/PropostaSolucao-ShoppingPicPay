-- 1. View de dados completos do colaborador

CREATE VIEW vw_colaborador_completo AS
SELECT
    c.id,
    c.nome,
    c.cpf,
    c.telefone,
    c.email,
    e.cep,
    e.rua,
    e.numero,
    e.bairro,
    e.cidade,
    e.estado,
    e.complemento
FROM colaborador c
JOIN endereco e
ON c.id_endereco = e.id;


-- 2. View de cartões com dono


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



-- 3. View de saldo por categoria de benefício

CREATE VIEW vw_saldo_beneficio AS
SELECT
    ccb.id,
    co.nome AS colaborador,
    ca.numero_cartao,
    cb.nome AS categoria,
    ccb.saldo,
    ccb.ativo
FROM cartao_categoria_beneficio ccb
JOIN cartao ca
ON ccb.id_cartao = ca.id
JOIN colaborador co
ON ca.id_colaborador = co.id
JOIN categoria_beneficio cb
ON ccb.id_categoria_beneficio = cb.id;



-- 4. View de estabelecimentos com MCC

CREATE VIEW vw_estabelecimento_mcc AS
SELECT
    e.id,
    e.nome,
    e.cnpj,
    e.telefone,
    e.email,
    m.codigo AS codigo_mcc,
    m.descricao AS descricao_mcc,
    e.status,
    e.data_cadastro
FROM estabelecimento e
JOIN mcc m
ON e.id_mcc = m.id;



-- 5. View completa de transações

CREATE VIEW vw_transacoes_completas AS
SELECT
    t.id,
    t.valor,
    t.data_tempo_transacao,
    
    co.nome AS colaborador,
    ca.numero_cartao,

    es.nome AS estabelecimento,
    es.cnpj,

    m.codigo AS codigo_mcc,
    m.descricao AS descricao_mcc

FROM transacao t

JOIN cartao ca
ON t.id_cartao = ca.id

JOIN colaborador co
ON ca.id_colaborador = co.id

JOIN estabelecimento es
ON t.id_estabelecimento = es.id

JOIN mcc m
ON es.id_mcc = m.id;




-- 6. View de gastos por colaborador

CREATE VIEW vw_total_gasto_colaborador AS
SELECT
    co.id,
    co.nome,
    SUM(t.valor) AS total_gasto,
    COUNT(t.id) AS quantidade_transacoes
FROM colaborador co

JOIN cartao ca
ON ca.id_colaborador = co.id

JOIN transacao t
ON t.id_cartao = ca.id

GROUP BY co.id, co.nome;




-- 7. View de gastos por categoria de benefício


CREATE VIEW vw_gasto_categoria AS
SELECT
    cb.nome AS categoria,
    SUM(t.valor) AS total_gasto
FROM transacao t

JOIN estabelecimento e
ON t.id_estabelecimento = e.id

JOIN mcc m
ON e.id_mcc = m.id

JOIN categoria_beneficio_mcc cbm
ON cbm.id_mcc = m.id

JOIN categoria_beneficio cb
ON cbm.id_categoria = cb.id

GROUP BY cb.nome;



-- 8. View de estabelecimentos ativos

CREATE VIEW vw_estabelecimentos_ativos AS
SELECT *
FROM estabelecimento
WHERE status = TRUE;




-- 9. View de cartões vencidos

CREATE VIEW vw_cartoes_vencidos AS
SELECT
    id,
    numero_cartao,
    validade
FROM cartao
WHERE validade < CURRENT_DATE;



-- 10. View de transações do mês

CREATE VIEW vw_transacoes_mes AS
SELECT *
FROM transacao
WHERE DATE_TRUNC('month', data_tempo_transacao)
      = DATE_TRUNC('month', CURRENT_DATE);


-- 11. View de ranking de estabelecimentos

CREATE VIEW vw_ranking_estabelecimentos AS
SELECT
    e.nome,
    COUNT(t.id) AS qtd_transacoes,
    SUM(t.valor) AS faturamento
FROM estabelecimento e

JOIN transacao t
ON t.id_estabelecimento = e.id

GROUP BY e.nome
ORDER BY faturamento DESC;



-- 12. View de categorias permitidas por MCC

CREATE VIEW vw_categoria_mcc AS
SELECT
    cb.nome AS categoria,
    m.codigo,
    m.descricao
FROM categoria_beneficio_mcc cbm

JOIN categoria_beneficio cb
ON cbm.id_categoria = cb.id

JOIN mcc m
ON cbm.id_mcc = m.id;










-- 1. vw_colaborador_completo
-- View responsável por reunir os dados pessoais do colaborador junto às informações de endereço, facilitando consultas completas sem necessidade de múltiplos JOINs.

-- 2. vw_cartao_colaborador
-- View que relaciona cartões aos seus respectivos colaboradores, permitindo visualizar rapidamente quem é o titular de cada cartão.

-- 3. vw_saldo_beneficio
-- View utilizada para consultar os saldos disponíveis de cada categoria de benefício vinculada aos cartões dos colaboradores.

-- 4. vw_estabelecimento_mcc
-- View que exibe os estabelecimentos juntamente com seus respectivos códigos MCC e descrições de categoria comercial.

-- 5. vw_transacoes_completas
-- View analítica que centraliza informações das transações, incluindo colaborador, cartão, estabelecimento e MCC em uma única consulta.

-- 6. vw_total_gasto_colaborador
-- View criada para calcular o total gasto e a quantidade de transações realizadas por cada colaborador.

-- 7. vw_gasto_categoria
-- View responsável por consolidar os gastos realizados em cada categoria de benefício com base nos MCCs associados.

-- 8. vw_estabelecimentos_ativos
-- View que retorna apenas os estabelecimentos ativos no sistema, simplificando consultas operacionais.

-- 9. vw_cartoes_vencidos
-- View utilizada para identificar cartões cuja validade já expirou, auxiliando no controle e manutenção do sistema.

-- 10. vw_transacoes_mes
-- View que filtra automaticamente as transações realizadas no mês atual, facilitando relatórios mensais e dashboards.

-- 11. vw_ranking_estabelecimentos
-- View responsável por gerar um ranking de estabelecimentos com base na quantidade de transações e no faturamento movimentado.

-- 12. vw_categoria_mcc
-- View que relaciona categorias de benefício aos códigos MCC permitidos, auxiliando na validação das regras de utilização dos benefícios.