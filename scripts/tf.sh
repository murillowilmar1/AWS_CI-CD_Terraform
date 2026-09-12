#!/usr/bin/env bash
# Uso:
#   ./scripts/tf.sh platform dev init
#   ./scripts/tf.sh platform dev plan
#   ./scripts/tf.sh platform dev apply
#   ./scripts/tf.sh services/ingest-postgres-glue/infra dev plan
#   ./scripts/tf.sh cicd prod apply
set -euo pipefail

MODULE_PATH=$1   # ej: platform | cicd | services/clean-service/infra
ENV=$2           # dev | prod
ACTION=$3        # init | plan | apply

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUCKET="CAMBIA-ESTE-BUCKET-tfstate"

case "$ENV" in
  dev)  REGION="us-east-1" ;;
  prod) REGION="us-west-2" ;;
  *) echo "Ambiente no soportado: $ENV (usa dev o prod)"; exit 1 ;;
esac

# services/x/infra -> key services/x/{env}/terraform.tfstate
STATE_KEY="${MODULE_PATH%/infra}/${ENV}/terraform.tfstate"

cd "${ROOT_DIR}/${MODULE_PATH}"

case "$ACTION" in
  init)
    terraform init \
      -backend-config="bucket=${BUCKET}" \
      -backend-config="key=${STATE_KEY}" \
      -backend-config="region=us-east-1"
    ;;
  plan)
    terraform plan \
      -var-file="${ROOT_DIR}/env/${ENV}.tfvars" \
      -var="region=${REGION}"
    ;;
  apply)
    terraform apply \
      -var-file="${ROOT_DIR}/env/${ENV}.tfvars" \
      -var="region=${REGION}"
    ;;
  *)
    echo "Acción no soportada: $ACTION (usa init, plan o apply)"
    exit 1
    ;;
esac
