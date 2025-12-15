# High-level data pipeline and tenant isolation model

This diagram shows how I think about multi-tenant data ingestion, isolation,
and promotion from raw data to customer-facing reporting.


```mermaid
flowchart LR
    A["Azure SQL (per component / per tenant or shared)"]
      -->|ADF ingestion| B["Blob / ADLS Landing"]

    B -->|Databricks jobs| C["Bronze (raw, auditable)"]
    C --> D["Silver (clean + conformed)"]
    D --> E["Gold (reporting marts / aggregates)"]
    E --> F["Reporting / BI / DS"]

    G["Aggregation Rights Table (tenant_id, group_id, entitlements)"]
      --> C
    G --> D
    G --> E

    H["Secrets & Key Management (Key Vault + CMK)"]
      --> A
    H --> B

    I["Observability (freshness, volume, failures)"]
      --> B
    I --> C
    I --> D
    I --> E
