param exists bool
param name string

// Compliance parameters - Key Vault for container image metadata
param enableKeyVaultCompliance bool = false
param keyVaultName string = 'kv-img-${take(replace(name, '-', ''), 15)}'

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

resource existingApp 'Microsoft.App/containerApps@2023-05-02-preview' existing = if (exists) {
  name: name
}

output containers array = exists ? existingApp.properties.template.containers : []
