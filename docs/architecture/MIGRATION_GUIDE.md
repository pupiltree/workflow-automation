# Migration Guide: 22 Services → 15 Services Architecture

**Version**: 2.0
**Date**: 2025-10-08
**Status**: Ready for Implementation

---

## Overview

This guide provides comprehensive instructions for migrating from the original 22-service architecture to the optimized 15-service architecture with supporting libraries.

**Architecture Consolidation Summary**:
- **Before**: 22 microservices
- **After**: 15 microservices + 2 supporting libraries
- **Reduction**: 30% fewer services
- **Performance Improvement**: 200-500ms latency reduction

---

## Service Consolidation Mapping

### Active Services (15)

| # | Service Name | Status |
|---|--------------|--------|
| **0** | Organization & Identity Management | ✅ Active (merged with 0.5) |
| 1 | Research Engine | ✅ Active |
| 2 | Demo Generator | ✅ Active |
| **3** | Sales Document Generator | ✅ Active (merged with 4, 5) |
| **6** | PRD Builder & Configuration Workspace | ✅ Active (merged with 19) |
| 7 | Automation Engine | ✅ Active |
| 8 | Agent Orchestration (Chatbot) | ✅ Active |
| 9 | Voice Agent (Voicebot) | ✅ Active |
| 11 | Monitoring Engine | ✅ Active |
| 12 | Analytics | ✅ Active |
| 13 | Customer Success | ✅ Active |
| 14 | Support Engine | ✅ Active |
| 15 | CRM Integration | ✅ Active |
| 17 | RAG Pipeline | ✅ Active |
| **20** | Communication & Hyperpersonalization Engine | ✅ Active (merged with 18) |
| 21 | Agent Copilot | ✅ Active |

**Bold** = Consolidated service

### Eliminated Services (7)

| Old # | Old Name | New Owner | Migration Path |
|-------|----------|-----------|----------------|
| 0.5 | Human Agent Management | Service 0 | Merge database tables, API endpoints |
| 4 | Pricing Model Generator | Service 3 | Merge into Sales Document Generator |
| 5 | Proposal Generator | Service 3 | Merge into Sales Document Generator |
| 10 | Configuration Management | @workflow/config-sdk | Convert to library |
| 16 | LLM Gateway | @workflow/llm-sdk | Convert to library |
| 18 | Outbound Communication | Service 20 | Merge into Communication Engine |
| 19 | Client Configuration Portal | Service 6 | Merge into PRD Builder |

---

## API Endpoint Migration

### Service 0.5 → Service 0

**Migrated Endpoints** (added to Service 0):
- POST /api/v1/agents/register → Service 0, Endpoint 17
- POST /api/v1/agents/:id/assign-client → Service 0, Endpoint 18
- POST /api/v1/agents/:id/handoff → Service 0, Endpoint 19
- PUT /api/v1/agents/:id/availability → Service 0, Endpoint 20
- GET /api/v1/agents/:id/metrics → Service 0, Endpoint 21

**Base URL**: No change (Kong Gateway routes to Service 0)

### Services 4, 5 → Service 3

**Pricing Endpoints** (formerly Service 4):
- POST /api/v1/pricing-models → Service 3, Endpoint 7
- GET /api/v1/pricing-models/:id → Service 3, Endpoint 8
- PUT /api/v1/pricing-models/:id → Service 3, Endpoint 9
- POST /api/v1/pricing-models/:id/approve → Service 3, Endpoint 10

**Proposal Endpoints** (formerly Service 5):
- POST /api/v1/proposals → Service 3, Endpoint 11
- GET /api/v1/proposals/:id → Service 3, Endpoint 12
- PUT /api/v1/proposals/:id → Service 3, Endpoint 13
- POST /api/v1/proposals/:id/send → Service 3, Endpoint 14
- GET /api/v1/proposals/:id/status → Service 3, Endpoint 15

**Base URL**: `/api/v1/*` (no change, all routed to Service 3)

### Service 10 → @workflow/config-sdk Library

**Old API Calls**:
```typescript
// OLD: HTTP call to Service 10
const response = await fetch('http://config-service/api/v1/configs/chatbot_sales');
const config = await response.json();
```

**New Library Usage**:
```typescript
// NEW: Direct S3 access via library
import { ConfigClient } from '@workflow/config-sdk';
const config = new ConfigClient({ s3Bucket: 'workflow-configs', tenantId: 'org_123' });
const agentConfig = await config.get({ configType: 'agent', configId: 'chatbot_sales' });
```

### Service 16 → @workflow/llm-sdk Library

**Old API Calls**:
```typescript
// OLD: HTTP call to Service 16
const response = await fetch('http://llm-gateway/api/v1/completions', {
  method: 'POST',
  body: JSON.stringify({ prompt, max_tokens: 2000 })
});
```

**New Library Usage**:
```typescript
// NEW: Direct LLM call via library
import { LLMClient } from '@workflow/llm-sdk';
const llm = new LLMClient({ apiKey: process.env.OPENAI_API_KEY });
const response = await llm.complete({ prompt, maxTokens: 2000 });
```

### Service 18 → Service 20

**Email/SMS Endpoints** (now in Service 20):
- POST /api/v1/communications/email → Service 20
- POST /api/v1/communications/sms → Service 20
- GET /api/v1/communications/:id/status → Service 20

**Base URL**: No change (`/api/v1/communications/*`)

### Service 19 → Service 6

**Configuration Portal Endpoints** (now in Service 6):
- POST /api/v1/prd/config/chat → Service 6, Config Management API 1
- PUT /api/v1/prd/config/visual-update → Service 6, Config Management API 2
- GET /api/v1/prd/config/versions → Service 6, Config Management API 3
- POST /api/v1/prd/config/rollback → Service 6, Config Management API 4
- PUT /api/v1/prd/config/permissions → Service 6, Config Management API 5

---

## Database Schema Migration

### Service 0.5 → Service 0

**New Tables Added to Service 0**:
```sql
-- Agent profiles
CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  roles JSONB NOT NULL,  -- ["sales_agent", "onboarding_specialist"]
  permissions JSONB NOT NULL,
  availability_status VARCHAR(50),
  current_capacity INTEGER,
  max_capacity INTEGER
);

-- Client assignments
CREATE TABLE client_assignments (
  id UUID PRIMARY KEY,
  agent_id UUID REFERENCES agent_profiles(id),
  client_id UUID REFERENCES clients(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  status VARCHAR(50)
);

-- Handoffs
CREATE TABLE handoffs (
  id UUID PRIMARY KEY,
  from_agent_id UUID,
  to_agent_id UUID,
  client_id UUID,
  handoff_reason TEXT,
  context_summary JSONB,
  created_at TIMESTAMPTZ
);
```

**Migration Steps**:
1. Create new tables in Service 0 database
2. Migrate data from Service 0.5 database (if exists)
3. Update Row-Level Security (RLS) policies
4. Verify multi-tenant isolation

### Services 4, 5 → Service 3

**New Tables Added to Service 3**:
```sql
-- Pricing models (from Service 4)
CREATE TABLE pricing_models (
  id UUID PRIMARY KEY,
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  volume_tiers JSONB NOT NULL,
  approval_status VARCHAR(50),
  created_at TIMESTAMPTZ
);

-- Proposals (from Service 5)
CREATE TABLE proposals (
  id UUID PRIMARY KEY,
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  nda_id UUID REFERENCES ndas(id),
  pricing_model_id UUID REFERENCES pricing_models(id),
  content JSONB NOT NULL,
  status VARCHAR(50),
  signed_at TIMESTAMPTZ
);

-- Shared e-signatures table
CREATE TABLE e_signatures (
  id UUID PRIMARY KEY,
  document_id UUID NOT NULL,
  document_type VARCHAR(50),  -- 'nda', 'proposal'
  provider VARCHAR(50),  -- 'docusign', 'hellosign'
  signature_request_id VARCHAR(255),
  status VARCHAR(50)
);
```

---

## Kafka Topic Migration

### Consolidated Topics

| Old Topics | New Topic | Migration Notes |
|------------|-----------|-----------------|
| nda_events, pricing_events, proposal_events | sales_doc_events | Unified event schema |
| outreach_events, personalization_events | communication_events | Merged communication topics |

**Total Topics**: 19 → 17

### Event Schema Changes

**sales_doc_events** (unified):
```json
{
  "event_type": "nda_generated | pricing_approved | proposal_sent",
  "document_id": "uuid",
  "document_type": "nda | pricing | proposal",
  "organization_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-08T..."
}
```

**communication_events** (unified):
```json
{
  "event_type": "email_sent | sms_sent | campaign_triggered",
  "communication_id": "uuid",
  "channel": "email | sms | push",
  "recipient": "email or phone",
  "template_id": "uuid",
  "timestamp": "2025-10-08T..."
}
```

---

## Library Installation Guide

### @workflow/llm-sdk

**Python**:
```bash
pip install workflow-llm-sdk
```

**Node.js**:
```bash
npm install @workflow/llm-sdk
```

**Configuration**:
```python
from workflow_llm_sdk import LLMClient

llm = LLMClient(
    api_key=os.getenv("OPENAI_API_KEY"),
    fallback_api_key=os.getenv("ANTHROPIC_API_KEY"),
    enable_caching=True,
    tenant_id="org_123"
)
```

### @workflow/config-sdk

**Python**:
```bash
pip install workflow-config-sdk
```

**Node.js**:
```bash
npm install @workflow/config-sdk
```

**Configuration**:
```python
from workflow_config_sdk import ConfigClient

config = ConfigClient(
    s3_bucket="workflow-configs",
    redis_url="redis://localhost:6379",
    tenant_id="org_123",
    enable_caching=True
)
```

---

## Deployment Strategy

### Phase 1: Infrastructure (Week 1-2)
1. Update Kubernetes deployments (remove Services 0.5, 4, 5, 10, 16, 18, 19)
2. Update Kong API Gateway routes
3. Deploy new Service 0 (with agent management)
4. Deploy new Service 3 (with sales documents)
5. Deploy new Service 6 (with config portal)
6. Deploy new Service 20 (with communication)

### Phase 2: Database Migration (Week 2)
1. Create new tables in consolidated services
2. Migrate data from eliminated services
3. Verify RLS policies and multi-tenant isolation
4. Test rollback procedures

### Phase 3: Kafka Topics (Week 2)
1. Create new unified topics (sales_doc_events, communication_events)
2. Update producers to publish to new topics
3. Update consumers to subscribe to new topics
4. Deprecate old topics (keep for 30 days)

### Phase 4: Library Deployment (Week 3)
1. Publish @workflow/llm-sdk to package registry
2. Publish @workflow/config-sdk to package registry
3. Update Services 8, 9, 21, 13, 14 to use @workflow/llm-sdk
4. Update all services to use @workflow/config-sdk
5. Remove HTTP calls to Services 10, 16

### Phase 5: Validation & Cutover (Week 4)
1. Run cross-reference validation script
2. Integration testing (all consolidated services)
3. Load testing (verify performance improvements)
4. Gradual traffic migration (canary deployment)
5. Monitor latency improvements (200-500ms expected)
6. Decommission old services

---

## Performance Expectations

| Improvement | Before | After | Savings |
|-------------|--------|-------|---------|
| LLM Calls | 400-700ms | 200ms | 200-500ms |
| Sales Pipeline | 600-900ms | 300-400ms | 300-500ms |
| Config Fetch | 100-150ms | 10-50ms | 50-100ms |

**Total Expected Latency Reduction**: 550-1100ms per complete workflow

---

## Rollback Plan

If issues arise during migration:

1. **Database Rollback**: Restore from pre-migration backup
2. **Kafka Rollback**: Revert to old topic names, keep consumers on old topics
3. **API Rollback**: Update Kong Gateway to route to old services
4. **Library Rollback**: Revert to HTTP calls to Services 10, 16

**Rollback Time**: <30 minutes per service

---

## Testing Checklist

- [ ] All API endpoints respond correctly
- [ ] Database migrations completed successfully
- [ ] RLS policies enforce multi-tenant isolation
- [ ] Kafka events publish/consume correctly
- [ ] @workflow/llm-sdk latency < 200ms
- [ ] @workflow/config-sdk latency < 50ms
- [ ] All cross-references validated (0 failures)
- [ ] Integration tests pass (100%)
- [ ] Load tests show performance improvement

---

## Support

**Documentation**: See `docs/architecture/` for complete specifications
**Validation**: Run `./scripts/validate_cross_references.sh`
**Questions**: Contact architecture team

---

**Last Updated**: 2025-10-08
**Version**: 2.0
**Status**: Ready for Implementation
