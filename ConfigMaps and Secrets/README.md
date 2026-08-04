<div align="center">

# 🔐 ConfigMaps and Secrets

### Hands-on lab: separate configuration from code and manage sensitive data properly in Kubernetes

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Minikube](https://img.shields.io/badge/Minikube-2496ED?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![OpenSSL](https://img.shields.io/badge/OpenSSL-721412?style=for-the-badge&logo=openssl&logoColor=white)
![kubectl](https://img.shields.io/badge/kubectl-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Difficulty](https://img.shields.io/badge/Difficulty-Intermediate-orange?style=for-the-badge)

</div>

---

## 📑 Table of Contents

- [🎯 Learning Objectives](#-learning-objectives)
- [📋 Prerequisites](#-prerequisites)
- [🖥️ Lab Environment](#️-lab-environment)
- [🧩 Task 1: Environment Setup and Kubernetes Installation](#-task-1-environment-setup-and-kubernetes-installation)
- [🗂️ Task 2: Create and Use ConfigMaps](#️-task-2-create-and-use-configmaps)
- [🔒 Task 3: Store Sensitive Information in Kubernetes Secrets](#-task-3-store-sensitive-information-in-kubernetes-secrets)
- [🔎 Task 4: Test Secret Access with kubectl](#-task-4-test-secret-access-with-kubectl)
- [🚀 Task 5: Advanced ConfigMap and Secret Operations](#-task-5-advanced-configmap-and-secret-operations)
- [🩹 Troubleshooting Tips](#-troubleshooting-tips)
- [🌍 Why This Matters](#-why-this-matters)
- [🏆 Best Practices Learned](#-best-practices-learned)
- [✅ Conclusion](#-conclusion)

---

## 🎯 Learning Objectives

| # | Objective |
|---|-----------|
| 1 | Understand the difference between ConfigMaps and Secrets in Kubernetes |
| 2 | Create and manage ConfigMaps to store non-sensitive configuration data |
| 3 | Create and manage Secrets to store sensitive information securely |
| 4 | Mount ConfigMaps and Secrets as volumes in pods |
| 5 | Use ConfigMaps and Secrets as environment variables |
| 6 | Access and verify Secret data using `kubectl` commands |
| 7 | Implement best practices for configuration management in Kubernetes |

---

## 📋 Prerequisites

| Skill Area | You Should Be Comfortable With |
|---|---|
| 🐧 Linux CLI | Basic command line operations |
| 📝 YAML | Reading and writing YAML file format |
| ☸️ Kubernetes Basics | Pods, Deployments |
| ⚙️ Configuration | Environment variables and configuration files |
| ☸️ Prior Labs | Completed previous Kubernetes labs or equivalent experience |

---

## 🖥️ Lab Environment

> **☁️ Note:** Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your dedicated Linux machine. The provided machine is **bare metal with no pre-installed tools** — you will install every required tool during the exercises below.

---

## 🧩 Task 1: Environment Setup and Kubernetes Installation

### 🔄 Subtask 1.1: Update System and Install Dependencies

```bash
# 🔄 Refresh package lists
sudo apt update

# 📥 Install required packages
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

# 🔑 Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 📚 Add the Docker apt repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 🔄 Refresh the package index and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 👤 Add your user to the docker group
sudo usermod -aG docker $USER
newgrp docker

# ✅ Verify the installation
docker --version
```

### 🧰 Subtask 1.2: Install Kubernetes Tools

```bash
# ⬇️ Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# ✅ Verify kubectl
kubectl version --client

# ⬇️ Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# ✅ Verify Minikube
minikube version
```

### 🎡 Subtask 1.3: Start Kubernetes Cluster

```bash
# 🚀 Start the Minikube cluster
minikube start --driver=docker

# ✅ Verify the cluster is running
kubectl cluster-info

# 🔎 Check node status
kubectl get nodes
```

---

## 🗂️ Task 2: Create and Use ConfigMaps

### 📖 Subtask 2.1: Understanding ConfigMaps

ConfigMaps store **non-confidential** configuration data as key-value pairs. They separate configuration from application code, making applications more portable and easier to manage across environments.

### 🏷️ Subtask 2.2: Create ConfigMap from Literal Values

```bash
# 🗂️ Create a ConfigMap from literal key-value pairs
kubectl create configmap app-config \
  --from-literal=database_host=mysql.example.com \
  --from-literal=database_port=3306 \
  --from-literal=app_mode=production \
  --from-literal=log_level=info

# ✅ Verify the ConfigMap was created
kubectl get configmaps

# 📋 View its details
kubectl describe configmap app-config
```

### 📄 Subtask 2.3: Create ConfigMap from File

```bash
# 📁 Create a working directory for lab files
mkdir -p ~/k8s-lab5
cd ~/k8s-lab5

# 📝 Create a sample configuration file
cat > app.properties << EOF
# Application Configuration
server.port=8080
server.host=0.0.0.0
database.url=jdbc:mysql://localhost:3306/myapp
database.driver=com.mysql.cj.jdbc.Driver
cache.enabled=true
cache.ttl=3600
logging.level=DEBUG
EOF

# 🗂️ Create a ConfigMap from the file
kubectl create configmap app-properties --from-file=app.properties

# 👀 View the resulting ConfigMap
kubectl get configmap app-properties -o yaml
```

### 🧾 Subtask 2.4: Create ConfigMap Using YAML Manifest

```bash
# 🧾 Create a ConfigMap manifest with multiple data keys
cat > configmap-web.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
  labels:
    app: web-server
data:
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        
        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
        }
        
        location /api {
            proxy_pass http://backend:8080;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
        <title>ConfigMap Demo</title>
    </head>
    <body>
        <h1>Welcome to ConfigMap Demo</h1>
        <p>This content is loaded from a ConfigMap!</p>
    </body>
    </html>
EOF

# 📤 Apply the ConfigMap
kubectl apply -f configmap-web.yaml

# ✅ Verify creation
kubectl get configmap web-config -o yaml
```

### 📦 Subtask 2.5: Use ConfigMap in a Pod

```bash
# 🧾 Create a pod manifest that consumes ConfigMaps two ways: env vars + volumes
cat > pod-with-configmap.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: configmap-demo-pod
  labels:
    app: demo
spec:
  containers:
  - name: demo-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    env:
    # 🌱 Use ConfigMap keys as environment variables
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_host
    - name: DATABASE_PORT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_port
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: app_mode
    volumeMounts:
    # 📦 Mount ConfigMaps as files
    - name: config-volume
      mountPath: /etc/nginx/conf.d
    - name: web-content
      mountPath: /usr/share/nginx/html
    - name: app-properties
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: web-config
      items:
      - key: nginx.conf
        path: default.conf
  - name: web-content
    configMap:
      name: web-config
      items:
      - key: index.html
        path: index.html
  - name: app-properties
    configMap:
      name: app-properties
EOF

# 📤 Create the pod
kubectl apply -f pod-with-configmap.yaml

# ⏳ Wait for it to become ready
kubectl wait --for=condition=Ready pod/configmap-demo-pod --timeout=60s

# ✅ Verify it's running
kubectl get pods
```

### 🧪 Subtask 2.6: Verify ConfigMap Usage

```bash
# 🌱 Check the environment variables inside the pod
kubectl exec configmap-demo-pod -- env | grep -E "(DATABASE|APP_MODE)"

# 📂 Check the mounted configuration files
kubectl exec configmap-demo-pod -- ls -la /etc/config/
kubectl exec configmap-demo-pod -- cat /etc/config/app.properties

# 📄 Check the mounted nginx configuration
kubectl exec configmap-demo-pod -- cat /etc/nginx/conf.d/default.conf

# 📄 Check the mounted web content
kubectl exec configmap-demo-pod -- cat /usr/share/nginx/html/index.html

# 🌐 Test the web server end to end
kubectl port-forward pod/configmap-demo-pod 8080:80 &
sleep 2
curl http://localhost:8080
pkill -f "kubectl port-forward"
```

```bash
# TODO: Add a subPath mount so only a single file from a larger ConfigMap gets mounted
```

---

## 🔒 Task 3: Store Sensitive Information in Kubernetes Secrets

### 📖 Subtask 3.1: Understanding Secrets

Secrets store sensitive information such as passwords, OAuth tokens, SSH keys, and TLS certificates. Unlike ConfigMaps, Secret values are base64 encoded and can be encrypted at rest — but base64 is **encoding, not encryption**, so Secrets still need RBAC and encryption-at-rest controls to be truly protected.

### 🔑 Subtask 3.2: Create Secret from Literal Values

> **🔐 Lab-only credentials:** the values below are dummy placeholders for this exercise — never hardcode real passwords or keys in a lab manifest or command history.

```bash
# 🔑 Create a Secret from literal values
kubectl create secret generic database-secret \
  --from-literal=username=admin \
  --from-literal=password=supersecret123 \
  --from-literal=api-key=abc123def456ghi789

# ✅ Verify the Secret was created
kubectl get secrets

# 📋 View its details (note: values are not shown)
kubectl describe secret database-secret
```

### 📁 Subtask 3.3: Create Secret from Files

```bash
# 📝 Create files holding sensitive data
echo -n "admin" > username.txt
echo -n "supersecret123" > password.txt
echo -n "abc123def456ghi789" > api-key.txt

# 🔑 Create a Secret from those files
kubectl create secret generic file-secret \
  --from-file=username.txt \
  --from-file=password.txt \
  --from-file=api-key.txt

# 🧹 Clean up the plaintext files immediately
rm username.txt password.txt api-key.txt

# ✅ Verify creation
kubectl get secret file-secret -o yaml
```

### 🔏 Subtask 3.4: Create TLS Secret

```bash
# 🔏 Generate a self-signed certificate for demo purposes
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=demo.example.com/O=demo"

# 🔑 Create a TLS-type Secret from the cert/key pair
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key

# ✅ Verify the TLS Secret
kubectl get secret tls-secret -o yaml

# 🧹 Clean up the plaintext certificate files
rm tls.key tls.crt
```

### 🧾 Subtask 3.5: Create Secret Using YAML Manifest

```bash
# 🔢 Encode values to base64 for the manifest
echo -n "dbuser" | base64
echo -n "dbpass123" | base64
echo -n "mongodb://localhost:27017/myapp" | base64

# 🧾 Create the Secret manifest with the base64 output
cat > secret-manifest.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  labels:
    app: myapp
type: Opaque
data:
  db-username: ZGJ1c2Vy
  db-password: ZGJwYXNzMTIz
  connection-string: bW9uZ29kYjovL2xvY2FsaG9zdDoyNzAxNy9teWFwcA==
EOF

# 📤 Apply the Secret
kubectl apply -f secret-manifest.yaml

# ✅ Verify creation
kubectl get secret app-secret -o yaml
```

### 🔐 Subtask 3.6: Use Secrets in a Pod

```bash
# 🧾 Create a pod that consumes Secrets as env vars and mounted files
cat > pod-with-secrets.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo-pod
  labels:
    app: secret-demo
spec:
  containers:
  - name: demo-container
    image: nginx:1.21
    ports:
    - containerPort: 80
    env:
    # 🌱 Use Secret keys as environment variables
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: database-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: database-secret
          key: password
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: database-secret
          key: api-key
    volumeMounts:
    # 📦 Mount Secrets as read-only files
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    - name: tls-volume
      mountPath: /etc/tls
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
  - name: tls-volume
    secret:
      secretName: tls-secret
EOF

# 📤 Create the pod
kubectl apply -f pod-with-secrets.yaml

# ⏳ Wait for it to become ready
kubectl wait --for=condition=Ready pod/secret-demo-pod --timeout=60s

# ✅ Verify it's running
kubectl get pods
```

```bash
# TODO: Swap readOnly: true off and observe why that's a bad idea for Secret volumes
```

---

## 🔎 Task 4: Test Secret Access with kubectl

### 👁️ Subtask 4.1: View Secret Data

```bash
# 📋 List all Secrets
kubectl get secrets

# 📄 Get a Secret in full YAML
kubectl get secret database-secret -o yaml

# 🔓 Pull a specific field and decode it from base64
kubectl get secret database-secret -o jsonpath='{.data.username}' | base64 --decode
echo
kubectl get secret database-secret -o jsonpath='{.data.password}' | base64 --decode
echo
kubectl get secret database-secret -o jsonpath='{.data.api-key}' | base64 --decode
echo
```

### ✅ Subtask 4.2: Verify Secret Usage in Pod

```bash
# 🌱 Check the environment variables inside the pod
kubectl exec secret-demo-pod -- env | grep -E "(DB_|API_KEY)"

# 📂 Check the mounted Secret files
kubectl exec secret-demo-pod -- ls -la /etc/secrets/
kubectl exec secret-demo-pod -- cat /etc/secrets/db-username
kubectl exec secret-demo-pod -- cat /etc/secrets/db-password
kubectl exec secret-demo-pod -- cat /etc/secrets/connection-string

# 🔏 Check the mounted TLS certificate
kubectl exec secret-demo-pod -- ls -la /etc/tls/
kubectl exec secret-demo-pod -- openssl x509 -in /etc/tls/tls.crt -text -noout | head -20
```

### 🔄 Subtask 4.3: Update Secrets

```bash
# 🔄 Update the Secret with new values via a dry-run + apply
kubectl create secret generic database-secret \
  --from-literal=username=newadmin \
  --from-literal=password=newsecret456 \
  --from-literal=api-key=xyz789abc123def456 \
  --dry-run=client -o yaml | kubectl apply -f -

# ✅ Verify the update took effect
kubectl get secret database-secret -o jsonpath='{.data.username}' | base64 --decode
echo

# ♻️ Pods need a restart to pick up new env-var Secret values
kubectl delete pod secret-demo-pod
kubectl apply -f pod-with-secrets.yaml
kubectl wait --for=condition=Ready pod/secret-demo-pod --timeout=60s

# ✅ Confirm the new value is live
kubectl exec secret-demo-pod -- env | grep DB_USERNAME
```

### 🛡️ Subtask 4.4: Secret Security Best Practices

```bash
# ⚠️ Demonstrate that base64 is encoding, not encryption — it's trivially reversible
echo "This demonstrates that base64 is encoding, not encryption:"
echo -n "mysecretpassword" | base64
echo "bXlzZWNyZXRwYXNzd29yZA==" | base64 --decode
echo

# 🛡️ Create a Secret alongside a ServiceAccount to model RBAC-scoped access
cat > secret-rbac-demo.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: rbac-secret
  namespace: default
  annotations:
    description: "Secret with RBAC considerations"
type: Opaque
data:
  sensitive-data: dGhpc2lzdmVyeXNlbnNpdGl2ZWRhdGE=
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: secret-reader
  namespace: default
EOF

# 📤 Apply the RBAC demo resources
kubectl apply -f secret-rbac-demo.yaml

# 👀 Inspect the resulting Secret
kubectl get secret rbac-secret -o yaml
```

```bash
# TODO: Attach a Role + RoleBinding scoping secret-reader to only "get" this one Secret
```

---

## 🚀 Task 5: Advanced ConfigMap and Secret Operations

### 🔒 Subtask 5.1: ConfigMap and Secret Immutability

```bash
# 🧾 Create an immutable ConfigMap
cat > immutable-configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: immutable-config
immutable: true
data:
  config.yaml: |
    app:
      name: "MyApp"
      version: "1.0.0"
      environment: "production"
    database:
      host: "prod-db.example.com"
      port: 5432
EOF

# 📤 Apply the immutable ConfigMap
kubectl apply -f immutable-configmap.yaml

# ❌ Try to update it — this should fail because it's immutable
kubectl patch configmap immutable-config --patch='{"data":{"config.yaml":"modified"}}'

# 🧾 Create an immutable Secret
cat > immutable-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: immutable-secret
type: Opaque
immutable: true
data:
  token: dGhpc2lzYXNlY3JldHRva2Vu
EOF

# 📤 Apply the immutable Secret
kubectl apply -f immutable-secret.yaml

# 🔎 Verify immutability on both
kubectl describe configmap immutable-config
kubectl describe secret immutable-secret
```

### 🧩 Subtask 5.2: Using ConfigMaps and Secrets Together

```bash
# 🧾 Deploy a complete app that combines a ConfigMap and a Secret
cat > complete-app.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-complete
data:
  app.yaml: |
    server:
      port: 8080
      host: "0.0.0.0"
    logging:
      level: "INFO"
      format: "json"
    features:
      cache_enabled: true
      metrics_enabled: true
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets-complete
type: Opaque
data:
  db_password: cG9zdGdyZXNfcGFzc3dvcmQ=
  jwt_secret: and0X3NlY3JldF9rZXlfMTIz
  api_token: YWJjZGVmZ2hpams=
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: complete-app
  labels:
    app: complete-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: complete-app
  template:
    metadata:
      labels:
        app: complete-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 8080
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets-complete
              key: db_password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets-complete
              key: jwt_secret
        - name: API_TOKEN
          valueFrom:
            secretKeyRef:
              name: app-secrets-complete
              key: api_token
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
        - name: secret-volume
          mountPath: /etc/secrets
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: app-config-complete
      - name: secret-volume
        secret:
          secretName: app-secrets-complete
EOF

# 📤 Deploy the complete application
kubectl apply -f complete-app.yaml

# ⏳ Wait for the Deployment to become available
kubectl wait --for=condition=available deployment/complete-app --timeout=120s

# ✅ Verify the Deployment
kubectl get deployments
kubectl get pods -l app=complete-app
```

### 🧹 Subtask 5.3: Cleanup and Resource Management

```bash
# 📋 List all ConfigMaps and Secrets
echo "=== ConfigMaps ==="
kubectl get configmaps

echo "=== Secrets ==="
kubectl get secrets

# 📊 Check resource usage (if metrics-server is available)
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

# 🗑️ Clean up all lab resources
kubectl delete pod configmap-demo-pod secret-demo-pod
kubectl delete deployment complete-app
kubectl delete configmap app-config app-properties web-config immutable-config app-config-complete
kubectl delete secret database-secret file-secret tls-secret app-secret rbac-secret immutable-secret app-secrets-complete
kubectl delete serviceaccount secret-reader

# ✅ Verify cleanup
kubectl get configmaps
kubectl get secrets
kubectl get pods
```

---

## 🩹 Troubleshooting Tips

<details>
<summary>🔧 Issue 1: Pod fails to start due to missing ConfigMap or Secret</summary>

```bash
# 📋 Check pod events for the missing-reference error
kubectl describe pod <pod-name>

# 🔎 Verify the ConfigMap/Secret actually exists
kubectl get configmaps
kubectl get secrets
```

</details>

<details>
<summary>🔧 Issue 2: Environment variables not showing up in pod</summary>

```bash
# 🔑 Check that the expected keys exist in the ConfigMap/Secret
kubectl describe configmap <configmap-name>
kubectl describe secret <secret-name>

# ✅ Verify the environment variable names match exactly
kubectl exec <pod-name> -- env
```

</details>

<details>
<summary>🔧 Issue 3: Mounted files are empty or missing</summary>

```bash
# 📦 Check the pod's volume mount configuration
kubectl describe pod <pod-name>

# 📂 Verify the file actually landed at the expected path
kubectl exec <pod-name> -- ls -la /path/to/mount
```

</details>

<details>
<summary>🔧 Issue 4: Base64 encoding/decoding issues</summary>

```bash
# 🔢 Encode properly — the -n flag avoids a trailing newline corrupting the value
echo -n "your-secret" | base64

# 🔓 Decode and verify
echo "encoded-value" | base64 --decode
```

</details>

---

## 🌍 Why This Matters

Configuration management is crucial in modern application deployment because:

- 🧩 **Separation of Concerns** — configuration is separated from application code, making applications more portable
- 🌎 **Environment-Specific Settings** — different configurations can be used for development, staging, and production
- 🔒 **Security** — sensitive data is handled separately from regular configuration data
- 📈 **Scalability** — configuration changes don't require rebuilding application images
- 📜 **Compliance** — proper secret management helps meet security and compliance requirements

---

## 🏆 Best Practices Learned

- ✅ Use ConfigMaps for non-sensitive data like application settings, feature flags, and environment-specific configurations
- ✅ Use Secrets for sensitive information such as passwords, API keys, and certificates
- ✅ Implement proper RBAC to control access to Secrets
- ✅ Consider immutable ConfigMaps and Secrets for production environments
- ✅ Use volume mounts for large configuration files and environment variables for simple key-value pairs
- ✅ Regularly rotate secrets and update configurations as needed

---

## ✅ Conclusion

### 🏆 Key Accomplishments

- ✅ Installed and configured a complete Kubernetes environment using Minikube
- ✅ Created and managed ConfigMaps using multiple methods — literal values, config files, and YAML manifests
- ✅ Implemented Secrets management for sensitive data — generic secrets, TLS secrets, and both file-based and manifest-based creation
- ✅ Deployed applications that consume both ConfigMaps and Secrets — as environment variables, as mounted volumes, and combined for complete application configuration
- ✅ Tested and verified proper access and security — decoded Secret data with `kubectl`, verified mounting and env-var injection, and applied security best practices

### 🌍 Real-World Applications

This lab provides a solid foundation for managing application configuration and secrets in Kubernetes environments. The patterns practiced here — separating config from code, protecting sensitive values, and understanding the real limits of base64 "encoding" — are exactly what's needed to run secure, portable, environment-aware applications in real-world container orchestration scenarios.

---

<div align="center">

**🎓 Al Nafi — Cloud & Cybersecurity Training Labs**

</div>
