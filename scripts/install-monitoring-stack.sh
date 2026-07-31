#!/bin/bash

set -e

echo "Adding Helm repositories..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

echo "Creating monitoring namespace..."

kubectl create namespace monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Prometheus Stack..."

helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring/prometheus/prometheus-values.yaml \
  --set grafana.enabled=false \
    --set prometheus.service.type=NodePort \
    --set prometheus.service.nodePort=32090 \
  --wait

echo "Creating Grafana dashboard ConfigMap..."

kubectl create configmap grafana-dashboards \
  --namespace monitoring \
  --from-file=monitoring/grafana/dashboards/ \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Grafana..."

helm upgrade --install grafana \
  grafana/grafana \
  --namespace monitoring \
  -f monitoring/grafana/grafana-values.yaml \
  --set service.type=NodePort \
  --set service.nodePort=32000 \
  --wait

echo "Restarting Grafana..."

kubectl rollout restart deployment grafana -n monitoring

echo "Waiting for pods..."

kubectl wait --for=condition=Ready pod \
  -l app.kubernetes.io/name=prometheus \
  -n monitoring \
  --timeout=300s || true

kubectl wait --for=condition=Ready pod \
  -l app.kubernetes.io/name=grafana \
  -n monitoring \
  --timeout=300s || true

echo
echo "======================================="
echo "Monitoring Stack Deployed Successfully"
echo "======================================="
echo

echo "Grafana:"
echo "http://<EC2-PUBLIC-IP>:32000"

echo

echo "Prometheus:"
echo "http://<EC2-PUBLIC-IP>:32090"

echo

echo "Default Grafana credentials:"
echo "Username: admin"

echo "Password:"
kubectl get secret grafana \
  -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 -d

echo
echo

echo "Installed Pods:"
kubectl get pods -n monitoring

echo

echo "Installed Services:"
kubectl get svc -n monitoring