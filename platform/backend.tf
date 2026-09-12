terraform {
  backend "s3" {
    # Los valores reales (bucket, key, region) se pasan en tiempo de
    # init mediante -backend-config (ver scripts/tf.sh). Esto permite
    # reusar el mismo código para dev (us-east-1) y prod (us-west-2)
    # sin hardcodear nada aquí.
  }
}
