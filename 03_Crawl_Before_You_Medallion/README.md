# Crawl Before You Medallion: Getting Your First Fabric Platform to Production

**Speaker:** [Karianne Kies](https://www.linkedin.com/in/kariannekies)

---

## Presented At

| Event | Date |
|---|---|
| TBC | TBC |

---

## Overview

Microsoft Fabric is sold as a "data platform for everyone" — but the reference architectures we layer on top turn it back into an enterprise platform that requires an enterprise team to maintain. Bronze/silver/gold medallion, dev/test/prod environment separation, Git integration, deployment pipelines, parameterised notebooks: implemented properly, this is a significant operational commitment.

For most projects building their first data platform, this complexity kills momentum before they ever reach production.

This session argues for a simpler starting architecture that gets projects to value fast, builds organisational data capability, and evolves into medallion when the complexity actually earns its place. It is a pro-Fabric argument framed as architecture critique — medallion is the right destination for the right project, but it is not the starting line.

---

## Session Structure

| Section | Title | Duration |
|---|---|---|
| 1 | The Promise and the Pattern | 8–10 min |
| 2 | The Contradiction | 5–7 min |
| 3 | The Project Story | 12–15 min |
| 4 | The Bridge to Medallion | 8–10 min |
| 5 | Close | 3–5 min |
| — | Q&A | 15 min |

Total slot: 45–60 min (expandable to 60 min)

---

## Key Takeaways

- The reference architecture is not wrong — it is premature for most first-time Fabric projects.
- A simpler architecture can be production-grade and safe to evolve from.
- Concrete trigger signals tell you when to graduate each layer of complexity.
- The architect's job is to right-size, not to copy reference architectures.

---

## Repository Contents

```
03_Crawl_Before_You_Medallion/
├── README.md
├── outline/
│   ├── session_outline.md          Full section-by-section outline with speaker notes
│   └── objection_map.md            Anticipated pushback and on-stage responses
└── frameworks/
    └── readiness_framework.md      Decision framework: when each layer earns its place
```

---

## Audience

Mid-level data engineers, architects, and consultants implementing Microsoft Fabric for the first time on projects ranging from mid-market to enterprise. Assumes familiarity with Fabric concepts; no live demo.

---

## Tone

Contrarian-but-balanced. Senior consultant with a strong point of view, not a provocateur. Every critique of complexity is paired with a reason someone would reasonably choose it. Pro-adoption, not anti-Microsoft.
