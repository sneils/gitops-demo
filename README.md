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
$ ./create_cluster.sh
<snip_lots_of_output>

# for notifications with telegram, you'll need your own bot+token secret
# and set up your own channel in etc/argocd-notifications-cm.yaml
$ kubectl -n argocd apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
stringData:
  telegram-token: xxx
type: Opaque
EOF
$ kubectl -n argocd patch cm argocd-notifications-cm --type merge --patch-file etc/argocd-notifications-cm.yaml

# add argocd.localhost to your /etc/hosts for convenient ingress
$ echo '127.0.0.1 argocd.localhost' | sudo tee -a /etc/hosts
# you can now find the web interface at that addess https://argocd.localhost, but you'll need to accept the self-signed ssl cert
$ open https://argocd.locahost

# grab the initial argocd admin password
$ kubectl -n argocd get secret argocd-initial-admin-secret -o json | jq -r .data.password | base64 -d; echo
<some_password>

$ argocd login argocd.localhost --insecure --username=admin
<input_password>

# just the guestbook app
$ argocd app create guestbook -f apps/guestbook.yaml
<hurray!>

# or we'll bootstrap it by having a meta app above all apps
$ argocd app create bootstrap -f bootstrap/bootstrap.yaml
<hurray!>

# we're done, let's get rid of it
$ kind delete cluster

```
