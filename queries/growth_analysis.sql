-- 1. Month-over-Month Growth
WITH monthly_metrics AS (
    SELECT 
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY 1
),
monthly_growth AS (
    SELECT 
        order_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
        total_orders,
        LAG(total_orders) OVER (ORDER BY order_month) AS prev_month_orders
    FROM monthly_metrics
)
SELECT 
    order_month,
    total_revenue,
    prev_month_revenue,
    ROUND(((total_revenue - prev_month_revenue) / prev_month_revenue) * 100.0, 2) AS revenue_mom_growth_pct,
    total_orders,
    prev_month_orders,
    ROUND(((total_orders::NUMERIC - prev_month_orders) / prev_month_orders) * 100.0, 2) AS orders_mom_growth_pct
FROM monthly_growth
ORDER BY order_month;


-- 2. Quarter-over-Quarter Growth
WITH quarterly_metrics AS (
    SELECT 
        DATE_TRUNC('quarter', o.order_date)::DATE AS order_quarter,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY 1
)
SELECT 
    order_quarter,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_quarter) AS prev_quarter_revenue,
    ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY order_quarter)) / LAG(total_revenue) OVER (ORDER BY order_quarter)) * 100.0, 2) AS revenue_qoq_growth_pct
FROM quarterly_metrics
ORDER BY order_quarter;