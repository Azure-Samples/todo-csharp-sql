param authType string
//param appResourceId string
param targetResourceId string
param runtimeName string
param dbUserName string = ''
param keyVaultName string
param webAppName string
param connectionStringKey string =''

@secure()
param dbUserPassword string = ''


// if !empty(keyVaultName), create connection to keyvault so that db credentials could be saved into keyvault, 
// and app service could retrieve secrets from keyvault using managed identity
resource connectionToKeyVault 'Microsoft.ServiceLinker/linkers@2022-11-01-preview' =  if(!empty(keyVaultName)) {
  name: 'conn_kv'
  scope: webApp
  properties: {
    targetService: {
      id: keyVault.id
      type: 'AzureResource'
    }
    clientType: 'none'
    authInfo: {
      authType: 'systemAssignedIdentity'
      roles: [
        '4633458b-17de-408a-b874-0445c86b69e6'
      ]
    }
    configurationInfo: {
      customizedKeys: {
        'AZURE_KEYVAULT_RESOURCEENDPOINT': 'AZURE_KEY_VAULT_ENDPOINT'
      }
    }
  }
  dependsOn: [
    webApp
  ]
}

// if !empty(targetResourceId), create connection to target database, including: 
// - add db connectionstr (from keyvault if applicable) in webapp appsettings or connectionString(for dotnetcore convention)
// - allow webapp firewall at target database if applicable (target allows firewall instead of public access)
resource connectionToTargetDB 'Microsoft.ServiceLinker/linkers@2022-11-01-preview' = if (!empty(targetResourceId)) {
  name: 'conn_db'
  scope: webApp
  properties: {
    targetService: {
      id: targetResourceId
      type: 'AzureResource'
    }
    secretStore: {
      keyVaultId: !empty(keyVaultName) ? keyVault.id : ''
      keyVaultSecretName: !empty(keyVaultName) ? connectionStringKey : ''
    }
    authInfo: {
      authType: authType
      name: dbUserName
      secretInfo: {
        secretType: 'rawValue'
        value: dbUserPassword
      }
    }
    clientType: runtimeName
  }
  dependsOn: [
    connectionToKeyVault
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
  scope: resourceGroup()
}

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
  scope: resourceGroup()
}
