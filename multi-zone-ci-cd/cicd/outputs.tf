output "pipeline_names" {
  value = [
    module.pipeline_ingest_sharepoint.pipeline_name,
    module.pipeline_ingest_postgres.pipeline_name,
    module.pipeline_ingest_sqlserver.pipeline_name,
    module.pipeline_clean_service.pipeline_name,
  ]
}
