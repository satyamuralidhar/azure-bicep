@description('add paramters')
@maxLength(24)
@minLength(3)
param name string = 'storage784'
param sku_name string = 'Standard_LRS' 
param blobAccess bool = false
param accessTier string = 'Hot'
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_0'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: sku_name
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: blobAccess
    minimumTlsVersion: minimumTlsVersion
  }
}
// az deployment group create --resource-group ansible --name rollout01 --template-file main.bicep
//az deployment group delete --resource-group ansible --name rollout01
//covert bicep into arm 
//az bicep build -f ./main.bicep
//want to use params in json format create a params.json file and add params
