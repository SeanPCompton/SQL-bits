/* Example: Privacy-safe household candidate generation to bridge product gaps

   Context:
   At the time this was written, the core product did not provide reliable
   household-level grouping for records with inconsistent source schemas.
   This SQL-based approach was introduced as a controlled workaround to:
     - Normalize highly variable customer inputs
     - Enable downstream analysis without exposing raw PII
     - Unblock reporting and migration needs while product improvements
       were in progress

   Intent:
   This logic is deliberately scoped and rule-based. It is not a replacement
   for a full identity graph or in-product resolution system.

   Rollback / Decommission Plan:
   - Once the product-level householding or identity service is available:
       * Remove candidate_households and downstream consumers
       * Replace joins with the product-provided household / identity key
       * Retain normalization logic only if still required upstream
   - Historical backfills should be re-keyed using the authoritative product
     identifier to avoid dual household definitions

   QA / Governance Notes:
   - Uses deterministic hashing to avoid exposing raw PII in joins or outputs
   - Hashing strategy should align with security guidance (salting / tokenization)
   - OR-based matching can increase false positives; outputs should be treated
     as candidates and validated before operational use
   - Monitor match rates, fan-out, and unexpected growth in household sizes
*/

WITH cleaned_data AS (
    -- Step 1: Normalize source fields to reduce drift from free-form inputs
    SELECT
          ShopperID
        , TRIM(UPPER(COALESCE(NULLIF(FirstName, ''), 'UNKNOWN'))) AS first_name
        , TRIM(UPPER(COALESCE(NULLIF(LastName,  ''), 'UNKNOWN'))) AS last_name
        , TRIM(UPPER(COALESCE(NULLIF(Address,   ''), 'UNKNOWN'))) AS cleaned_address
        , REGEXP_REPLACE(
              TRIM(COALESCE(NULLIF(PhoneNumber, ''), 'UNKNOWN'))
            , '[^0-9]'
            , ''
          ) AS cleaned_phone
    FROM Shoppers
)

, hashed_data AS (
    -- Step 2: Hash sensitive attributes so no raw PII appears in joins or outputs
    SELECT
          ShopperID
        , first_name
        , last_name
        , SHA2(cleaned_address, 256) AS hashed_address
        , SHA2(cleaned_phone,   256) AS hashed_phone
    FROM cleaned_data
)

, candidate_households AS (
    -- Step 3: Generate candidate household links using shared address or phone
    -- A < B ordering prevents mirrored pairs and limits join explosion
    SELECT
          A.ShopperID AS shopper_id_1
        , B.ShopperID AS shopper_id_2
        , A.hashed_address
        , A.hashed_phone
    FROM hashed_data A
    JOIN hashed_data B
      ON A.ShopperID < B.ShopperID
     AND (
            A.hashed_address = B.hashed_address
         OR A.hashed_phone   = B.hashed_phone
         )
)

, deduped_households AS (
    -- Step 4: De-duplicate as a defensive measure for rule-based matching
    SELECT DISTINCT
          shopper_id_1
        , shopper_id_2
        , hashed_address
        , hashed_phone
    FROM candidate_households
)

-- Step 5: Output privacy-safe candidate household relationships
SELECT
      shopper_id_1
    , shopper_id_2
    , hashed_address
    , hashed_phone
FROM deduped_households
ORDER BY
      shopper_id_1
    , shopper_id_2
;
