# az role definition list --name "Storage Blob Data Reader" --output tsv --query '[].{name:name}'

# Using WestUS2 for now - as part of the FD+PL limitations - https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations
./deploy.ps1 -resourceGroup "AzFdPrivLinkDemo" `
    -location "westus2" `
    -projectName "AzFdPrivLink" `
    -environmentName "dev" `
    -bicepFile bicep/main.bicep `
    -bicepParametersFile main.parameters.dev.json