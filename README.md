# Jira on Azure Demo

## Prerequisites

1. Install [Azure Command-Line Interface (CLI)](https://learn.microsoft.com/en-us/cli/azure/):

    ```powershell
    winget install Microsoft.AzureCLI
    ```

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/):

    ```powershell
    winget install Kubernetes.kubectl
    winget install Microsoft.Azure.Kubelogin
    ```

1. Install [Helm](https://helm.sh/docs/intro/install/):

    ```powershell
    winget install Helm.Helm
    ```

## Deploy

1. Set `SQL_ADMINISTRATOR_LOGIN_PASSWORD`:

    ```powershell
    $env:SQL_ADMINISTRATOR_LOGIN_PASSWORD=...
    ```

1. Update `main.bicepparam`
1. Deploy template:

    ```powershell
    az deployment sub create --location northeurope --template-file .\main.bicep --parameters .\main.bicepparam
    ```

1. Make current user admin (TODO: Configure in Bicep)

    ```powershell
    $cluster=$(az aks show --resource-group Atlassian --name atlassian --query id -o tsv)
    $user=$(az ad signed-in-user show --query id -o tsv)
    az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --assignee $user --scope $cluster
    ```

1. Login to Kubernetes:

    ```powershell
    az aks get-credentials --resource-group Atlassian --name atlassian
    ```

1. Verify connection:

    ```powershell
    kubectl cluster-info
    ```

1. Create namespace for Jira:

    ```powershell
    kubectl create namespace jira
    ```

1. Set secrets:

    ```powershell
    kubectl create secret generic jira.database.credentials --from-literal=username="sqladmin" --from-literal=password="$env:SQL_ADMINISTRATOR_LOGIN_PASSWORD" -n jira
    ```

1. Apply storage class:

    ```powershell
    kubectl apply -f azure-file-sc.yaml
    ```

1. Enable Azure Monitor in the Portal (TODO: Configure in Bicep)
1. Install Jira using Helm: <https://atlassian.github.io/data-center-helm-charts/userguide/INSTALLATION/>:

    ```powershell
    helm install jira atlassian-data-center/jira --namespace jira --values jira-values.yaml
    ```

1. Test and debug

    ```powershell
    helm test jira --logs --namespace jira

    kubectl get pods -n jira
    kubectl get service -n jira
    kubectl logs jira-0 -n jira
    kubectl describe pod jira-0 -n jira

    helm upgrade jira atlassian-data-center/jira --namespace jira --values jira-values.yaml

    helm uninstall jira --namespace jira
    ```