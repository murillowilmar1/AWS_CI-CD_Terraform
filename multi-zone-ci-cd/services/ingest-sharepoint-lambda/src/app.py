import json
import os


def lambda_handler(event, context):
    """
    Se conecta a SharePoint via Microsoft Graph API y deja el dato
    crudo (sin transformar) en el bucket de raw.
    """
    raw_bucket = os.environ.get("RAW_BUCKET")
    environment = os.environ.get("ENVIRONMENT")
    print(environment)

    # TODO 1: autenticar contra Microsoft Graph (client credentials flow)
    # TODO 2: listar/leer los archivos o listas de SharePoint que necesitas
    # TODO 3: guardar el resultado tal cual (raw) en `raw_bucket`

    return {
        "statusCode": 200,
        "body": json.dumps(
            {"message": "Ingesta completada", "bucket": raw_bucket, "environment": environment}
        ),
    }
