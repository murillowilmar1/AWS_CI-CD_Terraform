import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ["RAW_BUCKET", "SOURCE_PREFIX", "ENVIRONMENT"])


def main():
    print(f"[postgres/raw] Extrayendo de Postgres -> s3://{args['RAW_BUCKET']}/{args['SOURCE_PREFIX']}/ ({args['ENVIRONMENT']})")
    # TODO: conectar a Postgres, leer las tablas fuente, escribir crudo en RAW_BUCKET/SOURCE_PREFIX/


if __name__ == "__main__":
    main()
    # nota: la extracción real se conecta vía JDBC a Postgres
