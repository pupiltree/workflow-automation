# Service 23: Dynamic Workflow Engine

**Category**: Automation & AI Workflows
**Status**: Planned (Not Yet Implemented)
**Owner**: Platform Engineering
**Last Updated**: 2025-10-08

---

## Table of Contents

1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Solution Architecture](#solution-architecture)
4. [Objectives & Requirements](#objectives--requirements)
5. [Features](#features)
6. [Architecture](#architecture)
7. [Natural Language Workflow Specification](#natural-language-workflow-specification)
8. [Workflow Specification Format](#workflow-specification-format)
9. [Agent Library](#agent-library)
10. [API Specification](#api-specification)
11. [Database Schema](#database-schema)
12. [Event-Driven Integration](#event-driven-integration)
13. [LangGraph Implementation](#langgraph-implementation)
14. [State Management](#state-management)
15. [Multi-Tenancy & Security](#multi-tenancy--security)
16. [Error Handling & Recovery](#error-handling--recovery)
17. [Monitoring & Observability](#monitoring--observability)
18. [Dependencies](#dependencies)
19. [Testing Strategy](#testing-strategy)
20. [Deployment](#deployment)
21. [Implementation Phases](#implementation-phases)

---

## Overview

### Purpose

Service 23 (Dynamic Workflow Engine) enables users to create and execute complex, multi-step AI workflows from natural language descriptions. It dynamically generates LangGraph-based workflows that can orchestrate LLMs, tools, external APIs, and human-in-the-loop operations.

**Example**: "Scrape 10 LinkedIn profiles → extract skills with LLM → email summary" automatically becomes a 3-node LangGraph workflow with web scraping, LLM processing, and email delivery agents.

### Key Capabilities

1. **Natural Language Workflow Creation**
   - Parse natural language workflow descriptions using LLM
   - Generate LangGraph StateGraph workflows dynamically
   - Support orchestrator-worker, map-reduce, conditional routing, and parallel execution patterns

2. **Agent Library**
   - Pre-built agents: LLM, Web Scraping, Data Processing, Email, Router, Aggregator, Human-Loop
   - Custom agent registration (bring your own tools)
   - Agent composition and chaining

3. **Workflow Execution Engine**
   - LangGraph-based execution with StateGraph and conditional edges
   - Checkpointing for fault tolerance and resume capability
   - Parallel execution with Send API for map-reduce workflows
   - Real-time progress tracking via WebSocket

4. **YAML Configuration Integration**
   - Store workflows as YAML configs using @workflow/config-sdk
   - Hot-reload support for workflow updates
   - Version control with rollback capability

5. **Event-Driven Coordination**
   - Publishes workflow events to `workflow_events` Kafka topic
   - Integrates with existing services (0, 6, 7, 8, 9, 11, 12, 17, 21)
   - Trigger workflows from external events

### Business Value

- **Democratize Automation**: Non-technical users can create complex workflows with natural language
- **Accelerate Development**: Reduce workflow creation time from days to minutes
- **Reduce Engineering Overhead**: AI agents replace custom code for common tasks
- **Enable Experimentation**: Business users can iterate on workflows without engineering support
- **Cost Optimization**: Reuse agent library across 1000+ workflows instead of building custom integrations

---

## Problem Statement

### Current Challenges

1. **Manual Workflow Creation**: Creating multi-step AI workflows requires:
   - Custom code for each workflow
   - LangGraph expertise (StateGraph, nodes, edges)
   - Integration knowledge (APIs, databases, LLMs)
   - Result: 5-10 days per workflow

2. **Limited Reusability**: Each workflow is a one-off implementation:
   - No shared agent library
   - Duplicate logic across workflows (scraping, LLM calls, email sending)
   - Result: 60% code duplication across workflows

3. **Business User Dependency**: Business users cannot create/modify workflows:
   - Require engineering team for every change
   - Slow iteration cycles (2-week sprint cycles)
   - Result: Business bottlenecks on engineering capacity

4. **Poor Observability**: Existing workflows lack standardized monitoring:
   - No unified execution tracking
   - Hard to debug failures in multi-step workflows
   - Result: Mean time to resolution (MTTR) = 4 hours

### Solution Goals

- **Natural Language Interface**: Users describe workflows in plain English → system generates LangGraph code
- **Agent Library**: Reusable agents (scraping, LLM, email, data processing) reduce development time by 80%
- **Self-Service**: Business users can create/modify workflows without engineering support
- **Standardized Monitoring**: Unified observability across all workflows with OpenTelemetry tracing

---

## Solution Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                Service 23: Dynamic Workflow Engine              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Natural Language  │  │  Workflow       │  │  Execution   │ │
│  │ Parser            │  │  Generator      │  │  Engine      │ │
│  │ (LLM-powered)     │  │  (LangGraph)    │  │  (StateGraph)│ │
│  └────────┬──────────┘  └────────┬────────┘  └──────┬───────┘ │
│           │                      │                   │         │
│  ┌────────┴──────────────────────┴───────────────────┴───────┐ │
│  │                    Agent Library                           │ │
│  │  - LLM Agent        - Scraping Agent    - Email Agent     │ │
│  │  - Router Agent     - Aggregator Agent  - Human-Loop      │ │
│  │  - Data Agent       - API Agent         - Custom Agents   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │  PostgreSQL  │  │    Redis     │  │  @workflow/        │   │
│  │  (workflows, │  │  (execution  │  │  config-sdk        │   │
│  │   execution  │  │   state,     │  │  (YAML storage)    │   │
│  │   logs)      │  │   caching)   │  │                    │   │
│  └──────────────┘  └──────────────┘  └────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │                     │                    │
         ▼                     ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  Kafka Topics    │  │  @workflow/      │  │  Other Services  │
│  workflow_events │  │  llm-sdk         │  │  (0,6,7,8,9,11,  │
│  (publish)       │  │  (LLM inference) │  │   12,17,21)      │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

### Component Responsibilities

**Natural Language Parser**
- Parse user's natural language workflow description
- Identify workflow steps (nodes), dependencies (edges), and data flow
- Extract agent requirements (scraping, LLM, email, etc.)
- Use @workflow/llm-sdk to generate structured workflow specification

**Workflow Generator**
- Generate LangGraph StateGraph code from parsed specification
- Create nodes for each workflow step (agents)
- Add edges (sequential, conditional, parallel) based on dependencies
- Apply workflow patterns (orchestrator-worker, map-reduce, conditional routing)
- Validate generated workflow for correctness

**Execution Engine**
- Execute LangGraph workflows using StateGraph
- Manage workflow state with checkpointing (PostgreSQL)
- Support parallel execution with Send API
- Handle human-in-the-loop with approval nodes
- Track execution progress and publish events

**Agent Library**
- Pre-built agents for common tasks (LLM, scraping, email, data processing)
- Agent registration system for custom agents
- Agent composition (chaining agents)
- Agent parameter validation

---

## Objectives & Requirements

### Functional Requirements

**FR-1: Natural Language Workflow Creation**
1. Accept natural language workflow descriptions (e.g., "Scrape 10 LinkedIn profiles → extract skills → email summary")
2. Parse description using LLM to identify workflow steps, agents, and dependencies
3. Generate structured workflow specification (JSON/YAML)
4. Validate workflow specification for completeness and correctness
5. Generate executable LangGraph StateGraph code
6. Store workflow as YAML config using @workflow/config-sdk
7. Support workflow editing via natural language ("Change step 2 to use GPT-4 instead")
8. Version control workflows with rollback capability
9. Workflow templates for common patterns (scrape-process-notify, research-analyze-report)
10. Dry-run mode to preview workflow execution without running

**FR-2: Workflow Execution**
1. Execute LangGraph workflows with StateGraph and conditional edges
2. Support sequential execution (node A → node B → node C)
3. Support conditional routing (if condition → node A, else → node B)
4. Support parallel execution with map-reduce (fan-out → process in parallel → fan-in)
5. Support orchestrator-worker pattern (orchestrator → dynamic workers → synthesizer)
6. Checkpointing for fault tolerance (resume from failure point)
7. Human-in-the-loop with approval nodes (workflow pauses for human approval)
8. Real-time progress tracking via WebSocket (node completion, state updates)
9. Workflow cancellation mid-execution
10. Retry logic with exponential backoff for failed nodes

**FR-3: Agent Library**
1. **LLM Agent**: Call LLMs (GPT-4, Claude, GPT-3.5) for text generation, analysis, extraction
2. **Web Scraping Agent**: Scrape websites with Playwright (JavaScript rendering support)
3. **Data Processing Agent**: Transform, filter, aggregate data (pandas, JSON manipulation)
4. **Email Agent**: Send emails via SMTP or SendGrid with templates
5. **Router Agent**: Route workflow to different paths based on conditions
6. **Aggregator Agent**: Combine outputs from parallel nodes (map-reduce)
7. **Human-Loop Agent**: Pause workflow for human approval/input
8. **API Agent**: Call external REST APIs with authentication
9. **Database Agent**: Query PostgreSQL, MongoDB, Redis
10. **Custom Agent Registration**: Users can register custom agents with tool specifications

**FR-4: YAML Configuration Integration**
1. Store workflows as YAML configs using @workflow/config-sdk (S3-backed)
2. Workflow YAML structure: metadata, nodes, edges, agents, state_schema
3. Hot-reload support (workflow updates without service restart)
4. Version control with semantic versioning (v1.0.0, v1.1.0, v2.0.0)
5. Rollback to previous versions with one-click
6. Config validation with JSON Schema before deployment
7. Multi-environment support (dev, staging, prod configs)
8. Config inheritance (base workflow → environment-specific overrides)
9. Secret management for API keys, credentials (encrypted in S3)
10. Config diff viewer (compare versions side-by-side)

**FR-5: Event-Driven Integration**
1. Publish workflow events to `workflow_events` Kafka topic
2. Event types: `workflow_created`, `workflow_started`, `workflow_completed`, `workflow_failed`, `node_completed`, `node_failed`
3. Consume events from other services to trigger workflows
4. Example: `demo_completed` → trigger "Send follow-up email" workflow
5. Workflow scheduling (cron-like syntax: "Run daily at 9am")
6. Event-driven workflow chaining (workflow A completes → trigger workflow B)
7. Conditional workflow triggering (if condition → trigger workflow)
8. Idempotent event processing (prevent duplicate workflow executions)
9. Event replay for debugging (replay events to reproduce failures)
10. Cross-service workflow orchestration (orchestrate Services 8, 9, 20)

**FR-6: Integration with Existing Services**
1. **Service 0 (Auth)**: Authenticate users, authorize workflow creation/execution
2. **Service 6 (PRD Builder)**: Trigger workflows from PRD milestones
3. **Service 7 (Automation Engine)**: Complement YAML config generation with dynamic workflows
4. **Service 8 (Chatbot)**: Trigger workflows from chatbot conversations
5. **Service 9 (Voicebot)**: Trigger workflows from voice interactions
6. **Service 11 (Monitoring)**: Monitor workflow execution health, SLAs
7. **Service 12 (Analytics)**: Track workflow performance metrics
8. **Service 17 (RAG Pipeline)**: Use RAG for workflow recommendations
9. **Service 21 (Agent Copilot)**: Suggest workflows to human agents
10. Integration APIs for workflow invocation from any service

**FR-7: Monitoring & Observability**
1. Real-time workflow execution dashboard (active, completed, failed workflows)
2. Node-level execution logs (input, output, duration, errors)
3. Execution timeline visualization (Gantt chart of node execution)
4. Performance metrics (execution time, cost per workflow, success rate)
5. Error tracking with stack traces and retry history
6. Workflow execution history (last 100 executions with filters)
7. Cost tracking (LLM token usage, API calls, execution time)
8. SLA monitoring (alert if workflow exceeds expected duration)
9. OpenTelemetry distributed tracing (trace workflow across services)
10. Prometheus metrics export (workflow_executions_total, workflow_duration_seconds)

### Non-Functional Requirements

**NFR-1: Performance**
- Workflow creation from natural language: <5 seconds
- Workflow execution start: <1 second (minimal cold start)
- Node execution latency: <100ms overhead (excluding agent work)
- Support 1000+ concurrent workflow executions
- LLM parser caching: 40-60% cache hit rate for similar descriptions
- WebSocket update latency: <100ms

**NFR-2: Scalability**
- Support 10,000+ workflows per tenant
- Handle 100,000+ workflow executions/day
- Agent library: 100+ pre-built agents
- Custom agents: 1000+ per tenant
- Horizontal scaling: 10+ pods with Kubernetes
- Database: Handle 1M+ workflow execution records

**NFR-3: Availability**
- 99.9% uptime SLA
- Graceful degradation (continue execution if monitoring unavailable)
- Checkpointing every 10 nodes for fault tolerance
- Automatic retry with exponential backoff (max 3 retries)
- Health check endpoints: `/health`, `/ready`
- Zero-downtime deployments

**NFR-4: Security**
- Multi-tenant isolation (Row-Level Security in PostgreSQL)
- Role-based access control (only workflow owners can execute/modify)
- Audit logging for all workflow operations
- Encrypted secrets storage (API keys, credentials in S3 with KMS)
- Sandboxed agent execution (prevent malicious code execution)
- Rate limiting (100 workflow executions/hour per user)

**NFR-5: Observability**
- OpenTelemetry distributed tracing with trace_id propagation
- Structured logging in JSON format (timestamp, level, workflow_id, node_id)
- Prometheus metrics: `workflow_executions_total`, `workflow_duration_seconds`, `workflow_failures_total`, `agent_execution_duration_seconds`
- Error rate monitoring with automatic alerting (>5% failure rate → alert)
- Cost tracking per workflow (LLM tokens, API calls, compute time)

### Dependencies

**Internal Services:**
- Service 0: Authentication, authorization, user management
- Service 6: PRD Builder integration (trigger workflows from PRD milestones)
- Service 7: Automation Engine integration (complement YAML config generation)
- Service 8: Agent Orchestration (trigger workflows from chatbot)
- Service 9: Voice Agent (trigger workflows from voicebot)
- Service 11: Monitoring Engine (workflow SLA monitoring)
- Service 12: Analytics (workflow performance metrics)
- Service 17: RAG Pipeline (workflow recommendations)
- Service 21: Agent Copilot (suggest workflows to human agents)

**External Services:**
- @workflow/llm-sdk: LLM inference for natural language parsing and agent execution
- @workflow/config-sdk: Workflow storage in S3 with hot-reload
- PostgreSQL (Supabase): Workflow definitions, execution logs, checkpoints
- Redis: Execution state caching, WebSocket connection tracking
- Apache Kafka: Event publishing/consuming for workflow orchestration
- Qdrant: Vector search for workflow recommendations
- OpenTelemetry: Distributed tracing

### Data Storage

**PostgreSQL (Supabase):**
- Workflow definitions (metadata, specification, YAML config reference)
- Workflow executions (status, input, output, logs, checkpoints)
- Agent library (agent definitions, parameters, tool specifications)
- Execution checkpoints (state snapshots for fault tolerance)

**Redis:**
- Execution state cache (active workflows, node status)
- WebSocket connection tracking (workflow_id → connection_id)
- LLM response caching (natural language parser results)

**S3 (via @workflow/config-sdk):**
- Workflow YAML configs (versioned)
- Execution artifacts (large inputs/outputs, files, screenshots)

**Qdrant:**
- Workflow embeddings for similarity search
- Workflow recommendation based on user queries

---

## Features

### Must-Have (MVP)

1. ✅ **Natural Language Workflow Creation**: Parse "scrape LinkedIn → extract skills → email summary" into executable workflow
2. ✅ **Core Agent Library**: LLM, Web Scraping, Email, Data Processing agents
3. ✅ **Sequential Workflow Execution**: Execute workflows step-by-step with StateGraph
4. ✅ **Workflow Storage**: Store workflows as YAML configs using @workflow/config-sdk
5. ✅ **Execution Tracking**: Real-time progress via WebSocket
6. ✅ **Error Handling**: Retry logic with exponential backoff
7. ✅ **Checkpointing**: Resume workflows from failure point
8. ✅ **Multi-Tenancy**: Row-Level Security for workflow isolation
9. ✅ **Kafka Integration**: Publish workflow events to `workflow_events` topic
10. ✅ **Basic Monitoring**: Execution logs, success/failure tracking

### Nice-to-Have (Post-MVP)

11. 🔄 **Parallel Execution**: Map-reduce workflows with Send API
12. 🔄 **Orchestrator-Worker Pattern**: Dynamic task delegation
13. 🔄 **Human-in-the-Loop**: Approval nodes for human review
14. 🔄 **Custom Agent Registration**: Users can bring their own agents
15. 🔄 **Workflow Templates**: Pre-built templates for common use cases
16. 🔄 **Conditional Routing**: If-else logic in workflows
17. 🔄 **Workflow Scheduling**: Cron-like scheduling (daily, weekly, monthly)
18. 🔄 **Advanced Monitoring**: Gantt charts, cost tracking, SLA alerting
19. 🔄 **Workflow Marketplace**: Share workflows with other users
20. 🔄 **AI Workflow Optimization**: LLM suggests improvements to workflows

### Feature Interactions

**With Service 21 (Agent Copilot):**
- Agent Copilot suggests workflows to human agents based on client context
- Example: "Client health score dropped → suggest workflow: Analyze support tickets → Generate retention strategy → Send to Success Manager"

**With Service 8 (Chatbot):**
- Chatbot triggers workflows from user conversations
- Example: User asks "Send me a report of all open tickets" → Trigger workflow: Query tickets → Generate report → Email to user

**With Service 6 (PRD Builder):**
- Trigger workflows when PRD milestones are reached
- Example: PRD approved → Trigger workflow: Generate config → Create GitHub issues → Notify team

**With Service 17 (RAG Pipeline):**
- Use RAG to recommend workflows based on user queries
- Example: User types "I need to analyze customer feedback" → RAG suggests similar workflows: "Scrape reviews → Sentiment analysis → Generate insights"

---

## Architecture

### LangGraph Workflow Patterns

**1. Sequential (Simple Chain)**
```
┌──────────┐    ┌──────────┐    ┌──────────┐
│  Node A  │ -> │  Node B  │ -> │  Node C  │
└──────────┘    └──────────┘    └──────────┘
```

**2. Conditional Routing**
```
┌──────────┐
│  Node A  │
└─────┬────┘
      │
      ├──────> if condition1 ──> Node B
      │
      └──────> else ──────────> Node C
```

**3. Parallel Execution (Map-Reduce)**
```
┌──────────┐
│  Map     │
│  Node    │
└─────┬────┘
      │
      ├──────> Worker 1 ─┐
      │                  │
      ├──────> Worker 2 ─┼──> Reduce
      │                  │    Node
      └──────> Worker 3 ─┘
```

**4. Orchestrator-Worker**
```
┌──────────────┐
│ Orchestrator │
│ (breaks task)│
└──────┬───────┘
       │
       ├──────> Dynamic Worker 1 ─┐
       │                          │
       ├──────> Dynamic Worker 2 ─┼──> Synthesizer
       │                          │
       └──────> Dynamic Worker N ─┘
```

**5. Human-in-the-Loop**
```
┌──────────┐    ┌──────────┐    ┌──────────┐
│  Node A  │ -> │  Human   │ -> │  Node C  │
│          │    │ Approval │    │          │
└──────────┘    └──────────┘    └──────────┘
```

---

## Natural Language Workflow Specification

### Example 1: LinkedIn Skills Extraction

**User Input:**
```
"Scrape 10 LinkedIn profiles → extract skills with LLM → email summary to me"
```

**Parsed Workflow:**
```json
{
  "name": "LinkedIn Skills Extraction",
  "description": "Scrape LinkedIn profiles and extract skills",
  "pattern": "sequential",
  "nodes": [
    {
      "id": "scrape_profiles",
      "agent": "web_scraping",
      "parameters": {
        "urls": ["https://linkedin.com/in/profile1", "...", "profile10"],
        "selector": ".profile-section"
      },
      "output": "profiles_html"
    },
    {
      "id": "extract_skills",
      "agent": "llm",
      "parameters": {
        "model": "gpt-4",
        "prompt": "Extract skills from the following LinkedIn profiles: {profiles_html}",
        "output_format": "json_array"
      },
      "input": ["profiles_html"],
      "output": "skills_json"
    },
    {
      "id": "send_email",
      "agent": "email",
      "parameters": {
        "to": "{user.email}",
        "subject": "LinkedIn Skills Summary",
        "body": "Here are the extracted skills: {skills_json}"
      },
      "input": ["skills_json"]
    }
  ],
  "edges": [
    {"from": "scrape_profiles", "to": "extract_skills"},
    {"from": "extract_skills", "to": "send_email"}
  ]
}
```

### Example 2: Customer Feedback Analysis (Parallel)

**User Input:**
```
"Scrape 100 customer reviews → analyze sentiment in parallel → generate insights report"
```

**Parsed Workflow:**
```json
{
  "name": "Customer Feedback Analysis",
  "pattern": "map_reduce",
  "nodes": [
    {
      "id": "scrape_reviews",
      "agent": "web_scraping",
      "parameters": {
        "url": "https://reviews.example.com",
        "limit": 100
      },
      "output": "reviews"
    },
    {
      "id": "map_sentiment",
      "agent": "llm",
      "pattern": "map",
      "parameters": {
        "model": "gpt-3.5",
        "prompt": "Analyze sentiment of this review: {review}",
        "batch_size": 10
      },
      "input": ["reviews"],
      "output": "sentiments"
    },
    {
      "id": "aggregate_insights",
      "agent": "aggregator",
      "parameters": {
        "aggregation": "summarize",
        "format": "markdown_report"
      },
      "input": ["sentiments"],
      "output": "insights_report"
    }
  ],
  "edges": [
    {"from": "scrape_reviews", "to": "map_sentiment"},
    {"from": "map_sentiment", "to": "aggregate_insights"}
  ]
}
```

### Example 3: Conditional Routing

**User Input:**
```
"Check website uptime → if down, send alert to Slack; if up, log to database"
```

**Parsed Workflow:**
```json
{
  "name": "Website Uptime Monitor",
  "pattern": "conditional",
  "nodes": [
    {
      "id": "check_uptime",
      "agent": "api",
      "parameters": {
        "url": "https://example.com",
        "method": "GET",
        "timeout": 5
      },
      "output": "uptime_status"
    },
    {
      "id": "router",
      "agent": "router",
      "parameters": {
        "condition": "uptime_status.status_code != 200",
        "if_true": "send_slack_alert",
        "if_false": "log_to_db"
      },
      "input": ["uptime_status"]
    },
    {
      "id": "send_slack_alert",
      "agent": "api",
      "parameters": {
        "url": "https://hooks.slack.com/services/...",
        "method": "POST",
        "body": {"text": "Website is down!"}
      }
    },
    {
      "id": "log_to_db",
      "agent": "database",
      "parameters": {
        "query": "INSERT INTO uptime_logs (status, timestamp) VALUES ($1, NOW())",
        "params": ["{uptime_status.status_code}"]
      }
    }
  ],
  "edges": [
    {"from": "check_uptime", "to": "router"},
    {"from": "router", "to": "send_slack_alert", "condition": "uptime_down"},
    {"from": "router", "to": "log_to_db", "condition": "uptime_up"}
  ]
}
```

---

## Workflow Specification Format

### YAML Workflow Config

```yaml
# Stored in S3 via @workflow/config-sdk
# Path: /workflows/{tenant_id}/{workflow_id}.yaml

metadata:
  id: "wf_001"
  name: "LinkedIn Skills Extraction"
  description: "Scrape LinkedIn profiles and extract skills"
  version: "1.0.0"
  created_by: "user_001"
  created_at: "2025-10-08T10:00:00Z"
  updated_at: "2025-10-08T10:00:00Z"
  tags: ["scraping", "llm", "linkedin"]

pattern: "sequential"  # sequential | conditional | map_reduce | orchestrator_worker

state_schema:
  input:
    type: "object"
    properties:
      profile_urls:
        type: "array"
        items:
          type: "string"
      user_email:
        type: "string"
  output:
    type: "object"
    properties:
      skills:
        type: "array"
      email_sent:
        type: "boolean"

nodes:
  - id: "scrape_profiles"
    agent: "web_scraping"
    description: "Scrape LinkedIn profiles"
    parameters:
      urls: "{input.profile_urls}"
      selector: ".profile-section"
      wait_for_load: true
      timeout: 30
    output_key: "profiles_html"
    retry:
      max_attempts: 3
      backoff: "exponential"
    timeout: 120

  - id: "extract_skills"
    agent: "llm"
    description: "Extract skills from profiles using LLM"
    parameters:
      model: "gpt-4"
      temperature: 0.3
      prompt: |
        Extract skills from the following LinkedIn profiles.
        Return JSON array of skills: ["skill1", "skill2", ...]

        Profiles:
        {state.profiles_html}
      output_format: "json"
    input_keys: ["profiles_html"]
    output_key: "skills_json"
    retry:
      max_attempts: 2
      backoff: "exponential"
    timeout: 60

  - id: "send_email"
    agent: "email"
    description: "Email skills summary to user"
    parameters:
      to: "{input.user_email}"
      subject: "LinkedIn Skills Summary"
      body: |
        Hello,

        Here are the extracted skills from LinkedIn profiles:

        {state.skills_json}

        Best,
        Workflow Engine
    input_keys: ["skills_json"]
    timeout: 30

edges:
  - from: "scrape_profiles"
    to: "extract_skills"
    type: "sequential"

  - from: "extract_skills"
    to: "send_email"
    type: "sequential"

settings:
  checkpointing:
    enabled: true
    frequency: "every_node"  # every_node | every_5_nodes | on_failure

  error_handling:
    on_failure: "rollback"  # rollback | continue | stop
    notify_on_failure: true
    notification_channel: "slack"

  monitoring:
    track_cost: true
    track_duration: true
    alert_on_sla_breach: true
    sla_seconds: 300

  execution:
    max_concurrent_nodes: 5
    timeout_seconds: 600
```

---

## Agent Library

### 1. LLM Agent

**Purpose**: Call LLMs for text generation, analysis, extraction, classification

**Parameters:**
- `model`: "gpt-4" | "gpt-3.5" | "claude-opus" | "claude-sonnet"
- `temperature`: 0.0 - 2.0 (default: 0.7)
- `prompt`: Template with variable substitution
- `output_format`: "text" | "json" | "markdown"
- `max_tokens`: 100 - 4000

**Example:**
```yaml
agent: "llm"
parameters:
  model: "gpt-4"
  temperature: 0.3
  prompt: "Summarize the following text in 3 bullet points: {input_text}"
  output_format: "markdown"
  max_tokens: 500
```

---

### 2. Web Scraping Agent

**Purpose**: Scrape websites with JavaScript rendering support (Playwright)

**Parameters:**
- `urls`: Array of URLs or single URL
- `selector`: CSS selector for content extraction
- `wait_for_load`: true | false (wait for dynamic content)
- `screenshot`: true | false (capture screenshot)
- `timeout`: Seconds to wait for page load

**Example:**
```yaml
agent: "web_scraping"
parameters:
  urls: ["https://example.com/page1", "https://example.com/page2"]
  selector: ".article-content"
  wait_for_load: true
  screenshot: false
  timeout: 30
```

---

### 3. Data Processing Agent

**Purpose**: Transform, filter, aggregate data

**Parameters:**
- `operation`: "filter" | "map" | "reduce" | "aggregate" | "transform"
- `script`: Python or JavaScript code for custom processing
- `input_format`: "json" | "csv" | "text"
- `output_format`: "json" | "csv" | "text"

**Example:**
```yaml
agent: "data_processing"
parameters:
  operation: "filter"
  script: |
    # Filter items where score > 0.5
    return [item for item in data if item['score'] > 0.5]
  input_format: "json"
  output_format: "json"
```

---

### 4. Email Agent

**Purpose**: Send emails via SMTP or SendGrid

**Parameters:**
- `to`: Recipient email (supports templates)
- `cc`: CC recipients (optional)
- `subject`: Email subject
- `body`: Email body (supports HTML and templates)
- `attachments`: Array of file paths (optional)

**Example:**
```yaml
agent: "email"
parameters:
  to: "{user.email}"
  subject: "Workflow Completed: {workflow.name}"
  body: |
    Hello {user.name},

    Your workflow "{workflow.name}" has completed successfully.

    Results: {workflow.output}
  attachments: ["/tmp/report.pdf"]
```

---

### 5. Router Agent

**Purpose**: Route workflow to different paths based on conditions

**Parameters:**
- `condition`: Python expression to evaluate
- `if_true`: Node ID to route to if condition is true
- `if_false`: Node ID to route to if condition is false
- `default`: Default node if condition evaluation fails

**Example:**
```yaml
agent: "router"
parameters:
  condition: "state['score'] > 0.8"
  if_true: "send_success_email"
  if_false: "send_failure_email"
  default: "log_error"
```

---

### 6. Aggregator Agent

**Purpose**: Combine outputs from parallel nodes (map-reduce)

**Parameters:**
- `aggregation`: "concat" | "sum" | "average" | "max" | "min" | "summarize"
- `format`: "json" | "text" | "markdown_report"
- `custom_script`: Python script for custom aggregation

**Example:**
```yaml
agent: "aggregator"
parameters:
  aggregation: "summarize"
  format: "markdown_report"
  custom_script: |
    # Custom aggregation logic
    total_score = sum(item['score'] for item in results)
    return {"total_score": total_score, "count": len(results)}
```

---

### 7. Human-Loop Agent

**Purpose**: Pause workflow for human approval/input

**Parameters:**
- `message`: Message to display to human reviewer
- `approval_type`: "approve_reject" | "text_input" | "multiple_choice"
- `timeout`: Seconds to wait for approval (default: 3600 = 1 hour)
- `on_timeout`: "reject" | "approve" | "cancel"

**Example:**
```yaml
agent: "human_loop"
parameters:
  message: "Review the following data before proceeding: {data}"
  approval_type: "approve_reject"
  timeout: 1800  # 30 minutes
  on_timeout: "reject"
```

---

### 8. API Agent

**Purpose**: Call external REST APIs

**Parameters:**
- `url`: API endpoint
- `method`: "GET" | "POST" | "PUT" | "DELETE"
- `headers`: Request headers (e.g., Authorization)
- `body`: Request body for POST/PUT
- `timeout`: Request timeout in seconds

**Example:**
```yaml
agent: "api"
parameters:
  url: "https://api.example.com/data"
  method: "POST"
  headers:
    Authorization: "Bearer {secrets.api_token}"
    Content-Type: "application/json"
  body:
    data: "{state.processed_data}"
  timeout: 30
```

---

### 9. Database Agent

**Purpose**: Query PostgreSQL, MongoDB, or Redis

**Parameters:**
- `database`: "postgresql" | "mongodb" | "redis"
- `connection_string`: Database connection string
- `query`: SQL query (PostgreSQL) or command (MongoDB/Redis)
- `params`: Query parameters for safe parameterization

**Example:**
```yaml
agent: "database"
parameters:
  database: "postgresql"
  connection_string: "{secrets.postgres_url}"
  query: "INSERT INTO workflow_results (workflow_id, result) VALUES ($1, $2)"
  params: ["{workflow.id}", "{state.result}"]
```

---

### 10. Custom Agent Registration

**Users can register custom agents:**

**POST** `/api/v1/workflows/agents/register`

```json
{
  "agent_name": "my_custom_agent",
  "description": "Custom agent for specific task",
  "tool_specification": {
    "parameters": {
      "param1": {"type": "string", "required": true},
      "param2": {"type": "integer", "default": 10}
    },
    "returns": {
      "type": "object",
      "properties": {
        "result": {"type": "string"}
      }
    }
  },
  "implementation": {
    "type": "python_function",
    "code": "def execute(param1, param2): return {'result': f'{param1}_{param2}'}"
  }
}
```

---

## API Specification

### 1. Create Workflow from Natural Language

**POST** `/api/v1/workflows/create`

Create a workflow from natural language description.

**Request Body:**
```json
{
  "organization_id": "org_123",
  "description": "Scrape 10 LinkedIn profiles → extract skills with LLM → email summary",
  "name": "LinkedIn Skills Extraction",
  "tags": ["scraping", "llm", "linkedin"],
  "dry_run": false
}
```

**Response** (201 Created):
```json
{
  "workflow_id": "wf_001",
  "name": "LinkedIn Skills Extraction",
  "status": "active",
  "parsed_specification": {
    "pattern": "sequential",
    "nodes": [
      {"id": "scrape_profiles", "agent": "web_scraping"},
      {"id": "extract_skills", "agent": "llm"},
      {"id": "send_email", "agent": "email"}
    ],
    "edges": [
      {"from": "scrape_profiles", "to": "extract_skills"},
      {"from": "extract_skills", "to": "send_email"}
    ]
  },
  "yaml_config_url": "s3://workflow-configs/org_123/wf_001.yaml",
  "version": "1.0.0",
  "created_at": "2025-10-08T10:00:00Z"
}
```

---

### 2. Execute Workflow

**POST** `/api/v1/workflows/{workflow_id}/execute`

Execute a workflow with input data.

**Request Body:**
```json
{
  "organization_id": "org_123",
  "input": {
    "profile_urls": [
      "https://linkedin.com/in/profile1",
      "https://linkedin.com/in/profile2"
    ],
    "user_email": "user@example.com"
  },
  "options": {
    "async": true,
    "webhook_url": "https://example.com/webhook",
    "timeout_seconds": 300
  }
}
```

**Response** (202 Accepted):
```json
{
  "execution_id": "exec_001",
  "workflow_id": "wf_001",
  "status": "running",
  "progress": {
    "total_nodes": 3,
    "completed_nodes": 0,
    "current_node": "scrape_profiles"
  },
  "started_at": "2025-10-08T10:05:00Z",
  "estimated_completion": "2025-10-08T10:10:00Z",
  "websocket_url": "wss://api.company.com/v1/workflows/executions/exec_001/stream"
}
```

---

### 3. Get Execution Status

**GET** `/api/v1/workflows/executions/{execution_id}`

Get real-time status of workflow execution.

**Response** (200 OK):
```json
{
  "execution_id": "exec_001",
  "workflow_id": "wf_001",
  "status": "completed",
  "progress": {
    "total_nodes": 3,
    "completed_nodes": 3,
    "failed_nodes": 0
  },
  "nodes": [
    {
      "node_id": "scrape_profiles",
      "status": "completed",
      "started_at": "2025-10-08T10:05:00Z",
      "completed_at": "2025-10-08T10:06:30Z",
      "duration_seconds": 90,
      "output": {"profiles_html": "..."}
    },
    {
      "node_id": "extract_skills",
      "status": "completed",
      "started_at": "2025-10-08T10:06:30Z",
      "completed_at": "2025-10-08T10:08:00Z",
      "duration_seconds": 90,
      "output": {"skills_json": ["Python", "JavaScript", "..."]}
    },
    {
      "node_id": "send_email",
      "status": "completed",
      "started_at": "2025-10-08T10:08:00Z",
      "completed_at": "2025-10-08T10:08:10Z",
      "duration_seconds": 10,
      "output": {"email_sent": true}
    }
  ],
  "output": {
    "skills": ["Python", "JavaScript", "Machine Learning"],
    "email_sent": true
  },
  "started_at": "2025-10-08T10:05:00Z",
  "completed_at": "2025-10-08T10:08:10Z",
  "duration_seconds": 190,
  "cost": {
    "llm_tokens": 1500,
    "api_calls": 12,
    "total_usd": 0.15
  }
}
```

---

### 4. Cancel Workflow Execution

**POST** `/api/v1/workflows/executions/{execution_id}/cancel`

Cancel a running workflow execution.

**Response** (200 OK):
```json
{
  "execution_id": "exec_001",
  "status": "cancelled",
  "cancelled_at": "2025-10-08T10:07:00Z",
  "message": "Workflow execution cancelled by user",
  "completed_nodes": 1,
  "pending_nodes": 2
}
```

---

### 5. List Workflows

**GET** `/api/v1/workflows`

List all workflows for an organization.

**Query Parameters:**
- `organization_id` (required)
- `status`: "active" | "archived"
- `tags`: Comma-separated tags
- `limit`: Number of results (default: 50)
- `offset`: Pagination offset

**Response** (200 OK):
```json
{
  "workflows": [
    {
      "workflow_id": "wf_001",
      "name": "LinkedIn Skills Extraction",
      "description": "Scrape LinkedIn profiles and extract skills",
      "status": "active",
      "version": "1.0.0",
      "tags": ["scraping", "llm", "linkedin"],
      "executions_count": 145,
      "last_executed": "2025-10-08T09:00:00Z",
      "created_at": "2025-10-01T10:00:00Z"
    }
  ],
  "total": 25,
  "limit": 50,
  "offset": 0
}
```

---

### 6. Update Workflow

**PUT** `/api/v1/workflows/{workflow_id}`

Update workflow from natural language description.

**Request Body:**
```json
{
  "organization_id": "org_123",
  "description": "Change step 2 to use GPT-3.5 instead of GPT-4",
  "version_increment": "patch"
}
```

**Response** (200 OK):
```json
{
  "workflow_id": "wf_001",
  "version": "1.0.1",
  "changes": [
    {
      "node_id": "extract_skills",
      "field": "parameters.model",
      "old_value": "gpt-4",
      "new_value": "gpt-3.5"
    }
  ],
  "yaml_config_url": "s3://workflow-configs/org_123/wf_001_v1.0.1.yaml",
  "updated_at": "2025-10-08T11:00:00Z"
}
```

---

### 7. Rollback Workflow

**POST** `/api/v1/workflows/{workflow_id}/rollback`

Rollback workflow to previous version.

**Request Body:**
```json
{
  "organization_id": "org_123",
  "target_version": "1.0.0"
}
```

**Response** (200 OK):
```json
{
  "workflow_id": "wf_001",
  "current_version": "1.0.0",
  "previous_version": "1.0.1",
  "rolled_back_at": "2025-10-08T11:30:00Z"
}
```

---

### 8. Get Workflow Execution History

**GET** `/api/v1/workflows/{workflow_id}/executions`

Get execution history for a workflow.

**Query Parameters:**
- `status`: "completed" | "failed" | "running" | "cancelled"
- `limit`: Number of results (default: 100)
- `offset`: Pagination offset

**Response** (200 OK):
```json
{
  "executions": [
    {
      "execution_id": "exec_001",
      "status": "completed",
      "duration_seconds": 190,
      "cost_usd": 0.15,
      "started_at": "2025-10-08T10:05:00Z",
      "completed_at": "2025-10-08T10:08:10Z"
    }
  ],
  "total": 145,
  "success_rate": 0.95,
  "avg_duration_seconds": 185,
  "total_cost_usd": 21.75
}
```

---

### 9. Register Custom Agent

**POST** `/api/v1/workflows/agents/register`

Register a custom agent for use in workflows.

**Request Body:**
```json
{
  "organization_id": "org_123",
  "agent_name": "my_custom_agent",
  "description": "Custom agent for specific task",
  "tool_specification": {
    "parameters": {
      "param1": {"type": "string", "required": true},
      "param2": {"type": "integer", "default": 10}
    },
    "returns": {
      "type": "object",
      "properties": {
        "result": {"type": "string"}
      }
    }
  },
  "implementation": {
    "type": "python_function",
    "code": "def execute(param1, param2):\n    return {'result': f'{param1}_{param2}'}"
  }
}
```

**Response** (201 Created):
```json
{
  "agent_id": "agent_custom_001",
  "agent_name": "my_custom_agent",
  "status": "active",
  "registered_at": "2025-10-08T12:00:00Z"
}
```

---

### 10. WebSocket: Real-Time Execution Updates

**WebSocket** `wss://api.company.com/v1/workflows/executions/{execution_id}/stream`

Subscribe to real-time workflow execution updates.

**Connection**:
```javascript
const ws = new WebSocket('wss://api.company.com/v1/workflows/executions/exec_001/stream', {
  headers: {
    'Authorization': 'Bearer <jwt_token>',
    'X-Tenant-ID': 'org_123'
  }
});
```

**Receive Updates**:
```json
{
  "type": "node_started",
  "execution_id": "exec_001",
  "node_id": "scrape_profiles",
  "timestamp": "2025-10-08T10:05:00Z"
}
```

```json
{
  "type": "node_completed",
  "execution_id": "exec_001",
  "node_id": "scrape_profiles",
  "duration_seconds": 90,
  "output": {"profiles_html": "..."},
  "timestamp": "2025-10-08T10:06:30Z"
}
```

```json
{
  "type": "workflow_completed",
  "execution_id": "exec_001",
  "status": "completed",
  "output": {"skills": ["Python", "JavaScript"], "email_sent": true},
  "duration_seconds": 190,
  "timestamp": "2025-10-08T10:08:10Z"
}
```

---

## Database Schema

### PostgreSQL Tables

#### 1. workflows

Stores workflow definitions and metadata.

```sql
CREATE TABLE workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,

  -- Workflow metadata
  name VARCHAR(255) NOT NULL,
  description TEXT,
  version VARCHAR(20) NOT NULL DEFAULT '1.0.0',
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived', 'deprecated')),

  -- Workflow specification
  pattern VARCHAR(50) NOT NULL CHECK (pattern IN ('sequential', 'conditional', 'map_reduce', 'orchestrator_worker')),
  specification JSONB NOT NULL,  -- Parsed workflow specification
  yaml_config_url TEXT NOT NULL,  -- S3 URL to YAML config

  -- Tags and categorization
  tags TEXT[] DEFAULT '{}',

  -- Usage tracking
  executions_count INTEGER DEFAULT 0,
  last_executed_at TIMESTAMPTZ,

  -- Metadata
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::UUID)
);

CREATE INDEX idx_workflows_tenant ON workflows(tenant_id);
CREATE INDEX idx_workflows_org ON workflows(organization_id);
CREATE INDEX idx_workflows_status ON workflows(status);
CREATE INDEX idx_workflows_tags ON workflows USING gin(tags);

ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON workflows
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

#### 2. workflow_executions

Stores workflow execution records.

```sql
CREATE TABLE workflow_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  workflow_id UUID REFERENCES workflows(id) NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,

  -- Execution status
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),

  -- Input/Output
  input_data JSONB DEFAULT '{}',
  output_data JSONB DEFAULT '{}',

  -- Progress tracking
  total_nodes INTEGER,
  completed_nodes INTEGER DEFAULT 0,
  failed_nodes INTEGER DEFAULT 0,
  current_node_id VARCHAR(100),

  -- Timing
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_seconds INTEGER,

  -- Error tracking
  error_message TEXT,
  error_node_id VARCHAR(100),
  retry_count INTEGER DEFAULT 0,

  -- Cost tracking
  llm_tokens_used INTEGER DEFAULT 0,
  api_calls_made INTEGER DEFAULT 0,
  cost_usd DECIMAL(10,4) DEFAULT 0.00,

  -- Metadata
  triggered_by VARCHAR(50),  -- 'user', 'event', 'schedule', 'api'
  webhook_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::UUID)
);

CREATE INDEX idx_exec_tenant ON workflow_executions(tenant_id);
CREATE INDEX idx_exec_workflow ON workflow_executions(workflow_id);
CREATE INDEX idx_exec_org ON workflow_executions(organization_id);
CREATE INDEX idx_exec_status ON workflow_executions(status);
CREATE INDEX idx_exec_created ON workflow_executions(created_at DESC);

ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON workflow_executions
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

#### 3. execution_node_logs

Stores node-level execution logs.

```sql
CREATE TABLE execution_node_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  execution_id UUID REFERENCES workflow_executions(id) NOT NULL,

  -- Node details
  node_id VARCHAR(100) NOT NULL,
  agent_name VARCHAR(100) NOT NULL,

  -- Execution status
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'running', 'completed', 'failed', 'skipped')),

  -- Input/Output
  input_data JSONB DEFAULT '{}',
  output_data JSONB DEFAULT '{}',

  -- Timing
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_seconds INTEGER,

  -- Error tracking
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,

  -- Cost tracking
  llm_tokens_used INTEGER DEFAULT 0,
  api_calls_made INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::UUID)
);

CREATE INDEX idx_node_logs_tenant ON execution_node_logs(tenant_id);
CREATE INDEX idx_node_logs_execution ON execution_node_logs(execution_id);
CREATE INDEX idx_node_logs_status ON execution_node_logs(status);

ALTER TABLE execution_node_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON execution_node_logs
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

#### 4. execution_checkpoints

Stores workflow state checkpoints for fault tolerance.

```sql
CREATE TABLE execution_checkpoints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  execution_id UUID REFERENCES workflow_executions(id) NOT NULL,

  -- Checkpoint details
  checkpoint_number INTEGER NOT NULL,
  node_id VARCHAR(100) NOT NULL,

  -- State snapshot
  state_snapshot JSONB NOT NULL,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::UUID)
);

CREATE INDEX idx_checkpoints_tenant ON execution_checkpoints(tenant_id);
CREATE INDEX idx_checkpoints_execution ON execution_checkpoints(execution_id);
CREATE UNIQUE INDEX idx_checkpoints_exec_number ON execution_checkpoints(execution_id, checkpoint_number);

ALTER TABLE execution_checkpoints ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON execution_checkpoints
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

#### 5. custom_agents

Stores custom agent registrations.

```sql
CREATE TABLE custom_agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,

  -- Agent details
  agent_name VARCHAR(100) NOT NULL,
  description TEXT,

  -- Tool specification
  tool_specification JSONB NOT NULL,

  -- Implementation
  implementation_type VARCHAR(50) NOT NULL CHECK (implementation_type IN ('python_function', 'api_endpoint', 'docker_container')),
  implementation_code TEXT,
  implementation_url TEXT,

  -- Status
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'deprecated')),

  -- Usage tracking
  usage_count INTEGER DEFAULT 0,

  -- Metadata
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::UUID)
);

CREATE INDEX idx_custom_agents_tenant ON custom_agents(tenant_id);
CREATE INDEX idx_custom_agents_org ON custom_agents(organization_id);
CREATE INDEX idx_custom_agents_status ON custom_agents(status);
CREATE UNIQUE INDEX idx_custom_agents_name_org ON custom_agents(agent_name, organization_id);

ALTER TABLE custom_agents ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON custom_agents
  USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

---

### Redis Data Structures

**1. Execution State Cache**
```
Key: workflow:execution:{execution_id}:state
Type: Hash
TTL: 1 hour
Fields:
  - status: "running"
  - current_node: "extract_skills"
  - completed_nodes: "2"
  - total_nodes: "3"
```

**2. WebSocket Connection Tracking**
```
Key: workflow:execution:{execution_id}:ws
Type: Set
TTL: 1 hour
Members: [connection_id_1, connection_id_2]
```

**3. LLM Response Caching**
```
Key: workflow:parser:cache:{hash_of_description}
Type: String (JSON)
TTL: 24 hours
Value: Parsed workflow specification
```

**4. Execution Queue**
```
Key: workflow:execution:queue
Type: Sorted Set
Score: scheduled_at_timestamp
Members: execution_id
```

---

## Event-Driven Integration

### Kafka Topics Published

**Topic**: `workflow_events`

**Event Types:**

1. **workflow_created**
```json
{
  "event_type": "workflow_created",
  "event_id": "evt_001",
  "tenant_id": "tenant_001",
  "organization_id": "org_123",
  "workflow_id": "wf_001",
  "timestamp": "2025-10-08T10:00:00Z",
  "payload": {
    "name": "LinkedIn Skills Extraction",
    "pattern": "sequential",
    "version": "1.0.0",
    "created_by": "user_001"
  }
}
```

2. **workflow_started**
```json
{
  "event_type": "workflow_started",
  "event_id": "evt_002",
  "tenant_id": "tenant_001",
  "organization_id": "org_123",
  "workflow_id": "wf_001",
  "execution_id": "exec_001",
  "timestamp": "2025-10-08T10:05:00Z",
  "payload": {
    "triggered_by": "user",
    "input_data": {"profile_urls": ["..."]},
    "total_nodes": 3
  }
}
```

3. **workflow_completed**
```json
{
  "event_type": "workflow_completed",
  "event_id": "evt_003",
  "tenant_id": "tenant_001",
  "organization_id": "org_123",
  "workflow_id": "wf_001",
  "execution_id": "exec_001",
  "timestamp": "2025-10-08T10:08:10Z",
  "payload": {
    "status": "completed",
    "duration_seconds": 190,
    "output_data": {"skills": ["Python", "JavaScript"], "email_sent": true},
    "cost_usd": 0.15
  }
}
```

4. **workflow_failed**
```json
{
  "event_type": "workflow_failed",
  "event_id": "evt_004",
  "tenant_id": "tenant_001",
  "organization_id": "org_123",
  "workflow_id": "wf_001",
  "execution_id": "exec_001",
  "timestamp": "2025-10-08T10:07:00Z",
  "payload": {
    "error_node_id": "extract_skills",
    "error_message": "LLM rate limit exceeded",
    "retry_count": 3,
    "duration_seconds": 120
  }
}
```

5. **node_completed**
```json
{
  "event_type": "node_completed",
  "event_id": "evt_005",
  "tenant_id": "tenant_001",
  "execution_id": "exec_001",
  "timestamp": "2025-10-08T10:06:30Z",
  "payload": {
    "node_id": "scrape_profiles",
    "agent_name": "web_scraping",
    "duration_seconds": 90,
    "output_data": {"profiles_html": "..."}
  }
}
```

---

### Kafka Topics Consumed

Service 23 can consume events from other services to trigger workflows:

**1. From Service 2 (Demo Generator):**
- Topic: `demo_events`
- Event: `demo_completed` → Trigger "Send follow-up email" workflow

**2. From Service 6 (PRD Builder):**
- Topic: `prd_events`
- Event: `prd_approved` → Trigger "Generate config and create GitHub issues" workflow

**3. From Service 8 (Chatbot):**
- Topic: `conversation_events`
- Event: `conversation_escalated` → Trigger "Analyze conversation and notify support" workflow

**4. From Service 13 (Customer Success):**
- Topic: `customer_success_events`
- Event: `health_score_dropped` → Trigger "Analyze churn risk and suggest retention strategy" workflow

---

### Event Handler Pattern

```python
@kafka_consumer("demo_events")
async def handle_demo_completed(event: dict):
    """
    Trigger follow-up workflow when demo completed.
    """
    organization_id = event["organization_id"]
    demo_id = event["demo_id"]

    # Find workflow configured for this trigger
    workflow = await db.fetchrow(
        """
        SELECT * FROM workflows
        WHERE organization_id = $1
        AND specification->>'trigger_event' = 'demo_completed'
        AND status = 'active'
        """,
        organization_id
    )

    if not workflow:
        logger.info(f"No workflow configured for demo_completed trigger")
        return

    # Execute workflow
    execution_id = await execute_workflow(
        workflow_id=workflow["id"],
        input_data={
            "demo_id": demo_id,
            "organization_id": organization_id,
            "demo_feedback": event.get("feedback_score")
        },
        triggered_by="event"
    )

    logger.info(f"Triggered workflow {workflow['id']} (execution: {execution_id}) from demo_completed event")
```

---

## LangGraph Implementation

### StateGraph Workflow Generation

**Example: Sequential Workflow**

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

# Define state
class WorkflowState(TypedDict):
    profiles_html: str
    skills_json: list
    email_sent: bool
    error: str

# Create StateGraph
workflow_graph = StateGraph(WorkflowState)

# Add nodes
async def scrape_profiles_node(state: WorkflowState) -> WorkflowState:
    """Scrape LinkedIn profiles."""
    from workflow_agents import WebScrapingAgent

    agent = WebScrapingAgent()
    profiles_html = await agent.execute(
        urls=state["input"]["profile_urls"],
        selector=".profile-section"
    )

    return {"profiles_html": profiles_html}

async def extract_skills_node(state: WorkflowState) -> WorkflowState:
    """Extract skills using LLM."""
    from workflow_llm_sdk import LLMClient

    llm_client = LLMClient(model="gpt-4")
    skills_json = await llm_client.generate(
        prompt=f"Extract skills from: {state['profiles_html']}",
        output_format="json"
    )

    return {"skills_json": skills_json}

async def send_email_node(state: WorkflowState) -> WorkflowState:
    """Send email summary."""
    from workflow_agents import EmailAgent

    agent = EmailAgent()
    await agent.execute(
        to=state["input"]["user_email"],
        subject="LinkedIn Skills Summary",
        body=f"Skills: {state['skills_json']}"
    )

    return {"email_sent": True}

# Add nodes to graph
workflow_graph.add_node("scrape_profiles", scrape_profiles_node)
workflow_graph.add_node("extract_skills", extract_skills_node)
workflow_graph.add_node("send_email", send_email_node)

# Add edges
workflow_graph.set_entry_point("scrape_profiles")
workflow_graph.add_edge("scrape_profiles", "extract_skills")
workflow_graph.add_edge("extract_skills", "send_email")
workflow_graph.add_edge("send_email", END)

# Compile graph
compiled_workflow = workflow_graph.compile()
```

---

### Conditional Routing with Edges

**Example: Router Agent**

```python
from langgraph.graph import StateGraph, END

# Define routing function
def route_based_on_score(state: WorkflowState) -> str:
    """Route to different nodes based on score."""
    score = state.get("score", 0)

    if score > 0.8:
        return "send_success_email"
    else:
        return "send_failure_email"

# Create graph
workflow_graph = StateGraph(WorkflowState)

# Add nodes
workflow_graph.add_node("check_score", check_score_node)
workflow_graph.add_node("send_success_email", success_email_node)
workflow_graph.add_node("send_failure_email", failure_email_node)

# Add conditional edge
workflow_graph.set_entry_point("check_score")
workflow_graph.add_conditional_edges(
    "check_score",
    route_based_on_score,
    {
        "send_success_email": "send_success_email",
        "send_failure_email": "send_failure_email"
    }
)

# Both paths end
workflow_graph.add_edge("send_success_email", END)
workflow_graph.add_edge("send_failure_email", END)

compiled_workflow = workflow_graph.compile()
```

---

### Parallel Execution with Send API

**Example: Map-Reduce Workflow**

```python
from langgraph.graph import StateGraph, END, Send

class MapReduceState(TypedDict):
    reviews: list
    sentiments: list
    insights_report: str

# Map node (runs in parallel for each review)
async def analyze_sentiment_node(state: dict) -> dict:
    """Analyze sentiment of a single review."""
    review = state["review"]

    from workflow_llm_sdk import LLMClient
    llm_client = LLMClient(model="gpt-3.5")

    sentiment = await llm_client.generate(
        prompt=f"Analyze sentiment of this review: {review}",
        output_format="json"
    )

    return {"sentiment": sentiment}

# Reduce node (aggregates all sentiments)
async def aggregate_insights_node(state: MapReduceState) -> MapReduceState:
    """Aggregate sentiments into insights report."""
    sentiments = state["sentiments"]

    insights_report = f"Total reviews: {len(sentiments)}\n"
    insights_report += f"Positive: {sum(1 for s in sentiments if s['sentiment'] == 'positive')}\n"
    insights_report += f"Negative: {sum(1 for s in sentiments if s['sentiment'] == 'negative')}\n"

    return {"insights_report": insights_report}

# Create graph
workflow_graph = StateGraph(MapReduceState)

# Fan-out function (sends each review to a separate worker)
def fan_out_to_workers(state: MapReduceState):
    """Send each review to a worker node."""
    return [
        Send("analyze_sentiment", {"review": review})
        for review in state["reviews"]
    ]

# Add nodes
workflow_graph.add_node("analyze_sentiment", analyze_sentiment_node)
workflow_graph.add_node("aggregate_insights", aggregate_insights_node)

# Add edges
workflow_graph.set_entry_point("analyze_sentiment")
workflow_graph.add_conditional_edges(
    "analyze_sentiment",
    fan_out_to_workers
)
workflow_graph.add_edge("analyze_sentiment", "aggregate_insights")
workflow_graph.add_edge("aggregate_insights", END)

compiled_workflow = workflow_graph.compile()
```

---

### Checkpointing for Fault Tolerance

```python
from langgraph.checkpoint.postgres import PostgresCheckpointSaver

# Initialize checkpoint saver
checkpointer = PostgresCheckpointSaver(
    connection_string=os.getenv("DATABASE_URL")
)

# Compile workflow with checkpointing
compiled_workflow = workflow_graph.compile(
    checkpointer=checkpointer,
    interrupt_before=["human_approval"]  # Pause at human approval node
)

# Execute workflow with checkpointing
config = {
    "configurable": {
        "thread_id": execution_id,  # Unique ID for this execution
        "checkpoint_frequency": "every_node"  # Checkpoint after every node
    }
}

result = await compiled_workflow.ainvoke(input_data, config=config)
```

---

### Resume Workflow from Checkpoint

```python
# Resume workflow from last checkpoint
async def resume_workflow(execution_id: str, approval_data: dict):
    """Resume workflow after human approval."""

    # Get latest checkpoint
    checkpoint = await db.fetchrow(
        """
        SELECT state_snapshot FROM execution_checkpoints
        WHERE execution_id = $1
        ORDER BY checkpoint_number DESC
        LIMIT 1
        """,
        execution_id
    )

    if not checkpoint:
        raise ValueError(f"No checkpoint found for execution {execution_id}")

    # Load state from checkpoint
    state = json.loads(checkpoint["state_snapshot"])

    # Add approval data
    state["approval"] = approval_data

    # Resume workflow
    config = {
        "configurable": {
            "thread_id": execution_id,
            "resume_from_checkpoint": True
        }
    }

    result = await compiled_workflow.ainvoke(state, config=config)

    return result
```

---

## State Management

### State Schema

**Typed State with Pydantic:**

```python
from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class WorkflowState(BaseModel):
    """Workflow state schema with type safety."""

    # Input data
    input: Dict[str, Any]

    # Node outputs (dynamically added)
    node_outputs: Dict[str, Any] = {}

    # Execution metadata
    execution_id: str
    workflow_id: str
    current_node: Optional[str] = None

    # Error tracking
    error: Optional[str] = None
    error_node: Optional[str] = None
    retry_count: int = 0

    # Progress tracking
    completed_nodes: List[str] = []
    pending_nodes: List[str] = []

    # Cost tracking
    llm_tokens_used: int = 0
    api_calls_made: int = 0

    class Config:
        extra = "allow"  # Allow dynamic fields
```

---

### State Updates

**Node state update pattern:**

```python
async def node_function(state: WorkflowState) -> Dict[str, Any]:
    """
    Nodes return partial state updates.
    LangGraph merges updates into state.
    """
    # Process data
    result = await process_data(state.input)

    # Return partial state update
    return {
        "node_outputs": {
            **state.node_outputs,
            "current_node_output": result
        },
        "completed_nodes": state.completed_nodes + ["current_node"],
        "llm_tokens_used": state.llm_tokens_used + result.get("tokens", 0)
    }
```

---

### State Persistence

**Checkpoint state to PostgreSQL:**

```python
async def save_checkpoint(execution_id: str, state: WorkflowState, node_id: str):
    """Save workflow state checkpoint."""

    # Get current checkpoint count
    checkpoint_number = await db.fetchval(
        "SELECT COALESCE(MAX(checkpoint_number), 0) + 1 FROM execution_checkpoints WHERE execution_id = $1",
        execution_id
    )

    # Save checkpoint
    await db.execute(
        """
        INSERT INTO execution_checkpoints (
            tenant_id, execution_id, checkpoint_number, node_id, state_snapshot
        )
        VALUES ($1, $2, $3, $4, $5)
        """,
        state.tenant_id,
        execution_id,
        checkpoint_number,
        node_id,
        json.dumps(state.dict())
    )

    # Cache in Redis for fast access
    await redis.setex(
        f"workflow:execution:{execution_id}:checkpoint",
        3600,
        json.dumps(state.dict())
    )
```

---

## Multi-Tenancy & Security

### Row-Level Security (RLS)

**PostgreSQL RLS Policy:**

```sql
-- Enable RLS on all workflow tables
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE execution_node_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE execution_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_agents ENABLE ROW LEVEL SECURITY;

-- Create tenant isolation policy
CREATE POLICY tenant_isolation ON workflows
  USING (tenant_id = current_setting('app.current_tenant')::UUID);

CREATE POLICY tenant_isolation ON workflow_executions
  USING (tenant_id = current_setting('app.current_tenant')::UUID);

-- ... repeat for all tables
```

---

### FastAPI Middleware

**Set tenant context in middleware:**

```python
from fastapi import Request, HTTPException

@app.middleware("http")
async def set_tenant_context(request: Request, call_next):
    tenant_id = request.headers.get("X-Tenant-ID")

    if not tenant_id:
        return JSONResponse(
            status_code=400,
            content={"error": "Missing X-Tenant-ID header"}
        )

    # Set PostgreSQL session variable
    async with db.acquire() as conn:
        await conn.execute(f"SET app.current_tenant = '{tenant_id}'")

    response = await call_next(request)
    return response
```

---

### Authorization

**Role-Based Access Control:**

```python
async def check_workflow_access(user_id: str, workflow_id: str, action: str):
    """
    Check if user has permission to perform action on workflow.
    """
    # Check workflow ownership
    workflow = await db.fetchrow(
        "SELECT created_by, organization_id FROM workflows WHERE id = $1",
        workflow_id
    )

    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")

    # Owner has full access
    if workflow["created_by"] == user_id:
        return True

    # Check organization membership
    membership = await db.fetchrow(
        """
        SELECT role FROM organization_members
        WHERE user_id = $1 AND organization_id = $2
        """,
        user_id, workflow["organization_id"]
    )

    if not membership:
        raise HTTPException(status_code=403, detail="Access denied")

    # Check role permissions
    permissions = {
        "admin": ["create", "read", "update", "delete", "execute"],
        "editor": ["read", "update", "execute"],
        "viewer": ["read"]
    }

    user_permissions = permissions.get(membership["role"], [])

    if action not in user_permissions:
        raise HTTPException(status_code=403, detail=f"Action '{action}' not permitted for role '{membership['role']}'")

    return True
```

---

### Sandboxed Agent Execution

**Execute custom agents in isolated environment:**

```python
import docker

async def execute_custom_agent_sandboxed(agent_code: str, input_data: dict):
    """
    Execute custom agent code in Docker container for security isolation.
    """
    client = docker.from_env()

    # Create temporary container
    container = client.containers.run(
        "python:3.11-slim",
        command=f"python -c '{agent_code}'",
        environment={"INPUT_DATA": json.dumps(input_data)},
        mem_limit="512m",
        cpu_quota=50000,  # 50% CPU
        network_mode="none",  # No network access
        detach=True,
        remove=True
    )

    # Wait for completion (with timeout)
    try:
        result = container.wait(timeout=60)
        output = container.logs().decode("utf-8")
        return json.loads(output)
    except Exception as e:
        container.stop()
        raise RuntimeError(f"Custom agent execution failed: {e}")
```

---

## Error Handling & Recovery

### Retry Logic with Exponential Backoff

```python
async def execute_node_with_retry(node_fn, state: WorkflowState, max_retries: int = 3):
    """
    Execute node with retry logic and exponential backoff.
    """
    retry_count = 0
    backoff_seconds = 1

    while retry_count < max_retries:
        try:
            result = await node_fn(state)
            return result

        except Exception as e:
            retry_count += 1

            if retry_count >= max_retries:
                # Max retries reached, fail
                logger.error(f"Node failed after {max_retries} retries: {e}")
                raise

            # Log retry
            logger.warning(f"Node failed (attempt {retry_count}/{max_retries}), retrying in {backoff_seconds}s: {e}")

            # Exponential backoff
            await asyncio.sleep(backoff_seconds)
            backoff_seconds *= 2
```

---

### Error Tracking

```python
async def track_node_failure(execution_id: str, node_id: str, error: Exception):
    """
    Track node failure in database.
    """
    await db.execute(
        """
        UPDATE execution_node_logs
        SET
            status = 'failed',
            error_message = $1,
            retry_count = retry_count + 1,
            completed_at = NOW()
        WHERE execution_id = $2 AND node_id = $3
        """,
        str(error),
        execution_id,
        node_id
    )

    # Update workflow execution
    await db.execute(
        """
        UPDATE workflow_executions
        SET
            status = 'failed',
            error_message = $1,
            error_node_id = $2,
            completed_at = NOW()
        WHERE id = $3
        """,
        str(error),
        node_id,
        execution_id
    )

    # Publish failure event
    await kafka_producer.send("workflow_events", {
        "event_type": "workflow_failed",
        "execution_id": execution_id,
        "error_node_id": node_id,
        "error_message": str(error)
    })
```

---

### Graceful Degradation

```python
async def execute_workflow_with_degradation(workflow_id: str, input_data: dict):
    """
    Execute workflow with graceful degradation.
    If monitoring/analytics fail, continue execution.
    """
    try:
        # Start execution
        execution_id = await start_execution(workflow_id, input_data)

        # Execute workflow
        result = await compiled_workflow.ainvoke(input_data)

        # Mark as completed
        await complete_execution(execution_id, result)

        return result

    except Exception as e:
        # Log error
        logger.error(f"Workflow execution failed: {e}")

        # Try to save failure state (even if monitoring is down)
        try:
            await mark_execution_failed(execution_id, str(e))
        except:
            logger.error("Failed to save failure state")

        # Re-raise
        raise
```

---

## Monitoring & Observability

### OpenTelemetry Tracing

```python
from opentelemetry import trace
from opentelemetry.trace import Status, StatusCode

tracer = trace.get_tracer(__name__)

async def execute_workflow_with_tracing(workflow_id: str, input_data: dict):
    """
    Execute workflow with OpenTelemetry distributed tracing.
    """
    with tracer.start_as_current_span("execute_workflow") as span:
        # Add workflow metadata to span
        span.set_attribute("workflow.id", workflow_id)
        span.set_attribute("workflow.name", workflow["name"])
        span.set_attribute("workflow.pattern", workflow["pattern"])

        try:
            # Execute workflow
            result = await compiled_workflow.ainvoke(input_data)

            # Mark span as successful
            span.set_status(Status(StatusCode.OK))
            span.set_attribute("workflow.status", "completed")

            return result

        except Exception as e:
            # Mark span as failed
            span.set_status(Status(StatusCode.ERROR), str(e))
            span.record_exception(e)
            span.set_attribute("workflow.status", "failed")

            raise
```

---

### Prometheus Metrics

```python
from prometheus_client import Counter, Histogram, Gauge

# Metrics
workflow_executions_total = Counter(
    "workflow_executions_total",
    "Total workflow executions",
    ["workflow_id", "status"]
)

workflow_duration_seconds = Histogram(
    "workflow_duration_seconds",
    "Workflow execution duration",
    ["workflow_id"]
)

active_workflows_gauge = Gauge(
    "active_workflows",
    "Number of active workflow executions"
)

# Track metrics
async def execute_workflow_with_metrics(workflow_id: str, input_data: dict):
    """
    Execute workflow with Prometheus metrics tracking.
    """
    start_time = time.time()
    active_workflows_gauge.inc()

    try:
        result = await compiled_workflow.ainvoke(input_data)

        # Record success
        workflow_executions_total.labels(
            workflow_id=workflow_id,
            status="completed"
        ).inc()

        return result

    except Exception as e:
        # Record failure
        workflow_executions_total.labels(
            workflow_id=workflow_id,
            status="failed"
        ).inc()

        raise

    finally:
        # Record duration
        duration = time.time() - start_time
        workflow_duration_seconds.labels(workflow_id=workflow_id).observe(duration)

        active_workflows_gauge.dec()
```

---

### Cost Tracking

```python
async def track_workflow_cost(execution_id: str):
    """
    Track workflow execution cost (LLM tokens, API calls).
    """
    # Get all node logs
    node_logs = await db.fetch(
        "SELECT * FROM execution_node_logs WHERE execution_id = $1",
        execution_id
    )

    total_llm_tokens = sum(log["llm_tokens_used"] for log in node_logs)
    total_api_calls = sum(log["api_calls_made"] for log in node_logs)

    # Calculate cost
    # Assume GPT-4: $0.03/1K input tokens, $0.06/1K output tokens
    llm_cost_usd = (total_llm_tokens / 1000) * 0.045  # Average
    api_cost_usd = total_api_calls * 0.01  # $0.01 per API call
    total_cost_usd = llm_cost_usd + api_cost_usd

    # Update execution record
    await db.execute(
        """
        UPDATE workflow_executions
        SET
            llm_tokens_used = $1,
            api_calls_made = $2,
            cost_usd = $3
        WHERE id = $4
        """,
        total_llm_tokens,
        total_api_calls,
        total_cost_usd,
        execution_id
    )

    return total_cost_usd
```

---

## Dependencies

### Internal Service Dependencies

| Service | Type | Purpose |
|---------|------|---------|
| **Service 0** | API | Authentication, authorization, user management |
| **Service 6** | Event Consumer | Trigger workflows from PRD milestones |
| **Service 7** | Event Consumer | Complement YAML config generation |
| **Service 8** | Event Consumer | Trigger workflows from chatbot conversations |
| **Service 9** | Event Consumer | Trigger workflows from voicebot interactions |
| **Service 11** | Event Producer | Workflow SLA monitoring, alerting |
| **Service 12** | Event Producer | Workflow performance analytics |
| **Service 17** | API | RAG-based workflow recommendations |
| **Service 21** | Event Consumer | Suggest workflows to human agents |

### External Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| **PostgreSQL (Supabase)** | Database | Workflow definitions, executions, checkpoints |
| **Redis** | Cache | Execution state, WebSocket connections |
| **Apache Kafka** | Event Bus | Workflow event publishing/consuming |
| **@workflow/llm-sdk** | Library | LLM inference for natural language parsing |
| **@workflow/config-sdk** | Library | Workflow YAML storage (S3) |
| **Qdrant** | Vector DB | Workflow similarity search, recommendations |
| **Playwright** | Browser Automation | Web scraping agent |
| **Docker** | Container Runtime | Sandboxed custom agent execution |
| **OpenTelemetry** | Observability | Distributed tracing |
| **Prometheus** | Monitoring | Metrics export |

---

## Testing Strategy

### Unit Tests

```python
import pytest

def test_parse_natural_language_description():
    """Test natural language parser."""
    description = "Scrape 10 LinkedIn profiles → extract skills with LLM → email summary"

    result = await parse_workflow_description(description)

    assert result["pattern"] == "sequential"
    assert len(result["nodes"]) == 3
    assert result["nodes"][0]["agent"] == "web_scraping"
    assert result["nodes"][1]["agent"] == "llm"
    assert result["nodes"][2]["agent"] == "email"

def test_workflow_state_update():
    """Test workflow state updates."""
    state = WorkflowState(
        input={"data": "test"},
        execution_id="exec_001",
        workflow_id="wf_001"
    )

    # Simulate node update
    update = {"node_outputs": {"node1": "result"}}
    new_state = {**state.dict(), **update}

    assert new_state["node_outputs"]["node1"] == "result"
```

---

### Integration Tests (with REAL services)

```python
def test_workflow_execution_end_to_end():
    """Test complete workflow execution with real Kafka, PostgreSQL, LLM."""
    # Create workflow
    workflow = await create_workflow(
        organization_id="org_test",
        description="Mock scrape → mock LLM → mock email"
    )

    assert workflow["workflow_id"]

    # Execute workflow
    execution = await execute_workflow(
        workflow_id=workflow["workflow_id"],
        input_data={"urls": ["https://example.com"]}
    )

    assert execution["status"] == "running"

    # Wait for completion
    await wait_for_completion(execution["execution_id"], timeout=60)

    # Verify execution completed
    final_state = await get_execution_status(execution["execution_id"])

    assert final_state["status"] == "completed"
    assert final_state["completed_nodes"] == 3
    assert final_state["output"]["email_sent"] is True

def test_kafka_event_triggers_workflow():
    """Test workflow triggered by Kafka event."""
    # Publish demo_completed event
    await kafka_producer.send("demo_events", {
        "event_type": "demo_completed",
        "organization_id": "org_test",
        "demo_id": "demo_001"
    })

    # Wait for workflow to be triggered
    await asyncio.sleep(2)

    # Verify workflow execution started
    executions = await db.fetch(
        """
        SELECT * FROM workflow_executions
        WHERE organization_id = $1
        AND triggered_by = 'event'
        ORDER BY created_at DESC
        LIMIT 1
        """,
        "org_test"
    )

    assert len(executions) == 1
    assert executions[0]["status"] in ["running", "completed"]
```

---

### Multi-Tenancy Tests

```python
def test_tenant_isolation():
    """Verify workflows are isolated between tenants."""
    # Create workflow for tenant A
    workflow_a = await create_workflow(
        organization_id="org_a",
        tenant_id="tenant_a",
        description="Test workflow A"
    )

    # Try to access from tenant B context
    with pytest.raises(PermissionDenied):
        # Set tenant B context
        await db.execute("SET app.current_tenant = 'tenant_b'")

        # Attempt to get workflow from tenant A
        await get_workflow(workflow_a["workflow_id"])
```

---

## Deployment

### Docker Configuration

**Dockerfile:**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright browsers for web scraping
RUN playwright install chromium

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**requirements.txt:**

```
fastapi==0.104.1
uvicorn==0.24.0
asyncpg==0.29.0
redis==5.0.1
aiokafka==0.10.0
qdrant-client==1.6.4
workflow-llm-sdk==1.0.0
workflow-config-sdk==1.0.0
pydantic==2.5.0
python-jose==3.3.0
httpx==0.25.0
langchain==0.1.0
langgraph==0.0.20
playwright==1.40.0
docker==6.1.3
opentelemetry-api==1.20.0
opentelemetry-sdk==1.20.0
opentelemetry-instrumentation-fastapi==0.41b0
prometheus-client==0.18.0
```

---

### Kubernetes Deployment

**deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-23-workflow-engine
  namespace: workflow-automation
spec:
  replicas: 3
  selector:
    matchLabels:
      app: service-23-workflow-engine
  template:
    metadata:
      labels:
        app: service-23-workflow-engine
    spec:
      containers:
      - name: workflow-engine
        image: workflow/service-23-workflow-engine:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: REDIS_URL
          value: redis://redis-service:6379
        - name: QDRANT_URL
          value: http://qdrant-service:6333
        - name: KAFKA_BROKERS
          value: kafka-0.kafka-headless:9092,kafka-1.kafka-headless:9092
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openai-credentials
              key: api_key
        - name: S3_BUCKET
          value: workflow-configs
        resources:
          requests:
            memory: "1Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "4000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
```

---

### Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:password@postgres:5432/workflow_automation
REDIS_URL=redis://redis:6379
QDRANT_URL=http://qdrant:6333

# Kafka
KAFKA_BROKERS=kafka-0:9092,kafka-1:9092
KAFKA_CONSUMER_GROUP=service-23-workflow-engine

# LLM
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# S3 (for @workflow/config-sdk)
S3_BUCKET=workflow-configs
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...

# Docker (for sandboxed agent execution)
DOCKER_HOST=unix:///var/run/docker.sock

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
PROMETHEUS_PORT=9090
LOG_LEVEL=INFO
```

---

## Implementation Phases

### Phase 1: MVP (Weeks 1-4)

**Goal**: Natural language workflow creation with sequential execution

**Features:**
- Natural language parser using @workflow/llm-sdk
- Sequential workflow generation (3 nodes max)
- Core agent library (LLM, Web Scraping, Email, Data Processing)
- Workflow storage in PostgreSQL + S3 (via @workflow/config-sdk)
- Basic execution engine with LangGraph StateGraph
- REST API endpoints (create, execute, get status)
- Kafka integration (publish workflow_events)
- Multi-tenancy with RLS
- Basic error handling with retry logic

**Deliverables:**
- Working API for workflow creation and execution
- Support "Scrape LinkedIn → extract skills → email" use case
- Execution logs in PostgreSQL
- Kafka events published

---

### Phase 2: Advanced Patterns (Weeks 5-8)

**Goal**: Conditional routing, parallel execution, and human-in-the-loop

**Features:**
- Conditional routing with Router Agent
- Parallel execution with Send API (map-reduce)
- Orchestrator-worker pattern
- Human-in-the-loop with approval nodes
- Checkpointing for fault tolerance
- Resume workflows from checkpoints
- WebSocket real-time updates
- Workflow templates for common use cases

**Deliverables:**
- Conditional workflows ("if uptime down → alert; else → log")
- Parallel workflows ("scrape 100 reviews → analyze in parallel → aggregate")
- Human approval workflows ("generate report → human reviews → send email")
- Checkpoint/resume capability
- Real-time progress tracking via WebSocket

---

### Phase 3: Integrations & Monitoring (Weeks 9-12)

**Goal**: Service integrations, advanced monitoring, and observability

**Features:**
- Event-driven triggers from Services 2, 6, 8, 9, 13
- Integration with Service 21 (Agent Copilot) for workflow suggestions
- Custom agent registration
- Advanced monitoring dashboard (Gantt charts, execution timeline)
- Cost tracking (LLM tokens, API calls)
- SLA monitoring with alerting
- OpenTelemetry distributed tracing
- Prometheus metrics export
- Workflow marketplace (share workflows)

**Deliverables:**
- Workflows triggered by external events (demo_completed, prd_approved)
- Custom agent registration API
- Monitoring dashboard with cost tracking
- OpenTelemetry + Prometheus integration
- Workflow sharing/marketplace

---

### Phase 4: Optimization & Scale (Weeks 13-16)

**Goal**: Performance optimization, scaling, and AI workflow optimization

**Features:**
- Workflow scheduling (cron-like syntax)
- Workflow versioning and rollback
- Hot-reload for workflow updates
- Performance optimization (caching, parallel execution)
- Horizontal scaling (10+ pods)
- AI workflow optimizer (LLM suggests improvements)
- Workflow analytics (success rate, avg duration, cost trends)
- Advanced error recovery strategies
- Load testing (1000+ concurrent executions)

**Deliverables:**
- Scheduled workflows ("Run daily at 9am")
- Workflow version control with rollback
- Hot-reload support
- Optimized for 1000+ concurrent executions
- AI-powered workflow optimization suggestions
- Production-ready with 99.9% uptime

---

## Summary

Service 23 (Dynamic Workflow Engine) enables users to create and execute complex AI workflows from natural language descriptions, leveraging LangGraph for flexible workflow orchestration and @workflow SDKs for seamless platform integration.

**Key Benefits:**
- **Democratize Automation**: Non-technical users create workflows with natural language
- **Reduce Development Time**: From days to minutes with agent library
- **Enable Experimentation**: Business users iterate without engineering
- **Cost Optimization**: Reuse agents across 1000+ workflows

**Implementation Roadmap**: 16 weeks from MVP to production-ready system supporting 1000+ concurrent workflow executions, 10,000+ workflows per tenant, and 99.9% uptime.

**Integration**: Event-driven coordination with 9 existing services (0, 6, 7, 8, 9, 11, 12, 17, 21) via Kafka, using @workflow/llm-sdk for LLM inference and @workflow/config-sdk for YAML workflow storage.

---

**Document Version**: 1.0
**Last Updated**: 2025-10-08
**Status**: Specification Complete - Ready for Implementation Review
