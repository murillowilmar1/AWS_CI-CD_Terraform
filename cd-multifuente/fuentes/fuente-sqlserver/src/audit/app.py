import json
import os


def lambda_handler(event, context):
    """
    Audita los registros en STAGE_BUCKET/SOURCE_PREFIX/ y valida que
    cumplan una condición de negocio (ej. campos obligatorios, rangos
    válidos). No transforma datos, solo reporta hallazgos.
    """
    stage_bucket = os.environ.get("STAGE_BUCKET")
    source_prefix = os.environ.get("SOURCE_PREFIX")
    environment = os.environ.get("ENVIRONMENT")
    print(environment)

    # TODO: leer objetos de stage_bucket/source_prefix/, aplicar la
    # condición de auditoría, y reportar (SNS, tabla de resultados, etc.)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Auditoría completada",
                "stage_bucket": stage_bucket,
                "source_prefix": source_prefix,
                "environment": environment,
            }
        ),
    }
