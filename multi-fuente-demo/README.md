# Multi-fuente demo — varias fuentes de datos, un pipeline por fuente

Proyecto independiente (código propio, no comparte `modules/` con
`data-platform`) que vive en el mismo repo de GitHub como carpeta
aparte. Simula dos fuentes de datos con necesidades distintas:

- **Postgres**: raw → stage → analytics (3 Glue jobs)
- **SQL Server**: raw → stage → analytics (3 Glue jobs) + un Lambda de
  auditoría que valida que ciertos registros cumplan una condición

Ambas fuentes comparten una capa `platform-shared/`: buckets
raw/stage/analytics, un Glue Catalog Database y un Athena Workgroup
**únicos para las dos** (cada fuente escribe bajo su propio prefijo:
`raw/postgres/`, `raw/sqlserver/`, etc.)

## Estructura

```
multi-fuente-demo/
├── platform-shared/     Buckets raw/stage/analytics, Glue DB, Athena
│                        workgroup, roles IAM — COMPARTIDO por ambas fuentes
├── modules/
│   ├── codepipeline/    Copia del módulo validado en data-platform
│   ├── glue-job/
│   └── lambda-function/
├── cicd/                Un pipeline por fuente (2 en total)
├── env/{dev,prod}.tfvars
├── scripts/tf.sh
└── fuentes/
    ├── fuente-postgres/
    │   ├── infra/         3 módulos glue-job (raw, stage, analytics)
    │   ├── src/{raw,stage,analytics}/job.py
    │   ├── buildspec.yml
    │   └── buildspec-apply.yml
    └── fuente-sqlserver/
        ├── infra/         3 módulos glue-job + 1 módulo lambda-function (audit)
        ├── src/{raw,stage,analytics}/job.py, src/audit/app.py
        ├── buildspec.yml
        └── buildspec-apply.yml
```

## Aislamiento por fuente

`cicd/main.tf` instancia el módulo `codepipeline` una vez por fuente,
cada una con su propio `path_filter`
(`multi-fuente-demo/fuentes/fuente-postgres/**` /
`.../fuente-sqlserver/**`). Un cambio en cualquiera de los 3 Glue jobs
o el Lambda de SQL Server dispara **solo** `pipeline-fuente-sqlserver-<env>`
— postgres no se entera, y viceversa. Los 3 jobs de una misma fuente
SÍ se despliegan juntos (un solo `terraform apply` por fuente, no uno
por job) — así se decidió para este ejercicio.

## Qué se reutiliza de `data-platform` (infraestructura de cuenta, no código)

- Las CodeConnections de GitHub (`data-platform-dev` / `data-platform-prod`)
  — son reutilizables por cualquier repo al que la GitHub App tenga acceso,
  no están atadas a un path.
- El bucket de tfstate (`data-platform-tfstate-357032925182`), con un
  prefijo de key distinto (`multi-fuente-demo/...`).
- Los buckets de artifacts de CodePipeline (`data-platform-artifacts-{dev,prod}-...`)
  — CodePipeline los usa con un prefijo por pipeline, no hay colisión.

Nada del **código** (módulos, buildspecs, infra) se comparte con
`data-platform` — es a propósito, para que este proyecto pueda
evolucionar sin arriesgar al otro.

## Orden de despliegue

```bash
./scripts/tf.sh platform-shared dev init
./scripts/tf.sh platform-shared dev plan
./scripts/tf.sh platform-shared dev apply

./scripts/tf.sh cicd dev init
./scripts/tf.sh cicd dev plan
./scripts/tf.sh cicd dev apply
```

Después de esto, un push a `dev` que toque `fuentes/fuente-postgres/**`
o `fuentes/fuente-sqlserver/**` dispara el pipeline correspondiente
automáticamente (auto-apply en dev, aprobación manual en prod — mismo
diseño que `data-platform`).
