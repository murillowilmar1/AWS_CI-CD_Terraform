variable "environment" {
  description = "dev o prod"
  type        = string
}

variable "region" {
  description = "Región AWS (us-east-1 = dev, us-west-2 = prod)"
  type        = string
}
