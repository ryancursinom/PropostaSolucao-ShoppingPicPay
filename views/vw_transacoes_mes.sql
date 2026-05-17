-- View: vw_transacoes_mes
-- Explicação: View que filtra automaticamente as transações realizadas no mês atual, facilitando relatórios mensais e dashboards.

CREATE VIEW vw_transacoes_mes AS (
      SELECT *
      FROM transacao
      WHERE DATE_TRUNC('month', data_tempo_transacao)
            = DATE_TRUNC('month', CURRENT_DATE)
);
