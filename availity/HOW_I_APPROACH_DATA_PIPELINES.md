# How I Approach Data Pipelines

This folder is a small set of examples, but the bigger point is how I think about building data systems that don’t fall apart as tenants, volume, and requirements grow.

I tend to optimize for reliability and change rather than cleverness.


Most data problems I’ve worked on weren’t caused by missing tools — they were caused by
systems growing faster than their original assumptions.

## Principles I Default To

- **Boring upstream, opinionated downstream.**  
  Keep core data tall, normalized, and auditable; reshape at the reporting or feature edge where consumers actually need it.

- **Contracts before heroics.**  
  Define grain, keys, required fields, and aggregation rights explicitly so downstream users can rely on stability instead of tribal knowledge.

- **Secure by default.**  
  Treat tenant isolation and PII handling as first-class design constraints, not add-ons or afterthoughts.

- **Config over forks.**  
  Prefer tenant-specific configuration (windows, table allow-lists, feature flags) over copying pipelines or notebooks.

- **Operational reality wins.**  
  Monitoring, backfills, and “what happens at 2am” are part of the design, not things to bolt on later.


## How I Map This to the Stack (SQL → Parquet/Blob → Databricks → Reporting)

Practically this usually means...

### Tenant isolation and aggregation rights
- **SQL sources:** include `tenant_id` (and optionally `group_id`) as explicit columns and keep a clear mapping table for aggregation rights.
- **Landing (Blob/ADLS):** partition paths by tenant to preserve clean boundaries (e.g. `.../tenant_id=123/...`), then layer group rollups in curated tables or views.
- **Databricks:** prefer Unity Catalog and table/view ACLs for analyst access; keep tenant-safe views separate from admin/service views.
- **Reporting:** expose only tenant-safe or group-safe datasets; avoid raw tables flowing directly into BI.

### Data quality as a promotion gate
For pipelines, the biggest wins usually come from:
- schema drift detection before jobs break
- null or missing required fields
- duplicate or primary-key integrity checks
- volume and freshness expectations
- reconciliation checks for customer-facing metrics

If a dataset feeds external reporting, I like producing a small QA summary that’s easy to alert on.

### Change management
- **Schema evolution:** allow additive changes where safe; treat breaking type changes as migrations with versioned models.
- **Backfills:** reprocess with idempotent writes and explicit windowing (`as_of_date`) to avoid leakage or double counting.
- **Tenant variance:** keep differences in config tables rather than branching pipelines.


I don’t assume perfect inputs or perfect requirements.
I assume systems will change, customers will grow, and edge cases will appear..edge cases can become future priorities or emerging strategies
The goal is to make those changes safe and unsurprising.

