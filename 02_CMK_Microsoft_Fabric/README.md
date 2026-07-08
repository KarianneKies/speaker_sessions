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

Creates a Key Vault with:
- Soft delete enabled (Fabric hard prerequisite)
- Purge protection enabled (Fabric hard prerequisite)
- Diagnostic settings sending `AuditEvent` logs to Log Analytics

### Step 3 — Grant Fabric access to the vault

Assigns the **Crypto Service Encryption User** role to the Fabric Platform CMK service principal. This role provides exactly three permissions: read key metadata, wrap key, unwrap key. Fabric cannot create, delete, or export keys.

### Step 4 — Create RSA key and configure rotation

Creates an RSA-2048 key and sets automatic quarterly rotation. Outputs the **versionless key URI** — use this in Fabric so new key versions are detected automatically without reconfiguration.

> Keep the previous key version enabled for at least 24 hours after rotation. Fabric checks for new versions on a daily cycle.

### Step 5 — Activate CMK on the workspace

Via the Fabric workspace settings UI:
**Workspace Settings → Security → Encryption → Paste the versionless key URI**

> The workspace must only contain CMK-supported item types. Check the [current supported items list](https://learn.microsoft.com/fabric/security/customer-managed-keys) before activating.

### Step 6 — Audit key access

---
