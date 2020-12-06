#!/usr/bin/env bash
#export KUBECONFIG=./k8s.conf
# wordir=$(pwd)
# KUBECONFIG=$wordir/inventory/my-cluster/artifacts/admin.conf


#####
#Helm Version: 3.3.4+
#Kubernetes Version: 1.19.0
####

helm-install(){
  helm install  $Name ./goApp-Chart  --set image.tag=$Tag  --set image.repository=$Image --set=service.port=$Port
}

prepare-cluster(){
   echo "Install Kube Dashbord"
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
   echo "Run Dashbord on LocalHost and install ingress controller" 
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm install ingress-nginx/ingress-nginx  --set controller.publishService.enabled=true  --generate-name
   kubectl proxy --address 0.0.0.0 --accept-hosts '.*' & 
}

getTocken(){
    kubectl create serviceaccount cluster-admin-dashboard-sa
    kubectl create clusterrolebinding cluster-admin-dashboard-sa  \
    --clusterrole=cluster-admin \
      --serviceaccount=default:cluster-admin-dashboard-sa
    kubectl describe secret $(kubectl -n kube-system get secret | awk '/^cluster-admin-dashboard-sa-token-/{print }') 
}


prometeus(){
  kubectl create ns monitoring
  kubectl get servicemonitors
  kubectl create -f manifests/
}

case "$1" in
  prepare-cluster)  shift; prepare-cluster "$@" ;;
  helm-install)  shift; helm-install "$@" ;;
  helm-update)  shift; helm-update "$@" ;;
  prometeus)  shift; prometeus "$@" ;;
  tocken)  shift; tocken "$@" ;;
  *) print_help; exit 1
esac
