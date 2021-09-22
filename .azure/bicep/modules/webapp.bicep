param projectName string = 'AzApp'
param environmentName string = 'dev'
param appName string = toLower('${projectName}-${environmentName}')

@description('The location into which the App Service resources should be deployed. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
param location string = 'australiasoutheast'

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.')
param appServicePlanSkuName string = 'P1V2'

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int = 1

@description('UUID/Name of the Storage Blob Data Reader role')
param packagesBlobReaderRoleId string = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

@description('Full Resource ID of the Storage Account used for storing application package zips')
param packagesStorageAccountId string

@description('Full name of the storage account used for storing application package zips')
param packagesStorageAccountName string

// ----------------------------------------------------------------------------

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appName
  location: location
  kind: 'app'
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
  }
}

resource appService 'Microsoft.Web/sites@2021-01-15' = {
  name: appName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
    }
  }
}

resource packagesStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: packagesStorageAccountName
}

resource blobStorageRole 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(packagesBlobReaderRoleId, packagesStorageAccountId)
  scope: packagesStorageAccount
  properties: {
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', packagesBlobReaderRoleId)
    principalId: appService.identity.principalId
  }
}

output hostname string = appService.properties.defaultHostName
output resourceId string = appService.id
