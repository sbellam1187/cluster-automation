# ADOT POC Evaluation

## Overview

This Proof of Concept (POC) evaluates two approaches for collecting application custom metrics and streaming them to **Amazon CloudWatch**.

The goal is to compare the implementation details, operational complexity, observability flow, and overall scalability of each option.

### Approaches Under Evaluation

1. **ADOT Collector (By KPaaS)**
   - Application emits custom metrics
   - Metrics are collected by **AWS Distro for OpenTelemetry (ADOT) Collector**
   - ADOT Collector exports metrics directly to **Amazon CloudWatch**

> <img width="1340" height="360" alt="CloudWatch drawio" src="https://github.com/user-attachments/assets/75d238ae-2404-4528-8e85-ce099bea13d6" />


2. **Dynatrace OneAgent + Dynatrace SaaS (By SAE)**
   - Application emits custom metrics
   - Metrics are collected by **Dynatrace OneAgent/Activegate**
   - Metrics flow through **Dynatrace SaaS**
   - Metrics are then streamed to **Amazon CloudWatch**

> <img width="1680" height="360" alt="CloudWatch-DT drawio" src="https://github.com/user-attachments/assets/b26e6ea2-38cb-4311-b6cf-b92723906e54" />

## Objective

The purpose of this POC is to determine the best approach for collecting and publishing application-level custom metrics to CloudWatch while evaluating:

- Ease of implementation
- Design complexity
- Operational overhead
- Performance and latency
- Scalability
- Troubleshooting experience

## Scope

This evaluation focuses only on **custom application metrics**.

### In Scope

- Application-generated business (NXOP Business Metrics)
- Metric collection pipeline Complexity
- Export path to Amazon CloudWatch
- Metadata and dimensional enrichment
- Failure handling and retry behavior
- Operational and support considerations

### Out of Scope

- Distributed tracing
- Log forwarding
- Infrastructure host metrics
- Cloudwatch Agent Installation

## Implementational Details

>**Cluster:** kaas-nxop-np-eks-3001-westus
>**Region:** us-west-2
>**App Namespace:** nxop-core-nonprod
>**ADOT Namespace:** opentelemetry-operator-system
>**Cloudwatch ACC (KPaaS):** 285282426848
>**Cloudwatch ACC (NXOP):** 972818039298
>**Cloudwatch ARN (NXOP):** `arn:aws:oam:us-west-2:972818039298:sink/62077a21-c1d3-44b2-8606-955e87bf2764`

### Deployment Details

- **Deployment Mode:** AWS Distro for OpenTelemetry (ADOT) EKS Add-on
- **Namespace:** opentelemetry-operator-system
- **Components:** 
  - ADOT Operator (OTEL Control Plane)
    - adot-col-prom-metrics (Prometheus Collector)
    - adot-col-otlp-ingest (OTEL Metrics/Trace Collector)
- **Replicas:** 1 per component (Total:3)
- **Resources:**
  - CPU:
    - Requests: 300m
    - Limits: 2000m
  - Mem: 
    - Requests: 512Mi
    - Limits: 4Gi
- **IAM Roles:**
  - adot-col-prom-metrics(sa): `arn:aws:iam::285282426848:role/AmazonEKSPodIdentityADOT-adot-col-prom-metrics-Role`
  - adot-col-otlp-ingest(sa): `arn:aws:iam::285282426848:role/AmazonEKSPodIdentityADOT-adot-col-otlp-ingest-Role`
  - adot-col-container-logs(sa): `arn:aws:iam::285282426848:role/AmazonEKSPodIdentityADOT-adot-col-container-logs-Role`
- **OTEL Endpoints:**
> HTTPS
> ``` log
> adot-col-otlp-ingest-collector.opentelemetry-operator-system.svc.cluster.local:4318/v1/metrics
> ```
> gRPC
> ``` log
> adot-col-otlp-ingest-collector.opentelemetry-operator-system.svc.cluster.local:4317
> ```

### ADOT Configuration

<details>
<summary><b>Operator Configuration</b></summary>

``` yaml
collector:
  prometheusMetrics:
    resources:
      limits:
        cpu: 2000m
        memory: 4Gi
      requests:
        cpu: 300m
        memory: 512Mi
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: "arn:aws:iam::285282426848:role/AmazonEKSPodIdentityADOT-adot-col-prom-metrics-Role"
    pipelines:
      metrics:
        amp:
          enabled: false
        emf:
          enabled: true
  otlpIngest:
    resources:
      limits:
        cpu: 2000m
        memory: 4Gi
      requests:
        cpu: 300m
        memory: 512Mi
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: "arn:aws:iam::285282426848:role/AmazonEKSPodIdentityADOT-adot-col-otlp-ingest-Role"
    pipelines:
      traces:
        xray:
          enabled: true
```
</details>

<details>
<summary><b>Opentelemetrycollectors -- adot-col-prom-metrics</b></summary>

``` yaml
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  creationTimestamp: "2026-03-23T21:18:51Z"
  finalizers:
  - opentelemetrycollector.opentelemetry.io/finalizer
  generation: 4
  name: adot-col-prom-metrics
  namespace: opentelemetry-operator-system
  resourceVersion: "115224154"
  uid: 0f96cb9c-2e9b-4667-871d-562baba4774f
spec:
  config:
    exporters:
      awsemf:
        dimension_rollup_option: NoDimensionRollup
        log_group_name: /aws/containerinsights/${CLUSTER_NAME}/prometheus
        metric_declarations:
        - dimensions:
          - - EKS_Cluster
            - EKS_Namespace
            - EKS_PodName
          metric_name_selectors:
          - apiserver_request_.*
          - container_memory_.*
          - container_threads
          - otelcol_process_.*
          - ^process_cpu_seconds_total$
          - ^jvm_memory_used_bytes$
          - ^container_cpu_cfs_periods_total$
        namespace: ContainerInsights/Prometheus
        parse_json_encoded_attr_values:
        - Sources
        - kubernetes
        region: us-west-2
        resource_to_telemetry_conversion:
          enabled: true
    processors:
      batch/metrics:
        timeout: 60s
      metricstransform/labelling:
        transforms:
        - action: update
          include: .*
          match_type: regexp
          operations:
          - action: add_label
            new_label: EKS_Cluster
            new_value: ${CLUSTER_NAME}
          - action: update_label
            label: kubernetes_pod_name
            new_label: EKS_PodName
          - action: update_label
            label: kubernetes_namespace
            new_label: EKS_Namespace
    receivers:
      prometheus:
        config:
          global:
            scrape_interval: 15s
            scrape_timeout: 10s
          scrape_configs:
          - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
            job_name: kubernetes-apiservers
            kubernetes_sd_configs:
            - role: endpoints
            relabel_configs:
            - action: keep
              regex: default;kubernetes;https
              source_labels:
              - __meta_kubernetes_namespace
              - __meta_kubernetes_service_name
              - __meta_kubernetes_endpoint_port_name
            scheme: https
            tls_config:
              ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecure_skip_verify: true
          - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
            job_name: kubernetes-nodes
            kubernetes_sd_configs:
            - role: node
            relabel_configs:
            - action: labelmap
              regex: __meta_kubernetes_node_label_(.+)
            - replacement: kubernetes.default.svc:443
              target_label: __address__
            - regex: (.+)
              replacement: /api/v1/nodes/$$1/proxy/metrics
              source_labels:
              - __meta_kubernetes_node_name
              target_label: __metrics_path__
            scheme: https
            tls_config:
              ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecure_skip_verify: true
          - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
            job_name: kubernetes-nodes-cadvisor
            kubernetes_sd_configs:
            - role: node
            relabel_configs:
            - action: labelmap
              regex: __meta_kubernetes_node_label_(.+)
            - replacement: kubernetes.default.svc:443
              target_label: __address__
            - regex: (.+)
              replacement: /api/v1/nodes/$$1/proxy/metrics/cadvisor
              source_labels:
              - __meta_kubernetes_node_name
              target_label: __metrics_path__
            scheme: https
            tls_config:
              ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              insecure_skip_verify: true
          - job_name: kubernetes-service-endpoints
            kubernetes_sd_configs:
            - role: endpoints
            relabel_configs:
            - action: keep
              regex: true
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scrape
            - action: replace
              regex: (https?)
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scheme
              target_label: __scheme__
            - action: replace
              regex: (.+)
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_path
              target_label: __metrics_path__
            - action: replace
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $$1:$$2
              source_labels:
              - __address__
              - __meta_kubernetes_service_annotation_prometheus_io_port
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
              replacement: __param_$$1
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - action: replace
              source_labels:
              - __meta_kubernetes_namespace
              target_label: kubernetes_namespace
            - action: replace
              source_labels:
              - __meta_kubernetes_service_name
              target_label: kubernetes_name
            - action: replace
              source_labels:
              - __meta_kubernetes_pod_node_name
              target_label: kubernetes_node
          - job_name: kubernetes-service-endpoints-slow
            kubernetes_sd_configs:
            - role: endpoints
            relabel_configs:
            - action: keep
              regex: true
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scrape_slow
            - action: replace
              regex: (https?)
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_scheme
              target_label: __scheme__
            - action: replace
              regex: (.+)
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_path
              target_label: __metrics_path__
            - action: replace
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $$1:$$2
              source_labels:
              - __address__
              - __meta_kubernetes_service_annotation_prometheus_io_port
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
              replacement: __param_$$1
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - action: replace
              source_labels:
              - __meta_kubernetes_namespace
              target_label: kubernetes_namespace
            - action: replace
              source_labels:
              - __meta_kubernetes_service_name
              target_label: kubernetes_name
            - action: replace
              source_labels:
              - __meta_kubernetes_pod_node_name
              target_label: kubernetes_node
            scrape_interval: 5m
            scrape_timeout: 30s
          - honor_labels: true
            job_name: prometheus-pushgateway
            kubernetes_sd_configs:
            - role: service
            relabel_configs:
            - action: keep
              regex: pushgateway
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_probe
          - job_name: kubernetes-services
            kubernetes_sd_configs:
            - role: service
            metrics_path: /probe
            params:
              module:
              - http_2xx
            relabel_configs:
            - action: keep
              regex: true
              source_labels:
              - __meta_kubernetes_service_annotation_prometheus_io_probe
            - source_labels:
              - __address__
              target_label: __param_target
            - replacement: blackbox
              target_label: __address__
            - source_labels:
              - __param_target
              target_label: instance
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - source_labels:
              - __meta_kubernetes_namespace
              target_label: kubernetes_namespace
            - source_labels:
              - __meta_kubernetes_service_name
              target_label: kubernetes_name
          - job_name: kubernetes-pods
            kubernetes_sd_configs:
            - role: pod
            relabel_configs:
            - action: keep
              regex: true
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scrape
            - action: replace
              regex: (https?)
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scheme
              target_label: __scheme__
            - action: replace
              regex: (.+)
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_path
              target_label: __metrics_path__
            - action: replace
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $$1:$$2
              source_labels:
              - __address__
              - __meta_kubernetes_pod_annotation_prometheus_io_port
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
              replacement: __param_$$1
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - action: replace
              source_labels:
              - __meta_kubernetes_namespace
              target_label: kubernetes_namespace
            - action: replace
              source_labels:
              - __meta_kubernetes_pod_name
              target_label: kubernetes_pod_name
            - action: drop
              regex: Pending|Succeeded|Failed|Completed
              source_labels:
              - __meta_kubernetes_pod_phase
          - job_name: kubernetes-pods-slow
            kubernetes_sd_configs:
            - role: pod
            relabel_configs:
            - action: keep
              regex: true
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scrape_slow
            - action: replace
              regex: (https?)
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_scheme
              target_label: __scheme__
            - action: replace
              regex: (.+)
              source_labels:
              - __meta_kubernetes_pod_annotation_prometheus_io_path
              target_label: __metrics_path__
            - action: replace
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $$1:$$2
              source_labels:
              - __address__
              - __meta_kubernetes_pod_annotation_prometheus_io_port
              target_label: __address__
            - action: labelmap
              regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
              replacement: __param_$$1
            - action: labelmap
              regex: __meta_kubernetes_pod_label_(.+)
            - action: replace
              source_labels:
              - __meta_kubernetes_namespace
              target_label: namespace
            - action: replace
              source_labels:
              - __meta_kubernetes_pod_name
              target_label: pod
            - action: drop
              regex: Pending|Succeeded|Failed|Completed
              source_labels:
              - __meta_kubernetes_pod_phase
            scrape_interval: 5m
            scrape_timeout: 30s
    service:
      pipelines:
        metrics/cloudwatch:
          exporters:
          - awsemf
          processors:
          - batch/metrics
          - metricstransform/labelling
          receivers:
          - prometheus
      telemetry:
        metrics:
          readers:
          - pull:
              exporter:
                prometheus:
                  host: 0.0.0.0
                  port: 8888
  configVersions: 3
  daemonSetUpdateStrategy: {}
  deploymentUpdateStrategy: {}
  env:
  - name: CLUSTER_NAME
    value: kaas-nxop-np-eks-3001-westus
  image: public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0
  ingress:
    route: {}
  ipFamilyPolicy: SingleStack
  managementState: managed
  mode: deployment
  networkPolicy: {}
  observability:
    metrics: {}
  podAnnotations:
    prometheus.io/port: "8888"
    prometheus.io/scrape: "true"
  podDnsConfig: {}
  replicas: 1
  resources:
    limits:
      cpu: "2"
      memory: 4Gi
    requests:
      cpu: 300m
      memory: 512Mi
  serviceAccount: adot-col-prom-metrics
  targetAllocator:
    allocationStrategy: consistent-hashing
    collectorNotReadyGracePeriod: 30s
    collectorTargetReloadInterval: 30s
    filterStrategy: relabel-config
    observability:
      metrics: {}
    prometheusCR:
      scrapeInterval: 30s
    resources: {}
  upgradeStrategy: automatic
status:
  image: public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0
  scale:
    replicas: 1
    selector: app.kubernetes.io/component=opentelemetry-collector,app.kubernetes.io/instance=opentelemetry-operator-system.adot-col-prom-metrics,app.kubernetes.io/managed-by=opentelemetry-operator,app.kubernetes.io/name=adot-col-prom-metrics-collector,app.kubernetes.io/part-of=opentelemetry,app.kubernetes.io/version=v0.46.0
    statusReplicas: 1/1
  version: 0.141.0

```
</details>

<details>
<summary><b>Opentelemetrycollectors -- adot-col-otlp-ingest</b></summary>

``` yaml
apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  creationTimestamp: "2026-03-23T21:18:50Z"
  finalizers:
  - opentelemetrycollector.opentelemetry.io/finalizer
  generation: 8
  name: adot-col-otlp-ingest
  namespace: opentelemetry-operator-system
  resourceVersion: "117693206"
  uid: bad820dd-8320-4fec-838f-a6ba729d7513
spec:
  config:
    exporters:
      awsemf:
        dimension_rollup_option: NoDimensionRollup
        log_group_name: /aws/containerinsights/kaas-nxop-np-eks-3001-westus/otlp-metrics
        metric_declarations:
        - dimensions:
          - - EKS_Cluster
            - k8s.namespace.name
            - k8s.pod.name
            - k8s.node.name
          - - EKS_Cluster
            - k8s.namespace.name
            - k8s.pod.name
          - - EKS_Cluster
            - k8s.pod.name
          - - EKS_Cluster
          - []
          metric_name_selectors:
          - .*
        namespace: NXOP/BusinessMetrics
        region: us-west-2
        resource_to_telemetry_conversion:
          enabled: true
      awsxray:
        region: us-west-2
      debug:
        verbosity: detailed
    processors:
      batch:
        timeout: 60s
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    service:
      pipelines:
        metrics/cloudwatch:
          exporters:
          - awsemf
          - debug
          processors:
          - batch
          receivers:
          - otlp
        traces/xray:
          exporters:
          - awsxray
          processors:
          - batch
          receivers:
          - otlp
      telemetry:
        metrics:
          readers:
          - pull:
              exporter:
                prometheus:
                  host: 0.0.0.0
                  port: 8888
  configVersions: 3
  daemonSetUpdateStrategy: {}
  deploymentUpdateStrategy: {}
  image: public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0
  ingress:
    route: {}
  ipFamilyPolicy: SingleStack
  managementState: managed
  mode: deployment
  networkPolicy: {}
  observability:
    metrics: {}
  podDnsConfig: {}
  replicas: 1
  resources:
    limits:
      cpu: "2"
      memory: 4Gi
    requests:
      cpu: 300m
      memory: 512Mi
  serviceAccount: adot-col-otlp-ingest
  targetAllocator:
    allocationStrategy: consistent-hashing
    collectorNotReadyGracePeriod: 30s
    collectorTargetReloadInterval: 30s
    filterStrategy: relabel-config
    observability:
      metrics: {}
    prometheusCR:
      scrapeInterval: 30s
    resources: {}
  upgradeStrategy: automatic
status:
  image: public.ecr.aws/aws-observability/aws-otel-collector:v0.46.0
  scale:
    replicas: 1
    selector: app.kubernetes.io/component=opentelemetry-collector,app.kubernetes.io/instance=opentelemetry-operator-system.adot-col-otlp-ingest,app.kubernetes.io/managed-by=opentelemetry-operator,app.kubernetes.io/name=adot-col-otlp-ingest-collector,app.kubernetes.io/part-of=opentelemetry,app.kubernetes.io/version=v0.46.0
    statusReplicas: 1/1
  version: 0.141.0

```
</details>

### NXOP Custom Metrics

``` log
    "fee.airport.lookup.time",
    "fee.airport.enhancement.time",
    "fee.airport.event.processing.time",
    "fee.documentdb.available",
    "fee.event.processing.time",
    "fee.flight.enhancement.time",
    "fee.kafka.publish.success.total",
    "fee.kafka.publish.time",
    "fee.maintenance.enhancement.time",
    "fee.maintenance.event.processing.time",
```

## Observations

> [!NOTE]
> Applicable to ADOT Installation (Option-1). 

- **Ease of implementation**
  - Easy -- Supports Helm Charts, TF and EKS Add-on templates
- **Design Complexity**
  - ADOT is tailored for AWS Cloudwatch, lacks flexibility expanding ADOT capabilities beyond AWS. 
  - Requires installing dedicated "OTEL Collector" for each one of the following use-cases..
    - Prometheus metrics
    - OTEL Metrics/Traces
    - OTEL Logs
    - Per App/Tenant based on application telemetry requirements
- **Operational Overhead**
  - Requires adding multiple agents (3) to support ADOT
  - Pipeline troubleshooting is hard
  - Life Cycle Management of ADOT components
  - Visibility into Upstream Cloudwatch accounts
- **Performance and Latency**
  - Not evaluated
- **Scalability**
  - Hard to scale pipeline configuration for various app/tenants without adding new collectors
  - Filtering will be resource heavy
- **Troubleshooting**
  - Troubleshooting can span multiple systems and ownership domains such as app teams need to validate if right SDK's are being used for OTEL metrics, platform team need to validate the network connectivity between source and collector along with validating source signal and telemetry pipeline configuration on the collector.
  - Requires enabling "debug" mode on both Source and Collector to analyze telemetry signal transmission and pipeline processing. 
- **Dependencies/Support**
  - App teams
  - AWS for Cloudwatch

### Comparision table

| Category | ADOT Collector | Dynatrace OneAgent + SaaS|
| :--- | :--- | :--- |
| Deployment | New OTEL Agent  | Present on all nodes as standard   |
| Telemetry Signals  | Metrics | Metrics, Logs & Traces |
| Signal Context  | App/Business | App, Services, Infra |
| Platform Dependency | AWS | Platform and Cloud Agnostic |
| Operational Ownership| TBD | Shared Responsibility (KPaaS + SAE) |
| Path to CloudWatch | Direct (ADOT >> Cloudwatch) | Indirect  (Oneagent >> Dynatrace SaaS >> Cloudwatch) |
| Latency to CloudWatch | Expected to be lower due to direct export | May be higher due to extra processing hop |
| Resilient Path | EKS-Cloudwatch (Dataplane-to-Dataplane) | External (DT SaaS to Cloudwatch) |
| Custom Config | None | Required (Workflow: DT SaaS to Cloudwath) |
| Standards Alignment | New Tooling | Enterprise APM Solution |
| Troubleshooting | Higher -- New Tool and Pipeline Complexity | Low -- Team is well faimiliar with Oneagent |
| Cost Considerations | Cloudwatch Usage + OPS overhead | Covered by SAE/DT Licensing|






