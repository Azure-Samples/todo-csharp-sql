#!/bin/bash
echo "Loading azd .env file from current environment..."

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF

az_account=$(az account show | jq -r '.user.type')

if [[ $az_account == "user" ]]; then
    AZURE_PRINCIPAL_ID=$(az account show | jq -r '.user.name')
    clientID=$(az ad user list --filter "mail eq '$AZURE_PRINCIPAL_ID'" --query "[0].id" -o tsv)
elif [[ $az_account == "servicePrincipal" ]]; then
    AZURE_PRINCIPAL_ID=$(az account show | jq -r '.user.assignedIdentityInfo' | awk -F 'MSIClient-' '{print $2}')
    clientID=$(az ad sp show --id $AZURE_PRINCIPAL_ID | jq -r '.id')
fi

echo "Setting AZURE_PRINCIPAL_ID to $AZURE_PRINCIPAL_ID"
azd env set AZURE_PRINCIPAL_ID $AZURE_PRINCIPAL_ID

echo "Setting clientID to $clientID"
azd env set clientID $clientID