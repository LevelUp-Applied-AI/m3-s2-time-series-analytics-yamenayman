WITH daily_metrics AS (
    SELECT 
        o.order_date,
        COUNT(DISTINCT o.order_id) AS daily_orders,
        SUM(oi.quantity * oi.unit_price) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_date
)
SELECT 
    order_date,
    daily_revenue,
    -- حساب المتوسط المتحرك للإيرادات لآخر 7 أيام
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS ma_7d_revenue,
    
    -- حساب المتوسط المتحرك للإيرادات لآخر 30 يوم
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2) AS ma_30d_revenue,
    
    daily_orders,
    -- حساب المتوسط المتحرك لعدد الطلبات لآخر 7 أيام
    ROUND(AVG(daily_orders) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS ma_7d_orders
FROM daily_metrics
ORDER BY order_date;