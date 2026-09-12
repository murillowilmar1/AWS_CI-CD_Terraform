import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(
    sys.argv, ["STAGE_BUCKET", "ANALYTICS_BUCKET", "GLUE_DATABASE", "SOURCE_PREFIX", "ENVIRONMENT"]
)


def main():
    print(
        f"[postgres/analytics] Agregando s3://{args['STAGE_BUCKET']}/{args['SOURCE_PREFIX']}/ "
        f"-> s3://{args['ANALYTICS_BUCKET']}/{args['SOURCE_PREFIX']}/, "
        f"catalogado en {args['GLUE_DATABASE']} ({args['ENVIRONMENT']})"
    )
    # TODO: escribir parquet particionado + registrar tabla en el Glue
    # Catalog compartido para poder consultarlo luego desde Athena.


if __name__ == "__main__":
    main()
