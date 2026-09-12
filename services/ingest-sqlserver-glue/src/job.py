import sys
# from awsglue.utils import getResolvedOptions
# from awsglue.context import GlueContext
# from pyspark.context import SparkContext


def main():
    """
    Job de Glue que extrae datos desde SQL Server (via Glue Connection)
    y los deja crudos en el bucket raw.
    """
    # args = getResolvedOptions(sys.argv, ["JOB_NAME", "RAW_BUCKET", "ENVIRONMENT"])

    # TODO 1: leer desde la conexión de SQL Server (Glue Connection)
    # TODO 2: escribir el resultado en RAW_BUCKET, particionado por
    #         fecha de extracción (ej: raw/sqlserver/dt=2026-09-11/)

    print("Ingesta de SQL Server completada")


if __name__ == "__main__":
    main()
