# ADR 0002 — SQLite e geração local de TechDocs na PoC

## Decisão

Executar uma única réplica do Backstage com SQLite em PVC e gerar TechDocs localmente, publicando o resultado no MinIO interno.

## Consequências

Essa configuração reduz o custo e a complexidade da PoC, mas não oferece alta disponibilidade. Uma evolução para produção deve migrar a persistência para PostgreSQL, avaliar execução isolada da geração de documentação e definir backup/recuperação do conteúdo TechDocs.
