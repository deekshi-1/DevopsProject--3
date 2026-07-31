#!/bin/bash
# Deploys a temporary pod to consume CPU and trigger the HighCPU alert
echo "Starting CPU stress test on the cluster..."
kubectl run stress-test --image=polinux/stress --restart=Never -- stress --cpu 4 --timeout 600s
echo "Stress test running for 10 minutes. Check Grafana/Prometheus for alerts."