# GitOps Demo with ArgoCD

Add some more info here :)

## Steps

```sh
./create_cluster.sh

argocd login --username=admin argocd.localhost

argocd app create guestbook-ui --repo https://github.com/sneils/gitops-demo --path guestbook-ui --dest-server https://kubernetes.default.svc --dest-namespace apps

```
