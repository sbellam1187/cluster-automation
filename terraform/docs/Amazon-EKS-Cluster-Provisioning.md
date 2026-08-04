
## Introduction
This guide documents the process of provisioning an EKS cluster using the AWS Console ("ClickOps"), with corresponding notes.

---

## Table of Contents
- Prerequisites
- VPC & Subnet Setup
- IAM Roles & Policies
- EKS Cluster Creation (Console)
- Node Group Configuration
- Cluster Access & Kubeconfig
- Verifying Cluster Health

---

## 1. Prerequisites
- AWS account with necessary permissions.
- AWS CLI installed (optional for verification).
- Basic understanding of EKS concepts (Cluster, Node Group, IAM, VPC).

---

## 2. VPC & Subnet Setup
GND team provisions VPC for us.
1. Navigate to VPC dashboard.
2. Select Your VPCs - `AA_KAAS_N_EA_10.218.16.0_20_VPC`  `VPC ID: vpc-079061f4b143ac3fa`. We have 2 CIDRS primary: 10.218.16.0/20 (for nodes) and secondary:100.64.0.0/16 (for pods)
3. We carve out public and private subnets in each Availability Zones. A public subnet is a subnet with a route table that includes a route to an [internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), whereas a private subnet is a subnet with a route table that doesn’t include a route to an internet gateway.
4. Set up route tables and NAT gateways.

---

## 3. IAM Roles & Policies
### Console Steps:
1. Create an IAM role for EKS cluster.
2. Attach policies:
   - `AmazonEKSClusterPolicy`
   - `AmazonEKSServicePolicy`
3. Create an IAM role for node group:
   - Attach `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, `AmazonEKS_CNI_Policy`.

---

## 4. EKS Cluster Creation (Console)
### Console Steps:
1. Go to Amazon EKS > Clusters > Create Cluster.
2. Select Custom configuration and disable 'Use EKS Auto Mode' ( Auto mode creates all dependencies)
3. Enter cluster name and Choose the Cluster IAM role created.
4. Select Kubernetes version and upgrade policy "Standard"
5. Cluster access : Select "Allow cluster admin access" and "EKS API authentication" mode.
6. Disable "Envelope encryption" , "ARC Zonal shift" and "Deletion protection"
7. No tags for now, we will add later after recommendation from GaaS.
8. Select VPC and subnets. For subnets choose *1a_nodes , *1b_nodes and *1c_nodes
9. Security groups - Leave it blank ( EKS automatically creates a cluster security group on cluster creation to facilitate communication between worker nodes and control plane)
10. Choose cluster IP address family - IPv4
11. Service IP CIDR block - Disable . AKS will create 172.*.*.* 
12. Disable CIDR blocks for on-premises ( we don't use hybrid worker nodes)
13. Cluster endpoint access "Choose "public and private"
14. Observability - Don't select any 
15. Add-ons - Select "VPC CNI , kube-proxy , Node monitoring agent , CoreDNS , Metrics Server"
16. Create the Cluster

---

## 5. Node Group Configuration
### Console Steps:
1. In cluster details, go to "Add Node Group".
2. Enter node group name, select AMI type, instance type, scaling parameters.
3. Attach IAM role for nodes.
4. Select subnets - choose *1a_nodes , *1b_nodes and *1c_nodes
5. Click "Create".

---

## 6. Cluster Access & Kubeconfig
### Console Steps:
1. On cluster’s "Connect" tab, copy the `aws eks update-kubeconfig` command.
2. Run it locally to configure `kubectl` access.

---

## 7. Verifying Cluster Health
### Console Steps:
1. Run `kubectl get nodes` to verify node status.
2. Deploy a test workload (`kubectl run ...`) and check pod status.

---

## 8. VPC CNI Custom Networking

1. Run `kubectl get pod -n kube-system` to verify AWS VPC CNI is up and running.
pods with name aws-node-***** are CNI daemon set pods.

2. To enable custom networking we have to set the AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG environment variable to true in the aws-node DaemonSet.

`kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true`

3. Create an ENIConfig custom resource for each subnet that pods will be deployed in:

First 3 lines commented are our POD CIDR subnets name | subnet ID | VPC ID | VPC Name
```
# kaas_non-prod_us-east-1b_pods| subnet-04a7d04b5b8961e65 | vpc-079061f4b143ac3fa | AA_KAAS_N_EA_10.218.16.0_20_VPC | 100.64.16.0/20
# kaas_non-prod_us-east-1c_pods|subnet-0d241646f0a18aa3c | vpc-079061f4b143ac3fa | AA_KAAS_N_EA_10.218.16.0_20_VPC | 100.64.32.0/20
# kaas_non-prod_us-east-1a_pods| subnet-037edef24489abe85 | vpc-079061f4b143ac3fa | AA_KAAS_N_EA_10.218.16.0_20_VPC | 100.64.0.0/20

apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: "us-east-1a"
spec:
  subnet: "subnet-037edef24489abe85"
  securityGroups:
  - sg-00fe1b9725eda412f
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: "us-east-1c"
spec:
  subnet: "subnet-0d241646f0a18aa3c"
  securityGroups:
  - sg-00fe1b9725eda412f

---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: "us-east-1b"
spec:
  subnet: "subnet-04a7d04b5b8961e65"
  securityGroups:
  - sg-00fe1b9725eda412f
```
apply this resource to the cluster using `kubectl`
EKS automatically creates a cluster security group on cluster creation , you need to get your cluster security group id and use it in the file.

4. Update the aws-node DaemonSet to automatically apply the ENIConfig for an Availability Zone to any new Amazon EC2 nodes created in the EKS cluster
`kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone`
