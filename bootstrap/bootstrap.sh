#!/bin/bash

set -e

LOCATION="japaneast"
TFSTATE_RG_NAME="rg-tfstate-cicddeployment"
STORAGE_ACCOUNT="strgaccttst2jhdgfcashjk"

echo ">>> Creating resource group for Terraform state..."
az group create \
  --name "$TFSTATE_RG_NAME" \
  --location "$LOCATION"

echo ">>> Creating storage account..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$TFSTATE_RG_NAME" \
  --sku Standard_LRS \
  --min-tls-version TLS1_2

echo ">>> Creating state containers (one per environment)..."
az storage container create --name staging --account-name "$STORAGE_ACCOUNT"
az storage container create --name prod --account-name "$STORAGE_ACCOUNT"

echo ">>> Creating staging Service Principal..."
STAGING_APP=$(az ad app create --display-name "github-tf-staging" --query appId -o tsv)
az ad sp create --id "$STAGING_APP"

echo ">>> Creating prod Service Principal..."
PROD_APP=$(az ad app create --display-name "github-tf-prod" --query appId -o tsv)
az ad sp create --id "$PROD_APP"

SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo ">>> Assigning roles to staging SP..."
# az role assignment create \
#     --assignee "$STAGING_APP" \
#     --role "Contributor" \
#     --scope "/subscriptions/$SUB_ID/resourceGroups/rg-tfstate-cicddeployment"

# az role assignment create \
#   --assignee "$STAGING_APP" \
#   --role "Storage Blob Data Contributor" \
#   --scope "/subscriptions/$SUB_ID/resourceGroups/$TFSTATE_RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"


# echo ">>> Assigning roles to prod SP..."
# az role assignment create \
#     --assignee "$PROD_APP" \
#     --role "Contributor" \
#     --scope "/subscriptions/$SUB_ID/resourceGroups/rg-tfstate-cicddeployment"

# az role assignment create \
#   --assignee "$PROD_APP" \
#   --role "Storage Blob Data Contributor" \
#   --scope "/subscriptions/$SUB_ID/resourceGroups/$TFSTATE_RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"


# --- Staging role assignments ---
az role assignment create \
  --assignee "$STAGING_APP" \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/rg-tfstate-cicddeployment"

az role assignment create \
  --assignee "$STAGING_APP" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$TFSTATE_RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

# --- Prod role assignments ---
az role assignment create \
  --assignee "$PROD_APP" \
  --role "Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/rg-tfstate-cicddeployment"

az role assignment create \
  --assignee "$PROD_APP" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$TFSTATE_RG_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"

echo ">>> Adding OIDC federated credentials..."
az ad app federated-credential create --id "$STAGING_APP" --parameters "{
  \"name\": \"github-main-branch\",
  \"issuer\": \"https://token.actions.githubusercontent.com\",
  \"subject\": \"repo:yoii18/az-bicep-deployment-1:ref:refs/heads/main\",
  \"audiences\": [\"api://AzureADTokenExchange\"]
}"

# az ad app federated-credential create \
#   --id <SP_STAGING_APP_ID> \
#   --parameters '{
#     "name": "github-staging-environment",
#     "issuer": "https://token.actions.githubusercontent.com",
#     "subject": "repo:yoii18/az-bicep-deployment-1:environment:staging",
#     "audiences": ["api://AzureADTokenExchange"]
#   }'

az ad app federated-credential create --id "$PROD_APP" --parameters "{
  \"name\": \"github-production-branch\",
  \"issuer\": \"https://token.actions.githubusercontent.com\",
  \"subject\": \"repo:yoii18/az-bicep-deployment-1:ref:refs/heads/production\",
  \"audiences\": [\"api://AzureADTokenExchange\"]
}"


echo ""
echo "════════════════════════════════════════════"
echo "Bootstrap complete. Save these values as GitHub Secrets:"
echo "AZURE_CLIENT_ID_STAGING  = $STAGING_APP"
echo "AZURE_CLIENT_ID_PROD     = $PROD_APP"
echo "AZURE_TENANT_ID          = $TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID    = $SUB_ID"
echo "TF_STATE_STORAGE_ACCOUNT = $STORAGE_ACCOUNT"
echo "════════════════════════════════════════════"