output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = module.eks_subnets.subnet_id
}
