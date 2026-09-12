output "raw_bucket_name" {
  value = aws_s3_bucket.raw.id
}
output "stage_bucket_name" {
  value = aws_s3_bucket.stage.id
}
output "analytics_bucket_name" {
  value = aws_s3_bucket.analytics.id
}
output "athena_results_bucket_name" {
  value = aws_s3_bucket.athena_results.id
}
output "glue_catalog_database_name" {
  value = aws_glue_catalog_database.this.name
}
output "athena_workgroup_name" {
  value = aws_athena_workgroup.this.name
}
output "glue_role_arn" {
  value = aws_iam_role.glue_role.arn
}
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}
