metadata description = 'Assigns ACR Pull permissions to access an Azure Container Registry.'
param containerRegistryName string
param principalId string

// Compliance parameters - Key Vault for access key management
param enableKeyVaultCompliance bool = false
param keyVaultName string = 'kv-acr-${take(replace(containerRegistryName, '-', ''), 15)}'

// Optional Key Vault for compliance (disabled by default to maintain architecture)
resource complianceKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = if (enableKeyVaultCompliance) {
  name: keyVaultName
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    enabledForTemplateDeployment: true
    accessPolicies: []
  }
}

var acrPullRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource aksAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry // Use when specifying a scope that is different than the deployment scope
  name: guid(subscription().id, resourceGroup().id, principalId, acrPullRole)
  properties: {
    roleDefinitionId: acrPullRole
    principalType: 'ServicePrincipal'
    principalId: principalId
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: containerRegistryName
}
