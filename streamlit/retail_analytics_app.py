import json
import streamlit as st
import requests

try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
    IS_SIS = True
except:
    from snowflake.snowpark import Session
    import os
    session = Session.builder.config('connection_name', os.getenv('SNOWFLAKE_CONNECTION_NAME', 'default')).create()
    IS_SIS = False

AGENT_NAME = "JACK.DEMO.RETAIL_ANALYTICS_AGENT"
ICONS = {"user": "👤", "assistant": "🛒"}

st.title("Retail Analytics Assistant")
st.caption("Powered by Cortex Agent + Semantic View")

if "messages" not in st.session_state:
    st.session_state.messages = []
if "thread_id" not in st.session_state:
    st.session_state.thread_id = None

def get_snowflake_token():
    return session._conn._rest._token

def create_thread():
    host = session.get_current_account_url()
    resp = requests.post(
        f"{host}/api/v2/cortex/threads",
        headers={
            "Authorization": f'Snowflake Token="{get_snowflake_token()}"',
            "Content-Type": "application/json"
        },
        json={"origin_application": "retail_analytics_app"}
    )
    if resp.status_code < 400:
        return resp.json().get("thread_id")
    return None

def run_agent(user_message: str, thread_id: str):
    host = session.get_current_account_url()
    
    parent_id = "0"
    if st.session_state.messages:
        for msg in reversed(st.session_state.messages):
            if msg.get("message_id"):
                parent_id = msg["message_id"]
                break
    
    payload = {
        "thread_id": thread_id,
        "parent_message_id": parent_id,
        "messages": [
            {
                "role": "user",
                "content": [{"type": "text", "text": user_message}]
            }
        ]
    }
    
    db, schema, agent = AGENT_NAME.split(".")
    resp = requests.post(
        f"{host}/api/v2/databases/{db}/schemas/{schema}/agents/{agent}:run",
        headers={
            "Authorization": f'Snowflake Token="{get_snowflake_token()}"',
            "Content-Type": "application/json",
            "Accept": "text/event-stream"
        },
        json=payload,
        stream=True
    )
    
    return resp

def process_stream(response):
    full_text = ""
    sql_queries = []
    message_id = None
    
    for line in response.iter_lines():
        if line:
            line_str = line.decode('utf-8')
            if line_str.startswith("data:"):
                try:
                    data = json.loads(line_str[5:].strip())
                    if "message_id" in data:
                        message_id = data["message_id"]
                    if "delta" in data:
                        delta = data["delta"]
                        if "content" in delta:
                            for item in delta["content"]:
                                if item.get("type") == "text":
                                    full_text += item.get("text", "")
                                elif item.get("type") == "tool_results":
                                    for result in item.get("tool_results", []):
                                        if result.get("type") == "cortex_analyst_result":
                                            sql = result.get("sql", "")
                                            if sql:
                                                sql_queries.append(sql)
                except json.JSONDecodeError:
                    continue
    
    return full_text, sql_queries, message_id

with st.sidebar:
    st.header("About")
    st.markdown("""
    Ask questions about:
    - **Customers** - segments, locations
    - **Products** - categories, pricing
    - **Orders** - status, trends
    - **Revenue** - by customer, category, time
    """)
    
    st.divider()
    
    if st.button("Clear Chat"):
        st.session_state.messages = []
        st.session_state.thread_id = None
        st.rerun()
    
    st.divider()
    st.caption("Sample questions:")
    sample_questions = [
        "Who are the top 5 customers by revenue?",
        "What is revenue by product category?",
        "How many orders are pending?",
        "Which state has the most customers?"
    ]
    for q in sample_questions:
        if st.button(q, key=f"sample_{q[:20]}"):
            st.session_state.pending_question = q

for msg in st.session_state.messages:
    with st.chat_message(msg["role"], avatar=ICONS.get(msg["role"])):
        st.markdown(msg["content"])
        if msg.get("sql"):
            with st.expander("View SQL"):
                st.code(msg["sql"], language="sql")

pending = st.session_state.get("pending_question")
user_input = st.chat_input("Ask about retail data...")

if pending:
    user_input = pending
    st.session_state.pending_question = None

if user_input:
    st.session_state.messages.append({"role": "user", "content": user_input})
    with st.chat_message("user", avatar=ICONS["user"]):
        st.markdown(user_input)
    
    with st.chat_message("assistant", avatar=ICONS["assistant"]):
        with st.spinner("Thinking..."):
            if not st.session_state.thread_id:
                st.session_state.thread_id = create_thread()
            
            if st.session_state.thread_id:
                response = run_agent(user_input, st.session_state.thread_id)
                
                if response.status_code < 400:
                    text, sql_queries, msg_id = process_stream(response)
                    
                    if text:
                        st.markdown(text)
                        msg_data = {"role": "assistant", "content": text}
                        if msg_id:
                            msg_data["message_id"] = msg_id
                        if sql_queries:
                            msg_data["sql"] = sql_queries[0]
                            with st.expander("View SQL"):
                                st.code(sql_queries[0], language="sql")
                        st.session_state.messages.append(msg_data)
                    else:
                        st.error("No response received")
                else:
                    st.error(f"Error: {response.status_code}")
            else:
                st.error("Could not create conversation thread")
    
    st.rerun()
