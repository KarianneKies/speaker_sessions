# Objection Map
## Crawl Before You Medallion — On-Stage Responses

Prepared responses to the most likely pushback from a senior architect / MVP / Microsoft-aligned audience. Each entry includes the steelman of the objection (take it seriously), the direct response, and a one-line version for live delivery.

---

## Objection 1: "Isn't this just technical debt you'll have to refactor later?"

**Why this lands hard:** It is the most natural framing for any "start simple" argument. Senior engineers have been burned by "temporary" architectures that ran for a decade.

**Steelman:** Every shortcut you take today is a migration you pay for at the worst possible moment — when the platform is in production, users depend on it, and the team has no slack capacity.

**Response:**
Technical debt is the right word only if the simple architecture prevents you from doing something you will actually need to do. A Bronze–Silver–Gold medallion has three layers; a landing zone plus a transform layer has two. When you add the third layer — and the framework in this session tells you when — you are adding a Lakehouse and a set of notebooks, not rewriting the platform. The data model does not change. The lineage does not break. The consumers do not notice.

The real technical debt in this industry is the fully-specified medallion architecture that never reached production because the project ran out of budget in month three. That debt accrues interest in the form of lost organisational trust in data, and it takes years to recover.

What I am arguing against is not simplicity — it is the confusion of *starting simple* with *staying simple forever*. The framework includes explicit triggers for adding each layer. Build those triggers into your delivery plan. Then you are not accumulating debt; you are executing a planned progression.

**One-liner for stage:** "Technical debt is debt. This is a mortgage with a pre-agreed refinancing schedule."

---

## Objection 2: "Microsoft recommends medallion — who are you to say otherwise?"

**Why this lands hard:** Microsoft staff and MVPs will be in the room. This objection is often unspoken but present.

**Steelman:** Reference architectures exist for good reasons. Microsoft's documentation is written to serve the widest possible audience and the highest-stakes use cases. Following it is a defensible, reasonable choice.

**Response:**
Microsoft recommends medallion for the same reason a car manual tells you to check the oil every 5,000 miles — it is the correct guidance for the designed operating conditions. The manual does not say "only check the oil if you drive more than 10,000 miles per year." It gives you the right maintenance schedule for a car that is actually used.

My argument is not that the reference architecture is wrong. It is that it describes the steady-state operating conditions of a mature data platform, and most projects implementing Fabric for the first time are not there yet. The reference architecture is the destination. I am describing the route.

If a Microsoft architect in this room wants to argue that every Fabric project, regardless of team size or data volume, should implement full medallion on day one, I would be very interested to hear how they define success for a project with one analyst and a two-month deadline.

**One-liner for stage:** "I'm not arguing with Microsoft's architecture. I'm arguing about the timing."

---

## Objection 3: "What about governance and compliance from day one?"

**Why this lands hard:** Regulated industries — finance, healthcare, public sector — genuinely cannot defer governance. The objection is often correct for the person making it.

**Steelman:** If your project is for a bank, GDPR right-to-erasure and financial audit requirements do not care that you are in an MVP phase. Getting governance wrong in a regulated environment is not a refactor; it is a regulatory incident.

**Response:**
This is the most important nuance in the framework. The decision table explicitly includes a regulatory axis, and compliance requirements score a 2 on that axis by definition. If you score a 2 on compliance, you add the elements the compliance requirement mandates — service principals, environment separation, audit-ready lineage — regardless of your score on the other axes.

The framework does not tell you to skip governance. It tells you to add governance components in proportion to actual governance requirements, not in anticipation of governance requirements you may never face.

The project I used in this session was at an asset manager. Financial services. The kind of environment the person asking this question is probably picturing. Here is the distinction that mattered: the data in scope was internal portfolio reporting — operational data consumed by the same analyst who built the platform, not externally reported, not subject to a formal audit trail obligation for the specific dataset involved. The regulatory axis scored a 1, not a 2. GDPR applied, as it does everywhere in Europe, but no formal right-to-erasure or lineage requirement was triggered by the data in scope.

That is the question to ask. Not "is this a regulated industry?" — almost every industry is regulated in some way. Ask: "Does the data in scope trigger a specific compliance requirement that mandates an architectural control?" If the answer is yes — audit trail, right-to-erasure, data residency, formal lineage — you add the control that requirement mandates. You do not add the entire reference architecture pre-emptively because the industry sounds regulated.

There is a real difference between a fund administrator with a quarterly audit obligation on trading data and an asset manager automating internal monthly reporting that has always lived in Excel. The architecture should reflect that difference.

If the data in scope genuinely scores a 2 on the compliance axis, the simple architecture is not for you, and the session says so explicitly.

**One-liner for stage:** "The question isn't whether the industry is regulated. It's whether this data, in this scope, triggers a specific control."

---

### Sub-objection 3a: "But asset managers in Norway are subject to Finanstilsynet and MiFID II — how does that not score a 2?"

**Who asks this:** Someone with specific knowledge of Norwegian or EU financial regulation. Rare but possible at a Nordic-heavy event.

**The distinction:**
MiFID II imposes record-keeping and audit obligations on investment firms — but those obligations attach to transaction records and client-facing reporting, not to internal operational data. The data in scope for this engagement was internal portfolio reporting: aggregated position data consumed by the asset manager's own analyst for internal management purposes. It was not the transaction ledger. It was not client reporting. It was not the data that Finanstilsynet would ask to see in an inspection.

GDPR applied, as it does to all data processing in Norway. But GDPR does not mandate a three-environment architecture or Delta table lineage. It mandates that personal data is processed lawfully, stored securely, and deletable on request. Those requirements were addressed at the Fabric workspace and data sensitivity level, not by adding medallion layers.

**If pressed further:**
"You're right that MiFID II has record-keeping requirements — Article 16 of the directive, five-year retention for communications and transaction records. Those requirements applied to a different system on this project, and that system was already compliant. The Fabric platform was not in scope for those obligations."

> *[SPEAKER NOTE: Only go to this level of detail if the person pushes past your first response. Most rooms will accept the distinction between internal operational data and regulated transaction data without needing the specific article citation. Have it ready; do not lead with it.]*

**One-liner for stage:** "MiFID II covers transaction records and client reporting. This was internal management data. Different obligation, different architecture."

---

## Objection 4: "When the project grows, won't they have to rewrite everything?"

**Why this lands hard:** Architects think in three-to-five year horizons. The word "rewrite" is a trigger.

**Steelman:** An architecture that cannot scale is a liability. If your starting architecture requires a rewrite to evolve, the cost of that rewrite may exceed the cost of doing it right from the beginning.

**Response:**
Let me be specific about what "growing into medallion" actually involves. You have two Lakehouse layers today: a raw landing zone and a clean transform layer. You want to add a gold aggregation layer. What does that migration look like?

You create a third Lakehouse. You add a notebook that reads from silver and writes the aggregations. You update your semantic model to point at gold instead of silver for the measures that need it. Everything else stays the same.

That is not a rewrite. That is an addition.

The harder migration — the one I have seen teams spend months on — is when a project built the full medallion architecture in month one, got the data model wrong because they did not yet understand the business, and now needs to restructure three layers of Delta tables and four deployment pipelines across three environments while the business is actively using the reports. That is the rewrite that kills projects.

You cannot get the data model right until you understand the data. You cannot understand the data until you have worked with it. The simple architecture lets you do that work without incurring the cost of restructuring a system built at enterprise scale before the requirements were stable.

**One-liner for stage:** "Adding a Lakehouse is not a rewrite. Getting the data model wrong across three environments is."

---

## Objection 5: "This only works for small projects. Enterprise always needs medallion from day one."

**Why this lands hard:** Enterprise architects have pattern-matched on scale. Small-project advice feels irrelevant to them.

**Steelman:** Large enterprises have complexity that small projects do not — multiple business units, concurrent data engineering teams, audit obligations, existing tooling to integrate. The overhead of medallion is more manageable when you have a team of ten engineers to absorb it.

**Response:**
Agree — and the framework reflects that. Team capacity axis = 2 means you have three or more data engineers with separate release ownership. At that point, most of the complexity elements earn their place, and the talk says so.

But there are two scenarios worth separating. First: a large enterprise standing up a new Fabric workload for a specific business unit or use case. They have an enterprise team overall, but the team for this workload is two people. The enterprise context does not change the axis scores for this workload.

Second: a large enterprise doing a greenfield Fabric migration with a full team. That team may legitimately score high on all four axes from day one. Fine. The framework tells them to add everything. The talk is not for them.

The audience I am speaking to is the architect who has a project with one analyst and is being asked whether to implement Dev/Test/Prod before they have written their first notebook. That architect is in this room.

**One-liner for stage:** "Enterprise context doesn't change the axis scores for a two-person workload team."

---

## Objection 6: "Without a silver layer, how do you enforce data quality?"

**Why this lands hard:** Data quality is a senior concern. Skipping the cleaning layer sounds like skipping quality entirely.

**Steelman:** Silver exists precisely to apply quality rules once, centrally, so that downstream consumers do not each implement their own version. Removing silver moves quality logic into every report and model, which is worse.

**Response:**
The simple architecture has a transform layer — it is just not called silver. Call it "clean" or "prepared" or "reporting-ready" — the name does not matter. What it contains is the same: type casting, null handling, deduplication, business key resolution. The difference is that it is a single layer that writes directly to the semantic model, not a middle layer that feeds another middle layer.

What the simple architecture does not have is a separate gold layer with pre-aggregated business metrics. That is what gets deferred, not data quality. Quality rules live in the transform layer from day one.

**One-liner for stage:** "The cleaning layer is still there. It just isn't called silver yet."

---

## Objection 7: "You're just describing what Microsoft calls a 'lakehouse pattern' — that's already in the docs."

**Why this lands hard:** It undercuts the novelty of the argument and may be partly correct.

**Steelman:** Microsoft does document simpler patterns for early-stage implementations. If this is already official guidance, the talk may be fighting a straw man.

**Response:**
Yes, Microsoft documents the lakehouse pattern, and it is a good one. My argument is about what actually gets built on the ground, not what the documentation describes. In my experience working on projects implementing Fabric for the first time — and I expect several people in this room have seen the same — the pull toward full medallion is strong. It comes from the sales process, from community blog posts, from architects who want to deliver something enterprise-grade, and from fear of technical debt. The gap between what the documentation allows and what teams actually build is real.

If this talk helps one architect in this room say "we do not need three environments yet" and ship faster as a result, it has done its job, regardless of whether the documentation already permits that choice.

**One-liner for stage:** "The docs allow it. I'm here because teams aren't doing it."

---

## General Principles for Q&A

- **Agree before you redirect.** Almost every objection contains a true premise. Name it before you push back.
- **Use the framework.** If someone describes a scenario, score it on the four axes in real time. This demonstrates that the framework is usable, not just theoretical.
- **Avoid "it depends."** Always follow "it depends" with the specific thing it depends on and the specific threshold.
- **The Microsoft-in-the-room rule.** Never say "Microsoft got it wrong." Always say "the reference architecture is right for steady-state; I'm describing the path to get there."
- **Time cap.** If a question is becoming a debate, offer to continue after the session. "I'd love to keep going on this — find me in the hall."
