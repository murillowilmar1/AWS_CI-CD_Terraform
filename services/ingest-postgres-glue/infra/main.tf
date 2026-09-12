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

resource "aws_s3_object" "script" {
  bucket = data.terraform_remote_state.platform.outputs.raw_bucket_name
  key    = "scripts/ingest_postgres_job.py"
  source = "../src/job.py"
  etag   = filemd5("../src/job.py")
}

module "postgres_ingest_job" {
  source          = "../../../modules/glue-job"
  job_name        = "glue-ingest-postgres-${var.environment}"
  role_arn        = data.terraform_remote_state.platform.outputs.glue_role_arn
  script_location = "s3://${aws_s3_object.script.bucket}/${aws_s3_object.script.key}"

  default_arguments = {
    "--RAW_BUCKET"  = data.terraform_remote_state.platform.outputs.raw_bucket_name
    "--ENVIRONMENT" = var.environment
  }
}
