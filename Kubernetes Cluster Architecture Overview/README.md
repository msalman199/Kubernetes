<div align="center">

# ☸️ Kubernetes Cluster Architecture Overview

### Hands-on lab: build a single-node Kubernetes cluster from scratch and dissect every control-plane and worker-node component

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![containerd](https://img.shields.io/badge/containerd-575757?style=for-the-badge&logo=containerd&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![systemd](https://img.shields.io/badge/systemd-black?style=for-the-badge&logo=linux&logoColor=white)
![Flannel](https://img.shields.io/badge/Flannel-CNI-4A90D9?style=for-the-badge)
![kubeadm](https://img.shields.io/badge/kubeadm-cluster%20bootstrap-326CE5?style=for-the-badge)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment Setup](#️-lab-environment-setup)
- [🧩 Task 1: Install and Configure Kubernetes Components](#-task-1-install-and-configure-kubernetes-components)
- [🚀 Task 2: Initialize Kubernetes Cluster and Identify Components](#-task-2-initialize-kubernetes-cluster-and-identify-components)
- [🔍 Task 3: Examine Kubernetes Control Plane Components](#-task-3-examine-kubernetes-control-plane-components)
- [🛠️ Task 4: Examine Worker Node Components](#️-task-4-examine-worker-node-components)
- [⚙️ Task 5: Managing Kubernetes Services with systemctl](#️-task-5-managing-kubernetes-services-with-systemctl)
- [🔗 Task 6: Analyze Component Communication and Dependencies](#-task-6-analyze-component-communication-and-dependencies)
- [🧯 Task 7: Troubleshooting Common Issues](#-task-7-troubleshooting-common-issues)
- [📄 Task 8: Create Architecture Documentation](#-task-8-create-architecture-documentation)
- [🩹 Troubleshooting Tips](#-troubleshooting-tips)
- [🧹 Lab Cleanup](#-lab-cleanup)
- [📊 Key Concepts](#-key-concepts)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Understand the core components of Kubernetes control plane architecture |
| 2 | Identify and examine worker node components in a Kubernetes cluster |
| 3 | Navigate and inspect key Kubernetes services including `kube-apiserver`, `kubelet`, and `etcd` |
| 4 | Use `systemctl` commands to manage Kubernetes services |
| 5 | Analyze the communication flow between different Kubernetes components |
| 6 | Troubleshoot basic Kubernetes service issues using system logs |

---

## 📋 Prerequisites

| Skill Area | You Should Be Comfortable With |
|---|---|
| 🐧 Linux CLI | Basic command line operations |
| ⚙️ System Services | systemd services and process management |
| 📦 Containers | Core containerization concepts |
| 📝 YAML | Reading and editing YAML file structure |
| 🌐 Networking | Ports, IP addresses, and basic protocols |

---

## 🖥️ Lab Environment Setup

> **☁️ Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux environment. The provided machine is **bare metal with no pre-installed tools** — you will install every required component during the exercises below.

---

## 🧩 Task 1: Install and Configure Kubernetes Components

### 🧱 Subtask 1.1: Prepare the System Environment

Update the system and install the dependencies Kubernetes needs before anything else.

```bash
# 🔄 Refresh package lists and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# 📥 Install required dependencies
sudo apt install -y apt-transport-https ca-certificates curl gpg

# 🚫 Disable swap (Kubernetes will not schedule pods with swap enabled)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

```bash
# TODO: Confirm swap is fully off before moving on
free -h
```

### 🐳 Subtask 1.2: Install Container Runtime (containerd)

Kubernetes needs a container runtime to actually run pods — we'll use `containerd`.

```bash
# 📥 Install containerd
sudo apt install -y containerd

# 📁 Create the containerd configuration directory
sudo mkdir -p /etc/containerd

# 🧾 Generate the default containerd configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# 🔧 Enable SystemdCgroup so containerd and kubelet share the same cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# ♻️ Restart and enable containerd
sudo systemctl restart containerd
sudo systemctl enable containerd

# ✅ Verify containerd is running
sudo systemctl status containerd
```

### ☸️ Subtask 1.3: Install Kubernetes Components

Install the three core Kubernetes CLI/agent components: `kubeadm`, `kubelet`, and `kubectl`.

```bash
# 🔑 Add the Kubernetes GPG signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# 📚 Add the Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 🔄 Refresh the package index
sudo apt update

# 📥 Install kubelet, kubeadm, and kubectl
sudo apt install -y kubelet kubeadm kubectl

# 🔒 Pin these packages so they don't auto-update mid-cluster
sudo apt-mark hold kubelet kubeadm kubectl

# ▶️ Enable the kubelet service
sudo systemctl enable kubelet
```

```bash
# TODO: Pin a different Kubernetes minor version by editing the repo URL above
# e.g. swap v1.28 for the version your organization standardizes on
```

---

## 🚀 Task 2: Initialize Kubernetes Cluster and Identify Components

### 🏁 Subtask 2.1: Initialize the Control Plane

```bash
# ☸️ Bootstrap the control plane with a pod network CIDR
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 👤 Configure kubectl for your regular (non-root) user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ✅ Confirm the cluster is up
kubectl cluster-info
```

### 🌐 Subtask 2.2: Install Pod Network (Flannel)

```bash
# 🕸️ Apply the Flannel CNI plugin so pods can talk to each other
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 🪓 Remove the control-plane taint so pods can also schedule here (single-node lab)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# 👀 Watch pods come online across all namespaces
kubectl get pods --all-namespaces -w
```

```bash
# TODO: Swap Flannel for a different CNI (Calico, Cilium, Weave) to compare behavior
```

---

## 🔍 Task 3: Examine Kubernetes Control Plane Components

### 🧠 Subtask 3.1: Identify and Inspect kube-apiserver

The `kube-apiserver` is the front door of the cluster — every `kubectl` command talks to it.

```bash
# 🔎 Confirm the API server static pod is running
kubectl get pods -n kube-system | grep apiserver

# 📋 Inspect its configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')

# 📜 View its logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}')

# 🧬 Check the underlying host process
ps aux | grep kube-apiserver

# 🔌 Confirm it's listening on port 6443
sudo netstat -tlnp | grep 6443
```

### 🗄️ Subtask 3.2: Examine etcd Component

`etcd` is the distributed key-value store holding all cluster state.

```bash
# 🔎 Confirm the etcd pod is running
kubectl get pods -n kube-system | grep etcd

# 📋 Inspect its configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}')

# 📜 View its logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}')

# 🧬 Check the underlying host process
ps aux | grep etcd

# 🔌 Confirm it's listening on port 2379
sudo netstat -tlnp | grep 2379
```

### 🕹️ Subtask 3.3: Examine kube-controller-manager

The `kube-controller-manager` runs the reconciliation loops that keep the cluster in its desired state.

```bash
# 🔎 Confirm the controller manager pod is running
kubectl get pods -n kube-system | grep controller-manager

# 📋 Inspect its configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep controller-manager | awk '{print $1}')

# 📜 View its logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep controller-manager | awk '{print $1}')

# 🧬 Check the underlying host process
ps aux | grep kube-controller-manager
```

### 🧮 Subtask 3.4: Examine kube-scheduler

The `kube-scheduler` decides which node each new pod lands on.

```bash
# 🔎 Confirm the scheduler pod is running
kubectl get pods -n kube-system | grep scheduler

# 📋 Inspect its configuration
kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}')

# 📜 View its logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep scheduler | awk '{print $1}')

# 🧬 Check the underlying host process
ps aux | grep kube-scheduler
```

---

## 🛠️ Task 4: Examine Worker Node Components

### 🤖 Subtask 4.1: Inspect kubelet Service

The `kubelet` is the node agent that keeps pods running and reports back to the control plane.

```bash
# ✅ Check kubelet's systemd status
sudo systemctl status kubelet

# 📝 View its live configuration
sudo cat /var/lib/kubelet/config.yaml

# 📜 Tail its logs in real time
sudo journalctl -u kubelet -f --no-pager

# 🧬 Check the underlying host process
ps aux | grep kubelet

# 🔌 Confirm it's listening on port 10250
sudo netstat -tlnp | grep 10250
```

### 🔀 Subtask 4.2: Examine kube-proxy

`kube-proxy` maintains the network rules that let Services route traffic to pods.

```bash
# 🔎 Confirm kube-proxy pods are running (one per node, as a DaemonSet)
kubectl get pods -n kube-system | grep kube-proxy

# 📋 Inspect the DaemonSet configuration
kubectl describe daemonset -n kube-system kube-proxy

# 📜 View its logs
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep kube-proxy | awk '{print $1}')

# 🧱 Inspect the iptables NAT rules it manages
sudo iptables -t nat -L | head -20
```

### 📦 Subtask 4.3: Examine Container Runtime

```bash
# ✅ Check containerd's systemd status
sudo systemctl status containerd

# 📃 List running containers
sudo ctr containers list

# 🔧 Confirm SystemdCgroup is enabled
sudo cat /etc/containerd/config.toml | grep -A 5 -B 5 SystemdCgroup

# 📜 Review recent containerd logs
sudo journalctl -u containerd --no-pager | tail -20
```

```bash
# TODO: Compare this output against a CRI-O or Docker Engine runtime if available
```

---

## ⚙️ Task 5: Managing Kubernetes Services with systemctl

### ⏯️ Subtask 5.1: Practice Starting and Stopping kubelet Service

```bash
# ⏹️ Stop kubelet
sudo systemctl stop kubelet

# 🔴 Confirm it's now inactive
sudo systemctl status kubelet

# 👀 Watch how the node status reacts
kubectl get nodes

# ▶️ Start kubelet back up
sudo systemctl start kubelet

# 🟢 Confirm it's running again
sudo systemctl status kubelet

# ✅ Confirm the node recovers to Ready
kubectl get nodes
```

### 📦 Subtask 5.2: Practice Managing containerd Service

```bash
# ⏹️ Stop containerd
sudo systemctl stop containerd

# 🔴 Confirm it's inactive
sudo systemctl status containerd

# ❌ Container commands should now fail
sudo ctr containers list

# ▶️ Start containerd back up
sudo systemctl start containerd

# 🟢 Confirm it's running again
sudo systemctl status containerd

# ✅ Confirm containers are reachable again
sudo ctr containers list
```

### 🏆 Subtask 5.3: Service Management Best Practices

```bash
# 🔁 Make sure services start on boot
sudo systemctl enable kubelet
sudo systemctl enable containerd

# ✅ Confirm they're enabled
sudo systemctl is-enabled kubelet
sudo systemctl is-enabled containerd

# ♻️ Restart in one shot (stop + start)
sudo systemctl restart kubelet
sudo systemctl restart containerd

# 🔃 Reload config without a full restart, where supported
sudo systemctl reload-or-restart kubelet
```

---

## 🔗 Task 6: Analyze Component Communication and Dependencies

### 🧵 Subtask 6.1: Examine Component Interactions

```bash
# 🚀 Create a test deployment to trigger the full component chain
kubectl create deployment test-nginx --image=nginx:latest

# 👀 Watch pods get created in the background
kubectl get pods -w &

# 📈 Scale up to see the scheduler place new pods
kubectl scale deployment test-nginx --replicas=3

# 🗓️ Review the event timeline showing each component's involvement
kubectl get events --sort-by=.metadata.creationTimestamp

# 🛑 Stop the background watch
kill %1
```

### 💓 Subtask 6.2: Verify Component Health

```bash
# 🩺 Check every system pod's status
kubectl get pods -n kube-system

# 🗃️ Dump full cluster diagnostic info
kubectl cluster-info dump > cluster-info.txt

# 📊 Check control-plane component status
kubectl get componentstatuses

# 🖥️ Review detailed node readiness
kubectl describe nodes
```

```bash
# TODO: Add your own kubectl get events filter for a namespace you care about
```

---

## 🧯 Task 7: Troubleshooting Common Issues

### 🩺 Subtask 7.1: Diagnose Service Issues

```bash
# 🧪 Build a quick health-check script for all core services
cat << 'EOF' > check_k8s_services.sh
#!/bin/bash

echo "=== Checking Kubernetes Services ==="
echo "1. Checking kubelet service:"
sudo systemctl is-active kubelet

echo "2. Checking containerd service:"
sudo systemctl is-active containerd

echo "3. Checking system pods:"
kubectl get pods -n kube-system --no-headers | awk '{print $1 " - " $3}'

echo "4. Checking node status:"
kubectl get nodes --no-headers | awk '{print $1 " - " $2}'

echo "5. Checking cluster endpoints:"
kubectl cluster-info | grep -E "(Kubernetes|CoreDNS)"
EOF

# 🔓 Make it executable and run it
chmod +x check_k8s_services.sh
./check_k8s_services.sh
```

### 📜 Subtask 7.2: Log Analysis

```bash
# 🧪 Build a log-analysis script targeting recent errors
cat << 'EOF' > analyze_k8s_logs.sh
#!/bin/bash

echo "=== Kubernetes Component Logs Analysis ==="

echo "1. Recent kubelet errors:"
sudo journalctl -u kubelet --since "10 minutes ago" | grep -i error | tail -5

echo "2. Recent containerd errors:"
sudo journalctl -u containerd --since "10 minutes ago" | grep -i error | tail -5

echo "3. API server pod logs (last 10 lines):"
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep apiserver | awk '{print $1}') --tail=10

echo "4. etcd pod logs (last 10 lines):"
kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep etcd | awk '{print $1}') --tail=10
EOF

# 🔓 Make it executable and run it
chmod +x analyze_k8s_logs.sh
./analyze_k8s_logs.sh
```

```bash
# TODO: Extend analyze_k8s_logs.sh to also scan scheduler and controller-manager logs
```

---

## 📄 Task 8: Create Architecture Documentation

### 📝 Subtask 8.1: Document Your Cluster Architecture

```bash
# 🗂️ Generate a full architecture report covering every component
cat << 'EOF' > cluster_architecture_report.sh
#!/bin/bash

echo "=== Kubernetes Cluster Architecture Report ==="
echo "Generated on: $(date)"
echo ""

echo "=== CONTROL PLANE COMPONENTS ==="
echo "1. API Server:"
kubectl get pods -n kube-system | grep apiserver
echo ""

echo "2. etcd:"
kubectl get pods -n kube-system | grep etcd
echo ""

echo "3. Controller Manager:"
kubectl get pods -n kube-system | grep controller-manager
echo ""

echo "4. Scheduler:"
kubectl get pods -n kube-system | grep scheduler
echo ""

echo "=== WORKER NODE COMPONENTS ==="
echo "1. kubelet status:"
sudo systemctl is-active kubelet
echo ""

echo "2. kube-proxy:"
kubectl get pods -n kube-system | grep kube-proxy
echo ""

echo "3. Container Runtime (containerd):"
sudo systemctl is-active containerd
echo ""

echo "=== CLUSTER INFORMATION ==="
echo "1. Cluster Info:"
kubectl cluster-info
echo ""

echo "2. Node Status:"
kubectl get nodes -o wide
echo ""

echo "3. System Pods:"
kubectl get pods -n kube-system
echo ""

echo "=== NETWORK CONFIGURATION ==="
echo "1. Service CIDR and Pod CIDR:"
kubectl cluster-info dump | grep -E "(service-cluster-ip-range|cluster-cidr)" | head -2
echo ""

echo "2. Active Network Interfaces:"
ip addr show | grep -E "(inet|UP)" | grep -v "127.0.0.1"
EOF

# 🔓 Make it executable and run it, saving output to a report file
chmod +x cluster_architecture_report.sh
./cluster_architecture_report.sh > my_cluster_report.txt

# 📖 Display the finished report
cat my_cluster_report.txt
```

```bash
# TODO: Pipe my_cluster_report.txt into your team's documentation wiki or Git repo
```

---

## 🩹 Troubleshooting Tips

<details>
<summary>🔧 Issue 1: kubelet fails to start</summary>

```bash
# 🔎 Check kubelet logs for the specific failure
sudo journalctl -u kubelet --no-pager | tail -20

# 🚫 Verify swap is actually disabled
free -h

# 🐳 Confirm containerd is running (kubelet depends on it)
sudo systemctl status containerd
```

</details>

<details>
<summary>🔧 Issue 2: Pods stuck in Pending state</summary>

```bash
# 📊 Check node resource availability
kubectl describe nodes

# 🗓️ Check pod-level events for the reason
kubectl describe pod <pod-name>

# 🧮 Verify the scheduler is actually running
kubectl get pods -n kube-system | grep scheduler
```

</details>

<details>
<summary>🔧 Issue 3: API server not responding</summary>

```bash
# 🔎 Confirm the API server pod is running
kubectl get pods -n kube-system | grep apiserver

# 🔌 Verify the API server port is listening
sudo netstat -tlnp | grep 6443

# 🗄️ Check etcd connectivity — the API server depends on it
kubectl get pods -n kube-system | grep etcd
```

</details>

---

## 🧹 Lab Cleanup

```bash
# 🗑️ Remove the test deployment
kubectl delete deployment test-nginx

# 🧻 Clean up generated report and script files
rm -f cluster-info.txt my_cluster_report.txt
rm -f check_k8s_services.sh analyze_k8s_logs.sh cluster_architecture_report.sh

# ♻️ Optional: reset the cluster entirely if you need a clean slate for the next lab
# sudo kubeadm reset --force
```

---

## 📊 Key Concepts

| Component | Layer | Role |
|---|---|---|
| 🧠 `kube-apiserver` | Control Plane | Front door for all cluster operations; every `kubectl` call goes through it |
| 🗄️ `etcd` | Control Plane | Distributed key-value store holding all cluster state |
| 🕹️ `kube-controller-manager` | Control Plane | Runs reconciliation loops that keep actual state matching desired state |
| 🧮 `kube-scheduler` | Control Plane | Assigns new pods to nodes based on resources and constraints |
| 🤖 `kubelet` | Worker Node | Node agent that starts/stops containers and reports node health |
| 🔀 `kube-proxy` | Worker Node | Manages iptables rules so Services can route traffic to pods |
| 🐳 `containerd` | Worker Node | Container runtime that actually pulls images and runs containers |
| 🌐 Flannel (CNI) | Networking | Provides the pod network so pods across the cluster can reach each other |

---

## ✅ Conclusion

### 🏆 Key Accomplishments

- ✅ Installed and configured a complete Kubernetes cluster on a single Linux machine
- ✅ Identified and examined all major components — `kube-apiserver`, `etcd`, `kube-controller-manager`, `kube-scheduler`, `kubelet`, and `kube-proxy`
- ✅ Practiced `systemctl` service management: starting, stopping, and monitoring Kubernetes services
- ✅ Analyzed component interactions and traced how a pod request flows through the cluster
- ✅ Built troubleshooting scripts for diagnosing common Kubernetes issues
- ✅ Produced a full architecture report documenting the cluster end-to-end

### 🌍 Real-World Applications

Understanding Kubernetes architecture is foundational for anyone working with container orchestration. The component-level knowledge from this lab directly supports troubleshooting production incidents, tuning cluster performance, and making sound design decisions when running Kubernetes at scale. The `systemctl` and log-analysis skills practiced here are exactly what's needed day-to-day to keep a real cluster healthy and reliable.

---

<div align="center">

**🎓 Al Nafi — Cloud & Cybersecurity Training Labs**

</div>
