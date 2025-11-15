// Main Bicep Template
// Purpose: Orchestrates deployment of all Azure resources for e-commerce microservices

targetScope = 'subscription'

@description('Unique prefix for resource naming (3-5 characters)')
param projectPrefix string = 'ecom'

@description('Azure region for resources')
param location string = resourceGroup().location

@description('Number of AKS nodes')
@minValue(1)
@maxValue(5)
param aksNodeCount int = 2

@description('AKS node VM size (use Standard_B2s for student subscription)')
param aksVmSize string = 'Standard_B2s'

@description('SQL Database SKU')
param sqlDatabaseSku string = 'Basic'

@description('PostgreSQL SKU')
param postgresSku string = 'Standard_B1ms'

@description('Cosmos DB throughput (RU/s)')
@minValue(400)
param cosmosDbThroughput int = 400

@description('Enable App Service as alternative hosting')
param enableAppService bool = true

// Resource Group
var resourceGroupName = '${projectPrefix}-rg-${uniqueString(subscription().id)}'
var resourceGroup = resourceGroup(resourceGroupName, location)

// Outputs
output resourceGroupName string = resourceGroupName
output acrName string = acr.outputs.acrName
output aksName string = aks.outputs.aksName
output keyVaultName string = keyVault.outputs.keyVaultName
output sqlServerName string = databases.outputs.sqlServerName
output postgresServerName string = databases.outputs.postgresServerName
output cosmosDbName string = databases.outputs.cosmosDbName
output redisName string = databases.outputs.redisName
output serviceBusName string = serviceBus.outputs.serviceBusName
output appInsightsName string = monitoring.outputs.appInsightsName

// Modules
module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
  }
}

module aks 'modules/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
    acrName: acr.outputs.acrName
    nodeCount: aksNodeCount
    vmSize: aksVmSize
  }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
    aksPrincipalId: aks.outputs.aksPrincipalId
  }
}

module databases 'modules/databases.bicep' = {
  name: 'databases-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
    sqlDatabaseSku: sqlDatabaseSku
    postgresSku: postgresSku
    cosmosDbThroughput: cosmosDbThroughput
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'servicebus-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
    budgetThreshold: 30 // $30/month for student
  }
}

module appService 'modules/appservice.bicep' = {
  name: 'appservice-deployment'
  condition: enableAppService
  params: {
    projectPrefix: projectPrefix
    location: location
    resourceGroupName: resourceGroupName
    acrName: acr.outputs.acrName
  }
}

