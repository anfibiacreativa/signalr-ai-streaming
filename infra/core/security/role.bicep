metadata description = 'Creates a role assignment for a service principal.'
param principalId string

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'
param roleDefinitionId string

// Compliance parameters - Key Vault for role assignment metadata
param enableKeyVaultCompliance bool = false
param keyVaultName string = 'kv-role-${take(replace(principalId, '-', ''), 15)}'

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

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinitionId)
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
