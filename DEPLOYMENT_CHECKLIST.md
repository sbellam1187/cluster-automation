# EKS Cluster Deployment Checklist

Use this checklist to ensure all steps are completed correctly.

## Pre-Deployment

- [ ] AWS Account access verified (`aws sts get-caller-identity`)
- [ ] Terraform 1.0+ installed (`terraform version`)
- [ ] AWS CLI v2 installed (`aws --version`)
- [ ] kubectl installed (`kubectl version`)
- [ ] S3 bucket created for Terraform state
- [ ] DynamoDB table created for state locking
- [ ] IAM permissions verified for required services

## Configuration

- [ ] `terraform.tfvars` copied from `terraform.tfvars.example`
- [ ] `cluster_name` set to desired cluster name
- [ ] `environment` set to `dev`, `staging`, or `prod`
- [ ] `project_name` set
- [ ] `aws_region` set to target region
- [ ] VPC CIDR blocks reviewed and customized if needed
- [ ] Node group configuration reviewed
- [ ] Private registry settings configured (if applicable)
  - [ ] `enable_ecr_access = false`
  - [ ] `private_registry_url` set
  - [ ] `private_registry_username` set
  - [ ] `private_registry_password` set
  - [ ] `private_registry_email` set
- [ ] Security settings reviewed
  - [ ] `enable_imds_v2 = true`
  - [ ] `enable_ssm_access = true`
  - [ ] `cluster_endpoint_public_access_cidrs` restricted
- [ ] `backend.tf` S3 bucket and DynamoDB table names updated
- [ ] Tags reviewed and customized
- [ ] All sensitive values use appropriate secret management

## Terraform Preparation

- [ ] `terraform init` completed successfully
- [ ] No errors in `terraform validate`
- [ ] Code formatted with `terraform fmt`
- [ ] `terraform plan` generated and reviewed
- [ ] Resource count verified (should be 200+)
- [ ] No unexpected changes in plan

## Deployment Execution

- [ ] Team notified of deployment
- [ ] Maintenance window scheduled if needed
- [ ] `terraform apply` started
- [ ] Deploy process monitored (15-20 minutes expected)
- [ ] No errors during apply
- [ ] All resources created successfully

## Post-Deployment Validation

### Terraform State
- [ ] State file successfully stored in S3
- [ ] `terraform state list` shows all resources
- [ ] `terraform output` displays expected values

### AWS Resources
- [ ] VPC created with correct CIDR
- [ ] Public and private subnets created across AZs
- [ ] Internet Gateway and NAT Gateways operational
- [ ] EKS cluster endpoint accessible
- [ ] EKS cluster status is "ACTIVE"
- [ ] Node groups in "ACTIVE" state
- [ ] Nodes transitioning to "Ready" state

### Kubernetes Cluster

#### Basic Connectivity
- [ ] `kubectl cluster-info` shows cluster details
- [ ] `kubectl config current-context` shows correct cluster
- [ ] `kubectl get nodes` lists all worker nodes
- [ ] All nodes have status "Ready"

#### System Components
- [ ] `kubectl get pods -n kube-system` shows system pods
- [ ] CoreDNS pods are running
- [ ] kube-proxy pods are running
- [ ] aws-node (VPC CNI) pods are running
- [ ] All pods have status "Running"

#### Networking
- [ ] `kubectl get svc` shows default Kubernetes services
- [ ] Pod-to-pod communication working
- [ ] DNS resolution working (test with `kubectl run -it --rm debug --image=alpine --restart=Never -- sh`)

#### CloudWatch Logs
- [ ] CloudWatch log group created `/aws/eks/<cluster-name>/cluster`
- [ ] Control plane logs appearing in CloudWatch
- [ ] Cluster audit logs available

### IAM and Access

#### OIDC Provider
- [ ] OIDC provider created and listed in IAM
- [ ] OIDC provider URL format correct
- [ ] Thumbprint configured

#### Service Accounts
- [ ] Default service account exists
- [ ] RBAC roles and bindings present
- [ ] Service account tokens valid

#### IAM Roles
- [ ] Cluster IAM role created and policies attached
- [ ] Node IAM roles created for each node group
- [ ] Instance profiles associated with nodes

### Container Registry

#### Private Registry Secrets (if configured)
- [ ] `kubectl get secrets` shows registry secrets
- [ ] Secrets in `default` namespace
- [ ] Secrets in `kube-system` namespace
- [ ] Test pull from registry: `kubectl create -f test-private-registry-pod.yaml`
- [ ] Test pod successfully pulls image

### Add-ons

- [ ] VPC CNI addon installed and running
- [ ] CoreDNS addon installed and running
- [ ] kube-proxy addon installed and running
- [ ] Optional addons installed if enabled:
  - [ ] EBS CSI driver (if `enable_addon_ebs_csi_driver = true`)
  - [ ] EFS CSI driver (if `enable_addon_efs_csi_driver = true`)

### Security Verification

#### IMDSv2
- [ ] IMDSv2 enforced on nodes
- [ ] Node metadata restrictions applied
- [ ] Test IMDSv2 compliance

#### Security Groups
- [ ] Cluster security group created with correct rules
- [ ] Node security group created with correct rules
- [ ] Ingress rules allow inter-node communication
- [ ] Egress rules allow outbound traffic

#### Network Policies (Optional)
- [ ] Verify CNI supports network policies
- [ ] Create test network policy if desired
- [ ] Verify policy enforcement

## Application Deployment Tests

- [ ] Deploy test application to cluster
- [ ] Verify application starts successfully
- [ ] Verify logging and monitoring work
- [ ] Test auto-scaling (if configured)
- [ ] Test rolling updates
- [ ] Verify resource limits work

## Documentation

- [ ] Cluster information documented
- [ ] Access procedures documented
- [ ] Backup/recovery procedures documented
- [ ] Scaling procedures documented
- [ ] Monitoring setup documented
- [ ] Escalation contacts listed

## Optimization and Tuning

- [ ] Review CloudWatch metrics
- [ ] Verify node capacity usage
- [ ] Check for resource bottlenecks
- [ ] Adjust node group sizes if needed
- [ ] Configure autoscaling policies
- [ ] Review cost allocation tags

## Backup and Disaster Recovery

- [ ] Terraform state backed up
- [ ] kubeconfig backed up
- [ ] Cluster configuration exported
- [ ] DR procedures tested (if applicable)
- [ ] RTO and RPO targets defined

## Team Handoff

- [ ] Team trained on cluster access
- [ ] Team trained on basic operations
- [ ] Team trained on troubleshooting
- [ ] Runbooks created and shared
- [ ] On-call rotation established
- [ ] Escalation procedures defined

## Monitoring and Alerting

- [ ] CloudWatch alarms configured for:
  - [ ] Node CPU utilization
  - [ ] Node memory utilization
  - [ ] Pod capacity
  - [ ] Control plane API latency
  - [ ] Control plane request rates
- [ ] SNS topics configured for alerts
- [ ] Email/Slack notifications tested

## Cost Review

- [ ] Estimated monthly cost calculated
- [ ] Cost allocation tags applied
- [ ] Budget alerts configured
- [ ] Cost optimization opportunities identified
- [ ] Reserved capacity considered

## Final Sign-Off

- [ ] All checklist items completed
- [ ] No outstanding issues
- [ ] Cluster deemed ready for production
- [ ] Deployment date: _______________
- [ ] Deployed by: _______________
- [ ] Reviewed by: _______________

## Known Issues (if any)

- Issue 1: _______________
  Status: _______________
  Resolution: _______________

- Issue 2: _______________
  Status: _______________
  Resolution: _______________

## Next Steps

1. [ ] Schedule post-deployment review meeting
2. [ ] Plan capacity review in 2 weeks
3. [ ] Schedule disaster recovery drill
4. [ ] Plan next version upgrade
5. [ ] Collect team feedback for improvements

---

**Deployment Date**: _______________
**Cluster Name**: _______________
**Environment**: _______________
**Deployed By**: _______________

**Notes**:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
