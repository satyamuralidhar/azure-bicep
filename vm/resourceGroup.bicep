@allowed(
  [
    'eastus'
    'eastus2'
  ]
)
param location string = 'eastus'
var resourceGroupName  = 'BicepRsg'
targetScope = 'subscription'

@description('creating rsg')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceGroupName}'
  location: location

  
}

/*
az deployment sub create --name myrsg --location eastus --template-file resourceGroup.bicep
az deployment sub delete --name myrsg 
*/
