metadata description = 'Creates an Azure SQL Server instance.'
param name string
param location string = resourceGroup().location
param tags object = {}


param databaseName string
param keyVaultName string
param connectionStringKey string = 'AZURE-SQL-CONNECTION-STRING'

param apiAppName string

param userAssignedManagedIdentityId string
param userassignedmanagedidentityName string
param sqlAdmin string = 'sqlAdmin'
@secure()
param sqlAdminPassword string
param userAssignedManagedIdentityClientId string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    administratorLogin: sqlAdmin
    administratorLoginPassword: sqlAdminPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: userassignedmanagedidentityName
      principalType: 'Group'
      sid: userAssignedManagedIdentityClientId
      tenantId: tenant().tenantId
    }
  }

  resource database 'databases' = {
    name: databaseName
    location: location
  }

  resource firewall 'firewallRules' = {
    name: 'Azure Services'
    properties: {
      // Allow all clients
      // Note: range [0.0.0.0-0.0.0.0] means "allow all Azure-hosted clients only".
      // This is not sufficient, because we also want to allow direct access from developer machine, for debugging purposes.
      startIpAddress: '0.0.0.1'
      endIpAddress: '255.255.255.254'
    }
  }
}



resource sqlDeploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${name}-deployment-script'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.52.0'
    retentionInterval: 'PT1H' // Retain the script resource for 1 hour after it ends running
    timeout: 'PT5M' // Five minutes
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'DBNAME'
        value: databaseName
      }
      {
        name: 'DBSERVER'
        value: sqlServer.properties.fullyQualifiedDomainName
      }
      {
        name: 'apiAppName'
        value: apiAppName
      }
      {
        name: 'sqlManagedIdentityId'
        value: userAssignedManagedIdentityClientId
      }

    ]

    scriptContent: '''
wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

cat <<SCRIPT_END > ./initDb.sql
drop user if exists ${apiAppName}
go
CREATE USER ${apiAppName} FROM EXTERNAL PROVIDER
go
ALTER ROLE db_datareader ADD MEMBER ${apiAppName}
go
ALTER ROLE db_datawriter ADD MEMBER ${apiAppName}
go
SCRIPT_END

./sqlcmd -S ${DBSERVER} -d ${DBNAME} --authentication-method ActiveDirectoryManagedIdentity -U ${sqlManagedIdentityId} -i ./initDb.sql
    '''
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource sqlAdminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: 'sqlAdminPassword'
  properties: {
    value: sqlAdminPassword
  }
}

var connectionString = 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Authentication=Active Directory Default; Initial Catalog=${sqlServer::database.name};'
resource sqlAzureConnectionStringSercret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: connectionStringKey
  properties: {
    value: connectionString
  }
}

output connectionStringKey string = connectionStringKey
output databaseName string = sqlServer::database.name
