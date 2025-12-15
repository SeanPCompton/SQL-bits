/* Data quality quick-checks for newly imported / landing data

   Purpose:
   - Fast profile of common ingest issues (duplicates, null/blank required fields, PK integrity).
   - Intended for staging/landing validation before promoting data downstream.

   Governance notes:
   - Returns counts only (no raw values), which reduces exposure risk if sensitive columns exist.
   - In practice, align checks with a documented data contract (PK, required fields, grain).
   - Persist results to a QA log table for auditability and trend tracking.
*/

WITH
duplicate_rows AS (
    /* Duplicate detection across a representative natural key.
       Replace column1/2/3 with the dataset’s true uniqueness contract. */
    SELECT
          column1
        , column2
        , column3
        , COUNT(*) AS duplicate_count
    FROM imported_data
    GROUP BY
          column1
        , column2
        , column3
    HAVING COUNT(*) > 1
),

null_or_blank_values AS (
    /* Required-field completeness check (NULL or whitespace-only).
       TRIM(COALESCE(x,'')) = '' treats NULL and blanks consistently. */
    SELECT
          COUNT(*) AS null_or_blank_count
    FROM imported_data
    WHERE TRIM(COALESCE(column1, '')) = ''
       OR TRIM(COALESCE(column2, '')) = ''
       OR TRIM(COALESCE(column3, '')) = ''
),

singleton_records AS (
    /* Informational: counts IDs that appear exactly once.
       Useful for spotting unexpected sparsity or verifying uniqueness behavior. */
    SELECT
          column1
        , COUNT(*) AS singleton_count
    FROM imported_data
    GROUP BY
          column1
    HAVING COUNT(*) = 1
),

primary_key_issues AS (
    /* Primary key integrity checks:
       - NULL PK values
       - Duplicate PK values */
    SELECT
          'NULL Primary Key' AS issue_type
        , COUNT(*)           AS issue_count
    FROM imported_data
    WHERE primary_key_column IS NULL

    UNION ALL

    SELECT
          'Duplicate Primary Key' AS issue_type
        , COUNT(*)                AS issue_count
    FROM imported_data
    WHERE primary_key_column IN (
        SELECT
              primary_key_column
        FROM imported_data
        GROUP BY
              primary_key_column
        HAVING COUNT(*) > 1
    )
)

-- Consolidated summary report
SELECT
      'Duplicate Rows' AS issue_type
    , COUNT(*)         AS issue_count
FROM duplicate_rows

UNION ALL

SELECT
      'Null or Blank Values' AS issue_type
    , null_or_blank_count    AS issue_count
FROM null_or_blank_values

UNION ALL

SELECT
      'Singleton Records' AS issue_type
    , COUNT(*)            AS issue_count
FROM singleton_records

UNION ALL

SELECT
      issue_type
    , issue_count
FROM primary_key_issues
;
