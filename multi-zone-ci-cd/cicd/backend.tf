terraform {
  backend "s3" {
    # Igual que en platform/: los valores reales se pasan por
    # -backend-config en tiempo de init (ver scripts/tf.sh).
  }
}
