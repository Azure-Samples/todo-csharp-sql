#!/usr/bin/env pwsh
Write-Host "Loading azd .env file from current environment"
foreach ($line in (& azd env get-values)) {
    if ($line -match "([^=]+)=(.*)") {
        $key = $matches[1]
        $value = $matches[2] -replace '^"|"$'
	    [Environment]::SetEnvironmentVariable($key, $value)
    }
}

$az_account = (az account show | ConvertFrom-Json)

if ($az_account.user.type -eq "user") {
    $AZURE_PRINCIPAL_ID = $az_account.user.name
    #az ad user list --filter "mail eq '$($AZURE_PRINCIPAL_ID)'" --query "[0].id" -o tsv
    $clientID = (az ad user list --filter "mail eq '$AZURE_PRINCIPAL_ID'" --query "[0].id" -o tsv)
    #$clientID = (az ad user show --id $AZURE_PRINCIPAL_ID | ConvertFrom-Json).id
}
elseif ($az_account.user.type -eq "servicePrincipal") {
    $AZURE_PRINCIPAL_ID = ($az_account.user.assignedIdentityInfo -split "MSIClient-")[1]
    $clientID = (az ad sp show --id $AZURE_PRINCIPAL_ID | ConvertFrom-Json).id
}

Write-Host "Setting AZURE_PRINCIPAL_ID to $AZURE_PRINCIPAL_ID"
azd env set AZURE_PRINCIPAL_ID $AZURE_PRINCIPAL_ID

Write-Host "Setting clientID to $clientID"
azd env set clientID $clientID