-- View: vw_transacoes_completas
-- Explicação: View analítica que centraliza informações das transações, incluindo colaborador, cartão, estabelecimento e MCC em uma única consulta.

CREATE VIEW vw_transacoes_completas AS (
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
    ON es.id_mcc = m.id
);
