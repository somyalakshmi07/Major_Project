// Azure Service Bus Module
// Purpose: Creates Service Bus namespace with queues and topics for event-driven communication

param projectPrefix string
param location string
param resourceGroupName string

var serviceBusName = '${projectPrefix}-sb-${uniqueString(resourceGroup().id)}'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Basic' // Cost-effective for student subscription
    tier: 'Basic'
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
}

resource inventoryQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: 'inventory-events'
  properties: {
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P7D'
    lockDuration: 'PT1M'
    requiresDuplicateDetection: false
    requiresSession: false
  }
}

resource orderTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: 'order-events'
  properties: {
    maxSizeInMegabytes: 1024
    defaultMessageTimeToLive: 'P7D'
    requiresDuplicateDetection: false
  }
}

resource orderCreatedSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  parent: orderTopic
  name: 'order-created'
  properties: {
    maxDeliveryCount: 10
    lockDuration: 'PT1M'
    defaultMessageTimeToLive: 'P7D'
  }
}

output serviceBusName string = serviceBusNamespace.name
output serviceBusConnectionString string = serviceBusNamespace.listKeys().primaryConnectionString
output inventoryQueueName string = inventoryQueue.name
output orderTopicName string = orderTopic.name

