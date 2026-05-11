##  Upgrade process for On-Prem Clusters in Rancher using Terraform and GitHub Actions
-   create cluster configuration files under [config-onprem/clusters](https://github.com/AAInternal/runway-kubernetes-cluster-automation/tree/main/config-onprem) based on environment in our github repo
-   Change the required supported `kubernetes_version` on "cluster.tfvars" under cluster folder
-   To import an existing RKE cluster configuration into Terraform, you can use the terraform import command. Here are the steps:
   ``` - Create a Terraform configuration file with the necessary resources to manage the RKE cluster.

    -   Run the `terraform init` command to initialize the Terraform working directory.

    -   Run the `terraform import` command to import the existing RKE cluster configuration into the Terraform state. The syntax for the terraform import command is as follows:
    -   For example, to import an RKE cluster configuration, you would use the following command:

            `terraform import module.rke.rke_cluster.cluster <cluster_id>`

            here   module.rke.rke_cluster.cluster means terraform resource address
                    <cluster_id> means  ID of the existing resource
```
## Import the statefile ##

To make it work for the current enviornment :Go to that directory where terraform files exists and run the below commands accordingly tweeks the inputs  
  1)   `terraform init -backend-config=config-onprem/clusters/${{ inputs.targetEnvironment }}/${{ inputs.targetCluster }}/backend-${{ inputs.targetCluster }}.tfvars`

 2) `terraform import -var-file=config-onprem/clusters/${{ inputs.targetEnvironment }}/${{ inputs.targetCluster }}/${{ inputs.targetCluster }}.tfvars rancher2_cluster.ok8s-cluster <cluster ID>`

 -  Provide access_key token and secret_key  accordingly (these can check with in team before you create new)

 once state files are created.

 ### NOTE:  Make sure to take backup of the cluster just before upgrade for that Take a `Snapshot` of the cluster before the upgrade.
     -  ClusterManagement -> cluster -> Snapshots -> Snapshotnow

- Run the terraform Plan by using below command :-
  ```
    gh workflow run -R AAInternal/runway-kubernetes-cluster-automation terraform-plan-onprem.yaml  \
        --ref $RUNWAY_BRANCH_NAME \
        -f targetCluster=<cluster-name> \
        -f targetEnvironment=<cluster_ENVIRONMENT> \
        -f targetPullRequest=<Prnumber>
  ```

- Run Terraform apply by using below command:-

```
gh workflow run -R AAInternal/runway-kubernetes-cluster-automation terraform-plan-apply-onprem.yaml  \
--ref $RUNWAY_BRANCH_NAME \
-f targetCluster=<cluster-name> \
-f targetEnvironment=<cluster_ENVIRONMENT> \
-f targetPullRequest=<Prnumber>
```
## Validation: ##
1)  After TF apply going into Rancher and watch the upgrade take place.
2)  Check upgrade log status in the provisioning log , watch it until it says kubernetes upgraded successfully.
3) `Kubectl get nodes` makesure all nodes are upgraded sucessfully.
4)  ClusterManagement->cluster -> explore -> `edit config` -> verify the k8s version from portal
5)  Check a few ingress EP and make sure all deployments  are up and running
 -  `kubectl get svc -A`  
 -  `kubectl get ing -A`  
      -  from portal go to cluster check all workloads  status as active and then service discovery for ingress EP  &  validate few ingress EP are acessible.
