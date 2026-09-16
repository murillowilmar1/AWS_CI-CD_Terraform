# De local a CodePipeline

## Orden de despliegue

1. `platform/` (una vez por región/ambiente) — crea buckets, Glue DB, roles IAM
2. `cicd/` (una vez por región/ambiente) — crea los 4 pipelines de CodePipeline
3. `services/*` — cada uno con su propio pipeline, disparado por su propio filtro de ruta

## Simulación de cuentas con regiones

Este laboratorio usa **us-east-1 = dev** y **us-west-2 = prod** dentro de
la misma cuenta AWS, para poder practicar sin necesitar dos cuentas reales.

Esto simula bien: aislamiento de recursos, states separados, el flujo
completo de plan → aprobación → apply.

Esto **no** simula: el aislamiento real de seguridad. Un rol IAM en tu
cuenta tiene los mismos permisos en ambas regiones — en un proyecto real
de producción, dev y prod deben ser cuentas AWS distintas.

## Cross-account (cuando sí tengas dos cuentas reales)

Para que el pipeline (viviendo en una cuenta) pueda desplegar en otra:

1. Rol IAM en la cuenta destino que confíe en la cuenta del pipeline
2. Ese rol con permisos para los recursos del template
3. En la acción de "Apply", especificar ese rol cross-account

## Qué dispara cada pipeline

Cada módulo `codepipeline` recibe un `path_filter` distinto
(`services/ingest-postgres-glue/**`, etc.), así que un push que solo
toca `clean-service/` jamás dispara los otros tres pipelines.
