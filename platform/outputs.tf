output "raw_bucket_name" {
  value = aws_s3_bucket.raw.bucket
}
output "raw_bucket_arn" {
  value = aws_s3_bucket.raw.arn
}
output "clean_bucket_name" {
  value = aws_s3_bucket.clean.bucket
}
output "clean_bucket_arn" {
  value = aws_s3_bucket.clean.arn
}
output "curated_bucket_name" {
  value = aws_s3_bucket.curated.bucket
}
output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}
output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
output "kms_key_arn" {
  value = aws_kms_key.data_platform.arn
}
