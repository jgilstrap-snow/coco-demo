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
        if msg["role"] == "user":
            st.markdown(f"**You:** {msg['content']}")
        else:
            st.markdown(f"**Agent:** {msg['content']}")

    with st.form("chat_form", clear_on_submit=True):
        prompt = st.text_input("Ask about your retail data...", key="user_input")
        submitted = st.form_submit_button("Send")

    if submitted and prompt:
        st.session_state.messages.append({"role": "user", "content": prompt})
        
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
                                st.dataframe(df)
                            except Exception as e:
                                st.error(f"Error executing SQL: {e}")
                    st.session_state.messages.append({"role": "assistant", "content": response_text})
                else:
                    error_msg = f"Agent error: {run_resp.status_code}"
                    st.error(error_msg)
                    st.session_state.messages.append({"role": "assistant", "content": error_msg})

            except Exception as e:
                error_msg = f"Error: {str(e)}"
                st.error(error_msg)
                st.session_state.messages.append({"role": "assistant", "content": error_msg})
        
        st.rerun()

with tab2:
    table_choice = st.selectbox("Select a table", ["CUSTOMERS", "PRODUCTS", "ORDERS", "ORDER_ITEMS"])
    df = session.sql(f"SELECT * FROM COCO_DEMO.DEMO.{table_choice} LIMIT 100").to_pandas()
    st.dataframe(df)

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
