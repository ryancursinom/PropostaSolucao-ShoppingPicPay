-- View: vw_estabelecimento_mcc
-- Explicação: View que exibe os estabelecimentos juntamente com seus respectivos códigos MCC e descrições de categoria comercial.

CREATE VIEW vw_estabelecimento_mcc AS (
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
    ON e.id_mcc = m.id
);
