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

module "clean_function" {
  source             = "../../../modules/lambda-function"
  function_name      = "lambda-clean-${var.environment}"
  source_dir         = "../src"
  execution_role_arn = data.terraform_remote_state.platform.outputs.lambda_role_arn
  timeout            = 120
  memory_size        = 512

  environment_variables = {
    RAW_BUCKET   = data.terraform_remote_state.platform.outputs.raw_bucket_name
    CLEAN_BUCKET = data.terraform_remote_state.platform.outputs.clean_bucket_name
    ENVIRONMENT  = var.environment
  }
}
