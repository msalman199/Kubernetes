# ☸️ Introduction to Kubernetes

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-Introduction-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white">
  <img src="https://img.shields.io/badge/Minikube-Local%20Cluster-94399E?style=for-the-badge&logo=kubernetes&logoColor=white">
  <img src="https://img.shields.io/badge/Docker-Container%20Runtime-2496ED?style=for-the-badge&logo=docker&logoColor=white">
  <img src="https://img.shields.io/badge/Linux-Ubuntu-FCC624?style=for-the-badge&logo=linux&logoColor=black">
  <img src="https://img.shields.io/badge/kubectl-CLI-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white">
</p>

<p align="center">
  🚀 <b>Hands-On Kubernetes Fundamentals Lab</b> 🚀
</p>

---

## 📖 Overview

This lab provides a practical introduction to **Kubernetes**, the leading container orchestration platform used to deploy, manage, scale, and troubleshoot containerized applications.

The lab starts with the fundamental Kubernetes architecture and progresses through:

* ☸️ Kubernetes architecture
* 🧩 Control plane and node components
* 🐳 Container runtime
* 🏗️ Minikube cluster installation
* ⚙️ `kubectl` configuration
* 🖥️ Node management
* 📦 Pod management
* 🌐 Pod networking
* 🗂️ Namespace operations
* 🔍 Cluster inspection
* 🛠️ Kubernetes troubleshooting

By completing this lab, learners build the foundation required for more advanced Kubernetes topics such as **Deployments, Services, Ingress, Storage, ConfigMaps, Secrets, RBAC, StatefulSets, and Kubernetes administration**.

---

# 🎯 Lab Objectives

By the end of this lab, you will be able to:

* ☸️ Understand fundamental Kubernetes architecture
* 🧠 Identify Kubernetes control-plane components
* 🖥️ Understand worker-node components
* 🐳 Install Docker as the Minikube container runtime
* 🚀 Install and configure Minikube
* ⚙️ Install and configure `kubectl`
* 🔗 Connect `kubectl` to a Kubernetes cluster
* 🔍 Explore Kubernetes nodes and Pods
* 📦 Create and manage Pods
* 📜 Inspect Pod logs
* 🐚 Execute commands inside containers
* 🌐 Port-forward applications
* 🗂️ Work with Kubernetes namespaces
* 🛠️ Troubleshoot common Kubernetes issues

---

# 🧰 Technologies Used

| Technology    | Purpose                           |
| ------------- | --------------------------------- |
| ☸️ Kubernetes | Container orchestration platform  |
| 🚀 Minikube   | Local Kubernetes cluster          |
| 🐳 Docker     | Container runtime                 |
| ⚙️ kubectl    | Kubernetes command-line interface |
| 🐧 Linux      | Lab operating system              |
| 📄 YAML       | Kubernetes configuration format   |
| 🌐 Nginx      | Example containerized application |
| 🧪 BusyBox    | Verification container            |

---

# 📋 Prerequisites

Before starting this lab, you should have:

* Basic Linux command-line knowledge
* Familiarity with Docker/container concepts
* Basic YAML knowledge
* Basic networking knowledge
* Administrative privileges on the Linux machine

---

# ☁️ Lab Environment

This lab uses a **Linux-based cloud machine provided by Al Nafi**.

The machine starts with a base Linux installation and required software is installed during the lab.

### Environment

```text
┌──────────────────────────────────────┐
│        Al Nafi Cloud Machine         │
│                                      │
│             Linux Host               │
│                 │                    │
│                 ▼                    │
│              Docker                  │
│                 │                    │
│                 ▼                    │
│             Minikube                 │
│                 │                    │
│                 ▼                    │
│        Kubernetes Cluster            │
│                 │                    │
│                 ▼                    │
│              kubectl                 │
└──────────────────────────────────────┘
```

---

# 🏗️ Task 1 — Understanding Kubernetes Architecture

## 🔹 Kubernetes Control Plane

The Kubernetes control plane manages the overall state of the cluster.

### API Server

The **Kubernetes API Server** is the primary interface between users, tools, and the Kubernetes cluster.

```text
kubectl
   │
   ▼
API Server
   │
   ├──► Scheduler
   ├──► Controller Manager
   └──► etcd
```

### etcd

`etcd` is the distributed key-value store used by Kubernetes to store cluster state and configuration.

### Scheduler

The scheduler determines which node should run newly created Pods.

### Controller Manager

The Controller Manager runs Kubernetes controllers that continuously compare the desired state with the current state.

---

# 🖥️ Kubernetes Node Components

Worker nodes run application workloads.

Important components include:

### kubelet

The kubelet communicates with the Kubernetes API Server and ensures containers specified by Pods are running.

### kube-proxy

`kube-proxy` provides networking functionality for Kubernetes Services.

### Container Runtime

The container runtime is responsible for running containers.

In this lab, **Docker** is used with Minikube.

---

# 📦 Kubernetes Objects

The lab introduces several important Kubernetes objects.

| Object     | Purpose                                |
| ---------- | -------------------------------------- |
| Pod        | Smallest deployable Kubernetes unit    |
| Node       | Machine that runs workloads            |
| Service    | Provides stable network access to Pods |
| Deployment | Manages replicated application Pods    |
| Namespace  | Provides logical resource isolation    |

---

# 🚀 Task 2 — Install Kubernetes Using Minikube

## 🔹 Step 2.1 — Update the System

```bash
sudo apt update && sudo apt upgrade -y
```

Install required packages:

```bash
sudo apt install -y curl wget apt-transport-https
```

---

## 🐳 Install Docker

```bash
sudo apt install -y docker.io
```

Start Docker:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

Add the current user to the Docker group:

```bash
sudo usermod -aG docker $USER
```

Apply the group membership:

```bash
newgrp docker
```

Verify Docker:

```bash
docker --version
```

---

# 🚀 Step 2.2 — Install Minikube

Download Minikube:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
```

Install it:

```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Verify:

```bash
minikube version
```

Expected result:

```text
minikube version: vX.X.X
```

---

# ☸️ Step 2.3 — Start the Kubernetes Cluster

Start Minikube using Docker:

```bash
minikube start --driver=docker
```

Check the cluster status:

```bash
minikube status
```

Check the Minikube IP:

```bash
minikube ip
```

Expected status:

```text
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

---

# ⚙️ Task 3 — Configure kubectl

## 🔹 Step 3.1 — Install kubectl

Download the latest stable version:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Make it executable:

```bash
chmod +x kubectl
```

Move it into the system PATH:

```bash
sudo mv kubectl /usr/local/bin/
```

Verify:

```bash
kubectl version --client
```

---

# 🔗 Step 3.2 — Verify Cluster Connectivity

Check cluster information:

```bash
kubectl cluster-info
```

View the Kubernetes configuration:

```bash
kubectl config view
```

Check the current context:

```bash
kubectl config current-context
```

Expected context:

```text
minikube
```

---

# 🔍 Task 4 — Basic kubectl Commands

## 🖥️ Step 4.1 — Explore Cluster Nodes

List nodes:

```bash
kubectl get nodes
```

Get additional information:

```bash
kubectl get nodes -o wide
```

Describe the Minikube node:

```bash
kubectl describe node minikube
```

Example:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   5m    v1.28.3
```

A `Ready` status confirms that the node is available for workloads.

---

# 📦 Step 4.2 — Explore Pods

List Pods in the default namespace:

```bash
kubectl get pods
```

List Pods across all namespaces:

```bash
kubectl get pods --all-namespaces
```

Display additional information:

```bash
kubectl get pods -o wide --all-namespaces
```

---

# ⚙️ Step 4.3 — Explore System Components

List resources in the `kube-system` namespace:

```bash
kubectl get all -n kube-system
```

List system Pods:

```bash
kubectl get pods -n kube-system
```

Describe CoreDNS:

```bash
kubectl describe pod -n kube-system -l k8s-app=kube-dns
```

Typical Kubernetes system components include:

```text
kube-system
│
├── CoreDNS
├── kube-proxy
├── kube-apiserver
├── kube-controller-manager
├── kube-scheduler
└── etcd
```

---

# 🐳 Step 4.4 — Create Your First Pod

Create an Nginx Pod:

```bash
kubectl run my-first-pod \
  --image=nginx \
  --port=80
```

Check the Pod:

```bash
kubectl get pods
```

Get detailed information:

```bash
kubectl describe pod my-first-pod
```

View logs:

```bash
kubectl logs my-first-pod
```

---

# 🐚 Step 4.5 — Interact With the Pod

Open a shell inside the container:

```bash
kubectl exec -it my-first-pod -- /bin/bash
```

Inside the container:

```bash
curl localhost
```

Exit:

```bash
exit
```

---

# 🌐 Port Forwarding

Forward local port `8080` to the Pod's port `80`:

```bash
kubectl port-forward my-first-pod 8080:80 &
```

Test Nginx:

```bash
curl http://localhost:8080
```

Stop port forwarding:

```bash
pkill -f "kubectl port-forward"
```

---

# 🧹 Step 4.6 — Clean Up the Pod

Delete the Pod:

```bash
kubectl delete pod my-first-pod
```

Verify:

```bash
kubectl get pods
```

---

# 🗂️ Task 5 — Kubernetes Namespaces

List namespaces:

```bash
kubectl get namespaces
```

Create a namespace:

```bash
kubectl create namespace my-lab-namespace
```

List Pods in that namespace:

```bash
kubectl get pods -n my-lab-namespace
```

Set it as the default namespace for the current context:

```bash
kubectl config set-context \
  --current \
  --namespace=my-lab-namespace
```

---

# 🔎 Additional kubectl Commands

## API Resources

```bash
kubectl api-resources
```

## Cluster Events

```bash
kubectl get events
```

## Kubernetes Version

```bash
kubectl version
```

## Cluster Information

```bash
kubectl cluster-info
```

---

# 🛠️ Troubleshooting

## ❌ Issue 1 — Minikube Fails to Start

Check Docker:

```bash
sudo systemctl status docker
```

Restart Docker:

```bash
sudo systemctl restart docker
```

Delete the existing Minikube cluster:

```bash
minikube delete
```

Start again:

```bash
minikube start --driver=docker
```

---

## ❌ Issue 2 — kubectl Connection Refused

Check Minikube:

```bash
minikube status
```

Update the context:

```bash
minikube update-context
```

Restart Minikube:

```bash
minikube stop
minikube start
```

---

## ❌ Issue 3 — Permission Denied

Check Docker group membership:

```bash
groups $USER
```

Add the user:

```bash
sudo usermod -aG docker $USER
```

Apply the changes:

```bash
newgrp docker
```

If necessary, log out and log back in.

---

# ✅ Verification

Run the following commands to verify the lab.

### 1. Check Minikube

```bash
minikube status
```

### 2. Check Kubernetes Connectivity

```bash
kubectl cluster-info
```

### 3. Check Nodes

```bash
kubectl get nodes
```

### 4. Check System Pods

```bash
kubectl get pods -n kube-system
```

### 5. Create a Verification Pod

```bash
kubectl run verification-pod \
  --image=busybox \
  --command -- sleep 3600
```

Verify:

```bash
kubectl get pods
```

Delete it:

```bash
kubectl delete pod verification-pod
```

---

# 🧠 Kubernetes Architecture Summary

```text
                    ☸️ Kubernetes Cluster
                            │
              ┌─────────────┴─────────────┐
              │                           │
       🎛️ Control Plane              🖥️ Worker Node
              │                           │
      ┌───────┼────────┐          ┌───────┼────────┐
      │       │        │          │       │        │
   API      etcd   Scheduler   kubelet kube-proxy Runtime
   Server
      │
      ▼
   Kubernetes
     State
```

---

# 🎓 Lab Summary

In this lab, you successfully:

* ☸️ Learned Kubernetes architecture
* 🧩 Explored control-plane components
* 🖥️ Learned about Kubernetes nodes
* 🐳 Installed Docker
* 🚀 Installed Minikube
* ⚙️ Installed `kubectl`
* 🔗 Connected `kubectl` to a Kubernetes cluster
* 🔍 Inspected cluster nodes
* 📦 Created and managed Pods
* 📜 Viewed Pod logs
* 🐚 Executed commands inside containers
* 🌐 Used port forwarding
* 🗂️ Created and managed namespaces
* 🛠️ Practiced basic troubleshooting

---

# 🔑 Key Takeaways

### ☸️ Kubernetes Is Declarative

Kubernetes allows you to describe the desired state of your applications and continuously works to maintain that state.

### 🚀 Minikube Is Ideal for Learning

Minikube provides a lightweight local Kubernetes environment for experimenting with Kubernetes concepts without requiring a production cluster.

### ⚙️ kubectl Is the Primary CLI

The `kubectl` command is one of the most important tools for interacting with Kubernetes clusters.

### 📦 Pods Are Fundamental

Pods represent the smallest deployable units in Kubernetes and contain one or more containers.

### 🌐 Kubernetes Is More Than Containers

Kubernetes provides:

```text
Containers
   +
Networking
   +
Storage
   +
Scheduling
   +
Scaling
   +
Self-Healing
   +
Security
   =
☸️ Kubernetes Platform
```

---

# 🚀 Next Steps

After completing this introductory lab, continue with:

1. 📦 Kubernetes Deployments
2. 🌐 Kubernetes Services
3. 🔗 Advanced Kubernetes Networking
4. 💾 Persistent Volumes and Storage
5. 🗄️ ConfigMaps and Secrets
6. 📈 Application Scaling
7. 🔄 Rolling Updates and Rollbacks
8. 🧩 StatefulSets
9. 🌍 Ingress Controllers
10. 🔐 Kubernetes RBAC
11. 🛡️ Kubernetes Security
12. 📊 Monitoring and Observability
13. ⚙️ Helm
14. 🚀 GitOps with Argo CD

---

# 🏆 Skills Developed

<p align="center">

<img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white">
<img src="https://img.shields.io/badge/Minikube-94399E?style=for-the-badge&logo=kubernetes&logoColor=white">
<img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white">
<img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black">
<img src="https://img.shields.io/badge/kubectl-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white">

</p>

---

# 🌟 Conclusion

This lab establishes a strong foundation in **Kubernetes cluster architecture, Minikube, kubectl, Pods, Nodes, Namespaces, and basic cluster administration**.

The practical skills developed here are directly applicable to larger Kubernetes environments used for **cloud computing, DevOps, microservices, CI/CD, container orchestration, and cloud-native application deployment**.

> ☸️ **Start Small → Understand the Cluster → Deploy Workloads → Master Kubernetes**

---

<p align="center">
  <b>🚀 Learn • Practice • Deploy • Troubleshoot • Master Kubernetes 🚀</b>
</p>

<p align="center">
  ☸️ <b>Kubernetes Fundamentals</b> | 🐳 <b>Docker</b> | 🚀 <b>Minikube</b> | ⚙️ <b>kubectl</b>
</p>
