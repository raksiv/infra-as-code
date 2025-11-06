output "bigquery_dataset" {
  description = "BigQuery dataset resource"
  value       = module.bigquery.bigquery_dataset
}

output "bigquery_tables" {
  description = "Map of BigQuery tables created"
  value       = module.bigquery.bigquery_tables
}

output "bigquery_views" {
  description = "Map of BigQuery views created"
  value       = module.bigquery.bigquery_views
}

output "bigquery_external_tables" {
  description = "Map of BigQuery external tables created"
  value       = module.bigquery.bigquery_external_tables
}

output "dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = module.bigquery.bigquery_dataset.dataset_id
}
