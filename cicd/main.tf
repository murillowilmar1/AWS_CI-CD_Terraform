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

module "pipeline_ingest_sharepoint" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-ingest-sharepoint-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "services/ingest-sharepoint-lambda/**"
  buildspec_path       = "services/ingest-sharepoint-lambda/buildspec.yml"
  apply_buildspec_path = "services/ingest-sharepoint-lambda/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}

module "pipeline_ingest_postgres" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-ingest-postgres-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "services/ingest-postgres-glue/**"
  buildspec_path       = "services/ingest-postgres-glue/buildspec.yml"
  apply_buildspec_path = "services/ingest-postgres-glue/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}

module "pipeline_ingest_sqlserver" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-ingest-sqlserver-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "services/ingest-sqlserver-glue/**"
  buildspec_path       = "services/ingest-sqlserver-glue/buildspec.yml"
  apply_buildspec_path = "services/ingest-sqlserver-glue/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}

module "pipeline_clean_service" {
  source               = "../modules/codepipeline"
  pipeline_name        = "pipeline-clean-service-${var.environment}"
  repo_connection_arn  = var.repo_connection_arn
  repo_full_name       = var.repo_full_name
  branch               = var.branch
  path_filter          = "services/clean-service/**"
  buildspec_path       = "services/clean-service/buildspec.yml"
  apply_buildspec_path = "services/clean-service/buildspec-apply.yml"
  artifact_bucket      = var.artifact_bucket
  environment          = var.environment
  tfstate_bucket       = var.platform_state_bucket
  tfstate_region       = var.platform_state_region
  require_approval     = var.environment == "prod"
}
