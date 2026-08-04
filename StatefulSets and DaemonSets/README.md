<div align="center">

# ☸️ StatefulSets and DaemonSets

### Hands-on lab: run stateful MySQL workloads with persistent storage and deploy node-level DaemonSets across a multi-node Minikube cluster

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Minikube](https://img.shields.io/badge/Minikube-2496ED?style=for-the-badge&logo=kubernetes&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Prometheus](https://img.shields.io/badge/Node%20Exporter-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Fluent Bit](https://img.shields.io/badge/Fluent%20Bit-49BDA5?style=for-the-badge&logo=fluentbit&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Difficulty](https://img.shields.io/badge/Difficulty-Advanced-red?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment Setup](#️-lab-environment-setup)
- [🧩 Task 1: Install Required Tools](#-task-1-install-required-tools)
- [🗄️ Task 2: Create a StatefulSet with Persistent Volume](#️-task-2-create-a-statefulset-with-persistent-volume)
- [👥 Task 3: Deploy a DaemonSet and Test Pod Distribution on Nodes](#-task-3-deploy-a-daemonset-and-test-pod-distribution-on-nodes)
- [🔁 Task 4: Advanced StatefulSet Operations](#-task-4-advanced-statefulset-operations)
- [🎯 Task 5: Advanced DaemonSet Operations](#-task-5-advanced-daemonset-operations)
- [🩺 Task 6: Troubleshooting Common Issues](#-task-6-troubleshooting-common-issues)
- [📊 Task 7: Resource Management](#-task-7-resource-management)
- [🧹 Task 8: Cleanup Resources](#-task-8-cleanup-resources)
- [📚 Key Concepts Learned](#-key-concepts-learned)
- [🏆 Best Practices Learned](#-best-practices-learned)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Understand the differences between StatefulSets, DaemonSets, and regular Deployments |
| 2 | Create and manage StatefulSets with persistent storage |
| 3 | Deploy DaemonSets and verify their distribution across cluster nodes |
| 4 | Configure persistent volumes for stateful applications |
| 5 | Monitor and troubleshoot StatefulSets and DaemonSets |
| 6 | Understand use cases for stateful workloads in Kubernetes |

---

## 📋 Prerequisites

| Skill Area | You Should Be Comfortable With |
|---|---|
| ☸️ Kubernetes Basics | Pods, Services, Deployments |
| 🐧 Linux CLI | Basic command line operations |
| 📝 YAML | Reading and editing YAML file structure |
| 📦 Containers | Core container concepts |

---

## 🖥️ Lab Environment Setup

> **☁️ Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install every required tool during the exercises below.

---

## 🧩 Task 1: Install Required Tools

### 🔄 Subtask 1.1: Update System and Install Dependencies

```bash
# 🔄 Refresh package lists and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# 📥 Install curl, wget, and other core utilities
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release
```

### 🐳 Subtask 1.2: Install Docker

```bash
# 🔑 Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 📚 Add the Docker apt repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 🔄 Refresh the package index and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 👤 Add your user to the docker group
sudo usermod -aG docker $USER

# ▶️ Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# ✅ Verify the installation
docker --version
```

### 🧰 Subtask 1.3: Install kubectl

```bash
# ⬇️ Download the latest stable kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 🔓 Make kubectl executable
chmod +x kubectl

# 📂 Move kubectl into your system PATH
sudo mv kubectl /usr/local/bin/

# ✅ Verify the installation
kubectl version --client
```

### 🎡 Subtask 1.4: Install and Start Minikube

```bash
# ⬇️ Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# 📥 Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 🚀 Start a 3-node Minikube cluster (needed to see StatefulSet/DaemonSet distribution)
minikube start --driver=docker --nodes=3

# ✅ Verify the cluster status
kubectl get nodes
minikube status
```

```bash
# TODO: Bump --nodes to a higher count if you want to see DaemonSets spread even wider
```

---

## 🗄️ Task 2: Create a StatefulSet with Persistent Volume

### 📖 Subtask 2.1: Understand StatefulSets

StatefulSets are built for stateful applications that need:

- 🏷️ **Stable network identities** — each pod gets a predictable, persistent hostname
- 🔢 **Ordered deployment and scaling** — pods are created and terminated one at a time, in order
- 💾 **Persistent storage** — each pod can own its own dedicated persistent volume

### 💽 Subtask 2.2: Create Storage Class and Persistent Volume

```bash
# 🧾 Create the StorageClass manifest for dynamic provisioning
cat > storageclass.yaml << 'EOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: k8s.io/minikube-hostpath
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF

# 📤 Apply the StorageClass
kubectl apply -f storageclass.yaml

# ✅ Verify it was created
kubectl get storageclass
```

### 🐬 Subtask 2.3: Create a StatefulSet with MySQL

```bash
# 🧾 Create the MySQL StatefulSet + headless Service + ClusterIP Service manifest
cat > mysql-statefulset.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
  labels:
    app: mysql
spec:
  serviceName: mysql-headless
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        - name: MYSQL_DATABASE
          value: "testdb"
        - name: MYSQL_USER
          value: "testuser"
        - name: MYSQL_PASSWORD
          value: "testpass"
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: local-storage
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
  labels:
    app: mysql
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
    name: mysql
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  labels:
    app: mysql
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
    name: mysql
  type: ClusterIP
EOF

# 📤 Apply the StatefulSet and its Services
kubectl apply -f mysql-statefulset.yaml
```

> **🔐 Note:** The credentials above are hardcoded for lab purposes only — never ship plaintext database passwords in a real manifest. Use a `Secret` in production.

```yaml
# TODO: Swap the plaintext env vars for a Kubernetes Secret referenced via secretKeyRef
```

### 👀 Subtask 2.4: Monitor StatefulSet Deployment

```bash
# 👀 Watch the StatefulSet rollout
kubectl get statefulset mysql-statefulset -w

# 👀 In another terminal, monitor pods as they come up
kubectl get pods -l app=mysql -w

# 📋 Check StatefulSet status
kubectl describe statefulset mysql-statefulset

# 💾 Verify persistent volumes and claims
kubectl get pv
kubectl get pvc
```

### 🧪 Subtask 2.5: Test StatefulSet Properties

```bash
# 🏷️ Pod names should be predictable: mysql-statefulset-0, -1, -2
kubectl get pods -l app=mysql

# 💾 Check the persistent volume claims
kubectl get pvc

# 🌐 Test stable network identity via the headless Service DNS name
kubectl run mysql-client --image=mysql:8.0 -it --rm --restart=Never -- mysql -h mysql-statefulset-0.mysql-headless.default.svc.cluster.local -u root -prootpassword -e "SELECT @@hostname;"

# 📉 Test ordered scaling — scale down to 2 replicas
kubectl scale statefulset mysql-statefulset --replicas=2

# 👀 Watch which pod terminates (should be mysql-statefulset-2, highest ordinal first)
kubectl get pods -l app=mysql -w

# 📈 Scale back up to 3 replicas
kubectl scale statefulset mysql-statefulset --replicas=3
```

### 💾 Subtask 2.6: Test Data Persistence

```bash
# ✍️ Connect to the first MySQL pod and create test data
kubectl exec -it mysql-statefulset-0 -- mysql -u root -prootpassword -e "
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;
CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
SELECT * FROM users;
"

# 💥 Delete the pod to simulate a failure
kubectl delete pod mysql-statefulset-0

# ⏳ Wait for the pod to be recreated and ready
kubectl wait --for=condition=Ready pod/mysql-statefulset-0 --timeout=300s

# ✅ Verify the data survived the restart
kubectl exec -it mysql-statefulset-0 -- mysql -u root -prootpassword -e "
USE testdb;
SELECT * FROM users;
"
```

---

## 👥 Task 3: Deploy a DaemonSet and Test Pod Distribution on Nodes

### 📖 Subtask 3.1: Understand DaemonSets

DaemonSets guarantee that a copy of a pod runs on all (or a selected subset of) nodes. Common use cases:

- 📊 Node monitoring agents (e.g. Prometheus Node Exporter)
- 📜 Log collection daemons (e.g. Fluentd/Fluent Bit)
- 🌐 Network plugins (e.g. Calico)
- 💾 Storage daemons (e.g. Ceph)

### 📈 Subtask 3.2: Create a Monitoring DaemonSet

```bash
# 🧾 Create the node-monitor DaemonSet + Service manifest
cat > monitoring-daemonset.yaml << 'EOF'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
  labels:
    app: node-monitor
spec:
  selector:
    matchLabels:
      app: node-monitor
  template:
    metadata:
      labels:
        app: node-monitor
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-monitor
        image: prom/node-exporter:latest
        args:
        - '--path.procfs=/host/proc'
        - '--path.sysfs=/host/sys'
        - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)'
        ports:
        - containerPort: 9100
          hostPort: 9100
          name: metrics
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /rootfs
          readOnly: true
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        securityContext:
          runAsNonRoot: true
          runAsUser: 65534
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
---
apiVersion: v1
kind: Service
metadata:
  name: node-monitor-service
  labels:
    app: node-monitor
spec:
  selector:
    app: node-monitor
  ports:
  - port: 9100
    targetPort: 9100
    name: metrics
  type: ClusterIP
EOF

# 📤 Apply the DaemonSet
kubectl apply -f monitoring-daemonset.yaml
```

### ✅ Subtask 3.3: Verify DaemonSet Distribution

```bash
# 📋 Check DaemonSet status
kubectl get daemonset node-monitor

# 📃 List all cluster nodes
kubectl get nodes

# 🗺️ Check pod distribution across nodes
kubectl get pods -l app=node-monitor -o wide

# 📋 Describe the DaemonSet
kubectl describe daemonset node-monitor

# 🎯 Map each monitoring pod to its node
kubectl get pods -l app=node-monitor --field-selector=status.phase=Running -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

### ➕ Subtask 3.4: Test DaemonSet Scaling with Node Addition

```bash
# 🔢 Check the current node count
kubectl get nodes

# ➕ Add a new node to the Minikube cluster
minikube node add

# ⏳ Wait for the new node to become Ready
kubectl wait --for=condition=Ready node --all --timeout=300s

# ✅ Verify the new node is present
kubectl get nodes

# ✅ Confirm the DaemonSet auto-deployed a pod to the new node
kubectl get pods -l app=node-monitor -o wide

# 📊 Confirm the DaemonSet's desired count increased
kubectl get daemonset node-monitor
```

### 🧪 Subtask 3.5: Test DaemonSet Functionality

```bash
# 🔌 Port-forward to reach node-exporter metrics
kubectl port-forward daemonset/node-monitor 9100:9100 &

# 🧪 Test the metrics endpoint
curl http://localhost:9100/metrics | head -20

# 🛑 Stop the port-forward
pkill -f "kubectl port-forward"

# 🖥️ Spin up a test pod to reach the Service internally
kubectl run test-pod --image=curlimages/curl -it --rm --restart=Never -- sh

# 🧪 Inside the test pod, try:
# curl http://node-monitor-service:9100/metrics | head -10
# exit
```

### 📜 Subtask 3.6: Create a Log Collection DaemonSet

```bash
# 🧾 Create a Fluent Bit log-collector DaemonSet + ConfigMap
cat > log-collector-daemonset.yaml << 'EOF'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  labels:
    app: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: log-collector
        image: fluent/fluent-bit:latest
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: config
          mountPath: /fluent-bit/etc/
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: config
        configMap:
          name: fluent-bit-config
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On

    [OUTPUT]
        Name  stdout
        Match *
  
  parsers.conf: |
    [PARSER]
        Name        docker
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
EOF

# 📤 Apply the log-collector DaemonSet
kubectl apply -f log-collector-daemonset.yaml
```

### 🔎 Subtask 3.7: Monitor Multiple DaemonSets

```bash
# 📋 List all DaemonSets
kubectl get daemonsets

# 🗺️ Check pods for both DaemonSets
kubectl get pods -l app=node-monitor -o wide
kubectl get pods -l app=log-collector -o wide

# ✅ Confirm both are spread across all nodes
kubectl get pods -o wide | grep -E "(node-monitor|log-collector)"

# 📊 Check resource usage
kubectl top pods -l app=node-monitor
kubectl top pods -l app=log-collector
```

```bash
# TODO: Point Fluent Bit's [OUTPUT] at a real backend (Elasticsearch, Loki) instead of stdout
```

---

## 🔁 Task 4: Advanced StatefulSet Operations

### 🔄 Subtask 4.1: Rolling Updates

```bash
# 🔄 Patch the MySQL image to a newer version
kubectl patch statefulset mysql-statefulset -p='{"spec":{"template":{"spec":{"containers":[{"name":"mysql","image":"mysql:8.0.35"}]}}}}'

# 👀 Watch the rolling update progress
kubectl rollout status statefulset/mysql-statefulset

# 📜 Check rollout history
kubectl rollout history statefulset/mysql-statefulset
```

### 💾 Subtask 4.2: StatefulSet Backup and Recovery

```bash
# 💾 Back up data from one pod
kubectl exec mysql-statefulset-0 -- mysqldump -u root -prootpassword --all-databases > backup.sql

# 💥 Simulate a pod failure
kubectl delete pod mysql-statefulset-1

# ⏳ Wait for automatic recovery
kubectl wait --for=condition=Ready pod/mysql-statefulset-1 --timeout=300s

# ✅ Verify data integrity after recovery
kubectl exec -it mysql-statefulset-1 -- mysql -u root -prootpassword -e "SHOW DATABASES;"
```

---

## 🎯 Task 5: Advanced DaemonSet Operations

### 🏷️ Subtask 5.1: Node Selector for DaemonSets

```bash
# 🏷️ Label a specific node
kubectl label nodes minikube-m02 environment=production

# 🧾 Create a DaemonSet restricted to that label
cat > selective-daemonset.yaml << 'EOF'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: production-monitor
spec:
  selector:
    matchLabels:
      app: production-monitor
  template:
    metadata:
      labels:
        app: production-monitor
    spec:
      nodeSelector:
        environment: production
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "Monitoring production node"; sleep 30; done']
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF

# 📤 Apply the selective DaemonSet
kubectl apply -f selective-daemonset.yaml

# ✅ Confirm it only landed on the labeled node
kubectl get pods -l app=production-monitor -o wide
```

```bash
# TODO: Add a second nodeSelector tier (e.g. environment=staging) and compare distribution
```

---

## 🩺 Task 6: Troubleshooting Common Issues

### 🗄️ Subtask 6.1: StatefulSet Troubleshooting

```bash
# 📋 Check StatefulSet events
kubectl describe statefulset mysql-statefulset

# 📋 Check pod-level events
kubectl describe pod mysql-statefulset-0

# 💾 Check persistent volume / claim issues
kubectl get pv,pvc

# 📋 Check StorageClass issues
kubectl describe storageclass local-storage

# 📜 View StatefulSet pod logs
kubectl logs mysql-statefulset-0

# 📊 Check resource constraints
kubectl top pods -l app=mysql
```

### 👥 Subtask 6.2: DaemonSet Troubleshooting

```bash
# 📋 Check DaemonSet status in full YAML
kubectl get daemonset node-monitor -o yaml

# 📋 Check why pods might not be scheduled
kubectl describe daemonset node-monitor

# 🚫 Check node taints and tolerations
kubectl describe nodes | grep -A 5 Taints

# 📜 View DaemonSet pod logs
kubectl logs -l app=node-monitor

# 📊 Check resource usage
kubectl top pods -l app=node-monitor
```

---

## 📊 Task 7: Resource Management

### 📐 Subtask 7.1: Resource Limits and Requests

```bash
# 📊 Check current resource usage across the cluster
kubectl top nodes
kubectl top pods

# 🔧 Update the StatefulSet's resource limits
kubectl patch statefulset mysql-statefulset -p='{"spec":{"template":{"spec":{"containers":[{"name":"mysql","resources":{"requests":{"memory":"512Mi","cpu":"500m"},"limits":{"memory":"1Gi","cpu":"1000m"}}}]}}}}'

# 🔎 Monitor the resource changes
kubectl describe statefulset mysql-statefulset | grep -A 10 Resources
```

### ⚠️ Subtask 7.2: Horizontal Pod Autoscaling (HPA) Limitations

```bash
# ❌ Try to autoscale a StatefulSet (this will demonstrate the limitation)
kubectl autoscale statefulset mysql-statefulset --cpu-percent=50 --min=1 --max=10

# 🔎 Check the resulting HPA state / error
kubectl get hpa

# 🧹 Clean up the failed HPA object
kubectl delete hpa mysql-statefulset
```

> **⚠️ Why this matters:** HPA scales replica *count*, but StatefulSet pods are individually addressed and often carry unique per-pod state (like a MySQL replica's own dataset) — blindly scaling them like a stateless Deployment can break data consistency.

---

## 🧹 Task 8: Cleanup Resources

### 🗄️ Subtask 8.1: Clean Up StatefulSets

```bash
# 🗑️ Delete the StatefulSet (PVCs are kept by default)
kubectl delete statefulset mysql-statefulset

# 🔎 Check remaining PVCs
kubectl get pvc

# 🗑️ Delete the PVCs manually
kubectl delete pvc mysql-storage-mysql-statefulset-0
kubectl delete pvc mysql-storage-mysql-statefulset-1
kubectl delete pvc mysql-storage-mysql-statefulset-2

# 🗑️ Delete the Services
kubectl delete service mysql-headless mysql-service

# 🗑️ Delete the StorageClass
kubectl delete storageclass local-storage
```

### 👥 Subtask 8.2: Clean Up DaemonSets

```bash
# 🗑️ Delete all three DaemonSets
kubectl delete daemonset node-monitor log-collector production-monitor

# 🗑️ Delete the associated ConfigMap
kubectl delete configmap fluent-bit-config

# 🗑️ Delete the monitoring Service
kubectl delete service node-monitor-service

# 🏷️ Remove the node label
kubectl label nodes minikube-m02 environment-
```

### 🧹 Subtask 8.3: Final Cleanup

```bash
# 🔎 Confirm no resources remain
kubectl get all

# ⏹️ Stop the Minikube cluster
minikube stop

# ♻️ Optional: delete the Minikube cluster completely
# minikube delete
```

---

## 📚 Key Concepts Learned

**🗄️ StatefulSets**
- Provide stable network identities and ordered deployment
- Essential for databases, message queues, and other stateful applications
- Maintain persistent storage across pod restarts
- Support ordered scaling and rolling updates

**👥 DaemonSets**
- Ensure pods run on all or selected nodes
- Perfect for system-level services like monitoring and logging
- Automatically scale as cluster nodes are added
- Support node selection and tolerations

**💾 Persistent Storage**
- StorageClasses enable dynamic volume provisioning
- PersistentVolumeClaims provide a storage abstraction layer
- Data persists beyond an individual pod's lifecycle

---

## 🏆 Best Practices Learned

- ✅ Always set resource limits to prevent resource exhaustion
- ✅ Implement proper backup strategies for stateful applications
- ✅ Monitor resource usage and performance metrics continuously
- ✅ Use appropriate tolerations for DaemonSets running on control-plane nodes
- ✅ Test disaster-recovery scenarios regularly
- ✅ Apply proper security contexts for system-level pods

---

## ✅ Conclusion

### 🏆 What You Accomplished

- ✅ Installed and configured a complete Kubernetes environment using Minikube
- ✅ Created and managed StatefulSets with persistent storage for stateful applications
- ✅ Deployed DaemonSets for system-level services across all cluster nodes
- ✅ Implemented persistent storage using StorageClasses and PersistentVolumeClaims
- ✅ Tested data persistence and pod recovery scenarios
- ✅ Monitored resource usage and performance characteristics
- ✅ Troubleshot common issues with both StatefulSets and DaemonSets
- ✅ Performed advanced operations like rolling updates and selective deployment

### 🌍 Real-World Applications

The skills built in this lab apply directly to:

- 🗄️ **Database Management** — running MySQL, PostgreSQL, or MongoDB clusters
- 📊 **Monitoring Systems** — deploying Prometheus, Grafana, or custom monitoring solutions
- 📜 **Log Management** — implementing centralized logging with Fluentd, Filebeat, or similar tools
- 🌐 **Network Services** — managing network plugins and service meshes
- 💾 **Storage Systems** — deploying distributed storage solutions like Ceph or GlusterFS

---

<div align="center">

**🎓 Al Nafi — Cloud & Cybersecurity Training Labs**

</div>
