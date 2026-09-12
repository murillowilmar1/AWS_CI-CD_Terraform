variable "pipeline_name" {
  type = string
}

variable "repo_connection_arn" {
  type        = string
  description = "ARN de la CodeStar Connection (GitHub/Bitbucket), creada a mano una vez en la consola"
}

variable "repo_full_name" {
  type        = string
  description = "org/repo, ej: tu-org/data-platform"
}

variable "branch" {
  type    = string
  default = "main"
}

variable "path_filter" {
  type        = string
  description = "Ruta que dispara este pipeline, ej: services/clean-service/**"
}

variable "buildspec_path" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "environment" {
  type        = string
  description = "dev o prod, se pasa al build como ENVIRONMENT"
}

variable "tfstate_bucket" {
  type        = string
  description = "Bucket de tfstate, se pasa al build como TFSTATE_BUCKET"
}

variable "tfstate_region" {
  type        = string
  description = "Región del bucket de tfstate, se pasa al build como TFSTATE_REGION"
}
