#!/bin/bash

echo "=== Kubernetes Network Report ==="
echo "Date: \$(date)"
echo

echo "=== Node Status ==="
kubectl get nodes -o wide

echo -e "\n=== Pod Status ==="
kubectl get pods -o wide

echo -e "\n=== Services ==="
kubectl get services

echo -e "\n=== Network Policies ==="
kubectl get networkpolicies

echo -e "\n=== Calico Status ==="
kubectl get pods -n kube-system | grep calico

echo -e "\n=== IP Pool Information ==="
kubectl exec -n kube-system -it \$(kubectl get pods -n kube-system -l k8s-app=calico-node -o jsonpath='{.items[0].metadata.name}') -- calicoctl get ippool -o wide 2>/dev/null || echo "Unable to retrieve IP pool info"
