param name string
param location string

resource web 'Microsoft.Web/sites@2021-01-15' = {
  name: '${name}web'
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
  name: '${name}api'
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
      'AZURE_SQL_CONNECTION_STRING': AZURE_SQL_CONNECTION_STRING
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
  name: '${name}farm'
  location: location
  sku: {
    name: 'B1'
  }
}

module insights './appinsights.bicep' = {
  name: '${name}-airesources'
  params: {
    name: toLower(name)
    location: location
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: '${name}sql'
  location: location
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
    location: location
  }

  resource firewall 'firewallRules' = {
    name: 'Azure Services'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

// Defined as a var here because it is used above

var AZURE_SQL_CONNECTION_STRING = 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Authentication=Active Directory Default; Database=${sqlServer::database.name};'

output AZURE_SQL_CONNECTION_STRING string = AZURE_SQL_CONNECTION_STRING
output APPINSIGHTS_INSTRUMENTATIONKEY string = insights.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = insights.outputs.APPINSIGHTS_CONNECTION_STRING
output API_URI string = 'https://${api.properties.defaultHostName}'
