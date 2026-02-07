-- Retail Analytics Semantic View
-- Creates a semantic view for natural language queries via Cortex Analyst

CREATE OR REPLACE SEMANTIC VIEW JACK.DEMO.RETAIL_ANALYTICS_SV
  TABLES (
    customers AS JACK.DEMO.CUSTOMERS PRIMARY KEY (customer_id)
      WITH SYNONYMS = ('clients', 'buyers')
      COMMENT = 'Customer information',
    products AS JACK.DEMO.PRODUCTS PRIMARY KEY (product_id)
      WITH SYNONYMS = ('items', 'inventory')
      COMMENT = 'Product catalog',
    orders AS JACK.DEMO.ORDERS PRIMARY KEY (order_id)
      WITH SYNONYMS = ('purchases', 'transactions')
      COMMENT = 'Customer orders',
    order_items AS JACK.DEMO.ORDER_ITEMS PRIMARY KEY (item_id)
      COMMENT = 'Order line items'
  )
  RELATIONSHIPS (
    orders_to_customers AS orders (customer_id) REFERENCES customers,
    items_to_orders AS order_items (order_id) REFERENCES orders,
    items_to_products AS order_items (product_id) REFERENCES products
  )
  FACTS (
    order_items.quantity AS quantity COMMENT = 'Quantity ordered',
    order_items.line_total AS quantity * unit_price COMMENT = 'Line item total',
    products.unit_price AS unit_price COMMENT = 'Product price',
    products.unit_cost AS cost COMMENT = 'Product cost'
  )
  DIMENSIONS (
    customers.customer_name AS CONCAT(first_name, ' ', last_name) 
      WITH SYNONYMS = ('client name', 'buyer name') 
      COMMENT = 'Full customer name',
    customers.city AS city COMMENT = 'Customer city',
    customers.state AS state COMMENT = 'Customer state',
    customers.customer_segment AS customer_segment 
      WITH SYNONYMS = ('segment', 'tier') 
      COMMENT = 'Premium or Standard',
    customers.signup_date AS signup_date COMMENT = 'Customer signup date',
    products.product_name AS product_name 
      WITH SYNONYMS = ('item name') 
      COMMENT = 'Product name',
    products.category AS category COMMENT = 'Product category',
    orders.order_status AS status 
      WITH SYNONYMS = ('status') 
      COMMENT = 'Order status',
    orders.order_date AS order_date 
      WITH SYNONYMS = ('purchase date', 'transaction date') 
      COMMENT = 'Date order was placed'
  )
  METRICS (
    order_items.total_revenue AS SUM(quantity * unit_price)
      WITH SYNONYMS = ('revenue', 'sales', 'total sales')
      COMMENT = 'Total revenue from orders',
    order_items.total_units_sold AS SUM(quantity)
      WITH SYNONYMS = ('units sold', 'quantity sold')
      COMMENT = 'Total units sold',
    order_items.avg_order_value AS AVG(quantity * unit_price)
      WITH SYNONYMS = ('AOV', 'average order')
      COMMENT = 'Average order value',
    orders.total_orders AS COUNT(*)
      COMMENT = 'Total number of orders',
    customers.customer_count AS COUNT(*)
      COMMENT = 'Total number of customers',
    products.product_count AS COUNT(*)
      COMMENT = 'Total number of products'
  )
  COMMENT = 'Semantic view for retail analytics demo';
