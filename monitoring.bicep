param location string = resourceGroup().location
param prometheusName string
param grafanaName string
param logAnalyticsName string

resource prometheus 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: '${prometheusName}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {}
}

resource grafana 'Microsoft.Dashboard/grafana@2022-08-01' = {
  name: '${grafanaName}-${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: prometheus.id
        }
      ]
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${logAnalyticsName}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
  }
} 

output logAnalyticsWorkspace string = logAnalytics.id
