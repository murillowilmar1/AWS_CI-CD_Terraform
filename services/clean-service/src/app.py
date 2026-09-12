import json
import os


def lambda_handler(event, context):
    """
    Lee el dato crudo desde el bucket raw, aplica limpieza/transformación,
    y escribe el resultado en el bucket clean.
    """
    raw_bucket = os.environ.get("RAW_BUCKET")
    clean_bucket = os.environ.get("CLEAN_BUCKET")
    environment = os.environ.get("ENVIRONMENT")

    # TODO 1: leer el/los objeto(s) desde `raw_bucket`
    # TODO 2: aplicar limpieza (tipos de datos, nulos, normalización, etc.)
    # TODO 3: escribir el resultado transformado en `clean_bucket`

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Limpieza completada",
                "raw_bucket": raw_bucket,
                "clean_bucket": clean_bucket,
                "environment": environment,
            }
        ),
    }
