# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**AI-Powered Workflow Automation Platform for B2B SaaS**

This platform automates the complete client lifecycle: research → demo generation → NDA/pricing → PRD creation → implementation → monitoring → customer success. The goal is 95% automation within 12 months.

### Project Status
**Currently in planning phase** - comprehensive architecture documentation exists but implementation has not yet begun.

### Key Architecture Documents
- **WORKFLOW.md**: End-to-end business process flow
- **MICROSERVICES_ARCHITECTURE*.md**: Technical architecture across 16 microservices
- **RESEARCH.md**: Research and competitive analysis

---

## Implementation Philosophy

> Think carefully and implement the most concise solution that changes as little code as possible.

## USE SUB-AGENTS FOR CONTEXT OPTIMIZATION

### 1. Always use the file-analyzer sub-agent when asked to read files.
The file-analyzer agent is an expert in extracting and summarizing critical information from files, particularly log files and verbose outputs. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 2. Always use the code-analyzer sub-agent when asked to search code, analyze code, research bugs, or trace logic flow.

The code-analyzer agent is an expert in code analysis, logic tracing, and vulnerability detection. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 3. Always use the test-runner sub-agent to run tests and analyze the test results.

Using the test-runner agent ensures:

- Full test output is captured for debugging
- Main conversation stays clean and focused
- Context usage is optimized
- All issues are properly surfaced
- No approval dialogs interrupt the workflow

## Philosophy

### Error Handling

- **Fail fast** for critical configuration (missing text model)
- **Log and continue** for optional features (extraction model)
- **Graceful degradation** when external services unavailable
- **User-friendly messages** through resilience layer

### Testing

- Always use the test-runner agent to execute tests.
- Do not use mock services for anything ever.
- Do not move on to the next test until the current test is complete.
- If the test fails, consider checking if the test is structured correctly before deciding we need to refactor the codebase.
- Tests to be verbose so we can use them for debugging.


## Tone and Behavior

- Criticism is welcome. Please tell me when I am wrong or mistaken, or even when you think I might be wrong or mistaken.
- Please tell me if there is a better approach than the one I am taking.
- Please tell me if there is a relevant standard or convention that I appear to be unaware of.
- Be skeptical.
- Be concise.
- Short summaries are OK, but don't give an extended breakdown unless we are working through the details of a plan.
- Do not flatter, and do not give compliments unless I am specifically asking for your judgement.
- Occasional pleasantries are fine.
- Feel free to ask many questions. If you are in doubt of my intent, don't guess. Ask.

## ABSOLUTE RULES:

- NO PARTIAL IMPLEMENTATION
- NO SIMPLIFICATION : no "//This is simplified stuff for now, complete implementation would blablabla"
- NO CODE DUPLICATION : check existing codebase to reuse functions and constants Read files before writing new functions. Use common sense function name to find them easily.
- NO DEAD CODE : either use or delete from codebase completely
- IMPLEMENT TEST FOR EVERY FUNCTIONS
- NO CHEATER TESTS : test must be accurate, reflect real usage and be designed to reveal flaws. No useless tests! Design tests to be verbose so we can use them for debuging.
- NO INCONSISTENT NAMING - read existing codebase naming patterns.
- NO OVER-ENGINEERING - Don't add unnecessary abstractions, factory patterns, or middleware when simple functions would work. Don't think "enterprise" when you need "working"
- NO MIXED CONCERNS - Don't put validation logic inside API handlers, database queries inside UI components, etc. instead of proper separation
- NO RESOURCE LEAKS - Don't forget to close database connections, clear timeouts, remove event listeners, or clean up file handles

---

## Architecture Patterns (When Implementation Begins)

### Agent Orchestration
- **LangGraph two-node workflow**: Standard pattern is agent node + tools node
- Reference: https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/
- **YAML-driven configuration**: System prompts, tools, and integrations configured per client via YAML
- **Checkpointing**: Always implement state persistence for fault tolerance
- **State typing**: Use strict TypedDict/Pydantic models for agent state

### Multi-Tenancy
- **Row-Level Security (RLS)**: ALWAYS filter by tenant_id in PostgreSQL queries
- **Namespace isolation**: Use tenant namespaces in Qdrant, Neo4j, and vector DBs
- **Never bypass tenant filtering**: Even for admin operations, use proper authorization checks
- **Test isolation thoroughly**: Every test must verify data cannot leak between tenants

### Event-Driven Architecture
- **Kafka topic naming**: `{service}_{entity}_{event_type}` (e.g., `prd_builder_prd_created`)
- **Event schema versioning**: Always version event schemas, use backward-compatible changes
- **Idempotency**: All event handlers MUST be idempotent (use idempotency keys)
- **Saga pattern**: Use for distributed transactions across services

### YAML Configuration
- **JSON Schema validation**: Validate YAML configs before applying
- **Version control**: All YAML configs tracked in Git with semantic versioning
- **Hot reload testing**: Test config updates without service restarts
- **S3 storage**: Production configs stored in S3, cached in Redis

### Technology Stack
- **Agent framework**: LangGraph for stateful AI workflows
- **Database**: PostgreSQL (Supabase) with RLS for multi-tenant isolation
- **Vector DB**: Qdrant with namespace-per-tenant
- **Voice**: LiveKit for real-time voice agents
- **Event bus**: Apache Kafka for service coordination
- **Orchestration**: Kubernetes for container management
- **API Gateway**: Kong for routing, auth, rate limiting

### Cost Optimization
- **Token monitoring**: Track LLM token usage per tenant, per workflow
- **Semantic caching**: Cache similar prompts to reduce LLM calls
- **Model routing**: Use cheaper models (GPT-3.5) for simple tasks, premium (GPT-4) for complex
- **Batch processing**: Aggregate non-urgent operations to reduce API calls

### Voice Agent Specific
- **Latency target**: <500ms for voice responses
- **LiveKit workflow**: Two-node pattern (see ../kishna_diagnostics/services/voice)
- **Interruption handling**: Support barge-in and context preservation
- **Fallback strategy**: Always have human escalation path

### Testing Requirements
- **Integration tests**: Use real Kafka/PostgreSQL/Qdrant instances (no mocks for infrastructure)
- **Multi-tenant test fixtures**: Create test data for multiple tenants in every test
- **Event replay**: Test idempotency by replaying events
- **Load testing**: Simulate 1000+ concurrent voice/chat sessions
- **Chaos testing**: Verify resilience when services fail

---

## When Implementation Starts

### Sprint Planning Reference
The architecture documents define a 20-sprint roadmap (40 weeks) to production. Refer to MICROSERVICES_ARCHITECTURE*.md for detailed sprint breakdown.

### First Implementation Priorities (Sprints 1-2)
1. Basic LangGraph agent orchestration
2. LLM gateway with model routing
3. PostgreSQL setup with RLS and multi-tenancy
4. Kafka event bus foundation
5. Configuration management service

### Common Development Patterns
- **Service template**: Each microservice follows the same structure (API layer → Business logic → Data access → Event publishing)
- **Error boundaries**: Graceful degradation when optional services fail
- **Observability**: OpenTelemetry for distributed tracing across all services
- **Health checks**: Kubernetes liveness/readiness probes for every service

---
