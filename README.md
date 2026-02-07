# Cortex Code (CoCo) Demo

A showcase repository demonstrating Snowflake's AI-powered coding assistant capabilities for SE teams.

## Quick Start

Run the setup scripts in order:
```sql
-- 1. Create sample data
@setup/01_create_sample_data.sql

-- 2. Create semantic view
@setup/02_create_semantic_view.sql

-- 3. Create Cortex Agent
@setup/03_create_agent.sql
```

## What's Included

### Snowflake Objects Created

| Object | Type | Location | Description |
|--------|------|----------|-------------|
| `CUSTOMERS` | Table | `JACK.DEMO` | 10 sample customers |
| `PRODUCTS` | Table | `JACK.DEMO` | 10 products across 5 categories |
| `ORDERS` | Table | `JACK.DEMO` | 20 orders with various statuses |
| `ORDER_ITEMS` | Table | `JACK.DEMO` | 30 line items |
| `RETAIL_ANALYTICS_SV` | Semantic View | `JACK.DEMO` | Natural language query interface |
| `RETAIL_ANALYTICS_AGENT` | Cortex Agent | `JACK.DEMO` | AI assistant for data questions |
| `GITHUB_PAT_SECRET` | Secret | `JACK.DEMO` | GitHub credentials |
| `GITHUB_API_INTEGRATION` | API Integration | Account | Git connectivity |
| `COCO_DEMO_REPO` | Git Repository | `JACK.DEMO` | Synced repo clone |

### Demo Capabilities

#### 1. Semantic View + Cortex Analyst
Ask natural language questions about the data:
```sql
-- Example: Query the semantic view directly
SELECT * FROM SEMANTIC_VIEW(
  JACK.DEMO.RETAIL_ANALYTICS_SV
  METRICS (order_items.total_revenue)
  DIMENSIONS (products.category)
);
```

#### 2. Cortex Agent
The agent can answer questions like:
- "Who are the top 5 customers by revenue?"
- "What is revenue by product category?"
- "How many orders are pending?"
- "Which state has the most customers?"

#### 3. Streamlit App
A chat interface that connects to the Cortex Agent for interactive data exploration.

## Repository Structure

```
coco-demo/
├── README.md                           # This file
├── setup/
│   ├── 01_create_sample_data.sql       # Tables with sample data
│   ├── 02_create_semantic_view.sql     # Semantic view definition
│   └── 03_create_agent.sql             # Cortex Agent definition
└── streamlit/
    └── retail_analytics_app.py         # Chat app using Cortex Agent
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

## Demo Flow

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Sample Data │ -> │ Semantic View│ -> │ Cortex Agent │ -> │ Streamlit App│
└─────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
     Tables           Text-to-SQL        AI Assistant       Chat Interface
```

## What CoCo Can Demo

| Category | Feature | Description |
|----------|---------|-------------|
| **AI** | Semantic View | Natural language to SQL via Cortex Analyst |
| **AI** | Cortex Agent | Multi-tool AI orchestration |
| **Apps** | Streamlit | Build data apps conversationally |
| **Data Eng** | Dynamic Tables | Pipeline creation from descriptions |
| **DevOps** | Git Integration | Commit, push, PR from CoCo |
| **Governance** | RBAC | Role and grant configuration |
| **Cost** | FinOps | Credit consumption analysis |

---

*Generated and maintained using Cortex Code*
