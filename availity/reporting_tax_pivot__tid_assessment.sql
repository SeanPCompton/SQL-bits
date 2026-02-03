/* Pivot table data for a list of columns provided as variables.
   Converts tax_month values into columns for a bounded, client-facing report.

   Example of Jinja-templated SQL used for dynamic inclusion in migration
   and reconciliation work.

   Client-facing use case, which is why a pivot is appropriate here.
   Live consulting experience with MGM, Wyndham, Nordstrom.
*/

{# Jurisdiction-specific hotel tax example: Tourism Improvement District (TID) assessment #}
{% set hotel_tax_type = 'tourism_improvement_district_assessment' %}

{# Reporting months required by contract / finance stakeholders #}
{% set metrics = ['2025-01', '2025-02', '2025-03'] %}

SELECT *
FROM (
  SELECT
    region,
    tax_month,
    value
  FROM tax_metrics
  WHERE tax_type = '{{ hotel_tax_type }}'
) s
PIVOT (
  SUM(value) FOR tax_month IN (
    {% for m in metrics %}
      '{{ m }}' AS tax_{{ m | replace('-', '_') }}{% if not loop.last %}, {% endif %}
    {% endfor %}
  )
) p;

-- Pivot components:
  -- Grouping dimension: region
  -- Pivot key: tax_month (becomes columns)
  -- Aggregation: SUM(value)

-- Design note:
  -- Core data remains tall upstream for flexibility and auditability.
  -- Pivoting is applied only at the reporting edge and parameterized
     to support controlled change.


/* =====================================================================
   OPTIONAL ALTERNATIVE — CONDITIONAL AGGREGATION (PORTABLE PATTERN)

   Equivalent output using CASE-based aggregation.
   Preferred in engines without native PIVOT support or when diff
   clarity and portability matter more than syntax convenience.
=====================================================================

SELECT
  region,
  {% for m in metrics %}
    SUM(CASE WHEN tax_month = '{{ m }}' THEN value ELSE 0 END)
      AS tax_{{ m | replace('-', '_') }}{% if not loop.last %}, {% endif %}
  {% endfor %}
FROM tax_metrics
WHERE tax_type = '{{ hotel_tax_type }}'
  AND tax_month IN (
    {% for m in metrics %}
      '{{ m }}'{% if not loop.last %}, {% endif %}
    {% endfor %}
  )
GROUP BY region;

*/


/* =====================================================================
   OPTIONAL ALTERNATIVE — TALL → EDGE PATTERN WITH QA SIGNALS

   Pattern used during migrations and reconciliations:
     - Preserve a normalized base
     - Produce a thin, wide edge for consumption
     - Surface basic indicators to explain deltas and exclusions
=====================================================================

WITH base AS (
  SELECT
    region,
    tax_month,
    value
  FROM tax_metrics
  WHERE tax_type = '{{ hotel_tax_type }}'
),
guardrails AS (
  SELECT
    region,
    COUNT(*) AS row_count,
    COUNT(DISTINCT tax_month) AS distinct_months,
    SUM(CASE
          WHEN tax_month IN (
            {% for m in metrics %}
              '{{ m }}'{% if not loop.last %}, {% endif %}
            {% endfor %}
          )
          THEN 0 ELSE 1
        END) AS out_of_band_rows
  FROM base
  GROUP BY region
),
edge_wide AS (
  SELECT
    region,
    {% for m in metrics %}
      SUM(CASE WHEN tax_month = '{{ m }}' THEN value ELSE 0 END)
        AS tax_{{ m | replace('-', '_') }}{% if not loop.last %}, {% endif %}
    {% endfor %}
  FROM base
  GROUP BY region
)
SELECT
  w.*,
  g.row_count,
  g.distinct_months,
  g.out_of_band_rows
FROM edge_wide w
JOIN guardrails g
  ON w.region = g.region;

*/
