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


echo "Deploying Prometheus..."

helm upgrade --install prometheus \
prometheus-community/prometheus \
--namespace monitoring \
-f monitoring/prometheus/prometheus-values.yaml


echo "Deploying Grafana..."

helm upgrade --install grafana \
grafana/grafana \
--namespace monitoring \
-f monitoring/grafana/grafana-values.yaml


echo "Monitoring stack deployed successfully!"