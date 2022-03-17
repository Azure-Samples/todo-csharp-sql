targetScope = 'subscription'

@minLength(1)
@maxLength(17)
@description('Prefix for all resources, i.e. {name}storage')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${name}rg'
  location: location
}

module resources './resources.bicep' = {
  name: '${rg.name}-resources'
  scope: rg
  params: {
    name: toLower(name)
    location: location
  }
}

output AZURE_SQL_CONNECTION_STRING string = resources.outputs.AZURE_SQL_CONNECTION_STRING
output APPINSIGHTS_INSTRUMENTATIONKEY string = resources.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = resources.outputs.APPINSIGHTS_CONNECTION_STRING
output REACT_APP_API_BASE_URL string = resources.outputs.API_URI
output REACT_APP_APPINSIGHTS_INSTRUMENTATIONKEY string = resources.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output AZURE_LOCATION string = location
