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

# ---------- Buckets de datos (raw / clean / curated) ----------

resource "aws_s3_bucket" "raw" {
  bucket = "${var.project_name}-raw-${var.environment}"
}

resource "aws_s3_bucket" "clean" {
  bucket = "${var.project_name}-clean-${var.environment}"
}

resource "aws_s3_bucket" "curated" {
  bucket = "${var.project_name}-curated-${var.environment}"
}

# ---------- Cifrado ----------

resource "aws_kms_key" "data_platform" {
  description             = "KMS key para cifrar los buckets de datos (${var.environment})"
  deletion_window_in_days = 7
}

# ---------- Catálogo de datos ----------

resource "aws_glue_catalog_database" "this" {
  name = "${replace(var.project_name, "-", "_")}_${var.environment}"
}

# ---------- Rol IAM para los Glue jobs ----------

resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}-glue-role-${var.environment}"

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
  name = "${var.project_name}-glue-s3-${var.environment}"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.raw.arn,
        "${aws_s3_bucket.raw.arn}/*",
        aws_s3_bucket.clean.arn,
        "${aws_s3_bucket.clean.arn}/*",
        aws_s3_bucket.curated.arn,
        "${aws_s3_bucket.curated.arn}/*",
      ]
    }]
  })
}

# ---------- Rol IAM para las Lambdas ----------

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

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
  name = "${var.project_name}-lambda-s3-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject"]
      Resource = ["${aws_s3_bucket.raw.arn}/*", "${aws_s3_bucket.clean.arn}/*"]
    }]
  })
}
