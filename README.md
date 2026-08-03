
# ☸️ Kubernetes — Cloud-Native Container Orchestration

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-Container%20Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes">
  <img src="https://img.shields.io/badge/Docker-Containers-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Linux-Administration-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/DevOps-Cloud%20Native-0A66C2?style=for-the-badge&logo=devops&logoColor=white" alt="DevOps">
  <img src="https://img.shields.io/badge/YAML-Configuration-CB171E?style=for-the-badge&logo=yaml&logoColor=white" alt="YAML">
</p>

<p align="center">
  <b>🚀 A Practical Kubernetes Learning, Deployment & Automation Repository</b>
</p>

---

## 📌 Repository Purpose

The purpose of this repository is to provide a **structured, practical, and hands-on collection of Kubernetes labs, configurations, exercises, and deployment examples**.

The repository is designed to build strong practical knowledge of **Kubernetes container orchestration** and demonstrate how containerized applications can be deployed, managed, scaled, secured, monitored, and exposed in cloud-native environments.

Rather than focusing only on Kubernetes theory, this repository emphasizes **real-world command-line operations, YAML manifests, troubleshooting, application deployment, networking, storage, security, and cluster administration**.

```text
                    ☸️ Kubernetes
                         │
        ┌────────────────┼────────────────┐
        │                │                │
     🚀 Deploy         🌐 Network       💾 Storage
        │                │                │
        ├───────────────┼────────────────┤
        │                │                │
     📈 Scale          🔐 Secure        📊 Monitor
        │                │                │
        └────────────────┼────────────────┘
                         │
                    ☁️ Cloud Native
```

---

# 🎯 Main Objectives

This repository aims to develop practical skills in:

* ☸️ Kubernetes architecture and core concepts
* 🚀 Application deployment
* 📦 Pod and container management
* 🔄 Deployments and ReplicaSets
* 🌐 Kubernetes networking
* 🔗 Services and service discovery
* 💾 Persistent storage
* 🗄️ ConfigMaps and Secrets
* 📈 Application scaling
* 🔄 Rolling updates and rollbacks
* 🧩 Stateful applications
* 🌐 Ingress and traffic management
* 🔐 Kubernetes security and RBAC
* 🏗️ Cluster administration
* 🛠️ Troubleshooting Kubernetes workloads
* 📊 Monitoring and observability
* ⚙️ Infrastructure automation
* 🚀 Cloud-native DevOps practices

---

# 🧰 Technologies Covered

| Technology            | Purpose                                |
| --------------------- | -------------------------------------- |
| ☸️ Kubernetes         | Container orchestration                |
| 🐳 Docker             | Container runtime and image management |
| 🐧 Linux              | Kubernetes administration environment  |
| 📄 YAML               | Kubernetes resource definitions        |
| 🔧 kubectl            | Kubernetes command-line administration |
| 🌐 Ingress            | HTTP/HTTPS traffic routing             |
| 💾 Persistent Volumes | Application data persistence           |
| 🔐 RBAC               | Access control                         |
| 📊 Monitoring         | Cluster and workload observability     |

---

# 📚 Repository Learning Areas

## 1. ☸️ Kubernetes Fundamentals

The repository introduces the core building blocks of Kubernetes, including:

* Clusters
* Nodes
* Control plane
* Worker nodes
* Pods
* Containers
* Namespaces
* Labels
* Selectors
* Annotations

Example:

```bash
kubectl get nodes
kubectl get pods
kubectl get namespaces
```

---

# 2. 📦 Pod Management

Pods are the fundamental execution units in Kubernetes.

Typical activities include:

```bash
kubectl run nginx --image=nginx
kubectl get pods
kubectl describe pod nginx
kubectl logs nginx
kubectl delete pod nginx
```

The repository demonstrates how to:

* Create Pods
* Inspect Pods
* View logs
* Execute commands inside containers
* Debug failed Pods
* Delete and recreate workloads

---

# 3. 🚀 Deployments

Kubernetes Deployments provide declarative application management.

Typical workflow:

```text
Deployment
    │
    ▼
ReplicaSet
    │
    ▼
Pods
    │
    ▼
Containers
```

Example:

```bash
kubectl create deployment nginx --image=nginx
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

Deployment concepts include:

* Desired state
* Replica management
* Rolling updates
* Rollbacks
* Scaling
* Self-healing

---

# 4. 🌐 Kubernetes Services

Services provide stable networking access to Pods.

Common service types include:

```text
ClusterIP
NodePort
LoadBalancer
ExternalName
```

Example:

```bash
kubectl expose deployment nginx \
  --port=80 \
  --target-port=80
```

Inspect the service:

```bash
kubectl get services
kubectl describe service nginx
```

---

# 5. 🌍 Networking

The repository explores Kubernetes networking concepts such as:

* Pod-to-Pod communication
* Service discovery
* ClusterIP
* NodePort
* DNS
* Network isolation
* Ingress
* Internal application communication

A simplified networking model:

```text
Client
  │
  ▼
Ingress
  │
  ▼
Service
  │
  ├──► Pod
  ├──► Pod
  └──► Pod
```

---

# 6. 💾 Kubernetes Storage

Stateful workloads require persistent storage.

The repository covers concepts such as:

* PersistentVolume
* PersistentVolumeClaim
* StorageClass
* Volume mounting
* Persistent application data

Architecture:

```text
Application
     │
     ▼
PersistentVolumeClaim
     │
     ▼
PersistentVolume
     │
     ▼
Storage Backend
```

---

# 7. 🗄️ ConfigMaps and Secrets

Kubernetes configuration can be separated from application images.

### ConfigMap

Used for non-sensitive configuration:

```bash
kubectl create configmap app-config \
  --from-literal=ENVIRONMENT=production
```

### Secret

Used for sensitive information:

```bash
kubectl create secret generic app-secret \
  --from-literal=password=example
```

This separation supports cleaner and more secure application deployments.

---

# 8. 📈 Scaling Applications

Kubernetes can scale workloads horizontally.

Example:

```bash
kubectl scale deployment nginx --replicas=5
```

Verify:

```bash
kubectl get deployment
kubectl get pods
```

Concept:

```text
              Deployment
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
      Pod        Pod        Pod
       │          │          │
       └──────────┼──────────┘
                  ▼
              Application
```

---

# 9. 🔄 Rolling Updates & Rollbacks

Kubernetes supports controlled application updates.

Example:

```bash
kubectl set image deployment/nginx \
  nginx=nginx:latest
```

Check rollout status:

```bash
kubectl rollout status deployment/nginx
```

View history:

```bash
kubectl rollout history deployment/nginx
```

Rollback:

```bash
kubectl rollout undo deployment/nginx
```

---

# 10. 🧩 Stateful Applications

The repository also provides practical exposure to Kubernetes StatefulSets.

StatefulSets are useful for workloads requiring:

* Stable network identities
* Persistent storage
* Ordered deployment
* Ordered termination
* Stateful application management

Typical architecture:

```text
StatefulSet
    │
    ├── Pod-0 → Persistent Storage
    │
    ├── Pod-1 → Persistent Storage
    │
    └── Pod-2 → Persistent Storage
```

---

# 11. 🌐 Ingress

Ingress allows HTTP and HTTPS traffic to be routed to Kubernetes services.

Example:

```text
Internet
   │
   ▼
Ingress Controller
   │
   ├──────────────► Service A
   │                    │
   │                    ▼
   │                   Pods
   │
   └──────────────► Service B
                        │
                        ▼
                       Pods
```

This enables hostname- and path-based application routing.

---

# 12. 🔐 Kubernetes Security

Security is an important part of the repository.

Topics include:

* Kubernetes RBAC
* Roles
* ClusterRoles
* RoleBindings
* ServiceAccounts
* Secrets
* Namespace isolation
* Least-privilege access
* Security contexts

Example:

```text
User
 │
 ▼
RoleBinding
 │
 ▼
Role
 │
 ▼
Kubernetes Resources
```

The goal is to understand how Kubernetes controls **who can perform which actions against which resources**.

---

# 13. 🏗️ Namespaces

Namespaces provide logical isolation inside a Kubernetes cluster.

Example:

```bash
kubectl create namespace development
kubectl create namespace production
```

View namespaces:

```bash
kubectl get namespaces
```

Example architecture:

```text
Kubernetes Cluster
│
├── development
│   ├── Pods
│   ├── Services
│   └── Deployments
│
└── production
    ├── Pods
    ├── Services
    └── Deployments
```

---

# 14. 📊 Monitoring & Troubleshooting

The repository emphasizes practical troubleshooting using `kubectl`.

Useful commands include:

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events
kubectl top pods
kubectl top nodes
```

Troubleshooting workflow:

```text
❌ Application Problem
        │
        ▼
kubectl get
        │
        ▼
kubectl describe
        │
        ▼
kubectl logs
        │
        ▼
kubectl get events
        │
        ▼
🔧 Identify Root Cause
        │
        ▼
✅ Apply Fix
```

---

# 🛠️ Common Kubernetes Commands

### Cluster Information

```bash
kubectl cluster-info
kubectl get nodes
kubectl version
```

### Workloads

```bash
kubectl get pods
kubectl get deployments
kubectl get replicasets
kubectl get statefulsets
```

### Networking

```bash
kubectl get services
kubectl get ingress
```

### Configuration

```bash
kubectl get configmaps
kubectl get secrets
```

### Storage

```bash
kubectl get pv
kubectl get pvc
kubectl get storageclass
```

### Debugging

```bash
kubectl describe pod <pod>
kubectl logs <pod>
kubectl exec -it <pod> -- /bin/sh
```

---

# 📁 Suggested Repository Structure

```text
Kubernetes/
│
├── README.md
│
├── Kubernetes Fundamentals/
│   ├── Pods/
│   ├── Namespaces/
│   └── Labels/
│
├── Deployments/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── README.md
│
├── Networking/
│   ├── Services/
│   ├── Ingress/
│   └── NetworkPolicies/
│
├── Storage/
│   ├── PersistentVolumes/
│   ├── PersistentVolumeClaims/
│   └── StorageClasses/
│
├── Security/
│   ├── RBAC/
│   ├── Secrets/
│   └── SecurityContexts/
│
├── StatefulSets/
│
├── ConfigMaps/
│
├── Monitoring/
│
└── Troubleshooting/
```

The exact structure can be adapted as additional labs and projects are added.

---

# 🎓 Learning Outcomes

After working through this repository, you should be able to:

✅ Understand Kubernetes architecture

✅ Deploy containerized applications

✅ Create and manage Pods

✅ Build Kubernetes Deployments

✅ Expose applications using Services

✅ Configure Ingress routing

✅ Manage persistent application storage

✅ Use ConfigMaps and Secrets

✅ Scale applications

✅ Perform rolling updates and rollbacks

✅ Deploy stateful workloads

✅ Configure namespace isolation

✅ Implement Kubernetes RBAC

✅ Troubleshoot application failures

✅ Monitor cluster resources

✅ Work confidently with `kubectl`

---

# ☁️ DevOps & Cloud-Native Relevance

Kubernetes is a core technology in modern cloud-native infrastructure.

The skills developed through this repository can be applied to:

* ☁️ Cloud platforms
* 🚀 CI/CD pipelines
* 🔄 GitOps workflows
* 🐳 Containerized applications
* 🏢 Enterprise infrastructure
* 📈 Scalable web applications
* 🔐 Secure production environments
* 📊 Microservices architectures
* ⚙️ DevOps automation

The repository therefore serves as a practical foundation for progressing toward advanced technologies such as:

```text
Docker
   ↓
Kubernetes
   ↓
Helm
   ↓
CI/CD
   ↓
GitOps
   ↓
Argo CD
   ↓
Cloud-Native Platforms
```

---

# 🏆 Repository Goals

The long-term goal of this repository is to maintain a **practical Kubernetes knowledge base** containing reusable manifests, commands, troubleshooting procedures, deployment examples, and hands-on labs.

Each exercise is intended to strengthen the ability to:

> **Build → Deploy → Manage → Secure → Scale → Monitor → Troubleshoot**

containerized applications using Kubernetes.

---

# 🌟 Key Skills

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-Expertise-326CE5?style=flat-square&logo=kubernetes&logoColor=white">
  <img src="https://img.shields.io/badge/Docker-Containers-2496ED?style=flat-square&logo=docker&logoColor=white">
  <img src="https://img.shields.io/badge/Linux-Administration-FCC624?style=flat-square&logo=linux&logoColor=black">
  <img src="https://img.shields.io/badge/DevOps-Automation-0A66C2?style=flat-square">
  <img src="https://img.shields.io/badge/Cloud--Native-Architecture-326CE5?style=flat-square">
</p>

---

# 🤝 Contribution

This repository is primarily intended for **learning, practice, experimentation, and documenting Kubernetes knowledge**.

Improvements, corrections, additional examples, and better deployment practices can be added as the repository evolves.

---

# 📜 License

This repository is intended for educational and practical DevOps/Kubernetes learning purposes.

---

<p align="center">
  ☸️ <b>Kubernetes | Cloud Native | DevOps</b> ☸️
</p>

<p align="center">
  <b>🚀 Learn • Deploy • Scale • Secure • Automate 🚀</b>
</p>
