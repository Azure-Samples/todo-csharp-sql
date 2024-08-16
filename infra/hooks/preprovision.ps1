#!/usr/bin/env pwsh
Write-Host "Loading azd .env file from current environment"
foreach ($line in (& azd env get-values)) {
    if ($line -match "([^=]+)=(.*)") {
        $key = $matches[1]
        $value = $matches[2] -replace '^"|"$'
	    [Environment]::SetEnvironmentVariable($key, $value)
    }
}

$clientID = (az ad user show --id $AZURE_PRINCIPAL_ID | ConvertFrom-Json).id
azd env set clientID $clientID