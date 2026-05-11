# Use the fetched information to create a DNS record
resource "null_resource" "create_dns_record" {
  count = (var.pci_cluster || var.private_aks) ? 1 : 0
  triggers = {
    private_ip_address = data.azurerm_private_endpoint_connection.pci_cluster_pe[0].private_service_connection[0].private_ip_address
  }
  provisioner "local-exec" {
    environment = {
      CLUSTER_HOSTNAME = split(".", data.azurerm_kubernetes_cluster.runway_ok8[0].private_fqdn)[0]
      IP_ADDRESS       = data.azurerm_private_endpoint_connection.pci_cluster_pe[0].private_service_connection[0].private_ip_address
      P42_PASSWORD     = var.pci_cluster ? data.vault_generic_secret.p42_password[0].data["value"] : ""

    }

    command = <<EOT
      TOKEN=$(curl -s -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' --data "{\"username\":\"${var.p42_user}\",\"password\":\"$P42_PASSWORD\"}" https://project42.aa.com/api/auth/token | jq -r ".access_token")
      curl -k "https://project42.aa.com/api/dns/addRecord" \
        -X 'POST' \
        --header "Authorization: Bearer $TOKEN" \
        -H 'Content-Type: application/json' \
        --data-binary "{\"item\":[{\"hostname\":\"$CLUSTER_HOSTNAME\",\"domain_suffix\":\"privatelink.${var.location}.azmk8s.io\",\"record_value\":\"$IP_ADDRESS\",\"record_type\":\"a\",\"archer_id\":\"7466101\"}],\"desc\":\"Creating DNS record\"}"
    EOT
  }
  depends_on = [azurerm_kubernetes_cluster.runway_ok8, data.azurerm_private_endpoint_connection.pci_cluster_pe, data.vault_generic_secret.p42_password]
}
