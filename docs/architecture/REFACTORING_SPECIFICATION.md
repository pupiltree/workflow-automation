# Architecture Refactoring Specification
## From 22 Services to 15 Services

**Status**: Implementation Blueprint
**Created**: 2025-10-08
**Target**: Optimize architecture by consolidating services and converting unnecessary microservices to libraries

---

## Executive Summary

This document provides a complete blueprint for refactoring the 22-service architecture into an optimized 15-service architecture. The consolidation eliminates:
- **Distributed monolith anti-patterns** (Services 3, 4, 5 doing the same thing)
- **Shared database issues** (Services 0 and 0.5 sharing auth.users)
- **Unnecessary network hops** (Services 10, 16 as pass-through layers)
- **Feature duplication** (E-signature, email/SMS, templates across multiple services)

**Architecture Health Score**: Improves from 6.5/10 to 9+/10

---

## Final Service List (15 Services)

### Active Services
0. **Organization & Identity Management** (merged 0 + 0.5)
1. **Research Engine**
2. **Demo Generator**
3. **Sales Document Generator** (merged 3 + 4 + 5)
6. **PRD Builder & Configuration Workspace** (merged 6 + 19)
7. **Automation Engine**
8. **Agent Orchestration (Chatbot)**
9. **Voice Agent (Voicebot)**
11. **Monitoring Engine**
12. **Analytics**
13. **Customer Success**
14. **Support Engine**
15. **CRM Integration**
17. **RAG Pipeline**
20. **Communication & Hyperpersonalization Engine** (merged 18 + 20)
21. **Agent Copilot**

### Converted to Libraries
- **@workflow/llm-sdk** (formerly Service 16)
- **@workflow/config-sdk** (formerly Service 10)

### Eliminated Through Consolidation
- Service 4 (Pricing Model Generator) → merged into Service 3
- Service 5 (Proposal Generator) → merged into Service 3
- Service 18 (Outbound Communication) → merged into Service 20
- Service 19 (Client Configuration Portal) → merged into Service 6
- Service 0.5 (Human Agent Management) → merged into Service 0

---

## PART 1: MICROSERVICES_ARCHITECTURE.md Changes

### Change 1.1: Executive Summary Update

**Location**: Lines 1-38

**Current**:
```
The architecture decomposes a complex workflow into **22 specialized microservices** (Services 0, 0.5, 1-20)
```

**New**:
```
The architecture decomposes a complex workflow into **15 specialized microservices** (Services 0, 1, 2, 3, 6, 7, 8, 9, 11-15, 17, 20, 21) plus supporting libraries (@workflow/llm-sdk, @workflow/config-sdk)

**Architecture Consolidation**: This architecture represents an optimized design that eliminates distributed monolith anti-patterns, shared database issues, and unnecessary network hops through strategic service mergers and library conversions. Previous iterations identified opportunities for consolidation that improved the architecture health score from 6.5/10 to 9+/10.
```

---

### Change 1.2: Architecture Overview Diagram Update

**Location**: Lines 146-197

**Current Diagram Shows**: Services 0, 0.5, 1-10

**Updated Diagram**:
```
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway (Kong)                       │
│              Authentication • Rate Limiting • Routing            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Event Bus (Apache Kafka)                    │
│   Topics (19): auth_events, org_events, collaboration_events,   │
│   client_events, prd_events, demo_events, sales_doc_events,     │
│   research_events, config_events, voice_events,                 │
│   escalation_events, monitoring_incidents,                      │
│   analytics_experiments, customer_success_events,               │
│   support_tickets, communication_events, personalization_events,│
│   cross_product_events                                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴──────────────────────┐
         │                                           │
         ▼                                           ▼
┌─────────────────┐                        ┌──────────────────┐
│  Core Services  │                        │  Support Services│
├─────────────────┤                        ├──────────────────┤
│ 0. Org & Identity│                       │ 11. Monitoring   │
│    Management   │                        │ 12. Analytics    │
│ 1. Research     │                        │ 13. Customer     │
│ 2. Demo Gen     │                        │     Success      │
│ 3. Sales Doc    │◄───────────────────────┤ 14. Support      │
│    Generator    │  (Handoffs & Routing)  │ 15. CRM          │
│ 6. PRD Builder &│                        │     Integration  │
│    Config       │                        │ 17. RAG Pipeline │
│ 7. Automation   │                        │ 20. Comm & Hyper │
│ 8. Agent Orch   │                        │ 21. Agent Copilot│
│ 9. Voice Agent  │                        └──────────────────┘
└─────────────────┘

Supporting Libraries (Direct SDK Integration):
- @workflow/llm-sdk: Direct LLM provider access (used by Services 8, 9, 21)
- @workflow/config-sdk: S3 config management with validation (used by all services)

Data Layer:
- PostgreSQL (Supabase) with RLS: Transactional data, multi-tenant isolation
- Qdrant: Vector storage for RAG, namespace-per-tenant
- Neo4j: Knowledge graphs for GraphRAG
- Redis: Caching, session state, rate limiting, auth tokens
- TimescaleDB: Time-series metrics and analytics
```

---

### Change 1.3: Rename Service 0

**Location**: Line 266

**Current**: `### 0. Organization Management & Authentication Service`

**New**: `### 0. Organization & Identity Management Service`

**Add Consolidation Note** (after line 268):
```markdown
**🔄 Consolidated Service**: This service was created by merging:
- **Former Service 0**: Organization Management & Authentication
- **Former Service 0.5**: Human Agent Management

**Rationale**: Eliminated shared database anti-pattern. Both services shared the `auth.users` table, creating tight coupling and violating microservices autonomy. Consolidating into a single "Identity Management" service provides unified authentication, authorization, and identity management for both client organizations and platform human agents.
```

---

### Change 1.4: Expand Service 0 Objectives

**Location**: Lines 268-274

**Add to Objectives** (after current objectives):
```markdown
- **Extended Purpose**: Unified identity management for ALL platform users (client organizations + platform human agents)
- **Human Agent Management**: Multi-role agent registration, handoff orchestration, specialist routing, workload balancing
- **Client Lifecycle Tracking**: Assignment management through Sales → Onboarding → Support → Success stages
```

---

### Change 1.5: Expand Service 0 Database Schema

**Current Schema** (lines 307-400): Contains only client organization tables

**Add to Schema** (merge from Service 0.5):
```sql
-- agent_profiles table (extends auth.users where user_type='agent')
CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  roles JSONB NOT NULL,  -- Array of role objects
  permissions JSONB NOT NULL DEFAULT '{}',
  capacity JSONB NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  availability TEXT DEFAULT 'offline' CHECK (availability IN ('online', 'busy', 'offline', 'away')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- client_assignments table
CREATE TABLE client_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  assigned_role TEXT NOT NULL,
  lifecycle_stage TEXT NOT NULL,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assignment_type TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'transferred')),
  completed_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'
);

-- handoffs table
CREATE TABLE handoffs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  from_agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  from_role TEXT NOT NULL,
  to_agent_id UUID REFERENCES agent_profiles(id),
  to_role TEXT NOT NULL,
  lifecycle_stage_from TEXT NOT NULL,
  lifecycle_stage_to TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
  handoff_type TEXT NOT NULL,
  context_notes TEXT,
  client_prefs JSONB,
  technical_requirements JSONB,
  initiated_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  rejection_reason TEXT
);

-- specialist_invitations table
CREATE TABLE specialist_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  invited_by_agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  specialist_agent_id UUID REFERENCES agent_profiles(id),
  specialist_role TEXT NOT NULL,
  invitation_reason TEXT NOT NULL,
  opportunity_type TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  outcome JSONB
);

-- agent_activity_logs table
CREATE TABLE agent_activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  client_id UUID,
  organization_id UUID REFERENCES organizations(id),
  action_type TEXT NOT NULL,
  action_role TEXT NOT NULL,
  service_name TEXT,
  metadata JSONB DEFAULT '{}',
  duration_seconds INTEGER,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);
```

---

### Change 1.6: Expand Service 0 API Specification

**Add Agent Management APIs** (merge all APIs from Service 0.5):
- Register Human Agent
- Assign Client to Agent
- Initiate Client Handoff
- Accept/Reject Handoff
- Invite Specialist to Client
- Get Agent Workload and Queue
- Update Agent Availability
- Get Available Agents for Role
- Get Agent Permissions (for Kong)
- Get Client Lifecycle Timeline

(Full API specs available in original Service 0.5 section - copy lines 1441-2075 from original document)

---

### Change 1.7: Remove Service 0.5 Section Entirely

**Location**: Lines 1259-2243 (entire Service 0.5 section)

**Action**: DELETE this entire section

**Add Navigation Comment**:
```markdown
<!-- Service 0.5 (Human Agent Management) was consolidated into Service 0 (Organization & Identity Management) to eliminate shared database anti-pattern -->
```

---

### Change 1.8: Rename Service 3

**Location**: Line 3807

**Current**: `### 3. NDA Generator Service`

**New**: `### 3. Sales Document Generator Service`

**Add Consolidation Note**:
```markdown
**🔄 Consolidated Service**: This service was created by merging:
- **Former Service 3**: NDA Generator
- **Former Service 4**: Pricing Model Generator
- **Former Service 5**: Proposal Generator

**Rationale**: Eliminated distributed monolith anti-pattern. All three services performed the same core function (document generation with e-signature workflow) but for different document types. Consolidating into a single "Sales Document Generator" eliminates code duplication, provides unified template management, single e-signature integration, and reduces network hops for document workflows.

**Feature Coverage**: This unified service handles:
- NDA generation and e-signature workflow
- Volume-based pricing model calculation and proposal generation
- Comprehensive proposal creation with terms and conditions
- Unified document template management
- Single e-signature integration (DocuSign/HelloSign)
- Document version control and audit trails
```

---

### Change 1.9: Expand Service 3 Objectives

**Current Objectives** (line 3809-3816): Only cover NDA generation

**Replace With**:
```markdown
#### Objectives
- **Primary Purpose**: Automated generation of all sales-stage documents (NDAs, pricing models, proposals) with e-signature workflow orchestration and template management
- **Business Value**: Eliminates 80% of manual sales document preparation time, ensures consistency across all document types, provides unified version control and audit trails, integrates single e-signature workflow for all documents
- **Scope Boundaries**:
  - **Does**: Generate NDAs, pricing proposals, comprehensive proposals; manage document templates; orchestrate e-signature workflows; track document versions; handle document approvals
  - **Does Not**: Generate implementation documents (PRD Builder handles that), manage billing/invoicing (separate billing service), handle contract negotiations (human agents do this)
```

---

### Change 1.10: Expand Service 3 Requirements

**Add to Functional Requirements**:
```markdown
**NDA Generation:**
1. AI-powered NDA generation from templates
2. Customizable NDA templates (mutual, one-way, specialized)
3. E-signature workflow orchestration (DocuSign/HelloSign)
4. NDA approval tracking and reminders

**Pricing Model Generation:**
5. Volume-based tiered pricing calculation
6. Dynamic pricing based on feature selection (chatbot/voicebot)
7. Discount application (volume, early adopter, enterprise)
8. ROI calculator integration
9. Pricing proposal generation with breakdown

**Proposal Generation:**
10. Comprehensive proposal assembly (scope, pricing, terms)
11. Custom proposal templates per industry
12. Terms and conditions management
13. Proposal version control and comparison
14. Proposal approval workflow

**Unified Features:**
15. Document template management system
16. Version control for all document types
17. Unified e-signature integration
18. Document audit trails
19. Multi-tenant document isolation
20. Document collaboration (comments, edits)
```

---

### Change 1.11: Expand Service 3 Database Schema

**Merge schemas from Services 3, 4, 5**:
```sql
-- Unified sales_documents table (replaces separate nda, pricing, proposal tables)
CREATE TABLE sales_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  document_type TEXT NOT NULL CHECK (document_type IN ('nda', 'pricing', 'proposal')),
  document_subtype TEXT,  -- 'mutual_nda', 'one_way_nda', 'tiered_pricing', 'custom_proposal'
  title TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'pending_review', 'pending_signature', 'signed', 'rejected', 'expired')),
  content JSONB NOT NULL,  -- Document content and metadata
  template_id UUID REFERENCES document_templates(id),
  created_by UUID REFERENCES auth.users(id),
  reviewed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  signed_at TIMESTAMPTZ
);

-- Unified document_templates table
CREATE TABLE document_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),  -- NULL for platform templates
  template_type TEXT NOT NULL CHECK (template_type IN ('nda', 'pricing', 'proposal')),
  template_name TEXT NOT NULL,
  template_version INTEGER DEFAULT 1,
  is_default BOOLEAN DEFAULT FALSE,
  variables JSONB NOT NULL,  -- Template variables and placeholders
  content_template TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- pricing_models table (for pricing calculation logic)
CREATE TABLE pricing_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  model_name TEXT NOT NULL,
  product_type TEXT NOT NULL CHECK (product_type IN ('chatbot', 'voicebot', 'both')),
  base_price DECIMAL(10, 2) NOT NULL,
  volume_tiers JSONB NOT NULL,  -- [{min: 0, max: 1000, price_per_unit: 0.10}, ...]
  feature_pricing JSONB,  -- {advanced_analytics: 500, custom_integration: 2000}
  discount_rules JSONB,  -- {volume_threshold: 10000, discount_percent: 15}
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- e_signature_workflows table
CREATE TABLE e_signature_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES sales_documents(id) ON DELETE CASCADE,
  provider TEXT NOT NULL CHECK (provider IN ('docusign', 'hellosign', 'pandadoc')),
  provider_envelope_id TEXT UNIQUE,
  signers JSONB NOT NULL,  -- [{email, name, role, status, signed_at}]
  status TEXT DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'signed', 'declined', 'expired')),
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  webhook_events JSONB DEFAULT '[]'
);

-- document_versions table (unified version control)
CREATE TABLE document_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES sales_documents(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  changes_summary TEXT,
  content_snapshot JSONB NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### Change 1.12: Expand Service 3 API Endpoints

**Merge APIs from Services 3, 4, 5**:

**NDA Endpoints:**
- POST /api/v1/sales-docs/nda/generate
- GET /api/v1/sales-docs/nda/{id}
- POST /api/v1/sales-docs/nda/{id}/send-for-signature

**Pricing Endpoints:**
- POST /api/v1/sales-docs/pricing/calculate
- POST /api/v1/sales-docs/pricing/generate-proposal
- GET /api/v1/sales-docs/pricing/{id}

**Proposal Endpoints:**
- POST /api/v1/sales-docs/proposal/generate
- GET /api/v1/sales-docs/proposal/{id}
- PATCH /api/v1/sales-docs/proposal/{id}
- POST /api/v1/sales-docs/proposal/{id}/send-for-signature

**Unified Document Endpoints:**
- GET /api/v1/sales-docs (list all documents with filters)
- GET /api/v1/sales-docs/{id}/versions
- POST /api/v1/sales-docs/{id}/versions (create new version)
- POST /api/v1/sales-docs/templates (create template)
- GET /api/v1/sales-docs/templates (list templates)

**E-Signature Endpoints:**
- POST /api/v1/sales-docs/{id}/signature-workflow
- GET /api/v1/sales-docs/{id}/signature-status
- POST /api/v1/sales-docs/signature-webhook (for provider callbacks)

---

### Change 1.13: Update Service 3 Kafka Events

**Replace separate topics with unified topic**:

**Topic**: `sales_doc_events` (replaces `nda_events`, `pricing_events`, `proposal_events`)

**Events**:
- `sales_doc_created` (type: nda | pricing | proposal)
- `sales_doc_sent_for_signature`
- `sales_doc_signed`
- `sales_doc_rejected`
- `sales_doc_expired`
- `sales_doc_version_created`

---

### Change 1.14: Remove Service 4 Section Entirely

**Location**: Lines 4194-4705 (entire Service 4 section)

**Action**: DELETE this entire section

**Add Navigation Comment**:
```markdown
<!-- Service 4 (Pricing Model Generator) was consolidated into Service 3 (Sales Document Generator) to eliminate distributed monolith anti-pattern -->
```

---

### Change 1.15: Remove Service 5 Section Entirely

**Location**: Lines 4706-end of document (entire Service 5 section)

**Action**: DELETE this entire section

**Add Navigation Comment**:
```markdown
<!-- Service 5 (Proposal Generator) was consolidated into Service 3 (Sales Document Generator) to eliminate distributed monolith anti-pattern -->
```

---

## PART 2: MICROSERVICES_ARCHITECTURE_PART2.md Changes

### Change 2.1: Update Document Header

**Add Consolidation Note**:
```markdown
# Microservices Architecture Specification - Part 2
## PRD Builder, Automation, LLM, and RAG Services

**Note**: This document has been updated to reflect the consolidated 15-service architecture. See REFACTORING_SPECIFICATION.md for details on service mergers and eliminations.
```

---

### Change 2.2: Rename Service 6

**Current**: `### 6. PRD Builder Engine Service`

**New**: `### 6. PRD Builder & Configuration Workspace Service`

**Add Consolidation Note**:
```markdown
**🔄 Consolidated Service**: This service was created by merging:
- **Former Service 6**: PRD Builder Engine
- **Former Service 19**: Client Configuration Portal

**Rationale**: Both services provided client-facing workspace interfaces for configuration management. Service 6 handled PRD creation/collaboration during onboarding, while Service 19 handled post-deployment config management. Merging these eliminates the artificial boundary and provides a unified workspace for all client configuration needs throughout the lifecycle.

**Feature Coverage**:
- PRD creation and AI-powered generation during onboarding
- Real-time collaboration on PRDs with version control
- Post-deployment configuration management (system prompts, tools, voice params)
- Conversational editing with AI assistance
- Permission-based access control for config changes
- Hot-reload orchestration with risk assessment
```

---

### Change 2.3: Expand Service 6 Objectives

**Add to Objectives**:
```markdown
- **Extended Purpose**: Unified client workspace for PRD creation (onboarding) AND ongoing configuration management (post-deployment)
- **Lifecycle Coverage**: Spans from initial PRD generation through continuous product iteration and configuration updates
- **Self-Service**: Empowers clients to manage their own configurations with AI-guided editing and safety guardrails
```

---

### Change 2.4: Expand Service 6 Database Schema

**Add Configuration Management Tables** (merge from Service 19):
```sql
-- config_change_requests table (for self-service config management)
CREATE TABLE config_change_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  requested_by UUID NOT NULL REFERENCES auth.users(id),
  config_type TEXT NOT NULL CHECK (config_type IN ('system_prompt', 'tools', 'voice_params', 'integrations')),
  change_description TEXT NOT NULL,
  current_value JSONB NOT NULL,
  proposed_value JSONB NOT NULL,
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high')),
  requires_approval BOOLEAN DEFAULT FALSE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'deployed', 'rolled_back')),
  approved_by UUID REFERENCES auth.users(id),
  deployed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- config_permissions table (who can change what)
CREATE TABLE config_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  can_view_configs BOOLEAN DEFAULT TRUE,
  can_edit_system_prompt BOOLEAN DEFAULT FALSE,
  can_edit_tools BOOLEAN DEFAULT FALSE,
  can_edit_voice_params BOOLEAN DEFAULT FALSE,
  can_edit_integrations BOOLEAN DEFAULT FALSE,
  can_rollback_versions BOOLEAN DEFAULT FALSE,
  can_deploy_configs BOOLEAN DEFAULT FALSE,
  can_manage_permissions BOOLEAN DEFAULT FALSE,
  max_risk_level TEXT DEFAULT 'low' CHECK (max_risk_level IN ('low', 'medium', 'high')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

-- conversational_edit_sessions table (AI-guided editing)
CREATE TABLE conversational_edit_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  session_type TEXT NOT NULL CHECK (session_type IN ('prd_creation', 'config_edit', 'troubleshooting')),
  messages JSONB NOT NULL DEFAULT '[]',  -- Conversation history
  current_draft JSONB,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);
```

---

### Change 2.5: Expand Service 6 API Endpoints

**Add Configuration Management APIs** (merge from Service 19):
- POST /api/v1/prd/{org_id}/config/change-request
- GET /api/v1/prd/{org_id}/config/change-requests
- POST /api/v1/prd/{org_id}/config/conversational-edit
- POST /api/v1/prd/{org_id}/config/deploy
- POST /api/v1/prd/{org_id}/config/rollback
- GET /api/v1/prd/{org_id}/config/permissions
- PATCH /api/v1/prd/{org_id}/config/permissions/{user_id}

---

### Change 2.6: Convert Service 16 to Library

**Location**: Service 16 section (find with grep)

**Action**: Move entire Service 16 specification to new "Supporting Libraries" section at end of document

**New Section Structure**:
```markdown
---

## Supporting Libraries

### @workflow/llm-sdk (formerly Service 16: LLM Gateway)

**🔄 Architecture Change**: Converted from microservice to SDK library to eliminate 200-500ms latency per AI call.

**Rationale**: Service 16 acted as a pass-through layer to LLM providers with no business logic beyond routing and caching. Every AI call required two network hops (service → gateway → provider → gateway → service). Converting to a library eliminates this overhead while preserving all functionality.

#### Library Purpose
- Direct LLM provider access (OpenAI, Anthropic, Cohere)
- Semantic caching with Redis integration
- Model routing and fallback logic
- Cost tracking per request
- Token usage monitoring
- Streaming support for real-time responses

#### Installation
```bash
npm install @workflow/llm-sdk
# or
pip install workflow-llm-sdk
```

#### Usage Example
```typescript
import { LLMClient, ModelType } from '@workflow/llm-sdk';

const llm = new LLMClient({
  apiKey: process.env.OPENAI_API_KEY,
  fallbackProvider: 'anthropic',
  semanticCacheEnabled: true,
  redisCacheUrl: process.env.REDIS_URL
});

const response = await llm.chat({
  model: ModelType.GPT4,
  messages: [{role: 'user', content: 'Generate a PRD'}],
  temperature: 0.7,
  stream: true,
  organizationId: 'uuid',  // For cost tracking
  userId: 'uuid'
});

for await (const chunk of response) {
  console.log(chunk.content);
}
```

#### Configuration
```typescript
interface LLMConfig {
  // Provider Configuration
  openai?: {
    apiKey: string;
    organization?: string;
  };
  anthropic?: {
    apiKey: string;
  };
  cohere?: {
    apiKey: string;
  };

  // Model Routing
  modelRoutes?: {
    [task: string]: ModelType;  // e.g., 'simple': GPT35, 'complex': GPT4
  };

  // Caching
  semanticCacheEnabled?: boolean;
  cacheThreshold?: number;  // Similarity threshold for cache hits
  cacheTTL?: number;  // Time-to-live in seconds

  // Cost Optimization
  costTrackingEnabled?: boolean;
  maxTokensPerRequest?: number;

  // Resilience
  maxRetries?: number;
  fallbackProvider?: 'anthropic' | 'cohere' | 'none';
}
```

#### Features Preserved from Service 16
✅ Multi-provider support (OpenAI, Anthropic, Cohere)
✅ Semantic caching (Redis-based)
✅ Cost tracking per organization/user
✅ Token usage monitoring
✅ Model routing and fallback
✅ Streaming support
✅ Rate limiting (client-side)
✅ Error handling and retries

#### Integration Points
**Used By**:
- Service 8 (Agent Orchestration) - chatbot LLM calls
- Service 9 (Voice Agent) - voicebot LLM calls
- Service 21 (Agent Copilot) - context management LLM calls
- Service 6 (PRD Builder) - PRD generation
- Service 2 (Demo Generator) - demo script generation
- Service 3 (Sales Document Generator) - document generation

**Dependencies**:
- Redis (semantic cache storage)
- PostgreSQL (cost tracking, usage metrics)

#### Cost Tracking Schema
```sql
CREATE TABLE llm_usage_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  user_id UUID REFERENCES auth.users(id),
  service_name TEXT NOT NULL,
  model TEXT NOT NULL,
  prompt_tokens INTEGER NOT NULL,
  completion_tokens INTEGER NOT NULL,
  total_cost_usd DECIMAL(10, 6) NOT NULL,
  cached BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_llm_usage_org ON llm_usage_logs(organization_id, timestamp DESC);
CREATE INDEX idx_llm_usage_service ON llm_usage_logs(service_name, timestamp DESC);
```

---
```

---

## PART 3: MICROSERVICES_ARCHITECTURE_PART3.md Changes

### Change 3.1: Convert Service 10 to Library

**Location**: Service 10 section

**Action**: Move to "Supporting Libraries" section

**New Section**:
```markdown
### @workflow/config-sdk (formerly Service 10: Configuration Management)

**🔄 Architecture Change**: Converted from microservice to SDK library to eliminate 50-100ms latency per config access.

**Rationale**: Service 10 acted as a simple wrapper around S3 operations with JSON Schema validation. Converting to a library eliminates network overhead while preserving all functionality and improving config access performance.

#### Library Purpose
- YAML config storage/retrieval from S3
- JSON Schema validation
- Hot-reload notifications via Redis
- Version control for configs
- Multi-tenant config isolation

#### Installation
```bash
npm install @workflow/config-sdk
# or
pip install workflow-config-sdk
```

#### Usage Example
```typescript
import { ConfigClient } from '@workflow/config-sdk';

const config = new ConfigClient({
  s3Bucket: process.env.CONFIG_S3_BUCKET,
  s3Region: 'us-east-1',
  redisUrl: process.env.REDIS_URL,
  schemaValidation: true
});

// Load configuration
const agentConfig = await config.load({
  organizationId: 'uuid',
  productType: 'chatbot',
  environment: 'production'
});

// Watch for changes
config.watch({
  organizationId: 'uuid',
  productType: 'chatbot',
  onChange: (newConfig) => {
    console.log('Config updated:', newConfig);
    // Reload agent with new config
  }
});

// Save configuration
await config.save({
  organizationId: 'uuid',
  productType: 'chatbot',
  config: updatedConfig,
  version: '1.2.0',
  userId: 'uuid'
});
```

#### Features Preserved from Service 10
✅ S3 config storage
✅ JSON Schema validation
✅ Hot-reload via Redis pub/sub
✅ Version control
✅ Multi-tenant isolation
✅ Config templates
✅ Rollback support
✅ Audit logging

#### Integration Points
**Used By**: All services that need config access

**Dependencies**:
- S3 (config storage)
- Redis (hot-reload notifications)
- PostgreSQL (audit logs)
```

---

### Change 3.2: Merge Service 18 into Service 20

**Location**: Find Service 18 and Service 20 sections

**Action**:
1. Expand Service 20 title and consolidation note
2. Merge Service 18 features into Service 20
3. Delete Service 18 section

**Service 20 New Title**:
```markdown
### 20. Communication & Hyperpersonalization Engine Service
```

**Consolidation Note**:
```markdown
**🔄 Consolidated Service**: This service was created by merging:
- **Former Service 18**: Outbound Communication Service
- **Former Service 20**: Hyperpersonalization Engine

**Rationale**: Both services dealt with communication to customers. Service 18 handled transactional emails/SMS (requirements forms, follow-ups), while Service 20 handled lifecycle-based personalization. Merging eliminates email/SMS integration duplication and provides unified communication orchestration.

**Feature Coverage**:
- Transactional email/SMS (onboarding, requirements, follow-ups)
- Lifecycle-based hyperpersonalization (success, support, upsell campaigns)
- Unified email template management
- A/B testing for communication strategies
- Cohort-based segmentation
- Communication analytics and optimization
```

---

### Change 3.3: Expand Service 20 Features

**Add from Service 18**:
```markdown
**Outbound Communication:**
- Email/SMS delivery (SendGrid, Twilio)
- Requirements form generation and distribution
- Follow-up sequence automation
- Delivery tracking and analytics
- Template management for transactional emails

**Hyperpersonalization (existing):**
- Lifecycle-based messaging
- A/B testing
- Cohort segmentation
- Dynamic content generation
```

---

### Change 3.4: Remove Service 19 Section

**Location**: Service 19 section

**Action**: DELETE entire section

**Add Navigation Comment**:
```markdown
<!-- Service 19 (Client Configuration Portal) was consolidated into Service 6 (PRD Builder & Configuration Workspace) in PART2 to provide unified client workspace -->
```

---

## PART 4: SERVICE_INDEX.md Complete Rewrite

**Replace entire file with**:

```markdown
# Microservices Architecture - Master Service Index

**Total Services: 15** (down from 22 through strategic consolidation)

This index provides quick navigation to all microservices across the three architecture documents.

**Architecture Health**: Optimized from initial 22-service design through consolidation of distributed monoliths, elimination of shared database anti-patterns, and conversion of pass-through services to libraries.

---

## Service Locations by Document

### MICROSERVICES_ARCHITECTURE.md (Part 1)
**5 Services**

| Service # | Service Name | Purpose |
|-----------|--------------|---------|
| 0 | Organization & Identity Management | Auth, multi-tenant org setup, member management, human agent management (merged 0 + 0.5) |
| 1 | Research Engine | Automated market research, volume prediction, competitor analysis |
| 2 | Demo Generator | AI-powered chatbot/voicebot demo creation |
| 3 | Sales Document Generator | Unified NDA, pricing, proposal generation with e-signature (merged 3 + 4 + 5) |

---

### MICROSERVICES_ARCHITECTURE_PART2.md (Part 2)
**4 Services + 2 Libraries**

| Service # | Service Name | Purpose |
|-----------|--------------|---------|
| 6 | PRD Builder & Configuration Workspace | PRD generation, collaboration, ongoing config management (merged 6 + 19) |
| 7 | Automation Engine | YAML config generation, GitHub issue creation, hot-reload management |
| 17 | RAG Pipeline | Retrieval-Augmented Generation for knowledge injection |

**Supporting Libraries:**
| Library | Purpose |
|---------|---------|
| @workflow/llm-sdk | Direct LLM provider access (formerly Service 16) |
| @workflow/config-sdk | S3 config management with validation (formerly Service 10) |

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
| 20 | Communication & Hyperpersonalization Engine | Unified email/SMS, lifecycle personalization (merged 18 + 20) |

---

### Standalone Document
**1 Service**

| Service # | Service Name | Document | Purpose |
|-----------|--------------|----------|---------|
| 21 | Agent Copilot | SERVICE_21_AGENT_COPILOT.md | AI-powered context management for human agents |

---

## Quick Reference: Service by Number

| # | Name | Document | Notes |
|---|------|----------|-------|
| 0 | Organization & Identity Management | PART1 | Merged 0 + 0.5 |
| 1 | Research Engine | PART1 | |
| 2 | Demo Generator | PART1 | |
| 3 | Sales Document Generator | PART1 | Merged 3 + 4 + 5 |
| ~~4~~ | ~~Pricing Model Generator~~ | *Eliminated* | Merged into Service 3 |
| ~~5~~ | ~~Proposal Generator~~ | *Eliminated* | Merged into Service 3 |
| 6 | PRD Builder & Configuration Workspace | PART2 | Merged 6 + 19 |
| 7 | Automation Engine | PART2 | |
| 8 | Agent Orchestration (Chatbot) | PART3 | |
| 9 | Voice Agent (Voicebot) | PART3 | |
| ~~10~~ | ~~Configuration Management~~ | *Library* | Now @workflow/config-sdk |
| 11 | Monitoring Engine | PART3 | |
| 12 | Analytics | PART3 | |
| 13 | Customer Success | PART3 | |
| 14 | Support Engine | PART3 | |
| 15 | CRM Integration | PART3 | |
| ~~16~~ | ~~LLM Gateway~~ | *Library* | Now @workflow/llm-sdk |
| 17 | RAG Pipeline | PART2 | |
| ~~18~~ | ~~Outbound Communication~~ | *Eliminated* | Merged into Service 20 |
| ~~19~~ | ~~Client Configuration Portal~~ | *Eliminated* | Merged into Service 6 |
| 20 | Communication & Hyperpersonalization | PART3 | Merged 18 + 20 |
| 21 | Agent Copilot | Standalone | |

---

## Service Categories

### **Foundation Layer (Infrastructure)**
- Service 0: Organization & Identity Management
- @workflow/llm-sdk: LLM access library
- @workflow/config-sdk: Configuration library
- Service 17: RAG Pipeline

### **Client Acquisition (Sales Pipeline)**
- Service 1: Research Engine
- Service 2: Demo Generator
- Service 3: Sales Document Generator (unified NDA/pricing/proposal)
- Service 20: Communication & Hyperpersonalization (includes outbound)

### **Implementation (Onboarding)**
- Service 6: PRD Builder & Configuration Workspace
- Service 7: Automation Engine

### **Runtime (Production Operations)**
- Service 8: Agent Orchestration (Chatbot)
- Service 9: Voice Agent (Voicebot)
- Service 11: Monitoring Engine
- Service 12: Analytics

### **Customer Operations**
- Service 13: Customer Success
- Service 14: Support Engine
- Service 15: CRM Integration
- Service 21: Agent Copilot

---

## Event-Driven Communication

### **Kafka Topics (17 Total)** - Updated

| Topic | Primary Producers | Primary Consumers |
|-------|------------------|-------------------|
| `auth_events` | Service 0 | Services 1, 20 |
| `research_events` | Service 1 | Service 2 |
| `client_events` | Service 0 | Multiple |
| `demo_events` | Service 2 | Service 3 |
| `sales_doc_events` | Service 3 | Service 6 |
| `prd_events` | Service 6 | Service 7 |
| `config_events` | Service 7 | Services 8, 9 |
| `conversation_events` | Services 8, 9 | Services 11, 12, 20 |
| `voice_events` | Service 9 | Services 11, 12 |
| `support_events` | Service 14 | Services 13, 21 |
| `customer_success_events` | Service 13 | Services 20, 21 |
| `communication_events` | Service 20 | Services 8, 9 |
| `monitoring_incidents` | Service 11 | Services 13, 14, 21 |
| `analytics_experiments` | Service 12 | Services 13, 20 |
| `crm_sync_events` | Service 15 | Services 13, 14 |
| `collaboration_events` | Service 6 | Service 0 |
| `cross_product_events` | Services 8, 9 | Service 12 |

**Removed Topics** (consolidated):
- ~~`nda_events`~~ → merged into `sales_doc_events`
- ~~`pricing_events`~~ → merged into `sales_doc_events`
- ~~`proposal_events`~~ → merged into `sales_doc_events`
- ~~`agent_events`~~ → now internal to Service 0
- ~~`outreach_events`~~ → merged into `communication_events`
- ~~`personalization_events`~~ → merged into `communication_events`

---

## Architecture Consolidation Summary

### Mergers Completed
1. **Service 0 + Service 0.5** → Organization & Identity Management
   - Rationale: Eliminated shared database anti-pattern

2. **Services 3 + 4 + 5** → Sales Document Generator
   - Rationale: Eliminated distributed monolith (same function, different docs)

3. **Service 6 + Service 19** → PRD Builder & Configuration Workspace
   - Rationale: Unified client workspace across lifecycle stages

4. **Service 18 + Service 20** → Communication & Hyperpersonalization Engine
   - Rationale: Eliminated email/SMS integration duplication

### Microservices → Libraries
1. **Service 16** → @workflow/llm-sdk
   - Rationale: Eliminated 200-500ms latency per AI call

2. **Service 10** → @workflow/config-sdk
   - Rationale: Eliminated 50-100ms latency per config access

### Impact
- **Services Reduced**: 22 → 15 (32% reduction)
- **Feature Duplication**: Eliminated (e-signature, email/SMS, templates)
- **Latency Improvements**: 250-600ms average savings on AI + config calls
- **Architecture Health Score**: 6.5/10 → 9+/10
- **Maintenance Complexity**: Significantly reduced through consolidation

---

**Last Updated**: 2025-10-08
**Document Version**: 2.0 (Consolidated Architecture)
**Maintained By**: Technical Documentation Team
```

---

## Cross-Reference Updates Required

### Throughout All Documents

**Find and Replace**:
1. "Service 0.5" OR "Human Agent Management Service" → "Service 0 (Organization & Identity Management)"
2. "Service 4" OR "Pricing Model Generator" → "Service 3 (Sales Document Generator - Pricing Module)"
3. "Service 5" OR "Proposal Generator" → "Service 3 (Sales Document Generator - Proposal Module)"
4. "Service 10" OR "Configuration Management Service" → "@workflow/config-sdk library"
5. "Service 16" OR "LLM Gateway Service" → "@workflow/llm-sdk library"
6. "Service 18" OR "Outbound Communication Service" → "Service 20 (Communication & Hyperpersonalization)"
7. "Service 19" OR "Client Configuration Portal" → "Service 6 (PRD Builder & Configuration Workspace)"
8. "22 services" → "15 services"
9. "22 specialized microservices" → "15 specialized microservices plus supporting libraries"

### Kafka Topic References

**Find and Replace**:
1. `nda_events` → `sales_doc_events`
2. `pricing_events` → `sales_doc_events`
3. `proposal_events` → `sales_doc_events`
4. `agent_events` → `internal to Service 0` (remove from event bus documentation)
5. `outreach_events` → `communication_events`
6. `personalization_events` → `communication_events`

---

## Implementation Checklist

### Phase 1: Documentation Updates
- [ ] Update MICROSERVICES_ARCHITECTURE.md executive summary
- [ ] Merge Service 0.5 into Service 0
- [ ] Merge Services 3, 4, 5 into Service 3
- [ ] Remove eliminated service sections
- [ ] Add consolidation notes to merged services

### Phase 2: Part 2 Updates
- [ ] Merge Service 19 into Service 6
- [ ] Convert Service 16 to library documentation
- [ ] Convert Service 10 to library documentation
- [ ] Create "Supporting Libraries" section
- [ ] Update cross-references

### Phase 3: Part 3 Updates
- [ ] Merge Service 18 into Service 20
- [ ] Remove Service 19 reference
- [ ] Remove Service 10 section
- [ ] Update dependency graphs

### Phase 4: Index Updates
- [ ] Completely rewrite SERVICE_INDEX.md
- [ ] Update service count (22 → 15)
- [ ] Document eliminated services
- [ ] Update Kafka topics list
- [ ] Add consolidation summary

### Phase 5: Cross-Reference Validation
- [ ] Search and replace all "Service 0.5" references
- [ ] Search and replace all "Service 4" and "Service 5" references
- [ ] Search and replace all "Service 10" and "Service 16" references
- [ ] Search and replace all "Service 18" and "Service 19" references
- [ ] Update all Kafka topic references
- [ ] Update all "22 services" mentions

### Phase 6: Verification
- [ ] Verify no broken cross-references
- [ ] Verify all eliminated services have navigation comments
- [ ] Verify all merged services have consolidation notes
- [ ] Verify Kafka topics align with new architecture
- [ ] Verify service dependency graphs are accurate

---

## Notes for Implementation

1. **Large File Handling**: The documents are very large (5000-8000 lines each). Use line-by-line editing tools rather than full rewrites.

2. **Preserve Existing Content**: Most content remains unchanged. Only merge/consolidate specific sections.

3. **Cross-References**: After structural changes, do a comprehensive search for all eliminated service numbers (0.5, 4, 5, 10, 16, 18, 19) and update references.

4. **Kafka Topics**: Update event bus documentation to show consolidated topics.

5. **Database Schemas**: Merge schemas carefully, ensuring no foreign key conflicts.

6. **API Endpoints**: Combine endpoints from merged services under unified routes.

---

**This specification provides a complete blueprint for refactoring the architecture from 22 to 15 services. Each change is documented with rationale, location, and specific edits required.**
