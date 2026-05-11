# EKS Cluster Automation - Complete Guide

This repository contains a comprehensive, production-ready Terraform configuration for deploying AWS EKS clusters. It provides both standalone and modular approaches to fit different use cases.

## 📁 Repository Structure

```
cluster-automation/
├── README.md                    # Original standalone guide
├── QUICKSTART.md               # 5-minute quick start
├── DEPLOYMENT.md               # Step-by-step deployment
├── DEPLOYMENT_CHECKLIST.md     # Verification checklist
├── PROJECT_SUMMARY.md          # Project overview
│
├── Standalone Files/           # Original flat structure
│   ├── backend.tf
│   ├── variables.tf (60+ variables)
│   ├── outputs.tf (40+ outputs)
│   ├── vpc.tf
│   ├── iam.tf
│   ├── eks.tf
│   ├── data.tf
│   └── ...
│
└── terraform/                  # Modular structure
    ├── MODULAR_GUIDE.md       # Modular architecture guide
    ├── MIGRATION_GUIDE.md     # Flat to modular migration
    ├── IMPLEMENTATION_SUMMARY.md  # What was created
    ├── README.md              # Modular overview
    ├── __modules/             # Reusable modules
    │   ├── aws-eks-cluster/
    │   ├── aws-subnets/
    │   ├── aws-iam-roles/
    │   ├── aws-iam-policy/
    │   └── ... (10+ modules)
    │
    └── eks-cluster/           # Cluster implementations
        ├── example/           # Complete working example
        │   ├── main.tf (Module composition)
        │   ├── variables.tf
        │   ├── outputs.tf
        │   ├── terraform.tfvars.example
        │   └── README.md
        └── lab/               # Existing lab environment
```

## 🚀 Quick Start

### Option 1: Standalone (Simplest)

Perfect for learning and simple deployments:

```bash
# Using files in root directory
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

terraform init
terraform plan -out=tfplan
terraform apply tfplan

eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes
```

**Best for**: Quick prototypes, single clusters, learning

### Option 2: Modular (Recommended)

Perfect for production and multiple environments:

```bash
# Using modular structure
cd terraform/eks-cluster/example

cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

terraform init
terraform plan -out=tfplan
terraform apply tfplan

eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes
```

**Best for**: Production, multiple environments (dev/staging/prod), large organizations

## 📚 Documentation Guide

### For First-Time Users
Start here if you're new to this project:

1. **[QUICKSTART.md](QUICKSTART.md)** - 5 minute overview
2. **[README.md](README.md)** - Full reference
3. **Deploy using root files** or **terraform/eks-cluster/example**

### For Modular Users
Want to use the modular approach:

1. **[terraform/MODULAR_GUIDE.md](terraform/MODULAR_GUIDE.md)** - Architecture overview
2. **[terraform/eks-cluster/example/README.md](terraform/eks-cluster/example/README.md)** - Deployment guide
3. **[terraform/IMPLEMENTATION_SUMMARY.md](terraform/IMPLEMENTATION_SUMMARY.md)** - What's included

### For Migration
Moving from flat to modular structure:

1. **[terraform/MIGRATION_GUIDE.md](terraform/MIGRATION_GUIDE.md)** - How to migrate
2. Review modules in **[terraform/__modules/](terraform/__modules/)**
3. Create environment in **[terraform/eks-cluster/](terraform/eks-cluster/)**

### For Deep Dive
Complete technical reference:

1. **[README.md](README.md)** - Comprehensive standalone guide
2. **[DEPLOYMENT.md](DEPLOYMENT.md)** - Step-by-step deployment
3. **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Verification

## 🎯 Choose Your Path

### I want to deploy a cluster ASAP
→ Use **Standalone Files** (root directory)  
→ Follow **[QUICKSTART.md](QUICKSTART.md)**  
→ Takes 5 minutes to get started

### I want to understand the architecture
→ Read **[README.md](README.md)** (full guide)  
→ Review **[DEPLOYMENT.md](DEPLOYMENT.md)** (detailed steps)  
→ Takes 30 minutes to understand

### I want modular, reusable configuration
→ Review **[terraform/MODULAR_GUIDE.md](terraform/MODULAR_GUIDE.md)**  
→ Try **[terraform/eks-cluster/example](terraform/eks-cluster/example/)**  
→ Takes 20 minutes to get started

### I'm managing multiple clusters
→ Read **[terraform/MIGRATION_GUIDE.md](terraform/MIGRATION_GUIDE.md)**  
→ Use **[terraform/__modules/](terraform/__modules/)** for each cluster  
→ Create environments in **[terraform/eks-cluster/](terraform/eks-cluster/)**

### I need to verify everything is correct
→ Use **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)**  
→ Complete all items before production  
→ Takes 1-2 hours for full verification

## 📋 What's Included

### Terraform Modules (9 core files)

```
✅ backend.tf         - S3 remote state configuration
✅ variables.tf       - 60+ configurable input variables
✅ outputs.tf         - 40+ output values
✅ data.tf           - AWS data sources
✅ vpc.tf            - Complete VPC setup
✅ iam.tf            - IAM roles and policies
✅ eks.tf            - EKS cluster and node groups
✅ private_registry.tf - Container registry support
✅ versions.tf       - Provider requirements
```

### Modular Structure (11+ modules)

```
✅ aws-eks-cluster/    - EKS cluster + add-ons
✅ aws-subnets/       - VPC + networking
✅ aws-iam-roles/     - Generic IAM role module
✅ aws-iam-policy/    - Generic policy module
✅ castai/            - CASTAI integration
✅ rancher_register/  - Rancher registration
✅ vault/             - Vault integration
✅ k8s_serviceaccount/ - Kubernetes service accounts
✅ vault-approle/     - Vault AppRole
✅ vault-pki/        - Vault PKI
✅ ... (10+ modules total)
```

### Features

```
✅ Multi-AZ VPC with public/private subnets
✅ NAT Gateways (single or per-AZ)
✅ EKS cluster with Kubernetes 1.24+
✅ Managed node groups with auto-scaling
✅ Private container registry support
✅ OIDC provider for IRSA
✅ CloudWatch logging
✅ EKS add-ons (VPC CNI, CoreDNS, kube-proxy)
✅ Optional EBS/EFS CSI drivers
✅ Security best practices (IMDSv2, least-privilege IAM)
✅ Systems Manager access
✅ 60+ customizable variables
✅ 40+ output values
```

## 🔧 Configuration Examples

### Minimal Development

```hcl
cluster_name = "dev-cluster"
environment = "dev"
kubernetes_version = "1.29"
instance_types = ["t3.small"]
single_nat_gateway = true  # Cost savings
```

### Production HA

```hcl
cluster_name = "prod-cluster"
environment = "prod"
kubernetes_version = "1.29"
instance_types = ["t3.xlarge"]
single_nat_gateway = false  # Multiple NATs
enable_oidc_provider = true
enable_cluster_logging = true
```

### With Private Registry

```hcl
enable_private_registry = true
private_registry_url = "myregistry.azurecr.io"
private_registry_username = "username"
private_registry_password = "token"
private_registry_email = "user@example.com"
```

## 📊 Repository Stats

- **Total Files Created**: 25+
- **Lines of Terraform**: 5,000+
- **Modular Modules**: 11+
- **Input Variables**: 60+
- **Output Values**: 40+
- **Documentation Pages**: 10+
- **AWS Resources**: 200+ per deployment

## 🎓 Learning Path

### Beginner
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Deploy using root files
3. Access your cluster
4. Run sample workload

### Intermediate
1. Read [README.md](README.md)
2. Understand configuration options
3. Deploy to multiple environments
4. Implement monitoring

### Advanced
1. Review [terraform/MODULAR_GUIDE.md](terraform/MODULAR_GUIDE.md)
2. Create custom modules
3. Implement CI/CD
4. Scale to organization

## 🛠️ Prerequisites

```bash
# Check versions
terraform version        # >= 1.0
aws --version          # >= 2.0
kubectl version        # >= 1.24
```

## 📖 File Reference

### Root Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| [README.md](README.md) | Complete reference | Everyone |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute guide | Beginners |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Step-by-step | Operators |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Verification | QA/Reviewers |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Overview | Architects |

### Modular Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| [terraform/MODULAR_GUIDE.md](terraform/MODULAR_GUIDE.md) | Architecture | Operators |
| [terraform/MIGRATION_GUIDE.md](terraform/MIGRATION_GUIDE.md) | Migration | Teams |
| [terraform/IMPLEMENTATION_SUMMARY.md](terraform/IMPLEMENTATION_SUMMARY.md) | What's included | Architects |
| [terraform/eks-cluster/example/README.md](terraform/eks-cluster/example/README.md) | Example guide | Operators |

## 🚀 Deployment Workflow

```
1. Clone/Download Repository
   └─ Review structure

2. Choose Approach
   ├─ Standalone (root files)
   └─ Modular (terraform/eks-cluster/example)

3. Configure
   └─ Copy terraform.tfvars.example
   └─ Update cluster_name, environment, region

4. Initialize
   └─ terraform init

5. Review
   └─ terraform plan

6. Deploy
   └─ terraform apply

7. Verify
   └─ kubectl get nodes
   └─ Check deployment checklist

8. Manage
   └─ Scale node groups
   └─ Update cluster version
   └─ Monitor logs
```

## 💡 Tips & Tricks

### Quick Deployment
```bash
# Skip interactive prompts
terraform apply -auto-approve

# Use specific variable file
terraform apply -var-file=prod.tfvars
```

### Troubleshooting
```bash
# Verbose output
TF_LOG=DEBUG terraform plan

# Check state
terraform state list
terraform state show module.eks_cluster
```

### Viewing Outputs
```bash
# All outputs
terraform output

# Specific output
terraform output -raw cluster_id

# JSON format
terraform output -json | jq '.cluster_id.value'
```

## 🔐 Security Considerations

- ✅ IMDSv2 enabled by default
- ✅ Private API endpoints supported
- ✅ Least-privilege IAM roles
- ✅ Security groups configured
- ✅ OIDC provider for IRSA
- ✅ CloudWatch logging
- ✅ VPC Flow Logs optional

## 💰 Cost Estimation

### Development Environment
- 1 t3.small NAT: $10/month
- 1-2 t3.small nodes: $20-40/month
- **Total**: $30-50/month

### Production Environment
- 3 t3.xlarge NAT: $30/month
- 5-10 t3.xlarge nodes: $500-1000/month
- **Total**: $530-1030/month

*Use [AWS Cost Calculator](https://calculator.aws/) for accurate estimates*

## 📞 Support

### Documentation
- Review relevant README files
- Check DEPLOYMENT_CHECKLIST.md
- Read module documentation

### Troubleshooting
- See [README.md](README.md) troubleshooting section
- Check [DEPLOYMENT.md](DEPLOYMENT.md) common issues
- Review [terraform/MODULAR_GUIDE.md](terraform/MODULAR_GUIDE.md) advanced topics

### References
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📝 License

This Terraform configuration is provided as-is for use in AWS environments.

---

## 🎯 Next Steps

Choose your path and get started:

- **Quickest**: [QUICKSTART.md](QUICKSTART.md) (5 minutes)
- **Recommended**: [terraform/eks-cluster/example](terraform/eks-cluster/example/) (20 minutes)
- **Complete**: [README.md](README.md) (comprehensive guide)
- **Production**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) (full verification)

**Happy deploying! 🚀**

---

**Version**: 1.0  
**Last Updated**: 2026-05-11  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: ~> 5.0
