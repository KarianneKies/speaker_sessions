#!/usr/bin/env bash
# Grants the Fabric Platform CMK service principal the Crypto Service Encryption User role
# on the Key Vault.
#
# Run AFTER enabling CMK in the Fabric Admin Portal:
#   Admin Portal → Tenant Settings → Encryption → Customer Managed Keys → Enable
# That step registers the "Fabric Platform CMK" application in your Entra ID tenant.
#
# Requirements: Azure CLI, az login completed, Key Vault created by 01_keyvault_setup.sh.

set -euo pipefail

KEY_VAULT_NAME="kv-fabric-cmk"
RESOURCE_GROUP="rg-fabric-cmk"

# ---------------------------------------------------------------------------
# 1. Locate the Fabric Platform CMK service principal
# ---------------------------------------------------------------------------
FABRIC_CMK_SP_OBJECT_ID=$(az ad sp list \
  --display-name "Fabric Platform CMK" \
  --query "[0].id" -o tsv)

if [ -z "$FABRIC_CMK_SP_OBJECT_ID" ]; then
  echo "ERROR: 'Fabric Platform CMK' service principal not found in this tenant."
  echo "Enable CMK in the Fabric Admin Portal first, then re-run this script."
  exit 1
fi

echo "Fabric Platform CMK object ID: $FABRIC_CMK_SP_OBJECT_ID"

# ---------------------------------------------------------------------------
# 2. Assign Crypto Service Encryption User on the vault scope
#
#    This built-in role grants exactly three permissions — nothing else:
#      - Microsoft.KeyVault/vaults/keys/read        (read key metadata)
#      - Microsoft.KeyVault/vaults/keys/wrap/action  (wrap DEK)
#      - Microsoft.KeyVault/vaults/keys/unwrap/action (unwrap DEK)
#
#    Fabric cannot create, delete, export, or rotate keys in your vault.
# ---------------------------------------------------------------------------
KEY_VAULT_RESOURCE_ID=$(az keyvault show \
  --name "$KEY_VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

az role assignment create \
  --role "Crypto Service Encryption User" \
  --assignee-object-id "$FABRIC_CMK_SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --scope "$KEY_VAULT_RESOURCE_ID" \
  --output table

echo ""
echo "RBAC assigned: Crypto Service Encryption User → Fabric Platform CMK"
echo "Next step: run 03_create_rsa_key.sh"
