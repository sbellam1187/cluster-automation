# Terraform for AA Corporate Vault Servers

## KaaS Namespace

- Example workflow

```sh
$ az login
$ rm -rf .terraform
$ rm .terraform.lock.hcl
$ terraform init
$ terraform validate
$ terraform plan
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7.4 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~>3.24 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | ~>3.24 |
| <a name="provider_vault.prod"></a> [vault.prod](#provider\_vault.prod) | ~>3.24 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_vault_login_approle_role_id_nonprod"></a> [vault\_login\_approle\_role\_id\_nonprod](#input\_vault\_login\_approle\_role\_id\_nonprod) | Vault Approle Role ID - dev (nonprod) | `string` | yes |
| <a name="input_vault_login_approle_role_id_prod"></a> [vault\_login\_approle\_role\_id\_prod](#input\_vault\_login\_approle\_role\_id\_prod) | Vault Approle Role ID - prod | `string` | yes |
| <a name="input_vault_login_approle_secret_id_nonprod"></a> [vault\_login\_approle\_secret\_id\_nonprod](#input\_vault\_login\_approle\_secret\_id\_nonprod) | Vault Approle Secret ID - dev (nonprod) | `string` | yes |
| <a name="input_vault_login_approle_secret_id_prod"></a> [vault\_login\_approle\_secret\_id\_prod](#input\_vault\_login\_approle\_secret\_id\_prod) | Vault Approle Secret ID - prod | `string` | yes |
| <a name="input_vault_ca_cert_file_nonprod"></a> [vault\_ca\_cert\_file\_nonprod](#input\_vault\_ca\_cert\_file\_nonprod) | Vault server CA certificate - dev (nonprod) | `string` | no |
| <a name="input_vault_ca_cert_file_prod"></a> [vault\_ca\_cert\_file\_prod](#input\_vault\_ca\_cert\_file\_prod) | Vault server CA certificate - prod | `string` | no |
| <a name="input_vault_host_url_nonprod"></a> [vault\_host\_url\_nonprod](#input\_vault\_host\_url\_nonprod) | Vault server URL - dev (nonprod) | `string` | no |
| <a name="input_vault_host_url_prod"></a> [vault\_host\_url\_prod](#input\_vault\_host\_url\_prod) | Vault server URL - prod | `string` | no |
| <a name="input_vault_namespace"></a> [vault\_namespace](#input\_vault\_namespace) | Vault server namespace | `string` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
