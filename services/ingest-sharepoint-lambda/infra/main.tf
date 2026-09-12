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

module "ingest_function" {
  source             = "../../../modules/lambda-function"
  function_name      = "lambda-ingest-sharepoint-${var.environment}"
  source_dir         = "../src"
  execution_role_arn = data.terraform_remote_state.platform.outputs.lambda_role_arn

  environment_variables = {
    RAW_BUCKET  = data.terraform_remote_state.platform.outputs.raw_bucket_name
    ENVIRONMENT = var.environment
  }
}
