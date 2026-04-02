WITH customer_first_order AS (
    SELECT 
        customer_id,
        order_date AS first_order_date,
        DATE_TRUNC('month', order_date)::DATE AS cohort_month
    FROM (
        SELECT 
            customer_id, 
            order_date,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
        FROM orders 
        WHERE status = 'completed'
    ) sub 
    WHERE rn = 1
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS total_customers
    FROM customer_first_order GROUP BY cohort_month
),
retention_data AS (
    SELECT 
        c.cohort_month,
        COUNT(DISTINCT CASE WHEN o.order_date > c.first_order_date AND o.order_date <= c.first_order_date + INTERVAL '30 days' THEN o.customer_id END) AS retained_30d,
        COUNT(DISTINCT CASE WHEN o.order_date > c.first_order_date AND o.order_date <= c.first_order_date + INTERVAL '60 days' THEN o.customer_id END) AS retained_60d,
        COUNT(DISTINCT CASE WHEN o.order_date > c.first_order_date AND o.order_date <= c.first_order_date + INTERVAL '90 days' THEN o.customer_id END) AS retained_90d
    FROM customer_first_order c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status = 'completed'
    GROUP BY c.cohort_month
)
SELECT 
    s.cohort_month, s.total_customers,
    ROUND(r.retained_30d * 100.0 / s.total_customers, 2) AS retention_30d_pct,
    ROUND(r.retained_60d * 100.0 / s.total_customers, 2) AS retention_60d_pct,
    ROUND(r.retained_90d * 100.0 / s.total_customers, 2) AS retention_90d_pct
FROM cohort_size s JOIN retention_data r ON s.cohort_month = r.cohort_month
ORDER BY s.cohort_month;