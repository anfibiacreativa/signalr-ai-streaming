param name string
param location string = resourceGroup().location
param tags object = {}

@description('Service principal that should be granted read access to the KeyVault. If unset, no service principal is granted access by default')
param principalId string = ''

// Managed Identity for Key Vault access control
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${name}-identity'
  location: location
  tags: tags
}

var defaultAccessPolicies = !empty(principalId) ? [
  {
    objectId: principalId
    permissions: { secrets: [ 'get', 'list' ] }
    tenantId: subscription().tenantId
  }
] : []

// Add managed identity to access policies
var managedIdentityAccessPolicies = [
  {
    objectId: managedIdentity.properties.principalId
    permissions: { 
      secrets: [ 'get', 'list', 'set', 'delete' ]
      keys: [ 'get', 'list' ]
      certificates: [ 'get', 'list' ]
    }
    tenantId: subscription().tenantId
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    enabledForTemplateDeployment: true
    accessPolicies: union(defaultAccessPolicies, managedIdentityAccessPolicies)
  }
}

output endpoint string = keyVault.properties.vaultUri
output name string = keyVault.name
