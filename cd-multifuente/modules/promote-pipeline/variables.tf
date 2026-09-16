variable "pipeline_name" {
  type = string
}

variable "repo_connection_arn" {
  type = string
}

variable "repo_full_name" {
  type = string
}

variable "branch" {
  type        = string
  description = "Rama que el pipeline consulta al arrancar (ej. main)"
}

variable "artifact_bucket" {
  type = string
}

variable "environment" {
  type = string
}

variable "tfstate_bucket" {
  type = string
}

variable "tfstate_region" {
  type = string
}

variable "plan_buildspec_path" {
  type        = string
  description = "Buildspec genérico de plan, usa la variable FUENTE para saber qué carpeta tocar"
}

variable "apply_buildspec_path" {
  type = string
}

variable "default_fuente" {
  type        = string
  description = "Valor por defecto de la variable FUENTE si no se especifica al arrancar"
}
