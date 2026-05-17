-- View: vw_colaborador_completo
-- Explicação: View responsável por reunir os dados pessoais do colaborador junto às informações de endereço, facilitando consultas completas sem necessidade de múltiplos JOINs.

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
