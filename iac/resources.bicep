param basename string
param location string
param principalId string = ''

resource web 'Microsoft.Web/sites@2021-01-15' = {
  name: '${basename}web'
  location: location
  properties: {
    serverFarmId: farm.id
    siteConfig: {
      alwaysOn: true
      ftpsState: 'FtpsOnly'
    }
    httpsOnly: true
  }

  resource webappappsettings 'config' = {
    name: 'appsettings'
    properties: {
      'SCM_DO_BUILD_DURING_DEPLOYMENT': 'false'
      'APPINSIGHTS_INSTRUMENTATIONKEY': insights.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
    }
  }

  resource logs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Verbose'
        }
      }
      detailedErrorMessages: {
        enabled: true
      }
      failedRequestsTracing: {
        enabled: true
      }
      httpLogs: {
        fileSystem: {
          enabled: true
          retentionInDays: 1
          retentionInMb: 35
        }
      }
    }
  }
}

resource api 'Microsoft.Web/sites@2021-01-15' = {
  name: '${basename}api'
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: farm.id
    siteConfig: {
      alwaysOn: true
      ftpsState: 'FtpsOnly'
    }
    httpsOnly: true
  }

  identity: {
    type: 'SystemAssigned'
  }

  resource appsettings 'config' = {
    name: 'appsettings'
    properties: {
      'SQL_CONNECTION_STRING': SQL_CONNECTION_STRING
      'APPINSIGHTS_INSTRUMENTATIONKEY': insights.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
    }
  }

  resource logs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: {
        fileSystem: {
          level: 'Verbose'
        }
      }
      detailedErrorMessages: {
        enabled: true
      }
      failedRequestsTracing: {
        enabled: true
      }
      httpLogs: {
        fileSystem: {
          enabled: true
          retentionInDays: 1
          retentionInMb: 35
        }
      }
    }
  }
}

resource farm 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: '${basename}farm'
  location: location
  sku: {
    name: 'B1'
  }
}


module insights './appinsights.bicep' = {
  name: '${basename}-airesources'
  params: {
    basename: toLower(basename)
    location: location
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: '${basename}sql'
  location: resourceGroup().location
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'User'
      sid: api.identity.principalId
      login: 'activedirectoryadmin'
      tenantId: api.identity.tenantId
      azureADOnlyAuthentication: true
    }
  }

  resource database 'databases' = {
    name: 'ToDo'
    location: resourceGroup().location
  }

  resource firewall 'firewallRules' = {
    name: 'Azure Services'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

var SQL_CONNECTION_STRING = 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Authentication=Active Directory Default; Database=${sqlServer::database.name};'

output SQL_CONNECTION_STRING string = SQL_CONNECTION_STRING
output APPINSIGHTS_NAME string = insights.outputs.APPINSIGHTS_NAME
output APPINSIGHTS_INSTRUMENTATIONKEY string = insights.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_DASHBOARD_NAME string = insights.outputs.APPINSIGHTS_DASHBOARD_NAME
output APPINSIGHTS_CONNECTION_STRING string = insights.outputs.APPINSIGHTS_CONNECTION_STRING
output API_URI string = 'https://${api.properties.defaultHostName}'
