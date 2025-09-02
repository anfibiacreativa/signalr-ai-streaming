metadata description = 'Creates an SignalR Services instance.'
param name string
param location string = resourceGroup().location
param tags object = {}
param disableLocalAuth bool = true

param sku object = {
  name: 'Premium_P1'
}

// Managed Identity for SignalR Service
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${name}-identity'
  location: location
  tags: tags
}

resource signalr 'Microsoft.SignalRService/signalR@2023-08-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: sku
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    disableLocalAuth: disableLocalAuth
  }
}

output endpoint string = signalr.properties.hostName
output id string = signalr.id
output name string = signalr.name
