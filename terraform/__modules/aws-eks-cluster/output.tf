output "cluster_id" {
  value       = aws_eks_cluster.eks_cluster.id
  description = "cluster ID"
}
output "cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "cluster endpoint"
}
output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "cluster name"
}
output "cluster_security_group_id" {
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description = "cluster security group ID"
}
output "cluster_certificate_authority" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "cluster certificate authority"
}
output "cluster_oidc_issuer" {
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  description = "cluster OIDC issuer"
}
output "nodegroup_ids" {
  value       = [for ng in aws_eks_node_group.ng_pool : ng.id]
  description = "EKS node group IDs"
}

output "eip_id" {
  description = "ID of EIP"
  value       = aws_eip.eip.allocation_id
}

output "eip_ip" {
  description = "IP address of EIP"
  value       = aws_eip.eip.public_ip
}
