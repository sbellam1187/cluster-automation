### AWS -- KPaaS Architecture
>[!Note]
> Architectural designs are not finalized, final designs may vary

#### AWS KPaaS Resource Topology
> - **AWS Account:** One per environment and covers multiple regions. This is equivalent of subscription in Azure
> - **VPC:** Single VPC per environment and region. This is equivalent of vNet in Azure
> - **Regions:** us-east-1 (Virginia) and us-west-2 (Oregon)
> - **Availability Zones:** 3
> - **EKS Access Mode:** Private

![AWS_Network_Design-Page-2 drawio](https://github.com/user-attachments/assets/8ed6faa2-fe1b-4c1a-8be4-5c8b5e7f9d81)

#### AWS KPaaS NXOP Service Connectivity
> - Network communication between services will be facilitated via a combination of the following resources -- Transit Gateway, VPC Endpoints, AWS Private link etc.

![AWS_Network_Design-Page-3 drawio](https://github.com/user-attachments/assets/771d3bd6-a32e-4fea-9f67-12c6b822e119)

**Design principles:**
- Alignment with AKS Account Structure (Subscription/Resource Group)
- EKS Cluster Isolation
- Better access management controls
- Compliance requirements
- Better Quota management
- Troubleshoot

#### AWS EKS Network Topology
> **Network Flow:** TBD

![AWS_Network_Design-Page-1 drawio](https://github.com/user-attachments/assets/9dfc1c88-f1b8-4085-9325-afae05e9b6ce)

---
### KPaaS Service Capabilities

KPaaS feature capabilities across cloud providers

>[!note]
> AWS EKS clusters are in development phase. Features availability listed here are scoped for initial release (Phase-1)
---

| Feature | Description | Status(AKS) | Status(AWS) |
|---------|-------------|:---:|:---:|
| **Region** | Cloud provider regions where KPaaS services available | eastus, westus  | us-east-1, us-west-2 |
| **Stateless Applications** | Full support for stateless microservices and containerized applications using `webapp` CRD| ✅  | ☑️ |
| **Batch and optimization Workload** |  Batch/Long Running/Optimization workload available using `conductor` CRD | ✅ | ❌ |
| **PCI Workloads** | Dedicated clusters for PCI-compliant workloads | ✅ | ❌ |
| **Self-service Portal** | Integration with Runway for simplified onboarding and workload management | ✅ | ☑️ |
| **CI Integration** | Built-in support for CI workflows managed by DTE when deployed via Runway Templates | ✅ | ☑️ |
| **CD Integration** | Built-in support for CD using ArgoCD | ✅ | ☑️ |
| **Cluster Access** | Rancher for cluster access and viewing Kubernetes resources | ✅ | ☑️ |
| **Role-based Access Control** | Fine-grained permissions for namespace access using Azure AAD | ✅ | ☑️ |
| **Entra Workload ID \| Pod Identity** | Identity to access cloud provider service using IAM  | 📅 |  ☑️ |
| **Auto Scaling** | CPU-based HPA and KEDA (ServiceBus, BlobStorage, Cron) | ✅ | ☑️ |
| **Resource Optimization** | Workload Right Sizing using CastAI | 🚧 | 🚧 |
| **Apigee** | Apigee Microgateway Integrations using `webapp` | ✅ | ☑️ |
| **PingFed** | PingFed OIDC integrations | 📅 | 📅 |
| **Secret Management** | HashiCorp Vault integrations for secrets using `webapp` integration | ✅ | ☑️ |
| **Logging** | Centralized log collection Via Mezmos | ✅ | ☑️ |
| **Metrics** | Comprehensive application and cluster metrics in Dynatrace | ✅ | ☑️ |
| **Traffic Management (Akamai)** | GTM via Akamai across cloud regions for North-South traffic | ✅ | ☑️ |
| **Traffic Management (Infoblox)** | GTM for AA Internal network only for North-South traffic | 🔒 | NA |
| **Service Mesh Support** | Advanced networking capabilities like East-West traffic auto failover | ✅ | ☑️ |
| **Dedicated Clusters** | Dedicated clusters | ❌ | ☑️ |
| **Network Segmentation** | Granular control over pod-to-pod communication using Istio| 📅 | 📅 |
| **Canary Deployments** | Canary deployments for % based traffic routing using Istio| 📅 | 📅 |
| **Persistent Storage** | Persistent volumes | ❌ | ❌ |
| **StatefulSets** | Kubernetes StatefulSets for ordered, persistent applications | ❌ | ❌ |
| **Helm** | Helm based install | ❌ | ❌ |

✅ --> Available
☑️ --> Available as part of initial release once KPaaS EKS service is available in AWS
🚧 --> In development
📅 --> Future release (In backlog) 
🔒 --> Available only on PCI clusters
❌ --> Not available

---

### KPaaS EKS Cluster Rollout:

**Milestone-1(MVP):** Bare-bones Cluster **| Env:** POC(nonprod) **| Timeline:** October last week
> [!Note]
> Cluster: kaas-nxop-poc-aws-3006-eastus
> Account: aa-aws-kaas-nonprod
> Region: us-east-1

> - [x]  NXOP EKS Cluster will be deployed in AA AWS non-prod account
> - [x]  Cluster availability in us-east-1 region only
> - [x]  Custom cluster
> - [x]  Custom networking
> - [x]  Public facing K8s API
> - [x]  Integrate with AA DNS
> - [x]  Bootstrap components rollout (Partial support)
> - [x]  Container Registry (Cloudsmith)
> - [x]  WebApp Operator
> - [x]  Istio Ingress Operator
> - [x]  Akamai GTM Property for external services
> - [x]  Mesh Network (Istio)
> - [x]  Rancher Integration
> - [x]  Runway Integration
> - [x]  ArgoCD
> - [x]  Telemetry (Dynatrace & Mezmo)
> - [x]  Use Public IP for Istio Ingress Gateway
> - [ ]  Connectivity from AWS-KPaaS account to AWS-NXOP Services
> - [x]  Pod Identity (Manual role creation and mapping)

**Milestone-2:** Integrated Cluster with IaC **| Env:** Nonprod **| Timeline:** December 1st week
- All of the above from Milestone-1 plus the following..
> - [ ] Terraform Support for Cluster support
> - [ ] Bootstrap components rollout (Full support)
> - [ ] Private EKS Cluster
> - [ ] AWS Load balancer controller support
> - [ ] Apigee Support
> - [ ] Hashicorp Vault Integration**
> - [ ] Pod Identity with WebApp Support
> - [ ] Connectivity from AWS-KPaaS account to AWS-NXOP Services (Establish Patterns)
> - [ ] Tenable
> - [ ] Velero (backup)

**Milestone-3:** Integrated Cluster with IaC **| Env:** Prod **|** TBD
- All of the above from Milestone-2 plus the following..
> - [ ] Production clusters us-east-1 and us-west-2
> - [ ] Network connectivity to Prod NXOP VPC

---

### WebApp Pattern:
>[!Note]
> Complete WebApp spec is documented [here](https://developer.aa.com/docs/default/component/runway/getting-started/userguides/webapp/#spec-reference)

**State:** Stateless workload
**Resources:**
- CPU: 8 (Max)
- Mem: 8Gi (Max)

**Replicas:**
- 40 (Max)

**Health Checks:**
- Scheme: HTTP
- Supported Probes: Readiness, Liveness

**Access Management:**
- UI access via Rancher
- "read-only" access to namespaces

**API Management:**
- Apigee

**CI/CD:**
- Github & Argo
- Workload management is done through Github -- Updates to WebApp >> ArgoCD >> Workloads on K8s

**Networking:**
- East-West using Istio Mesh with mTLS
- North-South: Akamai(GTM) >> IstioGateway (Ingress Controller) >> Workloads(Pods)
- GTM traffic targets use handoutCName instead of IP target servers

**Security:**
- Privilege Escalation: Disabled
- Run as Root: Disabled

**Secrets Management:**
- Using Hashicorp Vault

---

### AWS POD Identity:
<img width="1404" height="1160" alt="image" src="https://github.com/user-attachments/assets/abbea461-b575-4c54-ac76-5f26c48c9cf8" />

---

### NXOP Requirements(Not Supported):
- **CloudWatch:** Not a platform capability, but workloads can be monitored using AWS Cloudwatch. Telemetry signals will be sent out to Dynatrace and Mezmo
- **KEDA:** Custom Keda triggers for MSK & MSF not supported, but will be considered for future support.
- **Helm:** Use WebApp for stateless workloads.
- **AWS Secrets Manager:** Use Hashicorp Vault
- **Apollo Graph:** Andy and team working on setting router in AWS

