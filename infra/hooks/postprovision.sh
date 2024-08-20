#!/bin/bash

echo "Downloading sqlcmd"
wget https://github.com/microsoft/go-sqlcmd/releases/download/v1.8.0/sqlcmd-linux-amd64.tar.bz2
tar x -f sqlcmd-linux-amd64.tar.bz2 -C .

echo "Running commands as:"
az account show
az_account=$(az account show | jq -r '.user.type')

if [[ $az_account == "user" ]]; then
    echo "Given MSI api App permission to access the database running as user"
    echo "sqlcmd -S $SQLSERVERFQDN -d $SQLDATABASENAME --authentication-method ActiveDirectoryDefault -v MSIapiAppName=$MSIAPIAPPNAME -i infra/hooks/initDb.sql"
    ./sqlcmd -S $SQLSERVERFQDN -d $SQLDATABASENAME --authentication-method ActiveDirectoryDefault -v MSIapiAppName=$MSIAPIAPPNAME -i infra/hooks/initDb.sql
elif [[ $az_account == "servicePrincipal" ]]; then
    echo "Given MSI api App permission to access the database running as MSI"
    echo "sqlcmd -S $SQLSERVERFQDN -d $SQLDATABASENAME --authentication-method ActiveDirectoryManagedIdentity -U $AZURE_PRINCIPAL_ID -v MSIapiAppName=$MSIAPIAPPNAME -i infra/hooks/initDb.sql"
    ./sqlcmd -S $SQLSERVERFQDN -d $SQLDATABASENAME --authentication-method ActiveDirectoryManagedIdentity -U $AZURE_PRINCIPAL_ID -v MSIapiAppName=$MSIAPIAPPNAME -i infra/hooks/initDb.sql
fi
