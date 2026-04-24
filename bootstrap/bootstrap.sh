#!/bin/bash

set -e

LOCATION="japaneast"
TFSTATE_RG_NAME="rg-tfstate-cicddeployment"
STORAGE_ACCOUNT="storageaccounttest-sjhdgfcashjkd"

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
az storage container create --name "staging" --account-name "$STORAGE_ACCOUNT"
az storage container create --name "prod" --account-name "$STORAGE_ACCOUNT"

echo ">>> Creating staging Service Principal..."
