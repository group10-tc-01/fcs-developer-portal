# FCS Developer Portal

Portal interno da plataforma **Conexão Solidária**, construído com
[Backstage](https://backstage.io/). Centraliza o catálogo de componentes, a
documentação técnica, as execuções do GitHub Actions e a visão operacional
somente leitura do K3s.

> Componente de plataforma que apoia os microsserviços `fcs-identity`,
> `fcs-campaign`, `fcs-donations`, `fcs-donation-worker`,
> `fcs-notifications`, `fcs-audit-logs`, `fcs-bff` e `fcs-web`.

---

## Responsabilidades

- Descobrir e apresentar os componentes da plataforma pelo catálogo Backstage.
- Renderizar a documentação versionada de cada repositório com TechDocs.
- Exibir, por componente, as execuções do GitHub Actions e os recursos do
  Kubernetes permitidos ao portal.
- Autenticar integrantes da organização GitHub `group10-tc-01`.
- Manter uma visão operacional de leitura, sem ações de deploy, remoção de pods
  ou acesso a Secrets Kubernetes.

O portal **não** é dono das aplicações de negócio, não armazena segredos em
Git e não substitui os pipelines de entrega dos serviços.

Documentação da arquitetura integrada:
[group10-tc-01/fcs-fase05-docs](https://github.com/group10-tc-01/fcs-fase05-docs).

---

## Funcionalidades

| Área           | O que oferece                                                   |
| -------------- | --------------------------------------------------------------- |
| Catálogo       | Componentes, sistemas, APIs, recursos e relações da plataforma  |
| TechDocs       | Documentação versionada nos próprios repositórios               |
| GitHub Actions | Histórico de workflows para os componentes anotados no catálogo |
| Kubernetes     | Pods e workloads permitidos pela ServiceAccount de leitura      |
| Autenticação   | Login GitHub restrito a membros de `group10-tc-01`              |

Os membros da organização são sincronizados no catálogo pelo provedor GitHub
Org. O primeiro ciclo inicia após a subida do backend e os ciclos seguintes
ocorrem a cada cinco minutos.

---

## Estrutura do projeto

```text
packages/
  app/                         # Frontend Backstage e navegação do portal
  backend/                     # Backend, catálogo, auth e integrações
catalog/                       # Entidades de fundação da plataforma
docs/                          # Fonte dos TechDocs e ADRs do portal
k8s/                           # Manifests do Deployment, RBAC, Service e Ingress
scripts/start-local.ps1        # Inicialização local com configurações descartáveis
```

---

## Pré-requisitos

- [Node.js 22 ou 24](https://nodejs.org/)
- [Corepack](https://nodejs.org/api/corepack.html) habilitado para usar Yarn 4
- Docker, somente se for necessário gerar a imagem ou usar ferramentas locais
  auxiliares

---

## Desenvolvimento local

O desenvolvimento local não depende da VPS ou do K3s. Use valores descartáveis
em `.env` e `app-config.local.yaml`; ambos são ignorados pelo Git e não devem
receber credenciais de produção.

```powershell
corepack enable
yarn install --immutable
.\scripts\start-local.ps1
```

O frontend fica disponível em `http://localhost:3000` e o backend em
`http://localhost:7007`.

Para validar o repositório:

```powershell
yarn prettier:check
yarn tsc
yarn build:all
```

---

## Autenticação e acesso

Em produção, o portal usa OAuth da GitHub App **FCS Developer Portal**. O
backend sincroniza os membros de `group10-tc-01` como entidades `User` e só
emite uma sessão quando o usuário autenticado possui uma entidade equivalente
no catálogo. Contas externas à organização não concluem o login.

O provedor Guest é mantido apenas para desenvolvimento local e não é habilitado
na configuração de produção.

A GitHub App deve estar instalada na organização com permissões somente leitura
para **Actions**, **Contents**, **Commit statuses**, **Members** e **Metadata**.
Ela não deve receber permissões de escrita.

---

## Kubernetes e plataforma

O portal é implantado no namespace `fcs-developer-portal`. Seus manifests
mantêm o Deployment, PVC, Service, Ingress HTTPS, RBAC de leitura e o recurso
`InfisicalStaticSecret`.

Os recursos compartilhados são responsabilidade do `fcs-infra`:

- K3s, Traefik, cert-manager e certificados TLS;
- namespace, políticas e dependências da plataforma;
- Infisical Secrets Operator;
- MinIO interno, usado pelo publicador do TechDocs;
- Datadog e observabilidade do cluster.

O acesso público é feito pelo Traefik em:

- `https://fcs-devportal.flaviojcf.com.br`

---

## Secrets e variáveis

Os valores de runtime são sincronizados pelo Infisical no projeto
`fcs-platform-dd-uk`, ambiente `prod`, path `/developer-portal`.

| Chave                       | Uso                                                      |
| --------------------------- | -------------------------------------------------------- |
| `backstage-backend-secret`  | Assinatura interna de tokens e comunicação entre plugins |
| `github-app-id`             | Identificador da GitHub App                              |
| `github-app-client-id`      | Client ID OAuth da GitHub App                            |
| `github-app-client-secret`  | Client secret OAuth da GitHub App                        |
| `github-app-private-key`    | Chave privada PEM da GitHub App                          |
| `minio-techdocs-access-key` | Credencial S3 do publicador TechDocs                     |
| `minio-techdocs-secret-key` | Segredo S3 do publicador TechDocs                        |

O workflow de entrega reutilizável também exige, no environment GitHub
`production`, os secrets de conexão privada com o K3s e as variables
`VPS_HOST` e `VPS_DEPLOY_USER`, conforme o padrão documentado em
[`fcs-pipelines`](https://github.com/group10-tc-01/fcs-pipelines).

Nenhum valor de secret deve ser colocado em manifest, configuração versionada,
issue ou pull request.

---

## CI/CD

Os workflows em `.github/workflows/` validam, publicam a imagem no GHCR e
entregam o manifesto no K3s:

- `ci.yml`: instalação imutável, formatação, tipagem, build e publicação da
  imagem `ghcr.io/group10-tc-01/fcs-developer-portal` após push em `main`.
- `delivery.yml`: entrega via workflow reutilizável de `fcs-pipelines`, usando
  túnel SSH privado até a API do K3s.

O deploy usa o environment GitHub `production`; portanto, somente ocorre após a
aprovação configurada nesse environment.

---

## Observabilidade e operação

- Readiness: `/.backstage/health/v1/readiness`
- Liveness: `/.backstage/health/v1/liveness`
- Logs: coletados pelo Datadog Agent do cluster
- TechDocs: gerados localmente pelo Backstage e publicados no MinIO interno

O portal recebe permissões Kubernetes somente de leitura. Se uma tela não
exibir recursos de um componente, confirme o namespace, a annotation
`backstage.io/kubernetes-label-selector` e o RBAC em `k8s/rbac.yaml`.

---

## Como este componente atende ao hackathon

| Necessidade                        | Onde é atendida                                            |
| ---------------------------------- | ---------------------------------------------------------- |
| Documentação técnica e arquitetura | Catálogo, TechDocs, `docs/` e links para `fcs-fase05-docs` |
| Rastreabilidade de entrega         | Plugin de GitHub Actions por componente                    |
| Visão da plataforma em Kubernetes  | Plugin Kubernetes com acesso somente leitura               |
| Segurança de acesso à equipe       | OAuth GitHub e sincronização de membros de `group10-tc-01` |
| Operação em ambiente integrado     | Imagem GHCR, K3s, Traefik, Infisical e Datadog             |

## Documentação complementar

- [Contexto do domínio](CONTEXT.md)
- [Índice TechDocs](docs/index.md)
- [ADR 0001 — Backstage como portal](docs/adr/0001-backstage-portal.md)
- [ADR 0002 — Persistência e TechDocs da PoC](docs/adr/0002-poc-persistence-and-techdocs.md)
