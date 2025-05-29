#!/usr/bin/env bash

minikube -p sbomer stop
minikube -p sbomer delete

# replace minikube setup command with below in ./hack/minikube-setup.sh:
MINIKUBE_FOR_MAC="exec minikube start -p sbomer --driver=qemu --network=socket_vmnet --cpus=4 --memory=4g --disk-size=20GB --kubernetes-version=v1.25.16 --embed-certs"
sed -i '' "
/^exec minikube start.*/c\\
$MINIKUBE_FOR_MAC
" ./hack/minikube-setup.sh

bash ./hack/minikube-setup.sh

kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.53.3/release.yaml

# Tekton dashboard support
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml

# kubectl config set-context sbomer-local
kubectl config use-context sbomer-local

# !!! MANUALLY create a ./certs directory and put in 2015-IT-Root-CA.pem and 2022-IT-Root-CA.pem
mkdir -p ./certs
cp -r $HOME/certs ./

# npm install the ui
pushd ./ui
npm install
popd

# brew install typescript

bash ./hack/build-images-minikube.sh

# git clone git@gitlab.cee.redhat.com:appsvcs-platform/security/sbomer-helm.git

pushd $HOME/workspace/sbomer-setup/sbomer-helm

# PRE-PREPARED HELM CHART, JUST MAKE SURE values fetched AND mequal uses macos image

# !!! Make sure to change mequal image tag to "macos"

# OR copy an existing sbomer-helm

helm --kube-context sbomer-local upgrade --install --values env/app/prod.yaml sbomer .

popd

echo "Giving 20 seconds of time for pods to start up..."
sleep 20

bash $HOME/workspace/sbomer-setup/sbomer-macos-setup/batch-run-commands.sh

# minikube --logtostderr -p sbomer mount /tmp/sbomer:/tmp/hostpath-provisioner/default/sbomer-sboms --uid=65532
# bash ./hack/minikube-expose-db.sh
# bash ./hack/run-service-dev.sh

# Run the UI
# export REACT_APP_SBOMER_URL=http://localhost:8080 
# ./hack/run-ui-dev.sh

# minikube -p sbomer dashboard
# kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097
# kubectl port-forward services/sbomer-mequal 8181:80
