WITH category_monthly_revenue AS (

    SELECT 
        DATE_TRUNC('month', o.order_date)::DATE AS order_month,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS category_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.status = 'completed'
    GROUP BY 1, 2
),
combined_windows AS (
    SELECT 
        order_month,
        category,
        category_revenue,

        SUM(category_revenue) OVER (PARTITION BY order_month) AS total_monthly_revenue,

        LAG(category_revenue) OVER (PARTITION BY category ORDER BY order_month) AS prev_month_category_rev
    FROM category_monthly_revenue
)
SELECT 
    order_month,
    category,
    category_revenue,

    ROUND((category_revenue / total_monthly_revenue) * 100.0, 2) AS revenue_share_pct,

    ROUND(((category_revenue - prev_month_category_rev) / prev_month_category_rev) * 100.0, 2) AS category_mom_growth_pct
FROM combined_windows
ORDER BY order_month, revenue_share_pct DESC;