/* RFM feature build for customer value modeling (DS-friendly engineering artifact)

   Purpose:
   - Generate a stable RFM feature table over a defined lookback window
   - Provide a simple baseline score for prioritization (not a true CLV model)

   Notes:
   - Avoid leakage by anchoring features to an "as_of_date"
   - Recency is measured in days since last purchase (lower is better)
   - Frequency/Monetary are computed over the lookback window
*/

WITH params AS (
    SELECT
          CURRENT_DATE() AS as_of_date
        , DATEADD(day, -365, CURRENT_DATE()) AS lookback_start
)

, tx_window AS (
    SELECT
          t.customer_id
        , t.purchase_date
        , t.purchase_amount
    FROM transactions t
    JOIN params p
      ON t.purchase_date >= p.lookback_start
     AND t.purchase_date <  p.as_of_date
)

, rfm_metrics AS (
    SELECT
          customer_id
        , DATEDIFF((SELECT as_of_date FROM params), MAX(purchase_date)) AS recency_days
        , COUNT(*)                                                     AS frequency_txn
        , SUM(purchase_amount)                                         AS monetary_value
        , AVG(purchase_amount)                                         AS avg_order_value
    FROM tx_window
    GROUP BY customer_id
)

SELECT
      customer_id
    , recency_days
    , frequency_txn
    , monetary_value
    , avg_order_value
    -- Baseline heuristic score for ranking (explicitly not "predicted CLV"):
    , (frequency_txn * avg_order_value)
        * (1.0 / (1.0 + recency_days)) AS baseline_value_score
FROM rfm_metrics
ORDER BY
      baseline_value_score DESC
;
