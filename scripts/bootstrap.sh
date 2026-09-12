#!/usr/bin/env bash
# Se corre UNA sola vez, a mano, antes de cualquier terraform init.
# Crea el bucket S3 donde vivirán TODOS los tfstate (dev y prod
# comparten el bucket, se diferencian por la "key").
set -euo pipefail

BUCKET="data-platform-tfstate-357032925182"
REGION="us-east-1"

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" || true
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

echo "Bucket de tfstate listo: $BUCKET"
