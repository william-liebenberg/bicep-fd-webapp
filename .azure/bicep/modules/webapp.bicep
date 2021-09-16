param projectName string = 'AzApp'
param environmentName string = 'dev'
param appName string = toLower('${projectName}-${environmentName}')

@description('The location into which the App Service resources should be deployed. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
param location string = 'australiasoutheast'

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.')
param appServicePlanSkuName string = 'P1V2'

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int = 1

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
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output hostname string = appService.properties.defaultHostName
output resourceId string = appService.id
