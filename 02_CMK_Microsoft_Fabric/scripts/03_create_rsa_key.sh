#!/usr/bin/env bash
# Creates an RSA key in Key Vault and configures automatic quarterly rotation.
# Outputs the versionless URI needed for Fabric workspace encryption settings.
#
# Requirements: Azure CLI, az login completed, RBAC assigned by 02_rbac_assignment.sh.

set -euo pipefail

KEY_VAULT_NAME="kv-fabric-cmk"
KEY_NAME="fabric-workspace-key"

# ---------------------------------------------------------------------------
# 1. Create the RSA key
#    RSA-2048 is the minimum Fabric accepts.
#    RSA-3072 or RSA-4096 for stricter compliance requirements.
# ---------------------------------------------------------------------------
az keyvault key create \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$KEY_NAME" \
  --kty RSA \
  --size 2048 \
  --output table

# ---------------------------------------------------------------------------
# 2. Configure automatic rotation
#    Fabric detects new key versions via a daily check cycle.
#    Keep the previous version enabled for at least 24 hours after rotation
#    so there is no gap while Fabric re-wraps the DEKs.
# ---------------------------------------------------------------------------
az keyvault key rotation-policy update \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$KEY_NAME" \
  --value '{
    "lifetimeActions": [
      {
        "action": { "type": "Rotate" },
        "trigger": { "timeAfterCreate": "P90D" }
      },
      {
        "action": { "type": "Notify" },
        "trigger": { "timeBeforeExpiry": "P7D" }
      }
    ],
    "attributes": {
      "expiryTime": "P2Y"
    }
  }'

echo "Rotation policy: rotate every 90 days, notify 7 days before expiry."

# ---------------------------------------------------------------------------
# 3. Output the versionless URI
#    A versionless URI has no version segment at the end, so Fabric picks up
#    new key versions automatically without requiring reconfiguration.
#
#    Versioned  : https://<vault>.vault.azure.net/keys/<name>/<version>
#    Versionless: https://<vault>.vault.azure.net/keys/<name>
# ---------------------------------------------------------------------------
VAULT_URI=$(az keyvault show \
  --name "$KEY_VAULT_NAME" \
  --query properties.vaultUri -o tsv)

VERSIONLESS_KEY_URI="${VAULT_URI}keys/${KEY_NAME}"

echo ""
echo "Copy this URI into Fabric workspace encryption settings:"
echo ""
echo "  $VERSIONLESS_KEY_URI"
echo ""
echo "Next step: run 04_workspace_cmk.ps1 (or configure via Fabric workspace settings UI)"
