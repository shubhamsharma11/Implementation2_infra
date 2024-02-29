docker-compose build

# Login to the Azure
az login

# Set the subscription
az account set --subscription 14f56a24-f129-441e-a95b-0df01d75c3a7

# Create service principle
az ad sp create-for-rbac --name spDemo01 --role Contributor --scopes /subscriptions/3b1bfc9b-7c37-48b7-b852-c4208989b7d1

# Initalize and apply terraform
terraform init
terraform apply --auto-approve

# get aks credentials
az aks get-credentials --resource-group rgDemo01 --name aksDemo01

# Display Nodes in AKS
kubectl get nodes

# Create ACR
az acr create --resource-group rgDemo01 --name acrshubdemo01 --sku Basic

# Login to the ACR
az acr login --name acrshubdemo01

# Push docker images to ACR using docker-compose
# docker push acrshubdemo01.azurecr.io/shub-image:v1
docker-compose push

# Display Images list available in ACR
az acr repository list --name acrshubdemo01 --output table

kubectl apply -f K8s

kubectl scale deployment nginx-deployment --replicas=5

kubectl scale deployment nginx-deployment --replicas=2

kubectl expose deployment nginx-deployment --name=vueapp-service --type=LoadBalancer --port=80 --protocol=TCP

az aks create -g rgDemo01 -n myAKSCluster --enable-managed-identity --node-count 1 --node-vm-size Standard_D2s_v3 --enable-addons monitoring --enable-msi-auth-for-monitoring  --attach-acr acrshubdemo01 --generate-ssh-keys

