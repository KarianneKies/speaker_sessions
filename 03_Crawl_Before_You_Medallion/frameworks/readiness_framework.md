# Architecture Readiness Framework
## Crawl Before You Medallion — Decision Tool

Use this framework before scoping a new Fabric platform engagement. For each architectural element, check whether the trigger conditions are met. If they are not, the element adds cost without value at this stage.

---

## The Four Axes

Score each axis for your project before choosing an architecture. Be honest — score for where the project is today, not where they aspire to be in three years.

| Axis | 0 — Start simple | 1 — Watch this | 2 — Earns its place now |
|---|---|---|---|
| **Team capacity** | 1 data engineer or analyst doing engineering work | 2 DEs, or 1 DE + dedicated governance/analytics role | 3+ DEs with separate release ownership or on-call rotation |
| **Data volume & velocity** | < 5 source tables · batch daily or slower · < 1 M rows total | 5–20 source tables, or near-real-time in one stream | > 20 source tables, streaming, or > 100 M rows per table |
| **Regulatory & compliance pressure** | Internal reporting only · no audit trail required | Some governance expectations · informal lineage desirable | GDPR right-to-erasure · financial audit · data residency · formal lineage required by policy |
| **Rate of change** | Stable source systems · schema changes < once per quarter | Occasional schema drift · 1 new source per quarter | Frequent schema changes · multiple new sources quarterly · > 2 consumer teams with different cadences |

---

## Element-by-Element Decision Table

For each architectural element, the table states what it costs to operate and the minimum axis score combination that justifies adding it.

### Medallion Layers

| Layer | What it buys you | Minimum trigger |
|---|---|---|
| **Raw / Bronze** | Immutable copy of source data; replayability if transformation logic changes | Any one of: > 1 source system · audit trail required · source system access is time-limited or expensive |
| **Cleaned / Silver** | Canonical data types, null handling, deduplication applied once rather than in every report | > 1 consumer of the same source table, OR data quality failures are causing report trust issues |
| **Aggregated / Gold** | Pre-computed business metrics; Power BI semantic layer can be thin | Power BI performance is visibly degraded, OR > 3 reports share the same calculation logic |

**Starting architecture that is safe to ship:** One landing zone (raw files as-is from source) + one transform layer (clean, typed, deduplicated). Two layers, not three. Name them whatever makes sense to the project.

---

### Environment Separation (Dev / Test / Prod)

| Environment split | Minimum trigger |
|---|---|
| **Dev workspace only** (single environment) | Team capacity axis = 0; no SLA; one data engineer who is also the consumer of the data |
| **Dev + Prod** (two environments) | A second person is consuming the data who did not build it, OR there is an implicit uptime expectation even informally stated |
| **Dev + Test + Prod** (three environments) | Formal release approval process required · compliance mandates environment separation · team capacity axis ≥ 2 |

---

### Git Integration

| Minimum trigger | Why it earns its place |
|---|---|
| Second data engineer joins the team | Without a second engineer, Git adds ceremony without the primary benefit (parallel development, PR review) |
| Enterprise governance policy requires source control | Even at team size = 0, governance may mandate this — acknowledge it, implement it, but don't gold-plate the branching strategy |
| Project has an existing Azure DevOps or GitHub tenant they actively use | Low marginal cost to connect; high alignment cost if you skip it and retrofit later |

**Before the trigger:** Use Fabric's built-in notebook checkpointing and manually export notebooks at milestones. Not ideal. Acceptable for 4–6 weeks.

---

### Deployment Pipelines

| Minimum trigger | Notes |
|---|---|
| Dev + Prod split exists AND releases happen more than once per month | Pipelines are a release automation tool. Without regular releases, they are overhead. |
| Team capacity axis ≥ 1 | Someone needs to own and understand the pipeline; a solo engineer maintaining pipelines they barely use is negative ROI |

---

### Service Principals (Non-human authentication)

| Minimum trigger | Notes |
|---|---|
| Any pipeline or scheduled refresh that must survive a person leaving | If a human user's credential is embedded in a scheduled refresh, that refresh breaks the day they leave or change their password |
| Compliance axis ≥ 2 | Regulated environments typically require non-human, auditable service identity for data movement |

**Day-one exception:** For a four-week MVP with a single engineer, a personal access token or user credential is acceptable if the project owner accepts the risk in writing. Revisit at handover.

---

### Parameterised Notebooks

| Minimum trigger | Notes |
|---|---|
| Same notebook runs in more than one environment | Parameterisation exists to avoid duplicating notebooks per environment. Without multiple environments, there is nothing to parameterise. |
| Source connection strings change between runs | If the notebook always connects to the same place, hard-coded strings are simpler and easier to read |

---

### Capacity Planning (Fabric CU allocation)

| Minimum trigger | Notes |
|---|---|
| > 50 concurrent users, or mixed interactive and batch workloads | Burst capacity contention becomes visible only at meaningful user scale |
| Compliance requires workload isolation | If SLA requires that a batch job cannot degrade a report for a senior stakeholder, you need to plan capacity |
| Project is on a shared / trial capacity | Understand the limits before you promise anything about performance |

---

## Quick-Reference Card (One-Page Version)

Ask these five questions. Each "yes" adds one layer of complexity.

| Question | If yes, add… |
|---|---|
| Will more than one person build pipelines? | Git + branching strategy |
| Will more than one person consume this data who did not build it? | Second environment (Dev + Prod) |
| Does the data come from more than one source system? | Bronze (raw) layer |
| Do more than two reports share the same business logic? | Gold (aggregated) layer |
| Will this platform outlast the tenure of any single engineer? | Service principals |

**Zero "yes" answers:** A single Fabric workspace, one Lakehouse, a notebook, a semantic model, and a Power BI report. Ship it.

**One or two "yes" answers:** Add only the elements those answers trigger. Name them simply.

**Three or more "yes" answers:** You are approaching the conditions where a medallion architecture earns its maintenance cost. Plan the migration, do not retroactively shame the starting architecture.

---

## What This Framework Is Not

- It is not an argument against medallion. Medallion is the right destination.
- It is not a shortcut that avoids good engineering. Each element removed is removed for a reason, not removed out of laziness.
- It is not permanent. Every element has a re-evaluation trigger. Build the re-evaluation into your delivery plan.
