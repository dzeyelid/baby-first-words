@description('The name of the resource group')
param resourceGroupName string = 'rg-baby-first-words'

@description('The location for the resource group')
param location string = 'japaneast'

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module main 'resources.bicep' = {
  name: 'main'
  scope: resourceGroup
  params: {
    location: location
  }
}

output resourceGroupName string = resourceGroup.name
output location string = resourceGroup.location