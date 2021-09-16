param projectName string = 'AzApp'
param environmentName string = 'dev'

@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource. When using Private Link origins with Front Door Premium during the preview period, there is a limited set of regions available for use. See https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations for more details.')
param location string

@description('The name of the App Service application to create. This must be globally unique.')
param appName string = toLower('${projectName}-${environmentName}-${uniqueString(resourceGroup().id)}')

@description('The name of the SKU to use when creating the App Service plan. This must be a SKU that is compatible with private endpoints, i.e. P1v2 or better.')
param appServicePlanSkuName string = 'P1v2'

@description('The number of worker instances of your App Service plan that should be provisioned.')
param appServicePlanCapacity int = 1

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param frontDoorEndpointName string = toLower('${projectName}-${environmentName}-${uniqueString(resourceGroup().id)}')

module webapp 'modules/webapp.bicep' = {
  name: 'appService'
  params: {
    location: location
    projectName: projectName
    environmentName: environmentName
    appName: appName
    appServicePlanSkuName: appServicePlanSkuName
    appServicePlanCapacity: appServicePlanCapacity
  }
}

module frontDoor 'modules/frontdoor.bicep' = {
  name: 'front-door'
  params: {
    projectName: projectName
    environmentName: environmentName
    skuName: 'Premium_AzureFrontDoor' // Private Link origins require the premium SKU.
    endpointName: frontDoorEndpointName
    originHostName: webapp.outputs.hostname
    privateEndpointResourceId: webapp.outputs.resourceId
    privateLinkResourceType: 'sites' // For App Service and Azure Functions, this needs to be 'sites'.
    privateEndpointLocation: location
  }
}

output webappHostName string = webapp.outputs.hostname
output frontDoorEndpointHostName string = frontDoor.outputs.frontDoorEndpointHostName
