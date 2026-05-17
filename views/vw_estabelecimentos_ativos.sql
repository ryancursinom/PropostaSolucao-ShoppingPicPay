-- View: vw_estabelecimentos_ativos
-- Explicação: View que retorna apenas os estabelecimentos ativos no sistema, simplificando consultas operacionais.

CREATE VIEW vw_estabelecimentos_ativos AS (
    SELECT *
    FROM estabelecimento
    WHERE status = TRUE
);
