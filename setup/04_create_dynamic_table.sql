-- Dynamic Table for Real-Time Revenue Metrics
-- Auto-refreshes every minute with aggregated sales data

CREATE OR REPLACE DYNAMIC TABLE JACK.DEMO.REVENUE_METRICS
  TARGET_LAG = '1 minute'
  WAREHOUSE = AICOLLEGE
  AS
SELECT 
    p.category,
    c.customer_segment,
    c.state,
    DATE_TRUNC('month', o.order_date) AS order_month,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity * p.cost) AS cost,
    SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * p.cost) AS profit,
    ROUND(100 * (SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * p.cost)) / 
          NULLIF(SUM(oi.quantity * oi.unit_price), 0), 2) AS profit_margin_pct
FROM JACK.DEMO.ORDER_ITEMS oi
JOIN JACK.DEMO.ORDERS o ON oi.order_id = o.order_id
JOIN JACK.DEMO.PRODUCTS p ON oi.product_id = p.product_id
JOIN JACK.DEMO.CUSTOMERS c ON o.customer_id = c.customer_id
GROUP BY 1, 2, 3, 4;

-- Query example
SELECT * FROM JACK.DEMO.REVENUE_METRICS 
ORDER BY revenue DESC 
LIMIT 10;
