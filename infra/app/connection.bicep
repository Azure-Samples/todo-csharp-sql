param authType string
//param appResourceId string
param targetResourceId string
param runtimeName string
param dbUserName string = ''
param keyVaultName string
param webAppName string
param connectionStringKey string = ''

@secure()
param dbUserPassword string

var resourcePrefix = uniqueString(webAppName)

module connections '../core/host/servicelinker.bicep' = {
  name: '${resourcePrefix}conns'
  params: {
    authType: authType
    //appResourceId: appResourceId
    targetResourceId: targetResourceId
    runtimeName: runtimeName
    dbUserName: dbUserName
    dbUserPassword: dbUserPassword
    keyVaultName: keyVaultName
    webAppName: webAppName
    connectionStringKey: connectionStringKey
  }
}
