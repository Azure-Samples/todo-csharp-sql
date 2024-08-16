#!/usr/bin/env pwsh

Write-Output  "Building contosochatapi:latest..."
az acr build --subscription $env:AZURE_SUBSCRIPTION_ID --registry $env:AZURE_CONTAINER_REGISTRY_NAME --image contosochatapi:latest ./src/ContosoChatAPI/ContosoChatAPI/
$image_name = $env:AZURE_CONTAINER_REGISTRY_NAME + '.azurecr.io/contosochatapi:latest'
az containerapp update --subscription $env:AZURE_SUBSCRIPTION_ID --name $env:SERVICE_ACA_NAME --resource-group $env:RESOURCE_GROUP_NAME --image $image_name
az containerapp ingress update --subscription $env:AZURE_SUBSCRIPTION_ID --name $env:SERVICE_ACA_NAME --resource-group $env:RESOURCE_GROUP_NAME --target-port 8080

# check if it's been executed by User or MSI
# If user execute the following steps if not skip it
# az ad user show --id vsantana_microsoft.com#EXT#@victorhepoca.onmicrosoft.com

wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

#./sqlcmd -S ${DBSERVER} -d ${DBNAME} --authentication-method ActiveDirectoryManagedIdentity -U ${sqlManagedIdentityId} -v MSIapiAppName= -i ./initDb.sql
./sqlcmd -S ${SQLDATABASENAME} -d ${SQLSERVERFQDN} --authentication-method ActiveDirectoryDefault -v MSIapiAppName=${MSIAPIAPPNAME} -i ./initDb.sql
