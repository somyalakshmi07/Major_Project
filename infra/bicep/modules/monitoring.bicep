// Monitoring Module
// Purpose: Creates Application Insights, Log Analytics, and budget alerts

param projectPrefix string
param location string
param resourceGroupName string
param budgetThreshold int = 30

var appInsightsName = '${projectPrefix}-ai-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = '${projectPrefix}-law-${uniqueString(resourceGroup().id)}'
var actionGroupName = '${projectPrefix}-ag-${uniqueString(resourceGroup().id)}'
var budgetName = '${projectPrefix}-budget-${uniqueString(resourceGroup().id)}'

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30 // Cost optimization
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Action Group for Alerts
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    groupShortName: 'EcomAlerts'
    enabled: true
    emailReceivers: [
      {
        name: 'EmailAdmin'
        emailAddress: 'admin@example.com' // UPDATE THIS
        useCommonAlertSchema: true
      }
    ]
  }
}

// Budget Alert
resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  scope: subscription().id
  properties: {
    timePeriod: {
      startDate: '${utcNow('yyyy-MM-01')}'
      endDate: '${dateTimeAdd(utcNow(), 'P1Y')}'
    }
    timeGrain: 'Monthly'
    amount: budgetThreshold
    category: 'Cost'
    notifications: {
      actual: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [
          'admin@example.com' // UPDATE THIS
        ]
      }
      forecasted: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          'admin@example.com' // UPDATE THIS
        ]
      }
    }
  }
}

output appInsightsName string = appInsights.name
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output logAnalyticsWorkspaceId string = logAnalytics.properties.customerId
output logAnalyticsWorkspaceKey string = logAnalytics.listKeys().primarySharedKey

