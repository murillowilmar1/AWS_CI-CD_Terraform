variable "environment" {
  description = "dev o prod"
  type        = string
}

variable "region" {
  description = "Región AWS que simula la cuenta (us-east-1 = dev, us-west-2 = prod)"
  type        = string
}

variable "project_name" {
  description = "Prefijo usado para nombrar los recursos"
  type        = string
  default     = "data-platform"
}

# Variables que no usa esta capa pero que comparten el mismo .tfvars
# que los demás módulos (Terraform solo emite un warning, no un error).
variable "platform_state_bucket" {
  type    = string
  default = ""
}
variable "platform_state_region" {
  type    = string
  default = ""
}
variable "repo_connection_arn" {
  type    = string
  default = ""
}
variable "repo_full_name" {
  type    = string
  default = ""
}
variable "artifact_bucket" {
  type    = string
  default = ""
}
