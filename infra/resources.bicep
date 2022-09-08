param environmentName string
param location string = resourceGroup().location
param principalId string = ''

@secure()
param sqlAdminPassword string
@secure()
param appUserPassword string


module appServicePlan './modules/appservice/appserviceplan-sites.bicep' = {
  name: 'appserviceplan-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

module web './modules/appservice/appservice-node.bicep' = {
  name: 'web-resources'
  params: {
    environmentName: environmentName
    location: location
    serviceName: 'web'
  }
  dependsOn: [
    applicationInsights
    appServicePlan
  ]
}

module api './modules/appservice/appservice-dotnet.bicep' = {
  name: 'api-resources'
  params: {
    environmentName: environmentName
    location: location
    serviceName: 'api'
    useKeyVault: true
  }
  dependsOn: [
    applicationInsights
    keyVault
    appServicePlan
  ]
}

module apiSqlServerConfig './modules/appservice/appservice-config-sqlserver.bicep' = {
  name: 'api-sqlserver-config-resources'
  params: {
    resourceName: api.outputs.NAME
    serviceName: 'api'
    sqlConnectionStringKey: sqlServer.outputs.AZURE_SQL_CONNECTION_STRING_KEY
  }
}

module keyVault './modules/keyvault/keyvault.bicep' = {
  name: 'keyvault-resources'
  params: {
    environmentName: environmentName
    location: location
    principalId: principalId
  }
}

module sqlServer './modules/sqlserver/sqlserver.bicep' = {
  name: 'sqlserver-resources'
  params: {
    environmentName: environmentName
    location: location
    sqlAdminPassword: sqlAdminPassword
    appUserPassword: appUserPassword
    dbName: 'ToDo'
  }
  dependsOn: [
    keyVault
  ]
}

module logAnalytics './modules/loganalytics/loganalytics.bicep' = {
  name: 'loganalytics-resources'
  params: {
    environmentName: environmentName
    location: location
  }
}

module applicationInsights './modules/applicationinsights/applicationinsights.bicep' = {
  name: 'applicationinsights-resources'
  params: {
    environmentName: environmentName
    location: location
    workspaceId: logAnalytics.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
  }
}


output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.AZURE_KEY_VAULT_ENDPOINT
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.outputs.APPLICATIONINSIGHTS_CONNECTION_STRING
output WEB_URI string = web.outputs.URI
output API_URI string = api.outputs.URI
output AZURE_SQL_CONNECTION_STRING_KEY string = sqlServer.outputs.AZURE_SQL_CONNECTION_STRING_KEY
output KEYVAULT_NAME string = keyVault.name
