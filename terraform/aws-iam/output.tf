output "eks_control_plane_role_arn" {
  value       = module.eks_control_plane_role.role_arn
  description = "eks control plane role arn"
}
output "ec2_eks_role_arn" {
  value       = module.ec2_eks_role.role_arn
  description = "ec2 eks role arn"
}
