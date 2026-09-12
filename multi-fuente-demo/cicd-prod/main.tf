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

# Un solo pipeline de prod para AMBAS fuentes. No se dispara con push;
# alguien lo arranca a mano indicando FUENTE=postgres|sqlserver, y solo
# esa carpeta se planea/aplica. Aprobación manual antes de aplicar.
module "promote_prod" {
  source               = "../modules/promote-pipeline"
  pipeline_name        = "pipeline-promote-prod"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  plan_buildspec_path  = "multi-fuente-demo/cicd-prod/buildspec-plan.yml"
  apply_buildspec_path = "multi-fuente-demo/cicd-prod/buildspec-apply.yml"
  default_fuente       = "postgres"
}

output "pipeline_name" {
  value = module.promote_prod.pipeline_name
}
