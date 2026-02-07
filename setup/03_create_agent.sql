-- Retail Analytics Cortex Agent for Snowflake Intelligence
-- Creates an AI agent with RAG capabilities (structured + unstructured data)
-- Accessible via AI & ML > Snowflake Intelligence in Snowsight

-- Setup Snowflake Intelligence database/schema (one-time)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE PUBLIC;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE PUBLIC;

-- Create the RAG-enabled agent with two tools
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.RETAIL_ANALYTICS_AGENT
  COMMENT = 'AI assistant for retail analytics - answers questions about data AND product FAQs'
  PROFILE = '{"display_name": "Retail Analytics Assistant"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "You have two tools: 1) retail_analyst for sales/customer/order data questions (revenue, trends, metrics), 2) product_faqs for product information, policies, returns, shipping, features. Use the appropriate tool based on the question. For questions mixing both (e.g., 'what are the features of our top selling product'), use both tools.",
      "response": "Be concise and helpful. For data questions, present numbers clearly. For FAQ questions, provide complete answers from the search results."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "retail_analyst",
          "description": "Query structured retail data: customers, products, orders, revenue, trends. Use for questions about sales metrics, top customers, order status, revenue by category, customer segments."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "product_faqs",
          "description": "Search product FAQs, policies, and documentation. Use for questions about product features, specifications, warranty, returns, shipping, care instructions, and store policies."
        }
      }
    ],
    "tool_resources": {
      "retail_analyst": {
        "semantic_view": "JACK.DEMO.RETAIL_ANALYTICS_SV",
        "execution_environment": {
          "type": "warehouse",
          "warehouse": "AICOLLEGE"
        },
        "query_timeout": 60
      },
      "product_faqs": {
        "search_service": "JACK.DEMO.PRODUCT_FAQ_SEARCH",
        "max_results": 5,
        "columns": ["category", "question", "answer"]
      }
    }
  }
  $$;

-- Grant access to all users
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.RETAIL_ANALYTICS_AGENT TO ROLE PUBLIC;
