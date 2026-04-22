param storageAccountName string
param location string
param storageAccountSKU string

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  location: location
  name: storageAccountName
  sku: {
    name: storageAccountSKU
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cold'
    isHnsEnabled: true
  }
}
