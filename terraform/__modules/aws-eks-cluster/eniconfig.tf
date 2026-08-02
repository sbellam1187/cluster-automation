resource "helm_release" "raw_eni_config" {
  for_each   = var.eni_configs
  name       = "eniconfig-${each.key}"
  repository = "oci://ghcr.io/hiddenmarten/charts"
  chart      = "raw"
  version    = "0.0.7"
  values = [
    <<-EOF
    resources:
      - apiVersion: crd.k8s.amazonaws.com/v1alpha1
        kind: ENIConfig
        metadata:
          name: ${each.key}
        spec:
          subnet: ${each.value}
          securityGroups:
          - ${aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id}
    EOF
  ]

  depends_on = [aws_eks_cluster.eks_cluster, aws_eks_addon.addon["vpc-cni"], aws_vpc_security_group_ingress_rule.allow_tls_ipv4]
}
