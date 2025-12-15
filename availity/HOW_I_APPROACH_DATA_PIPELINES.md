# How I Approach Data Pipelines

I tend to optimize for reliability and change rather than cleverness.

Most data problems I’ve worked on weren’t caused by missing tools — they were caused by
systems growing faster than their original assumptions.

At a high level, I try to:

- Keep core data flexible and boring (normalized, auditable, easy to backfill)
- Push reshaping and opinionated logic to the edges where users actually need it
- Make pipelines repeatable before making them fast
- Prefer configuration over forking when behavior needs to vary by customer or tenant
- Treat data scientists and analysts as customers of the platform

Practically, this usually means:

- Schema and data quality checks early, before data is promoted
- Clear contracts around grain, keys, and aggregation rights
- Privacy-safe handling of sensitive fields (hashing/tokenization where appropriate)
- Lightweight observability so failures are obvious and debuggable
- Temporary workarounds that are clearly scoped and easy to remove once product solutions exist

I don’t assume perfect inputs or perfect requirements.
I assume systems will change, customers will grow, and edge cases will appear.
The goal is to make those changes safe and unsurprising.
