## Changelog
### terraform-rancher-v1.0.0
- Added AAD groups `L_TnT_SecondOrder_Members` and `L_TnT_Phenoms_Members` with custom `DX-squad` role to cluster membership in rancher.tf and variables.tf.
- Changed group `AAD_DT_RG_DEVRUNWAY_CONTRIBUTOR_N` to use `DX-sqaud` custom role instead of `cluster owner`
### terraform-rancher-v1.0.1
- Added runway-automation zaccount Z2095621 to rancher-register/rancher.tf and variables.tf so that this zaccount gets created on all new shared clusters. This Zaccount will have the `cluster owner` role. We found without this role on the cluster membership, AAD group were not getting assigned to projects automatically.
### terraform-rancher-v1.0.2
- Add Runway gophers mgmt group `AAD_DT_RG_K8S_CONTRIBUTOR_N` to rancher_register terraform `rancher.tf` and `variables.tf` as cluster-owner
