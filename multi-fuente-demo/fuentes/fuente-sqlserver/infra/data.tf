data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = var.platform_state_bucket
    key    = "multi-fuente-demo/platform-shared/${var.environment}/terraform.tfstate"
    region = var.platform_state_region
  }
}
