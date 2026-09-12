terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- Fuente: Postgres (raw + stage + analytics, un solo pipeline) ---
# Se dispara con cualquier cambio bajo fuentes/fuente-postgres/**.
module "pipeline_fuente_postgres" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-fuente-postgres-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "multi-fuente-demo/fuentes/fuente-postgres/**"
  buildspec_path       = "multi-fuente-demo/fuentes/fuente-postgres/buildspec.yml"
  apply_buildspec_path = "multi-fuente-demo/fuentes/fuente-postgres/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}

# --- Fuente: SQL Server (raw + stage + analytics + audit lambda) ---
# Totalmente independiente de postgres: propio path_filter, propio
# state, propio pipeline. Comparten la capa platform-shared (Athena,
# Glue DB, buckets) pero un cambio en una fuente nunca dispara ni
# bloquea a la otra.
module "pipeline_fuente_sqlserver" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-fuente-sqlserver-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "multi-fuente-demo/fuentes/fuente-sqlserver/**"
  buildspec_path       = "multi-fuente-demo/fuentes/fuente-sqlserver/buildspec.yml"
  apply_buildspec_path = "multi-fuente-demo/fuentes/fuente-sqlserver/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}

output "pipeline_names" {
  value = [
    module.pipeline_fuente_postgres.pipeline_name,
    module.pipeline_fuente_sqlserver.pipeline_name,
  ]
}
