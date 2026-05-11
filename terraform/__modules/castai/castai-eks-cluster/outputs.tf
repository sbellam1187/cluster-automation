output "castai_cluster_id" {
  description = "The CAST AI EKS cluster ID"
  value       = castai_eks_cluster.eks_cluster.id
}

output "instance_role_arn" {
  value       = aws_iam_instance_profile.instance_profile.arn
  description = "ARN of the instance role created for the EKS cluster"
}
