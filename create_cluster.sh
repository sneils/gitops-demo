#!/usr/bin/env bash

set -E -e -u -o pipefail

cat <<EOF | kind create cluster --wait=90s --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait -n ingress-nginx --for=condition=ready pod -l=app.kubernetes.io/component=controller --timeout=90s

#kubectl create namespace ingress-example
#kubectl apply -n ingress-example -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait -n argocd --for=condition=ready pod -l=app.kubernetes.io/name=argocd-server --timeout=90s
kubectl apply -n argocd -f argocd-ingress.yaml

echo "argocd password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o json | jq -r .data.password | base64 -d

echo "add \`127.0.0.1 argocd.localhost\` to your /etc/hosts to be able to access it :)"
