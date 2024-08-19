# #!/usr/bin/env pwsh

# Disable progress bars
$ProgressPreference = 'SilentlyContinue'

Write-Host "Downloading sqlcmd"
Invoke-WebRequest -Uri "https://github.com/microsoft/go-sqlcmd/releases/download/v1.8.0/sqlcmd-windows-amd64.zip" -OutFile "sqlcmd-windows-amd64.zip"
expand-Archive -Force sqlcmd-windows-amd64.zip .

Write-Host "Running commands as:"
az account show
$az_account = (az account show | ConvertFrom-Json)

if ($az_account.user.type -eq "user") {
    Write-Host "Given MSI api App permission to access the database running as user"
    Write-Host "sqlcmd -S $env:SQLSERVERFQDN -d $env:SQLDATABASENAME --authentication-method ActiveDirectoryDefault -v MSIapiAppName=$env:MSIAPIAPPNAME -i infra\hooks\initDb.sql"
    .\sqlcmd -S $env:SQLSERVERFQDN -d $env:SQLDATABASENAME --authentication-method ActiveDirectoryDefault -v MSIapiAppName=$env:MSIAPIAPPNAME -i infra\hooks\initDb.sql
}
elseif ($az_account.user.type -eq "servicePrincipal") {
    Write-Host "Given MSI api App permission to access the database running as MSI"
    Write-Host "sqlcmd -S $env:SQLSERVERFQDN -d $env:SQLDATABASENAME --authentication-method ActiveDirectoryManagedIdentity -U $env:AZURE_PRINCIPAL_ID -v MSIapiAppName=$env:MSIAPIAPPNAME -i infra\hooks\initDb.sql"
    .\sqlcmd -S $env:SQLSERVERFQDN -d $env:SQLDATABASENAME --authentication-method ActiveDirectoryManagedIdentity -U $env:AZURE_PRINCIPAL_ID -v MSIapiAppName=$env:MSIAPIAPPNAME -i infra\hooks\initDb.sql
}
