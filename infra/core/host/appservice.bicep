param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param applicationInsightsName string = ''
param appServicePlanId string
param keyVaultName string = ''
param managedIdentity bool = !empty(keyVaultName)

// Runtime Properties
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'
param runtimeVersion string

// Microsoft.Web/sites Properties
param kind string = 'app,linux'

// Microsoft.Web/sites/config
param allowedOrigins array = []
param alwaysOn bool = true
param appCommandLine string = ''
param appSettings object = {}
param clientAffinityEnabled bool = false
param enableOryxBuild bool = contains(kind, 'linux')
param functionAppScaleLimit int = -1
param linuxFxVersion string = runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param scmDoBuildDuringDeployment bool = false
param use32BitWorkerProcess bool = false

// Target DB properties
param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'
param targetResourceId string = ''
param appUser string = ''
@secure()
param appUserPassword string = ''

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      numberOfWorkers: numberOfWorkers != -1 ? numberOfWorkers : null
      minimumElasticInstanceCount: minimumElasticInstanceCount != -1 ? minimumElasticInstanceCount : null
      use32BitWorkerProcess: use32BitWorkerProcess
      functionAppScaleLimit: functionAppScaleLimit != -1 ? functionAppScaleLimit : null
      cors: {
        allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
      }
    }
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: true
  }

  identity: { type: managedIdentity ? 'SystemAssigned' : 'None' }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: union(appSettings,
      {
        SCM_DO_BUILD_DURING_DEPLOYMENT: string(scmDoBuildDuringDeployment)
        ENABLE_ORYX_BUILD: string(enableOryxBuild)
      },
      !empty(applicationInsightsName) ? { APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString } : {})
  }

  resource configLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: { fileSystem: { level: 'Verbose' } }
      detailedErrorMessages: { enabled: true }
      failedRequestsTracing: { enabled: true }
      httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
    }
    dependsOn: [
      configAppSettings
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (!(empty(keyVaultName))) {
  name: keyVaultName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

// if !empty(keyVaultName), create connection to keyvault so that db credentials could be saved into keyvault, 
// and app service could retrieve secrets from keyvault using managed identity
resource connectionToKeyVault 'Microsoft.ServiceLinker/linkers@2022-11-01-preview' =  if(!empty(keyVaultName)) {
  name: 'conn_kv'
  scope: appService
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
}

// if !empty(targetResourceId), create connection to target database, including: 
// - add db connectionstr (from keyvault if applicable) in webapp appsettings or connectionString(for dotnetcore convention)
// - allow webapp firewall at target database if applicable (target allows firewall instead of public access)
resource connectionToTargetDB 'Microsoft.ServiceLinker/linkers@2022-11-01-preview' = if (!empty(targetResourceId)) {
  name: 'conn_db'
  scope: appService
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
      authType: 'secret'
      name: appUser
      secretInfo: {
        secretType: 'rawValue'
        value: appUserPassword
      }
    }
    clientType: 'dotnet'
  }
  dependsOn: [
    connectionToKeyVault
  ]
}

output identityPrincipalId string = managedIdentity ? appService.identity.principalId : ''
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
