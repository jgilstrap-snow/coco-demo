# Cortex Code (CoCo) Demo

A showcase repository demonstrating Snowflake's AI-powered coding assistant capabilities for SE teams.

## Quick Start

Run the setup scripts in order:
```sql
-- 1. Create sample data
@setup/01_create_sample_data.sql

-- 2. Create semantic view
@setup/02_create_semantic_view.sql

-- 3. Create Cortex Agent (deploys to Snowflake Intelligence)
@setup/03_create_agent.sql

-- 4. Create Dynamic Table for real-time metrics
@setup/04_create_dynamic_table.sql

-- 5. Create Cortex Search for RAG
@setup/05_create_cortex_search.sql
```

## Access the Agent

After setup, access the agent in Snowsight:
1. Navigate to **AI & ML > Snowflake Intelligence**
2. Select **Retail Analytics Assistant**
3. Start asking questions!

**Try these examples:**
- *Structured data:* "Who are the top 5 customers by revenue?"
- *Unstructured FAQs:* "What is your return policy?"
- *Combined (RAG):* "What features does the smart watch have, and how many have we sold?"

## What's Included

### Snowflake Objects Created

| Object | Type | Location | Description |
|--------|------|----------|-------------|
| `CUSTOMERS` | Table | `JACK.DEMO` | 10 sample customers |
| `PRODUCTS` | Table | `JACK.DEMO` | 10 products across 5 categories |
| `ORDERS` | Table | `JACK.DEMO` | 20 orders with various statuses |
| `ORDER_ITEMS` | Table | `JACK.DEMO` | 30 line items |
| `PRODUCT_FAQS` | Table | `JACK.DEMO` | 20 FAQs for RAG |
| `RETAIL_ANALYTICS_SV` | Semantic View | `JACK.DEMO` | Natural language query interface |
| `REVENUE_METRICS` | Dynamic Table | `JACK.DEMO` | Real-time revenue aggregations (1 min lag) |
| `PRODUCT_FAQ_SEARCH` | Cortex Search | `JACK.DEMO` | Semantic search on FAQs |
| `RETAIL_ANALYTICS_AGENT` | Cortex Agent | `SNOWFLAKE_INTELLIGENCE.AGENTS` | RAG-enabled AI assistant |
| `GITHUB_PAT_SECRET` | Secret | `JACK.DEMO` | GitHub credentials |
| `GITHUB_API_INTEGRATION` | API Integration | Account | Git connectivity |
| `COCO_DEMO_REPO` | Git Repository | `JACK.DEMO` | Synced repo clone |

### Demo Capabilities

#### 1. RAG-Enabled Agent (Snowflake Intelligence)
The agent combines **Cortex Analyst** (structured data) + **Cortex Search** (unstructured FAQs):
- Query sales data: "What is revenue by category?"
- Search FAQs: "How do I clean the yoga mat?"
- Combined queries: "What are the specs of our top selling product?"

#### 2. Dynamic Table Pipeline
Real-time aggregations that auto-refresh:
```sql
SELECT * FROM JACK.DEMO.REVENUE_METRICS
WHERE profit_margin_pct > 60
ORDER BY revenue DESC;
```

#### 3. Cortex Search Service
Semantic search on product documentation:
```sql
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
  'JACK.DEMO.PRODUCT_FAQ_SEARCH',
  '{"query": "warranty policy", "columns": ["question", "answer"], "limit": 3}'
);
```

#### 4. Analysis Notebook
Interactive data exploration with Altair visualizations:
- Revenue by category charts
- Top customers analysis
- Monthly trends
- Profit margin comparisons

#### 5. Streamlit App (Optional)
A chat interface that connects to the Cortex Agent for interactive data exploration.

## Repository Structure

```
coco-demo/
├── README.md                           # This file
├── setup/
│   ├── 01_create_sample_data.sql       # Tables with sample data
│   ├── 02_create_semantic_view.sql     # Semantic view definition
│   ├── 03_create_agent.sql             # RAG-enabled Cortex Agent
│   ├── 04_create_dynamic_table.sql     # Real-time revenue metrics
│   └── 05_create_cortex_search.sql     # FAQs + Cortex Search Service
├── notebooks/
│   └── retail_analysis.ipynb           # Data visualization notebook
└── streamlit/
    └── retail_analytics_app.py         # Optional chat app
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Snowflake Intelligence                          │
│                     RETAIL_ANALYTICS_AGENT (RAG)                        │
│   ┌─────────────────────────┐    ┌─────────────────────────┐           │
│   │    Cortex Analyst       │    │    Cortex Search        │           │
│   │   (Structured Data)     │    │  (Unstructured FAQs)    │           │
│   └───────────┬─────────────┘    └───────────┬─────────────┘           │
└───────────────┼──────────────────────────────┼─────────────────────────┘
                │                              │
    ┌───────────▼───────────┐      ┌───────────▼───────────┐
    │   Semantic View       │      │   PRODUCT_FAQ_SEARCH  │
    │ RETAIL_ANALYTICS_SV   │      │   20 searchable FAQs  │
    └───────────┬───────────┘      └───────────────────────┘
                │
    ┌───────────▼───────────────────────────────┐
    │            Base Tables                     │
    │  CUSTOMERS | PRODUCTS | ORDERS | ITEMS    │
    └───────────┬───────────────────────────────┘
                │
    ┌───────────▼───────────┐
    │    Dynamic Table      │
    │   REVENUE_METRICS     │
    │  (auto-refresh 1min)  │
    └───────────────────────┘
```

## Git Integration Setup

### Objects for Git Connectivity

```sql
-- 1. Create secret for GitHub credentials
CREATE OR REPLACE SECRET JACK.DEMO.github_pat_secret
  TYPE = PASSWORD
  USERNAME = '<github-username>'
  PASSWORD = '<github-pat>';

-- 2. Create API integration for GitHub
CREATE OR REPLACE API INTEGRATION github_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/jgilstrap-snow')
  ALLOWED_AUTHENTICATION_SECRETS = (JACK.DEMO.github_pat_secret)
  ENABLED = TRUE;

-- 3. Create Git repository clone
CREATE OR REPLACE GIT REPOSITORY JACK.DEMO.coco_demo_repo
  API_INTEGRATION = github_api_integration
  GIT_CREDENTIALS = JACK.DEMO.github_pat_secret
  ORIGIN = 'https://github.com/jgilstrap-snow/coco-demo.git';
```

### Creating a Workspace

1. Navigate to **Snowsight > Projects > Workspaces**
2. Click **From Git repository**
3. Paste: `https://github.com/jgilstrap-snow/coco-demo.git`
4. Select `GITHUB_API_INTEGRATION`
5. Choose **Personal access token** → `JACK.DEMO.GITHUB_PAT_SECRET`
6. Click **Create**

## What CoCo Can Demo

| Category | Feature | Description |
|----------|---------|-------------|
| **AI** | Semantic View | Natural language to SQL via Cortex Analyst |
| **AI** | Cortex Search | Semantic search on unstructured content |
| **AI** | RAG Agent | Multi-tool agent combining structured + unstructured |
| **AI** | Snowflake Intelligence | Agent accessible in Snowsight UI |
| **Apps** | Streamlit | Build data apps conversationally |
| **Apps** | Notebooks | Create visualizations with Altair |
| **Data Eng** | Dynamic Tables | Real-time pipeline creation |
| **DevOps** | Git Integration | Commit, push, PR from CoCo |
| **Governance** | RBAC | Role and grant configuration |
| **Cost** | FinOps | Credit consumption analysis |

---

*Generated and maintained using Cortex Code*
