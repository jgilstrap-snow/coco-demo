# Cortex Code (CoCo) Demo

A showcase repository demonstrating Snowflake's AI-powered coding assistant capabilities for SE teams.

## Overview

This repository contains demo collateral for showcasing Cortex Code features including:
- Natural language to SQL
- Semantic view and Cortex Agent creation
- Streamlit app development
- Git integration workflows
- And more...

## Snowflake Setup

### Objects Created

| Object | Type | Location |
|--------|------|----------|
| `GITHUB_PAT_SECRET` | Secret | `JACK.DEMO` |
| `GITHUB_API_INTEGRATION` | API Integration | Account |
| `COCO_DEMO_REPO` | Git Repository | `JACK.DEMO` |

### Setup SQL

```sql
USE ROLE SYSADMIN;
USE DATABASE JACK;
USE SCHEMA DEMO;

-- 1. Create secret for GitHub credentials
CREATE OR REPLACE SECRET github_pat_secret
  TYPE = PASSWORD
  USERNAME = '<github-username>'
  PASSWORD = '<github-pat>';

-- 2. Create API integration for GitHub
CREATE OR REPLACE API INTEGRATION github_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/<your-org>')
  ALLOWED_AUTHENTICATION_SECRETS = (JACK.DEMO.github_pat_secret)
  ENABLED = TRUE;

-- 3. Create Git repository clone
CREATE OR REPLACE GIT REPOSITORY coco_demo_repo
  API_INTEGRATION = github_api_integration
  GIT_CREDENTIALS = github_pat_secret
  ORIGIN = 'https://github.com/jgilstrap-snow/coco-demo.git';
```

### Creating a Workspace

1. Navigate to **Snowsight > Projects > Workspaces**
2. Click **From Git repository**
3. Paste: `https://github.com/jgilstrap-snow/coco-demo.git`
4. Select `GITHUB_API_INTEGRATION`
5. Choose **Personal access token** → `JACK.DEMO.GITHUB_PAT_SECRET`
6. Click **Create**

## Demo Scenarios

### Recommended Flow

```
Sample Data → Semantic View → Cortex Agent → Streamlit App → Test → Commit
```

### Categories

| Category | Demo | Description |
|----------|------|-------------|
| **AI** | Semantic View + Agent | Build conversational analytics |
| **Apps** | Streamlit | Create data apps with natural language |
| **Data Eng** | Dynamic Tables | Build pipelines from descriptions |
| **DevOps** | Git Workflow | Commit and PR from CoCo |
| **Governance** | RBAC & Cost | Security and FinOps insights |

## Repository Structure

```
coco-demo/
├── README.md
├── setup/                 # SQL setup scripts
├── semantic/              # Semantic views and models
├── agents/                # Cortex Agent definitions
├── streamlit/             # Streamlit applications
└── notebooks/             # Jupyter notebooks
```

## Getting Started

1. Ensure Git integration is configured (see Setup SQL above)
2. Create a workspace from this repository
3. Follow demo scenarios in order or pick specific features to showcase

---

*Generated and maintained using Cortex Code*
