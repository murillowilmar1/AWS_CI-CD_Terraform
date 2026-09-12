# Data Platform — laboratorio Terraform (dev/prod simulados por región)

Estructura completa: capa de plataforma, módulos reutilizables, 4
servicios independientes y sus pipelines de CodePipeline, todo
parametrizado para correr en dos regiones simulando dos cuentas:

- **dev** → `us-east-1`
- **prod** → `us-west-2`

```
data-platform/
├── platform/                 Buckets raw/clean/curated, Glue DB, roles IAM
├── modules/
│   ├── lambda-function/      Módulo reutilizable para Lambdas
│   ├── glue-job/             Módulo reutilizable para Glue jobs
│   └── codepipeline/         Módulo reutilizable para pipelines CI/CD
├── cicd/                     Instancia los 4 pipelines (uno por servicio)
├── services/
│   ├── ingest-sharepoint-lambda/
│   ├── ingest-postgres-glue/
│   ├── ingest-sqlserver-glue/
│   └── clean-service/
├── env/
│   ├── dev.tfvars            region = us-east-1
│   └── prod.tfvars           region = us-west-2
├── pipeline/
│   └── NOTAS-PIPELINE.md
└── scripts/
    ├── bootstrap.sh          Crea el bucket de tfstate (una sola vez)
    └── tf.sh                 Atajo para init/plan/apply por servicio y ambiente
```

## Antes de empezar (una sola vez)

1. AWS CLI configurado (`aws configure`) con permisos suficientes
2. Terraform >= 1.5 instalado
3. Crear el bucket de tfstate:

```bash
./scripts/bootstrap.sh
```

4. Abrir `env/dev.tfvars` y `env/prod.tfvars` y reemplazar cualquier
   valor que diga `CAMBIA-ESTE-...` por los tuyos reales (nombre del
   bucket de tfstate, bucket de artifacts, y el ARN de tu CodeStar
   Connection si vas a llegar hasta desplegar los pipelines).

## Orden de despliegue

### 1. Plataforma (dev y luego prod)

```bash
./scripts/tf.sh platform dev init
./scripts/tf.sh platform dev plan
./scripts/tf.sh platform dev apply

./scripts/tf.sh platform prod init
./scripts/tf.sh platform prod plan
./scripts/tf.sh platform prod apply
```

### 2. Servicios (cualquier orden entre ellos)

```bash
./scripts/tf.sh services/ingest-sharepoint-lambda/infra dev init
./scripts/tf.sh services/ingest-sharepoint-lambda/infra dev plan
./scripts/tf.sh services/ingest-sharepoint-lambda/infra dev apply
```

Repite el mismo patrón para `ingest-postgres-glue`, `ingest-sqlserver-glue`
y `clean-service`, y luego para `prod` cuando quieras promover.

### 3. Pipelines de CodePipeline (opcional, requiere una CodeStar
   Connection ya autorizada a mano en la consola — ese paso no se
   puede automatizar del todo, AWS exige un clic manual de OAuth)

```bash
./scripts/tf.sh cicd dev init
./scripts/tf.sh cicd dev plan
./scripts/tf.sh cicd dev apply
```

## Qué simula bien la separación por región, y qué no

Ver `pipeline/NOTAS-PIPELINE.md` para el detalle — en resumen: aísla
recursos y states, pero **no** aísla permisos IAM como lo haría una
cuenta AWS separada. Es un buen punto de partida para practicar el
flujo completo sin necesitar una segunda cuenta.
