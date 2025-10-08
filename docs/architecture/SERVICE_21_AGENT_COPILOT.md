# Service 21: Agent Copilot Service

**Category**: Customer Operations
**Status**: Active (Standalone Service)
**Owner**: Product Engineering
**Last Updated**: 2025-10-08

---

## Table of Contents

1. [Overview](#overview)
2. [Objectives & Requirements](#objectives--requirements)
3. [Architecture](#architecture)
4. [API Specification](#api-specification)
5. [Database Schema](#database-schema)
6. [Event-Driven Integration](#event-driven-integration)
7. [AI-Powered Action Planning](#ai-powered-action-planning)
8. [Communication Drafting](#communication-drafting)
9. [Approval Orchestration](#approval-orchestration)
10. [CRM Integration](#crm-integration)
11. [Village Knowledge Integration](#village-knowledge-integration)
12. [Performance Dashboard](#performance-dashboard)
13. [Multi-Tenancy & Security](#multi-tenancy--security)
14. [Dependencies](#dependencies)
15. [Testing Strategy](#testing-strategy)
16. [Deployment](#deployment)

---

## Overview

### Purpose

Service 21 (Agent Copilot) is the AI-powered context management and action planning hub for human agents across the entire client lifecycle. It provides a unified dashboard, intelligent task prioritization, communication drafting, approval orchestration, and performance tracking for Sales Agents, Onboarding Specialists, Support Specialists, and Success Managers.

### Key Capabilities

**Feature 2: Human Agent Co-Pilot System** (Already Implemented)
- Unified agent dashboard (single pane of glass for all client context)
- Real-time context aggregation from 17 Kafka topics
- Role-based views (Sales, Onboarding, Support, Success)
- Intelligent notifications and alerts
- Performance tracking vs. objectives
- Collaboration tools (handoffs, internal notes, @mentions)

**Feature 3: AI-Powered Action Planning System** (Enhanced Capabilities)
- AI-powered action plan generation with predictive outcomes
- Action sequence optimization based on historical success patterns
- Impact modeling (expected outcomes, effort, success probability)
- Continuous learning loop from action execution results
- Real-time action reprioritization based on changing context
- Daily prioritized task lists with next-best-action suggestions

**Additional Capabilities**
- Communication drafter (email, meeting agenda, QBR deck generation)
- Approval orchestration (intelligent routing based on type + risk level)
- CRM auto-update (Salesforce, HubSpot, Zendesk bi-directional sync)
- Village knowledge integration (best practices from similar clients)
- WebSocket real-time updates for dashboard

### Business Value

- **95% Automation Goal**: Enhances human agent productivity during the 5% of workflows requiring human intervention
- **Context Switching Reduction**: Eliminates need for agents to check 10+ systems; all context in one dashboard
- **Faster Response Times**: AI-powered action planning reduces decision time from hours to minutes
- **Quality Consistency**: Communication drafting ensures brand voice and reduces errors
- **Knowledge Sharing**: Village knowledge surfaces best practices across all agents
- **Scalability**: Single agent can manage 3x more clients with copilot assistance

---

## Objectives & Requirements

### Functional Requirements

**FR-1: Unified Agent Dashboard**
1. Single pane of glass showing all client context for assigned clients
2. Real-time updates via WebSocket for dashboard widgets
3. Role-based view customization (Sales, Onboarding, Support, Success)
4. Client search and filtering (by health score, lifecycle stage, industry)
5. Quick actions (send email, create task, escalate issue, update CRM)
6. Context timeline showing all client interactions chronologically
7. AI-generated daily summary ("What happened while you were away")
8. Task list with AI-prioritized next-best-actions
9. Notification center with intelligent alerts (SLA breaches, escalations, approvals)
10. Performance metrics vs. objectives (response time, resolution rate, CSAT)

**FR-2: AI-Powered Action Planning**
1. Generate daily action plan with prioritized tasks for each agent
2. Next-best-action recommendation for each client (with rationale)
3. Predictive outcome modeling (success probability, expected impact, effort estimate)
4. Action sequence optimization (order tasks for maximum efficiency)
5. Historical pattern analysis (learn from past actions → outcomes)
6. Dynamic reprioritization based on real-time events (escalations, SLA breaches)
7. Batch action suggestions (similar actions across multiple clients)
8. "Why this action?" explainability (show data driving recommendation)
9. Manual override with feedback loop (agent can reject + provide reason)
10. Continuous learning from action execution results

**FR-3: Communication Drafting**
1. Email drafting (outreach, follow-up, escalation, update)
2. Meeting agenda generation (discovery call, QBR, training session)
3. QBR deck generation (health score, KPIs, recommendations, roadmap)
4. Internal note drafting (handoff notes, case summaries)
5. Slack/Teams message drafting for client communication
6. Brand voice consistency (tone, terminology, formatting)
7. Context-aware drafting (references recent interactions, client history)
8. Multi-language support (draft in client's preferred language)
9. Template library with AI-powered customization
10. Edit + regenerate workflow (agent provides feedback → redraft)

**FR-4: Approval Orchestration**
1. Intelligent approval routing based on type + risk level + amount
2. Approval request creation (discount, refund, exception, escalation)
3. Approval workflow tracking (pending, approved, rejected, expired)
4. Approval SLA monitoring (escalate if pending >24hrs)
5. Approval dashboard for managers (all pending requests)
6. Delegation support (approve on behalf of, temporary delegation)
7. Audit trail for all approval decisions
8. Approval reason capture (manager must provide justification)
9. Approval templates (pre-approved scenarios for auto-approval)
10. Notification integration (Slack, email, SMS for urgent approvals)

**FR-5: CRM Auto-Update**
1. Bi-directional sync with Salesforce, HubSpot, Zendesk
2. Field mapping configuration (Agent Copilot fields ↔ CRM fields)
3. Automatic opportunity stage updates (demo completed → proposal sent)
4. Contact enrichment (email, phone, LinkedIn from CRM → copilot)
5. Activity logging (calls, emails, meetings logged to CRM)
6. Deal value tracking (pricing accepted → update opportunity amount)
7. Next steps sync (CRM task ↔ copilot action plan)
8. Custom field support (industry-specific CRM fields)
9. Conflict resolution (CRM updated externally → reconcile changes)
10. Sync status monitoring (track sync failures, retry logic)

**FR-6: Village Knowledge Integration**
1. Similar client lookup (find clients in same industry, use case, size)
2. Best practice recommendations (successful strategies from similar clients)
3. Problem-solving suggestions (how other agents handled similar issues)
4. Template sharing (successful email templates, QBR decks, playbooks)
5. Success pattern identification (common traits of high-health clients)
6. Failure pattern avoidance (identify warning signs from churned clients)
7. Knowledge contribution (agents can share lessons learned)
8. Knowledge voting (upvote/downvote village knowledge suggestions)
9. Knowledge freshness (prioritize recent learnings over old data)
10. Privacy-preserving (anonymize client-specific details in village knowledge)

**FR-7: Performance Dashboard**
1. Agent performance metrics (response time, resolution rate, CSAT, NPS)
2. Goal tracking (quota attainment, tasks completed, deals closed)
3. Peer benchmarking (compare performance to team average, top 10%)
4. Coaching suggestions (AI identifies improvement areas)
5. Trend analysis (performance over time, seasonality)
6. Client health impact (correlation between agent actions → health score)
7. Time allocation breakdown (how much time on sales vs. onboarding vs. support)
8. Automation opportunity identification (repetitive tasks to automate)
9. Skill gap analysis (compare agent capabilities to job requirements)
10. Gamification (badges, leaderboards, streaks for engagement)

### Non-Functional Requirements

**NFR-1: Performance**
- Dashboard load time: <2 seconds (with 50+ clients)
- WebSocket latency: <100ms for real-time updates
- Action plan generation: <5 seconds (using @workflow/llm-sdk with semantic caching)
- Communication draft generation: <3 seconds
- CRM sync latency: <30 seconds from event → CRM update
- Support 100+ concurrent agents with sub-second response times

**NFR-2: Scalability**
- Support 1000+ agents across all roles
- Handle 100,000+ events/day from Kafka topics
- Store 10M+ historical actions for learning
- Scale village knowledge to 100,000+ insights
- Horizontal scaling for dashboard API (Kubernetes)

**NFR-3: Availability**
- 99.9% uptime SLA
- Graceful degradation (dashboard works if AI service unavailable)
- CRM sync retry logic (exponential backoff, max 5 retries)
- Event replay capability (reprocess Kafka events if service down)
- Health check endpoint for Kubernetes liveness/readiness

**NFR-4: Security**
- Multi-tenant isolation (Row-Level Security in PostgreSQL)
- Role-based access control (agents can only see assigned clients)
- Audit logging for all CRM updates and approval decisions
- PII encryption at rest (agent notes, client communications)
- OAuth2 for CRM integrations (secure token storage)

**NFR-5: Observability**
- OpenTelemetry distributed tracing
- Action plan generation latency metrics
- CRM sync success/failure rates
- Dashboard usage analytics (most-used features)
- AI recommendation acceptance rate (feedback loop)

---

## Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Service 21: Agent Copilot                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │  Dashboard API  │  │  Action Planner  │  │  Comm Drafter │ │
│  │  (FastAPI)      │  │  (LLM-powered)   │  │  (LLM-powered)│ │
│  └────────┬────────┘  └────────┬─────────┘  └───────┬───────┘ │
│           │                    │                     │         │
│  ┌────────┴────────────────────┴─────────────────────┴───────┐ │
│  │               Copilot Business Logic Layer                 │ │
│  │  - Context Aggregation    - Approval Orchestration         │ │
│  │  - Event Processing       - CRM Sync Manager               │ │
│  │  - Village Knowledge      - Performance Tracking           │ │
│  └────────┬────────────────────────────────────────────┬──────┘ │
│           │                                            │        │
│  ┌────────┴────────┐  ┌──────────────┐  ┌────────────┴──────┐ │
│  │  PostgreSQL     │  │    Redis     │  │     Qdrant        │ │
│  │  (agent data,   │  │  (caching,   │  │  (village         │ │
│  │   actions,      │  │   real-time  │  │   knowledge       │ │
│  │   approvals)    │  │   state)     │  │   embeddings)     │ │
│  └─────────────────┘  └──────────────┘  └───────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
         │                     │                    │
         ▼                     ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  Kafka Topics    │  │  @workflow/      │  │  External APIs   │
│  (17 topics)     │  │  llm-sdk         │  │  (Salesforce,    │
│  (consume)       │  │  (LLM inference) │  │   HubSpot,       │
│                  │  │                  │  │   Zendesk)       │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

### Component Responsibilities

**Dashboard API (FastAPI)**
- REST endpoints for agent dashboard UI
- WebSocket server for real-time updates
- Authentication/authorization middleware
- Request validation and error handling
- Response caching (Redis)

**Action Planner (LLM-powered)**
- Generate daily action plans using @workflow/llm-sdk
- Predictive outcome modeling (success probability, impact, effort)
- Action sequence optimization
- Continuous learning from historical action → outcome pairs
- Dynamic reprioritization based on real-time events

**Communication Drafter (LLM-powered)**
- Email, meeting agenda, QBR deck generation
- Brand voice consistency enforcement
- Context-aware drafting (client history, recent interactions)
- Multi-language support
- Template library management

**Context Aggregation**
- Consume 17 Kafka topics for real-time client context
- Aggregate events by organization_id and agent_id
- Maintain timeline of all client interactions
- Cache frequently-accessed context (Redis)
- Idempotent event processing

**Approval Orchestration**
- Route approval requests based on type + risk + amount
- Track approval workflow state machine
- SLA monitoring and escalation
- Delegation support
- Audit trail for compliance

**CRM Sync Manager**
- Bi-directional sync with Salesforce, HubSpot, Zendesk
- Field mapping configuration
- Conflict resolution
- Retry logic with exponential backoff
- Sync status monitoring

**Village Knowledge**
- Store anonymized learnings from all agents
- Vector embeddings for similarity search (Qdrant)
- Retrieve best practices for similar clients/situations
- Knowledge contribution and voting
- Freshness scoring

**Performance Tracking**
- Agent metrics calculation (response time, resolution rate, CSAT)
- Goal tracking (quota, tasks completed)
- Peer benchmarking
- Trend analysis
- Coaching suggestions

### Data Flow

**Real-Time Context Updates**
1. Kafka event arrives (e.g., `conversation_events` → `conversation_completed`)
2. Event handler processes event, extracts organization_id and agent_id
3. Update PostgreSQL (add to context timeline)
4. Update Redis cache (invalidate cached context)
5. WebSocket broadcast to connected agents (if dashboard open)
6. Trigger action plan reprioritization (if SLA breach or escalation)

**Action Plan Generation**
1. Agent logs in → Dashboard API calls Action Planner
2. Action Planner retrieves:
   - Agent's assigned clients (PostgreSQL)
   - Recent client events (PostgreSQL context timeline)
   - Client health scores (from cache or Service 13 API)
   - Historical action → outcome pairs (PostgreSQL)
   - Village knowledge for similar clients (Qdrant)
3. Action Planner calls @workflow/llm-sdk with prompt:
   ```
   Agent: [name], Role: [Sales/Onboarding/Support/Success]
   Assigned Clients: [client list with health scores, lifecycle stage]
   Recent Events: [timeline of last 48 hours]
   Historical Success Patterns: [actions that led to good outcomes]
   Village Knowledge: [best practices from similar clients]

   Generate prioritized action plan with:
   - Next-best-action for each client (with rationale)
   - Predicted outcome (success probability, impact, effort)
   - Optimal action sequence (which to do first)
   ```
4. LLM returns structured JSON (action plan)
5. Action Planner stores to PostgreSQL (agent_action_plans table)
6. Return to Dashboard API → render in UI

**Communication Drafting**
1. Agent clicks "Draft Email" for client
2. Dashboard API calls Communication Drafter with:
   - Communication type (outreach, follow-up, escalation, QBR)
   - Client context (recent interactions, health score, industry)
   - Agent role (Sales, Success, etc.)
   - Template selection (if applicable)
3. Communication Drafter retrieves:
   - Client context timeline (PostgreSQL)
   - Brand voice guidelines (from template library)
   - Similar successful communications (village knowledge)
4. Communication Drafter calls @workflow/llm-sdk:
   ```
   Communication Type: Follow-up email after demo
   Client: [name], Industry: [industry], Health Score: [score]
   Recent Interactions: [demo completed, positive feedback, pricing concern]
   Brand Voice: Professional, friendly, concise
   Goal: Address pricing concern, propose next steps

   Draft email with:
   - Personalized greeting
   - Reference demo conversation
   - Address pricing concern tactfully
   - Propose concrete next steps
   - Call-to-action
   ```
5. LLM returns draft (text)
6. Communication Drafter applies brand formatting
7. Return to Dashboard API → show draft to agent
8. Agent can edit, regenerate, or send

**CRM Sync**
1. Kafka event arrives (e.g., `demo_events` → `demo_completed`)
2. Event handler extracts organization_id, demo_id
3. CRM Sync Manager checks mapping: demo_completed → Salesforce Opportunity stage update
4. CRM Sync Manager retrieves CRM credentials (OAuth token from secure vault)
5. Call Salesforce API: PATCH /sobjects/Opportunity/{id} {"StageName": "Demo Completed"}
6. If success: Log activity to PostgreSQL (crm_sync_log)
7. If failure: Retry with exponential backoff (max 5 retries)
8. If all retries fail: Create alert for agent ("CRM sync failed for {client}")

---

## API Specification

### Authentication

All API endpoints require JWT authentication via Kong API Gateway.

**Headers**:
```
Authorization: Bearer <jwt_token>
X-Tenant-ID: org_123456
```

### Endpoints

#### 1. Get Agent Dashboard Data

**GET** `/api/v1/copilot/dashboard`

Retrieve unified dashboard data for the authenticated agent.

**Query Parameters**:
- `role` (optional): Filter by role (sales, onboarding, support, success)
- `date` (optional): Date for dashboard (default: today)

**Response** (200 OK):
```json
{
  "agent": {
    "id": "agent_001",
    "name": "Jane Smith",
    "role": "success_manager",
    "email": "jane.smith@company.com"
  },
  "assigned_clients": [
    {
      "organization_id": "org_123",
      "name": "Acme Corp",
      "health_score": 85,
      "lifecycle_stage": "active",
      "industry": "fintech",
      "assigned_at": "2025-09-01T00:00:00Z",
      "last_interaction": "2025-10-07T14:30:00Z"
    }
  ],
  "action_plan": {
    "generated_at": "2025-10-08T08:00:00Z",
    "total_actions": 12,
    "high_priority": 3,
    "actions": [
      {
        "id": "action_001",
        "client": "Acme Corp",
        "type": "follow_up_email",
        "priority": "high",
        "rationale": "Health score dropped 10 points; last interaction 7 days ago",
        "predicted_outcome": {
          "success_probability": 0.75,
          "expected_impact": "Prevent churn, restore health to 90+",
          "effort_minutes": 15
        },
        "next_best_action": true
      }
    ]
  },
  "notifications": [
    {
      "id": "notif_001",
      "type": "sla_breach",
      "severity": "high",
      "message": "Support ticket #456 approaching SLA breach (2 hours remaining)",
      "client": "Acme Corp",
      "created_at": "2025-10-08T10:00:00Z",
      "action_required": true
    }
  ],
  "performance_metrics": {
    "response_time_hours": 2.5,
    "resolution_rate_pct": 92,
    "csat_score": 4.6,
    "tasks_completed_today": 8,
    "tasks_remaining": 4
  },
  "recent_activity": [
    {
      "timestamp": "2025-10-07T14:30:00Z",
      "client": "Acme Corp",
      "event_type": "conversation_completed",
      "summary": "Customer support chat resolved (billing question)"
    }
  ]
}
```

---

#### 2. Generate Action Plan

**POST** `/api/v1/copilot/action-plan/generate`

Generate or regenerate daily action plan for the authenticated agent.

**Request Body**:
```json
{
  "force_regenerate": false,
  "filters": {
    "clients": ["org_123", "org_456"],
    "priority_only": true
  }
}
```

**Response** (200 OK):
```json
{
  "action_plan_id": "plan_001",
  "generated_at": "2025-10-08T08:00:00Z",
  "agent_id": "agent_001",
  "actions": [
    {
      "id": "action_001",
      "client": "Acme Corp",
      "organization_id": "org_123",
      "type": "follow_up_email",
      "priority": "high",
      "rationale": "Health score dropped 10 points; last interaction 7 days ago",
      "predicted_outcome": {
        "success_probability": 0.75,
        "expected_impact": "Prevent churn, restore health to 90+",
        "effort_minutes": 15
      },
      "suggested_sequence": 1,
      "due_at": "2025-10-08T12:00:00Z",
      "village_knowledge": {
        "similar_situations": 23,
        "success_rate": 0.82,
        "best_practice": "Personalize email with specific product usage data"
      }
    }
  ],
  "total_actions": 12,
  "estimated_time_hours": 4.5
}
```

---

#### 3. Mark Action as Complete

**PUT** `/api/v1/copilot/actions/{action_id}/complete`

Mark an action as completed and provide outcome feedback for learning loop.

**Request Body**:
```json
{
  "outcome": "success",
  "actual_impact": "Client responded positively, health score increased to 88",
  "actual_effort_minutes": 20,
  "notes": "Client appreciated the proactive outreach",
  "follow_up_actions": ["schedule_qbr"]
}
```

**Response** (200 OK):
```json
{
  "action_id": "action_001",
  "status": "completed",
  "completed_at": "2025-10-08T10:30:00Z",
  "outcome": "success",
  "prediction_accuracy": {
    "success_probability_actual": 1.0,
    "effort_variance_minutes": 5,
    "impact_match": "high"
  },
  "learning_feedback": "Prediction was accurate; pattern reinforced for future recommendations"
}
```

---

#### 4. Draft Communication

**POST** `/api/v1/copilot/communications/draft`

Generate AI-powered communication draft (email, meeting agenda, QBR deck).

**Request Body**:
```json
{
  "organization_id": "org_123",
  "type": "email",
  "purpose": "follow_up",
  "context": {
    "recent_interaction": "demo_completed",
    "client_concern": "pricing",
    "desired_outcome": "schedule_proposal_call"
  },
  "template_id": "template_sales_demo_followup",
  "tone": "professional_friendly",
  "max_length_words": 200
}
```

**Response** (200 OK):
```json
{
  "draft_id": "draft_001",
  "type": "email",
  "generated_at": "2025-10-08T10:00:00Z",
  "content": {
    "subject": "Following up on your demo - Next steps for Acme Corp",
    "body": "Hi [Client Name],\n\nThank you for taking the time to explore our platform yesterday. I could tell you were excited about [specific feature], and I appreciate you raising the question about pricing.\n\nI'd love to walk you through our pricing options tailored to Acme Corp's specific needs. Are you available for a 20-minute call this Thursday or Friday?\n\nLooking forward to continuing our conversation,\n[Agent Name]"
  },
  "metadata": {
    "client_context_used": ["demo_completed", "positive_feedback", "pricing_concern"],
    "village_knowledge_used": true,
    "brand_voice_compliance": "high",
    "estimated_response_rate": 0.68
  },
  "suggestions": [
    "Consider adding specific ROI data from demo",
    "Mention successful case study from similar industry"
  ]
}
```

---

#### 5. Edit and Regenerate Draft

**PUT** `/api/v1/copilot/communications/{draft_id}/regenerate`

Regenerate communication draft based on agent feedback.

**Request Body**:
```json
{
  "feedback": "Too formal; make it more conversational. Add specific feature mentioned in demo.",
  "additional_context": {
    "demo_highlight": "real-time analytics dashboard"
  }
}
```

**Response** (200 OK):
```json
{
  "draft_id": "draft_001",
  "version": 2,
  "generated_at": "2025-10-08T10:05:00Z",
  "content": {
    "subject": "Quick follow-up: That analytics dashboard you loved",
    "body": "Hey [Client Name]!\n\nReally enjoyed showing you around the platform yesterday—especially seeing your reaction to the real-time analytics dashboard. I know pricing came up, so let's find a plan that works for Acme Corp.\n\nFree for a quick call Thursday or Friday? 20 minutes to make sure we nail the right package for you.\n\nCheers,\n[Agent Name]"
  },
  "changes_made": [
    "Tone adjusted to conversational",
    "Added specific reference to analytics dashboard",
    "Shortened length for punchier message"
  ]
}
```

---

#### 6. Send Communication

**POST** `/api/v1/copilot/communications/{draft_id}/send`

Send the communication via Service 20 (Communication Engine) and log to CRM.

**Request Body**:
```json
{
  "final_edits": "Quick follow-up: That analytics dashboard you loved",
  "send_via": "email",
  "cc": ["manager@company.com"],
  "schedule_send": "2025-10-08T14:00:00Z"
}
```

**Response** (200 OK):
```json
{
  "communication_id": "comm_001",
  "status": "sent",
  "sent_at": "2025-10-08T14:00:00Z",
  "recipient": "client@acmecorp.com",
  "crm_logged": true,
  "crm_activity_id": "salesforce_task_12345"
}
```

---

#### 7. Create Approval Request

**POST** `/api/v1/copilot/approvals/request`

Create approval request for discount, refund, exception, or escalation.

**Request Body**:
```json
{
  "organization_id": "org_123",
  "type": "discount",
  "amount": 5000,
  "percentage": 15,
  "reason": "Client threatened to churn; competitive offer received",
  "supporting_data": {
    "competitor": "Competitor Inc",
    "competitor_offer": "10% discount + 2 months free",
    "client_lifetime_value": 50000,
    "health_score": 65,
    "contract_renewal_date": "2025-12-01"
  },
  "urgency": "high",
  "requested_by": "agent_001"
}
```

**Response** (201 Created):
```json
{
  "approval_id": "approval_001",
  "status": "pending",
  "type": "discount",
  "amount": 5000,
  "routed_to": "manager_sales_003",
  "routing_reason": "Discount >10% requires sales manager approval",
  "sla_deadline": "2025-10-09T10:00:00Z",
  "created_at": "2025-10-08T10:00:00Z",
  "approval_url": "https://app.company.com/approvals/approval_001"
}
```

---

#### 8. Get Approval Status

**GET** `/api/v1/copilot/approvals/{approval_id}`

Retrieve approval request status and decision.

**Response** (200 OK):
```json
{
  "approval_id": "approval_001",
  "status": "approved",
  "type": "discount",
  "amount": 5000,
  "requested_by": "agent_001",
  "requested_at": "2025-10-08T10:00:00Z",
  "approved_by": "manager_sales_003",
  "approved_at": "2025-10-08T11:30:00Z",
  "decision_notes": "Approved given high LTV and churn risk. Apply discount for 6-month renewal only.",
  "conditions": [
    "Discount applies to 6-month contract only",
    "Client must sign by 2025-10-15"
  ]
}
```

---

#### 9. Get Village Knowledge Recommendations

**GET** `/api/v1/copilot/village-knowledge/recommendations`

Retrieve best practices and successful strategies from similar client situations.

**Query Parameters**:
- `organization_id` (required): Client to get recommendations for
- `situation_type` (optional): Type of situation (onboarding, support, churn_risk, expansion)
- `limit` (optional, default: 5): Number of recommendations

**Response** (200 OK):
```json
{
  "organization_id": "org_123",
  "client_profile": {
    "industry": "fintech",
    "size": "50-100 employees",
    "use_case": "customer_support_automation",
    "lifecycle_stage": "active",
    "health_score": 65
  },
  "recommendations": [
    {
      "id": "vk_001",
      "type": "best_practice",
      "title": "Weekly check-ins for fintech clients with health <70",
      "description": "Agents who scheduled weekly 15-min check-ins with fintech clients saw 40% faster health recovery",
      "similar_situations": 23,
      "success_rate": 0.82,
      "recency": "last_30_days",
      "contributed_by": "agent_045",
      "upvotes": 12,
      "tags": ["churn_prevention", "fintech", "proactive_outreach"]
    },
    {
      "id": "vk_002",
      "type": "successful_template",
      "title": "QBR deck template for fintech clients",
      "description": "QBR deck highlighting compliance features and security metrics",
      "usage_count": 18,
      "avg_satisfaction": 4.7,
      "template_url": "/templates/qbr_fintech_001"
    }
  ],
  "total_results": 7
}
```

---

#### 10. Contribute Village Knowledge

**POST** `/api/v1/copilot/village-knowledge/contribute`

Contribute a lesson learned or best practice to village knowledge.

**Request Body**:
```json
{
  "type": "best_practice",
  "title": "Proactive feature training reduces support tickets",
  "description": "For clients with >10 support tickets/month, scheduling a 30-min feature training session reduced tickets by 60% in the following month",
  "situation": "high_support_volume",
  "client_profile": {
    "industry": "e-commerce",
    "size": "100-500 employees",
    "lifecycle_stage": "active"
  },
  "outcome": "Support tickets reduced from 15/month to 6/month",
  "evidence": {
    "sample_size": 5,
    "time_period": "90_days"
  },
  "tags": ["support_reduction", "training", "e-commerce"]
}
```

**Response** (201 Created):
```json
{
  "village_knowledge_id": "vk_003",
  "status": "published",
  "created_at": "2025-10-08T11:00:00Z",
  "contributed_by": "agent_001",
  "visibility": "all_agents",
  "upvotes": 0
}
```

---

#### 11. Get Performance Dashboard

**GET** `/api/v1/copilot/performance`

Retrieve performance metrics and coaching suggestions for the authenticated agent.

**Query Parameters**:
- `period` (optional): Time period (today, week, month, quarter, year)
- `compare_to` (optional): Comparison (team_avg, top_10_pct, previous_period)

**Response** (200 OK):
```json
{
  "agent_id": "agent_001",
  "period": "month",
  "metrics": {
    "response_time_hours": 2.5,
    "resolution_rate_pct": 92,
    "csat_score": 4.6,
    "nps_score": 42,
    "tasks_completed": 245,
    "clients_managed": 18,
    "health_score_avg": 82,
    "churn_prevented": 2
  },
  "goals": {
    "response_time_hours": {
      "target": 3.0,
      "actual": 2.5,
      "attainment_pct": 120,
      "status": "exceeding"
    },
    "csat_score": {
      "target": 4.5,
      "actual": 4.6,
      "attainment_pct": 102,
      "status": "on_track"
    },
    "tasks_completed": {
      "target": 250,
      "actual": 245,
      "attainment_pct": 98,
      "status": "on_track"
    }
  },
  "benchmarks": {
    "team_avg": {
      "response_time_hours": 3.2,
      "csat_score": 4.4
    },
    "top_10_pct": {
      "response_time_hours": 2.0,
      "csat_score": 4.8
    }
  },
  "trends": [
    {
      "metric": "response_time_hours",
      "direction": "improving",
      "change_pct": -15,
      "message": "Response time improved 15% this month"
    }
  ],
  "coaching_suggestions": [
    {
      "area": "proactive_outreach",
      "observation": "Clients with weekly check-ins have 20% higher health scores",
      "suggestion": "Schedule weekly 15-min check-ins with 3 lowest-health clients",
      "expected_impact": "Increase avg health score from 82 to 88"
    }
  ],
  "time_allocation": {
    "sales": 30,
    "onboarding": 20,
    "support": 35,
    "success": 15
  }
}
```

---

#### 12. WebSocket: Real-Time Dashboard Updates

**WebSocket** `wss://api.company.com/v1/copilot/ws`

Subscribe to real-time dashboard updates for the authenticated agent.

**Connection**:
```javascript
const ws = new WebSocket('wss://api.company.com/v1/copilot/ws', {
  headers: {
    'Authorization': 'Bearer <jwt_token>',
    'X-Tenant-ID': 'org_123456'
  }
});
```

**Subscribe to Updates**:
```json
{
  "type": "subscribe",
  "channels": ["action_plan", "notifications", "client_events"]
}
```

**Receive Updates**:
```json
{
  "type": "notification",
  "channel": "notifications",
  "data": {
    "id": "notif_002",
    "severity": "high",
    "message": "Support ticket #789 SLA breached (5 hours overdue)",
    "client": "Beta Inc",
    "action_required": true,
    "created_at": "2025-10-08T12:00:00Z"
  }
}
```

```json
{
  "type": "client_event",
  "channel": "client_events",
  "data": {
    "organization_id": "org_123",
    "event_type": "health_score_dropped",
    "previous_score": 85,
    "new_score": 78,
    "reason": "Multiple support tickets unresolved",
    "timestamp": "2025-10-08T12:30:00Z"
  }
}
```

---

## Database Schema

### PostgreSQL Tables

#### 1. agent_copilot_context

Stores aggregated context for each agent's assigned clients.

```sql
CREATE TABLE agent_copilot_context (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES users(id) NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Client Info
  client_name VARCHAR(255),
  health_score INTEGER CHECK (health_score >= 0 AND health_score <= 100),
  lifecycle_stage VARCHAR(50), -- prospect, demo, onboarding, active, at_risk, churned
  industry VARCHAR(100),

  -- Context Timeline (JSONB array of events)
  context_timeline JSONB DEFAULT '[]'::jsonb,

  -- Last interaction tracking
  last_interaction_at TIMESTAMPTZ,
  last_interaction_type VARCHAR(100),
  last_interaction_summary TEXT,

  -- Metadata
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy (Row-Level Security)
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_copilot_context_agent ON agent_copilot_context(agent_id);
CREATE INDEX idx_copilot_context_org ON agent_copilot_context(organization_id);
CREATE INDEX idx_copilot_context_tenant ON agent_copilot_context(tenant_id);
CREATE INDEX idx_copilot_context_timeline ON agent_copilot_context USING gin(context_timeline);
```

**Example Row**:
```json
{
  "id": "context_001",
  "agent_id": "agent_001",
  "organization_id": "org_123",
  "tenant_id": "tenant_001",
  "client_name": "Acme Corp",
  "health_score": 85,
  "lifecycle_stage": "active",
  "industry": "fintech",
  "context_timeline": [
    {
      "timestamp": "2025-10-07T14:30:00Z",
      "event_type": "conversation_completed",
      "summary": "Customer support chat resolved (billing question)",
      "source_service": "Service 8",
      "kafka_topic": "conversation_events"
    },
    {
      "timestamp": "2025-10-05T10:00:00Z",
      "event_type": "health_score_dropped",
      "previous_score": 90,
      "new_score": 85,
      "reason": "Reduced product usage"
    }
  ],
  "last_interaction_at": "2025-10-07T14:30:00Z",
  "last_interaction_type": "support_chat",
  "assigned_at": "2025-09-01T00:00:00Z"
}
```

---

#### 2. agent_action_plans

Stores daily action plans generated for each agent.

```sql
CREATE TABLE agent_action_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES users(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Plan metadata
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  plan_date DATE NOT NULL,
  total_actions INTEGER DEFAULT 0,
  high_priority_count INTEGER DEFAULT 0,
  estimated_time_hours DECIMAL(5,2),

  -- Plan data (JSONB array of actions)
  actions JSONB DEFAULT '[]'::jsonb,

  -- Status tracking
  status VARCHAR(20) DEFAULT 'active', -- active, completed, superseded
  completion_pct INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_action_plans_agent ON agent_action_plans(agent_id);
CREATE INDEX idx_action_plans_date ON agent_action_plans(plan_date);
CREATE INDEX idx_action_plans_tenant ON agent_action_plans(tenant_id);
CREATE UNIQUE INDEX idx_action_plans_agent_date ON agent_action_plans(agent_id, plan_date);
```

**Example Row**:
```json
{
  "id": "plan_001",
  "agent_id": "agent_001",
  "tenant_id": "tenant_001",
  "generated_at": "2025-10-08T08:00:00Z",
  "plan_date": "2025-10-08",
  "total_actions": 12,
  "high_priority_count": 3,
  "estimated_time_hours": 4.5,
  "actions": [
    {
      "id": "action_001",
      "client": "Acme Corp",
      "organization_id": "org_123",
      "type": "follow_up_email",
      "priority": "high",
      "rationale": "Health score dropped 10 points; last interaction 7 days ago",
      "predicted_outcome": {
        "success_probability": 0.75,
        "expected_impact": "Prevent churn, restore health to 90+",
        "effort_minutes": 15
      },
      "suggested_sequence": 1,
      "due_at": "2025-10-08T12:00:00Z",
      "status": "pending",
      "village_knowledge_id": "vk_001"
    }
  ],
  "status": "active",
  "completion_pct": 33
}
```

---

#### 3. agent_actions

Stores individual actions from action plans with completion status and outcome feedback.

```sql
CREATE TABLE agent_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action_plan_id UUID REFERENCES agent_action_plans(id) NOT NULL,
  agent_id UUID REFERENCES users(id) NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Action details
  type VARCHAR(50) NOT NULL, -- follow_up_email, schedule_call, escalate, update_crm, etc.
  priority VARCHAR(20), -- high, medium, low
  rationale TEXT,

  -- Predictions (from AI action planner)
  predicted_success_probability DECIMAL(3,2),
  predicted_impact TEXT,
  predicted_effort_minutes INTEGER,

  -- Action sequence
  suggested_sequence INTEGER,
  due_at TIMESTAMPTZ,

  -- Completion tracking
  status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed, skipped, failed
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,

  -- Outcome feedback (for learning loop)
  outcome VARCHAR(20), -- success, partial_success, no_impact, failure
  actual_impact TEXT,
  actual_effort_minutes INTEGER,
  agent_notes TEXT,

  -- Village knowledge reference
  village_knowledge_id UUID,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_actions_plan ON agent_actions(action_plan_id);
CREATE INDEX idx_actions_agent ON agent_actions(agent_id);
CREATE INDEX idx_actions_org ON agent_actions(organization_id);
CREATE INDEX idx_actions_status ON agent_actions(status);
CREATE INDEX idx_actions_tenant ON agent_actions(tenant_id);
```

---

#### 4. communication_drafts

Stores AI-generated communication drafts (emails, agendas, decks).

```sql
CREATE TABLE communication_drafts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES users(id) NOT NULL,
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Draft metadata
  type VARCHAR(50) NOT NULL, -- email, meeting_agenda, qbr_deck, slack_message
  purpose VARCHAR(50), -- outreach, follow_up, escalation, qbr, training
  template_id UUID,

  -- Draft content
  version INTEGER DEFAULT 1,
  subject VARCHAR(500),
  body TEXT,
  attachments JSONB DEFAULT '[]'::jsonb,

  -- Generation metadata
  context_used JSONB, -- What client context was used for generation
  village_knowledge_used BOOLEAN DEFAULT false,
  brand_voice_compliance VARCHAR(20), -- high, medium, low
  estimated_response_rate DECIMAL(3,2),

  -- Agent feedback (for regeneration)
  agent_feedback TEXT,

  -- Status tracking
  status VARCHAR(20) DEFAULT 'draft', -- draft, edited, sent, archived
  sent_at TIMESTAMPTZ,
  communication_id UUID, -- Reference to sent communication in Service 20

  -- Metadata
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_comm_drafts_agent ON communication_drafts(agent_id);
CREATE INDEX idx_comm_drafts_org ON communication_drafts(organization_id);
CREATE INDEX idx_comm_drafts_status ON communication_drafts(status);
CREATE INDEX idx_comm_drafts_tenant ON communication_drafts(tenant_id);
```

---

#### 5. approval_requests

Stores approval requests (discounts, refunds, exceptions, escalations).

```sql
CREATE TABLE approval_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Requestor info
  requested_by UUID REFERENCES users(id) NOT NULL,
  requested_by_role VARCHAR(50), -- sales_agent, support_specialist, success_manager

  -- Approval details
  type VARCHAR(50) NOT NULL, -- discount, refund, exception, escalation
  amount DECIMAL(10,2),
  percentage INTEGER,
  reason TEXT NOT NULL,
  supporting_data JSONB,
  urgency VARCHAR(20) DEFAULT 'normal', -- low, normal, high, critical

  -- Routing
  routed_to UUID REFERENCES users(id), -- Manager who needs to approve
  routing_reason TEXT,
  delegation_chain JSONB DEFAULT '[]'::jsonb, -- Track delegations

  -- SLA tracking
  sla_deadline TIMESTAMPTZ,
  sla_breached BOOLEAN DEFAULT false,

  -- Decision tracking
  status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected, expired
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  decision_notes TEXT,
  conditions JSONB DEFAULT '[]'::jsonb, -- Approval conditions

  -- Audit trail
  audit_log JSONB DEFAULT '[]'::jsonb,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_approvals_requestor ON approval_requests(requested_by);
CREATE INDEX idx_approvals_approver ON approval_requests(routed_to);
CREATE INDEX idx_approvals_org ON approval_requests(organization_id);
CREATE INDEX idx_approvals_status ON approval_requests(status);
CREATE INDEX idx_approvals_tenant ON approval_requests(tenant_id);
```

---

#### 6. crm_sync_log

Tracks CRM synchronization status and failures.

```sql
CREATE TABLE crm_sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Sync details
  crm_provider VARCHAR(50) NOT NULL, -- salesforce, hubspot, zendesk
  sync_direction VARCHAR(20) NOT NULL, -- copilot_to_crm, crm_to_copilot
  entity_type VARCHAR(50), -- opportunity, contact, task, activity
  entity_id VARCHAR(255), -- CRM entity ID

  -- Sync trigger
  trigger_event VARCHAR(100), -- demo_completed, proposal_sent, ticket_resolved
  kafka_topic VARCHAR(100),
  kafka_event_id VARCHAR(255),

  -- Sync result
  status VARCHAR(20) NOT NULL, -- success, failed, retrying
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 5,

  -- Error tracking
  error_code VARCHAR(50),
  error_message TEXT,

  -- Sync payload
  request_payload JSONB,
  response_payload JSONB,

  -- Metadata
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  next_retry_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_crm_sync_org ON crm_sync_log(organization_id);
CREATE INDEX idx_crm_sync_status ON crm_sync_log(status);
CREATE INDEX idx_crm_sync_provider ON crm_sync_log(crm_provider);
CREATE INDEX idx_crm_sync_tenant ON crm_sync_log(tenant_id);
```

---

#### 7. village_knowledge

Stores anonymized best practices and learnings from all agents.

```sql
CREATE TABLE village_knowledge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Knowledge details
  type VARCHAR(50) NOT NULL, -- best_practice, successful_template, problem_solution, failure_pattern
  title VARCHAR(255) NOT NULL,
  description TEXT,

  -- Situational context
  situation_type VARCHAR(50), -- onboarding, support, churn_risk, expansion
  client_profile JSONB, -- Industry, size, use case (anonymized)

  -- Evidence
  similar_situations_count INTEGER DEFAULT 1,
  success_rate DECIMAL(3,2),
  sample_size INTEGER,
  time_period VARCHAR(50),

  -- Contribution metadata
  contributed_by UUID REFERENCES users(id),
  contributed_at TIMESTAMPTZ DEFAULT NOW(),

  -- Engagement tracking
  usage_count INTEGER DEFAULT 0,
  upvotes INTEGER DEFAULT 0,
  downvotes INTEGER DEFAULT 0,
  avg_satisfaction DECIMAL(3,2),

  -- Visibility
  visibility VARCHAR(20) DEFAULT 'all_agents', -- all_agents, role_specific, team_only
  status VARCHAR(20) DEFAULT 'published', -- draft, published, archived

  -- Tags for search
  tags TEXT[],

  -- Template reference (if type = successful_template)
  template_url VARCHAR(500),

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_village_knowledge_type ON village_knowledge(type);
CREATE INDEX idx_village_knowledge_situation ON village_knowledge(situation_type);
CREATE INDEX idx_village_knowledge_tags ON village_knowledge USING gin(tags);
CREATE INDEX idx_village_knowledge_tenant ON village_knowledge(tenant_id);
```

---

#### 8. agent_performance_metrics

Stores agent performance metrics for dashboard and coaching.

```sql
CREATE TABLE agent_performance_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES users(id) NOT NULL,
  tenant_id UUID REFERENCES tenants(id) NOT NULL,

  -- Time period
  period_type VARCHAR(20) NOT NULL, -- day, week, month, quarter, year
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,

  -- Performance metrics
  response_time_hours DECIMAL(5,2),
  resolution_rate_pct INTEGER,
  csat_score DECIMAL(3,2),
  nps_score INTEGER,
  tasks_completed INTEGER,
  clients_managed INTEGER,
  health_score_avg INTEGER,
  churn_prevented INTEGER,

  -- Time allocation (percentage)
  time_allocation_sales_pct INTEGER,
  time_allocation_onboarding_pct INTEGER,
  time_allocation_support_pct INTEGER,
  time_allocation_success_pct INTEGER,

  -- Goals (JSONB with target, actual, attainment_pct)
  goals JSONB,

  -- Benchmarks (JSONB with team_avg, top_10_pct)
  benchmarks JSONB,

  -- Metadata
  calculated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  -- Multi-tenancy
  CONSTRAINT rls_tenant_isolation CHECK (tenant_id = current_setting('app.current_tenant')::uuid)
);

CREATE INDEX idx_perf_metrics_agent ON agent_performance_metrics(agent_id);
CREATE INDEX idx_perf_metrics_period ON agent_performance_metrics(period_start, period_end);
CREATE INDEX idx_perf_metrics_tenant ON agent_performance_metrics(tenant_id);
CREATE UNIQUE INDEX idx_perf_metrics_agent_period ON agent_performance_metrics(agent_id, period_type, period_start);
```

---

### Redis Data Structures

**1. Agent Context Cache**
```
Key: copilot:context:{agent_id}:{organization_id}
Type: Hash
TTL: 1 hour
Fields:
  - client_name: "Acme Corp"
  - health_score: "85"
  - last_interaction: "2025-10-07T14:30:00Z"
  - context_timeline: JSON string
```

**2. Real-Time Agent Dashboard State**
```
Key: copilot:dashboard:{agent_id}
Type: Hash
TTL: 30 minutes
Fields:
  - action_plan_id: "plan_001"
  - notification_count: "3"
  - tasks_remaining: "4"
  - last_updated: "2025-10-08T10:00:00Z"
```

**3. WebSocket Connection Tracking**
```
Key: copilot:ws:{agent_id}
Type: Set
TTL: 1 hour
Members: [connection_id_1, connection_id_2]
```

**4. Action Plan Cache**
```
Key: copilot:action_plan:{agent_id}:{date}
Type: String (JSON)
TTL: 24 hours
Value: Full action plan JSON
```

**5. CRM Sync Retry Queue**
```
Key: copilot:crm_sync:retry_queue
Type: Sorted Set
Score: next_retry_timestamp
Members: sync_log_id
```

---

### Qdrant Collections

**1. village_knowledge_embeddings**

Vector embeddings for village knowledge semantic search.

```python
collection_config = {
    "name": "village_knowledge_embeddings",
    "vectors": {
        "size": 1536,  # OpenAI text-embedding-3-small
        "distance": "Cosine"
    },
    "payload_schema": {
        "village_knowledge_id": "uuid",
        "tenant_id": "uuid",
        "type": "keyword",
        "situation_type": "keyword",
        "title": "text",
        "description": "text",
        "client_profile": "object",
        "tags": "keyword[]",
        "success_rate": "float",
        "usage_count": "integer",
        "created_at": "datetime"
    }
}
```

**Semantic Search Example**:
```python
from qdrant_client import QdrantClient

client = QdrantClient(url="http://qdrant:6333")

# Agent searches for village knowledge for a churn-risk fintech client
query = "Best practices for preventing churn in fintech clients with high support volume"
query_vector = openai.embeddings.create(input=query, model="text-embedding-3-small")

results = client.search(
    collection_name="village_knowledge_embeddings",
    query_vector=query_vector.data[0].embedding,
    query_filter={
        "must": [
            {"key": "tenant_id", "match": {"value": "tenant_001"}},
            {"key": "situation_type", "match": {"value": "churn_risk"}}
        ]
    },
    limit=5
)
```

---

## Event-Driven Integration

Service 21 consumes events from **17 Kafka topics** across all services to build real-time agent context.

### Kafka Topics Consumed

| Topic | Producer | Events | Usage in Service 21 |
|-------|----------|--------|---------------------|
| `auth_events` | Service 0 | user_logged_in, role_assigned | Track agent login, role changes |
| `agent_events` | Service 0 | agent_assigned, agent_handoff | Update agent assignments, handoff tracking |
| `research_events` | Service 1 | research_completed | Add to context: market research insights |
| `client_events` | Service 0 | client_created, client_updated | Update client profile in context |
| `demo_events` | Service 2 | demo_created, demo_completed | Add to context: demo scheduled, demo feedback |
| `sales_doc_events` | Service 3 | nda_signed, pricing_sent, proposal_accepted | Add to context: sales milestone tracking |
| `billing_events` | Service 22 | payment_succeeded, payment_failed, subscription_updated | Add to context: billing status, dunning alerts |
| `prd_events` | Service 6 | prd_created, prd_approved | Add to context: onboarding progress |
| `config_events` | Service 7 | config_deployed, config_failed | Add to context: implementation status |
| `conversation_events` | Services 8, 9 | conversation_completed, escalation_requested | Add to context: customer interactions, escalations |
| `voice_events` | Service 9 | call_completed, voicemail_left | Add to context: voice interaction summaries |
| `monitoring_incidents` | Service 11 | incident_created, incident_resolved | Add to context: production issues affecting client |
| `analytics_experiments` | Service 12 | experiment_started, experiment_completed | Add to context: A/B test results |
| `customer_success_events` | Service 13 | health_score_changed, playbook_triggered, qbr_completed | Add to context: health changes, CS actions |
| `support_events` | Service 14 | ticket_created, ticket_resolved | Add to context: support tickets, resolution time |
| `communication_events` | Service 20 | email_sent, email_opened, sms_delivered | Add to context: communication tracking |
| `cross_product_events` | Services 8, 9 | product_switched | Add to context: client switched chatbot ↔ voicebot |

### Event Handlers

#### 1. Handle Health Score Change

**Topic**: `customer_success_events`
**Event**: `health_score_changed`

```python
@kafka_handler("customer_success_events")
async def handle_health_score_changed(event: dict):
    """
    When health score changes, update context and trigger action plan reprioritization.
    """
    organization_id = event["organization_id"]
    previous_score = event["previous_score"]
    new_score = event["new_score"]
    reason = event["reason"]

    # Update context in PostgreSQL
    await db.execute(
        """
        UPDATE agent_copilot_context
        SET
            health_score = $1,
            context_timeline = context_timeline || $2::jsonb,
            updated_at = NOW()
        WHERE organization_id = $3
        """,
        new_score,
        json.dumps({
            "timestamp": event["timestamp"],
            "event_type": "health_score_changed",
            "previous_score": previous_score,
            "new_score": new_score,
            "reason": reason,
            "source_service": "Service 13",
            "kafka_topic": "customer_success_events"
        }),
        organization_id
    )

    # Invalidate cache
    await redis.delete(f"copilot:context:*:{organization_id}")

    # If health dropped significantly (>10 points), trigger high-priority action
    if new_score < previous_score - 10:
        assigned_agent = await get_assigned_agent(organization_id, role="success_manager")

        if assigned_agent:
            # Create high-priority action
            await create_high_priority_action(
                agent_id=assigned_agent["id"],
                organization_id=organization_id,
                type="urgent_follow_up",
                rationale=f"Health score dropped from {previous_score} to {new_score}. Reason: {reason}",
                priority="high"
            )

            # Send real-time notification via WebSocket
            await websocket_broadcast(
                agent_id=assigned_agent["id"],
                message={
                    "type": "notification",
                    "severity": "high",
                    "message": f"Health score dropped for {event['client_name']} ({previous_score} → {new_score})",
                    "action_required": True
                }
            )
```

---

#### 2. Handle Support Ticket Created

**Topic**: `support_events`
**Event**: `ticket_created`

```python
@kafka_handler("support_events")
async def handle_ticket_created(event: dict):
    """
    When support ticket created, add to context and monitor SLA.
    """
    organization_id = event["organization_id"]
    ticket_id = event["ticket_id"]
    priority = event["priority"]
    sla_deadline = event["sla_deadline"]

    # Update context
    await db.execute(
        """
        UPDATE agent_copilot_context
        SET
            context_timeline = context_timeline || $1::jsonb,
            updated_at = NOW()
        WHERE organization_id = $2
        """,
        json.dumps({
            "timestamp": event["timestamp"],
            "event_type": "ticket_created",
            "ticket_id": ticket_id,
            "priority": priority,
            "subject": event["subject"],
            "sla_deadline": sla_deadline,
            "source_service": "Service 14"
        }),
        organization_id
    )

    # If high-priority ticket, notify support agent immediately
    if priority == "high":
        assigned_agent = await get_assigned_agent(organization_id, role="support_specialist")

        if assigned_agent:
            await websocket_broadcast(
                agent_id=assigned_agent["id"],
                message={
                    "type": "notification",
                    "severity": "high",
                    "message": f"High-priority support ticket #{ticket_id} created",
                    "action_required": True,
                    "sla_deadline": sla_deadline
                }
            )

    # Schedule SLA monitoring (check 1 hour before deadline)
    sla_check_time = datetime.fromisoformat(sla_deadline) - timedelta(hours=1)
    await schedule_task("check_ticket_sla", args=[ticket_id], run_at=sla_check_time)
```

---

#### 3. Handle Demo Completed

**Topic**: `demo_events`
**Event**: `demo_completed`

```python
@kafka_handler("demo_events")
async def handle_demo_completed(event: dict):
    """
    When demo completed, add to context and trigger follow-up action.
    """
    organization_id = event["organization_id"]
    demo_id = event["demo_id"]
    feedback_score = event.get("feedback_score")

    # Update context
    await db.execute(
        """
        UPDATE agent_copilot_context
        SET
            context_timeline = context_timeline || $1::jsonb,
            last_interaction_at = $2,
            last_interaction_type = 'demo',
            updated_at = NOW()
        WHERE organization_id = $3
        """,
        json.dumps({
            "timestamp": event["timestamp"],
            "event_type": "demo_completed",
            "demo_id": demo_id,
            "demo_type": event["demo_type"],
            "feedback_score": feedback_score,
            "key_features_shown": event.get("key_features", []),
            "source_service": "Service 2"
        }),
        event["timestamp"],
        organization_id
    )

    # Get assigned sales agent
    assigned_agent = await get_assigned_agent(organization_id, role="sales_agent")

    if assigned_agent:
        # Create follow-up action (prioritize based on feedback)
        priority = "high" if feedback_score and feedback_score >= 8 else "medium"

        await create_action(
            agent_id=assigned_agent["id"],
            organization_id=organization_id,
            type="demo_follow_up",
            priority=priority,
            rationale=f"Demo completed with feedback score {feedback_score}/10. Send follow-up within 24 hours.",
            suggested_sequence=1,
            due_at=datetime.now() + timedelta(hours=24)
        )

        # Sync to CRM (update Salesforce Opportunity stage)
        await sync_to_crm(
            organization_id=organization_id,
            crm_provider="salesforce",
            entity_type="opportunity",
            update_data={"StageName": "Demo Completed", "Demo_Feedback__c": feedback_score}
        )
```

---

#### 4. Handle Proposal Accepted

**Topic**: `sales_doc_events`
**Event**: `proposal_accepted`

```python
@kafka_handler("sales_doc_events")
async def handle_proposal_accepted(event: dict):
    """
    When proposal accepted, trigger agent handoff (Sales → Onboarding).
    """
    organization_id = event["organization_id"]
    proposal_id = event["proposal_id"]
    contract_value = event["contract_value"]

    # Update context
    await db.execute(
        """
        UPDATE agent_copilot_context
        SET
            context_timeline = context_timeline || $1::jsonb,
            lifecycle_stage = 'onboarding',
            updated_at = NOW()
        WHERE organization_id = $2
        """,
        json.dumps({
            "timestamp": event["timestamp"],
            "event_type": "proposal_accepted",
            "proposal_id": proposal_id,
            "contract_value": contract_value,
            "source_service": "Service 3"
        }),
        organization_id
    )

    # Get sales agent (handoff from)
    sales_agent = await get_assigned_agent(organization_id, role="sales_agent")

    # Get onboarding specialist (handoff to)
    onboarding_agent = await assign_agent(organization_id, role="onboarding_specialist")

    # Create handoff action for sales agent
    if sales_agent:
        await create_action(
            agent_id=sales_agent["id"],
            organization_id=organization_id,
            type="handoff_to_onboarding",
            priority="high",
            rationale=f"Proposal accepted (${contract_value}). Prepare handoff notes for onboarding.",
            due_at=datetime.now() + timedelta(hours=8)
        )

    # Create welcome action for onboarding agent
    if onboarding_agent:
        await create_action(
            agent_id=onboarding_agent["id"],
            organization_id=organization_id,
            type="onboarding_kickoff",
            priority="high",
            rationale=f"New client onboarding. Contract value: ${contract_value}. Schedule kickoff call.",
            due_at=datetime.now() + timedelta(days=2)
        )

        # Notify onboarding agent
        await websocket_broadcast(
            agent_id=onboarding_agent["id"],
            message={
                "type": "notification",
                "severity": "medium",
                "message": f"New client assigned: {event['client_name']} (${contract_value})",
                "action_required": True
            }
        )

    # Sync to CRM
    await sync_to_crm(
        organization_id=organization_id,
        crm_provider="salesforce",
        entity_type="opportunity",
        update_data={
            "StageName": "Closed Won",
            "Amount": contract_value,
            "CloseDate": datetime.now().date().isoformat()
        }
    )
```

---

### Event Processing Guarantees

**Idempotency**: All event handlers use `kafka_event_id` for deduplication.

```python
@kafka_handler("customer_success_events", idempotency_key="event_id")
async def handle_event(event: dict):
    # Check if already processed
    processed = await redis.get(f"copilot:processed_event:{event['event_id']}")
    if processed:
        logger.info(f"Event {event['event_id']} already processed, skipping")
        return

    # Process event
    await process_event(event)

    # Mark as processed (TTL 7 days)
    await redis.setex(f"copilot:processed_event:{event['event_id']}", 604800, "1")
```

**Ordering**: Use Kafka partitioning by `organization_id` to ensure ordered processing.

```python
# Kafka producer in other services
producer.send(
    topic="customer_success_events",
    value=event_data,
    key=organization_id.encode('utf-8')  # Partition by organization_id
)
```

**Failure Handling**: Dead letter queue for events that fail processing after 3 retries.

```python
@kafka_handler("customer_success_events", max_retries=3, dead_letter_topic="copilot_dlq")
async def handle_event(event: dict):
    try:
        await process_event(event)
    except Exception as e:
        logger.error(f"Failed to process event {event['event_id']}: {e}")
        raise  # Will retry up to 3 times, then send to DLQ
```

---

## AI-Powered Action Planning

### Action Plan Generation Algorithm

**Prompt Template**:

```python
SYSTEM_PROMPT = """
You are an AI action planner for customer success agents. Your goal is to generate a prioritized daily action plan that maximizes client health, revenue retention, and agent productivity.

**Context**:
- Agent: {agent_name}, Role: {agent_role}
- Date: {date}
- Assigned Clients: {num_clients}

**Your Task**:
Generate a prioritized action plan with:
1. Next-best-action for each client (with clear rationale)
2. Predicted outcome (success probability, expected impact, effort estimate)
3. Optimal action sequence (order tasks for maximum efficiency)
4. Village knowledge integration (best practices from similar situations)

**Prioritization Criteria**:
1. Client health score (lower = higher priority)
2. Time since last interaction (longer = higher priority)
3. SLA breach risk (approaching deadline = highest priority)
4. Contract value (higher = higher priority for at-risk clients)
5. Historical patterns (what worked before for similar clients)

**Output Format**:
Return a JSON array of actions, each with:
- client: Client name
- organization_id: UUID
- type: Action type (follow_up_email, schedule_call, escalate, etc.)
- priority: high/medium/low
- rationale: Why this action now (2-3 sentences)
- predicted_outcome:
  - success_probability: 0.0-1.0
  - expected_impact: What will happen if successful
  - effort_minutes: Estimated time to complete
- suggested_sequence: Optimal order (1, 2, 3, ...)
- due_at: Suggested deadline (ISO 8601)
- village_knowledge_id: Reference to relevant best practice (if applicable)
"""

USER_PROMPT_TEMPLATE = """
**Agent Profile**:
- Name: {agent_name}
- Role: {agent_role}
- Daily capacity: {daily_capacity_hours} hours

**Assigned Clients** ({num_clients} total):
{clients_json}

**Recent Events** (last 48 hours):
{recent_events_json}

**Historical Success Patterns** (from this agent):
{historical_patterns_json}

**Village Knowledge** (best practices from similar situations):
{village_knowledge_json}

**Current Incomplete Actions** (from previous days):
{incomplete_actions_json}

Generate the action plan now.
"""
```

---

### Action Planner Implementation

```python
from workflow_llm_sdk import LLMClient

async def generate_action_plan(agent_id: str, date: str) -> dict:
    """
    Generate daily action plan for agent using LLM.
    """
    # Retrieve agent profile
    agent = await db.fetchrow("SELECT * FROM users WHERE id = $1", agent_id)

    # Retrieve assigned clients with health scores
    clients = await db.fetch(
        """
        SELECT
            c.organization_id,
            c.client_name,
            c.health_score,
            c.lifecycle_stage,
            c.industry,
            c.last_interaction_at,
            c.context_timeline
        FROM agent_copilot_context c
        WHERE c.agent_id = $1
        ORDER BY c.health_score ASC, c.last_interaction_at ASC
        """,
        agent_id
    )

    # Retrieve recent events (last 48 hours)
    recent_events = []
    for client in clients:
        timeline = json.loads(client["context_timeline"])
        recent = [e for e in timeline if is_within_48_hours(e["timestamp"])]
        recent_events.extend(recent)

    # Retrieve historical patterns (successful actions from this agent)
    historical_patterns = await db.fetch(
        """
        SELECT
            type,
            organization_id,
            predicted_success_probability,
            outcome,
            actual_impact,
            COUNT(*) as count
        FROM agent_actions
        WHERE agent_id = $1 AND outcome = 'success'
        GROUP BY type, organization_id, predicted_success_probability, outcome, actual_impact
        ORDER BY count DESC
        LIMIT 10
        """,
        agent_id
    )

    # Retrieve village knowledge (best practices for similar clients)
    village_knowledge = await get_relevant_village_knowledge(clients)

    # Retrieve incomplete actions from previous days
    incomplete_actions = await db.fetch(
        """
        SELECT *
        FROM agent_actions
        WHERE agent_id = $1 AND status IN ('pending', 'in_progress')
        ORDER BY priority DESC, due_at ASC
        """,
        agent_id
    )

    # Build LLM prompt
    user_prompt = USER_PROMPT_TEMPLATE.format(
        agent_name=agent["name"],
        agent_role=agent["role"],
        daily_capacity_hours=8,
        num_clients=len(clients),
        clients_json=json.dumps([dict(c) for c in clients], indent=2),
        recent_events_json=json.dumps(recent_events, indent=2),
        historical_patterns_json=json.dumps([dict(p) for p in historical_patterns], indent=2),
        village_knowledge_json=json.dumps(village_knowledge, indent=2),
        incomplete_actions_json=json.dumps([dict(a) for a in incomplete_actions], indent=2)
    )

    # Call LLM via @workflow/llm-sdk
    llm_client = LLMClient(
        model="gpt-4o-mini",
        temperature=0.3,
        semantic_cache=True,
        cache_ttl=3600
    )

    response = await llm_client.chat_completion(
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ],
        response_format={"type": "json_object"}
    )

    # Parse LLM response
    actions = json.loads(response.choices[0].message.content)["actions"]

    # Store action plan in PostgreSQL
    action_plan = await db.fetchrow(
        """
        INSERT INTO agent_action_plans (
            agent_id, tenant_id, plan_date, total_actions,
            high_priority_count, estimated_time_hours, actions, status
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, 'active')
        RETURNING *
        """,
        agent_id,
        agent["tenant_id"],
        date,
        len(actions),
        sum(1 for a in actions if a["priority"] == "high"),
        sum(a["predicted_outcome"]["effort_minutes"] for a in actions) / 60,
        json.dumps(actions)
    )

    # Create individual action records
    for action in actions:
        await db.execute(
            """
            INSERT INTO agent_actions (
                action_plan_id, agent_id, organization_id, tenant_id,
                type, priority, rationale,
                predicted_success_probability, predicted_impact, predicted_effort_minutes,
                suggested_sequence, due_at, village_knowledge_id, status
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'pending')
            """,
            action_plan["id"],
            agent_id,
            action["organization_id"],
            agent["tenant_id"],
            action["type"],
            action["priority"],
            action["rationale"],
            action["predicted_outcome"]["success_probability"],
            action["predicted_outcome"]["expected_impact"],
            action["predicted_outcome"]["effort_minutes"],
            action["suggested_sequence"],
            action["due_at"],
            action.get("village_knowledge_id")
        )

    # Cache action plan
    await redis.setex(
        f"copilot:action_plan:{agent_id}:{date}",
        86400,  # 24 hours
        json.dumps(dict(action_plan))
    )

    return action_plan
```

---

### Continuous Learning Loop

**Track Action Outcomes** to improve future predictions:

```python
async def complete_action(action_id: str, outcome_data: dict):
    """
    Mark action as complete and record outcome for learning loop.
    """
    # Get action
    action = await db.fetchrow("SELECT * FROM agent_actions WHERE id = $1", action_id)

    # Update action with outcome
    await db.execute(
        """
        UPDATE agent_actions
        SET
            status = 'completed',
            completed_at = NOW(),
            outcome = $1,
            actual_impact = $2,
            actual_effort_minutes = $3,
            agent_notes = $4,
            updated_at = NOW()
        WHERE id = $5
        """,
        outcome_data["outcome"],
        outcome_data["actual_impact"],
        outcome_data["actual_effort_minutes"],
        outcome_data.get("notes"),
        action_id
    )

    # Calculate prediction accuracy
    predicted_prob = action["predicted_success_probability"]
    actual_success = 1.0 if outcome_data["outcome"] == "success" else 0.0

    predicted_effort = action["predicted_effort_minutes"]
    actual_effort = outcome_data["actual_effort_minutes"]
    effort_variance = abs(actual_effort - predicted_effort)

    # Store learning feedback
    learning_feedback = {
        "action_id": action_id,
        "action_type": action["type"],
        "organization_id": action["organization_id"],
        "predicted_success_probability": predicted_prob,
        "actual_success": actual_success,
        "prediction_error": abs(actual_success - predicted_prob),
        "predicted_effort_minutes": predicted_effort,
        "actual_effort_minutes": actual_effort,
        "effort_variance_minutes": effort_variance,
        "impact_match": "high" if "expected_impact" in outcome_data["actual_impact"].lower() else "low"
    }

    # TODO: Store in TimescaleDB for time-series analysis
    # TODO: Periodically retrain action plan generation model with this feedback

    logger.info(f"Action {action_id} completed. Prediction accuracy: {1 - learning_feedback['prediction_error']:.2%}")

    return learning_feedback
```

---

## Communication Drafting

### Email Drafting

**Prompt Template**:

```python
EMAIL_SYSTEM_PROMPT = """
You are an expert email writer for customer success teams. Your goal is to draft personalized, professional emails that drive engagement and positive outcomes.

**Brand Voice Guidelines**:
- Tone: Professional yet friendly
- Style: Concise, action-oriented, empathetic
- Avoid: Jargon, overly formal language, aggressive sales tactics
- Include: Specific references to client context, clear call-to-action

**Email Best Practices**:
1. Personalize with client-specific details (name, company, recent interactions)
2. Reference shared context (recent demo, support ticket, health score change)
3. Keep subject line under 60 characters, intriguing but clear
4. Body: 150-250 words (concise)
5. Single clear call-to-action
6. Warm, human sign-off

**Output Format**:
Return JSON with:
- subject: Email subject line
- body: Email body (with [Client Name], [Agent Name] placeholders)
- suggestions: Array of optional improvements
"""

EMAIL_USER_PROMPT_TEMPLATE = """
**Communication Details**:
- Type: {communication_type}
- Purpose: {purpose}
- Desired Outcome: {desired_outcome}

**Client Context**:
- Client: {client_name}
- Company: {company_name}
- Industry: {industry}
- Health Score: {health_score}/100
- Lifecycle Stage: {lifecycle_stage}

**Recent Interactions**:
{recent_interactions_json}

**Agent Profile**:
- Name: {agent_name}
- Role: {agent_role}

**Template** (optional):
{template_content}

**Agent Instructions**:
{agent_instructions}

Draft the email now.
"""
```

---

### Communication Drafter Implementation

```python
async def draft_communication(
    organization_id: str,
    agent_id: str,
    comm_type: str,
    purpose: str,
    context: dict,
    template_id: str = None,
    agent_instructions: str = None
) -> dict:
    """
    Generate AI-powered communication draft.
    """
    # Retrieve client context
    client_context = await db.fetchrow(
        """
        SELECT *
        FROM agent_copilot_context
        WHERE organization_id = $1
        """,
        organization_id
    )

    # Retrieve recent interactions (last 7 days)
    timeline = json.loads(client_context["context_timeline"])
    recent_interactions = [e for e in timeline if is_within_7_days(e["timestamp"])]

    # Retrieve agent profile
    agent = await db.fetchrow("SELECT * FROM users WHERE id = $1", agent_id)

    # Load template (if specified)
    template_content = ""
    if template_id:
        template = await db.fetchrow("SELECT * FROM communication_templates WHERE id = $1", template_id)
        template_content = template["content"]

    # Build prompt
    user_prompt = EMAIL_USER_PROMPT_TEMPLATE.format(
        communication_type=comm_type,
        purpose=purpose,
        desired_outcome=context.get("desired_outcome", ""),
        client_name=client_context["client_name"],
        company_name=client_context["client_name"],
        industry=client_context["industry"],
        health_score=client_context["health_score"],
        lifecycle_stage=client_context["lifecycle_stage"],
        recent_interactions_json=json.dumps(recent_interactions, indent=2),
        agent_name=agent["name"],
        agent_role=agent["role"],
        template_content=template_content,
        agent_instructions=agent_instructions or "None"
    )

    # Call LLM
    llm_client = LLMClient(model="gpt-4o-mini", temperature=0.7)

    response = await llm_client.chat_completion(
        messages=[
            {"role": "system", "content": EMAIL_SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ],
        response_format={"type": "json_object"}
    )

    # Parse response
    draft = json.loads(response.choices[0].message.content)

    # Store draft
    draft_record = await db.fetchrow(
        """
        INSERT INTO communication_drafts (
            agent_id, organization_id, tenant_id, type, purpose,
            template_id, version, subject, body,
            context_used, village_knowledge_used, brand_voice_compliance,
            status, generated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, 1, $7, $8, $9, $10, $11, 'draft', NOW())
        RETURNING *
        """,
        agent_id,
        organization_id,
        agent["tenant_id"],
        comm_type,
        purpose,
        template_id,
        draft["subject"],
        draft["body"],
        json.dumps(context),
        False,  # TODO: Detect if village knowledge was used
        "high"  # TODO: Implement brand voice compliance checker
    )

    return {
        "draft_id": draft_record["id"],
        "type": comm_type,
        "generated_at": draft_record["generated_at"].isoformat(),
        "content": {
            "subject": draft["subject"],
            "body": draft["body"]
        },
        "suggestions": draft.get("suggestions", [])
    }
```

---

## Approval Orchestration

### Approval Routing Rules

**Discount Approvals**:
```python
DISCOUNT_APPROVAL_RULES = [
    {"threshold_pct": 5, "approver_role": "sales_manager"},
    {"threshold_pct": 10, "approver_role": "vp_sales"},
    {"threshold_pct": 20, "approver_role": "cfo"},
]

async def route_discount_approval(amount: float, percentage: int, organization_id: str) -> str:
    """
    Route discount approval based on percentage thresholds.
    """
    # Determine required approver
    approver_role = "sales_manager"  # Default
    for rule in DISCOUNT_APPROVAL_RULES:
        if percentage >= rule["threshold_pct"]:
            approver_role = rule["approver_role"]

    # Find available approver
    approver = await db.fetchrow(
        """
        SELECT id FROM users
        WHERE role = $1 AND tenant_id = (
            SELECT tenant_id FROM organizations WHERE id = $2
        )
        ORDER BY random()
        LIMIT 1
        """,
        approver_role,
        organization_id
    )

    return approver["id"]
```

**Refund Approvals**:
```python
REFUND_APPROVAL_RULES = [
    {"threshold_amount": 1000, "approver_role": "support_manager"},
    {"threshold_amount": 5000, "approver_role": "customer_success_director"},
    {"threshold_amount": 10000, "approver_role": "cfo"},
]
```

---

### Approval SLA Monitoring

```python
async def monitor_approval_slas():
    """
    Background task to monitor approval SLAs and escalate overdue approvals.
    """
    while True:
        # Find approvals approaching deadline (1 hour before)
        approaching_deadline = await db.fetch(
            """
            SELECT * FROM approval_requests
            WHERE status = 'pending'
            AND sla_deadline < NOW() + INTERVAL '1 hour'
            AND sla_deadline > NOW()
            AND sla_breached = false
            """
        )

        for approval in approaching_deadline:
            # Send urgent notification to approver
            await websocket_broadcast(
                agent_id=approval["routed_to"],
                message={
                    "type": "notification",
                    "severity": "critical",
                    "message": f"Approval request #{approval['id'][:8]} expires in <1 hour",
                    "action_required": True
                }
            )

        # Find breached SLAs
        breached = await db.fetch(
            """
            SELECT * FROM approval_requests
            WHERE status = 'pending'
            AND sla_deadline < NOW()
            AND sla_breached = false
            """
        )

        for approval in breached:
            # Mark as breached
            await db.execute(
                "UPDATE approval_requests SET sla_breached = true WHERE id = $1",
                approval["id"]
            )

            # Escalate to next level (approver's manager)
            manager = await get_manager(approval["routed_to"])

            if manager:
                await db.execute(
                    """
                    UPDATE approval_requests
                    SET
                        routed_to = $1,
                        delegation_chain = delegation_chain || $2::jsonb
                    WHERE id = $3
                    """,
                    manager["id"],
                    json.dumps({
                        "escalated_from": approval["routed_to"],
                        "escalated_at": datetime.now().isoformat(),
                        "reason": "SLA breach"
                    }),
                    approval["id"]
                )

                # Notify manager
                await websocket_broadcast(
                    agent_id=manager["id"],
                    message={
                        "type": "notification",
                        "severity": "critical",
                        "message": f"Approval request #{approval['id'][:8]} escalated (SLA breached)",
                        "action_required": True
                    }
                )

        # Sleep for 5 minutes
        await asyncio.sleep(300)
```

---

## CRM Integration

### CRM Sync Manager

**Supported CRM Providers**:
- Salesforce (OAuth2)
- HubSpot (API Key)
- Zendesk (API Key)

**Field Mapping Configuration**:

```python
SALESFORCE_FIELD_MAPPING = {
    "demo_completed": {
        "entity_type": "Opportunity",
        "fields": {
            "StageName": "Demo Completed",
            "Demo_Date__c": "{{event.timestamp}}",
            "Demo_Feedback__c": "{{event.feedback_score}}"
        }
    },
    "proposal_accepted": {
        "entity_type": "Opportunity",
        "fields": {
            "StageName": "Closed Won",
            "Amount": "{{event.contract_value}}",
            "CloseDate": "{{event.timestamp}}"
        }
    },
    "health_score_changed": {
        "entity_type": "Account",
        "fields": {
            "Health_Score__c": "{{event.new_score}}",
            "Last_Health_Update__c": "{{event.timestamp}}"
        }
    }
}
```

---

### CRM Sync Implementation

```python
async def sync_to_crm(
    organization_id: str,
    crm_provider: str,
    entity_type: str,
    update_data: dict,
    event_context: dict = None
):
    """
    Sync data to CRM with retry logic.
    """
    # Get CRM credentials
    crm_config = await get_crm_config(organization_id, crm_provider)

    if not crm_config:
        logger.warning(f"No CRM config found for {organization_id} ({crm_provider})")
        return

    # Get CRM entity ID (from mapping table)
    entity_mapping = await db.fetchrow(
        """
        SELECT crm_entity_id FROM crm_entity_mappings
        WHERE organization_id = $1 AND crm_provider = $2 AND entity_type = $3
        """,
        organization_id,
        crm_provider,
        entity_type
    )

    if not entity_mapping:
        logger.error(f"No CRM entity mapping for {organization_id} ({entity_type})")
        return

    crm_entity_id = entity_mapping["crm_entity_id"]

    # Initialize CRM client
    if crm_provider == "salesforce":
        crm_client = SalesforceClient(
            access_token=crm_config["access_token"],
            instance_url=crm_config["instance_url"]
        )
    elif crm_provider == "hubspot":
        crm_client = HubSpotClient(api_key=crm_config["api_key"])
    elif crm_provider == "zendesk":
        crm_client = ZendeskClient(
            subdomain=crm_config["subdomain"],
            email=crm_config["email"],
            api_token=crm_config["api_token"]
        )
    else:
        raise ValueError(f"Unsupported CRM provider: {crm_provider}")

    # Attempt sync with retry logic
    max_retries = 5
    retry_count = 0

    while retry_count < max_retries:
        try:
            # Make CRM API call
            if crm_provider == "salesforce":
                response = await crm_client.update_sobject(entity_type, crm_entity_id, update_data)
            elif crm_provider == "hubspot":
                response = await crm_client.update_object(entity_type.lower(), crm_entity_id, update_data)
            elif crm_provider == "zendesk":
                response = await crm_client.update_ticket(crm_entity_id, update_data)

            # Log success
            await db.execute(
                """
                INSERT INTO crm_sync_log (
                    organization_id, tenant_id, crm_provider, sync_direction,
                    entity_type, entity_id, trigger_event, kafka_topic, kafka_event_id,
                    status, retry_count, request_payload, response_payload, synced_at
                )
                VALUES ($1, $2, $3, 'copilot_to_crm', $4, $5, $6, $7, $8, 'success', $9, $10, $11, NOW())
                """,
                organization_id,
                crm_config["tenant_id"],
                crm_provider,
                entity_type,
                crm_entity_id,
                event_context.get("event_type") if event_context else None,
                event_context.get("kafka_topic") if event_context else None,
                event_context.get("event_id") if event_context else None,
                retry_count,
                json.dumps(update_data),
                json.dumps(response)
            )

            logger.info(f"CRM sync successful: {crm_provider} {entity_type} {crm_entity_id}")
            return response

        except Exception as e:
            retry_count += 1
            logger.error(f"CRM sync failed (attempt {retry_count}/{max_retries}): {e}")

            if retry_count >= max_retries:
                # Log failure
                await db.execute(
                    """
                    INSERT INTO crm_sync_log (
                        organization_id, tenant_id, crm_provider, sync_direction,
                        entity_type, entity_id, trigger_event, kafka_topic,
                        status, retry_count, error_message, request_payload, synced_at
                    )
                    VALUES ($1, $2, $3, 'copilot_to_crm', $4, $5, $6, $7, 'failed', $8, $9, $10, NOW())
                    """,
                    organization_id,
                    crm_config["tenant_id"],
                    crm_provider,
                    entity_type,
                    crm_entity_id,
                    event_context.get("event_type") if event_context else None,
                    event_context.get("kafka_topic") if event_context else None,
                    max_retries,
                    str(e),
                    json.dumps(update_data)
                )

                # Create alert for agent
                agent = await get_assigned_agent(organization_id)
                if agent:
                    await websocket_broadcast(
                        agent_id=agent["id"],
                        message={
                            "type": "notification",
                            "severity": "medium",
                            "message": f"CRM sync failed for {entity_type} after {max_retries} retries"
                        }
                    )

                raise

            # Exponential backoff
            await asyncio.sleep(2 ** retry_count)
```

---

## Village Knowledge Integration

### Semantic Search for Best Practices

```python
async def get_relevant_village_knowledge(
    clients: list,
    situation_type: str = None,
    limit: int = 5
) -> list:
    """
    Retrieve relevant village knowledge for agent's assigned clients.
    """
    # Extract common client profiles
    industries = list(set(c["industry"] for c in clients))
    lifecycle_stages = list(set(c["lifecycle_stage"] for c in clients))

    # Build search query
    query = f"Best practices for {situation_type or 'customer success'} in {', '.join(industries)} companies at {', '.join(lifecycle_stages)} stage"

    # Generate query embedding
    embedding = await generate_embedding(query)

    # Search Qdrant
    from qdrant_client import QdrantClient
    qdrant = QdrantClient(url=settings.QDRANT_URL)

    results = qdrant.search(
        collection_name="village_knowledge_embeddings",
        query_vector=embedding,
        query_filter={
            "must": [
                {"key": "tenant_id", "match": {"value": str(clients[0]["tenant_id"])}},
                {"key": "status", "match": {"value": "published"}}
            ]
        },
        limit=limit
    )

    # Enrich with PostgreSQL data
    village_knowledge = []
    for result in results:
        vk_id = result.payload["village_knowledge_id"]
        vk = await db.fetchrow("SELECT * FROM village_knowledge WHERE id = $1", vk_id)

        if vk:
            village_knowledge.append({
                "id": vk["id"],
                "type": vk["type"],
                "title": vk["title"],
                "description": vk["description"],
                "situation_type": vk["situation_type"],
                "client_profile": json.loads(vk["client_profile"]),
                "success_rate": float(vk["success_rate"]),
                "usage_count": vk["usage_count"],
                "upvotes": vk["upvotes"],
                "relevance_score": result.score
            })

    return village_knowledge
```

---

## Performance Dashboard

### Metrics Calculation

**Background Job** (runs hourly):

```python
async def calculate_agent_performance_metrics():
    """
    Calculate performance metrics for all agents (daily, weekly, monthly).
    """
    agents = await db.fetch("SELECT id, tenant_id FROM users WHERE role IN ('sales_agent', 'onboarding_specialist', 'support_specialist', 'success_manager')")

    for agent in agents:
        # Calculate daily metrics
        await calculate_metrics_for_period(agent["id"], agent["tenant_id"], "day", date.today(), date.today())

        # Calculate weekly metrics (if Sunday)
        if date.today().weekday() == 6:
            week_start = date.today() - timedelta(days=6)
            await calculate_metrics_for_period(agent["id"], agent["tenant_id"], "week", week_start, date.today())

        # Calculate monthly metrics (if last day of month)
        if date.today() == date.today().replace(day=1) + timedelta(days=32) - timedelta(days=1):
            month_start = date.today().replace(day=1)
            await calculate_metrics_for_period(agent["id"], agent["tenant_id"], "month", month_start, date.today())


async def calculate_metrics_for_period(agent_id: str, tenant_id: str, period_type: str, period_start: date, period_end: date):
    """
    Calculate metrics for specific period.
    """
    # Response time (hours between client message and agent response)
    response_times = await db.fetch(
        """
        SELECT AVG(EXTRACT(EPOCH FROM (agent_response_at - client_message_at)) / 3600) as avg_hours
        FROM conversation_messages
        WHERE agent_id = $1 AND created_at BETWEEN $2 AND $3
        """,
        agent_id, period_start, period_end
    )

    # Resolution rate (tickets resolved / tickets assigned)
    resolution_rate = await db.fetchval(
        """
        SELECT
            (COUNT(*) FILTER (WHERE status = 'resolved')::float / NULLIF(COUNT(*), 0)) * 100
        FROM support_tickets
        WHERE assigned_to = $1 AND created_at BETWEEN $2 AND $3
        """,
        agent_id, period_start, period_end
    )

    # CSAT score
    csat_score = await db.fetchval(
        """
        SELECT AVG(satisfaction_score)
        FROM customer_satisfaction_surveys
        WHERE agent_id = $1 AND submitted_at BETWEEN $2 AND $3
        """,
        agent_id, period_start, period_end
    )

    # NPS score
    nps_score = await db.fetchval(
        """
        SELECT
            (COUNT(*) FILTER (WHERE nps_score >= 9)::float / NULLIF(COUNT(*), 0) * 100) -
            (COUNT(*) FILTER (WHERE nps_score <= 6)::float / NULLIF(COUNT(*), 0) * 100)
        FROM nps_surveys
        WHERE agent_id = $1 AND submitted_at BETWEEN $2 AND $3
        """,
        agent_id, period_start, period_end
    )

    # Tasks completed
    tasks_completed = await db.fetchval(
        """
        SELECT COUNT(*)
        FROM agent_actions
        WHERE agent_id = $1 AND status = 'completed' AND completed_at BETWEEN $2 AND $3
        """,
        agent_id, period_start, period_end
    )

    # Clients managed
    clients_managed = await db.fetchval(
        """
        SELECT COUNT(DISTINCT organization_id)
        FROM agent_copilot_context
        WHERE agent_id = $1
        """,
        agent_id
    )

    # Average health score
    health_score_avg = await db.fetchval(
        """
        SELECT AVG(health_score)
        FROM agent_copilot_context
        WHERE agent_id = $1
        """,
        agent_id
    )

    # Store metrics
    await db.execute(
        """
        INSERT INTO agent_performance_metrics (
            agent_id, tenant_id, period_type, period_start, period_end,
            response_time_hours, resolution_rate_pct, csat_score, nps_score,
            tasks_completed, clients_managed, health_score_avg,
            calculated_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())
        ON CONFLICT (agent_id, period_type, period_start) DO UPDATE SET
            response_time_hours = EXCLUDED.response_time_hours,
            resolution_rate_pct = EXCLUDED.resolution_rate_pct,
            csat_score = EXCLUDED.csat_score,
            nps_score = EXCLUDED.nps_score,
            tasks_completed = EXCLUDED.tasks_completed,
            clients_managed = EXCLUDED.clients_managed,
            health_score_avg = EXCLUDED.health_score_avg,
            calculated_at = NOW()
        """,
        agent_id, tenant_id, period_type, period_start, period_end,
        response_times[0]["avg_hours"] if response_times else None,
        resolution_rate,
        csat_score,
        nps_score,
        tasks_completed,
        clients_managed,
        health_score_avg
    )
```

---

## Multi-Tenancy & Security

### Row-Level Security (RLS)

All PostgreSQL queries enforce tenant isolation via RLS:

```sql
-- Enable RLS on all tables
ALTER TABLE agent_copilot_context ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_action_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE communication_drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_sync_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE village_knowledge ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_performance_metrics ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY tenant_isolation ON agent_copilot_context
    USING (tenant_id = current_setting('app.current_tenant')::uuid);

-- Set tenant context in each database session
SET app.current_tenant = 'tenant_001';
```

**Middleware** (FastAPI):

```python
from fastapi import Request

@app.middleware("http")
async def set_tenant_context(request: Request, call_next):
    tenant_id = request.headers.get("X-Tenant-ID")

    if not tenant_id:
        return JSONResponse(status_code=400, content={"error": "Missing X-Tenant-ID header"})

    # Set PostgreSQL session variable
    async with db.acquire() as conn:
        await conn.execute(f"SET app.current_tenant = '{tenant_id}'")

    response = await call_next(request)
    return response
```

---

### Authorization

**Agent-Level Authorization**: Agents can only access their assigned clients.

```python
async def check_agent_authorization(agent_id: str, organization_id: str) -> bool:
    """
    Check if agent is authorized to access organization.
    """
    assignment = await db.fetchrow(
        """
        SELECT 1 FROM agent_copilot_context
        WHERE agent_id = $1 AND organization_id = $2
        """,
        agent_id, organization_id
    )

    return assignment is not None
```

---

## Dependencies

### Internal Service Dependencies

| Service | Type | Purpose |
|---------|------|---------|
| **Service 0** | Event Consumer | Agent assignments, role changes |
| **Service 13** | Event Consumer | Health scores, CS playbooks, QBR data |
| **Service 14** | Event Consumer | Support tickets, escalations |
| **Service 15** | API | CRM entity mappings, sync configuration |
| **Service 17** | API | Village knowledge embeddings (Qdrant) |

### External Dependencies

| Dependency | Type | Purpose |
|------------|------|---------|
| **PostgreSQL** | Database | Primary data store (agent context, actions, approvals) |
| **Redis** | Cache | Dashboard state, WebSocket connections, CRM retry queue |
| **Qdrant** | Vector DB | Village knowledge semantic search |
| **Kafka** | Event Bus | Consume 17 topics for real-time context |
| **@workflow/llm-sdk** | Library | Action plan generation, communication drafting |
| **Salesforce** | External API | CRM sync |
| **HubSpot** | External API | CRM sync |
| **Zendesk** | External API | CRM sync |

---

## Testing Strategy

### Unit Tests

**Action Plan Generation**:
```python
def test_generate_action_plan():
    agent_id = "agent_001"
    date = "2025-10-08"

    action_plan = await generate_action_plan(agent_id, date)

    assert action_plan["total_actions"] > 0
    assert action_plan["status"] == "active"
    assert len(action_plan["actions"]) == action_plan["total_actions"]
```

**Communication Drafting**:
```python
def test_draft_email():
    draft = await draft_communication(
        organization_id="org_123",
        agent_id="agent_001",
        comm_type="email",
        purpose="follow_up",
        context={"recent_interaction": "demo_completed"}
    )

    assert draft["content"]["subject"]
    assert draft["content"]["body"]
    assert len(draft["content"]["body"]) < 1000  # Concise
```

### Integration Tests

**Event Processing**:
```python
def test_health_score_event_processing():
    # Publish health score event to Kafka
    event = {
        "event_id": "evt_001",
        "organization_id": "org_123",
        "previous_score": 85,
        "new_score": 70,
        "reason": "Multiple unresolved tickets",
        "timestamp": datetime.now().isoformat()
    }

    kafka_producer.send("customer_success_events", event)

    # Wait for processing
    time.sleep(2)

    # Verify context updated
    context = await db.fetchrow(
        "SELECT * FROM agent_copilot_context WHERE organization_id = $1",
        "org_123"
    )

    assert context["health_score"] == 70
    assert "health_score_changed" in json.dumps(context["context_timeline"])
```

**CRM Sync**:
```python
def test_crm_sync_salesforce():
    # Create test organization with Salesforce mapping
    organization_id = "org_test_001"

    # Trigger sync
    await sync_to_crm(
        organization_id=organization_id,
        crm_provider="salesforce",
        entity_type="Opportunity",
        update_data={"StageName": "Demo Completed"}
    )

    # Verify sync log
    sync_log = await db.fetchrow(
        "SELECT * FROM crm_sync_log WHERE organization_id = $1 ORDER BY synced_at DESC LIMIT 1",
        organization_id
    )

    assert sync_log["status"] == "success"
    assert sync_log["crm_provider"] == "salesforce"
```

---

## Deployment

### Docker Configuration

**Dockerfile**:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**requirements.txt**:
```
fastapi==0.104.1
uvicorn==0.24.0
asyncpg==0.29.0
redis==5.0.1
qdrant-client==1.6.4
aiokafka==0.10.0
workflow-llm-sdk==1.0.0
pydantic==2.5.0
python-jose==3.3.0
httpx==0.25.0
```

---

### Kubernetes Deployment

**deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-21-agent-copilot
  namespace: workflow-automation
spec:
  replicas: 3
  selector:
    matchLabels:
      app: service-21-agent-copilot
  template:
    metadata:
      labels:
        app: service-21-agent-copilot
    spec:
      containers:
      - name: agent-copilot
        image: workflow/service-21-agent-copilot:latest
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
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
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
KAFKA_CONSUMER_GROUP=service-21-agent-copilot

# LLM
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# CRM Integrations
SALESFORCE_CLIENT_ID=...
SALESFORCE_CLIENT_SECRET=...
HUBSPOT_API_KEY=...
ZENDESK_API_TOKEN=...

# Observability
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
LOG_LEVEL=INFO
```

---

## Summary

Service 21 (Agent Copilot) is a comprehensive, event-driven service that:

1. **Aggregates context** from 17 Kafka topics across all services
2. **Generates AI-powered action plans** with predictive outcomes and sequence optimization
3. **Drafts communications** (emails, agendas, QBR decks) with brand voice consistency
4. **Orchestrates approvals** with intelligent routing and SLA monitoring
5. **Syncs with CRMs** (Salesforce, HubSpot, Zendesk) bi-directionally
6. **Surfaces village knowledge** via semantic search for best practices
7. **Tracks performance** with coaching suggestions and peer benchmarking

**Architecture Health**: Service 21 follows all platform patterns (multi-tenancy with RLS, event-driven architecture, @workflow/llm-sdk usage, WebSocket real-time updates) and maintains 9+/10 architecture health.

**Business Impact**: Enhances human agent productivity during the 5% of workflows requiring human intervention, enabling single agents to manage 3x more clients while maintaining quality and reducing context-switching overhead.

---

**Document Version**: 1.0
**Last Updated**: 2025-10-08
**Status**: Ready for Implementation
