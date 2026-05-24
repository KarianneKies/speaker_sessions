# Power BI Dependency Reporting

**Speaker:** [Karianne Kies](https://www.linkedin.com/in/kariannekies)

---

## Presented At

| Event | Date |
|---|---|
| Data Saturday #74 — Data Saturday Denmark | 31 January 2026 |
| Data Saturday #78 — Data Community Austria Day | 23 January 2026 |

---

## Overview

This session demonstrates how to use the **Power BI Admin Scanner API** together with **Microsoft Fabric** to build automated column-level lineage and access control reporting across your entire Power BI tenant.

Instead of manually tracing which database views feed which reports, this approach scans every workspace in bulk and produces two Delta tables you can query and visualize in Power BI itself.

---

## What You Will Build

| Artifact | Description |
|---|---|
| `View_Dependency_Table` | Column-level lineage — maps each Power BI column back to its source view and flags whether it is used in a DAX measure |
| `Access_Control_Table` | Per-report user access rights, including whether the report is distributed via an Org App |

---

## Architecture

```
Azure AD (Service Principal)
        │
        ▼
Power BI Admin Scanner API
        │  scan all workspaces · get dataset schema + lineage
        ▼
Microsoft Fabric Notebook  (nb_api_scan.ipynb)
        │
        ├── View_Dependency_Table  (Delta)
        └── Access_Control_Table   (Delta)
                │
                ▼
        Power BI Reports  (rpt_dependency · rpt_employee · rpt_sales)
```

---

## Prerequisites

| Requirement | Details |
|---|---|
| Microsoft Fabric workspace | Notebook runs in a Fabric Lakehouse environment |
| Azure AD service principal | Needs `Tenant.Read.All` or `Tenant.ReadWrite.All` in the Power BI service |
| Python packages | `msal`, `requests`, `pandas` — available by default in Fabric notebooks |

**Power BI Admin portal — enable both settings:**
- Allow service principals to use read-only Power BI admin APIs
- Enhance admin APIs responses with detailed metadata

---

## Repository Contents

```
01_PowerBI_Dependency_Reporting/
├── README.md
├── notebook/
│   └── nb_api_scan.ipynb       Fabric notebook — scan, flatten, save to Delta
└── reports/
    ├── rpt_dependency.pbix     Dependency lineage report
    ├── rpt_employee.pbix       Employee sample report
    ├── rpt_sales.pbix          Sales sample report
    ├── sm_dependency.pbix      Semantic model — dependency
    ├── sm_employee.pbix        Semantic model — employee
    └── sm_sales.pbix           Semantic model — sales
```

---

## How to Run

1. **Create a service principal** in Azure AD and grant it the Scanner API permissions listed above.
2. **Upload `nb_api_scan.ipynb`** to a Microsoft Fabric Lakehouse notebook.
3. **Fill in your credentials** in the `Configure Authentication` section:
   ```python
   PBI_TENANT_NAME          = "<your-tenant-id>"
   PBI_ADMIN_API_CLIENT_ID  = "<your-client-id>"
   PBI_ADMIN_API_SECRET     = "<your-client-secret>"
   ```
4. **Run all cells** — the notebook scans all workspaces and writes both Delta tables.
5. **Import the `.pbix` files** into your Fabric workspace and connect them to the Delta tables.

---

## Key Concepts Covered

- Power BI Admin Scanner API — workspace scan, status polling, result retrieval
- Chunking large workspace lists to stay within API request limits
- Regex-based M expression parsing to extract source view names and schema references
- DAX measure cross-referencing to identify which columns are actively used
- Writing Pandas DataFrames to Delta tables via PySpark in Microsoft Fabric
- Access control visibility — per-user report rights and Org App distribution flags
