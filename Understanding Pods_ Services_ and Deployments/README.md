<div align="center">

# ☸️ Understanding Pods, Services, and Deployments

### Hands-on lab: stand up Minikube, deploy Nginx, expose it, scale it, and master the kubectl toolkit

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Minikube](https://img.shields.io/badge/Minikube-2496ED?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Difficulty](https://img.shields.io/badge/Difficulty-Beginner--Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧩 Task 1: Environment Setup and Kubernetes Installation](#-task-1-environment-setup-and-kubernetes-installation)
- [🚀 Task 2: Create a Deployment and Expose it via a Service](#-task-2-create-a-deployment-and-expose-it-via-a-service)
- [📈 Task 3: Scale the Deployment](#-task-3-scale-the-deployment)
- [🔍 Task 4: Use kubectl to Inspect Pods and Services](#-task-4-use-kubectl-to-inspect-pods-and-services)
- [🛠️ Task 5: Advanced Operations and Cleanup](#️-task-5-advanced-operations-and-cleanup)
- [🩹 Troubleshooting Tips](#-troubleshooting-tips)
- [📊 Key Concepts Summary](#-key-concepts-summary)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Install and configure a Kubernetes cluster on a single Linux machine using Minikube |
| 2 | Create and manage Kubernetes Deployments |
| 3 | Expose applications using Kubernetes Services |
| 4 | Scale deployments up and down |
| 5 | Use `kubectl` commands to inspect and manage Pods, Services, and Deployments |
| 6 | Understand the relationship between Pods, Services, and Deployments in Kubernetes |

---

## 📋 Prerequisites

| Skill Area | You Should Be Comfortable With |
|---|---|
| 🐧 Linux CLI | Basic command line operations |
| 📦 Containers | Core containerization concepts (Docker basics) |
| 📝 YAML | Reading and editing YAML file structure |
| 🌐 Networking | Ports and IP addresses |
| ✍️ Text Editors | `nano`, `vim`, or a similar editor |

---

## 🖥️ Lab Environment

> **☁️ Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install every required tool during the exercises below.

---

## 🧩 Task 1: Environment Setup and Kubernetes Installation

### 🔄 Subtask 1.1: Update System and Install Dependencies

```bash
# 🔄 Refresh package lists and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# 📥 Install required packages
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

# 🔑 Add Docker's GPG signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 📚 Add the Docker apt repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 🔄 Refresh the package index
sudo apt update

# 🐳 Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 👤 Add your user to the docker group (avoids needing sudo for every docker command)
sudo usermod -aG docker $USER

# ▶️ Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 🧰 Subtask 1.2: Install kubectl

```bash
# ⬇️ Download the latest stable kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 🔓 Make kubectl executable
chmod +x kubectl

# 📂 Move kubectl into your PATH
sudo mv kubectl /usr/local/bin/

# ✅ Verify the installation
kubectl version --client
```

### 🎡 Subtask 1.3: Install and Start Minikube

```bash
# ⬇️ Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# 📥 Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 🚀 Start the Minikube cluster on the Docker driver
minikube start --driver=docker

# ✅ Verify the cluster is running
kubectl cluster-info
kubectl get nodes
```

> **⚠️ Note:** If you hit Docker permission issues, log out and back in, or run `newgrp docker` to refresh your group membership.

```bash
# TODO: Try minikube start --driver=docker --cpus=2 --memory=4096 to tune resources
```

---

## 🚀 Task 2: Create a Deployment and Expose it via a Service

### 📝 Subtask 2.1: Create a Simple Web Application Deployment

```bash
# 📁 Create a working directory for lab files
mkdir ~/k8s-lab3
cd ~/k8s-lab3

# 🧾 Create the Deployment manifest
cat > nginx-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
EOF
```

```yaml
# TODO: Add a livenessProbe / readinessProbe block once you're comfortable with the base manifest
```

### 🚢 Subtask 2.2: Deploy the Application

```bash
# 📤 Apply the Deployment to the cluster
kubectl apply -f nginx-deployment.yaml

# ✅ Verify the Deployment was created
kubectl get deployments

# 🔎 Check pod status
kubectl get pods

# 📋 Get detailed Deployment information
kubectl describe deployment nginx-deployment
```

### 🌐 Subtask 2.3: Create a Service to Expose the Deployment

```bash
# 🧾 Create the Service manifest
cat > nginx-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
EOF
```

```bash
# 📤 Apply the Service
kubectl apply -f nginx-service.yaml

# ✅ Verify the Service was created
kubectl get services

# 📋 Get detailed Service information
kubectl describe service nginx-service
```

### 🧪 Subtask 2.4: Test the Service

```bash
# 📍 Get the Minikube node IP
minikube ip

# 🌐 Test the Service directly via curl
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30080

# 🔀 Alternative: let Minikube resolve the URL for you
minikube service nginx-service --url
```

> **✅ Expected result:** you should see the Nginx welcome page HTML content in your terminal.

---

## 📈 Task 3: Scale the Deployment

### ⬆️ Subtask 3.1: Scale Up the Deployment

```bash
# 📈 Scale the Deployment to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# ✅ Verify scaling
kubectl get pods

# 👀 Watch pods being created in real time
kubectl get pods -w
```

> **⏹️ Tip:** Press `Ctrl+C` to stop watching.

### ⬇️ Subtask 3.2: Scale Down the Deployment

```bash
# 📉 Scale the Deployment back down to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2

# ✅ Verify the scale-down
kubectl get pods

# 📋 Check Deployment status
kubectl get deployment nginx-deployment
```

### ✏️ Subtask 3.3: Update Deployment Using YAML

```bash
# ✏️ Edit the manifest directly to set replicas to 4
sed -i 's/replicas: 3/replicas: 4/' nginx-deployment.yaml

# 📤 Apply the updated manifest
kubectl apply -f nginx-deployment.yaml

# ✅ Verify the change took effect
kubectl get pods
kubectl get deployment nginx-deployment
```

```bash
# TODO: Try changing the container image tag in the YAML instead of replicas,
# then re-apply and watch kubectl rollout status in action
```

---

## 🔍 Task 4: Use kubectl to Inspect Pods and Services

### 🔬 Subtask 4.1: Detailed Pod Inspection

```bash
# 📋 List all pods with extra detail
kubectl get pods -o wide

# 🎯 Grab a specific pod name by label
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $POD_NAME

# 📜 View pod logs
kubectl logs $POD_NAME

# 📄 Get pod info as YAML
kubectl get pod $POD_NAME -o yaml

# 📄 Get pod info as JSON
kubectl get pod $POD_NAME -o json
```

### 🔗 Subtask 4.2: Service Inspection and Endpoints

```bash
# 📋 List all Services
kubectl get services

# 📋 Get detailed Service information
kubectl describe service nginx-service

# 🎯 Check the Service's live endpoints
kubectl get endpoints nginx-service

# 📄 View the Service as YAML
kubectl get service nginx-service -o yaml
```

### 🧮 Subtask 4.3: Advanced kubectl Commands

```bash
# 📦 Get every resource in the default namespace
kubectl get all

# 🏷️ Filter pods by label
kubectl get pods -l app=nginx

# 🗂️ Print pods with custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

# 📊 Check resource usage (if metrics-server is installed)
kubectl top pods 2>/dev/null || echo "Metrics server not available"

# 🗓️ Get events tied to the Deployment
kubectl get events --field-selector involvedObject.name=nginx-deployment
```

### 💻 Subtask 4.4: Interactive Pod Access

```bash
# 🖥️ Open an interactive shell inside the pod
kubectl exec -it $POD_NAME -- /bin/bash

# 🧪 Once inside, try commands like:
# nginx -v
# ps aux
# exit

# ⚡ Run a single command without a full interactive shell
kubectl exec $POD_NAME -- nginx -v

# 🔌 Port-forward from your machine to the pod
kubectl port-forward $POD_NAME 8080:80 &

# 🧪 Test the forwarded port
curl http://localhost:8080

# 🛑 Kill the port-forward process
pkill -f "kubectl port-forward"
```

```bash
# TODO: Try kubectl cp to copy a file into or out of the running pod
```

---

## 🛠️ Task 5: Advanced Operations and Cleanup

### 🔁 Subtask 5.1: Rolling Updates

```bash
# 🔄 Update the Nginx image version
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# 👀 Watch the rolling update progress
kubectl rollout status deployment/nginx-deployment

# 📜 Check rollout history
kubectl rollout history deployment/nginx-deployment

# ⏪ Roll back to the previous version if needed
kubectl rollout undo deployment/nginx-deployment
```

### 🗃️ Subtask 5.2: Create Additional Resources

```bash
# 🗃️ Create a ConfigMap
kubectl create configmap nginx-config --from-literal=server_name=my-nginx-server

# 📄 View the ConfigMap
kubectl get configmap nginx-config -o yaml

# 🧾 Create a second Deployment that consumes the ConfigMap
cat > nginx-deployment-with-config.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-v2
  labels:
    app: nginx-v2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-v2
  template:
    metadata:
      labels:
        app: nginx-v2
    spec:
      containers:
      - name: nginx
        image: nginx:1.22
        ports:
        - containerPort: 80
        env:
        - name: SERVER_NAME
          valueFrom:
            configMapKeyRef:
              name: nginx-config
              key: server_name
EOF

# 📤 Apply the new Deployment
kubectl apply -f nginx-deployment-with-config.yaml

# ✅ Verify the new Deployment
kubectl get deployments
kubectl get pods -l app=nginx-v2
```

```yaml
# TODO: Add a second key to nginx-config and reference it as another env var
```

### 🧹 Subtask 5.3: Resource Cleanup

```bash
# 🗑️ Delete both Deployments
kubectl delete deployment nginx-deployment
kubectl delete deployment nginx-deployment-v2

# 🗑️ Delete the Service
kubectl delete service nginx-service

# 🗑️ Delete the ConfigMap
kubectl delete configmap nginx-config

# ✅ Verify everything is cleaned up
kubectl get all

# ⏹️ Stop Minikube (optional)
minikube stop
```

---

## 🩹 Troubleshooting Tips

<details>
<summary>🔧 Issue 1: Pods stuck in Pending state</summary>

```bash
# 📊 Check node resource availability
kubectl describe nodes

# 🗓️ Check pod-level events for the reason
kubectl describe pod <pod-name>
```

</details>

<details>
<summary>🔧 Issue 2: Service not accessible</summary>

```bash
# 🎯 Verify the Service has live endpoints
kubectl get endpoints <service-name>

# 🔎 Check that matching pods are running and ready
kubectl get pods -l app=<app-label>

# 🏷️ Verify the Service selector matches the pod labels
kubectl get service <service-name> -o yaml
```

</details>

<details>
<summary>🔧 Issue 3: Docker permission denied</summary>

```bash
# 👤 Add your user to the docker group and refresh membership
sudo usermod -aG docker $USER
newgrp docker

# 🔁 Or simply restart your session
```

</details>

<details>
<summary>🔧 Issue 4: Minikube won't start</summary>

```bash
# ♻️ Delete and recreate the Minikube cluster
minikube delete
minikube start --driver=docker

# 📊 Check available system resources
free -h
df -h
```

</details>

---

## 📊 Key Concepts Summary

| Concept | What It Means |
|---|---|
| 🧱 **Pods** | The smallest deployable unit in Kubernetes; each pod holds one or more containers sharing storage and network. Pods are ephemeral — created, destroyed, and recreated as needed |
| 🚀 **Deployments** | Manage ReplicaSets and provide declarative updates to applications; ensure a specified number of pod replicas stay running; support rolling updates and rollbacks |
| 🌐 **Services** | Provide a stable network endpoint for reaching pods, abstracting away their dynamic nature; common types are `ClusterIP`, `NodePort`, and `LoadBalancer` |
| 🧰 **kubectl Commands** | The primary CLI for interacting with a cluster — `get`, `describe`, `create`, `apply`, `delete`, `scale` — with output formats like `yaml`, `json`, `wide`, and `custom-columns` |

---

## ✅ Conclusion

### 🏆 Key Accomplishments

- ✅ Set up a complete Kubernetes environment using Minikube on a single Linux machine
- ✅ Created and managed Kubernetes Deployments with multiple replicas
- ✅ Exposed applications using Services with a NodePort configuration
- ✅ Scaled deployments up and down dynamically
- ✅ Used a wide range of `kubectl` commands to inspect and manage cluster resources
- ✅ Performed rolling updates and rollbacks
- ✅ Implemented ConfigMaps for configuration management

### 🌍 Real-World Applications

This hands-on experience builds the fundamental skills needed to work with Kubernetes in production environments. You now understand how Pods, Services, and Deployments work together to create scalable, resilient applications — the foundation for more advanced topics like persistent storage, network policies, and cluster administration. These same skills apply directly to real-world scenarios where you need to deploy, scale, and manage containerized applications in Kubernetes clusters.

---

<div align="center">

**🎓 Al Nafi — Cloud & Cybersecurity Training Labs**

</div>
