// Azure Container Registry Module
// Purpose: Creates ACR for storing Docker images

param projectPrefix string
param location string
param resourceGroupName string

var acrName = '${projectPrefix}acr${uniqueString(resourceGroup().id)}'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic' // Cost-effective for student subscription
  }
  properties: {
    adminUserEnabled: true // Enable admin user for Azure DevOps
    publicNetworkAccess: 'Enabled'
  }
}

output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output acrResourceId string = acr.id

