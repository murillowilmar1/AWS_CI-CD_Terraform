variable "job_name" {
  type = string
}

variable "script_location" {
  type        = string
  description = "Ruta S3 del script (ej: s3://bucket/scripts/job.py)"
}

variable "role_arn" {
  type = string
}

variable "glue_version" {
  type    = string
  default = "4.0"
}

variable "worker_type" {
  type    = string
  default = "G.1X"
}

variable "number_of_workers" {
  type    = number
  default = 2
}

variable "default_arguments" {
  type    = map(string)
  default = {}
}
