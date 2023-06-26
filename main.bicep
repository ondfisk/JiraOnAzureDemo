targetScope = 'subscription'

param location string = deployment().location
param monitoringResourceGroupName string
param prometheusName string
param grafanaName string
param logAnalyticsName string

param atlassianResourceGroupName string
param containerRegistryName string
param clusterName string
param kubernetesVersion string = '1.25.6'
param dnsPrefix string
param nodeCount int = 3
param minNodeCount int = 1
param maxNodeCount int = 5
param nodeVmSize string = 'Standard_D8s_v3'
param sqlServerName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param sqlElasticPoolSkuName string = 'GP_Gen5_2'

resource monitoringResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: monitoringResourceGroupName
  location: location
}

module monitoring 'monitoring.bicep' = {
  scope: monitoringResourceGroup
  name: 'monitoring'
  params: {
    location: location
    prometheusName: prometheusName
    grafanaName: grafanaName
    logAnalyticsName: logAnalyticsName
  }
}

resource atlassianResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: atlassianResourceGroupName
  location: location
}

module atlassian 'atlassian.bicep' = {
  scope: atlassianResourceGroup
  name: 'atlassian'
  params: {
    location: location
    containerRegistryName: containerRegistryName
    clusterName: clusterName
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    nodeCount: nodeCount
    minNodeCount: minNodeCount
    maxNodeCount: maxNodeCount
    nodeVmSize: nodeVmSize
    logAnalyticsWorkspace: monitoring.outputs.logAnalyticsWorkspace
    sqlServerName: sqlServerName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlElasticPoolSkuName: sqlElasticPoolSkuName
  }
}
