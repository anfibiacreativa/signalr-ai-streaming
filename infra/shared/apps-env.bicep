param name string
param location string = resourceGroup().location
param tags object = {}

param logAnalyticsWorkspaceName string
param applicationInsightsName string = ''

// Compliance parameters - Key Vault for secrets  
param enableKeyVaultCompliance bool = false
param keyVaultName string = 'kv-apps-${take(replace(name, '-', ''), 15)}'

// Optional Key Vault for compliance (disabled by default to maintain architecture)
resource complianceKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = if (enableKeyVaultCompliance) {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    enabledForTemplateDeployment: true
    accessPolicies: []
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIConnectionString: applicationInsights.properties.ConnectionString
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output name string = containerAppsEnvironment.name
output domain string = containerAppsEnvironment.properties.defaultDomain
