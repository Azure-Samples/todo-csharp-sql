targetScope = 'subscription'

@minLength(1)
@maxLength(17)
@description('Prefix for all resources, i.e. {basename}storage')
param basename string

@minLength(1)
@description('Primary location for all resources')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${basename}rg'
  location: location
}

module resources './resources.bicep' = {
  name: '${rg.name}-resources'
  scope: rg
  params: {
    basename: toLower(basename)
    location: location
  }
}

output SQL_CONNECTION_STRING string = resources.outputs.SQL_CONNECTION_STRING
output APPINSIGHTS_INSTRUMENTATIONKEY string = resources.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output APPINSIGHTS_CONNECTION_STRING string = resources.outputs.APPINSIGHTS_CONNECTION_STRING
output APPINSIGHTS_NAME string = resources.outputs.APPINSIGHTS_NAME
output APPINSIGHTS_DASHBOARD_NAME string = resources.outputs.APPINSIGHTS_DASHBOARD_NAME
output REACT_APP_API_BASE_URL string = resources.outputs.API_URI
output REACT_APP_APPINSIGHTS_INSTRUMENTATIONKEY string = resources.outputs.APPINSIGHTS_INSTRUMENTATIONKEY
output LOCATION string = location
