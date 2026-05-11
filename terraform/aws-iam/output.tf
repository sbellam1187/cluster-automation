output "eks_control_plane_role_arn" {
  value       = module.eks_control_plane_role.role_arn
  description = "eks control plane role arn"
}
output "eks_node_role_arn" {
  value       = module.eks_node_role.role_arn
  description = "eks node role arn"
}
