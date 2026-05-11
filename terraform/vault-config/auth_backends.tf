# nonprod
resource "vault_ldap_auth_backend" "ldap_nonprod" {
  path             = "ldap"
  url              = "ldaps://sldap.qcorpaa.aa.com:636"
  binddn           = "CN=secretmgmtADLdapread\\, Hashicorp,OU=Hashicorp,OU=Applications,OU=Support User Accounts,DC=qcorpaa,DC=aa,DC=com"
  userdn           = "DC=qcorpaa,DC=aa,DC=com"
  userfilter       = "({{.UserAttr}}={{.Username}})"
  userattr         = "samaccountname"
  groupdn          = "DC=qcorpaa,DC=aa,DC=com"
  groupfilter      = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
  groupattr        = "cn"
  use_token_groups = true
  deny_null_bind   = true
  tls_min_version  = "tls12"
  tls_max_version  = "tls12"
  token_ttl        = 3600
  token_type       = "default"
  max_page_size    = 0
}

resource "vault_auth_backend" "approle_nonprod" {
  type = "approle"
}

# prod

resource "vault_ldap_auth_backend" "ldap_prod" {
  provider         = vault.prod
  path             = "ldap"
  url              = "ldaps://sldap.corpaa.aa.com:636"
  binddn           = "CN=Z2095422 HashiCorpADAuth - Z2095422,OU=Hashicorp,OU=Support User Accounts,DC=corpaa,DC=aa,DC=com"
  userdn           = "DC=corpaa,DC=aa,DC=com"
  userfilter       = "({{.UserAttr}}={{.Username}})"
  userattr         = "samaccountname"
  groupdn          = "DC=corpaa,DC=aa,DC=com"
  groupfilter      = "(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
  groupattr        = "cn"
  use_token_groups = true
  deny_null_bind   = true
  tls_min_version  = "tls12"
  tls_max_version  = "tls12"
  token_ttl        = 3600
  token_type       = "default"
  max_page_size    = 0
}

resource "vault_auth_backend" "approle_prod" {
  provider = vault.prod
  type     = "approle"
}
