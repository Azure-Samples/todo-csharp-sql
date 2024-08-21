targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters to override the default azd resource naming conventions. Update the main.parameters.json file to provide values. e.g.,:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param apiServiceName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param appServicePlanName string = ''
param keyVaultName string = ''
param logAnalyticsName string = ''
param resourceGroupName string = ''
param sqlServerName string = ''
param cosmosAccountName string = ''
param sqlDatabaseName string = ''
param webServiceName string = ''
param apimServiceName string = ''

@description('Flag to use Azure API Management to mediate the calls between the Web frontend and the backend API')
param useAPIM bool = false

@description('Flag to use Cosmos DB')
param useCosmos bool = true

@description('API Management SKU to use if APIM is enabled')
param apimSku string = 'Consumption'

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('ObjectId/ClientId of the azd executer, populated from pre-hook script')
param clientID string = ''

@secure()
@description('SQL Server administrator password')
param sqlAdminPassword string

@description('Whether the deployment is running on GitHub Actions')
param runningOnGh string = ''

@description('Whether the deployment is running on Azure DevOps Pipeline')
param runningOnAdo string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// USER ROLES
var principalType = empty(runningOnGh) && empty(runningOnAdo) ? 'User' : 'ServicePrincipal'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

//user-assigned managed identity for the API app
module apiAppManagedIdentity './core/security/managed-identity.bicep' = {
  name: 'managed-identity'
  scope: rg
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

//user-assigned managed identity for the SQL Admin
// module sqlAdminManagedIdentity './core/security/managed-identity.bicep' = {
//   name: 'sqlAdminManagedIdentity'
//   scope: rg
//   params: {
//     name: 'sqlAdminManagedIdentity'
//     location: location
//     tags: tags
//   }
// }

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    principalId: principalId
  }
}

// Give the API access to KeyVault
module apiKeyVaultAccess './core/security/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: apiAppManagedIdentity.outputs.managedIdentityPrincipalId
  }
}


module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B3'
    }
  }
}

// The application database
module sqlServer './app/db.bicep' = if (!useCosmos) {
  name: 'sql'
  scope: rg
  params: {
    name: !empty(sqlServerName) ? sqlServerName : '${abbrs.sqlServers}${resourceToken}'
    databaseName: sqlDatabaseName
    location: location
    tags: tags
    apiAppName: apiAppManagedIdentity.outputs.managedIdentityName
    keyVaultName: keyVault.outputs.name
    sqlAdminPassword: sqlAdminPassword
    userassignedmanagedidentityName: principalId
    userAssignedManagedIdentityClientId: clientID //will be populated from Pre provisioning hook script
    userAssignedManagedIdentityId: principalType == 'ServicePrincipal' ? principalId : ''
  }
}

// The application database
module cosmos './core/database/cosmos/sql/cosmos-sql-db.bicep' = if (useCosmos){
  name: 'cosmos'
  scope: rg
  params: {
    accountName: !empty(cosmosAccountName) ? cosmosAccountName : 'cosmos-keyless-${resourceToken}'
    databaseName: 'todo-db'
    location: location
    keyVaultName: keyVault.outputs.name
    tags: tags
    containers: [
      {
        name: 'todo'
        id: 'todo'
        partitionKey: '/id'
      }
    ]
  }
}

//cosmos role
module cosmosRoleContributor 'core/security/role.bicep' = if (useCosmos) {
  scope: rg
  name: 'ai-search-service-contributor'
  params: {
    principalId: apiAppManagedIdentity.outputs.managedIdentityPrincipalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' //Search Service Contributor
    principalType: 'ServicePrincipal'
  }
}

module cosmosAccountRole 'core/security/role-cosmos.bicep' = if (useCosmos){
  scope: rg
  name: 'cosmos-account-role'
  params: {
    principalId: apiAppManagedIdentity.outputs.managedIdentityPrincipalId
    databaseAccountId: cosmos.outputs.accountId
    databaseAccountName: cosmos.outputs.accountName
  }
}



// The application frontend
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: !empty(webServiceName) ? webServiceName : '${abbrs.webSitesAppService}web-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
  }
}

// The application backend
module api './app/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: !empty(apiServiceName) ? apiServiceName : '${abbrs.webSitesAppService}api-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    keyVaultName: keyVault.outputs.name
    allowedOrigins: [ web.outputs.SERVICE_WEB_URI ]
    appSettings: {
      AZURE_SQL_CONNECTION_STRING_KEY: sqlServer.outputs.connectionStringKey
      AZURE_CLIENT_ID: apiAppManagedIdentity.outputs.managedIdentityClientId
    }
    userassignedmanagedidentityId: apiAppManagedIdentity.outputs.managedIdentityId
  }
}

// Creates Azure API Management (APIM) service to mediate the requests between the frontend and the backend API
module apim './core/gateway/apim.bicep' = if (useAPIM) {
  name: 'apim-deployment'
  scope: rg
  params: {
    name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${resourceToken}'
    sku: apimSku
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
  }
}

// Configures the API in the Azure API Management (APIM) service
module apimApi './app/apim-api.bicep' = if (useAPIM) {
  name: 'apim-api-deployment'
  scope: rg
  params: {
    name: useAPIM ? apim.outputs.apimServiceName : ''
    apiName: 'todo-api'
    apiDisplayName: 'Simple Todo API'
    apiDescription: 'This is a simple Todo API'
    apiPath: 'todo'
    webFrontendUrl: web.outputs.SERVICE_WEB_URI
    apiBackendUrl: api.outputs.SERVICE_API_URI
    apiAppName: api.outputs.SERVICE_API_NAME
  }
}

// Data outputs
output AZURE_SQL_CONNECTION_STRING_KEY string = sqlServer.outputs.connectionStringKey

// App outputs
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output API_BASE_URL string = useAPIM ? apimApi.outputs.SERVICE_API_URI : api.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
output USE_APIM bool = useAPIM
output USE_COSMOS bool = useCosmos
output SERVICE_API_ENDPOINTS array = useAPIM ? [ apimApi.outputs.SERVICE_API_URI, api.outputs.SERVICE_API_URI ]: []
output SQLDATABASENAME string = sqlServer.outputs.databaseName
output SQLSERVERFQDN string = sqlServer.outputs.sqlServerFQDN
output MSIAPIAPPNAME string = apiAppManagedIdentity.outputs.managedIdentityName
