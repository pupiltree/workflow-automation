# Microservices Architecture Specification
## Complete Workflow Automation System

---

## Executive Summary

This document defines the comprehensive microservices architecture for an AI-powered workflow automation platform that automates client onboarding, demo generation, PRD creation, implementation, monitoring, and customer success. The architecture decomposes a complex workflow into 15 specialized microservices, leveraging event-driven patterns, multi-tenant isolation, and AI agent orchestration to achieve 95% automation within 12 months.

**Key Architecture Principles:**
- Event-driven communication via Apache Kafka for loose coupling and scalability
- Multi-tenant isolation using Row-Level Security (RLS) and namespace-based segregation
- YAML-driven dynamic configuration for agent behavior and workflow customization
- LangGraph-based agent orchestration for stateful, fault-tolerant AI workflows
- Microservices autonomy with database-per-service pattern
- Horizontal scalability through containerized deployment on Kubernetes

**Business Impact:**
- 80% reduction in customer service costs (from $13/call to $2-3/call)
- 95% automation rate target within 12 months
- Support for 10,000+ multi-tenant customers with isolated configurations
- Real-time monitoring and analytics for continuous optimization
- Sub-500ms voice agent latency and <2s API response times

---

## Architecture Overview

### System Architecture Diagram (Text Description)

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway (Kong)                       │
│              Authentication • Rate Limiting • Routing            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Event Bus (Apache Kafka)                    │
│     Topics: client_events, agent_decisions, tool_results,       │
│         system_events, analytics_events, monitoring_events       │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴──────────────────────┐
         │                                           │
         ▼                                           ▼
┌─────────────────┐                        ┌──────────────────┐
│  Core Services  │                        │  Support Services│
├─────────────────┤                        ├──────────────────┤
│ 1. Research     │                        │ 11. Monitoring   │
│ 2. Demo Gen     │                        │ 12. Analytics    │
│ 3. NDA Gen      │                        │ 13. Customer     │
│ 4. Pricing      │                        │     Success      │
│ 5. Proposal     │                        │ 14. Support      │
│ 6. PRD Builder  │                        │ 15. CRM          │
│ 7. Automation   │                        │     Integration  │
│ 8. Agent Orch   │                        └──────────────────┘
│ 9. Voice Agent  │
│ 10. Config Mgmt │
└─────────────────┘

Data Layer:
- PostgreSQL (Supabase) with RLS: Transactional data, multi-tenant isolation
- Qdrant: Vector storage for RAG, namespace-per-tenant
- Neo4j: Knowledge graphs for GraphRAG
- Redis: Caching, session state, rate limiting
- TimescaleDB: Time-series metrics and analytics
```

### Communication Patterns

**1. Event-Driven (Primary Pattern)**
- Asynchronous communication via Kafka topics
- Event sourcing for audit trails and replay capability
- Saga pattern for distributed transactions
- Eventual consistency across services

**2. Synchronous REST APIs**
- Real-time user-facing operations (demo generation, proposals)
- External integrations (CRM, payment gateways)
- Admin operations requiring immediate feedback

**3. gRPC for Internal Communication**
- High-performance inter-service calls
- Agent-to-agent coordination
- Tool invocation from agent orchestrator

### Multi-Tenancy Strategy

**Tier 1: Shared Infrastructure (0-1000 tenants)**
- Row-Level Security in PostgreSQL
- Namespace isolation in Qdrant
- Shared Kafka topics with tenant_id filtering
- Kong Workspaces for API isolation

**Tier 2: Dedicated Namespaces (1000-5000 tenants)**
- Separate Kubernetes namespaces per tenant
- Dedicated Neo4j graphs for enterprise customers
- Schema-per-tenant in PostgreSQL (Citus sharding)
- Enhanced monitoring and SLA guarantees

**Tier 3: Physical Isolation (Enterprise/Regulated)**
- Dedicated infrastructure clusters
- Separate databases with tenant-managed encryption keys
- HIPAA/PCI-DSS compliance requirements
- Custom deployment regions

---

## Microservice Specifications

### 1. Research Engine Service

#### Objectives
- **Primary Purpose**: Automated client research and competitive intelligence gathering
- **Business Value**: Eliminates 40+ hours of manual research per client, provides data-driven insights for demo personalization
- **Scope Boundaries**:
  - **Does**: Scrape public data sources, analyze competitor workflows, generate research reports, identify customer pain points
  - **Does Not**: Access private/authenticated data without authorization, make business decisions, generate demos

#### Requirements

**Functional Requirements:**
1. Multi-source data collection (Instagram, Facebook, TikTok, Google Maps, Reddit, reviews)
2. Decision maker identification via Apollo.io, LinkedIn Sales Navigator, and contact databases
3. Financial/funding news research via TechCrunch, YourStory, Crunchbase, PitchBook
4. Competitive workflow analysis through mystery shopping (human agent coordination)
5. Response quality assessment (speed, hours, coverage gaps)
6. Automated report generation with actionable insights
7. Data enrichment via third-party APIs (Clearbit, Apollo, ZoomInfo)
8. Duplicate detection and data deduplication

**Non-Functional Requirements:**
- Research completion within 24-48 hours per client
- 95% data accuracy for structured fields (phone, email, hours)
- Support 100 concurrent research jobs
- PII compliance (GDPR, CCPA) - anonymize personal data
- Cost optimization: <$50/research job

**Dependencies:**
- Demo Generator Service (publishes research_completed event)
- Configuration Management Service (scraping rules, source priorities)
- External APIs:
  - Social media: Instagram, Facebook, TikTok APIs
  - Business data: Google Maps API, Yelp API
  - Decision makers: Apollo.io, LinkedIn Sales Navigator, ZoomInfo
  - Financial news: TechCrunch API, YourStory, Crunchbase, PitchBook
  - Data enrichment: Clearbit, Hunter.io
  - Web scraping: Bright Data, ScrapingBee proxy services

**Data Storage:**
- PostgreSQL: Research metadata, job status, findings summaries
- S3/Object Storage: Raw scraped data, screenshots, documents
- Qdrant: Semantic search on research findings for retrieval

#### Features

**Must-Have:**
1. ✅ Automated scraping orchestrator (Playwright/Puppeteer)
2. ✅ Multi-platform social media data extraction
3. ✅ Google Maps business data scraping
4. ✅ Review aggregation and sentiment analysis
5. ✅ Decision maker research (Apollo.io, LinkedIn Sales Navigator integration)
6. ✅ Financial/funding news aggregation (TechCrunch, YourStory, Crunchbase, PitchBook)
7. ✅ Mystery shopping workflow (human agent task assignment)
8. ✅ Competitor workflow documentation
9. ✅ Research report generation (JSON + PDF formats)

**Nice-to-Have:**
10. 🔄 Real-time data streaming (live social media monitoring)
11. 🔄 Predictive analytics (churn risk, expansion opportunities)
12. 🔄 Video content transcription and analysis
13. 🔄 Automated SWOT analysis generation

**Feature Interactions:**
- Research completion triggers demo generation
- Findings feed into PRD Builder for context
- Competitive insights inform pricing model

#### API Specification

**1. Create Research Job**
```http
POST /api/v1/research/jobs
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "client_name": "Acme Corp",
  "industry": "e-commerce",
  "research_scope": {
    "primary_sources": ["instagram", "google_maps", "reviews"],
    "deep_research": ["reddit", "industry_forums"],
    "mystery_shopping": true
  },
  "target_platforms": ["instagram", "facebook", "tiktok"],
  "priority": "high",
  "deadline": "2025-10-10T00:00:00Z"
}

Response (201 Created):
{
  "job_id": "uuid",
  "status": "queued",
  "estimated_completion": "2025-10-06T12:00:00Z",
  "created_at": "2025-10-04T10:30:00Z",
  "webhook_url": "https://api.workflow.com/webhooks/research-complete"
}

Error Responses:
400 Bad Request: Invalid client_id or missing required fields
401 Unauthorized: Invalid or expired token
429 Too Many Requests: Rate limit exceeded (100 jobs/hour)
```

**2. Get Research Job Status**
```http
GET /api/v1/research/jobs/{job_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "job_id": "uuid",
  "client_id": "uuid",
  "status": "in_progress",
  "progress": {
    "primary_research": "completed",
    "deep_research": "in_progress",
    "mystery_shopping": "pending"
  },
  "findings_summary": {
    "instagram_followers": 15000,
    "google_rating": 4.2,
    "response_time_avg": "4 hours",
    "coverage_gaps": ["nights", "weekends"]
  },
  "estimated_completion": "2025-10-05T16:00:00Z",
  "updated_at": "2025-10-04T14:45:00Z"
}
```

**3. Get Research Report**
```http
GET /api/v1/research/jobs/{job_id}/report
Authorization: Bearer {jwt_token}
Accept: application/json | application/pdf

Response (200 OK - JSON):
{
  "job_id": "uuid",
  "client_id": "uuid",
  "research_completed_at": "2025-10-05T15:30:00Z",
  "primary_findings": {
    "social_media": {
      "instagram": {
        "handle": "@acmecorp",
        "followers": 15000,
        "engagement_rate": 3.2,
        "posting_frequency": "daily",
        "content_themes": ["product_demos", "customer_stories"]
      },
      "facebook": {...},
      "tiktok": {...}
    },
    "google_maps": {
      "business_name": "Acme Corp",
      "rating": 4.2,
      "review_count": 342,
      "hours": "Mon-Fri 9AM-6PM",
      "coverage_gaps": ["nights", "weekends"]
    },
    "reviews": {
      "avg_rating": 4.1,
      "total_reviews": 458,
      "sentiment_breakdown": {
        "positive": 72,
        "neutral": 18,
        "negative": 10
      },
      "common_complaints": [
        "slow_response_time",
        "weekend_unavailability"
      ]
    }
  },
  "decision_makers": {
    "identified_count": 5,
    "contacts": [
      {
        "name": "John Smith",
        "title": "CEO",
        "email": "john@acme.com",
        "phone": "+1-555-123-4567",
        "linkedin_url": "https://linkedin.com/in/johnsmith",
        "source": "apollo.io",
        "confidence": 0.95
      },
      {
        "name": "Jane Doe",
        "title": "VP Operations",
        "email": "jane@acme.com",
        "linkedin_url": "https://linkedin.com/in/janedoe",
        "source": "linkedin_sales_navigator",
        "confidence": 0.88
      }
    ],
    "org_chart": {
      "ceo": "John Smith",
      "direct_reports": ["Jane Doe - VP Ops", "Mike Johnson - CTO", "Sarah Williams - CFO"]
    }
  },
  "financial_news": {
    "funding_status": "Series B",
    "total_funding": "$25M",
    "last_round": {
      "amount": "$15M",
      "date": "2024-08-15",
      "lead_investor": "Sequoia Capital",
      "source": "crunchbase"
    },
    "recent_news": [
      {
        "title": "Acme Corp raises $15M Series B to expand AI capabilities",
        "source": "techcrunch",
        "url": "https://techcrunch.com/2024/08/15/acme-series-b",
        "date": "2024-08-15",
        "sentiment": "positive"
      },
      {
        "title": "Acme Corp shows 300% YoY growth in Q2 2024",
        "source": "yourstory",
        "url": "https://yourstory.com/2024/09/acme-growth",
        "date": "2024-09-10",
        "sentiment": "positive"
      }
    ],
    "growth_indicators": {
      "employee_count_growth": "+45% YoY",
      "market_expansion": ["US", "EU", "India"],
      "recent_partnerships": ["Microsoft", "AWS"]
    }
  },
  "deep_research": {
    "reddit_mentions": 23,
    "industry_forum_discussions": 8,
    "competitor_comparisons": [...]
  },
  "mystery_shopping": {
    "response_quality_score": 6.5,
    "avg_response_time": "4.2 hours",
    "work_hours_coverage": "Mon-Fri 9-6",
    "non_work_hours_coverage": "none",
    "workflow_analysis": "Email-based, manual routing, no automation"
  },
  "recommendations": [
    "Target decision makers: John Smith (CEO) and Jane Doe (VP Ops) for pilot discussions",
    "Leverage Series B funding news as conversation starter about scaling operations",
    "Implement 24/7 chatbot for after-hours coverage",
    "Automate response routing to reduce 4hr response time to <15min",
    "Add SMS/WhatsApp channels based on customer preferences"
  ]
}

Response (200 OK - PDF):
Binary PDF content with formatted report
```

**4. Trigger Mystery Shopping Task**
```http
POST /api/v1/research/jobs/{job_id}/mystery-shopping
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "target_channels": ["phone", "email", "chat"],
  "test_scenarios": [
    "product_inquiry",
    "support_request",
    "complaint"
  ],
  "agent_count": 3
}

Response (202 Accepted):
{
  "task_id": "uuid",
  "status": "assigned",
  "assigned_agents": [
    {"agent_id": "uuid", "channel": "phone"},
    {"agent_id": "uuid", "channel": "email"},
    {"agent_id": "uuid", "channel": "chat"}
  ],
  "estimated_completion": "2025-10-05T18:00:00Z"
}
```

**5. List Research Jobs**
```http
GET /api/v1/research/jobs?status=completed&limit=50&offset=0
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "total": 245,
  "limit": 50,
  "offset": 0,
  "jobs": [
    {
      "job_id": "uuid",
      "client_name": "Acme Corp",
      "status": "completed",
      "created_at": "2025-10-01T10:00:00Z",
      "completed_at": "2025-10-03T15:30:00Z"
    },
    ...
  ]
}
```

**Rate Limiting:**
- 100 research jobs per hour per tenant
- 500 API requests per minute per tenant
- Burst allowance: 200 requests in 10 seconds

#### Frontend Components

**1. Research Dashboard (Admin View)**
- Component: `ResearchJobsDashboard.tsx`
- Features:
  - Data grid showing all research jobs (status, client, progress)
  - Filters: status, date range, client, priority
  - Real-time status updates via WebSocket
  - Bulk actions (retry failed, export reports)
  - Analytics: avg completion time, success rate, cost per job

**2. Research Job Detail View**
- Component: `ResearchJobDetail.tsx`
- Features:
  - Progress timeline visualization
  - Source-by-source status (Instagram ✅, Reddit ⏳)
  - Live logs streaming
  - Manual intervention options (retry source, skip, abort)
  - Findings preview (collapsible sections)

**3. Research Report Viewer**
- Component: `ResearchReportViewer.tsx`
- Features:
  - Tabbed interface (Summary, Primary, Deep, Mystery Shopping)
  - Interactive charts (sentiment analysis, rating distributions)
  - Export options (PDF, JSON, CSV)
  - Annotation tools for sales team
  - Integration with Demo Generator (one-click demo creation)

**4. Mystery Shopping Task Manager**
- Component: `MysteryShoppingTasks.tsx`
- Features:
  - Task assignment interface for human agents
  - Recording templates for standardized observations
  - Response quality scoring rubric
  - Workflow documentation canvas
  - Screenshot/recording uploads

**State Management:**
- Redux Toolkit for global research job state
- React Query for API data fetching and caching
- WebSocket integration for real-time updates
- Optimistic UI updates for job creation

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Team Lead**
   - Role: Initiates research jobs for qualified leads
   - Access: Full CRUD on research jobs for assigned clients
   - Permissions: create:research, read:research, update:research
   - Workflows: Reviews reports, triggers demo generation

2. **Mystery Shopper Agents**
   - Role: Conduct manual competitor analysis and workflow testing
   - Access: Read-only on assigned tasks, write access to observations
   - Permissions: read:tasks, write:observations
   - Workflows: Receives task assignments, completes mystery shopping, submits findings
   - Approval: Task completions reviewed by QA before inclusion in reports

3. **Research Operations Manager**
   - Role: Oversees research quality, manages scraping infrastructure
   - Access: Full admin access to all research jobs and configurations
   - Permissions: admin:research, configure:scrapers, manage:agents
   - Workflows: Monitors job failures, optimizes scraping rules, reviews escalated issues

**AI Agents:**

1. **Research Orchestrator Agent**
   - Responsibility: Coordinates multi-source data collection, prioritizes sources
   - Tools: Web scraper, API integrators, data validators
   - Autonomy: Fully autonomous - no human approval required
   - Escalation: Alerts on repeated failures or blocked sources

2. **Data Enrichment Agent**
   - Responsibility: Enhances raw data with third-party APIs, deduplication
   - Tools: Clearbit API, Apollo API, fuzzy matching algorithms
   - Autonomy: Fully autonomous within budget limits ($5/enrichment)
   - Escalation: Human approval required for >$20 third-party API costs

3. **Insight Generation Agent**
   - Responsibility: Analyzes findings, generates recommendations
   - Tools: LLM (GPT-4), sentiment analysis, workflow pattern recognition
   - Autonomy: Fully autonomous
   - Escalation: Human review for high-stakes recommendations (>$100K contracts)

**Approval Workflows:**
1. Research Job Creation → Auto-approved for existing clients, requires Sales Lead approval for new clients
2. Mystery Shopping Tasks → Auto-assigned to available agents, QA review before report inclusion
3. Third-Party API Costs > $20 → Requires Research Operations Manager approval

---

### 2. Demo Generator Service

#### Objectives
- **Primary Purpose**: Automated generation of client-specific AI chatbot/voicebot demos with mock data and tools
- **Business Value**: Reduces demo creation time from 40+ hours to <2 hours, enables rapid iteration, increases win rates through personalized demos
- **Scope Boundaries**:
  - **Does**: Generate functional web UI demos, create mock datasets, integrate mock tools, deploy to sandboxed environments, enable developer testing
  - **Does Not**: Access production client data, deploy to production, handle real transactions

#### Requirements

**Functional Requirements:**
1. Generate demo chatbot/voicebot UI based on research findings
2. Create contextually relevant mock data (customer profiles, conversation histories)
3. Implement mock tool integrations (CRM, scheduling, payment)
3. Deploy to isolated sandbox environment with unique URL
4. Enable developer testing with issue tracking
5. Iterate on feedback until "demo perfect" status
6. Support A/B demo variations for same client

**Non-Functional Requirements:**
- Demo generation time: <30 minutes from research completion
- Demo availability: 99.5% uptime during client presentation window
- Concurrent demos: Support 100+ active sandbox environments
- Security: Complete tenant isolation, no cross-demo data leakage
- Performance: <2s initial load, <500ms chatbot response time

**Dependencies:**
- Research Engine (consumes research_completed events)
- Configuration Management (demo templates, UI themes)
- Agent Orchestration Service (powers demo chatbot logic)
- GitHub API (automated repo creation, deployment)

**Data Storage:**
- PostgreSQL: Demo metadata, status, feedback, developer test results
- S3: Demo artifacts (built UI bundles, mock datasets, screenshots)
- Separate PostgreSQL/Supabase instance per demo for isolation

#### Features

**Must-Have:**
1. ✅ Template-based UI generation (React/Next.js components)
2. ✅ Mock data synthesis from research context
3. ✅ Multi-channel demo support (web chat, voice call simulation)
4. ✅ Sandbox environment provisioning (Kubernetes namespace)
5. ✅ Developer testing workflow (issue creation, fix tracking)
6. ✅ Demo versioning and rollback
7. ✅ Shareable demo links with access controls

**Nice-to-Have:**
8. 🔄 Real-time collaboration on demo (multiplayer editing)
9. 🔄 Analytics on demo interactions (heatmaps, engagement)
10. 🔄 Auto-generated demo scripts for sales team
11. 🔄 Demo recording and playback

**Feature Interactions:**
- Research findings → Auto-populate demo context
- Developer fixes → Auto-update demo, notify sales team
- Demo approval → Trigger client meeting scheduling

#### API Specification

**1. Generate Demo**
```http
POST /api/v1/demos/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "research_job_id": "uuid",
  "client_id": "uuid",
  "demo_config": {
    "channels": ["webchat", "voice"],
    "use_cases": ["customer_support", "lead_qualification"],
    "branding": {
      "primary_color": "#1a73e8",
      "logo_url": "https://cdn.acme.com/logo.png",
      "company_name": "Acme Corp"
    },
    "mock_tools": ["crm_lookup", "appointment_scheduling", "knowledge_base"],
    "conversation_samples": 10
  },
  "template_id": "support_bot_v2"
}

Response (202 Accepted):
{
  "demo_id": "uuid",
  "status": "generating",
  "estimated_completion": "2025-10-04T11:00:00Z",
  "webhook_url": "https://api.workflow.com/webhooks/demo-ready"
}

Error Responses:
400 Bad Request: Invalid research_job_id or missing required config
402 Payment Required: Tenant exceeded demo quota
422 Unprocessable Entity: Research data insufficient for demo generation
```

**2. Get Demo Status**
```http
GET /api/v1/demos/{demo_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "demo_id": "uuid",
  "client_id": "uuid",
  "status": "ready",
  "demo_url": "https://demo.workflow.com/acme-corp-d3f5g7",
  "access_token": "demo_token_xyz",
  "valid_until": "2025-10-14T23:59:59Z",
  "generation_log": {
    "ui_generation": "completed",
    "mock_data_creation": "completed",
    "tool_integration": "completed",
    "deployment": "completed"
  },
  "metadata": {
    "channels": ["webchat", "voice"],
    "conversation_samples": 10,
    "mock_customers": 25
  },
  "developer_testing": {
    "status": "in_progress",
    "issues_found": 3,
    "issues_fixed": 1
  },
  "created_at": "2025-10-04T10:30:00Z",
  "updated_at": "2025-10-04T10:55:00Z"
}
```

**3. Update Demo**
```http
PATCH /api/v1/demos/{demo_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "branding": {
    "primary_color": "#ff5733"
  },
  "add_use_cases": ["upsell"],
  "remove_mock_tools": ["payment_processing"]
}

Response (200 OK):
{
  "demo_id": "uuid",
  "status": "updating",
  "version": 2,
  "estimated_completion": "2025-10-04T12:15:00Z"
}
```

**4. Submit Developer Feedback**
```http
POST /api/v1/demos/{demo_id}/feedback
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "tester_id": "uuid",
  "issues": [
    {
      "severity": "high",
      "category": "functionality",
      "description": "Chatbot fails to retrieve customer data when phone number contains spaces",
      "steps_to_reproduce": "1. Enter phone: +1 555 123 4567\n2. Ask 'What's my order status?'\n3. Error occurs",
      "screenshot_url": "https://storage.workflow.com/screenshots/abc123.png"
    },
    {
      "severity": "low",
      "category": "ui",
      "description": "Logo alignment off-center on mobile",
      "screenshot_url": "https://storage.workflow.com/screenshots/def456.png"
    }
  ],
  "overall_status": "needs_fixes"
}

Response (201 Created):
{
  "feedback_id": "uuid",
  "demo_id": "uuid",
  "issues_created": [
    {"issue_id": "uuid", "github_issue_url": "https://github.com/org/demos/issues/123"},
    {"issue_id": "uuid", "github_issue_url": "https://github.com/org/demos/issues/124"}
  ],
  "assigned_developer": "uuid",
  "estimated_fix_time": "2025-10-04T14:00:00Z"
}
```

**5. Mark Demo as Perfect**
```http
POST /api/v1/demos/{demo_id}/approve
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "approved_by": "uuid",
  "approval_notes": "All issues resolved, demo tested across devices, ready for client presentation"
}

Response (200 OK):
{
  "demo_id": "uuid",
  "status": "approved",
  "approved_at": "2025-10-04T15:00:00Z",
  "client_meeting_scheduled": false,
  "next_steps": ["schedule_client_meeting"]
}

Event Published to Kafka:
Topic: demo_events
{
  "event_type": "demo_approved",
  "demo_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-04T15:00:00Z"
}
```

**6. Get Demo Analytics**
```http
GET /api/v1/demos/{demo_id}/analytics
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "demo_id": "uuid",
  "usage_stats": {
    "total_sessions": 47,
    "unique_users": 12,
    "avg_session_duration": "8m 23s",
    "total_conversations": 156
  },
  "engagement_metrics": {
    "messages_per_conversation": 12.4,
    "tool_invocations": {
      "crm_lookup": 45,
      "appointment_scheduling": 23,
      "knowledge_base": 78
    },
    "user_satisfaction": 4.2,
    "completion_rate": 87
  },
  "technical_performance": {
    "avg_response_time": "1.2s",
    "error_rate": 0.02,
    "uptime": 99.8
  }
}
```

**Rate Limiting:**
- 10 demo generations per hour per tenant
- 1000 API requests per minute per tenant
- Demo updates: 50 per hour per demo

#### Frontend Components

**1. Demo Configuration Wizard**
- Component: `DemoConfigWizard.tsx`
- Features:
  - Multi-step form (Research Review → Channels → Branding → Tools → Confirm)
  - Real-time preview as config changes
  - Template gallery with filtering
  - Research findings auto-population
  - Budget estimate calculator

**2. Demo Builder Canvas**
- Component: `DemoBuilderCanvas.tsx`
- Features:
  - Drag-and-drop UI editor
  - Component library (chat widget, voice interface, forms)
  - Live preview mode (desktop, tablet, mobile)
  - Mock data editor (inline editing of conversation samples)
  - Version history with visual diff

**3. Developer Testing Dashboard**
- Component: `DevTestingDashboard.tsx`
- Features:
  - Issue tracker (Kanban board: Open, In Progress, Fixed, Verified)
  - Test execution logs
  - Screenshot annotations
  - Device/browser matrix testing status
  - Automated test results integration

**4. Demo Presentation View**
- Component: `DemoPresentationView.tsx`
- Features:
  - Fullscreen demo player
  - Presenter controls (pause, reset conversation, switch scenarios)
  - Side-by-side comparison (current vs proposed solution)
  - Real-time analytics overlay (engagement heatmap)
  - Screen recording with annotated commentary

**5. Demo Management Dashboard**
- Component: `DemoManagementDashboard.tsx`
- Features:
  - Grid/list view of all demos
  - Filters (status, client, date, use case)
  - Bulk actions (extend expiry, archive, clone)
  - Analytics summary cards
  - Integration with calendar (scheduled presentations)

**State Management:**
- Zustand for demo builder state (canvas, components)
- React Query for API data fetching
- Real-time updates via Server-Sent Events (SSE)
- LocalStorage for draft configurations

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Engineer**
   - Role: Configures and oversees demo generation
   - Access: Full CRUD on demos for assigned clients
   - Permissions: create:demo, read:demo, update:demo, approve:demo
   - Workflows: Reviews research, configures demo, coordinates with developers, presents to client

2. **Developer (QA/Tester)**
   - Role: Tests demos and fixes issues
   - Access: Read access to demos, write access to feedback and fixes
   - Permissions: read:demo, write:feedback, deploy:fixes
   - Workflows: Receives demo assignment, tests functionality, creates GitHub issues, implements fixes, verifies resolution
   - Approval: Fixes auto-deployed to sandbox, Sales Engineer approval required for demo re-generation

3. **Sales Manager**
   - Role: Oversees demo pipeline, approves high-value demos
   - Access: Read-only access to all demos, approval rights for >$500K deals
   - Permissions: read:all_demos, approve:high_value_demo
   - Workflows: Reviews demo status, approves enterprise demos, monitors win rates

**AI Agents:**

1. **Demo Generation Agent**
   - Responsibility: Orchestrates UI generation, mock data creation, deployment
   - Tools: Code generators (React component builder), mock data synthesizers, Kubernetes API
   - Autonomy: Fully autonomous for standard demos
   - Escalation: Human approval required for custom integrations or non-standard templates

2. **Mock Data Synthesis Agent**
   - Responsibility: Creates realistic mock datasets from research context
   - Tools: LLM (GPT-4 for context understanding), data generators (Faker.js), domain knowledge bases
   - Autonomy: Fully autonomous within data volume limits (max 1000 mock records)
   - Escalation: Alerts on insufficient research data for quality mock generation

3. **Issue Resolution Agent**
   - Responsibility: Analyzes developer feedback, suggests fixes, auto-patches simple issues
   - Tools: Code analysis (AST parsers), LLM for bug diagnosis, GitHub API
   - Autonomy: Auto-fixes for trivial issues (typos, CSS adjustments), suggests fixes for complex bugs
   - Escalation: Complex issues assigned to human developers with AI-generated fix recommendations

**Approval Workflows:**
1. Demo Generation → Auto-approved for standard templates, Sales Manager approval for custom/enterprise
2. Developer Fixes → Auto-deployed to sandbox, no approval required
3. Demo Approval (Perfect Status) → Sales Engineer approval, triggers client meeting scheduling
4. Demo Extension (>30 days) → Sales Manager approval required

---

### 3. NDA Generator Service

#### Objectives
- **Primary Purpose**: Automated generation and management of client NDAs with e-signature workflow
- **Business Value**: Reduces legal overhead from 5+ days to <1 hour, ensures compliance, accelerates sales cycle
- **Scope Boundaries**:
  - **Does**: Generate customized NDAs, manage e-signature workflow, track signature status, handle reminders
  - **Does Not**: Provide legal advice, handle complex contract negotiations, manage contracts beyond NDA scope

#### Requirements

**Functional Requirements:**
1. Generate NDAs from templates based on client business type and deal size
2. Integrate with e-signature platforms (AdobeSign, DocuSign, HelloSign)
3. Automated sending after pilot agreement in client meeting
4. Track signature status with automated reminders
5. Store executed NDAs with audit trail
6. Support multi-party NDAs (client + subcontractors)
7. Version control for NDA templates

**Non-Functional Requirements:**
- NDA generation: <2 minutes from trigger
- E-signature delivery: <5 minutes after generation
- 99.9% uptime for signature verification
- GDPR/CCPA compliance for PII handling
- Support 500 concurrent NDA workflows

**Dependencies:**
- Demo Generator (consumes demo_approved + client_agreed_pilot events)
- Configuration Management (NDA templates, client business classifications)
- Pricing Model Generator (triggers pricing calculation after NDA signing)
- External APIs: AdobeSign, DocuSign, SendGrid (email delivery)

**Data Storage:**
- PostgreSQL: NDA metadata, signature status, audit logs
- S3: NDA PDF files (encrypted at rest), signature evidence
- Vault: E-signature API credentials, client contact encryption

#### Features

**Must-Have:**
1. ✅ Template-based NDA generation (legal-approved templates)
2. ✅ Dynamic field population (client name, date, business type, scope)
3. ✅ Multi-platform e-signature integration (AdobeSign primary, DocuSign fallback)
4. ✅ Automated sending workflow (email + SMS notifications)
5. ✅ Signature tracking dashboard
6. ✅ Automated reminder sequences (Day 2, 5, 7 if unsigned)
7. ✅ Audit trail (who accessed, when signed, IP address)

**Nice-to-Have:**
8. 🔄 AI-powered clause recommendations based on industry
9. 🔄 Multi-language NDA support
10. 🔄 Bulk NDA generation for enterprise clients
11. 🔄 Integration with contract management systems (Ironclad, Concord)

**Feature Interactions:**
- Pilot agreement in demo meeting → Auto-generates NDA
- NDA signed → Triggers pricing model generation
- NDA expiry approaching → Alerts sales team for renewal

#### API Specification

**1. Generate NDA**
```http
POST /api/v1/ndas/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "business_type": "e-commerce",
  "deal_size_estimate": 250000,
  "template_id": "standard_saas_nda_v3",
  "signatories": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "role": "CEO",
      "signing_order": 1
    },
    {
      "name": "Jane Doe",
      "email": "jane@workflow.com",
      "role": "Sales Director",
      "signing_order": 2
    }
  ],
  "additional_clauses": ["data_residency", "subcontractor_disclosure"],
  "effective_duration_months": 24,
  "auto_send": true
}

Response (201 Created):
{
  "nda_id": "uuid",
  "status": "generated",
  "document_url": "https://storage.workflow.com/ndas/acme-nda-2025-10-04.pdf",
  "signature_workflow_id": "adobesign_xyz123",
  "sent_at": "2025-10-04T16:00:00Z",
  "signatories": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "status": "sent",
      "signature_url": "https://adobesign.com/sign/abc123"
    },
    {
      "name": "Jane Doe",
      "email": "jane@workflow.com",
      "status": "pending",
      "signature_url": null
    }
  ],
  "created_at": "2025-10-04T15:58:00Z"
}

Error Responses:
400 Bad Request: Invalid client_id or template_id
422 Unprocessable Entity: Missing required signatory information
503 Service Unavailable: E-signature provider unavailable
```

**2. Get NDA Status**
```http
GET /api/v1/ndas/{nda_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "nda_id": "uuid",
  "client_id": "uuid",
  "status": "partially_signed",
  "document_url": "https://storage.workflow.com/ndas/acme-nda-2025-10-04.pdf",
  "signature_workflow_id": "adobesign_xyz123",
  "signatories": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "status": "signed",
      "signed_at": "2025-10-04T18:23:00Z",
      "ip_address": "192.168.1.100",
      "signature_url": "https://adobesign.com/signed/abc123"
    },
    {
      "name": "Jane Doe",
      "email": "jane@workflow.com",
      "status": "pending",
      "reminder_sent_at": "2025-10-06T10:00:00Z",
      "signature_url": "https://adobesign.com/sign/def456"
    }
  ],
  "effective_date": null,
  "expiration_date": null,
  "audit_trail": [
    {"event": "generated", "timestamp": "2025-10-04T15:58:00Z", "actor": "system"},
    {"event": "sent_to_john", "timestamp": "2025-10-04T16:00:00Z", "actor": "system"},
    {"event": "viewed_by_john", "timestamp": "2025-10-04T17:45:00Z", "actor": "john@acme.com"},
    {"event": "signed_by_john", "timestamp": "2025-10-04T18:23:00Z", "actor": "john@acme.com"},
    {"event": "sent_to_jane", "timestamp": "2025-10-04T18:24:00Z", "actor": "system"}
  ],
  "created_at": "2025-10-04T15:58:00Z",
  "updated_at": "2025-10-06T10:00:00Z"
}
```

**3. Send Reminder**
```http
POST /api/v1/ndas/{nda_id}/remind
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "signatory_email": "jane@workflow.com",
  "reminder_message": "Gentle reminder to sign the NDA for our upcoming pilot project. Please let us know if you have any questions."
}

Response (200 OK):
{
  "nda_id": "uuid",
  "reminder_sent": true,
  "sent_to": "jane@workflow.com",
  "sent_at": "2025-10-06T14:30:00Z",
  "reminder_count": 2
}
```

**4. Get Signed NDA Document**
```http
GET /api/v1/ndas/{nda_id}/document
Authorization: Bearer {jwt_token}
Accept: application/pdf

Response (200 OK):
Binary PDF content with all signatures and certificate of completion

Headers:
Content-Type: application/pdf
Content-Disposition: attachment; filename="acme-nda-signed-2025-10-07.pdf"
X-Signature-Status: fully_signed
X-Effective-Date: 2025-10-07
X-Expiration-Date: 2027-10-07
```

**5. Void/Cancel NDA**
```http
DELETE /api/v1/ndas/{nda_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "reason": "Client requested cancellation",
  "notify_signatories": true
}

Response (200 OK):
{
  "nda_id": "uuid",
  "status": "voided",
  "voided_at": "2025-10-08T10:00:00Z",
  "voided_by": "uuid",
  "reason": "Client requested cancellation"
}

Event Published to Kafka:
Topic: nda_events
{
  "event_type": "nda_voided",
  "nda_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-08T10:00:00Z"
}
```

**6. Webhook - Signature Completed**
```http
POST /api/v1/ndas/webhooks/signature-complete
Content-Type: application/json
X-Webhook-Source: AdobeSign
X-Signature: hmac_sha256_signature

Request Body (from AdobeSign):
{
  "webhook_id": "adobesign_webhook_123",
  "event": "AGREEMENT_WORKFLOW_COMPLETED",
  "agreement_id": "adobesign_xyz123",
  "participant_email": "jane@workflow.com",
  "signed_at": "2025-10-07T09:15:00Z"
}

Response (200 OK):
{
  "received": true,
  "nda_id": "uuid",
  "status_updated": "fully_signed"
}

Internal Event Published to Kafka:
Topic: nda_events
{
  "event_type": "nda_fully_signed",
  "nda_id": "uuid",
  "client_id": "uuid",
  "signed_at": "2025-10-07T09:15:00Z",
  "effective_date": "2025-10-07",
  "expiration_date": "2027-10-07"
}
```

**Rate Limiting:**
- 50 NDA generations per hour per tenant
- 100 reminder sends per day per tenant
- 1000 API requests per minute per tenant

#### Frontend Components

**1. NDA Generation Form**
- Component: `NDAGenerationForm.tsx`
- Features:
  - Template selector with preview
  - Client information auto-population
  - Signatory management (add/remove, reorder)
  - Clause library (checkbox selection)
  - Duration configurator
  - Preview before send

**2. NDA Tracking Dashboard**
- Component: `NDATrackingDashboard.tsx`
- Features:
  - Kanban board (Drafted, Sent, Partially Signed, Fully Signed, Voided)
  - Quick filters (pending my signature, overdue, expiring soon)
  - Bulk reminder sending
  - Analytics cards (avg signature time, completion rate)
  - Export capabilities (CSV, PDF report)

**3. Signature Status Widget**
- Component: `SignatureStatusWidget.tsx`
- Features:
  - Timeline visualization (sent → viewed → signed)
  - Real-time status updates via WebSocket
  - Embedded e-signature iframe
  - Audit trail expandable section
  - Notification preferences toggle

**4. NDA Template Manager (Admin)**
- Component: `NDATemplateManager.tsx`
- Features:
  - Template CRUD operations
  - Variable placeholder editor ({{client_name}}, {{effective_date}})
  - Legal review workflow (draft → review → approved)
  - Version control with diff viewer
  - Usage analytics per template

**State Management:**
- Redux Toolkit for NDA workflow state
- React Query for API data fetching
- WebSocket integration for real-time signature updates
- Form state with React Hook Form

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Director**
   - Role: Initiates NDA generation after pilot agreement
   - Access: Create and view NDAs for assigned clients
   - Permissions: create:nda, read:nda, send:reminder
   - Workflows: Confirms pilot agreement, triggers NDA generation, monitors signature status

2. **Legal Counsel**
   - Role: Manages NDA templates and approves custom clauses
   - Access: Full admin access to templates, read-only on active NDAs
   - Permissions: admin:templates, read:all_ndas, approve:custom_clause
   - Workflows: Reviews template changes, approves non-standard clauses, investigates disputes

3. **Client Signatory**
   - Role: Reviews and signs NDA
   - Access: Read-only access to assigned NDA, signature capability
   - Permissions: read:assigned_nda, sign:nda
   - Workflows: Receives email notification, reviews NDA, signs electronically
   - Approval: N/A (external stakeholder)

**AI Agents:**

1. **NDA Generation Agent**
   - Responsibility: Selects appropriate template, populates fields, generates PDF
   - Tools: Template engine (Handlebars), PDF generator (Puppeteer), field validators
   - Autonomy: Fully autonomous for standard templates
   - Escalation: Legal Counsel approval required for custom clauses or >$1M deals

2. **Signature Orchestration Agent**
   - Responsibility: Manages e-signature workflow, sends reminders, tracks status
   - Tools: AdobeSign API, DocuSign API (fallback), email service (SendGrid)
   - Autonomy: Fully autonomous for standard reminder sequences
   - Escalation: Alerts Sales Director if unsigned after 7 days

3. **Compliance Verification Agent**
   - Responsibility: Validates NDA completeness, checks signatory authority, ensures legal compliance
   - Tools: Business registry APIs, LLM for clause analysis, compliance rule engine
   - Autonomy: Fully autonomous for standard compliance checks
   - Escalation: Legal Counsel review required for detected compliance risks

**Approval Workflows:**
1. NDA Generation (Standard Template) → Auto-approved and sent
2. NDA Generation (Custom Clauses) → Legal Counsel approval required before sending
3. NDA Generation (>$1M Deal) → Legal Counsel + VP Sales approval required
4. Signature Reminder → Auto-sent on Day 2, 5, 7; manual reminders require Sales Director approval

---

### 4. Pricing Model Generator Service

#### Objectives
- **Primary Purpose**: Automated generation of customized pricing proposals based on client use cases, tier selection, and financial cost modeling
- **Business Value**: Reduces pricing analysis from 8+ hours to <30 minutes, ensures margin consistency, enables dynamic pricing experiments
- **Scope Boundaries**:
  - **Does**: Calculate pricing tiers, incorporate Ashay's financial cost module, generate proposal PDFs, support A/B pricing tests
  - **Does Not**: Handle payment processing, manage subscriptions, provide financial advice

#### Requirements

**Functional Requirements:**
1. Generate pricing models from templatized structures based on use case complexity
2. Integrate Ashay's financial cost module (LLM costs, infrastructure, voice minutes)
3. Calculate pricing tiers (Starter, Professional, Enterprise) with margin targets
4. Support usage-based pricing (per conversation, per minute, per API call)
5. Include volume discounts and custom enterprise pricing
6. Generate pricing proposal documents (PDF, interactive web view)
7. Track pricing experiments and conversion rates

**Non-Functional Requirements:**
- Pricing calculation: <10 seconds including cost modeling
- Margin accuracy: ±2% of target margin (30-50% depending on tier)
- Support 1000+ concurrent pricing calculations
- Audit trail for all pricing decisions
- Support multi-currency (USD, EUR, GBP, INR)

**Dependencies:**
- NDA Generator (consumes nda_fully_signed event)
- PRD Builder (provides use case complexity for pricing)
- Financial Cost Module (Ashay's module for cost calculations)
- Proposal Generator (passes pricing data for inclusion)

**Data Storage:**
- PostgreSQL: Pricing models, tier definitions, experiments, conversion tracking
- Redis: Cached cost calculations, pricing rules
- S3: Pricing proposal PDFs

#### Features

**Must-Have:**
1. ✅ Template-based pricing model selection
2. ✅ Financial cost calculation integration (LLM, infra, voice)
3. ✅ Margin-based pricing with tier variations
4. ✅ Usage-based pricing calculators
5. ✅ Volume discount automation (>1000 conversations = 15% off)
6. ✅ Custom enterprise pricing workflows
7. ✅ Pricing proposal PDF generation
8. ✅ A/B pricing experiment framework

**Nice-to-Have:**
9. 🔄 Competitive pricing analysis (auto-fetch competitor pricing)
10. 🔄 Dynamic pricing based on market conditions
11. 🔄 Pricing optimization ML (recommend optimal price point)
12. 🔄 Multi-year contract discounting

**Feature Interactions:**
- Use case complexity from PRD → Determines base pricing tier
- Cost module integration → Ensures margin targets met
- Pricing approval → Triggers proposal generation

#### API Specification

**1. Generate Pricing Model**
```http
POST /api/v1/pricing/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "nda_id": "uuid",
  "use_case": {
    "type": "customer_support",
    "complexity": "medium",
    "expected_volume": {
      "conversations_per_month": 5000,
      "voice_minutes_per_month": 1200,
      "api_calls_per_month": 15000
    },
    "channels": ["webchat", "voice", "whatsapp"],
    "integrations": ["salesforce", "zendesk"],
    "custom_requirements": ["24/7_coverage", "multilingual"]
  },
  "pricing_strategy": "usage_based",
  "target_margin_percent": 40,
  "currency": "USD",
  "contract_term_months": 12,
  "include_setup_fee": true
}

Response (201 Created):
{
  "pricing_id": "uuid",
  "client_id": "uuid",
  "status": "generated",
  "cost_breakdown": {
    "llm_costs_monthly": 850.00,
    "infrastructure_monthly": 320.00,
    "voice_costs_monthly": 84.00,
    "integration_costs_monthly": 45.00,
    "total_cost_monthly": 1299.00
  },
  "pricing_tiers": [
    {
      "tier": "starter",
      "monthly_price": 1999.00,
      "margin_percent": 35.0,
      "included_volume": {
        "conversations": 3000,
        "voice_minutes": 800,
        "api_calls": 10000
      },
      "overage_pricing": {
        "per_conversation": 0.50,
        "per_voice_minute": 0.12,
        "per_api_call": 0.02
      }
    },
    {
      "tier": "professional",
      "monthly_price": 3499.00,
      "margin_percent": 40.0,
      "included_volume": {
        "conversations": 5000,
        "voice_minutes": 1200,
        "api_calls": 15000
      },
      "overage_pricing": {
        "per_conversation": 0.45,
        "per_voice_minute": 0.10,
        "per_api_call": 0.018
      },
      "additional_features": ["priority_support", "custom_branding"]
    },
    {
      "tier": "enterprise",
      "monthly_price": 6999.00,
      "margin_percent": 45.0,
      "included_volume": {
        "conversations": 10000,
        "voice_minutes": 3000,
        "api_calls": 30000
      },
      "overage_pricing": {
        "per_conversation": 0.40,
        "per_voice_minute": 0.08,
        "per_api_call": 0.015
      },
      "additional_features": ["dedicated_support", "sla_99.9", "custom_integrations", "white_label"]
    }
  ],
  "setup_fee": 2500.00,
  "volume_discounts": [
    {"threshold": 1000, "discount_percent": 15},
    {"threshold": 5000, "discount_percent": 25}
  ],
  "annual_contract_discount_percent": 10,
  "proposal_url": "https://storage.workflow.com/pricing/acme-pricing-2025-10-08.pdf",
  "created_at": "2025-10-08T10:30:00Z"
}

Error Responses:
400 Bad Request: Invalid use_case or missing required volume data
422 Unprocessable Entity: Cannot achieve target margin with given constraints
424 Failed Dependency: Financial cost module unavailable
```

**2. Get Pricing Model**
```http
GET /api/v1/pricing/{pricing_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "pricing_id": "uuid",
  "client_id": "uuid",
  "status": "approved",
  "cost_breakdown": {...},
  "pricing_tiers": [...],
  "selected_tier": "professional",
  "final_monthly_price": 3149.10,
  "discounts_applied": [
    {"type": "annual_contract", "discount_percent": 10, "savings": 349.90}
  ],
  "contract_value_annual": 37789.20,
  "margin_actual_percent": 41.2,
  "approved_by": "uuid",
  "approved_at": "2025-10-09T14:00:00Z",
  "created_at": "2025-10-08T10:30:00Z",
  "updated_at": "2025-10-09T14:00:00Z"
}
```

**3. Update Pricing Model**
```http
PATCH /api/v1/pricing/{pricing_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "adjust_margin_percent": 35,
  "apply_custom_discount_percent": 5,
  "custom_discount_reason": "Early adopter incentive",
  "update_volume": {
    "conversations_per_month": 7000
  }
}

Response (200 OK):
{
  "pricing_id": "uuid",
  "status": "updated",
  "recalculation_triggered": true,
  "new_cost_breakdown": {...},
  "new_pricing_tiers": [...],
  "version": 2,
  "updated_at": "2025-10-09T10:00:00Z"
}
```

**4. Create Pricing Experiment**
```http
POST /api/v1/pricing/experiments
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "experiment_name": "Professional Tier Price Test",
  "description": "Test $3499 vs $2999 for professional tier",
  "variants": [
    {
      "variant_id": "control",
      "tier": "professional",
      "monthly_price": 3499.00,
      "traffic_percent": 50
    },
    {
      "variant_id": "treatment",
      "tier": "professional",
      "monthly_price": 2999.00,
      "traffic_percent": 50
    }
  ],
  "target_metric": "conversion_rate",
  "duration_days": 30,
  "min_sample_size": 100
}

Response (201 Created):
{
  "experiment_id": "uuid",
  "status": "active",
  "started_at": "2025-10-09T15:00:00Z",
  "estimated_completion": "2025-11-08T15:00:00Z",
  "tracking_url": "https://analytics.workflow.com/experiments/uuid"
}
```

**5. Get Pricing Experiment Results**
```http
GET /api/v1/pricing/experiments/{experiment_id}/results
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "experiment_id": "uuid",
  "status": "completed",
  "duration_days": 30,
  "results": {
    "control": {
      "variant_id": "control",
      "impressions": 547,
      "conversions": 76,
      "conversion_rate": 13.9,
      "avg_deal_size": 41988.00,
      "total_revenue": 3191088.00
    },
    "treatment": {
      "variant_id": "treatment",
      "impressions": 553,
      "conversions": 94,
      "conversion_rate": 17.0,
      "avg_deal_size": 35988.00,
      "total_revenue": 3382872.00
    }
  },
  "statistical_significance": {
    "p_value": 0.032,
    "confidence_level": 95,
    "significant": true
  },
  "recommendation": {
    "winning_variant": "treatment",
    "reason": "17% higher conversion rate with acceptable revenue trade-off",
    "estimated_annual_impact": "+$2.3M revenue"
  },
  "completed_at": "2025-11-08T15:00:00Z"
}
```

**6. Calculate Custom Enterprise Pricing**
```http
POST /api/v1/pricing/enterprise/calculate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "custom_requirements": {
    "conversations_per_month": 50000,
    "voice_minutes_per_month": 15000,
    "dedicated_infrastructure": true,
    "sla_target": 99.99,
    "custom_integrations": ["sap", "oracle", "custom_crm"],
    "white_label": true,
    "dedicated_support_team_size": 3
  },
  "target_margin_percent": 50,
  "contract_term_months": 36
}

Response (200 OK):
{
  "pricing_id": "uuid",
  "tier": "enterprise_custom",
  "cost_breakdown": {
    "llm_costs_monthly": 8500.00,
    "infrastructure_monthly": 12000.00,
    "voice_costs_monthly": 1350.00,
    "integration_costs_monthly": 2500.00,
    "support_team_monthly": 15000.00,
    "total_cost_monthly": 39350.00
  },
  "recommended_monthly_price": 78700.00,
  "margin_actual_percent": 50.0,
  "annual_contract_value": 944400.00,
  "setup_fee": 50000.00,
  "volume_discounts": [
    {"threshold": 50000, "discount_percent": 20}
  ],
  "final_monthly_price": 62960.00,
  "final_annual_value": 755520.00,
  "requires_approval": true,
  "approval_workflow": ["sales_vp", "cfo", "ceo"]
}
```

**Rate Limiting:**
- 100 pricing calculations per hour per tenant
- 10 pricing experiments per month per tenant
- 1000 API requests per minute per tenant

#### Frontend Components

**1. Pricing Calculator**
- Component: `PricingCalculator.tsx`
- Features:
  - Interactive sliders for volume inputs
  - Real-time cost breakdown visualization
  - Tier comparison table
  - Margin % adjuster with live recalculation
  - Currency selector
  - Volume discount preview

**2. Pricing Proposal Builder**
- Component: `PricingProposalBuilder.tsx`
- Features:
  - Drag-and-drop proposal sections
  - Live PDF preview
  - Custom discount application
  - Payment terms configurator (monthly, annual, quarterly)
  - ROI calculator for client
  - Approval workflow status

**3. Pricing Experiment Dashboard**
- Component: `PricingExperimentDashboard.tsx`
- Features:
  - Experiment list (active, completed, archived)
  - Real-time conversion tracking
  - Statistical significance calculator
  - Winner declaration with recommendation
  - Variant performance charts
  - Export results to CSV/PDF

**4. Financial Cost Module Integration**
- Component: `FinancialCostModule.tsx`
- Features:
  - Cost driver inputs (LLM calls, voice minutes, infra resources)
  - Cost trend visualization (historical)
  - Cost optimization suggestions
  - Budget vs actual tracking
  - Alert configuration for cost overruns

**5. Enterprise Pricing Workflow**
- Component: `EnterprisePricingWorkflow.tsx`
- Features:
  - Multi-step custom pricing form
  - Approval pipeline visualization (pending, approved, rejected)
  - Negotiation history log
  - Contract terms builder
  - Digital signature integration

**State Management:**
- Zustand for pricing calculator state
- React Query for API data fetching and caching
- Form state with React Hook Form and Zod validation
- Real-time updates via Server-Sent Events

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Engineer**
   - Role: Configures pricing models, presents to clients
   - Access: Create and update pricing models for assigned clients
   - Permissions: create:pricing, read:pricing, update:pricing
   - Workflows: Inputs use case details, reviews generated pricing, applies discounts, seeks approvals

2. **Finance Manager (Ashay's Role)**
   - Role: Manages financial cost module, approves margin adjustments
   - Access: Full access to cost models and pricing configurations
   - Permissions: admin:cost_module, approve:margin_adjustment, read:all_pricing
   - Workflows: Updates cost assumptions, reviews margin targets, approves custom discounts >10%

3. **VP Sales**
   - Role: Approves enterprise pricing and experiments
   - Access: Read-only on all pricing, approval rights for >$500K deals
   - Permissions: read:all_pricing, approve:enterprise_pricing, manage:experiments
   - Workflows: Reviews custom enterprise pricing, approves pricing experiments, monitors conversion rates

4. **Client (Indirect Stakeholder)**
   - Role: Reviews and negotiates pricing proposal
   - Access: Read-only access to assigned pricing proposal
   - Permissions: read:assigned_pricing
   - Workflows: Receives pricing proposal, provides feedback, negotiates terms
   - Approval: N/A (external stakeholder)

**AI Agents:**

1. **Pricing Generation Agent**
   - Responsibility: Calculates optimal pricing tiers, applies templates, ensures margin targets
   - Tools: Financial cost module API, pricing rule engine, margin calculators
   - Autonomy: Fully autonomous for standard use cases with predefined margins
   - Escalation: Finance Manager approval required for margins <30% or custom cost assumptions

2. **Discount Optimization Agent**
   - Responsibility: Recommends volume discounts, analyzes competitive pricing, suggests promotions
   - Tools: Market data APIs, historical conversion data, LLM for competitive analysis
   - Autonomy: Auto-applies standard discounts (volume, annual contract)
   - Escalation: VP Sales approval required for custom discounts >10%

3. **Experiment Analysis Agent**
   - Responsibility: Monitors pricing experiments, calculates statistical significance, recommends winners
   - Tools: Statistical libraries (scipy), A/B test frameworks, revenue impact models
   - Autonomy: Fully autonomous for analysis and recommendations
   - Escalation: Alerts VP Sales when experiments reach significance, recommends rollout strategy

**Approval Workflows:**
1. Standard Pricing Model → Auto-approved if margin ≥30%, Finance Manager approval if <30%
2. Custom Discount >10% → VP Sales approval required
3. Enterprise Pricing (>$500K ACV) → VP Sales + CFO approval required
4. Pricing Experiment Launch → VP Sales approval required
5. Experiment Winner Rollout → Auto-approved if statistically significant at 95% confidence

---

### 5. Proposal & Agreement Draft Generator Service

#### Objectives
- **Primary Purpose**: AI-powered generation of comprehensive proposals and legal agreements with interactive editing capabilities
- **Business Value**: Reduces proposal creation from 10+ hours to <1 hour, ensures consistency, enables real-time collaboration
- **Scope Boundaries**:
  - **Does**: Generate proposals/agreements from templates, provide webchat UI for feedback-driven iteration, enable manual canvas editing, version control, e-signature integration
  - **Does Not**: Provide legal advice, handle complex contract negotiations beyond standard terms, replace legal review

#### Requirements

**Functional Requirements:**
1. Generate proposals/agreements from templates based on PRD and pricing data
2. Provide webchat UI for conversational editing ("make payment terms NET-30")
3. Enable manual editing in side-by-side canvas (WYSIWYG editor)
4. Version control with change tracking and rollback
5. Collaborative editing with real-time updates
6. Export to PDF, DOCX, Google Docs
7. E-signature integration for final agreement
8. Template library management (legal-approved templates)

**Non-Functional Requirements:**
- Generation time: <3 minutes for standard proposal
- Real-time collaboration: Support 5 concurrent editors
- 99.9% uptime during business hours
- Auto-save every 30 seconds
- Support documents up to 50 pages

**Dependencies:**
- Pricing Model Generator (provides pricing data)
- PRD Builder (provides technical requirements for proposal)
- NDA Generator (e-signature integration reuse)
- Configuration Management (proposal templates)

**Data Storage:**
- PostgreSQL: Proposal metadata, versions, collaboration sessions, approval status
- S3: Proposal documents (PDF, DOCX), version snapshots
- Redis: Real-time collaboration state (active editors, cursor positions)

#### Features

**Must-Have:**
1. ✅ Template-based proposal generation (SOW, MSA, Service Agreement)
2. ✅ Webchat UI for conversational editing
3. ✅ Side-by-side canvas editor (Quill/TipTap)
4. ✅ Version control with diff viewer
5. ✅ Real-time collaborative editing (Yjs/CRDT)
6. ✅ Export to multiple formats (PDF, DOCX, Google Docs)
7. ✅ E-signature workflow integration
8. ✅ Comment threads on sections

**Nice-to-Have:**
9. 🔄 AI-powered clause suggestions based on industry
10. 🔄 Redlining and track changes mode
11. 🔄 Smart templates with conditional logic
12. 🔄 Integration with legal review platforms (LegalSifter)

**Feature Interactions:**
- Pricing approval → Auto-populates proposal pricing section
- PRD completion → Auto-populates technical scope section
- Proposal finalization → Triggers e-signature workflow

#### API Specification

**1. Generate Proposal**
```http
POST /api/v1/proposals/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "pricing_id": "uuid",
  "prd_id": "uuid",
  "template_id": "saas_sow_v2",
  "proposal_type": "statement_of_work",
  "custom_sections": [
    {
      "title": "Implementation Timeline",
      "content": "12-week phased rollout with weekly milestones"
    }
  ],
  "include_attachments": ["technical_architecture.pdf", "pricing_breakdown.pdf"],
  "language": "en-US"
}

Response (201 Created):
{
  "proposal_id": "uuid",
  "client_id": "uuid",
  "status": "draft",
  "document_url": "https://proposals.workflow.com/acme-sow-2025-10-09",
  "edit_url": "https://proposals.workflow.com/edit/uuid",
  "webchat_url": "https://proposals.workflow.com/chat/uuid",
  "version": 1,
  "sections": [
    {
      "section_id": "uuid",
      "title": "Executive Summary",
      "content": "This Statement of Work outlines...",
      "editable": true
    },
    {
      "section_id": "uuid",
      "title": "Scope of Services",
      "content": "Workflow Automation will provide...",
      "editable": true
    },
    {
      "section_id": "uuid",
      "title": "Pricing",
      "content": "Monthly Fee: $3,499...",
      "editable": false,
      "source": "pricing_model"
    },
    {
      "section_id": "uuid",
      "title": "Implementation Timeline",
      "content": "12-week phased rollout...",
      "editable": true
    }
  ],
  "created_at": "2025-10-09T11:00:00Z"
}

Error Responses:
400 Bad Request: Invalid template_id or missing dependencies
422 Unprocessable Entity: Pricing or PRD data incomplete
```

**2. Update Proposal via Webchat**
```http
POST /api/v1/proposals/{proposal_id}/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "Change payment terms to NET-30 and add a clause about data retention for 90 days",
  "session_id": "uuid"
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "chat_response": "I've updated the payment terms to NET-30 in Section 5. I've also added a new clause in Section 8 (Data Management) specifying that data will be retained for 90 days after contract termination. Would you like to review these changes?",
  "changes_made": [
    {
      "section_id": "uuid",
      "section_title": "Payment Terms",
      "change_type": "content_update",
      "old_content": "Payment is due NET-15...",
      "new_content": "Payment is due NET-30...",
      "diff_url": "https://proposals.workflow.com/diff/uuid/v1-v2"
    },
    {
      "section_id": "uuid",
      "section_title": "Data Management",
      "change_type": "clause_added",
      "new_content": "Data Retention: All client data will be retained for 90 days following contract termination..."
    }
  ],
  "version": 2,
  "requires_approval": true,
  "approval_reason": "Legal review required for payment term changes"
}
```

**3. Update Proposal via Canvas**
```http
PATCH /api/v1/proposals/{proposal_id}/sections/{section_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "content": "<p>Updated content with <strong>formatting</strong></p>",
  "editor_id": "uuid",
  "session_id": "uuid"
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "section_id": "uuid",
  "version": 3,
  "updated_at": "2025-10-09T11:30:00Z",
  "updated_by": "uuid",
  "auto_saved": true
}

WebSocket Broadcast to Collaborators:
{
  "event": "section_updated",
  "proposal_id": "uuid",
  "section_id": "uuid",
  "editor_id": "uuid",
  "editor_name": "John Smith",
  "content": "<p>Updated content...</p>",
  "cursor_position": 145
}
```

**4. Get Proposal Versions**
```http
GET /api/v1/proposals/{proposal_id}/versions
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "proposal_id": "uuid",
  "current_version": 3,
  "versions": [
    {
      "version": 1,
      "created_at": "2025-10-09T11:00:00Z",
      "created_by": "system",
      "change_summary": "Initial generation from template",
      "document_url": "https://storage.workflow.com/proposals/uuid/v1.pdf"
    },
    {
      "version": 2,
      "created_at": "2025-10-09T11:15:00Z",
      "created_by": "uuid",
      "change_summary": "Updated payment terms to NET-30, added data retention clause",
      "document_url": "https://storage.workflow.com/proposals/uuid/v2.pdf",
      "changes_count": 2
    },
    {
      "version": 3,
      "created_at": "2025-10-09T11:30:00Z",
      "created_by": "uuid",
      "change_summary": "Manual edit to Section 4",
      "document_url": "https://storage.workflow.com/proposals/uuid/v3.pdf",
      "changes_count": 1
    }
  ]
}
```

**5. Finalize and Send Proposal**
```http
POST /api/v1/proposals/{proposal_id}/finalize
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "send_to": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "role": "CEO"
    }
  ],
  "message": "Please review and sign the attached proposal for our AI automation pilot.",
  "enable_esignature": true,
  "signature_workflow": "sequential"
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "status": "sent",
  "final_version": 3,
  "sent_at": "2025-10-09T12:00:00Z",
  "recipients": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "status": "sent",
      "view_url": "https://proposals.workflow.com/view/uuid?token=xyz",
      "signature_url": "https://adobesign.com/sign/abc123"
    }
  ],
  "esignature_workflow_id": "adobesign_xyz456"
}

Event Published to Kafka:
Topic: proposal_events
{
  "event_type": "proposal_sent",
  "proposal_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-09T12:00:00Z"
}
```

**6. Add Comment to Section**
```http
POST /api/v1/proposals/{proposal_id}/sections/{section_id}/comments
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "comment": "Legal team: This clause needs review before client sees it",
  "commenter_id": "uuid",
  "resolve_required": true,
  "visibility": "internal"
}

Response (201 Created):
{
  "comment_id": "uuid",
  "section_id": "uuid",
  "commenter": {
    "id": "uuid",
    "name": "Sarah Johnson",
    "role": "Legal Counsel"
  },
  "comment": "Legal team: This clause needs review...",
  "status": "open",
  "created_at": "2025-10-09T11:45:00Z"
}

WebSocket Broadcast to Collaborators:
{
  "event": "comment_added",
  "proposal_id": "uuid",
  "section_id": "uuid",
  "comment_id": "uuid",
  "commenter_name": "Sarah Johnson",
  "visibility": "internal"
}
```

**7. Export Proposal**
```http
GET /api/v1/proposals/{proposal_id}/export?format=pdf&version=3
Authorization: Bearer {jwt_token}

Response (200 OK):
Binary PDF content

Headers:
Content-Type: application/pdf
Content-Disposition: attachment; filename="acme-proposal-2025-10-09-v3.pdf"
X-Proposal-Version: 3
X-Generated-At: 2025-10-09T12:05:00Z

Alternative Formats:
?format=docx → Microsoft Word
?format=gdoc → Google Docs (returns shareable link)
```

**8. WebSocket - Real-Time Collaboration**
```
wss://proposals.workflow.com/ws/{proposal_id}
Authorization: Bearer {jwt_token}

Server → Client Events:
{
  "event": "editor_joined",
  "editor_id": "uuid",
  "editor_name": "Alice Cooper",
  "cursor_position": null
}

{
  "event": "cursor_moved",
  "editor_id": "uuid",
  "section_id": "uuid",
  "cursor_position": 247
}

{
  "event": "content_changed",
  "section_id": "uuid",
  "editor_id": "uuid",
  "changes": "CRDT operations...",
  "version": 4
}

Client → Server Events:
{
  "action": "update_cursor",
  "section_id": "uuid",
  "cursor_position": 150
}

{
  "action": "edit_content",
  "section_id": "uuid",
  "operations": "CRDT operations..."
}
```

**Rate Limiting:**
- 20 proposal generations per hour per tenant
- 500 chat messages per hour per proposal
- 100 section updates per minute per proposal
- 1000 API requests per minute per tenant

#### Frontend Components

**1. Proposal Generation Wizard**
- Component: `ProposalGenerationWizard.tsx`
- Features:
  - Template selector with preview
  - Auto-populated data from PRD and Pricing
  - Custom section builder
  - Attachment uploader
  - Preview before generation

**2. Proposal Editor (Split View)**
- Component: `ProposalEditor.tsx`
- Features:
  - Left: Webchat UI for conversational editing
  - Right: Canvas editor (TipTap WYSIWYG)
  - Section navigation sidebar
  - Real-time collaboration indicators (avatars, cursors)
  - Comment panel (expandable)
  - Version selector dropdown

**3. Webchat Interface**
- Component: `ProposalWebchat.tsx`
- Features:
  - Chat history with agent responses
  - Quick action buttons ("Add section", "Change format", "Export")
  - Suggested edits visualization
  - Diff preview before applying changes
  - Undo/redo chat-based changes

**4. Collaboration Panel**
- Component: `CollaborationPanel.tsx`
- Features:
  - Active editors list with real-time status
  - Comment threads (resolved, open, all)
  - Change activity feed
  - @mention functionality
  - Notification preferences

**5. Version History Viewer**
- Component: `VersionHistoryViewer.tsx`
- Features:
  - Timeline visualization
  - Side-by-side diff viewer
  - Rollback to previous version
  - Export specific version
  - Change attribution (who changed what)

**6. Signature Workflow Dashboard**
- Component: `SignatureWorkflowDashboard.tsx`
- Features:
  - Recipient status tracking
  - Embedded e-signature iframe
  - Reminder sending
  - Audit trail
  - Download signed document

**State Management:**
- Yjs CRDT for real-time collaborative editing
- Redux Toolkit for proposal metadata and UI state
- React Query for API data fetching
- WebSocket integration for real-time updates
- IndexedDB for offline draft support

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Engineer**
   - Role: Generates and edits proposals, coordinates with client
   - Access: Full CRUD on proposals for assigned clients
   - Permissions: create:proposal, read:proposal, update:proposal, send:proposal
   - Workflows: Generates proposal, iterates via webchat, finalizes, sends to client

2. **Legal Counsel**
   - Role: Reviews and approves legal clauses, manages templates
   - Access: Read-only on active proposals, admin access to templates
   - Permissions: read:all_proposals, approve:legal_clauses, admin:templates
   - Workflows: Reviews flagged clauses, comments on sections, approves custom terms
   - Approval: Required for custom clauses, payment term changes, liability modifications

3. **Client Stakeholder**
   - Role: Reviews proposal, requests edits, signs agreement
   - Access: Read-only access to assigned proposal, commenting capability
   - Permissions: read:assigned_proposal, comment:proposal, sign:proposal
   - Workflows: Receives proposal, reviews content, requests changes via comments, signs electronically
   - Approval: N/A (external stakeholder)

4. **Finance Manager**
   - Role: Reviews pricing sections, approves payment terms
   - Access: Read-only on proposals, approval rights for pricing/payment changes
   - Permissions: read:all_proposals, approve:pricing_changes
   - Workflows: Reviews pricing accuracy, approves custom payment terms

**AI Agents:**

1. **Proposal Generation Agent**
   - Responsibility: Generates initial proposal from templates, populates data from PRD/Pricing
   - Tools: Template engine (Handlebars), PDF generator, content assemblers
   - Autonomy: Fully autonomous for standard templates
   - Escalation: Legal Counsel approval for custom templates or non-standard clauses

2. **Conversational Editor Agent**
   - Responsibility: Interprets webchat commands, applies edits, suggests improvements
   - Tools: LLM (GPT-4), document manipulation APIs, diff generators
   - Autonomy: Fully autonomous for content edits, formatting changes
   - Escalation: Legal Counsel approval required for liability clauses, payment terms, SLA modifications

3. **Clause Recommendation Agent**
   - Responsibility: Suggests relevant clauses based on industry, deal size, risk profile
   - Tools: LLM with legal knowledge base, clause library, risk assessment models
   - Autonomy: Provides suggestions only, no auto-application
   - Escalation: Legal Counsel review required before adding suggested clauses

4. **Version Control Agent**
   - Responsibility: Tracks changes, manages versions, alerts on conflicts
   - Tools: Git-like diff algorithms, CRDT conflict resolution, notification system
   - Autonomy: Fully autonomous
   - Escalation: Alerts editors on merge conflicts requiring manual resolution

**Approval Workflows:**
1. Proposal Generation (Standard Template) → Auto-approved
2. Proposal Generation (Custom Template) → Legal Counsel approval required
3. Legal Clause Modifications → Legal Counsel approval required
4. Payment Term Changes → Finance Manager approval required
5. Pricing Section Edits → Finance Manager approval required
6. Proposal Finalization (>$500K Deal) → VP Sales approval required
7. Client-Requested Changes (Legal Impact) → Legal Counsel approval required

---

*Due to length constraints, I will continue with the remaining 10 microservices in the next response. This comprehensive specification will be complete in a follow-up document.*

**Remaining Microservices to Detail:**
6. PRD Builder Engine Service
7. Automation Engine Service
8. Agent Orchestration Service
9. Voice Agent Service
10. Configuration Management Service
11. Monitoring Engine Service
12. Analytics Service
13. Customer Success Service
14. Support Engine Service
15. CRM Integration Service

---
