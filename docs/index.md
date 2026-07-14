# FCS Developer Portal

Esta PoC organiza os serviços e recursos da Conexão Solidária em um catálogo único. Cada repositório mantém seu próprio `catalog-info.yaml` e documentação TechDocs.

O portal não executa deploys, não expõe segredos e só possui permissões de leitura no Kubernetes. O acesso externo é protegido pelo BasicAuth do Traefik.

## Operação

- Catálogo: componentes, APIs, sistema e recursos compartilhados.
- Kubernetes: estado operacional sem permissão para deletar pods ou alterar recursos.
- TechDocs: documentação processada localmente pelo Backstage e publicada no MinIO interno.
- Observabilidade: links de serviço para o Datadog; nenhuma credencial Datadog é entregue ao portal.
