param location string = resourceGroup().location
param containerRegistryName string
param clusterName string
param kubernetesVersion string = '1.25.6'
param dnsPrefix string
param nodeCount int = 3
param minNodeCount int = 1
param maxNodeCount int = 5
param nodeVmSize string = 'Standard_D8s_v3'
param logAnalyticsWorkspace string
param sqlServerName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param sqlElasticPoolSkuName string = 'GP_Gen5_2'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: '${containerRegistryName}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  location: location
  name: clusterName
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        enableAutoScaling: true
        minCount: minNodeCount
        maxCount: maxNodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeTaints: []
        enableNodePublicIP: false
        tags: {}
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'kubenet'
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    disableLocalAccounts: true
    aadProfile: {
      managed: true
      adminGroupObjectIDs: []
      enableAzureRBAC: true
    }
    apiServerAccessProfile: {
      enablePrivateCluster: false
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: null
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace
          logType: 'ContainerInsights'
          useAADAuth: 'true'
        }
      }
    }
    azureMonitorProfile: {
      metrics: {
        enabled: true
      }
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  location: location
  name: '${sqlServerName}${uniqueString(resourceGroup().id)}'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }

}

resource firewallRules 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource elasticPool 'Microsoft.Sql/servers/elasticPools@2021-11-01' = {
  location: location
  parent: sqlServer
  name: 'default'
  sku: {
    name: sqlElasticPoolSkuName
  }
  properties: {
    zoneRedundant: true
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: 'Jira'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP437_CI_AI '
    zoneRedundant: true
    elasticPoolId: elasticPool.id
  }
}
