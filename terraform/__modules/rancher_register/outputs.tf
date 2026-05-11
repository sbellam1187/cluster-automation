output "rancher_cluster_id" {
  description = "The Rancher cluster id"
  value       = rancher2_cluster.runway_cluster_import_rancher.id
}
