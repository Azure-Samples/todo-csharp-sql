#!/bin/bash
echo "Loading azd .env file from current environment..."

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF

id=$(az ad user show --id $AZURE_PRINCIPAL_ID | grep id)
noinit="${id//  \"id\": \"}"
clientID="${noinit//\",}"
azd env set clientID $clientID