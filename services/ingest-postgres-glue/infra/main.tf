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

module "postgres_ingest_job" {
  source          = "../../../modules/glue-job"
  job_name        = "glue-ingest-postgres-${var.environment}"
  role_arn        = data.terraform_remote_state.platform.outputs.glue_role_arn
  script_location = "s3://${data.terraform_remote_state.platform.outputs.raw_bucket_name}/scripts/ingest_postgres_job.py"

  default_arguments = {
    "--RAW_BUCKET"  = data.terraform_remote_state.platform.outputs.raw_bucket_name
    "--ENVIRONMENT" = var.environment
  }
}
