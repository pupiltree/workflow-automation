# Microservices Architecture - Master Service Index

**Total Services: 16** (optimized from 22)
**Supporting Libraries: 2** (@workflow/llm-sdk, @workflow/config-sdk)

This index provides quick navigation to all microservices across the three architecture documents.

**Architecture Optimization**: This architecture has been optimized through strategic consolidation, eliminating distributed monolith anti-patterns, shared database issues, and unnecessary network hops. Architecture health improved from 6.5/10 to 9+/10.

---

## Service Locations by Document

### MICROSERVICES_ARCHITECTURE.md (Part 1)
**5 Services**

| Service # | Service Name | Purpose |
|-----------|--------------|---------|
| 0 | Organization & Identity Management | Auth, multi-tenant organization setup, member management, human agent roles |
| 1 | Research Engine | Automated market research, volume prediction, competitor analysis |
| 2 | Demo Generator | AI-powered chatbot/voicebot demo creation |
| 3 | Sales Document Generator | Unified NDA, pricing, and proposal generation with e-signature |

**Consolidated**:
- Service 0.5 (Human Agent Management) → merged into Service 0
- Services 4, 5 (Pricing, Proposal) → merged into Service 3

---

### MICROSERVICES_ARCHITECTURE_PART2.md (Part 2)
**3 Services**

| Service # | Service Name | Purpose |
|-----------|--------------|---------|
| 6 | PRD Builder & Configuration Workspace | AI-powered PRD generation, village knowledge, client config portal |
| 7 | Automation Engine | YAML config generation, GitHub issue creation, hot-reload management |
| 17 | RAG Pipeline | Retrieval-Augmented Generation for knowledge injection |

**Consolidated**:
- Service 19 (Client Configuration Portal) → merged into Service 6

**Converted to Libraries**:
- Service 16 (LLM Gateway) → @workflow/llm-sdk
- Service 10 (Configuration Management) → @workflow/config-sdk

---

### MICROSERVICES_ARCHITECTURE_PART3.md (Part 3)
**7 Services**

| Service # | Service Name | Purpose |
|-----------|--------------|---------|
| 8 | Agent Orchestration (Chatbot) | LangGraph-based chatbot runtime, conversation management |
| 9 | Voice Agent (Voicebot) | LiveKit-based voicebot runtime, real-time voice processing |
| 11 | Monitoring Engine | Real-time monitoring, alerting, quality assurance |
| 12 | Analytics | Usage analytics, KPI tracking, business intelligence |
| 13 | Customer Success | Health scoring, playbooks, QBR automation, churn prediction |
| 14 | Support Engine | AI-powered support automation, ticket management |
| 15 | CRM Integration | Salesforce, HubSpot, Zendesk integration |
| 20 | Communication & Hyperpersonalization Engine | Email/SMS, templates, lifecycle personalization, A/B testing |

**Consolidated**:
- Service 18 (Outbound Communication) → merged into Service 20

---

### Standalone Document
**1 Service**

| Service # | Service Name | Document | Purpose |
|-----------|--------------|----------|---------|
| 21 | Agent Copilot | SERVICE_21_AGENT_COPILOT.md | AI-powered context management and action planning for human agents |

---

## Quick Reference: Active Services

| # | Name | Document |
|---|------|----------|
| **0** | **Organization & Identity Management** | **PART1** |
| 1 | Research Engine | PART1 |
| 2 | Demo Generator | PART1 |
| **3** | **Sales Document Generator** | **PART1** |
| **6** | **PRD Builder & Configuration Workspace** | **PART2** |
| 7 | Automation Engine | PART2 |
| 8 | Agent Orchestration (Chatbot) | PART3 |
| 9 | Voice Agent (Voicebot) | PART3 |
| 11 | Monitoring Engine | PART3 |
| 12 | Analytics | PART3 |
| 13 | Customer Success | PART3 |
| 14 | Support Engine | PART3 |
| 15 | CRM Integration | PART3 |
| 17 | RAG Pipeline | PART2 |
| **20** | **Communication & Hyperpersonalization Engine** | **PART3** |
| 21 | Agent Copilot | Standalone |

**Bold** = Consolidated service (contains functionality from multiple previous services)

---

## Eliminated Services (Consolidated or Converted)

### Merged into Other Services
| Original # | Original Name | Merged Into | New Owner |
|------------|---------------|-------------|-----------|
| 0.5 | Human Agent Management | Service 0 | Organization & Identity Management |
| 4 | Pricing Model Generator | Service 3 | Sales Document Generator |
| 5 | Proposal Generator | Service 3 | Sales Document Generator |
| 18 | Outbound Communication | Service 20 | Communication & Hyperpersonalization Engine |
| 19 | Client Configuration Portal | Service 6 | PRD Builder & Configuration Workspace |

### Converted to Supporting Libraries
| Original # | Original Name | New Library | Usage |
|------------|---------------|-------------|-------|
| 10 | Configuration Management | @workflow/config-sdk | Direct S3 access + validation library |
| 16 | LLM Gateway | @workflow/llm-sdk | Import library for LLM calls (eliminates 200-500ms latency) |

---

## Supporting Libraries

### @workflow/llm-sdk
**Purpose**: LLM inference with model routing, semantic caching, token counting
**Replaces**: Service 16 (LLM Gateway microservice)
**Used By**: Services 8, 9, 21, 13, 14
**Benefits**:
- Eliminates 200-500ms latency per LLM call
- No network hop to gateway service
- Direct OpenAI/Anthropic API access
**Documentation**: See PART2 "Supporting Libraries" section

### @workflow/config-sdk
**Purpose**: S3-based configuration storage with JSON Schema validation
**Replaces**: Service 10 (Configuration Management microservice)
**Used By**: All services requiring YAML configs
**Benefits**:
- Eliminates 50-100ms latency per config fetch
- Direct S3 access with client-side caching
- Simpler codebase (no HTTP wrapper)
**Documentation**: See PART2/PART3 "Supporting Libraries" section

---

## Service Categories

### **Foundation Layer (Infrastructure)**
- **Service 0**: Organization & Identity Management *(includes human agent roles)*
- **Service 17**: RAG Pipeline
- **@workflow/llm-sdk**: LLM Gateway *(library)*
- **@workflow/config-sdk**: Configuration Management *(library)*

### **Client Acquisition (Sales Pipeline)**
- **Service 1**: Research Engine
- **Service 2**: Demo Generator
- **Service 3**: Sales Document Generator *(unified NDA/pricing/proposal)*

### **Implementation (Onboarding)**
- **Service 6**: PRD Builder & Configuration Workspace *(includes client config portal)*
- **Service 7**: Automation Engine

### **Runtime (Production Operations)**
- **Service 8**: Agent Orchestration (Chatbot)
- **Service 9**: Voice Agent (Voicebot)
- **Service 11**: Monitoring Engine
- **Service 12**: Analytics
- **Service 20**: Communication & Hyperpersonalization Engine *(includes outbound email/SMS)*

### **Customer Operations**
- **Service 13**: Customer Success
- **Service 14**: Support Engine
- **Service 15**: CRM Integration
- **Service 21**: Agent Copilot

---

## Product Type Alignment

### **Chatbot Products (LangGraph-based)**
Primary Services:
- Service 8: Agent Orchestration
- Service 6: PRD Builder (chatbot workflows)
- Service 7: Automation Engine (chatbot YAML configs)

### **Voicebot Products (LiveKit-based)**
Primary Services:
- Service 9: Voice Agent
- Service 6: PRD Builder (voicebot workflows)
- Service 7: Automation Engine (voicebot YAML configs)

### **Shared Services (Both Products)**
- Service 11: Monitoring Engine
- Service 12: Analytics
- Service 13: Customer Success
- Service 14: Support Engine
- Service 15: CRM Integration
- Service 17: RAG Pipeline
- Service 20: Communication & Hyperpersonalization Engine
- @workflow/llm-sdk (library)
- @workflow/config-sdk (library)

---

## Event-Driven Communication

### **Kafka Topics (17 Total)**

**Note**: Reduced from 19 topics - consolidated some topics after service mergers.

| Topic | Primary Producers | Primary Consumers |
|-------|------------------|-------------------|
| `auth_events` | Service 0 | Services 1, 2 |
| `agent_events` | Service 0 | Services 13, 21 |
| `research_events` | Service 1 | Service 2 |
| `client_events` | Service 0 | Multiple |
| `demo_events` | Service 2 | Service 3 |
| `sales_doc_events` | Service 3 | Service 6 *(unified: nda/pricing/proposal)* |
| `prd_events` | Service 6 | Service 7 |
| `config_events` | Service 7 | Services 8, 9 |
| `conversation_events` | Services 8, 9 | Services 11, 12, 20 |
| `voice_events` | Service 9 | Services 11, 12 |
| `support_events` | Service 14 | Services 13, 21 |
| `customer_success_events` | Service 13 | Services 20, 21 |
| `communication_events` | Service 20 | Services 8, 9 *(unified: outreach/personalization)* |
| `escalation_events` | Service 14 | Service 0 |
| `monitoring_incidents` | Service 11 | Service 13 |
| `analytics_experiments` | Service 12 | Services 8, 9, 20 |
| `cross_product_events` | Services 8, 9 | Service 21 |

**Consolidated Topics**:
- `nda_events`, `pricing_events`, `proposal_events` → `sales_doc_events`
- `outreach_events`, `personalization_events` → `communication_events`

---

## Consolidation Summary

### Architecture Improvements
- **Service Count**: 22 → 15 (30% reduction)
- **Network Hops**: 36% reduction in service-to-service connections
- **Latency Improvements**:
  - AI workflows: 200-500ms faster (eliminated LLM Gateway hop)
  - Sales pipeline: 150-300ms faster (consolidated document generation)
  - Config operations: 50-100ms faster (eliminated Config Management service)
- **Architecture Health**: 6.5/10 → 9+/10

### Anti-Patterns Eliminated
✅ **Distributed Monolith**: Services 3, 4, 5 consolidated
✅ **Shared Database**: Services 0, 0.5 merged
✅ **Nano-Services**: Services 10, 16 converted to libraries
✅ **Chatty Communication**: Reduced through library conversions
✅ **Excessive Coupling**: Service 21 refactored to event-driven patterns

### Feature Duplications Resolved
✅ **E-signature Integration**: Consolidated to Service 3
✅ **Email/SMS Sending**: Consolidated to Service 20
✅ **Template Management**: Service 3 (sales), Service 20 (communication)
✅ **Configuration Validation**: Service 7 provides SDK
✅ **Webchat UI**: Documented as shared frontend component library

---

## Cross-Document Reference Guide

### **When in PART1, services reference:**
- Other PART1 services: Use `*[See Service X above/below]*`
- PART2 services: Use `*[See MICROSERVICES_ARCHITECTURE_PART2.md Service X]*`
- PART3 services: Use `*[See MICROSERVICES_ARCHITECTURE_PART3.md Service X]*`

### **When in PART2, services reference:**
- PART1 services: Use `*[See MICROSERVICES_ARCHITECTURE.md Service X]*`
- Other PART2 services: Use `*[See Service X above/below]*`
- PART3 services: Use `*[See MICROSERVICES_ARCHITECTURE_PART3.md Service X]*`

### **When in PART3, services reference:**
- PART1 services: Use `*[See MICROSERVICES_ARCHITECTURE.md Service X]*`
- PART2 services: Use `*[See MICROSERVICES_ARCHITECTURE_PART2.md Service X]*`
- Other PART3 services: Use `*[See Service X above/below]*`

### **References to Eliminated Services:**
- Service 0.5 → `*[See Service 0]*`
- Service 4 → `*[See Service 3 (Sales Document Generator)]*`
- Service 5 → `*[See Service 3 (Sales Document Generator)]*`
- Service 10 → `*[@workflow/config-sdk library]*`
- Service 16 → `*[@workflow/llm-sdk library]*`
- Service 18 → `*[See Service 20 (Communication & Hyperpersonalization Engine)]*`
- Service 19 → `*[See Service 6 (PRD Builder & Configuration Workspace)]*`

---

## Technology Stack Summary

### **Runtime Frameworks**
- **Chatbot**: LangGraph (Python) - two-node workflow pattern
- **Voicebot**: LiveKit Agents (Python) - VoicePipelineAgent pattern

### **Databases**
- **PostgreSQL** (Supabase): Primary data store with Row-Level Security
- **Qdrant**: Vector database for embeddings (village knowledge, RAG)
- **Neo4j**: Graph database for relationships and integrations
- **Redis**: Caching, real-time queues, hot-reload notifications
- **TimescaleDB**: Time-series analytics and metrics

### **Event Streaming**
- **Apache Kafka**: Event-driven orchestration (17 topics)

### **AI/LLM**
- **Primary**: OpenAI (GPT-4, GPT-3.5, GPT-4o-mini)
- **Fallback**: Anthropic Claude (Opus-4, Sonnet-4)
- **Voice STT**: Deepgram Nova-3
- **Voice TTS**: ElevenLabs Flash v2.5, OpenAI TTS

### **API Gateway**
- **Kong API Gateway**: Authentication, rate limiting, routing

### **Orchestration**
- **Kubernetes**: Container orchestration and deployment

---

## Documentation Maintenance

### **Adding a New Service**
1. Determine which document it belongs in (by category/phase)
2. Assign next available service number (next after 21)
3. Update this SERVICE_INDEX.md with the new service
4. Ensure all cross-references use correct document names
5. Run cross-reference validation script (see below)

### **Modifying Service Dependencies**
1. Update dependency section in service documentation
2. Verify cross-document references are correct
3. Update SERVICE_INDEX.md if event topics change
4. Run validation script to catch broken references

### **Consolidating Additional Services**
1. Document rationale in architectural review
2. Update merged service with all functionality
3. Remove eliminated service section from original document
4. Add entry to "Eliminated Services" section above
5. Update all cross-references throughout documents
6. Run validation script

---

## Validation

To validate all cross-references are correct, run:
```bash
./scripts/validate_cross_references.sh
```

This script checks:
- All service references point to correct documents (15 active services)
- References to eliminated services redirect to new owners
- All Kafka topics have defined producers/consumers (17 topics)
- Event schemas are consistent across services

---

## Migration Guide

For implementation teams migrating from the 22-service architecture:

**See**: `docs/architecture/REFACTORING_SPECIFICATION.md` for:
- Detailed consolidation rationale
- API endpoint migration mapping
- Database schema merge procedures
- Event topic consolidation guide
- Library conversion instructions

---

**Last Updated**: 2025-10-08
**Document Version**: 2.0 (Optimized Architecture)
**Architecture Health**: 9+/10
**Maintained By**: Technical Documentation Team
