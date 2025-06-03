@description('The location for all resources')
param location string = resourceGroup().location

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    location: location
  }
}

output storageAccountName string = storage.outputs.storageAccountName
output storageAccountId string = storage.outputs.storageAccountId