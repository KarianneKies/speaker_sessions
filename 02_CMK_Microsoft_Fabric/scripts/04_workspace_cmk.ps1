# Enables Customer Managed Keys on a Microsoft Fabric workspace via the Fabric REST API.
#
# Requirements:
#   - Az PowerShell module  (Install-Module Az)
#   - Authenticated session (Connect-AzAccount)
#   - Workspace admin rights on the target workspace
#   - CMK enabled in Fabric tenant settings (Admin Portal)
#   - Key Vault configured and RBAC assigned (scripts 01–03)
#
# Usage:
#   .\04_workspace_cmk.ps1 -WorkspaceId "<guid>" -KeyVaultKeyUri "<versionless-uri>"

param(
    [Parameter(Mandatory)]
    [string] $WorkspaceId,

    [Parameter(Mandatory)]
    [string] $KeyVaultKeyUri     # versionless URI from 03_create_rsa_key.sh
)

# ---------------------------------------------------------------------------
# 1. Acquire a Fabric API access token from the current Az context
# ---------------------------------------------------------------------------
$tokenResponse = Get-AzAccessToken -ResourceUrl "https://api.fabric.microsoft.com"
$token = $tokenResponse.Token

$headers = @{
    Authorization  = "Bearer $token"
    "Content-Type" = "application/json"
}

# ---------------------------------------------------------------------------
# 2. Verify the workspace exists and list its current encryption state
# ---------------------------------------------------------------------------
Write-Host "Checking workspace $WorkspaceId ..."

$workspace = Invoke-RestMethod `
    -Method Get `
    -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId" `
    -Headers $headers

Write-Host "  Display name : $($workspace.displayName)"
Write-Host "  Current state: $($workspace.workspaceState)"

# ---------------------------------------------------------------------------
# 3. Enable CMK on the workspace
#    The workspace must only contain CMK-supported item types.
#    Unsupported items will block activation — remove or move them first.
#    See: https://learn.microsoft.com/fabric/security/customer-managed-keys
# ---------------------------------------------------------------------------
$body = @{
    encryption = @{
        cmkKeyIdentifier = $KeyVaultKeyUri
    }
} | ConvertTo-Json -Depth 5

Write-Host ""
Write-Host "Enabling CMK ..."
Write-Host "  Key URI: $KeyVaultKeyUri"

Invoke-RestMethod `
    -Method Patch `
    -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId" `
    -Headers $headers `
    -Body $body | Out-Null

Write-Host ""
Write-Host "Done. CMK is now active on workspace '$($workspace.displayName)'."
Write-Host "Fabric will begin re-wrapping DEKs with your key. This is transparent to end users."
Write-Host ""
Write-Host "To disable CMK (reverts to Microsoft-managed keys):"
Write-Host "  Set cmkKeyIdentifier to an empty string or null in a follow-up PATCH."
