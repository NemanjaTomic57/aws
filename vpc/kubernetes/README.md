# Kubernetes VPC

This VPC is designed to run a high availability Kubernetes cluster in AWS.

Technologies include Terraform, Ansible and Python.

##  Tasks

### Done

- Provision infrastructure with Terraform
- Automate configuration with Ansible
- Join other nodes after first kubeadm init

### To Do

- Use Flannel as the CNI
- Use a Load Balancer to redirect traffic to a sample application

## Note: Error Message After Calico CNI Installation

This cluster is not functional, as there is the following error message after installing Calico CNI:

```bash
APIService: v3.projectcalico.org
================================

Name: v3.projectcalico.org
Namespace: <none>

Labels:
- app.kubernetes.io/component=APIServer.operator.tigera.io
- app.kubernetes.io/instance=default
- app.kubernetes.io/managed-by=tigera-operator
- app.kubernetes.io/name=v3.projectcalico.org
- app.kubernetes.io/part-of=Calico
- k8s-app=v3.projectcalico.org

API Version: apiregistration.k8s.io/v1
Kind: APIService

Metadata:
- Creation Timestamp: 2026-05-19T08:18:53Z
- Resource Version: 5692
- UID: d7f8d9c2-ac51-4e97-a6b8-34a746ec7c8f

Owner References:
- API Version: operator.tigera.io/v1
- Kind: APIServer
- Name: default
- UID: 906d04a8-eae5-4846-ba9a-d3e317b1ee30
- Controller: true
- Block Owner Deletion: true

Spec:
- Group: projectcalico.org
- Version: v3
- Group Priority Minimum: 1500
- Version Priority: 200

Service:
- Name: calico-api
- Namespace: calico-system
- Port: 443

Status:
Condition Type: Available
- Status: False
- Reason: FailedDiscoveryCheck
- Last Transition Time: 2026-05-19T08:18:53Z

Error Message:
failing or missing response from https://10.105.150.6:443/apis/projectcalico.org/v3:
Get "https://10.105.150.6:443/apis/projectcalico.org/v3":
net/http: request canceled while waiting for connection
(Client.Timeout exceeded while awaiting headers)

Notes:
- The APIService is currently unavailable.
- The Calico API endpoint is timing out while Kubernetes attempts discovery checks.
- This may indicate networking, service, pod, or TLS issues in the calico-system namespace.
```
