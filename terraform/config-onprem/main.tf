# RKE2 Custom Cluster Code

resource "rancher2_cluster_v2" "custom" {
  name                                     = var.cluster_name
  kubernetes_version                       = var.kubernetes_version
  default_cluster_role_for_project_members = "user"
  enable_network_policy                    = false
  local_auth_endpoint {
    enabled = true
  }
  rke_config {
    machine_global_config = <<EOF
    cni: "calico"
    disable:
      - rke2-ingress-nginx
    EOF
  }
}

resource "rancher2_cluster_role_template_binding" "role_binding" {
  for_each = { for binding in var.group_role_bindings : binding.group_principal_id => binding }

  name               = each.value["name"]
  cluster_id         = rancher2_cluster_v2.custom.cluster_v1_id
  role_template_id   = each.value["role_template_id"]
  group_principal_id = each.value["group_principal_id"]

  depends_on = [rancher2_cluster_v2.custom]
}
