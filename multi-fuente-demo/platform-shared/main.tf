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

data "aws_caller_identity" "current" {}

# ---------- Buckets compartidos por TODAS las fuentes ----------
# Cada fuente escribe bajo su propio prefijo (ej. raw/postgres/,
# raw/sqlserver/) — el bucket en sí es una sola capa compartida, no
# una por fuente.

resource "aws_s3_bucket" "raw" {
  bucket = "multi-fuente-raw-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "stage" {
  bucket = "multi-fuente-stage-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "analytics" {
  bucket = "multi-fuente-analytics-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "athena_results" {
  bucket = "multi-fuente-athena-results-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

# ---------- Catálogo y consulta compartidos ----------

resource "aws_glue_catalog_database" "this" {
  name = "multi_fuente_${var.environment}"
}

resource "aws_athena_workgroup" "this" {
  name = "multi-fuente-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.id}/"
    }
  }
}

# ---------- Rol IAM compartido para los Glue jobs de cualquier fuente ----------

resource "aws_iam_role" "glue_role" {
  name = "multi-fuente-glue-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "multi-fuente-glue-s3-${var.environment}"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.raw.arn, "${aws_s3_bucket.raw.arn}/*",
        aws_s3_bucket.stage.arn, "${aws_s3_bucket.stage.arn}/*",
        aws_s3_bucket.analytics.arn, "${aws_s3_bucket.analytics.arn}/*",
      ]
    }]
  })
}

# ---------- Rol IAM compartido para Lambdas (ej. el audit de sqlserver) ----------

resource "aws_iam_role" "lambda_role" {
  name = "multi-fuente-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "multi-fuente-lambda-s3-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.raw.arn, "${aws_s3_bucket.raw.arn}/*",
        aws_s3_bucket.stage.arn, "${aws_s3_bucket.stage.arn}/*",
      ]
    }]
  })
}
