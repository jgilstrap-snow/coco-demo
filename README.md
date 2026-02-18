# Cortex Code (CoCo) Demo

A self-contained demo that any SE can set up in their demo account. Everything you need is in this file.

## Quick Setup (CoCo Users)

**Attach this README to CoCo and say: "Set up this demo for me"**

CoCo will walk you through each step, prompting for your Git credentials when needed.

### Prerequisites

- Active CoCo connection to your demo account
- GitHub Personal Access Token with repo access
- Your fork/clone of this repository

---

## Setup Steps

Run each step in order. All SQL can be executed directly in Snowsight or via CoCo.

---

### Step 1: Infrastructure Setup

Creates role, database, schema, and warehouse. **Requires ACCOUNTADMIN.**

```sql
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS COCO_DEMO_ROLE;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE COCO_DEMO_ROLE;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE COCO_DEMO_ROLE;

CREATE DATABASE IF NOT EXISTS COCO_DEMO;
GRANT OWNERSHIP ON DATABASE COCO_DEMO TO ROLE COCO_DEMO_ROLE COPY CURRENT GRANTS;

CREATE WAREHOUSE IF NOT EXISTS COCO_DEMO_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
GRANT USAGE ON WAREHOUSE COCO_DEMO_WH TO ROLE COCO_DEMO_ROLE;

SET current_user_name = CURRENT_USER();
GRANT ROLE COCO_DEMO_ROLE TO USER IDENTIFIER($current_user_name);

USE ROLE COCO_DEMO_ROLE;
USE WAREHOUSE COCO_DEMO_WH;
USE DATABASE COCO_DEMO;

CREATE SCHEMA IF NOT EXISTS DEMO;
USE SCHEMA DEMO;
```

**Creates:** `COCO_DEMO_ROLE`, `COCO_DEMO` database, `DEMO` schema, `COCO_DEMO_WH` warehouse

---

### Step 2: Git Integration (Optional)

> Skip this step if you don't need Git integration for your demo.

**Replace placeholders before running:**
| Placeholder | Description | Example |
|-------------|-------------|---------|
| `<git_username>` | Your GitHub username | `myusername` |
| `<git_pat>` | Personal Access Token | `ghp_xxxx...` |
| `<git_prefix>` | Allowed URL prefix | `https://github.com/myusername` |
| `<repo_url>` | Full repository URL | `https://github.com/myusername/coco-demo.git` |

```sql
USE ROLE COCO_DEMO_ROLE;
USE DATABASE COCO_DEMO;
USE SCHEMA DEMO;
USE WAREHOUSE COCO_DEMO_WH;

CREATE OR REPLACE SECRET git_pat_secret
    TYPE = PASSWORD
    USERNAME = '<git_username>'
    PASSWORD = '<git_pat>';

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION coco_demo_git_integration
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('<git_prefix>')
    ALLOWED_AUTHENTICATION_SECRETS = (COCO_DEMO.DEMO.GIT_PAT_SECRET)
    ENABLED = TRUE;

GRANT USAGE ON INTEGRATION coco_demo_git_integration TO ROLE COCO_DEMO_ROLE;

USE ROLE COCO_DEMO_ROLE;

CREATE OR REPLACE GIT REPOSITORY coco_demo_repo
    API_INTEGRATION = coco_demo_git_integration
    GIT_CREDENTIALS = git_pat_secret
    ORIGIN = '<repo_url>';
```

**Creates:** `GIT_PAT_SECRET`, `COCO_DEMO_GIT_INTEGRATION`, `COCO_DEMO_REPO`

---

### Step 3: Sample Data

Creates 4 tables with sample retail data.

```sql
USE ROLE COCO_DEMO_ROLE;
USE DATABASE COCO_DEMO;
USE SCHEMA DEMO;
USE WAREHOUSE COCO_DEMO_WH;

CREATE OR REPLACE TABLE customers (
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(200),
    segment VARCHAR(50),
    region VARCHAR(50),
    created_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE products (
    product_id INT,
    name VARCHAR(200),
    category VARCHAR(100),
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),
    total_amount DECIMAL(12,2)
);

CREATE OR REPLACE TABLE order_items (
    item_id INT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2)
);

INSERT INTO customers (customer_id, name, email, segment, region, created_at)
SELECT 
    seq4() AS customer_id,
    'Customer ' || seq4() AS name,
    'customer' || seq4() || '@example.com' AS email,
    CASE MOD(seq4(), 3) WHEN 0 THEN 'Enterprise' WHEN 1 THEN 'SMB' ELSE 'Consumer' END AS segment,
    CASE MOD(seq4(), 4) WHEN 0 THEN 'North America' WHEN 1 THEN 'Europe' WHEN 2 THEN 'Asia Pacific' ELSE 'Latin America' END AS region,
    DATEADD(day, -UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

INSERT INTO products (product_id, name, category, price, cost)
SELECT 
    seq4() AS product_id,
    CASE MOD(seq4(), 5) 
        WHEN 0 THEN 'Laptop Model ' || seq4()
        WHEN 1 THEN 'Phone Model ' || seq4()
        WHEN 2 THEN 'Tablet Model ' || seq4()
        WHEN 3 THEN 'Accessory ' || seq4()
        ELSE 'Software License ' || seq4()
    END AS name,
    CASE MOD(seq4(), 5) 
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Mobile'
        WHEN 2 THEN 'Tablets'
        WHEN 3 THEN 'Accessories'
        ELSE 'Software'
    END AS category,
    ROUND(UNIFORM(50, 2000, RANDOM())::DECIMAL(10,2), 2) AS price,
    ROUND(UNIFORM(25, 1500, RANDOM())::DECIMAL(10,2), 2) AS cost
FROM TABLE(GENERATOR(ROWCOUNT => 20));

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
SELECT 
    seq4() AS order_id,
    UNIFORM(1, 50, RANDOM()) AS customer_id,
    DATEADD(day, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS order_date,
    CASE MOD(seq4(), 4) WHEN 0 THEN 'Completed' WHEN 1 THEN 'Shipped' WHEN 2 THEN 'Processing' ELSE 'Pending' END AS status,
    ROUND(UNIFORM(100, 5000, RANDOM())::DECIMAL(12,2), 2) AS total_amount
FROM TABLE(GENERATOR(ROWCOUNT => 200));

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price)
SELECT 
    seq4() AS item_id,
    UNIFORM(1, 200, RANDOM()) AS order_id,
    UNIFORM(1, 20, RANDOM()) AS product_id,
    UNIFORM(1, 5, RANDOM()) AS quantity,
    ROUND(UNIFORM(50, 2000, RANDOM())::DECIMAL(10,2), 2) AS unit_price
FROM TABLE(GENERATOR(ROWCOUNT => 500));
```

**Creates:** `CUSTOMERS` (50 rows), `PRODUCTS` (20 rows), `ORDERS` (200 rows), `ORDER_ITEMS` (500 rows)

---

### Step 4: Semantic View

Creates a semantic view for Cortex Analyst.

```sql
USE ROLE COCO_DEMO_ROLE;
USE DATABASE COCO_DEMO;
USE SCHEMA DEMO;
USE WAREHOUSE COCO_DEMO_WH;

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
  'COCO_DEMO.DEMO',
  $$
name: RETAIL_ANALYTICS_SV
description: Semantic model for retail analytics including customers, products, orders, and order items.

tables:
  - name: CUSTOMERS
    description: Customer information including segment and region.
    base_table:
      database: COCO_DEMO
      schema: DEMO
      table: CUSTOMERS
    primary_key:
      columns:
        - customer_id
    dimensions:
      - name: customer_id
        expr: customer_id
        description: Unique identifier for each customer.
        data_type: NUMBER
      - name: name
        expr: name
        description: Customer name.
        data_type: VARCHAR
      - name: email
        expr: email
        description: Customer email address.
        data_type: VARCHAR
      - name: segment
        synonyms:
          - customer_segment
          - customer_type
        expr: segment
        description: Customer segment (Enterprise, SMB, Consumer).
        data_type: VARCHAR
      - name: region
        synonyms:
          - geographic_region
          - location
        expr: region
        description: Geographic region (North America, Europe, Asia Pacific, Latin America).
        data_type: VARCHAR
    time_dimensions:
      - name: created_at
        expr: created_at
        description: Date when the customer was created.
        data_type: TIMESTAMP_NTZ

  - name: PRODUCTS
    description: Product catalog with pricing information.
    base_table:
      database: COCO_DEMO
      schema: DEMO
      table: PRODUCTS
    primary_key:
      columns:
        - product_id
    dimensions:
      - name: product_id
        expr: product_id
        description: Unique identifier for each product.
        data_type: NUMBER
      - name: product_name
        synonyms:
          - name
        expr: name
        description: Product name.
        data_type: VARCHAR
      - name: category
        synonyms:
          - product_category
          - product_type
        expr: category
        description: Product category (Electronics, Mobile, Tablets, Accessories, Software).
        data_type: VARCHAR
    measures:
      - name: price
        expr: price
        description: Product selling price.
        data_type: NUMBER
      - name: cost
        expr: cost
        description: Product cost.
        data_type: NUMBER
      - name: margin
        expr: price - cost
        description: Profit margin per unit.
        data_type: NUMBER

  - name: ORDERS
    description: Customer orders with status and total amounts.
    base_table:
      database: COCO_DEMO
      schema: DEMO
      table: ORDERS
    primary_key:
      columns:
        - order_id
    dimensions:
      - name: order_id
        expr: order_id
        description: Unique identifier for each order.
        data_type: NUMBER
      - name: customer_id
        expr: customer_id
        description: Reference to the customer who placed the order.
        data_type: NUMBER
      - name: status
        synonyms:
          - order_status
        expr: status
        description: Order status (Completed, Shipped, Processing, Pending).
        data_type: VARCHAR
    time_dimensions:
      - name: order_date
        expr: order_date
        description: Date when the order was placed.
        data_type: DATE
    measures:
      - name: total_amount
        synonyms:
          - order_total
          - revenue
        expr: total_amount
        description: Total order amount in dollars.
        data_type: NUMBER
        default_aggregation: sum

  - name: ORDER_ITEMS
    description: Individual line items within orders.
    base_table:
      database: COCO_DEMO
      schema: DEMO
      table: ORDER_ITEMS
    primary_key:
      columns:
        - item_id
    dimensions:
      - name: item_id
        expr: item_id
        description: Unique identifier for each order item.
        data_type: NUMBER
      - name: order_id
        expr: order_id
        description: Reference to the parent order.
        data_type: NUMBER
      - name: product_id
        expr: product_id
        description: Reference to the product.
        data_type: NUMBER
    measures:
      - name: quantity
        expr: quantity
        description: Quantity ordered.
        data_type: NUMBER
        default_aggregation: sum
      - name: unit_price
        expr: unit_price
        description: Price per unit at time of order.
        data_type: NUMBER
      - name: line_total
        expr: quantity * unit_price
        description: Total amount for this line item.
        data_type: NUMBER
        default_aggregation: sum

relationships:
  - name: orders_to_customers
    left_table: ORDERS
    right_table: CUSTOMERS
    relationship_columns:
      - left_column: customer_id
        right_column: customer_id
    join_type: left_outer
    relationship_type: many_to_one

  - name: order_items_to_orders
    left_table: ORDER_ITEMS
    right_table: ORDERS
    relationship_columns:
      - left_column: order_id
        right_column: order_id
    join_type: left_outer
    relationship_type: many_to_one

  - name: order_items_to_products
    left_table: ORDER_ITEMS
    right_table: PRODUCTS
    relationship_columns:
      - left_column: product_id
        right_column: product_id
    join_type: left_outer
    relationship_type: many_to_one
  $$
);
```

**Creates:** `RETAIL_ANALYTICS_SV` semantic view

---

### Step 5: Cortex Agent

Creates an AI agent that can answer natural language questions about your data.

```sql
USE ROLE COCO_DEMO_ROLE;
USE DATABASE COCO_DEMO;
USE SCHEMA DEMO;
USE WAREHOUSE COCO_DEMO_WH;

CREATE OR REPLACE AGENT retail_analytics_agent
    COMMENT = 'Retail analytics agent for natural language queries'
    PROFILE = '{"display_name": "Retail Analytics Agent"}'
    FROM SPECIFICATION $$
    {
        "models": {
            "orchestration": "claude-4-sonnet"
        },
        "instructions": {
            "orchestration": "Use the retail data analyst tool to answer questions about customers, products, orders, and sales metrics.",
            "response": "Provide clear, data-driven insights. Format numbers with appropriate precision. When showing trends, explain the significance."
        },
        "tools": [
            {
                "tool_spec": {
                    "type": "cortex_analyst_text_to_sql",
                    "name": "retail_data",
                    "description": "Query retail data including customers, products, orders, and order items. Use for questions about revenue, order counts, customer segments, product categories, and regional performance."
                }
            }
        ],
        "tool_resources": {
            "retail_data": {
                "semantic_view": "COCO_DEMO.DEMO.RETAIL_ANALYTICS_SV",
                "execution_environment": {
                    "type": "warehouse",
                    "warehouse": "COCO_DEMO_WH"
                },
                "query_timeout": 60
            }
        }
    }
    $$;
```

**Creates:** `RETAIL_ANALYTICS_AGENT`

---

### Step 6: Streamlit App

Deploys a Streamlit app to Snowflake. First, save the Python code below to a local file named `retail_analytics_app.py`, then run the SQL to deploy it.

**6a. Save this Python code to `retail_analytics_app.py`:**

```python
import json
import requests
import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()

DATABASE = "COCO_DEMO"
SCHEMA = "DEMO"
AGENT_NAME = "RETAIL_ANALYTICS_AGENT"

st.title("Retail Analytics Dashboard")

if "messages" not in st.session_state:
    st.session_state.messages = []
if "thread_id" not in st.session_state:
    st.session_state.thread_id = None

col1, col2, col3 = st.columns(3)
with col1:
    total_revenue = session.sql("SELECT SUM(total_amount) FROM COCO_DEMO.DEMO.ORDERS").collect()[0][0]
    st.metric("Total Revenue", f"${total_revenue:,.2f}" if total_revenue else "$0")
with col2:
    total_orders = session.sql("SELECT COUNT(*) FROM COCO_DEMO.DEMO.ORDERS").collect()[0][0]
    st.metric("Total Orders", f"{total_orders:,}" if total_orders else "0")
with col3:
    total_customers = session.sql("SELECT COUNT(*) FROM COCO_DEMO.DEMO.CUSTOMERS").collect()[0][0]
    st.metric("Total Customers", f"{total_customers:,}" if total_customers else "0")

st.divider()

tab1, tab2 = st.tabs(["Chat with Agent", "Data Explorer"])

with tab1:
    for msg in st.session_state.messages:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    if prompt := st.chat_input("Ask about your retail data..."):
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        with st.chat_message("assistant"):
            with st.spinner("Thinking..."):
                try:
                    host = session.sql("SELECT CURRENT_ACCOUNT_LOCATOR()").collect()[0][0]
                    region = session.sql("SELECT CURRENT_REGION()").collect()[0][0]
                    base_url = f"https://{host}.{region}.snowflakecomputing.com"
                    token = session._conn._rest._token

                    if not st.session_state.thread_id:
                        thread_resp = requests.post(
                            f"{base_url}/api/v2/cortex/threads",
                            headers={
                                "Authorization": f'Snowflake Token="{token}"',
                                "Content-Type": "application/json"
                            },
                            json={"origin_application": "retail_analytics_app"}
                        )
                        if thread_resp.status_code == 200:
                            st.session_state.thread_id = thread_resp.json().get("thread_id")

                    run_payload = {
                        "thread_id": st.session_state.thread_id or "0",
                        "parent_message_id": "0",
                        "messages": [
                            {
                                "role": "user",
                                "content": [{"type": "text", "text": prompt}]
                            }
                        ]
                    }

                    run_resp = requests.post(
                        f"{base_url}/api/v2/databases/{DATABASE}/schemas/{SCHEMA}/agents/{AGENT_NAME}:run",
                        headers={
                            "Authorization": f'Snowflake Token="{token}"',
                            "Content-Type": "application/json"
                        },
                        json=run_payload
                    )

                    if run_resp.status_code == 200:
                        response_data = run_resp.json()
                        content_items = response_data.get("message", {}).get("content", [])
                        response_text = ""
                        for item in content_items:
                            if item.get("type") == "text":
                                response_text += item.get("text", "")
                            elif item.get("type") == "sql":
                                sql_stmt = item.get("statement", "")
                                response_text += f"\n```sql\n{sql_stmt}\n```\n"
                                try:
                                    df = session.sql(sql_stmt).to_pandas()
                                    st.dataframe(df, hide_index=True)
                                except Exception as e:
                                    st.error(f"Error executing SQL: {e}")
                        st.markdown(response_text)
                        st.session_state.messages.append({"role": "assistant", "content": response_text})
                    else:
                        error_msg = f"Agent error: {run_resp.status_code}"
                        st.error(error_msg)
                        st.session_state.messages.append({"role": "assistant", "content": error_msg})

                except Exception as e:
                    error_msg = f"Error: {str(e)}"
                    st.error(error_msg)
                    st.session_state.messages.append({"role": "assistant", "content": error_msg})

with tab2:
    table_choice = st.selectbox("Select a table", ["CUSTOMERS", "PRODUCTS", "ORDERS", "ORDER_ITEMS"])
    df = session.sql(f"SELECT * FROM COCO_DEMO.DEMO.{table_choice} LIMIT 100").to_pandas()
    st.dataframe(df, hide_index=True)

    st.subheader("Revenue by Region")
    revenue_by_region = session.sql("""
        SELECT c.region, SUM(o.total_amount) AS revenue
        FROM COCO_DEMO.DEMO.ORDERS o
        JOIN COCO_DEMO.DEMO.CUSTOMERS c ON o.customer_id = c.customer_id
        GROUP BY c.region
        ORDER BY revenue DESC
    """).to_pandas()
    st.bar_chart(revenue_by_region.set_index("REGION"))

    st.subheader("Sales by Category")
    sales_by_category = session.sql("""
        SELECT p.category, SUM(oi.quantity * oi.unit_price) AS sales
        FROM COCO_DEMO.DEMO.ORDER_ITEMS oi
        JOIN COCO_DEMO.DEMO.PRODUCTS p ON oi.product_id = p.product_id
        GROUP BY p.category
        ORDER BY sales DESC
    """).to_pandas()
    st.bar_chart(sales_by_category.set_index("CATEGORY"))
```

**6b. Deploy to Snowflake:**

First create a stage and upload the file, then create the Streamlit app:

```sql
USE ROLE COCO_DEMO_ROLE;
USE DATABASE COCO_DEMO;
USE SCHEMA DEMO;
USE WAREHOUSE COCO_DEMO_WH;

CREATE STAGE IF NOT EXISTS STREAMLIT_STAGE;

-- Upload the file using SnowSQL or Snowsight:
-- PUT file://retail_analytics_app.py @STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

CREATE OR REPLACE STREAMLIT RETAIL_ANALYTICS_APP
    ROOT_LOCATION = '@COCO_DEMO.DEMO.STREAMLIT_STAGE'
    MAIN_FILE = 'retail_analytics_app.py'
    QUERY_WAREHOUSE = COCO_DEMO_WH
    COMMENT = 'Retail Analytics Dashboard with Agent Chat';
```

> **Note:** Use SnowSQL, Snowsight, or CoCo to upload `retail_analytics_app.py` to the stage before creating the Streamlit app.

---

## Objects Created

| Object | Type | Location |
|--------|------|----------|
| `COCO_DEMO_ROLE` | Role | Account |
| `COCO_DEMO` | Database | Account |
| `COCO_DEMO.DEMO` | Schema | Database |
| `COCO_DEMO_WH` | Warehouse | Account |
| `GIT_PAT_SECRET` | Secret | `COCO_DEMO.DEMO` |
| `COCO_DEMO_GIT_INTEGRATION` | API Integration | Account |
| `COCO_DEMO_REPO` | Git Repository | `COCO_DEMO.DEMO` |
| `CUSTOMERS` | Table | `COCO_DEMO.DEMO` |
| `PRODUCTS` | Table | `COCO_DEMO.DEMO` |
| `ORDERS` | Table | `COCO_DEMO.DEMO` |
| `ORDER_ITEMS` | Table | `COCO_DEMO.DEMO` |
| `RETAIL_ANALYTICS_SV` | Semantic View | `COCO_DEMO.DEMO` |
| `RETAIL_ANALYTICS_AGENT` | Cortex Agent | `COCO_DEMO.DEMO` |
| `STREAMLIT_STAGE` | Stage | `COCO_DEMO.DEMO` |
| `RETAIL_ANALYTICS_APP` | Streamlit App | `COCO_DEMO.DEMO` |

---

## Cleanup

To remove all demo objects:

```sql
USE ROLE ACCOUNTADMIN;

-- Drop objects in COCO_DEMO (optional - database drop handles these)
-- DROP STREAMLIT IF EXISTS COCO_DEMO.DEMO.RETAIL_ANALYTICS_APP;
-- DROP AGENT IF EXISTS COCO_DEMO.DEMO.RETAIL_ANALYTICS_AGENT;
-- DROP VIEW IF EXISTS COCO_DEMO.DEMO.RETAIL_ANALYTICS_SV;

-- Drop account-level objects
DROP DATABASE IF EXISTS COCO_DEMO;
DROP WAREHOUSE IF EXISTS COCO_DEMO_WH;
DROP INTEGRATION IF EXISTS COCO_DEMO_GIT_INTEGRATION;
DROP ROLE IF EXISTS COCO_DEMO_ROLE;
```

---

*Generated and maintained using Cortex Code*
