# GitOps Demo with KinD+ArgoCD

Add some more info here :)

You can find a lot of examples in the official repo: [https://github.com/argoproj/argocd-example-apps]

## Requirements

* [kind](https://github.com/kubernetes-sigs/kind)
* [kubectl](https://github.com/kubernetes/kubectl)
* [argocd](https://github.com/argoproj/argo-cd)
* [jq](https://github.com/stedolan/jq)

## Steps

```sh
./create_cluster.sh

kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd login  argocd.localhost --insecure --username=admin

argocd app create guestbook -f apps/guestbook.yaml

```
