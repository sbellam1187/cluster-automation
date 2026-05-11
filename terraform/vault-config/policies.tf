resource "vault_policy" "default_prod" {
  provider = vault.prod
  name     = "default"

  policy = <<EOT
# Allow tokens to look up their own properties
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow a token to look up its own capabilities on a path
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow a token to look up its own entity by id or name
path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = ["read"]
}

path "identity/entity/name/{{identity.entity.name}}" {
  capabilities = ["read"]
}

# Allow a token to look up its resultant ACL from all policies. This is useful
# for UIs. It is an internal path because the format may change at any time
# based on how the internal ACL features and capabilities change.
path "sys/internal/ui/resultant-acl" {
  capabilities = ["read"]
}

# Allow a token to renew a lease via lease_id in the request body; old path for
# old clients, new path for newer
path "sys/renew" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

# Allow looking up lease properties. This requires knowing the lease ID ahead
# of time and does not divulge any sensitive information.
path "sys/leases/lookup" {
  capabilities = ["update"]
}

# Allow a token to manage its own cubbyhole
path "cubbyhole/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow a token to wrap arbitrary values in a response-wrapping token
path "sys/wrapping/wrap" {
  capabilities = ["update"]
}

# Allow a token to look up the creation time and TTL of a given
# response-wrapping token
path "sys/wrapping/lookup" {
  capabilities = ["update"]
}

# Allow a token to unwrap a response-wrapping token. This is a convenience to
# avoid client token swapping since this is also part of the response wrapping
# policy.
path "sys/wrapping/unwrap" {
  capabilities = ["update"]
}

# Allow general purpose tools
path "sys/tools/hash" {
  capabilities = ["update"]
}

path "sys/tools/hash/*" {
  capabilities = ["update"]
}

# Allow checking the status of a Control Group request if the user has the
# accessor
path "sys/control-group/request" {
  capabilities = ["update"]
}

# Allow a token to make requests to the Authorization Endpoint for OIDC providers.
path "identity/oidc/provider/+/authorize" {
  capabilities = ["read", "update"]
}

EOT
}

resource "vault_policy" "kaas_admin_prod" {
  provider = vault.prod
  # This name already used a hyphen, so we left it that way.
  name = "kaas-admin"

  policy = <<EOT
# Broad admin access rights
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

EOT
}

resource "vault_policy" "kaas_full_vault_admin_prod" {
  provider = vault.prod
  name     = "kaas_full_vault_admin"

  policy = <<EOT
# Broad admin access rights
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}

# Manage namespaces
path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "+/sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "+/sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}
path "+/sys/policies/acl" {
   capabilities = ["list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
path "+/sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}
path "+/sys/mounts" {
  capabilities = [ "read" ]
}

EOT
}

resource "vault_policy" "kaas_access_prod" {
  provider = vault.prod
  name     = "kaas_access"

  policy = <<EOT
# Broad KV read rights
path "secrets/*"
{
  capabilities = ["read", "list"]
}

EOT
}

resource "vault_policy" "k8s_bootstrap_read_only_prod" {
  provider = vault.prod
  name     = "k8s_bootstrap_read_only"

  policy = <<EOT
path "secrets/data/bootstrap/k8s/*" {
  capabilities = [ "list", "read" ]
}

path "secrets/metadata/bootstrap/k8s/*" {
  capabilities = [ "list", "read" ]
}

EOT
}
