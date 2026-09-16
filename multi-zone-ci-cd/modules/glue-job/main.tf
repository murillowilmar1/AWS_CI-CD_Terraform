resource "aws_glue_job" "this" {
  name              = var.job_name
  role_arn          = var.role_arn
  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers

  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }

  default_arguments = var.default_arguments
}
