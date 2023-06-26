using './main.bicep'

param location = 'northeurope'

param monitoringResourceGroupName = 'Monitoring'
param prometheusName = 'prometheus'
param grafanaName = 'grafana'
param logAnalyticsName = 'logs'

param atlassianResourceGroupName = 'Atlassian'
param containerRegistryName = 'registry'
param clusterName = 'atlassian'
param kubernetesVersion = '1.25.6'
param dnsPrefix = 'atlassian'
param nodeCount = 3
param minNodeCount = 1
param maxNodeCount = 5
param nodeVmSize = 'Standard_D8s_v3'
param sqlServerName = 'sql'
param sqlAdministratorLogin = 'sqladmin'
param sqlAdministratorLoginPassword = readEnvironmentVariable('SQL_ADMINISTRATOR_LOGIN_PASSWORD')
