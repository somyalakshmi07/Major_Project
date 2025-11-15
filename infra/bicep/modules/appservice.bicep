// App Service Module (Alternative to AKS)
// Purpose: Creates App Service Plan and container hosting for cost-effective deployment

param projectPrefix string
param location string
param resourceGroupName string
param acrName string

var appServicePlanName = '${projectPrefix}-asp-${uniqueString(resourceGroup().id)}'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1' // Basic tier for student subscription
    tier: 'Basic'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true // Linux plan
  }
}

output appServicePlanName string = appServicePlan.name
output appServicePlanResourceId string = appServicePlan.id

