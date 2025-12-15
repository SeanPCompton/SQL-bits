# SQL Examples (Availity)

This folder contains a small, curated set of SQL examples shared for the
Availity interview process. They reflect how I approach
day-to-day data engineering work: messy source data, downstream consumers,
governance constraints, and systems that are still evolving.

These aren’t academic exercises or LeetCode-style problems. Each file is a
self-contained example of a pattern I’ve used in production or consulting
contexts, with comments focused on intent, tradeoffs, and operational reality.

## Examples

### Reporting Tax Pivot (Client-Facing)
`reporting_tax_pivot__tid_assessment.sql`

Parameterized pivot logic used for client-facing reporting and reconciliation.
Keeps data tall upstream and reshapes only at the edge. Includes commented
alternatives (conditional aggregation, QA-friendly variants) depending on
engine support and review needs.

---

### Candidate Households – PII-Safe Matching
`candidate_households__pii_safe_matching.sql`

Rule-based household candidate generation built to bridge a known product gap.
Normalizes inconsistent inputs, hashes sensitive fields, and produces
privacy-safe candidate links. Includes notes on limitations, QA considerations,
and how this logic would be rolled back once an in-product solution exists.

---

### Ingest QA – Schema Integrity Checks
`ingest_qa__schema_integrity_checks.sql`

Lightweight checks typically run in staging/landing layers to validate incoming
data before promotion. Focuses on duplicates, null/blank required fields, and
primary key integrity. Outputs counts only (no raw values).

---

### RFM Feature Build (DS Handoff)
`rfm_features__baseline_value_score.sql`

RFM-style feature build intended as a handoff to data science workflows.
Anchored to an explicit as-of date to avoid leakage. Produces a simple baseline
ranking score for prioritization, not a full CLV model.

## Notes

- SQL is intentionally generic; minor syntax tweaks may be needed per platform.
- Comments explain *why* decisions were made, not just what the query does.
- Examples are scoped on purpose rather than exhaustive.

