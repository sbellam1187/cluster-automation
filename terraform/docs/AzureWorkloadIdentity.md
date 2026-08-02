# Workload Identity Setup with FederatedIdentityCredential (ASO)

## Overview

This document covers setting up Workload Identity using a `FederatedIdentityCredential` with Azure Service Operator (ASO) v2 on Kubernetes, including installation, configuration, and troubleshooting common issues. The guide assumes the parent `UserAssignedIdentity` was created outside of ASO (e.g., via Azure Portal).

Official ASO documentation: https://azure.github.io/azure-service-operator/

---

## ASO Installation

Add the ASO v2 Helm repository and install the operator:

```bash
helm repo add aso2 https://raw.githubusercontent.com/Azure/azure-service-operator/main/v2/charts
```

```bash
helm upgrade --install aso2 aso2/azure-service-operator \
    --create-namespace \
    --namespace=azureserviceoperator-system \
    --set crdPattern='resources.azure.com/*;containerservice.azure.com/*;keyvault.azure.com/*;managedidentity.azure.com/*;eventhub.azure.com/*'
```

> **Note:** The `crdPattern` determines which Azure resource CRDs are installed. Add additional patterns as needed (e.g., `network.azure.com/*`). For Workload Identity setup only, `managedidentity.azure.com/*` is sufficient to limit ASO's scope to managed identity operations.

---

## Setup Steps

Based on: https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster?tabs=new-cluster&pivots=azure-cli

### 1. Set Environment Variables

```bash
export RESOURCE_GROUP="dx-runway-core-np"
export LOCATION="eastus"
export SERVICE_ACCOUNT_NAMESPACE="sravan-test"
export SERVICE_ACCOUNT_NAME="sravan-test-wi-sa"
export CLUSTER_NAME="kaas-runway-lab-aks-1006-westus"
export SUBSCRIPTION="$(az account show --query id --output tsv)"
export USER_ASSIGNED_IDENTITY_NAME="myIdentityd82d2e"
```

### 2. Get OIDC Issuer URL

```bash
export AKS_OIDC_ISSUER="$(az aks show \
  --name "${CLUSTER_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "oidcIssuerProfile.issuerUrl" \
  --output tsv)"
```

### 3. Create User Assigned Identity

```bash
export RANDOM_ID="$(openssl rand -hex 3)"
export USER_ASSIGNED_IDENTITY_NAME="myIdentity${RANDOM_ID}"

az identity create \
  --name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --subscription "${SUBSCRIPTION}"
```

### 4. Get Identity Client ID

```bash
export USER_ASSIGNED_CLIENT_ID="$(az identity show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --query 'clientId' \
  --output tsv)"
```

### 5. Create Kubernetes ServiceAccount

```bash
kubectl apply -f sravan-test-wi-sa.yaml
```

> The ServiceAccount must have the annotation `azure.workload.identity/client-id` set to the managed identity's client ID. See [sravan-test-wi-sa.yaml](#1-serviceaccount-sravan-test-wi-sayaml) below.

### 6. Create FederatedIdentityCredential via ASO

> **Important:** Instead of using `az identity federated-credential create` (as shown in the Microsoft docs), the FederatedIdentityCredential is created via **Azure Service Operator (ASO)** by applying a Kubernetes CR:

```bash
kubectl apply -f federated-identity.yaml
```

This creates the federated credential in Azure through ASO reconciliation. The `owner.armId` field references the existing managed identity directly, so no `UserAssignedIdentity` K8s CR is needed.

### 7. Create Key Vault and Secret

```bash
export KEYVAULT_NAME="keyvault-s007"

export KEYVAULT_RESOURCE_ID=$(az keyvault show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${KEYVAULT_NAME}" \
  --query id \
  --output tsv)
```

Create a secret in the Key Vault:

```bash
export RANDOM_ID="$(openssl rand -hex 3)"
export KEYVAULT_SECRET_NAME="my-secret${RANDOM_ID}"

az keyvault secret set \
  --vault-name "${KEYVAULT_NAME}" \
  --name "${KEYVAULT_SECRET_NAME}" \
  --value "Hello\!"
```

Grant the managed identity access to the Key Vault secret:

```bash
export IDENTITY_PRINCIPAL_ID=$(az identity show \
  --name "${USER_ASSIGNED_IDENTITY_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query principalId \
  --output tsv)
```

### 8. Get Key Vault URL

```bash
export KEYVAULT_URL="$(az keyvault show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${KEYVAULT_NAME}" \
  --query properties.vaultUri \
  --output tsv)"
```

### 9. Deploy Test Pod

```bash
kubectl apply -f pod-workloadidentity.yaml
```

The pod uses label `azure.workload.identity/use: "true"` and references the ServiceAccount. The Azure Workload Identity webhook injects the OIDC token automatically.

### 10. Verify the Pod Can Access Key Vault

```bash
kubectl logs sample-workload-identity-key-vault -n sravan-test
```

Expected output:
```
I0415 22:28:48.815866       1 main.go:63] "successfully got secret" secret="Hello!"
```

This confirms Workload Identity is working — the pod authenticated to Azure using the federated credential and retrieved the Key Vault secret without any stored credentials.

---

## Resource Definitions

### 1. ServiceAccount (`sravan-test-wi-sa.yaml`)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ab6cb6c9-e771-44a0-87a4-efb81ed9f9b2
  name: sravan-test-wi-sa
  namespace: sravan-test
```

### 2. FederatedIdentityCredential (`federated-identity.yaml`)

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: sravan-test-wi-fic
  namespace: sravan-test
spec:
  owner:
    #name: myIdentityd82d2e
    armId: /subscriptions/2fe97b8d-f7b5-4964-85b0-48740441865e/resourcegroups/dx-runway-core-np/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentityd82d2e
  issuer: https://westus.oic.prod-aks.azure.com/49793faf-eb3f-4d99-a0cf-aef7cce79dc1/3a2d9259-83ff-441e-9266-1ee4583da753/
  subject: system:serviceaccount:sravan-test:sravan-test-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

### 3. Test Pod (`pod-workloadidentity.yaml`)

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: sample-workload-identity-key-vault
    namespace: sravan-test
    labels:
        azure.workload.identity/use: "true"
spec:
    serviceAccountName: sravan-test-wi-sa
    containers:
      - image: ghcr.io/azure/azure-workload-identity/msal-go
        name: oidc
        env:
          - name: KEYVAULT_URL
            value: https://keyvault-s007.vault.azure.net/
          - name: SECRET_NAME
            value: my-secret7f09dd
```

---

## Issue 1: WaitingForOwner

### Error
```
Owner "myIdentityd82d2e, Group/Kind: managedidentity.azure.com/UserAssignedIdentity" cannot be found.
Progress is blocked until the owner is created.
```

### Cause
The `spec.owner.name` field requires the parent `UserAssignedIdentity` to exist as a **Kubernetes CR** in the same namespace. If the identity was created via Azure Portal or ARM (not via ASO), no K8s CR exists and ASO blocks reconciliation.

### Fix
Use `spec.owner.armId` instead of `spec.owner.name` to reference the existing Azure resource directly:

```yaml
spec:
  owner:
    armId: /subscriptions/2fe97b8d-f7b5-4964-85b0-48740441865e/resourcegroups/dx-runway-core-np/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentityd82d2e
```

> **Note:** `armId` bypasses the need for a Kubernetes `UserAssignedIdentity` CR — ASO resolves the owner directly from Azure.

---

## Issue 2: Global Credential Not Configured

### Error
```
global credential not configured, you must use either namespaced or per-resource credentials
```

### Cause
ASO's global credential secret (`aso-controller-settings`) in the `azureserviceoperator-system` namespace had empty values for `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`, and `AZURE_TENANT_ID`.

### Diagnosis
```bash
kubectl get secret aso-controller-settings -n azureserviceoperator-system \
  -o jsonpath='{.data}' | python3 -c "
import sys, json, base64
d = json.load(sys.stdin)
[print(k, '=', base64.b64decode(v).decode() if k != 'AZURE_CLIENT_SECRET' else '***') for k, v in d.items()]
"
```

### Fix
Patch the global credential secret with your Service Principal credentials:

```bash
kubectl patch secret aso-controller-settings -n azureserviceoperator-system \
  --type=merge \
  -p '{
    "stringData": {
      "AZURE_SUBSCRIPTION_ID": "<subscription-id>",
      "AZURE_TENANT_ID": "<tenant-id>",
      "AZURE_CLIENT_ID": "<service-principal-client-id>",
      "AZURE_CLIENT_SECRET": "<service-principal-secret>"
    }
  }'
```

> **Note:** Use `stringData` — Kubernetes handles base64 encoding automatically. No need to manually encode values.

Restart ASO controller to apply changes:
```bash
kubectl rollout restart deployment azureserviceoperator-controller-manager -n azureserviceoperator-system
```

> **Security:** The `azureserviceoperator-system` namespace should be restricted via RBAC so end users cannot access these credentials.

---

## Issue 3: Invalid Polling URL

### Error
```
invalid polling URL /subscriptions/.../federatedIdentityCredentials/sravan-test-wi-fic
```

### Cause
ASO attempted to create a resource that already existed in Azure and encountered an invalid async polling URL in the response.

### Diagnosis
Check if the FIC already exists in Azure:
```bash
az identity federated-credential show \
  --name <fic-name> \
  --identity-name <identity-name> \
  --resource-group <resource-group>
```

### Fix Options

**If the FIC exists in Azure** — delete it and let ASO recreate it:
```bash
az identity federated-credential delete \
  --name sravan-test-wi-fic \
  --identity-name myIdentityd82d2e \
  --resource-group dx-runway-core-np
```
Then reapply the YAML.

**If you want to adopt the existing resource** — add the `skip-reconcile` annotation:
```yaml
metadata:
  annotations:
    serviceoperator.azure.com/reconcile-policy: skip-reconcile
```

---

## Final Working YAML

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: sravan-test-wi-fic
  namespace: sravan-test
spec:
  owner:
    armId: /subscriptions/2fe97b8d-f7b5-4964-85b0-48740441865e/resourcegroups/dx-runway-core-np/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentityd82d2e
  issuer: https://westus.oic.prod-aks.azure.com/49793faf-eb3f-4d99-a0cf-aef7cce79dc1/3a2d9259-83ff-441e-9266-1ee4583da753/
  subject: system:serviceaccount:sravan-test:sravan-test-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

### Verify Success
```bash
kubectl get federatedidentitycredential sravan-test-wi-fic -n sravan-test
```

Expected output:
```
NAME                 READY   SEVERITY   REASON      MESSAGE
sravan-test-wi-fic   True               Succeeded
```

Also verify in Azure:
```bash
az identity federated-credential show \
  --name sravan-test-wi-fic \
  --identity-name myIdentityd82d2e \
  --resource-group dx-runway-core-np
```

---

## Cross-Subscription Workload Identity

When the AKS cluster and the target Azure resource (e.g., Key Vault) are in **different subscriptions**, Workload Identity still works because the trust relationship is between the AKS OIDC issuer and the Managed Identity — not between subscriptions directly.

### Scenario

| Component | Subscription | Resource Group |
|-----------|-------------|----------------|
| AKS Cluster | KPaaS subscription | KPaaS resource group |
| User Assigned Managed Identity | App subscription | App resource group |
| Key Vault | App subscription | App resource group |
| ServiceAccount + Pod | AKS cluster (KPaaS) | — |

### How It Works

```
Pod (KPaaS AKS cluster)
  → ServiceAccount (annotated with app identity client-id)
    → OIDC token issued by AKS cluster (KPaaS subscription)
      → FederatedIdentityCredential (on app identity, trusts KPaaS OIDC issuer)
        → Azure AD validates token, issues access token for app identity
          → Key Vault (app subscription) grants access
```

The FederatedIdentityCredential is created on the **app subscription's managed identity** but references the **KPaaS AKS cluster's OIDC issuer**. This cross-subscription trust is what allows pods in KPaaS to authenticate as the app identity.

### Steps

#### 1. Get the AKS OIDC Issuer (KPaaS subscription)

```bash
export KPAAS_CLUSTER_NAME="<kpaas-aks-cluster-name>"
export KPAAS_RESOURCE_GROUP="<kpaas-resource-group>"

export AKS_OIDC_ISSUER="$(az aks show \
  --name "${KPAAS_CLUSTER_NAME}" \
  --resource-group "${KPAAS_RESOURCE_GROUP}" \
  --query "oidcIssuerProfile.issuerUrl" \
  --output tsv)"
```

#### 2. Create or Identify the App Managed Identity (App subscription)

```bash
export APP_SUBSCRIPTION="<app-subscription-id>"
export APP_RESOURCE_GROUP="<app-resource-group>"
export APP_IDENTITY_NAME="<app-managed-identity-name>"

export APP_CLIENT_ID="$(az identity show \
  --subscription "${APP_SUBSCRIPTION}" \
  --resource-group "${APP_RESOURCE_GROUP}" \
  --name "${APP_IDENTITY_NAME}" \
  --query 'clientId' \
  --output tsv)"
```

#### 3. Create ServiceAccount in AKS (KPaaS cluster)

The ServiceAccount in the KPaaS AKS cluster must reference the **app identity's client ID**:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "<APP_CLIENT_ID>"
  name: <service-account-name>
  namespace: <namespace>
```

#### 4. Create FederatedIdentityCredential (App subscription)

The FIC must be created on the **app subscription's managed identity**, pointing to the **KPaaS AKS OIDC issuer**:

**Via ASO:**

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: <fic-name>
  namespace: <namespace>
spec:
  owner:
    armId: /subscriptions/<APP_SUBSCRIPTION>/resourcegroups/<APP_RESOURCE_GROUP>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<APP_IDENTITY_NAME>
  issuer: <AKS_OIDC_ISSUER from KPaaS cluster>
  subject: system:serviceaccount:<namespace>:<service-account-name>
  audiences:
    - api://AzureADTokenExchange
```

> **Key:** The `owner.armId` points to the app subscription identity, but `issuer` points to the KPaaS AKS OIDC issuer. This is what bridges the two subscriptions.

**Via Azure CLI (alternative):**

```bash
az identity federated-credential create \
  --name "<fic-name>" \
  --identity-name "${APP_IDENTITY_NAME}" \
  --resource-group "${APP_RESOURCE_GROUP}" \
  --subscription "${APP_SUBSCRIPTION}" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject "system:serviceaccount:<namespace>:<service-account-name>" \
  --audiences "api://AzureADTokenExchange"
```

#### 5. Grant Key Vault Access to the App Identity

Assign the managed identity a Key Vault role (RBAC) or access policy in the app subscription:

```bash
export APP_IDENTITY_PRINCIPAL_ID="$(az identity show \
  --subscription "${APP_SUBSCRIPTION}" \
  --resource-group "${APP_RESOURCE_GROUP}" \
  --name "${APP_IDENTITY_NAME}" \
  --query 'principalId' \
  --output tsv)"

az role assignment create \
  --assignee-object-id "${APP_IDENTITY_PRINCIPAL_ID}" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/${APP_SUBSCRIPTION}/resourcegroups/${APP_RESOURCE_GROUP}/providers/Microsoft.KeyVault/vaults/<keyvault-name>"
```

#### 6. Deploy Pod in KPaaS AKS

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cross-sub-test
  namespace: <namespace>
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: <service-account-name>
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
        - name: KEYVAULT_URL
          value: https://<keyvault-name>.vault.azure.net/
        - name: SECRET_NAME
          value: <secret-name>
```

### Important Notes

- **ASO credentials**: If using ASO to create the FIC, the ASO controller needs credentials (SP or Workload Identity) with permissions in the **app subscription** to manage the managed identity resource.
- **No VNet/network dependency**: The cross-subscription trust is purely an Azure AD / OIDC federation — no network peering or private endpoints are required for the identity flow itself.
- **Multiple clusters**: A single app managed identity can have multiple FICs, each trusting a different AKS cluster's OIDC issuer (e.g., one for prod, one for non-prod).
- **Cross-tenant reference**: For cross-tenant scenarios, see https://docs.azure.cn/en-us/aks/workload-identity-cross-tenant
- **ASO annotations reference**: For all supported ASO annotations (credential-from, reconcile-policy, etc.), see https://azure.github.io/azure-service-operator/guide/annotations/

---

## Cross-Subscription Design Options

There are three approaches for cross-subscription Workload Identity. **Option 3 is the recommended standard for KPaaS** — it combines the security of Option 2 with the migration seamlessness of Option 1.

---

### Option 1: App-Owned Subscription Model (Identity in App Subscription)

#### Approach

A central Service Principal (SP) has permissions to update User Managed Identities (UMIs) across subscriptions using federated credentials. Application teams provide:

- App subscription ID
- Existing UMI reference in the WebApp CRD

The KPaaS WebApp operator:

1. Creates a Kubernetes Service Account
2. Updates federated credentials on the provided UMI

#### Risk / Concern

Any application can reuse:

- Another app's subscription
- Another app's UMI

The operator will blindly:

- Create Service Account
- Attach federated credentials

> **⚠️ Result:** Privilege escalation and cross-account access leakage — one app can gain the same Azure access as another app, breaking isolation.

#### Key Challenge

How to enforce namespace/app-level isolation so that:

- Only authorized apps can bind to specific UMIs
- Prevent reuse or impersonation across namespaces/subscriptions

#### Technical Details

- Managed Identity + FIC live in the **app subscription**
- FIC references the KPaaS AKS OIDC issuer
- Requires cross-subscription write access (ASO needs app subscription credentials) or manual CLI creation
- App team owns identity lifecycle

---

### Option 2: KPaaS-Owned Subscription Model (Identity in KPaaS Subscription)

#### Approach

The webapp-operator fully owns identity lifecycle:

1. Creates UMI per WebApp CR (via Azure Service Operator)
2. Creates Service Account
3. Creates federated credentials

Application teams:

- Use the generated UMI
- Assign RBAC permissions on their Azure resources

#### Benefit

- Strong isolation (1 WebApp → 1 UMI)
- No risk of cross-app identity reuse

#### Challenge / Concern

During cluster migration:

1. New cluster → new WebApp CR
2. Operator creates **new UMI** via Azure Service Operator

This forces application teams to:

- Reconfigure Azure IAM permissions for the new UMI

> **⚠️ Result:** Breaking change during migrations — creates operational overhead for large-scale app movement.

#### Key Challenge

How to make identity portable and seamless across clusters without:

- Forcing UMI recreation
- Requiring repeated IAM updates by app teams

#### How It Works

```
webapp-operator creates CRs → ASO reconciles to Azure:
  1. UserAssignedIdentity (in KPaaS subscription/resource group)
  2. FederatedIdentityCredential (trusts KPaaS AKS OIDC issuer)
  3. ServiceAccount (annotated with identity client-id)

App team manages:
  4. RBAC assignment on their resource (e.g., Key Vault Secrets User)
```

The identity lives in KPaaS, but the app team grants it access to their resources via RBAC — no cross-subscription write access required.

#### ASO Resource Definitions

Based on: https://github.com/Azure/azure-service-operator/blob/main/v2/samples/managedidentity/v1api20230131/v1api20230131_userassignedidentity.yaml

**1. UserAssignedIdentity**

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: UserAssignedIdentity
metadata:
  name: <app-name>-wi-identity
  namespace: <app-namespace>
spec:
  location: <region>
  owner:
    name: <kpaas-resource-group>
    # Or use armId if the resource group is not managed by ASO:
    # armId: /subscriptions/<KPAAS_SUBSCRIPTION>/resourceGroups/<KPAAS_RESOURCE_GROUP>
  operatorSpec:
    configMaps:
      clientId:
        name: <app-name>-wi-identity-cm
        key: clientId
      principalId:
        name: <app-name>-wi-identity-cm
        key: principalId
      tenantId:
        name: <app-name>-wi-identity-cm
        key: tenantId
```

> **Note:** `operatorSpec.configMaps` tells ASO to write the identity's `clientId`, `principalId`, and `tenantId` to a ConfigMap after creation. This avoids manual `az identity show` lookups. However, ServiceAccount annotations are static strings — they **cannot** natively reference a ConfigMap. To wire the value, either:
> - Read the ConfigMap after creation and patch the SA: `kubectl get cm <app-name>-wi-identity-cm -o jsonpath='{.data.clientId}'`
> - Use the ASO resource status directly: `kubectl get userassignedidentity <name> -o jsonpath='{.status.clientId}'`
> - Use a templating tool (Helm, Kustomize with replacements, or a controller) to inject the value at deploy time.

**2. FederatedIdentityCredential**

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: <app-name>-wi-fic
  namespace: <app-namespace>
spec:
  owner:
    name: <app-name>-wi-identity
  issuer: <AKS_OIDC_ISSUER>
  subject: system:serviceaccount:<app-namespace>:<app-name>-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

> **Note:** With Option 2, `owner.name` works because the `UserAssignedIdentity` CR exists in the same namespace (created by ASO). No need for `owner.armId`.

**3. ServiceAccount**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <app-name>-wi-sa
  namespace: <app-namespace>
  annotations:
    azure.workload.identity/client-id: "<USER_ASSIGNED_CLIENT_ID>"
```

> The `client-id` can be obtained from the `UserAssignedIdentity` status after ASO creates it:
> ```bash
> kubectl get userassignedidentity <app-name>-wi-identity -n <app-namespace> \
>   -o jsonpath='{.status.clientId}'
> ```

#### App Team: RBAC Assignment Only

The app team grants the KPaaS-managed identity access to their resources:

```bash
az role assignment create \
  --assignee-object-id "<IDENTITY_PRINCIPAL_ID>" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<APP_SUBSCRIPTION>/resourcegroups/<APP_RG>/providers/Microsoft.KeyVault/vaults/<keyvault-name>"
```

> The `principalId` can be obtained from:
> ```bash
> kubectl get userassignedidentity <app-name>-wi-identity -n <app-namespace> \
>   -o jsonpath='{.status.principalId}'
> ```

#### Tested Working Example (Cross-Account)

The following YAMLs were tested and confirmed working on the `kaas-runway-lab-aks-1006-westus` cluster:

**1. UserAssignedIdentity** — Creates identity in KPaaS subscription, exports credentials to ConfigMap:

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: UserAssignedIdentity
metadata:
  name: tkp-crossaccount-uai
  namespace: sravan-test
spec:
  location: eastus
  #owner:
  #  name: <kpaas-resource-group>
  # Or use armId if the resource group is not managed by ASO:
  owner:
    armId: /subscriptions/2fe97b8d-f7b5-4964-85b0-48740441865e/resourceGroups/dx-runway-core-np
  operatorSpec:
    configMaps:
      clientId:
        name: sravan-wi-identity-cm
        key: clientId
      principalId:
        name: sravan-wi-identity-cm
        key: principalId
      tenantId:
        name: sravan-wi-identity-cm
        key: tenantId
```

**2. ServiceAccount** — Annotated with the identity's client ID from Azure:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: 204f40a6-1de5-4dcf-a582-86979b9f23a6
  name: sravan-crosscount-wi-sa
  namespace: sravan-test
```

**3. FederatedIdentityCredential** — Links the UAI to the AKS OIDC issuer and SA:

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: sravan-crossaccount-tkp-fic
  namespace: sravan-test
spec:
  owner:
    #name: myIdentityd82d2e
    armId: /subscriptions/2fe97b8d-f7b5-4964-85b0-48740441865e/resourcegroups/dx-runway-core-np/providers/Microsoft.ManagedIdentity/userAssignedIdentities/tkp-crossaccount-uai
  issuer: https://westus.oic.prod-aks.azure.com/49793faf-eb3f-4d99-a0cf-aef7cce79dc1/3a2d9259-83ff-441e-9266-1ee4583da753/
  subject: system:serviceaccount:sravan-test:sravan-crosscount-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

> **Note:** Here `owner.armId` points to the full ARM path of the `UserAssignedIdentity` resource (not the resource group). Alternatively, since the UAI CR exists in the same namespace, `owner.name: tkp-crossaccount-uai` also works.

**4. Test Pod** — Accesses Key Vault using workload identity:

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: sample-wi-crossaccount
    namespace: sravan-test
    labels:
        azure.workload.identity/use: "true"
spec:
    serviceAccountName: sravan-crosscount-wi-sa
    containers:
      - image: ghcr.io/azure/azure-workload-identity/msal-go
        name: oidc
        env:
          - name: KEYVAULT_URL
            value: https://keyvault-tkp-007.vault.azure.net/
          - name: SECRET_NAME
            value: my-secret958121
```

> **Result:** Pod successfully retrieved the Key Vault secret, confirming Option 2 cross-account workload identity works with ASO managing the identity in the KPaaS subscription.

#### Cross-Tenant Nuance

Even in Option 2, cross-tenant access works because:
- OIDC issuer = AKS tenant
- Identity tenant may differ from resource tenant
- Azure Entra allows cross-tenant token exchange by design ([docs](https://docs.azure.cn/en-us/aks/workload-identity-cross-tenant))

The application must set `AZURE_TENANT_ID` to the **identity's tenant** when accessing cross-tenant resources ([Microsoft guidance](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)).

---

### Design Tension Summary

| | Option 1 (App Sub) | Option 2 (KPaaS Sub) |
|---|---|---|
| **Security** | Weak — cross-app leakage risk | Strong — 1:1 isolation |
| **Migration** | Seamless — identity is stable | Breaking — new UMI per cluster |
| **Flexibility** | High | Low |

---

### Option 3: KPaaS-Owned Identity with Stable Lifecycle (Recommended)

**Combines Option 2's security with Option 1's migration seamlessness** by decoupling identity lifecycle from cluster lifecycle.

#### Core Principle

KPaaS owns and creates the UMI (strong security), but the UMI is:

- Stored in a **stable resource group** that persists across cluster migrations (e.g., `kpaas-identities-<region>`)
- Named with a **deterministic convention** derived from app/namespace (not cluster-specific)
- Supports **multiple FederatedIdentityCredentials** — one per cluster OIDC issuer (Azure supports up to 20 per identity)

During migration, only FICs are added/removed. The UMI itself (and all RBAC assignments) remain unchanged.

#### Architecture

```
webapp-operator manages (creates CRs reconciled by ASO):
  1. UserAssignedIdentity (in stable KPaaS identity RG — survives cluster lifecycle)
  2. FederatedIdentityCredential(s) — one per cluster OIDC issuer
  3. ServiceAccount (annotated with identity client-id)

App team manages (once, not per migration):
  4. RBAC assignment on their resource (bound to the stable UMI principalId)
```

#### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                         │
│           ┌─── FederatedIdentityCredential (OIDC Trust) ───┐                                           │
│           │                                                 │                                           │
│           ▼                                                 │                                           │
│   ┌───────────────────┐                            ┌────────┴────────────────────────────┐              │
│   │      KPaaS        │                            │          App Subscription            │              │
│   │                   │                            │                                     │              │
│   │  ┌─────────────┐  │                            │  ┌───────────────────────────────┐  │              │
│   │  │  UMI        │  │                            │  │  Azure Resources              │  │              │
│   │  │  (KPaaS     │◄─┼─── RBAC (principalId) ────┼──┤  Key Vault / Storage / DB     │  │              │
│   │  │   identity  │  │                            │  │                               │  │              │
│   │  │   RG)       │  │                            │  └───────────────────────────────┘  │              │
│ ③ │  └──────┬──────┘  │                            │                                     │              │
│   │         │          │                            │  ② Application assigns RBAC on      │              │
│   │         │ FIC      │                            │     their resources to UMI           │              │
│   │         ▼          │                            │     principalId (once, not per       │              │
│   │  ┌─────────────┐  │                            │     migration)                       │              │
│   │  │    FIC       │  │                            │                                     │              │
│   │  │ (trusts AKS │  │                            └─────────────────────────────────────┘              │
│   │  │  OIDC       │  │                                                                                 │
│   │  │  issuer)    │  │                                                                                 │
│   │  └──────┬──────┘  │                                                                                 │
│   │         │          │                                                                                 │
│   │         │ ① webapp + SA                                                                              │
│   │         ▼          │                                                                                 │
│   │  ┌─────────────┐  │                                                                                 │
│   │  │   webapp    │  │                                                                                 │
│   │  │             │  │                                                                                 │
│   │  │ serviceaccount  │                                                                                │
│   │  │ (client-id  │  │                                                                                 │
│   │  │  annotation)│  │                                                                                 │
│   │  └─────────────┘  │                                                                                 │
│   │                   │                                                                                  │
│   │  webapp-operator   │                                                                                 │
│   └───────────────────┘                                                                                 │
│                                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Step-by-Step Flow (Mirrors AWS Pod Identity Pattern)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                             │
│          ┌─── OIDC Token Exchange ────────────────────────┐                                 │
│          │                                                │                                 │
│   ┌──────┴──────┐                                 ┌───────┴───────┐                         │
│   │   KPaaS     │                                 │    App Sub    │                         │
│   │             │                                 │               │                         │
│   │ ┌────────┐  │    ┌──────────────────────┐     │  ┌─────────┐  │                         │
│   │ │webapp  │  │    │  UMI                  │     │  │Key Vault│  │                         │
│   │ │        │──┼───▶│  (kpaas-identities-   │─────┼─▶│Storage  │  │                         │
│   │ │service │  │    │   <region> RG)        │     │  │DB       │  │                         │
│   │ │account │  │    └──────────────────────┘     │  └─────────┘  │                         │
│   │ └────────┘  │                                 │               │                         │
│   │             │    ┌──────────────────────┐     │               │                         │
│   │ webapp-    │    │  FIC                  │     │               │                         │
│   │ operator ──┼───▶│  (OIDC issuer trust)  │     │               │                         │
│   │             │    └──────────────────────┘     │               │                         │
│   └─────────────┘                                 └───────────────┘                         │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Numbered Steps (Equivalent to AWS Pod Identity)

| Step | Actor | Action | Azure Resource | API/Kind |
|------|-------|--------|----------------|----------|
| **①** | Application | Deploys webapp; webapp-operator creates ServiceAccount (1:1 mapping). Adds label/annotation for workload identity target. | ServiceAccount | `v1/ServiceAccount` with annotation `azure.workload.identity/client-id` |
| **②** | Application | Assigns RBAC on their Azure resources (Key Vault, Storage, etc.) to the UMI's `principalId`. Done **once**, not per cluster. | Role Assignment | `az role assignment create --assignee-object-id <principalId>` |
| **③** | webapp-operator | Creates UserAssignedIdentity CR in stable KPaaS identity RG (`kpaas-identities-<region>`). ASO reconciles to Azure. Deterministic name: `<app>-<ns>-<region>-wi-identity`. | UserAssignedIdentity | `managedidentity.azure.com/v1api20230131` kind: `UserAssignedIdentity` |
| **④** | webapp-operator | Creates FederatedIdentityCredential CR linking the UMI to this cluster's OIDC issuer + ServiceAccount subject. ASO reconciles to Azure. | FederatedIdentityCredential | `managedidentity.azure.com/v1api20230131` kind: `FederatedIdentityCredential` |
| **⑤** | Application | Pod authenticates via OIDC token → Azure AD exchanges for access token → accesses Key Vault/Storage/DB via SDK. | — | Azure SDK (DefaultAzureCredential) |

#### Comparison: AWS Pod Identity vs Azure Workload Identity (Option 3)

| Aspect | AWS (EKS Pod Identity) | Azure (AKS Workload Identity) |
|--------|----------------------|------------------------------|
| Platform operator | webapp-operator (uses ACK) | webapp-operator (uses ASO) |
| Resource reconciler | ACK (AWS Controllers for K8s) | ASO (Azure Service Operator) |
| Identity in platform account | IAM Role (`webapp-role`) in KPaaS AWS account | UserAssignedIdentity (UMI) in KPaaS subscription |
| Identity in app account | IAM Role (`nxop-role`) in app AWS account | RBAC Role Assignment on app resources |
| Trust mechanism | AssumeRole trust policy | FederatedIdentityCredential (OIDC issuer trust) |
| Pod binding | `PodIdentityAssociation` (ACK CR) | ServiceAccount annotation + `azure.workload.identity/use: "true"` label |
| Cross-account bridge | AssumeRole chain (webapp-role → nxop-role) | OIDC token exchange (SA → FIC → UMI → Azure AD token) |
| App team label | `runway.aa.com/aws-pod-identity: target-aws-account/target-role` | `runway.aa.com/azure-workload-identity: target-subscription/target-resource` |
| App team action | Create nxop-role with trust policy | Assign RBAC to UMI principalId |
| Migration impact | PodIdentityAssociation re-created per cluster | FIC added/removed per cluster; UMI stable |
| SDK usage | AWS SDK (STS AssumeRole) | Azure SDK (DefaultAzureCredential) |

#### Deterministic Naming Convention

UMI name is derived from app metadata **and region**, not cluster metadata:

```
<app-name>-<namespace>-<region>-wi-identity
```

**Why include region?** The same application may be deployed in multiple regions (e.g., eastus and westus) with separate UMIs per region. Each regional UMI gets its own RBAC assignments scoped to regional resources. Without region in the name, a multi-region app would collide on a single UMI.

| App | Namespace | Region | UMI Name |
|-----|-----------|--------|----------|
| payments | ns-payments | eastus | `payments-ns-payments-eastus-wi-identity` |
| payments | ns-payments | westus | `payments-ns-payments-westus-wi-identity` |
| catalog | ns-catalog | eastus | `catalog-ns-catalog-eastus-wi-identity` |

This ensures:
- Same app + same region → same identity (portable across clusters in that region)
- Same app + different region → different identity (separate RBAC per region)

#### Stable Identity Resource Group

A dedicated, long-lived resource group **per region** for identities — **not** tied to any single AKS cluster lifecycle:

```
/subscriptions/<KPAAS_SUB>/resourceGroups/kpaas-identities-eastus/
  └── providers/Microsoft.ManagedIdentity/userAssignedIdentities/
        ├── appA-ns-appA-eastus-wi-identity
        ├── appB-ns-appB-eastus-wi-identity
        └── ...

/subscriptions/<KPAAS_SUB>/resourceGroups/kpaas-identities-westus/
  └── providers/Microsoft.ManagedIdentity/userAssignedIdentities/
        ├── appA-ns-appA-westus-wi-identity
        ├── appB-ns-appB-westus-wi-identity
        └── ...
```

#### Migration Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│ 1. New cluster created                                            │
│ 2. WebApp CR applied to new cluster                               │
│ 3. Operator computes deterministic UMI name                       │
│ 4. Operator applies UserAssignedIdentity CR                       │
│    → ASO reconciles idempotently (adopts existing Azure resource)  │
│ 5. Operator ADDS new FIC (new cluster OIDC issuer)                │
│ 6. Operator creates ServiceAccount in new cluster                 │
│ 7. App workload starts on new cluster ✓                           │
│ 8. Old cluster drained                                            │
│ 9. Operator REMOVES old FIC (old cluster OIDC issuer)             │
└──────────────────────────────────────────────────────────────────┘
```

No RBAC changes. No app team involvement. Zero downtime for identity.

#### Multi-FIC Strategy During Migration

A single UMI supports multiple FICs simultaneously:

```
Before migration:
  UMI: appA-ns-appA-eastus-wi-identity
    ├── FIC: fic-cluster-old (issuer: old cluster OIDC URL)
    └── FIC: fic-cluster-new (issuer: new cluster OIDC URL)  ← added first

After migration validated:
  UMI: appA-ns-appA-eastus-wi-identity
    └── FIC: fic-cluster-new (issuer: new cluster OIDC URL)  ← old removed
```

RBAC assignments remain untouched — they're bound to the UMI's `principalId`, which never changes.

#### UMI Deletion Safety: Dynamic Reconcile-Policy Flip

**Problem:** When the WebApp CR is deleted on the old cluster, the operator's standard cleanup would delete the `UserAssignedIdentity` ASO CR → ASO deletes the UMI from Azure → **breaks the new cluster**.

**Why NOT always use `detach-on-delete`?** With many apps deploying and deleting frequently, permanent `detach-on-delete` creates a growing pile of orphan UMIs that require a separate cleanup process — a nightmare at scale.

**Solution: Dynamic policy flip during migration only.**

The webapp-operator changes the reconcile-policy **only during migration**, then the owning cluster reverts to `manage`:

| Phase | Old Cluster UMI Policy | New Cluster UMI Policy | Why |
|-------|----------------------|----------------------|-----|
| Normal operation | `manage` | — | Cluster owns the UMI lifecycle; deletion cleans up Azure |
| Migration starts | `manage` → **`detach-on-delete`** | `manage` | Old cluster won't destroy UMI when drained |
| Migration complete | `detach-on-delete` (inert) | `manage` | New cluster is now the **owner** of the UMI |
| Old cluster torn down | CR deleted → Azure UMI untouched ✅ | `manage` (active owner) | Safe |
| App decommissioned (deleted from new cluster) | — | `manage` → ASO **deletes** UMI from Azure ✅ | No orphan! |

#### How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│ MIGRATION FLOW                                                           │
│                                                                          │
│ 1. Migration triggered for app (old-cluster → new-cluster)               │
│ 2. Operator on OLD cluster patches UMI CR:                               │
│      reconcile-policy: manage → detach-on-delete                         │
│ 3. WebApp CR applied to NEW cluster                                      │
│ 4. Operator on NEW cluster creates UMI CR with policy: manage            │
│      → ASO adopts existing Azure resource (idempotent)                   │
│ 5. Operator on NEW cluster adds FIC for new cluster OIDC                 │
│ 6. App workload starts on new cluster ✓                                  │
│ 7. Old cluster drained, WebApp CR deleted                                │
│      → Old FIC deleted (normal delete)                                   │
│      → UMI CR deleted BUT Azure resource survives (detach-on-delete)     │
│ 8. New cluster is now sole owner with manage policy                      │
│                                                                          │
│ RESULT: When app is eventually deleted from new cluster,                 │
│         ASO deletes the UMI from Azure. No orphans. No cleanup jobs.     │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Operator Go Code: Migration Policy Flip

```go
// Triggered when migration is initiated for this app to a new cluster
func (r *WebAppReconciler) handleMigrationOut(ctx context.Context, webapp *v1alpha1.WebApp) error {
    log := log.FromContext(ctx)
    name := umiName(webapp)

    // Patch UMI CR to detach-on-delete so teardown of this cluster won't destroy the Azure UMI
    uai := &managedidentity.UserAssignedIdentity{}
    if err := r.Get(ctx, client.ObjectKey{Name: name, Namespace: webapp.Namespace}, uai); err != nil {
        return err
    }

    if uai.Annotations == nil {
        uai.Annotations = map[string]string{}
    }
    uai.Annotations["serviceoperator.azure.com/reconcile-policy"] = "detach-on-delete"

    if err := r.Update(ctx, uai); err != nil {
        return err
    }

    log.Info("switched UMI to detach-on-delete for migration", "umi", name)
    return nil
}
```

#### Operator Go Code: New Cluster Takes Ownership

```go
func (r *WebAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    webapp := &v1alpha1.WebApp{}
    if err := r.Get(ctx, req.NamespacedName, webapp); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    name := umiName(webapp)

    // 1. Apply UserAssignedIdentity CR with reconcile-policy: manage
    //    This cluster is the OWNER — if app is deleted here, UMI should be cleaned up
    uai := buildUserAssignedIdentity(name, webapp.Namespace, r.IdentityRG, r.Subscription, r.Location)
    uai.Annotations["serviceoperator.azure.com/reconcile-policy"] = "manage"
    if err := r.applyASOResource(ctx, uai); err != nil {
        return ctrl.Result{}, err
    }

    // 2. Apply FIC for THIS cluster's OIDC issuer
    ficName := fmt.Sprintf("%s-fic-%s", name, r.ClusterShortID)
    fic := buildFederatedIdentityCredential(ficName, name, webapp.Namespace, r.OIDCIssuer, webapp.Name)
    if err := r.applyASOResource(ctx, fic); err != nil {
        return ctrl.Result{}, err
    }

    // 3. Create/patch ServiceAccount
    clientId, err := r.waitForClientId(ctx, name, webapp.Namespace)
    if err != nil {
        return ctrl.Result{}, err
    }
    if err := r.ensureServiceAccount(ctx, webapp, clientId); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}
```

#### Operator Go Code: Delete Handler (Normal + Migration)

```go
func (r *WebAppReconciler) handleDelete(ctx context.Context, webapp *v1alpha1.WebApp) error {
    log := log.FromContext(ctx)
    name := umiName(webapp)

    // 1. Delete THIS cluster's FIC (always safe — cluster-specific)
    ficName := fmt.Sprintf("%s-fic-%s", name, r.ClusterShortID)
    if err := r.deleteASOResource(ctx, ficName, webapp.Namespace, "FederatedIdentityCredential"); err != nil {
        return err
    }

    // 2. Delete ServiceAccount (cluster-local, safe)
    if err := r.deleteServiceAccount(ctx, webapp); err != nil {
        return err
    }

    // 3. Delete UserAssignedIdentity CR
    //    - If policy is "manage" (this cluster owns it) → ASO deletes Azure UMI (app decommissioned)
    //    - If policy is "detach-on-delete" (migrated away) → ASO removes CR, Azure UMI survives
    uai := &managedidentity.UserAssignedIdentity{}
    if err := r.Get(ctx, client.ObjectKey{Name: name, Namespace: webapp.Namespace}, uai); err != nil {
        if apierrors.IsNotFound(err) {
            return nil // Already gone
        }
        return err
    }

    policy := uai.Annotations["serviceoperator.azure.com/reconcile-policy"]
    log.Info("deleting UMI CR", "umi", name, "policy", policy)

    if err := r.Delete(ctx, uai); err != nil {
        return client.IgnoreNotFound(err)
    }

    return nil
}
```

#### What Happens If WebApp Is Deleted From ALL Clusters?

**Scenario: App decommissioned (not a migration)**

If the app is deleted from all clusters and no migration was triggered:

1. The cluster that still has `manage` policy deletes the WebApp → operator calls `handleDelete` → ASO deletes the UMI from Azure ✅
2. No orphan. No cleanup needed.

**Scenario: Both clusters delete after migration**

1. **Old cluster** (policy: `detach-on-delete`) deletes WebApp → FIC removed, UMI CR removed, Azure UMI **survives**
2. **New cluster** (policy: `manage`) deletes WebApp → FIC removed, UMI CR removed, Azure UMI **deleted** ✅

| Situation | Outcome |
|-----------|---------|
| App deleted from owning cluster (`manage`) | UMI deleted from Azure — clean |
| App deleted from non-owning cluster (`detach-on-delete`) | UMI stays in Azure — safe |
| App deleted from ALL clusters | Owning cluster's delete removes UMI — no orphan |
| Migration then old cluster torn down | Old cluster detaches, new cluster owns — clean |

> **Key insight:** There is always exactly **one cluster** with `manage` policy per UMI at any given time. That cluster is the owner. Ownership transfer happens during migration via the policy flip.

#### Edge Case: What If Owning Cluster Dies Unexpectedly?

If the owning cluster (with `manage` policy) is destroyed without graceful WebApp deletion:

- The UMI persists in Azure (no CR deletion triggered = no ASO action)
- The FIC for that cluster becomes stale but harmless
- **Recovery:** Deploy WebApp to a new cluster → operator adopts UMI with `manage` → back to normal
- **If app is truly decommissioned:** A lightweight audit script (not a nightly nightmare) can catch UMIs where all FICs reference non-existent cluster OIDC issuers

```bash
# One-off audit for UMIs with stale FICs (not a recurring cleanup job)
az identity list -g kpaas-identities-eastus --query "[].name" -o tsv | while read id; do
  echo "=== $id ==="
  az identity federated-credential list --identity-name "$id" -g kpaas-identities-eastus \
    --query "[].{name:name, issuer:issuer}" -o table
done
```

---

#### How the WebApp Operator Detects Existing UMI (Go)

**ASO handles this natively.** The operator always applies the `UserAssignedIdentity` CR with the deterministic name. ASO's default `reconcile-policy: manage` behavior:

- **Resource doesn't exist in Azure** → Creates it
- **Resource already exists in Azure** → Adopts and reconciles it (idempotent)

```go
// Deterministic name — same on any cluster for the same app+region
func umiName(webapp *v1alpha1.WebApp) string {
    return fmt.Sprintf("%s-%s-%s-wi-identity", webapp.Name, webapp.Namespace, webapp.Spec.Region)
}

func (r *WebAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    webapp := &v1alpha1.WebApp{}
    if err := r.Get(ctx, req.NamespacedName, webapp); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    name := umiName(webapp)

    // 1. Apply UserAssignedIdentity CR — ASO handles create-or-adopt
    uai := buildUserAssignedIdentity(name, webapp.Namespace, r.IdentityRG, r.Subscription, r.Location)
    if err := r.applyASOResource(ctx, uai); err != nil {
        return ctrl.Result{}, err
    }

    // 2. Wait for ASO to report status (clientId becomes available)
    clientId, err := r.waitForClientId(ctx, name, webapp.Namespace)
    if err != nil {
        return ctrl.Result{}, err
    }

    // 3. Apply FIC for THIS cluster's OIDC issuer
    ficName := fmt.Sprintf("%s-fic-%s", name, r.ClusterShortID)
    fic := buildFederatedIdentityCredential(ficName, name, webapp.Namespace, r.OIDCIssuer, webapp.Name)
    if err := r.applyASOResource(ctx, fic); err != nil {
        return ctrl.Result{}, err
    }

    // 4. Create/patch ServiceAccount with clientId annotation
    if err := r.ensureServiceAccount(ctx, webapp, clientId); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}
```

The operator code is **identical** whether it's a fresh deploy or a migration. No special "detection" logic needed — ASO's idempotent reconciliation handles it transparently.

#### ASO Resource Definitions (Option 3)

**1. UserAssignedIdentity** (created once, survives migrations):

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: UserAssignedIdentity
metadata:
  name: <app-name>-<namespace>-<region>-wi-identity
  namespace: <app-namespace>
  annotations:
    serviceoperator.azure.com/reconcile-policy: manage  # owning cluster; flipped to detach-on-delete during migration
spec:
  location: <region>
  owner:
    armId: /subscriptions/<KPAAS_SUB>/resourceGroups/kpaas-identities-<region>
  operatorSpec:
    configMaps:
      clientId:
        name: <app-name>-<region>-wi-identity-info
        key: clientId
      principalId:
        name: <app-name>-<region>-wi-identity-info
        key: principalId
```

**2. FederatedIdentityCredential** (one per cluster — includes cluster identifier in name):

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: <app-name>-<namespace>-<region>-fic-<cluster-short-id>
  namespace: <app-namespace>
spec:
  owner:
    name: <app-name>-<namespace>-<region>-wi-identity
  issuer: <THIS_CLUSTER_OIDC_ISSUER>
  subject: system:serviceaccount:<app-namespace>:<app-name>-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

**3. ServiceAccount** (patched by operator after clientId is known):

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <app-name>-wi-sa
  namespace: <app-namespace>
  annotations:
    azure.workload.identity/client-id: "<clientId from ASO status/ConfigMap>"
```

#### Security Controls

| Threat | Mitigation |
|--------|------------|
| App A references App B's UMI | Operator rejects — UMI name is deterministic from CR metadata, not user-supplied |
| Namespace squatting | Namespace creation is controlled (KPaaS onboarding process) |
| Stale FICs after migration | Operator garbage-collects FICs when WebApp CR is deleted from old cluster |
| Cross-namespace escalation | FIC `subject` includes namespace — SA in wrong namespace cannot authenticate |
| Operator credential scope | ASO credentials only need write access to `kpaas-identities-*` RG (single subscription) |

#### App Team Experience

App teams do this **once** (not per migration):

```bash
# Get the identity's principalId from the ConfigMap or ASO status
PRINCIPAL_ID=$(kubectl get cm <app-name>-wi-identity-info -n <ns> -o jsonpath='{.data.principalId}')

# Assign RBAC on their resource
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<APP_SUB>/resourceGroups/<APP_RG>/providers/Microsoft.KeyVault/vaults/<kv>"
```

#### Comparison: All Three Options

| Criteria | Option 1 | Option 2 | Option 3 |
|----------|----------|----------|----------|
| Identity ownership | App team | KPaaS | KPaaS |
| Cross-app leakage | Risk | None | None |
| Cross-subscription write access | Required | Not required | Not required |
| Migration impact | None | Breaking (new UMI) | **None (same UMI)** |
| App team RBAC changes on migration | None | Required | **None** |
| ASO compatibility | Needs per-resource creds | Global creds | Global creds |
| Identity lifecycle | Tied to app team | Tied to cluster | **Tied to app (stable)** |
| Teardown | Complex | Simple | Simple |

> **Azure limit:** 20 FICs per identity — sufficient for most scenarios (you won't have 20 simultaneous clusters for one app).

---

### Recommendation

| | Option 1 (App Sub) | Option 2 (KPaaS Sub) | Option 3 (Stable Lifecycle) |
|---|---|---|---|
| **Status** | Avoid — security risk | Legacy | **Standard / Default** |
| **When to use** | Never (unless explicit exception) | Existing setups not yet migrated | All new workload identity setups |
| **Requires** | Cross-sub SP creds or manual CLI | Only KPaaS subscription access | Only KPaaS subscription access + stable identity RG |

---

## Issue 4: SubscriptionMismatch When Creating FIC in Another Subscription via ASO

### FIC YAML Applied

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: sravan-crossaccount-wi-fic
  namespace: sravan-test
spec:
  owner:
    #name: myIdentityd82d2e
    armId: /subscriptions/e540da57-5250-45d5-9c19-74c5de18d0ab/resourcegroups/kaas-pstgrs-p/providers/Microsoft.ManagedIdentity/userAssignedIdentities/kpaas-crossaccount-test-mi
  issuer: https://westus.oic.prod-aks.azure.com/49793faf-eb3f-4d99-a0cf-aef7cce79dc1/3a2d9259-83ff-441e-9266-1ee4583da753/
  subject: system:serviceaccount:sravan-test:sravan-crosscount-wi-sa
  audiences:
    - api://AzureADTokenExchange
```

### Error
```
SubscriptionMismatch: SubscriptionID "e540da57-5250-45d5-9c19-74c5de18d0ab" for
"/subscriptions/e540da57-5250-45d5-9c19-74c5de18d0ab/resourcegroups/kaas-pstgrs-p/providers/
Microsoft.ManagedIdentity/userAssignedIdentities/kpaas-crossaccount-test-mi/
federatedIdentityCredentials/sravan-crossaccount-wi-fic"
resource does not match with Client Credential: "2fe97b8d-f7b5-4964-85b0-48740441865e"
```

### ASO Controller Logs

```
# Create attempt fails
E0416 00:57:44.368958 generic_reconciler.go:384] "Encountered error impacting Ready condition"
  err="Reason: SubscriptionMismatch, Severity: Error, RetryClassification: RetryFast,
  Cause: SubscriptionID \"e540da57-5250-45d5-9c19-74c5de18d0ab\" ... does not match
  with Client Credential: \"2fe97b8d-f7b5-4964-85b0-48740441865e\""

# Delete attempt also fails with the same error — resource gets stuck
E0416 01:09:32.350389 generic_reconciler.go:384] "Encountered error impacting Ready condition"
  err="Reason: SubscriptionMismatch ... reason="DeleteActionError"
```

> **Warning:** The resource also **cannot be deleted** by ASO due to the same subscription mismatch. The finalizer `serviceoperator.azure.com/finalizer` blocks `kubectl delete`. To force-remove a stuck resource, manually remove the finalizer:
>
> ```bash
> kubectl patch federatedidentitycredential sravan-crossaccount-wi-fic \
>   -n sravan-test \
>   --type=merge \
>   -p '{"metadata":{"finalizers":[]}}'
> ```

### Cause
ASO's global credential (`aso-controller-settings`) is configured for the **KPaaS subscription** (`2fe97b8d-...`), but the FIC resource targets a managed identity in the **app subscription** (`e540da57-...`). ASO validates that the resource's subscription matches the credential's `AZURE_SUBSCRIPTION_ID` and rejects the request.

### Fix: Use Namespaced or Per-Resource Credentials

ASO supports three credential scopes:
1. **Global** — `azureserviceoperator-system/aso-controller-settings` (default, single subscription)
2. **Namespaced** — a secret named `aso-credential` in the same namespace as the resource
3. **Per-resource** — annotation pointing to a specific secret

#### Option A: Namespaced Credential

Create a secret named `aso-credential` in the namespace where the FIC CR lives, with credentials that have access to the **app subscription**:

```bash
kubectl create secret generic aso-credential \
  --namespace=sravan-test \
  --from-literal=AZURE_SUBSCRIPTION_ID="e540da57-5250-45d5-9c19-74c5de18d0ab" \
  --from-literal=AZURE_TENANT_ID="<tenant-id>" \
  --from-literal=AZURE_CLIENT_ID="<sp-client-id-with-app-sub-access>" \
  --from-literal=AZURE_CLIENT_SECRET="<sp-secret>"
```

> ASO automatically picks up `aso-credential` in the resource's namespace, overriding the global credential for all ASO resources in that namespace.

#### Option B: Per-Resource Credential

Create a secret with any name and annotate the FIC CR to use it:

```bash
kubectl create secret generic aso-app-sub-credential \
  --namespace=sravan-test \
  --from-literal=AZURE_SUBSCRIPTION_ID="e540da57-5250-45d5-9c19-74c5de18d0ab" \
  --from-literal=AZURE_TENANT_ID="<tenant-id>" \
  --from-literal=AZURE_CLIENT_ID="<sp-client-id-with-app-sub-access>" \
  --from-literal=AZURE_CLIENT_SECRET="<sp-secret>"
```

Then annotate the FIC resource:

```yaml
apiVersion: managedidentity.azure.com/v1api20230131
kind: FederatedIdentityCredential
metadata:
  name: sravan-crossaccount-wi-fic
  namespace: sravan-test
  annotations:
    serviceoperator.azure.com/credential-from: aso-app-sub-credential
spec:
  owner:
    armId: /subscriptions/e540da57-5250-45d5-9c19-74c5de18d0ab/resourcegroups/kaas-pstgrs-p/providers/Microsoft.ManagedIdentity/userAssignedIdentities/kpaas-crossaccount-test-mi
  issuer: <AKS_OIDC_ISSUER from KPaaS cluster>
  subject: system:serviceaccount:sravan-test:<service-account-name>
  audiences:
    - api://AzureADTokenExchange
```

> **Per-resource** is preferred when only specific resources need cross-subscription access, so other ASO resources in the same namespace continue using the global credential.

#### Option C: Use Azure CLI Instead of ASO

If providing cross-subscription SP credentials to ASO is not desirable, create the FIC directly via CLI:

```bash
az identity federated-credential create \
  --name "sravan-crossaccount-wi-fic" \
  --identity-name "kpaas-crossaccount-test-mi" \
  --resource-group "kaas-pstgrs-p" \
  --subscription "e540da57-5250-45d5-9c19-74c5de18d0ab" \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject "system:serviceaccount:sravan-test:<service-account-name>" \
  --audiences "api://AzureADTokenExchange"
```

> **Note:** The SP or logged-in user must have `Managed Identity Contributor` role on the managed identity in the app subscription.

### Credential Precedence

ASO resolves credentials in this order (first match wins):

| Priority | Scope | Secret Name / Location |
|----------|-------|----------------------|
| 1 | Per-resource | Annotation `serviceoperator.azure.com/credential-from` |
| 2 | Namespaced | `aso-credential` in the resource's namespace |
| 3 | Global | `aso-controller-settings` in `azureserviceoperator-system` |

---

## Summary of Root Causes & Fixes

| # | Error | Root Cause | Fix |
|---|-------|-----------|-----|
| 1 | `WaitingForOwner` | Identity exists in Azure but not as a K8s CR | Use `owner.armId` instead of `owner.name` |
| 2 | `global credential not configured` | ASO secret had empty Azure credentials | Patch `aso-controller-settings` with SP credentials |
| 3 | `invalid polling URL` | FIC already existed in Azure | Delete from Azure and let ASO recreate |
| 4 | `SubscriptionMismatch` | ASO global credential is for a different subscription than the target resource | Use namespaced (`aso-credential`) or per-resource credential, or create FIC via CLI |
