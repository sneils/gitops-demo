#!/usr/bin/env bash

set -E -e -u -o pipefail

cd "$(dirname "$0")/.."

kind create cluster --wait=90s --config=etc/kind-config.yaml

# basic nginx ingress for convenience
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait -n ingress-nginx --for=condition=ready pod -l=app.kubernetes.io/component=controller --timeout=90s

# argocd system
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=ready pod -l=app.kubernetes.io/name=argocd-server --timeout=90s
kubectl apply -n argocd -f etc/argocd-ingress.yaml

# notification system
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/v1.1.1/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/v1.1.1/catalog/install.yaml
kubectl apply -n argocd -f etc/argocd-notifications-secret.yaml
#kubectl apply -n argocd -f etc/argocd-notifications-cm.yaml
kubectl patch cm argocd-notifications-cm --type merge -n argocd -p '{"data": {"service.telegram": "{ token: $telegram-token }"}}'

kubectl create namespace apps

echo "argocd password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o json | jq -r .data.password | base64 -d
printf "\n\n"

echo "add \`127.0.0.1 argocd.localhost\` to your /etc/hosts to be able to access it :)"
