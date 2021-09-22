param location string = resourceGroup().location
param projectName string = 'AzApp'
param environmentName string = 'dev'
param storageAccountName string = toLower('${projectName}${environmentName}')
param storageSkuName string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
    isVersioningEnabled: false
  }
}

resource webappContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  parent: blobService
  name: 'webapp'
  properties: {
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
  dependsOn: [
    storageAccount
  ]
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output webappContainerName string = webappContainer.name
output webappContainerId string = webappContainer.id
