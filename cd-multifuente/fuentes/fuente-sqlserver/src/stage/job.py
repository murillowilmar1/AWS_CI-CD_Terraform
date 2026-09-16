import sys
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ["RAW_BUCKET", "STAGE_BUCKET", "SOURCE_PREFIX", "ENVIRONMENT"])


def main():
    print(
        f"[sqlserver/stage] Limpiando s3://{args['RAW_BUCKET']}/{args['SOURCE_PREFIX']}/ "
        f"-> s3://{args['STAGE_BUCKET']}/{args['SOURCE_PREFIX']}/ ({args['ENVIRONMENT']})"
    )
    print("Hola Mundo")
    # TODO: tipos de datos, nulos, normalización


if __name__ == "__main__":
    main()
