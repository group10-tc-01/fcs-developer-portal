# Contexto do portal

O FCS Developer Portal é a PoC de portal interno da equipe. Ele centraliza o catálogo de software, documentação técnica e uma leitura operacional do cluster K3s.

| Termo | Significado neste projeto |
| --- | --- |
| Developer Portal | Aplicação Backstage publicada em `fcs-devportal.flaviojcf.com.br`. |
| Catalog Entity | Registro versionado que descreve um componente, sistema, API, recurso ou time. |
| Component | Repositório ou serviço mantido pela equipe, como `fcs-identity`. |
| System | Agrupamento de negócio `conexao-solidaria`. |
| Resource | Dependência compartilhada, como K3s, Kafka, SQL Server ou Infisical. |
| Owner | Grupo responsável; nesta PoC, `group:default/fcs-team`. |
| TechDocs | Documentação Markdown de cada repositório, gerada pelo Backstage e publicada no MinIO. |
