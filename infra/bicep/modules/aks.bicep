// Azure Kubernetes Service Module
// Purpose: Creates AKS cluster with system node pool optimized for student subscription

param projectPrefix string
param location string
param resourceGroupName string
param acrName string
param nodeCount int = 2
param vmSize string = 'Standard_B2s'

var aksName = '${projectPrefix}-aks-${uniqueString(resourceGroup().id)}'
var aksIdentityName = '${aksName}-identity'

// Managed Identity for AKS
resource aksIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: aksIdentityName
  location: location
}

// AKS Cluster
resource aks 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: aksName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksIdentity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: '1.28' // Latest stable
    dnsPrefix: aksName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: false // Disable for cost control
        minCount: nodeCount
        maxCount: nodeCount
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
    }
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${projectPrefix}-law'
        }
      }
    }
    enableRBAC: true
  }
}

// Grant ACR pull permissions to AKS identity
resource acrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksIdentity.id, acrName, 'AcrPull')
  scope: resourceId('Microsoft.ContainerRegistry/registries', acrName)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: aksIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output aksName string = aks.name
output aksFqdn string = aks.properties.fqdn
output aksPrincipalId string = aksIdentity.properties.principalId
output aksResourceId string = aks.id

