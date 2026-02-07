-- Retail Analytics Cortex Agent
-- Creates an AI agent that can answer natural language questions about retail data

CREATE OR REPLACE AGENT JACK.DEMO.RETAIL_ANALYTICS_AGENT
  COMMENT = 'AI assistant for retail analytics - answers questions about customers, products, and sales'
  PROFILE = '{"display_name": "Retail Analytics Assistant", "avatar": "shopping-cart"}'
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

-- Grant usage to appropriate roles
-- GRANT USAGE ON AGENT JACK.DEMO.RETAIL_ANALYTICS_AGENT TO ROLE <your_role>;
