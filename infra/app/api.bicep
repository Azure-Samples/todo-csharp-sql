param name string
param location string = resourceGroup().location
param tags object = {}

param allowedOrigins array = []
param appCommandLine string = ''
param applicationInsightsName string = ''
param appServicePlanId string
@secure()
param appSettings object = {}
param keyVaultName string
param serviceName string = 'api'
@secure()
param userassignedmanagedidentityId string

module api '../core/host/appservice.bicep' = {
  name: '${name}-app-module'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    allowedOrigins: allowedOrigins
    appCommandLine: appCommandLine
    applicationInsightsName: applicationInsightsName
    appServicePlanId: appServicePlanId
    appSettings: appSettings
    keyVaultName: keyVaultName
    runtimeName: 'dotnetcore'
    runtimeVersion: '8.0'
    scmDoBuildDuringDeployment: false
    userassignedmanagedidentityId: userassignedmanagedidentityId
  }
}

output SERVICE_API_NAME string = api.outputs.name
output SERVICE_API_URI string = api.outputs.uri
