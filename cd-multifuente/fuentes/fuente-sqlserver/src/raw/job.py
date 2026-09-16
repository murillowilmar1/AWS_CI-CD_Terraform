import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ["RAW_BUCKET", "SOURCE_PREFIX", "ENVIRONMENT"])


def main():
    print(f"[sqlserver/raw] Extrayendo de SQL Server -> s3://{args['RAW_BUCKET']}/{args['SOURCE_PREFIX']}/ ({args['ENVIRONMENT']})")
    # TODO: conectar a SQL Server, leer las tablas fuente, escribir crudo en RAW_BUCKET/SOURCE_PREFIX/


if __name__ == "__main__":
    main()
