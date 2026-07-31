#!/bin/bash

set -e

echo "Adding Helm repositories..."

helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts

helm repo add grafana \
https://grafana.github.io/helm-charts

helm repo update

echo "Creating monitoring namespace..."

kubectl create namespace monitoring \
--dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Prometheus Stack..."

helm upgrade --install kube-prometheus-stack \
prometheus-community/kube-prometheus-stack \
-n monitoring \
-f monitoring/prometheus/prometheus-values.yaml \
--set grafana.enabled=false \
--set prometheus.service.type=NodePort \
--set prometheus.service.nodePort=32090

echo "Deploying Grafana..."

helm upgrade --install grafana \
grafana/grafana \
--namespace monitoring \
-f monitoring/grafana/grafana-values.yaml \
--set service.type=NodePort \
--set service.nodePort=32000

echo "Monitoring stack deployed successfully!"