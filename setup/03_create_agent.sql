-- Retail Analytics Cortex Agent for Snowflake Intelligence
-- Creates an AI agent accessible via AI & ML > Snowflake Intelligence in Snowsight

-- Setup Snowflake Intelligence database/schema (one-time)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE PUBLIC;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE PUBLIC;

-- Create the agent
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.RETAIL_ANALYTICS_AGENT
  COMMENT = 'AI assistant for retail analytics - answers questions about customers, products, and sales'
  PROFILE = '{"display_name": "Retail Analytics Assistant"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "Use the retail_analyst tool to answer questions about sales, customers, products, and orders. Always query the data before responding.",
      "response": "Be concise and data-driven. Present numbers clearly. If asked for trends or comparisons, highlight key insights."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "retail_analyst",
          "description": "Query retail data including customers, products, orders, and sales metrics. Use for questions about revenue, top customers, product categories, order trends, and customer segments."
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
      }
    }
  }
  $$;

-- Grant access to all users
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.RETAIL_ANALYTICS_AGENT TO ROLE PUBLIC;
