# Sistema de Benefícios Inteligente - Regras de Negócio

## 1. Contexto do Projeto

Este projeto foi desenvolvido por João Pedro Souza, Lorenzo Lima
Mariana Marrão, Matheus Rezende, Raphaely Mendes e Ryan Cursino, alunos do 2°ano G com o objetivo de simular um **Motor de Benefícios Inteligente**, onde colaboradores possuem cartões com saldos separados por categorias (alimentação, refeição e transporte) para a Disciplina de Modelagem de Dados, lecionada pelo professor Marcelo Silva.

O objetivo da solução foi é implementar em **PostgreSQL** os conceitos de modelagem relacional, normalização, integridade referencial e automação com triggers, functions e procedures.

---

## 2. Objetivo do Sistema

O sistema tem como objetivo principal:

- Controlar o uso de benefícios corporativos;
- Impedir uso indevido de saldo entre categorias;
- Garantir que transações respeitem regras de MCC;
- Manter integridade financeira do sistema;
- Fornecer relatórios gerenciais através de views.

---

## 3. Padrões de Dados (OBRIGATÓRIO)

Todos os dados textuais do sistema devem seguir o padrão:

- Tudo em **minúsculo**;
- Sem acentos;
- Sem caracteres especiais desnecessários;
- Sem duplicidade de formatos.

### Exemplo:
- Alimentação → alimentacao  
- São Paulo → sao paulo  
- Cartão Refeição → cartao refeicao  

---

## 4. Regra de MCC (Merchant Category Code)

O sistema trabalha apenas com MCCs relacionados a:

- alimentação
- refeição
- transporte

---

## 5. Regras Gerais do Sistema

### 5.1 Colaborador
- cada colaborador possui um único endereço;
- pode possuir um ou mais cartões;
- deve ser identificado por CPF único.

---

### 5.2 Cartão
- pertence obrigatoriamente a um colaborador;
- pode possuir múltiplas categorias de benefício;
- não pode existir cartão sem vínculo com colaborador.

---

### 5.3 Categoria de Benefício
- define o tipo de saldo disponível;
- exemplos: alimentacao, refeicao, transporte;
- deve estar sempre associada a MCCs válidos.

---

### 5.4 MCC
- representa o tipo de estabelecimento;
- deve ser compatível com categorias de benefício;
- serve como filtro de validação de transações.

---

### 5.5 Estabelecimento
- deve possuir um MCC obrigatório;
- deve estar vinculado a um endereço;
- somente pode processar transações compatíveis com seu MCC.

---

### 5.6 Transação
- registra todas as compras realizadas;
- consome saldo da categoria associada ao cartão;
- depende de validação de saldo e MCC.

---

## 6. Regras de Validação (NEGÓCIO)

Uma transação só pode ser aprovada se:

- houver saldo disponível na categoria do cartão;
- o MCC do estabelecimento for compatível com a categoria;
- o status do cartão estiver ativo;
- o valor da transação for maior que zero.

Caso contrário:
- a transação deve ser negada;
- o sistema deve registrar a tentativa.

---

## 7. Regras de Integridade e Segurança

O sistema utiliza:

- PRIMARY KEY para identificação única;
- FOREIGN KEY para relacionamento entre tabelas;
- UNIQUE para evitar duplicidade;
- CHECK para validação de regras de domínio;
- DEFAULT para valores padrão;
- ON DELETE CASCADE para manter consistência referencial.

---

## 8. Regras de Automação 

### 8.1 Function
Responsável por:
- Validar se a transação está correta antes de inserir no banco (MCC e saldo combinam com a compra)
- Validar código MCC para confirmar uma transação.
- Preencher as tabelas de Log, inserindo quem fez a ação, qual ação foi realizada e os campos que foram alterados em caso de update.

---

### 8.2 Trigger
Responsável por:
- Validar se a transação está correta antes de inserir no banco (MCC e saldo combinam com a compra)
- Preencher as tabelas de Log, inserindo quem fez a ação, qual ação foi realizada e os campos que foram alterados em caso de update.


---

### 8.3 Procedure
Responsável por:
- Fazer a recarga mensal do **Vale Alimentação (VA)**
- Fazer a recarga mensal do **Vale Refeição (VR)**
- Fazer a recarga mensal do **Vale Transporte (VT)**
- Processar a recarga do VA no quinto dia útil, porém não vamos colocar ele no script final pois sua utilidade só aparece junto com os códigos presentes na pasta **schedules**.
- Processar a recarga do VT no primeiro dia útil, porém não vamos colocar ele no script final pois sua utilidade só aparece junto com os códigos presentes na pasta **schedules**.

---

### 8.4 View
Responsável por:
## 8.4 Views - Explicações

- **vw_cartao_colaborador**  
  View que relaciona cartões aos seus respectivos colaboradores, permitindo visualizar rapidamente quem é o titular de cada cartão.

- **vw_cartoes_vencidos**  
  View utilizada para identificar cartões cuja validade já expirou, auxiliando no controle e manutenção do sistema.

- **vw_categoria_mcc**  
  View que relaciona categorias de benefício aos códigos MCC permitidos, auxiliando na validação das regras de utilização dos benefícios.

- **vw_colaborador_completo**  
  View responsável por reunir os dados pessoais do colaborador junto às informações de endereço, facilitando consultas completas sem necessidade de múltiplos JOINs.

- **vw_dashboard_gestor**  
  View consolidada para painel gerencial, reunindo informações estratégicas como empresas, categorias e indicadores de desempenho.

- **vw_empresas**  
  View que consolida informações gerais das empresas, incluindo dados agregados de transações e estrutura organizacional.

- **vw_empresas_categoria**  
  View que analisa o desempenho das empresas por categoria, permitindo visualizar volume e valor de transações segmentadas.

- **vw_estabelecimento_mcc**  
  View que exibe os estabelecimentos juntamente com seus respectivos códigos MCC e descrições de categoria comercial.

- **vw_estabelecimentos_ativos**  
  View que retorna apenas os estabelecimentos ativos no sistema, simplificando consultas operacionais.

- **vw_gasto_categoria**  
  View responsável por consolidar os gastos realizados em cada categoria de benefício com base nos MCCs associados.

- **vw_ranking_estabelecimentos**  
  View que gera um ranking de estabelecimentos com base na quantidade de transações e no faturamento movimentado.

- **vw_saldo_beneficio**  
  View utilizada para consultar os saldos disponíveis de cada categoria de benefício vinculada aos cartões dos colaboradores.

- **vw_total_gasto_colaborador**  
  View que calcula o total gasto e a quantidade de transações realizadas por cada colaborador.

- **vw_transacoes_completas**  
  View analítica que centraliza informações das transações, incluindo colaborador, cartão, estabelecimento e MCC em uma única consulta.

- **vw_transacoes_mes**  
  View que filtra automaticamente as transações realizadas no mês atual, facilitando relatórios mensais e dashboards.
---

## 9. Requisitos Técnicos do Projeto

O sistema atende aos requisitos mínimos obrigatórios:

- mínimo de 10 tabelas normalizadas;
- mínimo de 500 registros para testes;
- uso de views, functions, procedures e triggers;
- implementação de regras de negócio diretamente no banco de dados.

---

## 10. Conclusão

O sistema implementa um modelo robusto de gestão de benefícios corporativos, garantindo integridade dos dados, controle de regras de negócio, automação de processos financeiros, escalabilidade para ambientes corporativos reais.