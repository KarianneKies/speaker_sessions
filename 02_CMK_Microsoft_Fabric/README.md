# Customer Managed Keys in Microsoft Fabric

**Speaker:** [Karianne Kies](https://www.linkedin.com/in/kariannekies)

---

## Presented At

| Event | Date |
|---|---|
| Data Saturday Rheinland 2026 | 11 July 2026 |
| Data Saturday Oslo 2026 | 29 August 2026 |

---

## Overview

Microsoft Fabric encrypts all data at rest by default using Microsoft-managed keys. For organisations subject to regulatory frameworks (GDPR, NIS2, DORA) or internal sovereignty mandates that require demonstrable control over key lifecycle, **Customer Managed Keys (CMK)** add a second encryption layer — your key, in your vault.

This session covers what CMK actually gives you, where the boundaries are, and how to set it up and operate it in production.

---

## How It Works

CMK uses **envelope encryption** (also called key wrapping):

```
Your Data
    │
    ▼
Fabric DEK  ← encrypts your data (Layer 1, Fabric-managed)
    │
    ▼
Your CMK in Azure Key Vault / Managed HSM  ← wraps the DEK (Layer 2, you manage)
```

To access your data, Fabric must call your key store to unwrap the DEK. Every wrap and unwrap operation is logged. The key never leaves your vault.

---

## What CMK Gives You

| Capability | Detail |
|---|---|
| Cryptographic control | You set the rotation schedule; revoke access by disabling the key |
| Audit trail | Every wrap / unwrap logged in Key Vault diagnostic logs |
| Key residency | Key material stays in the Azure region you choose |
| Revocation | Fabric loses access within ~1 hour of key disable |

**What CMK does not give you:** CMK controls key residency, not data residency. Your data lives where your Fabric capacity is hosted. In-memory query caches are encrypted with Microsoft's keys and cleared after each session.

---

## Prerequisites

| Requirement | Details |
|---|---|
| Fabric Tenant Admin access | To enable CMK in tenant settings |
| Azure subscription | To create Key Vault and assign RBAC |
| Azure CLI | For scripts 01–03 |
| Az PowerShell module | For script 04 |
| Log Analytics workspace | For audit log queries (script 05) |

---

## Demo: Step-by-Step

### Step 1 — Enable CMK in Fabric Tenant Settings

In the Fabric Admin Portal:
**Settings → Admin Portal → Tenant Settings → Encryption → Customer Managed Keys → Enable**

This makes CMK available to workspace admins and registers the **Fabric Platform CMK** service principal in your Entra ID tenant.

### Step 2 — Create and configure Key Vault

```bash
bash scripts/01_keyvault_setup.sh
```

Creates a Key Vault with:
- Soft delete enabled (Fabric hard prerequisite)
- Purge protection enabled (Fabric hard prerequisite)
- Diagnostic settings sending `AuditEvent` logs to Log Analytics

### Step 3 — Grant Fabric access to the vault

```bash
bash scripts/02_rbac_assignment.sh
```

Assigns the **Crypto Service Encryption User** role to the Fabric Platform CMK service principal. This role provides exactly three permissions: read key metadata, wrap key, unwrap key. Fabric cannot create, delete, or export keys.

### Step 4 — Create RSA key and configure rotation

```bash
bash scripts/03_create_rsa_key.sh
```

Creates an RSA-2048 key and sets automatic quarterly rotation. Outputs the **versionless key URI** — use this in Fabric so new key versions are detected automatically without reconfiguration.

> Keep the previous key version enabled for at least 24 hours after rotation. Fabric checks for new versions on a daily cycle.

### Step 5 — Activate CMK on the workspace

Via the Fabric workspace settings UI:
**Workspace Settings → Security → Encryption → Paste the versionless key URI**

Or via PowerShell / Fabric REST API:

```powershell
.\scripts\04_workspace_cmk.ps1 `
    -WorkspaceId "<your-workspace-guid>" `
    -KeyVaultKeyUri "https://<vault>.vault.azure.net/keys/<key-name>"
```

> The workspace must only contain CMK-supported item types. Check the [current supported items list](https://learn.microsoft.com/fabric/security/customer-managed-keys) before activating.

### Step 6 — Audit key access

Run the KQL queries in `scripts/05_audit_key_access.kql` against your Log Analytics workspace to verify the audit trail and set up access-failure alerts.

---

## Repository Contents

```
02_CMK_Microsoft_Fabric/
├── README.md
└── scripts/
    ├── 01_keyvault_setup.sh      Azure CLI — create Key Vault with required settings + audit logging
    ├── 02_rbac_assignment.sh     Azure CLI — grant Fabric service principal Crypto Service Encryption User
    ├── 03_create_rsa_key.sh      Azure CLI — create RSA key, configure auto-rotation, output versionless URI
    ├── 04_workspace_cmk.ps1      PowerShell — enable CMK on workspace via Fabric REST API
    └── 05_audit_key_access.kql   KQL — audit trail, failure alerts, and volume baseline queries
```

---

## Key Rotation in Production

Use automatic rotation (script 03 configures quarterly). Because the versionless URI is used, Fabric picks up new versions on its daily check cycle — no Fabric reconfiguration required and no downtime for end users.

---

## Key Revocation

Disabling the key in Key Vault causes Fabric to lose access to workspace data within ~1 hour. The bytes remain on Microsoft infrastructure but are unreadable without the key.

- **Soft delete** gives a recovery window (default 90 days) — re-enable the key to restore access
- **After the purge protection window expires**, permanent deletion makes recovery impossible

Some regulatory frameworks accept cryptographic erasure via key deletion as equivalent to data deletion. Confirm with your compliance and legal teams before using this as a deletion mechanism.

---

## Operational Considerations

Your Key Vault becomes a **critical dependency**. Plan for:

| Risk | Mitigation |
|---|---|
| Vault unavailable | Azure Monitor alert on Key Vault availability; geo-redundant vault for production |
| Accidental key disable | Restrict Key Vault access with Azure RBAC; require approval for destructive operations |
| Key loss | Soft delete + purge protection always on; backup key material if using Managed HSM |
| Alert on access failure | Use KQL Query 2 from script 05 as an Azure Monitor alert rule |
