# SQL Examples for Availity...and some notes about me

This folder contains a small, curated set of SQL examples. They reflect how I approach
day-to-day data engineering work: semi-structured source data, downstream consumers,
governance constraints, and systems that are still evolving. I use many other
languages and technologies on a daily basis and can help share those examples further if
helpful or desired. (including even a Cobol script I wrote in 1999...)

These aren’t academic exercises or LeetCode-style problems. Each is one of many
self-contained examples of a pattern I’ve used in production or consulting
contexts, with comments focused on intent, tradeoffs, and operational reality.

- SQL is intentionally generic; minor syntax tweaks may be needed per platform.
- Comments explain *why* decisions were made, not just what the query does.
- Examples are scoped on purpose rather than exhaustive.

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
Most of my work has naturally been proprietary client work or specific to my employer but I've
kept well-used favorites in Git as I have often used them to onboard new
team members or to repeat familiar work. Onboarding and governance are very important topics to me, 
and as a new employee I strive to maintain priority with this point of view especially in the first 90 days
in order best leverage a valuable perspective & time to document and add value to project teams. It is a part
of my DNA rather than a checkbox.

Often my work would expose me directly to clients in addition to working as a platform engineer 
thus I've encountered a wide spectrum of use cases, challenges, customizations and modes of work. I primarily consulted
premier consumer brand type clients (hotels, designer retail, grocery chains, financial institutions) whom ran on tight 
SLA schedules with high priority for identity resolution, fractured data sources, legacy systems, several TB worth of core data, 
real time streaming needs, or required extra help with governance.  My background prior to DE work is 
rich with analyst experience, often with business systems and always with data rich sales/marketing type environments. I have 
comfort speaking to executive business stakeholders and many different types of personas. I am known by my employers for skill with compliance 
such as CCPA, GDPR, SOC2 audits, TTL of data, and HIPAA. As well I have an MBA in Healthcare Administration relevant to 
this industry.

I was personally tasked by the CTO of 2 organizations to work with our most strategic customers and to audit their compliance practices. 
Today my work has accelerated greatly as I leverage AI/ML tools to the best of my ability not only to produce code, but with 
repeated emphasis on governance, onboarding, KB documentation. I've done this both with large enterprise companies (SAP) and
with ambitious startup companies where I had to wear many hats on the job.

All previous clients and employers used multiple cloud environments thus I am very comfortable not only using AZ/AWS/GCP but
switching amongst them quickly, projecting future needs, and leveraging typical tools such as Databricks/Snowflake. I have 
additional code examples for those I may be able to source and share as well if helpful.


