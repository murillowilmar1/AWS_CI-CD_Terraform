terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  raw_bucket       = data.terraform_remote_state.platform.outputs.raw_bucket_name
  stage_bucket     = data.terraform_remote_state.platform.outputs.stage_bucket_name
  analytics_bucket = data.terraform_remote_state.platform.outputs.analytics_bucket_name
  glue_role_arn    = data.terraform_remote_state.platform.outputs.glue_role_arn
  lambda_role_arn  = data.terraform_remote_state.platform.outputs.lambda_role_arn
  glue_database    = data.terraform_remote_state.platform.outputs.glue_catalog_database_name
}

# ---------- raw: trae datos de SQL Server al bucket raw compartido ----------

resource "aws_s3_object" "raw_script" {
  bucket = local.raw_bucket
  key    = "scripts/sqlserver/raw_job.py"
  source = "../src/raw/job.py"
  etag   = filemd5("../src/raw/job.py")
}

module "raw_job" {
  source          = "../../../modules/glue-job"
  job_name        = "multi-fuente-sqlserver-raw-${var.environment}"
  role_arn        = local.glue_role_arn
  script_location = "s3://${aws_s3_object.raw_script.bucket}/${aws_s3_object.raw_script.key}"

  default_arguments = {
    "--RAW_BUCKET"    = local.raw_bucket
    "--SOURCE_PREFIX" = "sqlserver"
    "--ENVIRONMENT"   = var.environment
  }
}

# ---------- stage: limpia/normaliza raw -> stage ----------

resource "aws_s3_object" "stage_script" {
  bucket = local.raw_bucket
  key    = "scripts/sqlserver/stage_job.py"
  source = "../src/stage/job.py"
  etag   = filemd5("../src/stage/job.py")
}

module "stage_job" {
  source          = "../../../modules/glue-job"
  job_name        = "multi-fuente-sqlserver-stage-${var.environment}"
  role_arn        = local.glue_role_arn
  script_location = "s3://${aws_s3_object.stage_script.bucket}/${aws_s3_object.stage_script.key}"

  default_arguments = {
    "--RAW_BUCKET"    = local.raw_bucket
    "--STAGE_BUCKET"  = local.stage_bucket
    "--SOURCE_PREFIX" = "sqlserver"
    "--ENVIRONMENT"   = var.environment
  }
}

# ---------- analytics: stage -> analytics, catalogado en el Glue DB compartido ----------

resource "aws_s3_object" "analytics_script" {
  bucket = local.raw_bucket
  key    = "scripts/sqlserver/analytics_job.py"
  source = "../src/analytics/job.py"
  etag   = filemd5("../src/analytics/job.py")
}

module "analytics_job" {
  source          = "../../../modules/glue-job"
  job_name        = "multi-fuente-sqlserver-analytics-${var.environment}"
  role_arn        = local.glue_role_arn
  script_location = "s3://${aws_s3_object.analytics_script.bucket}/${aws_s3_object.analytics_script.key}"

  default_arguments = {
    "--STAGE_BUCKET"     = local.stage_bucket
    "--ANALYTICS_BUCKET" = local.analytics_bucket
    "--GLUE_DATABASE"    = local.glue_database
    "--SOURCE_PREFIX"    = "sqlserver"
    "--ENVIRONMENT"      = var.environment
  }
}

# ---------- audit: Lambda que valida que ciertos registros cumplan una condición ----------
# Único componente de esta fuente que NO es Glue — se dispara aparte
# (ej. por EventBridge o invocación manual), audita el stage bucket.

module "audit_function" {
  source             = "../../../modules/lambda-function"
  function_name      = "multi-fuente-sqlserver-audit-${var.environment}"
  source_dir         = "../src/audit"
  execution_role_arn = local.lambda_role_arn
  timeout            = 60
  memory_size        = 256

  environment_variables = {
    STAGE_BUCKET  = local.stage_bucket
    SOURCE_PREFIX = "sqlserver"
    ENVIRONMENT   = var.environment
  }
}
