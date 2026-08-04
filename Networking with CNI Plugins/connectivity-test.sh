#!/bin/bash

echo "=== Pod Connectivity Test ==="
echo "Pod 1 IP: \$(kubectl get pod test-pod-1 -o jsonpath='{.status.podIP}')"
echo "Pod 2 IP: \$(kubectl get pod test-pod-2 -o jsonpath='{.status.podIP}')"
echo "Pod 3 IP: \$(kubectl get pod test-pod-3 -o jsonpath='{.status.podIP}')"

echo -e "\n=== Testing Pod-to-Pod Ping ==="
kubectl exec test-pod-2 -- ping -c 2 \$(kubectl get pod test-pod-1 -o jsonpath='{.status.podIP}')

echo -e "\n=== Testing HTTP Connectivity ==="
kubectl exec test-pod-2 -- wget -qO- --timeout=5 http://\$(kubectl get pod test-pod-1 -o jsonpath='{.status.podIP}')

echo -e "\n=== Testing Service DNS ==="
kubectl exec test-pod-2 -- nslookup test-service-1.default.svc.cluster.local

echo -e "\n=== Network Policy Test ==="
kubectl exec test-pod-3 -- timeout 5 wget -qO- http://\$(kubectl get pod test-pod-1 -o jsonpath='{.status.podIP}') || echo "Blocked by network policy (expected)"

echo -e "\n=== Test Complete ==="
