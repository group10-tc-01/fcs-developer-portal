# FCS Developer Portal

PoC Backstage para a equipe da Conexão Solidária. Centraliza catálogo, TechDocs e visibilidade somente leitura do K3s.

## Limites da PoC

- Uma réplica com SQLite em PVC.
- Acesso externo via BasicAuth no Traefik.
- Sem ações de deploy, exclusão de pods ou acesso a Secrets Kubernetes.
- TechDocs são gerados localmente pelo Backstage e publicados no MinIO interno.

## Desenvolvimento local

```powershell
yarn install --immutable
.\scripts\start-local.ps1
```

O arquivo `.env` e `app-config.local.yaml` já usam valores locais descartáveis, SQLite em memória, TechDocs local e Kubernetes desabilitado. Eles são ignorados pelo Git. Não use credenciais de produção nesse teste.

## Entrega

O manifesto em `k8s/` cria o portal no namespace `fcs-developer-portal`. A infraestrutura compartilhada cria o namespace, o MinIO e a sincronização de Secrets pelo Infisical. O workflow de entrega exige a aprovação do ambiente GitHub `production`.

## Segredos Infisical

No projeto `fcs-platform-dd-uk`, ambiente `prod`, path `/developer-portal`, cadastre:

| Chave                       | Uso                                                               |
| --------------------------- | ----------------------------------------------------------------- |
| `backstage-backend-secret`  | Chave interna de autenticação entre plugins.                      |
| `github-app-id`             | Identificador da GitHub App somente leitura.                      |
| `github-app-client-id`      | Client ID da GitHub App.                                          |
| `github-app-client-secret`  | Client secret da GitHub App.                                      |
| `github-app-private-key`    | Chave privada PEM da GitHub App.                                  |
| `minio-root-user`           | Usuário administrador do MinIO.                                   |
| `minio-root-password`       | Senha administrativa do MinIO.                                    |
| `minio-techdocs-access-key` | Chave S3 limitada ao bucket `techdocs`.                           |
| `minio-techdocs-secret-key` | Segredo S3 limitado ao bucket `techdocs`.                         |
| `traefik-basic-auth-users`  | Conteúdo `users` gerado por `htpasswd` para o Middleware Traefik. |

O valor de `traefik-basic-auth-users` deve conter o hash htpasswd completo, não senha em texto puro. Exemplo de geração local:

```powershell
docker run --rm httpd:2.4-alpine htpasswd -nbB portal '<senha-forte>'
```

## GitHub App

Instale uma GitHub App no owner `group10-tc-01`, limitada à organização, com permissões de leitura para Contents, Metadata e Commit statuses. Ela é usada para buscar descritores do catálogo e documentação; não deve ter permissões de escrita.

## Checklist de implantação

- [ ] Cadastrar os segredos do path `/developer-portal` no Infisical.
- [ ] Aplicar o Terraform de `fcs-infra` para criar namespace, MinIO e Secret sync.
- [ ] Criar o environment GitHub `production` e configurar aprovação obrigatória.
- [ ] Configurar os secrets de entrega Kubernetes no repositório conforme o padrão `fcs-pipelines`.
- [ ] Fazer o primeiro push manual da branch revisada e aprovar a entrega.
- [ ] Confirmar emissão do certificado `fcs-devportal-tls` e acesso com BasicAuth.

## Documentação

- [Contexto do domínio](CONTEXT.md)
- [Documentação TechDocs](docs/index.md)
- [ADR 0001](docs/adr/0001-backstage-portal.md)
- [ADR 0002](docs/adr/0002-poc-persistence-and-techdocs.md)
