#!/usr/bin/env bash
# Uso:
#   ./scripts/tf.sh platform-shared dev init
#   ./scripts/tf.sh fuentes/fuente-postgres/infra dev plan
#   ./scripts/tf.sh cicd prod apply
#
# Reusa el bucket de tfstate de multi-zone-ci-cd (mismo proceso, prefijo
# de key distinto: cd-multifuente/...) — es infraestructura de
# cuenta, no código de este proyecto.
set -euo pipefail

MODULE_PATH=$1   # ej: platform-shared | cicd | fuentes/fuente-postgres/infra
ENV=$2           # dev | prod
ACTION=$3        # init | plan | apply

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUCKET="CAMBIA-ESTE-BUCKET-tfstate"

case "$ENV" in
  dev)  REGION="us-east-1" ;;
  prod) REGION="us-west-2" ;;
  *) echo "Ambiente no soportado: $ENV (usa dev o prod)"; exit 1 ;;
esac

# fuentes/x/infra -> key cd-multifuente/fuentes/x/{env}/terraform.tfstate
STATE_KEY="cd-multifuente/${MODULE_PATH%/infra}/${ENV}/terraform.tfstate"

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
