// Databases Module
// Purpose: Creates SQL Server, PostgreSQL, Cosmos DB, and Redis

param projectPrefix string
param location string
param resourceGroupName string
param sqlDatabaseSku string
param postgresSku string
param cosmosDbThroughput int
param keyVaultName string

var sqlServerName = '${projectPrefix}-sql-${uniqueString(resourceGroup().id)}'
var sqlAdminLogin = 'sqladmin'
var sqlAdminPassword = 'P@ssw0rd123!' // Should be stored in Key Vault in production
var sqlDatabaseName = 'OrderDb'

var postgresServerName = '${projectPrefix}-postgres-${uniqueString(resourceGroup().id)}'
var postgresAdminLogin = 'postgresadmin'
var postgresAdminPassword = 'P@ssw0rd123!' // Should be stored in Key Vault
var postgresDatabaseName = 'AuthDb'

var cosmosDbName = '${projectPrefix}-cosmos-${uniqueString(resourceGroup().id)}'
var cosmosDbDatabaseName = 'CatalogDb'

var redisName = '${projectPrefix}-redis-${uniqueString(resourceGroup().id)}'

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
  }
}

resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB for Basic tier
  }
}

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  name: postgresServerName
  location: location
  sku: {
    name: postgresSku
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: postgresAdminLogin
    administratorLoginPassword: postgresAdminPassword
    version: '15'
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-06-01-preview' = {
  parent: postgresServer
  name: postgresDatabaseName
}

resource postgresFirewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: postgresServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Cosmos DB (MongoDB API)
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: cosmosDbName
  location: location
  kind: 'MongoDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: cosmosDbDatabaseName
  properties: {
    resource: {
      id: cosmosDbDatabaseName
    }
    options: {
      throughput: cosmosDbThroughput
    }
  }
}

// Redis Cache
resource redis 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisName
  location: location
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0 // C0 = 250MB, cost-effective
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
  }
}

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output sqlConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
output postgresServerName string = postgresServer.name
output postgresDatabaseName string = postgresDatabaseName.name
output postgresConnectionString string = 'Host=${postgresServer.properties.fullyQualifiedDomainName};Port=5432;Database=${postgresDatabaseName};Username=${postgresAdminLogin};Password=${postgresAdminPassword};'
output cosmosDbName string = cosmosAccount.name
output cosmosConnectionString string = 'mongodb://${cosmosAccount.name}:${cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString}@${cosmosAccount.name}.mongo.cosmos.azure.com:10255/${cosmosDbDatabaseName}?ssl=true&replicaSet=globaldb'
output redisName string = redis.name
output redisConnectionString string = '${redis.name}.redis.cache.windows.net:6380,password=${redis.listKeys().primaryKey},ssl=True,abortConnect=False'

