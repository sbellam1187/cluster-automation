## NXOP / KPaaS Work Items & Timeline

### Overall Estimated Timeline: **~3 weeks for LAB cluster**

---

## 1) Foundation & Access

### AWS Account (NXOP)
- Discuss and finalize access level for KPaaS team.

### VPC (GND) 
- Define boundary responsibilities between KPaaS and NXOP teams.
- Within KPaaS boundary, carve out EKS subnets.

---

## 2) FAR Submissions

### FAR Submissions for Integrations 
Submit required FAR for all integrations:
- Cloudsmith
- LTU
- GitHub Actions
- other required integrations

---

## 3) IAM Role for GitHub Actions Setup

### Define IAM Role for GitHub Actions in NXOP Account 
- Create GitHub OIDC as Identity Provider in NXOP AWS IAM.
- Update IAM policies using least-privilege principle.
- Discuss naming convention for NXOP roles  
  (Can existing role names be reused due to account-level uniqueness?).

---

## 4) Terraform State Management 

### Create S3 Bucket for NXOP Terraform State 
- Provision dedicated S3 bucket for Terraform state files.

---

## 5) IAM Role for EKS Setup 

### Define IAM Roles for EKS Cluster, Node Group, and Components (Terraform) 
- Create/define IAM roles for:
  - EKS Cluster
  - Node Group
  - EKS components
- Update policies using least-privilege principle.
- Discuss naming convention for NXOP roles  
  (Can existing role names be reused due to account-level uniqueness?).

### Conditional Follow-up (TBD)
- If new IAM roles are introduced for NXOP, update workflows accordingly.
---

## 6) EKS Provisioning & Bootstrap

- Provision EKS Cluster 
- Onboard Bootstrap Components with Patches for New Accounts
- Validate the cluster and signoff 

---

## 7) Internal to KPaaS (Parallel/Supporting Work in terraform modules to adapt new aws account)

EKS Cluster
- Use Role ARN in `tfvars` for cluster and node.
- In `PodIdentityAssociation`, parameterize `role_arn` in root module.
- Refine `locals.tf` in root module to remove hardcoded subnet values.

EKS Subnets
- Add new `tfvars` for NXOP subnets.
- Update related workflows.

EKS IAM
- If retaining same IAM role/policy model:
 - Add new `tfvars` for NXOP.
 - Update workflow accordingly.

---

## Week-by-Week Plan

### Week 1

Work Item # 1
Work Item # 2
Work Item # 3

### Week 2

Work Item # 4
Work Item # 5
Work Item # 7

### Week 3

Work Item # 6


---
