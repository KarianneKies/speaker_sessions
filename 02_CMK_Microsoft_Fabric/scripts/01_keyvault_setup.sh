#!/usr/bin/env bash
# Creates an Azure Key Vault configured for use with Microsoft Fabric CMK.
# Requirements: Azure CLI, az login completed, target subscription selected.
#
# Fabric enforces two hard prerequisites on the vault:
#   - Soft Delete enabled (on by default since API version 2021-04-01-preview)
#   - Purge Protection enabled (must be set explicitly)

set -euo pipefail

RESOURCE_GROUP="rg-fabric-cmk"
LOCATION="westeurope"            # change to your preferred region
KEY_VAULT_NAME="kv-fabric-cmk"  # must be globally unique, 3–24 chars

# ---------------------------------------------------------------------------
# 1. Resource group
# ---------------------------------------------------------------------------
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output table

# ---------------------------------------------------------------------------
# 2. Key Vault
#    --enable-purge-protection true   required by Fabric — cannot be disabled later
#    --retention-days 90              soft-delete retention window (7–90 days)
# ---------------------------------------------------------------------------
az keyvault create \
  --name "$KEY_VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --enable-purge-protection true \
  --retention-days 90 \
  --sku standard \
  --output table

# ---------------------------------------------------------------------------
# 3. Diagnostic settings — send AuditEvent logs to a Log Analytics workspace
#    Replace LOG_ANALYTICS_WORKSPACE_ID with your workspace resource ID.
# ---------------------------------------------------------------------------
LOG_ANALYTICS_WORKSPACE_ID="<your-log-analytics-workspace-resource-id>"

KEY_VAULT_RESOURCE_ID=$(az keyvault show \
  --name "$KEY_VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id -o tsv)

az monitor diagnostic-settings create \
  --name "kv-audit-to-law" \
  --resource "$KEY_VAULT_RESOURCE_ID" \
  --workspace "$LOG_ANALYTICS_WORKSPACE_ID" \
  --logs '[{"category":"AuditEvent","enabled":true,"retentionPolicy":{"enabled":false}}]' \
  --output table

VAULT_URI=$(az keyvault show \
  --name "$KEY_VAULT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.vaultUri -o tsv)

echo ""
echo "Key Vault ready."
echo "  Vault URI : $VAULT_URI"
echo "  Next step : run 02_rbac_assignment.sh"
