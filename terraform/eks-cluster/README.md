# EKS Cluster Terraform Deployment

This folder contains Terraform code for provisioning and managing an AWS Elastic Kubernetes Service (EKS) cluster and its supporting infrastructure. The design is modular, scalable, and environment-aware, making it suitable for both development and production use.

---

## High-Level Overview

The `eks-cluster/<env>` folder acts as a root Terraform module that orchestrates the creation of an EKS cluster, its node groups, IAM roles, add-ons, custom networking (ENIConfig), rancher registration. It leverages child modules for each major component, ensuring separation of concerns and maintainability.

---

## Folder Structure & File Purpose

### 1. `main.tf`
- **Purpose:** Entry point for the deployment. Calls child modules for cluster, node groups, IAM roles, add-ons, ENIConfig and rancher registration.
- **Usage:** Defines resource dependencies and passes required variables to each module.

### 2. `variables.tf`
- **Purpose:** Declares all input variables needed for the deployment.
- **Usage:** Includes cluster name, region, VPC/subnet IDs, IAM role ARNs, node group configuration, add-on config, and ENIConfig values.

### 3. `outputs.tf`
- **Purpose:** Exposes key outputs for use by other modules or for reference.
- **Usage:** Outputs cluster endpoint, CA certificate, node group details, and ENIConfig status.

### 4. `providers.tf`
- **Purpose:** Configures AWS and Kubernetes providers.
- **Usage:** Ensures Terraform can manage both AWS resources and in-cluster Kubernetes resources, using cluster outputs for authentication.

### 5. `data-sources.tf`
- **Purpose:** Fetches dynamic AWS information.
- **Usage:** Retrieves VPC details and subnet lists to avoid hardcoding.

---
