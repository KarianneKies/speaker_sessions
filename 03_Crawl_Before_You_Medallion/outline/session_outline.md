# Session Outline & Speaker Notes
## Crawl Before You Medallion: Getting Your First Fabric Platform to Production

**Slot:** 45 min talk + 15 min Q&A (expandable to 60 min — stretch notes marked ★)
**Format:** Slide-driven, no live demo
**Room:** Data Saturday or equivalent Microsoft data community event

---

## Pre-talk checklist

- [ ] Slides on screen, title slide showing before the session starts
- [ ] Know the room's WiFi situation — no live demos, but QR code to repo needs to work for the audience
- [ ] Note the time on the clock you will use for pacing
- [ ] Confirm slide clicker works before the room fills

---

## Section 1 — The Promise and the Pattern
**Target: 8–10 min | Stretch: 12 min ★**

### Opening (2 min)

> *Start on the title slide. Pause before speaking. Let the room settle.*

"I want to start with a question. How many people in this room are currently implementing Microsoft Fabric on a project? Keep your hand up if that project has been live in production for more than six months."

> *Watch the hands. In most rooms, hands drop fast. That gap is your opening.*

"That's the gap I want to talk about today. Not about whether Fabric is good — it is. Not about whether the architectures we build on top of it are correct — they are. I want to talk about why so many implementations get stuck between 'we're starting Fabric' and 'we're live in production.'"

---

### The "for everyone" promise (2 min)

> *Switch to a slide showing Microsoft's "data platform for everyone" positioning — a quote from the Fabric documentation or marketing, or a screenshot of the Fabric homepage.*

"Microsoft positions Fabric as a unified data platform for everyone. And that promise is real. OneLake is genuinely a simplification. The integrated experience across notebooks, pipelines, and Power BI removes real friction. The licensing model, for all its complexity, puts capabilities within reach of projects that could never have justified an Azure Synapse build."

"I believe the promise. My argument today is about what we do next."

---

### The reference architecture, presented honestly (4–6 min)

> *Switch to a diagram of the full medallion reference architecture — built properly, not strawmanned. This slide needs to be dense. The audience should feel the weight of it.*

"Here is what a properly implemented Fabric medallion architecture looks like. I want to show you all of it, because I am not going to argue that any single piece of it is wrong."

Walk through each element:

**Medallion layers:**
- Bronze Lakehouse — raw, immutable, partitioned by ingestion date
- Silver Lakehouse — cleaned, typed, deduplicated, with schema enforcement
- Gold Lakehouse — aggregated business metrics, optimised for semantic model

**Environment separation:**
- Development workspace
- Test workspace
- Production workspace
- Each with its own Lakehouse, pipelines, and semantic models

**DevOps and automation:**
- Git repository — one branch per environment
- Deployment pipelines — parameterised for workspace switching
- Service principals — one per environment for pipeline auth
- Parameter files — connection strings and schema names abstracted per environment

**Governance:**
- Capacity assignment and monitoring
- Sensitivity labels on semantic models
- Workspace access matrix

> *Pause here.*

"This is a real architecture. It scales. It is auditable. It handles multi-team development. If you are building a data platform for a financial services enterprise with a team of eight engineers and a compliance obligation, this is approximately what you should build."

"Count the objects. Three Lakehouses times three environments is nine Lakehouses. Three sets of pipelines. Three sets of notebooks. One Git repository with a branching strategy someone has to maintain. Service principals that someone has to rotate. Capacity planning that someone has to revisit every quarter."

> *Let that land.*

"Now let me show you the project this architecture is being sold to."

---

### ★ Stretch (2 min) — add a "cost of ownership" calculation

Show a rough operational cost estimate: how many hours per month to maintain the full stack for a one-engineer team. Use conservative numbers. The point is visceral, not precise.

---

## Section 2 — The Contradiction
**Target: 5–7 min | Stretch: 8 min ★**

> *Switch to a slide showing a single project profile: one analyst, Power BI Pro license, two source systems, six-week deadline to prove the value of moving to Fabric.*

"This is a real profile. I see it — or something very close to it — at least once a quarter. Mid-market company. They have been running Power BI on top of Excel and a SQL Server instance for three years. The business wants a data platform. The IT budget is a Fabric capacity. The implementation team is one person, possibly two."

---

### The gap made concrete (3 min)

> *Side-by-side slide: reference architecture object count vs. what a one-person team can realistically own.*

"Let's count what we are asking that person to set up, maintain, and troubleshoot:"

| Object | Count |
|---|---|
| Lakehouses | 9 |
| Deployment pipelines | 3 |
| Notebooks (parameterised) | N × 3 environments |
| Git branches to manage | 3 minimum |
| Service principals to rotate | 3+ |
| Workspaces | 6–9 |

"And that is before they have written a single line of business logic. Before they have loaded a single row of data. Before the business has seen a single number they care about."

"This is the contradiction. The platform promise is 'for everyone.' The implementation pattern we hand to everyone requires a team."

---

### Why this happens (2 min)

> *No slide — speak directly to the room.*

"I want to be fair about why this happens, because it is not stupidity. It is several reasonable decisions that compound."

"The reference architecture exists, so we follow it — and there is something professionally comfortable about following a reference architecture. If it goes wrong, you followed the standard."

"The sales process raises expectations. By the time a project has been through a Fabric demo, they have seen the medallion diagram. They expect it."

"And architects — us, the people in this room — we default to building things that scale. We have been burned by under-engineered systems. So we build for the scale we hope the project reaches, not the scale they are at today."

"The result is a platform that takes three to four months to get to a first output, exhausts the implementation budget before the business has seen any value, and leaves the project with a system nobody fully understands. And then we wonder why adoption is slow."

---

### ★ Stretch (1 min) — add a quote or anonymised project moment

A brief, direct line from a project team in this situation: "We spent two months on the DevOps setup and never got to the data."

---

## Section 3 — The Project Story
**Target: 12–15 min | Stretch: 18 min ★**

> *This section is the heart of the talk. Do not rush it. The audience needs to believe the outcome before the framework section will land.*

> *[SPEAKER NOTE: Verify all details against your firm's client confidentiality guidelines before finalising. Use the anonymised version below as a template and fill in specifics you have confirmed are safe to share publicly.]*

---

### Setting the scene (2 min)

> *Switch to a slide that shows only the project profile — no logos, no identifiable details.*

"I want to tell you about an engagement I led. I'm going to anonymise the project, but I am going to be specific enough that the decisions are real."

"Mid-market asset manager. Portfolio data coming from two places: a portfolio management system and a collection of Excel files maintained by the operations team. Power BI was already in use, but the reports behind it were rebuilt manually every month by an analyst who spent a week each time just assembling the data. The goal: get that process automated and governed in Fabric, live to the business within two months."

"The team delivering it: me, and one client-side analyst who was going to own the platform after handover. That's it."

> *Pause here — let the room do the math.*

"An asset manager. Financial services. The kind of project you might assume needs the full architecture from day one."

---

### What the reference architecture wanted us to build (3 min)

> *Switch to the full architecture diagram from Section 1, reprised.*

"We scoped the engagement against the reference architecture. Here is what a proper implementation would have looked like."

Walk through what was in the initial scope:
- Three environments
- Full medallion
- Git integration
- Deployment pipelines
- Parameterised notebooks

"Properly scoped, the full reference architecture would have taken significantly longer than two months to deliver and stabilise. We did not have that runway. And more importantly — I did not think we needed it."

---

### The conversation (2 min)

> *Speak directly, no slide.*

"Here is the conversation I had with the client. And I want to say it plainly: this is the conversation that is hard to have, because it sounds like you are arguing for less."

"I said: 'Here is the full architecture. Here is what it will take to build it and maintain it after we leave. And here is what I think you actually need to get to production within your timeline and budget. I want you to choose.'"

"They chose the simpler version — not because they did not understand what they were giving up, but because they understood exactly what they were giving up and decided it was the right trade."

---

### What we built instead (4 min)

> *Switch to the simplified architecture diagram — two Lakehouses, one workspace, no Git, no pipelines yet.*

"Here is what we built:"

Walk through the simplified architecture:
- **One Fabric workspace** — no environment separation yet
- **Two Lakehouses** — a landing zone (raw files as-is from source) and a transform layer (clean, typed, business-ready)
- **Notebooks** — not parameterised; connection strings in a config section at the top
- **One semantic model** — built directly on the transform layer
- **Power BI reports** — published to the workspace

"No Git. No deployment pipelines. No service principals in week one. A manual notebook export at each milestone to serve as backup."

---

### What we cut and why it was safe to cut (3 min)

> *New slide: a table of what was cut, with the explicit reason.*

| Cut | Why it was safe |
|---|---|
| Dev/Test/Prod separation | One engineer + one analyst. No parallel development. No release approval process. |
| Git integration | No second engineer. Notebook exports at milestones provided acceptable rollback. Agreed to add Git when second engineer joined. |
| Deployment pipelines | No environment separation means no pipeline to automate. |
| Parameterised notebooks | Notebooks running in one environment. Nothing to parameterise. |
| Service principals | Single engineer is sole operator. Risk accepted by client in writing. Scheduled for handover sprint. |
| Gold aggregation layer | Power BI semantic model handled aggregation logic. No performance problem justified a separate layer. |

"None of these decisions are permanent. Each one has a named trigger — a specific condition that will cause us to add that element. Those triggers are in the delivery documentation."

---

### The outcome (2 min)

> *New slide: a simple "before / after" or timeline.*

"The platform went live within eight weeks. The monthly reports that had previously taken the analyst a week to build manually were now automated. She ran the notebooks, the data landed, the reports refreshed. Same analyst, one person, maintaining it independently after handover."

"The week she used to spend assembling data she now spends analysing it."

> *Pause.*

"That is the outcome. Not a technical outcome — a business outcome. And I want to be direct: if we had spent the first six weeks setting up three environments, Git integration, and service principals, we would not have shipped within the two-month window. The business would have waited longer, the analyst would have had less time to build familiarity with the platform, and the engagement would have ended with a system that was architecturally impressive and operationally unfamiliar to the person who had to own it."

"The business has been using this data platform since then. If we had built the full reference architecture, there is a real chance the project would have stalled before they ever saw a number."

---

### ★ Stretch (3 min) — add the counter-example

Briefly describe (anonymised) what happened at a different engagement where the full reference architecture was implemented from day one. What broke down. What it cost. How long before first output.

---

## Section 4 — The Bridge to Medallion
**Target: 8–10 min | Stretch: 12 min ★**

> *This section is what saves the talk from being read as "just don't do medallion." It must land with equal force.*

---

### The framework (4 min)

> *Switch to the readiness framework slide — the four axes and the trigger table.*

"I want to give you something you can use on Monday. Not a philosophy — a decision tool."

"Four axes. Score each one zero, one, or two for your specific project. The axis scores tell you which architectural elements earn their place now."

Walk through the axes — briefly, one sentence each:

- **Team capacity:** How many data engineers are there, and do they work in parallel?
- **Data volume and velocity:** How many source tables, how fast does data arrive, how large?
- **Regulatory and compliance pressure:** Is there a formal audit obligation, a GDPR right-to-erasure requirement, data residency?
- **Rate of change:** How often do source schemas change, how quickly are new sources being added?

"Then for each architectural element — bronze, silver, gold, dev/test/prod, Git, pipelines, service principals — there is a minimum axis score combination that justifies adding it."

> *Walk through two or three examples using scores from the audience's actual situations.*

"If your project scores zero on all four axes, the simple architecture I just described is not a compromise. It is the correct architecture for those conditions."

---

### The trigger signals (3 min)

> *Switch to a slide listing the upgrade triggers — these are the moments when a project outgrows the simple architecture.*

"These are the events that should cause you to schedule an architecture review:"

| Trigger | Element to add |
|---|---|
| A second data engineer joins the team | Git integration, then deployment pipelines |
| A second source system lands with different load patterns | Consider bronze separation; definitely add monitoring |
| Power BI reports slow down noticeably at business hours | Gold aggregation layer, capacity review |
| A compliance requirement appears (audit, GDPR, data residency) | Service principals, environment separation, lineage |
| The project acquires another company | Full architecture review against new axis scores |
| Someone asks "what changed last week?" and nobody can answer | Git — now |

"These are not hypothetical. Each of these is a trigger I have seen in practice. Build them into your delivery plan as named milestones. 'When event X occurs, we will schedule a sprint to add element Y.' That is not technical debt. That is a planned progression."

---

### The migration is cheaper than you think (2 min)

> *Speak directly, no slide.*

"The question I always get here is: 'But what does the migration actually look like?' So let me be specific."

"You are going from two Lakehouses to three. You create the gold Lakehouse. You write a notebook that reads from silver and writes the aggregations. You update the semantic model to use gold for those measures. Everything else is unchanged. That is a sprint of work, not a rewrite."

"You are going from no Git to Git. You connect the workspace to a repository. You commit the current state of your notebooks. You define a branching strategy. That is a day of work."

"The migrations are cheap because the simple architecture was not carelessly built — it was deliberately built to be extensible. The difference between 'technical debt' and 'planned extensibility' is documentation and intent."

---

### ★ Stretch (2 min) — the growth curve visualised

Show a simple timeline: Month 1–3 simple architecture, Month 4 second engineer joins (Git added), Month 6 second source system (bronze separated), Month 12 compliance requirement (full medallion). The point: each layer was added when it earned its place, not before.

---

## Section 5 — Close
**Target: 3–5 min**

> *Switch to a closing slide — minimal text. The title. One sentence. Your name.*

---

### The reframe (2 min)

"Medallion is not an architecture. It is a destination."

"The bronze/silver/gold pattern describes what a mature, multi-team, high-volume data platform looks like when it has found its shape. It does not describe what a data platform should look like on day one."

"The architect's job — our job — is to right-size the architecture to the conditions the project is actually in, not the conditions we hope they reach. That requires judgment, and it requires courage, because recommending something simpler will always feel like recommending something lesser."

"It is not."

---

### The promise, revisited (1 min)

"Fabric's 'for everyone' promise is real but fragile. It is real because the platform genuinely lowers the barrier. It is fragile because we can raise the barrier right back up with the architecture we choose to layer on top."

"Every project who reaches production on a simple architecture has a better chance of becoming the project who eventually needs the full medallion. Every project who runs out of budget in month three before they ever reached production is a project who does not come back."

"The best thing we can do for Fabric adoption — and for our projects — is get them to production."

---

### Close line

> *Pause. Make eye contact with the room.*

"Crawl before you medallion."

> *Stop. Let the room react. Do not add anything after the close line.*

---

## Q&A — 15 min

> *See objection_map.md for prepared responses to the most likely pushback.*

**Framing for Q&A intro:** "I want to hear from people who disagree with me more than from people who agree. If you think I got something wrong, this is the time."

**Timekeeping:** Leave 2 minutes at the end of Q&A to close with the repo QR code and your contact details.

---

## Close-out slide

- QR code linking to this repository
- LinkedIn URL
- "The framework is in the repo" — one sentence

---

## Timing Summary

| Section | 45-min slot | 60-min slot |
|---|---|---|
| Section 1 — The Promise and the Pattern | 9 min | 12 min ★ |
| Section 2 — The Contradiction | 6 min | 8 min ★ |
| Section 3 — The Project Story | 13 min | 18 min ★ |
| Section 4 — The Bridge to Medallion | 9 min | 12 min ★ |
| Section 5 — Close | 4 min | 4 min |
| Buffer | 4 min | 6 min |
| **Talk total** | **45 min** | **60 min** |
| Q&A | 15 min | 15 min |

---

## Slide Count Guide

| Section | Suggested slides |
|---|---|
| Opening + promise | 2 |
| Reference architecture (full) | 1 (dense) |
| Cost of ownership ★ | 1 |
| Project profile | 1 |
| Object count table | 1 |
| Why this happens | 0 (spoken) |
| Project story — scene | 1 |
| Project story — what we built | 1 (simplified diagram) |
| What we cut table | 1 |
| Outcome | 1 |
| Counter-example ★ | 1 |
| Readiness framework | 1–2 |
| Trigger signals table | 1 |
| Migration is cheap | 0 (spoken) |
| Growth curve ★ | 1 |
| Close | 1 |
| Repo / contact | 1 |
| **Total (base)** | **~14 slides** |
| **Total (with stretch)** | **~18 slides** |
