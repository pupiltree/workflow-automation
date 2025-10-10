# Comprehensive Sprint-by-Sprint Implementation Plan
## AI-Powered Workflow Automation Platform

**Document Version:** 1.0
**Last Updated:** 2025-10-10
**Planning Horizon:** 32 weeks (8 weeks @ 1-week sprints + 24 weeks @ 2-week sprints)
**Total Sprints:** 20 sprints
**Target:** Complete end-to-end workflow automation platform with 95% automation capability

---

## Executive Summary

### Project Overview
This plan delivers a complete microservices-based workflow automation platform featuring:
- **17 specialized microservices** + 2 supporting libraries
- **23 Kafka topics** for event-driven orchestration
- **Dual runtime engines:** LangGraph (chatbot) + LiveKit (voicebot)
- **95% automation target** within 12 months post-deployment
- **3x agent productivity** increase via AI-powered Agent Copilot

### Timeline & Methodology
- **Total Duration:** 32 weeks (8 months)
- **Sprint Structure:**
  - Sprints 1-8: 1-week sprints (foundation & high uncertainty)
  - Sprints 9-20: 2-week sprints (feature delivery & optimization)
- **Methodology:** Agile Scrum with AI-assisted development
- **Velocity:** Conservative start (30% capacity Sprint 1), ramping to baseline by Sprint 3

### AI Productivity Strategy
- **Well-defined implementation tasks:** 1.25-1.55x productivity multiplier
- **Boilerplate/scaffolding:** 2-4x productivity multiplier
- **Complex problem-solving:** 0.8-1.0x (AI may slow experienced developers)
- **Strategic AI use:** Boilerplate generation, test scaffolding, documentation, NOT architecture decisions
- **Overall timeline impact:** 10-20% acceleration (40 weeks → 32 weeks)

### Key Milestones
- **Week 4:** Foundation complete (CI/CD, infrastructure, Service 0)
- **Week 8:** Core services operational (Services 1-3, basic chatbot)
- **Week 16:** Full runtime platform (Services 8-9, monitoring, analytics)
- **Week 24:** Production-ready system (security hardening, performance optimization)
- **Week 32:** Complete end-to-end workflow automation with all 17 services

---

## Table of Contents

1. [Overall Roadmap](#overall-roadmap)
2. [Technology Stack & Architecture Decisions](#technology-stack--architecture-decisions)
3. [Team Structure & Skills Matrix](#team-structure--skills-matrix)
4. [Sprint-by-Sprint Plans](#sprint-by-sprint-plans)
   - Foundation Phase (Sprints 1-4)
   - Core Services Phase (Sprints 5-8)
   - Integration Phase (Sprints 9-12)
   - Feature Delivery Phase (Sprints 13-16)
   - Optimization Phase (Sprints 17-20)
5. [Testing Strategy](#testing-strategy)
6. [DevOps & Deployment](#devops--deployment)
7. [Risk Management](#risk-management)
8. [Quality Assurance](#quality-assurance)

---

## Overall Roadmap

### Epic Breakdown

#### Epic 1: Foundation Infrastructure (Sprints 1-4, Weeks 1-4)
**Goal:** Establish development environment, CI/CD pipelines, and foundational services

**Services Delivered:**
- Service 0: Organization & Identity Management
- @workflow/llm-sdk library (foundation)
- @workflow/config-sdk library (foundation)

**Infrastructure:**
- Kubernetes cluster setup
- PostgreSQL with RLS
- Redis cluster
- Kafka cluster (3 brokers)
- Kong API Gateway
- CI/CD pipeline (GitHub Actions + Argo CD)
- Monitoring stack (Prometheus, Grafana, Jaeger)

**Key Deliverables:**
- Working auth system with JWT
- Multi-tenant data isolation
- Automated deployment pipeline
- Developer documentation

---

#### Epic 2: Pre-Sales Workflow (Sprints 5-8, Weeks 5-8)
**Goal:** Automate research, demo generation, and sales document workflow

**Services Delivered:**
- Service 1: Research Engine
- Service 2: Demo Generator
- Service 3: Sales Document Generator
- Service 22: Billing & Revenue Management

**Key Kafka Topics:**
- `auth_events`, `client_events`, `research_events`, `demo_events`, `sales_doc_events`, `billing_events`

**Key Deliverables:**
- Automated market research pipeline
- AI-powered demo generator (basic)
- NDA/proposal generation with e-signature
- Subscription management

---

#### Epic 3: Implementation & Configuration (Sprints 9-12, Weeks 9-16)
**Goal:** Build PRD generation, config management, and automation engine

**Services Delivered:**
- Service 6: PRD Builder & Configuration Workspace
- Service 7: Automation Engine
- Service 17: RAG Pipeline

**Key Kafka Topics:**
- `prd_events`, `collaboration_events`, `config_events`, `rag_events`

**Key Deliverables:**
- AI-powered PRD generation with village knowledge
- JSON config generation from PRD
- RAG pipeline with Qdrant + Neo4j
- Client self-service portal

---

#### Epic 4: Runtime Engines & Monitoring (Sprints 13-16, Weeks 17-24)
**Goal:** Deploy chatbot/voicebot runtime with monitoring and analytics

**Services Delivered:**
- Service 8: Agent Orchestration (Chatbot)
- Service 9: Voice Agent (Voicebot)
- Service 11: Monitoring Engine
- Service 12: Analytics

**Key Kafka Topics:**
- `conversation_events`, `voice_events`, `cross_product_events`, `monitoring_incidents`, `analytics_experiments`

**Key Deliverables:**
- LangGraph-based chatbot runtime
- LiveKit-based voicebot runtime
- Real-time monitoring and alerting
- Analytics dashboards

---

#### Epic 5: Customer Lifecycle & Agent Copilot (Sprints 17-20, Weeks 25-32)
**Goal:** Complete customer success, support, and agent productivity tools

**Services Delivered:**
- Service 13: Customer Success
- Service 14: Support Engine
- Service 15: CRM Integration
- Service 20: Communication & Hyperpersonalization
- Service 21: Agent Copilot

**Key Kafka Topics:**
- `customer_success_events`, `support_events`, `escalation_events`, `communication_events`, `agent_action_events`, `crm_events`

**Key Deliverables:**
- Automated customer health scoring
- AI-powered support ticket resolution
- CRM bidirectional sync
- Multi-armed bandit A/B testing
- Agent copilot dashboard aggregating 21 Kafka topics

---

### MVP Identification

**Minimum Viable Product (Week 16):**
- ✅ Service 0 (Auth & Identity)
- ✅ Service 1 (Research Engine)
- ✅ Service 2 (Demo Generator - basic)
- ✅ Service 3 (Sales Document Generator)
- ✅ Service 6 (PRD Builder - basic)
- ✅ Service 7 (Automation Engine)
- ✅ Service 8 (Agent Orchestration - basic chatbot)
- ✅ @workflow/llm-sdk (LLM integration)
- ✅ @workflow/config-sdk (Config management)
- ✅ Basic monitoring (Service 11)

**MVP Capabilities:**
- End-to-end workflow: Client signup → Research → Demo → NDA → PRD → Config → Chatbot deployment
- 60% automation for research/onboarding phases
- Manual handoffs for complex scenarios
- Basic monitoring and alerting

**Post-MVP Enhancements (Weeks 17-32):**
- Voice agent (Service 9)
- Advanced analytics (Service 12)
- Customer success automation (Service 13)
- Support automation (Service 14)
- CRM integration (Service 15)
- Hyperpersonalization (Service 20)
- Agent copilot (Service 21)
- Advanced monitoring and optimization

---

### Release Planning

#### Alpha Release (Week 8)
**Services:** 0, 1, 2, 3, 22 + @workflow/llm-sdk + @workflow/config-sdk
**Capabilities:** Pre-sales workflow automation (research → demo → sales docs)
**Target Audience:** Internal testing team
**Success Criteria:** Complete 5 end-to-end test scenarios

#### Beta Release (Week 16 - MVP)
**Services:** Alpha + 6, 7, 8, 11, 17
**Capabilities:** Full workflow through chatbot deployment
**Target Audience:** 3-5 pilot customers
**Success Criteria:** Deploy 3 production chatbots, <2s response time P95

#### Production Release v1.0 (Week 24)
**Services:** Beta + 9, 12
**Capabilities:** Chatbot + Voicebot with analytics
**Target Audience:** General availability (first 50 customers)
**Success Criteria:** 99.9% uptime, <500ms voice latency P95

#### Production Release v2.0 (Week 32)
**Services:** All 17 services
**Capabilities:** Complete platform with agent copilot
**Target Audience:** Unrestricted customer acquisition
**Success Criteria:** 95% automation, 3x agent productivity, 80% cost reduction

---

## Technology Stack & Architecture Decisions

### Core Technology Choices

#### 1. Service Mesh: **Linkerd** (chosen over Istio)
**Rationale:**
- **163ms faster** at 99th percentile latency (critical for <500ms voice target)
- **90% less resource usage** (CPU/memory)
- Simpler operational model
- Better fit for your latency-sensitive workloads

**Implementation:**
- Deploy Linkerd control plane in Sprint 2
- Mesh Services 8-9 (runtime) in Sprint 13
- Mesh remaining services progressively

#### 2. Multi-Tenancy: **Shared Schema + PostgreSQL RLS**
**Rationale:**
- Balance of scalability, cost, and isolation
- `tenant_id` on every table, enforced at database level
- Supports 0-5000 tenants efficiently
- Clear upgrade path to dedicated schemas (Citus sharding) for Tier 2

**Implementation:**
- RLS policies from Sprint 1 (Service 0)
- Automated tenant isolation tests on every endpoint
- Namespace-per-tenant in Qdrant/Neo4j

#### 3. CI/CD: **GitOps with Argo CD**
**Rationale:**
- Git as single source of truth
- Declarative infrastructure
- Automated sync and rollback
- Best-in-class UI for observability

**Implementation:**
- GitHub Actions for CI (build, test, scan)
- Argo CD for CD (deploy to Kubernetes)
- Helm charts for service packaging

#### 4. Secrets Management: **External Secrets Operator + AWS Secrets Manager**
**Rationale:**
- No secrets in Git or environment variables
- Automatic secret rotation
- Kubernetes-native with CRDs
- Integrates with cloud provider IAM

**Implementation:**
- Deploy External Secrets Operator in Sprint 1
- AWS Secrets Manager for secret storage
- Separate secrets per environment (dev, staging, prod)

#### 5. Observability: **OpenTelemetry + Jaeger + Prometheus + Grafana**
**Rationale:**
- OpenTelemetry: Vendor-neutral standard, future-proof
- Jaeger: Distributed tracing for debugging latency
- Prometheus: Metrics collection and alerting
- Grafana: Unified visualization

**Implementation:**
- Deploy monitoring stack in Sprint 2
- Instrument services progressively
- Custom dashboards per service

---

### Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Kong API Gateway                            │
│              Authentication • Rate Limiting • Routing            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Linkerd Service Mesh                          │
│              mTLS • Load Balancing • Circuit Breaking            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                 ┌───────────┴──────────┐
                 │                      │
                 ▼                      ▼
┌──────────────────────────┐  ┌──────────────────────────┐
│   Microservices Layer    │  │  Supporting Libraries    │
│  (17 Services in K8s)    │  │  (@workflow/* packages)  │
└──────────────────────────┘  └──────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Event Bus (Apache Kafka)                    │
│                    23 Topics • 3 Brokers                         │
└─────────────────────────────────────────────────────────────────┘
                 │
      ┌──────────┴──────────┬──────────────────┐
      ▼                     ▼                   ▼
┌──────────────┐  ┌──────────────────┐  ┌────────────────┐
│ PostgreSQL   │  │ Redis Cluster    │  │ Qdrant + Neo4j │
│ (Supabase)   │  │ (Cache + Queue)  │  │ (Vector + Grap│
│ RLS enforced │  │                  │  │                │
└──────────────┘  └──────────────────┘  └────────────────┘
```

---

## Team Structure & Skills Matrix

### Recommended Team Composition

#### Core Development Team (6-8 developers)

**Backend Engineers (3-4)**
- **Skills Required:** Python (FastAPI, LangGraph), PostgreSQL, Kafka, microservices patterns
- **AI Productivity Profile:** High (1.4-1.55x on implementation tasks)
- **Responsibilities:**
  - Implement services 0-3, 6-7, 11-15, 20-22
  - Database schema design with RLS
  - Kafka producer/consumer implementation
  - API development

**AI/ML Engineers (2)**
- **Skills Required:** LangChain, LangGraph, LiveKit, LLM prompt engineering, RAG patterns
- **AI Productivity Profile:** Medium (1.15-1.25x - lots of experimentation)
- **Responsibilities:**
  - Implement services 8, 9, 17
  - LangGraph workflow design
  - LiveKit voicebot pipeline
  - RAG pipeline with Qdrant + Neo4j
  - Prompt optimization

**Frontend Engineers (1-2)**
- **Skills Required:** React, TypeScript, Next.js, WebSocket, real-time UIs
- **AI Productivity Profile:** High (1.4-1.55x on component development)
- **Responsibilities:**
  - Service 21 (Agent Copilot) dashboard
  - Service 6 (PRD Builder) conversational UI
  - Client configuration portal
  - Admin dashboards

#### Platform/DevOps Team (2-3)

**DevOps Engineers (2)**
- **Skills Required:** Kubernetes, Terraform, Helm, Argo CD, GitOps, AWS/GCP
- **AI Productivity Profile:** Medium (1.25-1.4x on IaC, lower on troubleshooting)
- **Responsibilities:**
  - Kubernetes cluster management
  - CI/CD pipeline setup
  - Infrastructure as code
  - Secret management
  - Disaster recovery

**SRE/Platform Engineer (1)**
- **Skills Required:** Observability, Linkerd, Prometheus, Grafana, incident response
- **AI Productivity Profile:** Low (1.0-1.15x - debugging/troubleshooting)
- **Responsibilities:**
  - Service mesh deployment and management
  - Monitoring/alerting setup
  - Performance optimization
  - On-call rotation
  - Runbook creation

#### Leadership & Quality (2-3)

**Tech Lead / Architect (1)**
- **Skills Required:** Distributed systems, microservices architecture, DDD, event-driven design
- **AI Productivity Profile:** Low (0.8-1.0x for architectural decisions)
- **Responsibilities:**
  - Architecture decisions
  - Code review (security, multi-tenancy, performance)
  - Sprint planning
  - Technical debt management
  - Spike investigations

**QA Engineer (1)**
- **Skills Required:** Test automation, Pytest, K6 (load testing), Postman/REST APIs
- **AI Productivity Profile:** High (1.4-1.55x on test scaffolding)
- **Responsibilities:**
  - Test strategy and planning
  - Integration test suites
  - Load testing (1000+ concurrent sessions)
  - Tenant isolation testing
  - Test automation framework

**Product Manager (1)**
- **Skills Required:** Agile methodologies, technical product management, user story writing
- **Responsibilities:**
  - Product backlog management
  - Sprint planning facilitation
  - Stakeholder communication
  - Feature prioritization
  - User story refinement

#### Total Team Size: **10-13 people**

---

### Skills Development & Training

**Pre-Sprint 1 (Week 0):**
- **LangGraph Workshop:** 2-day workshop for AI/ML engineers and backend leads
- **Linkerd Training:** 1-day training for DevOps and SREs
- **Multi-tenancy Security:** 1-day workshop for all backend engineers
- **Kafka Fundamentals:** 1-day workshop for all engineers

**Ongoing:**
- **Bi-weekly tech talks:** 30 minutes, rotating presenters
- **Monthly architecture reviews:** Deep dive into one service
- **AI tool training:** Best practices for Claude Code usage

---

### Collaboration Patterns

**Daily:**
- **Daily standup:** 15 minutes, async-first (Slack standup bot)
- **Pair programming:** 2-4 hours, especially for security-critical code
- **Code review:** Within 4 hours, mandatory for all PRs

**Weekly:**
- **Sprint planning:** 2 hours (Sprints 1-8), 3 hours (Sprints 9-20)
- **Backlog refinement:** 1 hour mid-sprint
- **Tech debt review:** 30 minutes, identify and prioritize

**Bi-weekly:**
- **Sprint retrospective:** 1.5 hours
- **Sprint demo:** 1 hour
- **Architecture sync:** 1 hour (Tech Lead + Senior Engineers)

**Monthly:**
- **All-hands:** 2 hours, roadmap review and team updates
- **On-call retrospective:** 1 hour, review incidents and improve runbooks

---

## Sprint-by-Sprint Plans

---

## SPRINT 1: Foundation Setup & Service 0 (Week 1)

### Sprint Goal
Establish development environment, CI/CD foundation, and core authentication service with multi-tenant isolation.

### Sprint Metadata
- **Sprint Number:** 1
- **Duration:** 1 week
- **Team Velocity:** 30% of full capacity (conservative for first sprint)
- **Key Milestone:** Working auth system with JWT + multi-tenant PostgreSQL

---

### Backlog Items

#### User Story 1.1: Developer Environment Setup
**Story ID:** PLAT-001
**Story Points:** 5
**Priority:** P0 (Critical)
**Business Value:** Enables all subsequent development

**Description:**
As a developer, I need a standardized local development environment so that I can develop and test services consistently.

**Acceptance Criteria:**
- [ ] Docker Compose setup for local development (PostgreSQL, Redis, Kafka)
- [ ] README with setup instructions (<15 minutes to running state)
- [ ] `.env.example` with all required environment variables
- [ ] Pre-commit hooks for linting and formatting (Black, isort, Pylint)
- [ ] VS Code workspace settings with recommended extensions

**Technical Implementation:**
```yaml
# docker-compose.yml includes:
- postgres:15-alpine (with RLS config)
- redis:7-alpine
- kafka:3.6 (single broker for local)
- zookeeper:3.9
- pgadmin4 (database management UI)
```

---

#### User Story 1.2: CI/CD Pipeline Foundation
**Story ID:** PLAT-002
**Story Points:** 8
**Priority:** P0 (Critical)
**Business Value:** Automated testing and deployment from day 1

**Description:**
As a DevOps engineer, I need a CI/CD pipeline so that code changes are automatically tested, built, and deployed.

**Acceptance Criteria:**
- [ ] GitHub Actions workflow for Python services
  - Lint (Black, Pylint, mypy)
  - Unit tests with coverage (pytest, pytest-cov)
  - Security scan (Bandit, Safety)
  - Docker image build and push to registry
- [ ] Argo CD installed in Kubernetes cluster
- [ ] GitOps repository structure (`/k8s/base`, `/k8s/overlays/dev`, `/k8s/overlays/staging`)
- [ ] Automated deployment to dev environment on main branch merge
- [ ] Slack notifications for build failures

**Technical Implementation:**
- **CI:** GitHub Actions (`.github/workflows/ci.yml`)
- **CD:** Argo CD + Helm charts
- **Image Registry:** AWS ECR or Docker Hub
- **Deployment Targets:** Kubernetes dev cluster

---

#### User Story 1.3: Service 0 - Authentication System
**Story ID:** SVC0-001
**Story Points:** 13
**Priority:** P0 (Critical)
**Business Value:** Foundation for all services, enables multi-tenant isolation

**Description:**
As a system architect, I need a secure authentication service so that all services can verify user identity and enforce tenant isolation.

**Acceptance Criteria:**
- [ ] User signup with email verification (SendGrid integration)
- [ ] User login with JWT token generation (RS256 algorithm)
- [ ] JWT token validation middleware (Kong plugin or custom)
- [ ] Organization creation with unique `organization_id` (UUID)
- [ ] Team member invitation and role assignment (Owner, Admin, Member)
- [ ] PostgreSQL schema with RLS policies enforced on `organization_id`
- [ ] API endpoints:
  - `POST /auth/signup`
  - `POST /auth/login`
  - `POST /auth/verify-email`
  - `POST /organizations`
  - `POST /organizations/{org_id}/members`
- [ ] Kafka producer for `auth_events` (user_signed_up, email_verified, user_logged_in)
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests (signup → login flow)

**Technical Implementation:**
```python
# Database schema (PostgreSQL)
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE team_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  user_id UUID REFERENCES users(id),
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies (critical for multi-tenancy)
ALTER TABLE team_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY team_memberships_tenant_isolation ON team_memberships
  USING (organization_id = current_setting('app.current_tenant_id')::UUID);
```

**API Example:**
```bash
# Signup
POST /auth/signup
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "organization_name": "Acme Corp"
}

# Response
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "organization_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "message": "Verification email sent"
}

# Login
POST /auth/login
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

# Response
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

---

#### User Story 1.4: Kubernetes Cluster Setup
**Story ID:** INFRA-001
**Story Points:** 8
**Priority:** P0 (Critical)
**Business Value:** Deployment target for all services

**Description:**
As a DevOps engineer, I need a Kubernetes cluster so that services can be deployed, scaled, and managed.

**Acceptance Criteria:**
- [ ] Kubernetes cluster deployed (EKS on AWS or GKE on GCP)
- [ ] Node groups with autoscaling (min 3, max 10 nodes)
- [ ] Namespaces created: `platform-dev`, `platform-staging`, `platform-prod`
- [ ] RBAC configured (least privilege principle)
- [ ] kubectl access configured for all engineers
- [ ] Kubernetes dashboard installed (optional, for visualization)
- [ ] Health checks and resource limits defined in Helm chart template

**Technical Implementation:**
```bash
# EKS cluster with Terraform
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "workflow-automation"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      min_size     = 3
      max_size     = 10
      desired_size = 3
      instance_types = ["t3.large"]
    }
  }
}
```

---

### Technical Implementation Details

#### Services to Implement
1. **Service 0: Organization & Identity Management**
   - Technology: FastAPI (Python 3.11+)
   - Database: PostgreSQL 15 with RLS
   - Authentication: JWT (RS256, 1-hour expiry)
   - Email: SendGrid API for verification emails
   - Kafka: Producer for `auth_events`

#### APIs to Develop
- **POST /auth/signup** - User registration
- **POST /auth/login** - User authentication
- **POST /auth/verify-email** - Email verification
- **POST /auth/refresh** - Token refresh
- **GET /auth/me** - Get current user profile
- **POST /organizations** - Create organization
- **GET /organizations/{org_id}** - Get organization details
- **POST /organizations/{org_id}/members** - Invite team member

#### Database Schemas
See User Story 1.3 for complete schema definitions with RLS policies.

#### Infrastructure Components
- **Kubernetes:** 3-node cluster (EKS or GKE)
- **PostgreSQL:** Managed instance (AWS RDS or GCP Cloud SQL)
- **Redis:** Managed cluster (AWS ElastiCache or GCP Memorystore)
- **Kafka:** Managed service (AWS MSK or Confluent Cloud) - single broker for dev
- **S3/GCS:** Object storage for configs and documents

#### Integration Points
- **Kong API Gateway ← Service 0:** JWT validation plugin
- **Service 0 → Kafka:** Produce `auth_events`
- **Service 0 → SendGrid:** Email verification
- **Service 0 → PostgreSQL:** User/org data with RLS

---

### Architecture Decisions

#### Decision 1.1: Multi-Tenancy Strategy
**Context:**
Need to isolate customer data across thousands of tenants while maintaining query performance and operational simplicity.

**Options Considered:**
1. Database-per-tenant (high isolation, complex operations)
2. Schema-per-tenant (medium isolation, moderate complexity)
3. Shared schema with RLS (low isolation, simple operations)

**Chosen Approach:**
Shared schema with PostgreSQL Row-Level Security (RLS)

**Rationale:**
- Supports 0-5000 tenants efficiently
- RLS enforced at database level (defense in depth)
- Simple backup/restore operations
- Clear upgrade path to schema-per-tenant (Citus sharding) for Tier 2
- Balances security, cost, and operational complexity

**Implementation Notes:**
- `organization_id` (UUID) on EVERY table
- RLS policies on ALL tables with user-generated content
- Application sets `app.current_tenant_id` session variable on every connection
- Automated tenant isolation tests on every endpoint

---

#### Decision 1.2: JWT Algorithm Choice
**Context:**
Need to select JWT signing algorithm for authentication tokens.

**Options Considered:**
1. HS256 (HMAC with SHA-256, symmetric key)
2. RS256 (RSA with SHA-256, asymmetric key)

**Chosen Approach:**
RS256 (RSA asymmetric keys)

**Rationale:**
- Public key can be distributed to all services for verification
- Private key remains only in Service 0 (reduced attack surface)
- Standard for microservices architectures
- Supports key rotation without service downtime
- Kong API Gateway has built-in RS256 JWT validation

---

### Dependencies & Prerequisites

**Technical Dependencies:**
- AWS/GCP account with billing enabled
- Domain name for API endpoints (e.g., `api.workflow-automation.com`)
- SendGrid account for transactional emails
- GitHub organization for source control
- Docker Hub or AWS ECR for image registry

**External Dependencies:**
- None (this is Sprint 1, no external service dependencies)

**Blockers:**
- None anticipated

**Risk Mitigation:**
- **Risk:** Kubernetes cluster provisioning delays (1-2 days)
  - **Mitigation:** Start cluster provisioning on Day 1 of sprint, parallelize with local development
- **Risk:** Team unfamiliarity with PostgreSQL RLS
  - **Mitigation:** Tech lead provides RLS pattern examples and code review

---

### Testing Strategy

#### Unit Testing
- **Framework:** pytest with pytest-cov
- **Coverage Target:** 80%+ for Service 0
- **Scope:**
  - Password hashing/validation
  - JWT token generation/validation
  - Email validation logic
  - RLS policy enforcement (mock database)

**Example Test:**
```python
# tests/test_auth.py
def test_signup_creates_user_and_organization():
    response = client.post("/auth/signup", json={
        "email": "test@example.com",
        "password": "SecurePass123!",
        "organization_name": "Test Org"
    })
    assert response.status_code == 201
    assert "user_id" in response.json()
    assert "organization_id" in response.json()

    # Verify user created in database
    user = db.query(User).filter_by(email="test@example.com").first()
    assert user is not None
    assert user.email_verified is False
```

#### Integration Testing
- **Framework:** pytest with testcontainers (real PostgreSQL + Kafka)
- **Scope:**
  - Complete signup flow (signup → email verification → login)
  - Organization creation and member invitation
  - JWT token validation across services (mock Kong)
  - Kafka event publishing (verify `auth_events` produced)

**Example Test:**
```python
# tests/integration/test_auth_flow.py
def test_complete_signup_and_login_flow():
    # 1. Signup
    signup_response = client.post("/auth/signup", json={
        "email": "integration@example.com",
        "password": "SecurePass123!",
        "organization_name": "Integration Test Org"
    })
    assert signup_response.status_code == 201
    user_id = signup_response.json()["user_id"]

    # 2. Verify email (simulate clicking verification link)
    verification_token = get_verification_token_from_db(user_id)
    verify_response = client.post(f"/auth/verify-email?token={verification_token}")
    assert verify_response.status_code == 200

    # 3. Login
    login_response = client.post("/auth/login", json={
        "email": "integration@example.com",
        "password": "SecurePass123!"
    })
    assert login_response.status_code == 200
    assert "access_token" in login_response.json()

    # 4. Verify Kafka event
    events = consume_kafka_topic("auth_events", timeout=5)
    assert any(e["event_type"] == "user_signed_up" for e in events)
```

#### End-to-End Testing
- **Scope:** Deferred to Sprint 2 (no E2E tests in Sprint 1)

#### Performance Testing
- **Scope:** None (Sprint 1 focus is functional correctness)

#### Security Testing
- **Framework:** Bandit (static analysis), Safety (dependency vulnerabilities)
- **Scope:**
  - SQL injection prevention (parameterized queries)
  - Password storage (bcrypt with salt)
  - JWT secret protection (environment variables, never in code)
  - RLS bypass attempts (try accessing other tenant's data)

**Example Security Test:**
```python
# tests/security/test_tenant_isolation.py
def test_user_cannot_access_other_tenant_data():
    # Create two tenants
    tenant1_token = create_tenant_and_login("tenant1@example.com")
    tenant2_token = create_tenant_and_login("tenant2@example.com")

    # Tenant 1 creates a resource
    response = client.post("/organizations/members",
        headers={"Authorization": f"Bearer {tenant1_token}"},
        json={"email": "member@tenant1.com", "role": "member"})
    member_id = response.json()["id"]

    # Tenant 2 tries to access Tenant 1's resource (should fail)
    response = client.get(f"/organizations/members/{member_id}",
        headers={"Authorization": f"Bearer {tenant2_token}"})
    assert response.status_code == 403  # Forbidden
```

---

### DevOps & Deployment

#### CI/CD Updates
- **CI Pipeline (GitHub Actions):**
  ```yaml
  # .github/workflows/ci-service-0.yml
  name: CI - Service 0
  on:
    push:
      paths:
        - 'services/service-0/**'
        - '.github/workflows/ci-service-0.yml'

  jobs:
    test:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Set up Python 3.11
          uses: actions/setup-python@v4
          with:
            python-version: '3.11'
        - name: Install dependencies
          run: |
            cd services/service-0
            pip install -r requirements.txt
            pip install -r requirements-dev.txt
        - name: Lint with Black and Pylint
          run: |
            black --check .
            pylint services/service-0
        - name: Type check with mypy
          run: mypy services/service-0
        - name: Security scan with Bandit
          run: bandit -r services/service-0
        - name: Check dependencies with Safety
          run: safety check
        - name: Run unit tests
          run: pytest services/service-0/tests --cov=services/service-0 --cov-report=xml
        - name: Upload coverage to Codecov
          uses: codecov/codecov-action@v3

    build:
      needs: test
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Set up Docker Buildx
          uses: docker/setup-buildx-action@v3
        - name: Login to AWS ECR
          uses: aws-actions/amazon-ecr-login@v2
        - name: Build and push Docker image
          uses: docker/build-push-action@v5
          with:
            context: services/service-0
            push: true
            tags: |
              ${{ secrets.ECR_REGISTRY }}/service-0:${{ github.sha }}
              ${{ secrets.ECR_REGISTRY }}/service-0:latest
            cache-from: type=gha
            cache-to: type=gha,mode=max
  ```

- **CD Pipeline (Argo CD):**
  - Argo CD watches GitOps repository (`k8s/` directory)
  - On new image tag, automatically updates Helm chart values
  - Syncs changes to Kubernetes cluster
  - Health checks ensure deployment success

#### Infrastructure Changes
- **Terraform Modules:**
  - `modules/eks` - Kubernetes cluster
  - `modules/rds` - PostgreSQL database
  - `modules/elasticache` - Redis cluster
  - `modules/msk` - Kafka cluster
  - `modules/vpc` - Network infrastructure

- **Helm Charts:**
  - `charts/service-0` - Service 0 deployment manifest

**Helm Chart Example:**
```yaml
# charts/service-0/values.yaml
replicaCount: 3

image:
  repository: ${ECR_REGISTRY}/service-0
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8000

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: service-0-secrets
        key: database-url
  - name: JWT_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
        name: service-0-secrets
        key: jwt-private-key
  - name: SENDGRID_API_KEY
    valueFrom:
      secretKeyRef:
        name: service-0-secrets
        key: sendgrid-api-key

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
  initialDelaySeconds: 5
  periodSeconds: 5
```

#### Deployment Strategy
- **Blue-Green Deployment:** Not yet (Sprint 1 has no production traffic)
- **Canary Deployment:** Not yet
- **Rolling Update:** Default Kubernetes rolling update strategy (25% max unavailable)

#### Rollback Plan
- **Automated:** Argo CD can rollback to previous revision via UI or CLI
- **Manual:** `kubectl rollout undo deployment/service-0 -n platform-dev`
- **Database:** No schema changes in Sprint 1, so no database rollback needed

---

### Observability

#### Metrics to Track
- **Service 0 Metrics:**
  - `service0_signup_total` (counter) - Total signups
  - `service0_signup_duration_seconds` (histogram) - Signup latency
  - `service0_login_total` (counter) - Total logins
  - `service0_login_duration_seconds` (histogram) - Login latency
  - `service0_jwt_validation_total` (counter) - JWT validations
  - `service0_jwt_validation_errors_total` (counter) - Failed JWT validations
  - `service0_db_queries_total` (counter) - Database query count
  - `service0_db_query_duration_seconds` (histogram) - Database query latency

**Prometheus Example:**
```python
# services/service-0/metrics.py
from prometheus_client import Counter, Histogram

signup_counter = Counter('service0_signup_total', 'Total signups', ['status'])
signup_duration = Histogram('service0_signup_duration_seconds', 'Signup latency')

@signup_duration.time()
def create_user(email, password, org_name):
    # ... user creation logic ...
    signup_counter.labels(status='success').inc()
```

#### Logs to Collect
- **Structured Logging (JSON format):**
  ```json
  {
    "timestamp": "2025-10-10T14:30:45.123Z",
    "level": "INFO",
    "service": "service-0",
    "trace_id": "550e8400-e29b-41d4-a716-446655440000",
    "span_id": "7c9e6679-7425-40de",
    "message": "User signed up successfully",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "organization_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "email": "user@example.com"
  }
  ```

- **Log Levels:**
  - DEBUG: Detailed troubleshooting (disabled in production)
  - INFO: Normal operations (user signup, login)
  - WARNING: Unexpected but recoverable (rate limit exceeded, duplicate signup)
  - ERROR: Failures requiring attention (database connection failed, Kafka publish failed)
  - CRITICAL: System-level failures (service crash)

#### Traces to Implement
- **OpenTelemetry Instrumentation:**
  - Auto-instrumentation for FastAPI (HTTP requests)
  - Manual spans for critical operations (signup, login, JWT generation)
  - Span attributes: `user_id`, `organization_id`, `email`

**Example:**
```python
# services/service-0/main.py
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

app = FastAPI()
FastAPIInstrumentor.instrument_app(app)
tracer = trace.get_tracer(__name__)

@app.post("/auth/signup")
async def signup(request: SignupRequest):
    with tracer.start_as_current_span("signup") as span:
        span.set_attribute("email", request.email)
        # ... signup logic ...
        span.set_attribute("user_id", str(user_id))
        span.set_attribute("organization_id", str(org_id))
```

#### Alerts to Configure
- **Critical Alerts (PagerDuty):**
  - Service 0 unhealthy (no healthy pods for 2 minutes)
  - Database connection failures (>5 in 1 minute)
  - JWT validation error rate >5%

- **Warning Alerts (Slack):**
  - Login latency P95 >500ms (sustained for 5 minutes)
  - Signup error rate >2%
  - Kafka publish failures (>10 in 5 minutes)

**Prometheus Alert Rules:**
```yaml
# k8s/base/prometheus/rules/service-0.yaml
groups:
  - name: service-0
    interval: 30s
    rules:
      - alert: Service0Down
        expr: up{job="service-0"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service 0 is down"
          description: "Service 0 has been down for more than 2 minutes"

      - alert: Service0HighLoginLatency
        expr: histogram_quantile(0.95, service0_login_duration_seconds) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High login latency"
          description: "P95 login latency is {{ $value }}s (threshold: 0.5s)"
```

---

### Documentation

#### Technical Documentation
- **Architecture Decision Records (ADRs):**
  - `docs/adr/001-multi-tenancy-strategy.md`
  - `docs/adr/002-jwt-algorithm-choice.md`

- **Database Schema Documentation:**
  - `docs/database/service-0-schema.md` (Entity-Relationship Diagram + table descriptions)

- **Service README:**
  - `services/service-0/README.md` (setup, development, testing, deployment)

#### API Documentation
- **OpenAPI Spec (Swagger):**
  - Auto-generated from FastAPI
  - Accessible at `http://localhost:8000/docs` (local dev)
  - Published to `https://api.workflow-automation.com/docs` (production)

**Example:**
```python
# services/service-0/main.py
@app.post("/auth/signup",
    response_model=SignupResponse,
    status_code=201,
    summary="Create new user and organization",
    description="""
    Creates a new user account and organization.
    Sends verification email to the provided email address.

    **Multi-tenancy:** Creates a new `organization_id` that isolates this tenant's data.
    """,
    responses={
        201: {"description": "User and organization created successfully"},
        400: {"description": "Invalid request (email already exists, weak password)"},
        429: {"description": "Rate limit exceeded"}
    })
async def signup(request: SignupRequest):
    ...
```

#### Deployment Guides
- **Sprint 1 Deployment Guide:**
  - `docs/deployment/sprint-1-deployment.md`
  - Steps to deploy Service 0 to dev/staging/production
  - Smoke testing checklist
  - Rollback procedure

#### Operational Runbooks
- **Runbook: Service 0 Incident Response**
  - `docs/runbooks/service-0-incident-response.md`
  - Common issues (database connection failure, Kafka unavailable)
  - Troubleshooting steps
  - Escalation path

**Example Runbook Snippet:**
```markdown
## Runbook: Service 0 - Database Connection Failure

**Symptoms:**
- Alert: "Service0DatabaseConnectionFailure"
- Users cannot sign up or log in
- Logs show: `psycopg2.OperationalError: could not connect to server`

**Investigation Steps:**
1. Check PostgreSQL health: `kubectl exec -it postgres-0 -- pg_isready`
2. Check Service 0 logs: `kubectl logs -l app=service-0 -n platform-prod --tail=100`
3. Check database credentials: `kubectl get secret service-0-secrets -o yaml`

**Resolution:**
- If PostgreSQL is down: Restart database (see Database Runbook)
- If credentials expired: Rotate secrets (see Secret Rotation Runbook)
- If connection pool exhausted: Scale Service 0 replicas: `kubectl scale deployment service-0 --replicas=5`

**Prevention:**
- Monitor database connection pool usage
- Set connection pool max_connections appropriately
- Implement connection retry logic with exponential backoff
```

---

### Risk Mitigation

#### Identified Risks

**Risk 1: Team Unfamiliarity with PostgreSQL RLS**
- **Probability:** High (80%)
- **Impact:** Medium (2-day delay)
- **Mitigation:**
  - Tech lead creates RLS pattern examples before Sprint 1
  - Pair programming for first RLS implementation
  - Mandatory code review by tech lead for all RLS policies
- **Contingency:** If RLS proves too complex, defer to Sprint 2 and use application-level tenant filtering (technical debt)

**Risk 2: Kubernetes Cluster Provisioning Delays**
- **Probability:** Medium (40%)
- **Impact:** Medium (1-2 day delay)
- **Mitigation:**
  - Start cluster provisioning on Day 1 of Sprint 1
  - Parallelize local development (doesn't require cluster)
  - Use existing shared dev cluster as temporary fallback
- **Contingency:** Extend Sprint 1 by 1 day if needed

**Risk 3: SendGrid API Integration Issues**
- **Probability:** Low (20%)
- **Impact:** Low (1-day delay)
- **Mitigation:**
  - Use SendGrid Python SDK (well-documented)
  - Implement email sending as async task (non-blocking)
  - Mock email service in tests (don't call real SendGrid)
- **Contingency:** Temporarily log verification links to console for development, implement email later

**Risk 4: Kafka Cluster Setup Complexity**
- **Probability:** Medium (50%)
- **Impact:** Low (1-day delay)
- **Mitigation:**
  - Use managed Kafka service (AWS MSK or Confluent Cloud) instead of self-hosted
  - Single-broker Kafka for dev environment (simpler)
  - Use Kafka Docker image for local development
- **Contingency:** Defer Kafka integration to Sprint 2, use in-memory queue temporarily

---

### Sprint Retrospective Preparation

#### Success Criteria
- [ ] All 4 user stories completed and merged to main
- [ ] Service 0 deployed to dev environment
- [ ] CI/CD pipeline functional (green build on main branch)
- [ ] At least 1 successful end-to-end test (signup → login)
- [ ] Database RLS policies verified with tenant isolation tests
- [ ] Team velocity baseline established (actual story points completed)

#### Metrics to Measure
- **Story Points Completed:** Target 34 (actual will establish baseline)
- **Velocity:** Story points per day (target: ~6-7 points/day for Sprint 1)
- **Code Coverage:** Service 0 unit tests (target: 80%+)
- **Build Time:** CI pipeline duration (target: <10 minutes)
- **Deployment Time:** From merge to deployed (target: <15 minutes with Argo CD)
- **Incidents:** Number of production incidents (target: 0, since no production traffic yet)

#### Lessons Learned Focus Areas
- **What went well:**
  - Was RLS implementation easier or harder than expected?
  - Did local development setup work smoothly?
  - Were the architecture decisions clear and helpful?

- **What could be improved:**
  - Were story points accurately estimated?
  - Was the sprint scope appropriate (too much/too little)?
  - Did we encounter unexpected blockers?

- **Action items for Sprint 2:**
  - Adjust story point estimates based on actual velocity
  - Identify and document any technical debt introduced
  - Update development workflows based on team feedback

---

### Task Breakdown & AI Productivity Classification

#### Well-Defined Implementation Tasks (High AI Productivity: 1.4-1.55x)
- **Estimated Effort without AI:** 40 hours
- **Estimated Effort with AI:** 26-29 hours
- **Tasks:**
  - API endpoint implementation (CRUD operations)
  - Database schema creation (SQL DDL)
  - JWT token generation/validation logic
  - Kafka producer implementation (boilerplate)
  - Unit test scaffolding
  - OpenAPI documentation generation
  - Docker Compose configuration
  - Helm chart templating
  - CI pipeline YAML configuration

**AI Usage Strategy:**
- Use Claude Code to generate API endpoint boilerplate
- Generate database migration files
- Create test fixtures and mock data
- Scaffold CI/CD pipeline configurations

#### Exploratory/Complex Tasks (Low AI Productivity: 0.8-1.0x)
- **Estimated Effort without AI:** 20 hours
- **Estimated Effort with AI:** 20-25 hours (no significant speedup, may be slower)
- **Tasks:**
  - PostgreSQL RLS policy design (security-critical)
  - Multi-tenancy strategy decisions
  - JWT algorithm selection and key management
  - Kubernetes cluster architecture and sizing
  - Error handling and edge case discovery
  - Performance bottleneck investigation

**AI Usage Strategy:**
- Use AI for research and documentation lookup
- DO NOT rely on AI for security decisions (multi-tenancy, RLS, JWT)
- Mandate human review for all security-critical code
- Use AI to explain concepts, not make architectural decisions

#### Total Sprint 1 Effort Estimate
- **Without AI:** 60 hours of development work
- **With Strategic AI Use:** 46-54 hours (18-23% faster)
- **Team Capacity:** 6 engineers × 3 productive hours/day × 5 days = 90 hours available
- **Utilization:** 51-60% (reasonable for Sprint 1 with setup overhead)

---

## SPRINT 2: Infrastructure & Observability (Week 2)

### Sprint Goal
Deploy observability stack, service mesh, and secrets management foundation to enable production-readiness for all future services.

### Sprint Metadata
- **Sprint Number:** 2
- **Duration:** 1 week
- **Team Velocity:** 40-50% of full capacity (still ramping up)
- **Key Milestone:** Linkerd service mesh operational + monitoring stack deployed

---

### Backlog Items

#### User Story 2.1: Observability Stack Deployment
**Story ID:** PLAT-003
**Story Points:** 13
**Priority:** P0 (Critical)
**Business Value:** Visibility into system behavior, critical for debugging and performance optimization

**Description:**
As an SRE, I need a complete observability stack so that I can monitor system health, debug issues, and track performance metrics.

**Acceptance Criteria:**
- [ ] Prometheus deployed (metrics collection)
  - scrapes metrics from all services every 30s
  - retention: 15 days
- [ ] Grafana deployed (visualization)
  - pre-built dashboards for Kubernetes cluster health
  - Service 0 dashboard (signup/login metrics)
- [ ] Jaeger deployed (distributed tracing)
  - collects traces from OpenTelemetry instrumentation
  - retention: 7 days
- [ ] ELK Stack deployed (logging) - OR - Loki as lightweight alternative
  - collects logs from all pods
  - retention: 30 days
- [ ] AlertManager configured
  - routes critical alerts to PagerDuty
  - routes warning alerts to Slack
- [ ] Health check endpoints on all services (`/health`, `/ready`)

**Technical Implementation:**
```bash
# Deploy monitoring stack using Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts

# Prometheus + Grafana
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set prometheus.prometheusSpec.retention=15d \
  --set grafana.adminPassword=<secure-password>

# Jaeger
helm install jaeger jaegertracing/jaeger \
  --namespace monitoring \
  --set provisionDataStore.cassandra=false \
  --set storage.type=elasticsearch

# Loki (lightweight alternative to ELK)
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set promtail.enabled=true
```

---

#### User Story 2.2: Linkerd Service Mesh Deployment
**Story ID:** PLAT-004
**Story Points:** 8
**Priority:** P1 (High)
**Business Value:** mTLS, observability, load balancing, circuit breaking for all services

**Description:**
As a platform engineer, I need a service mesh so that services can communicate securely and reliably with built-in observability.

**Acceptance Criteria:**
- [ ] Linkerd control plane installed
- [ ] Linkerd CLI installed on developer machines
- [ ] Service 0 meshed (auto-injected with Linkerd proxy)
- [ ] mTLS enabled between services
- [ ] Linkerd dashboard accessible
- [ ] Golden metrics visible (success rate, latency, request volume)
- [ ] Circuit breaking configured (max connections: 1024, max pending requests: 1024)

**Technical Implementation:**
```bash
# Install Linkerd CLI
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh

# Install Linkerd control plane
linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -

# Verify installation
linkerd check

# Mesh Service 0 namespace
kubectl annotate namespace platform-dev linkerd.io/inject=enabled

# Redeploy Service 0 to get Linkerd proxy injected
kubectl rollout restart deployment/service-0 -n platform-dev

# Access Linkerd dashboard
linkerd viz dashboard
```

**Why Linkerd over Istio:**
- 163ms faster at P99 latency (critical for <500ms voice target)
- 90% less resource usage (CPU/memory)
- Simpler operational model (no CRDs overload)
- Better developer experience

---

#### User Story 2.3: External Secrets Operator Setup
**Story ID:** PLAT-005
**Story Points:** 8
**Priority:** P0 (Critical)
**Business Value:** Secure secret management, no secrets in Git or environment variables

**Description:**
As a security engineer, I need secrets managed externally so that credentials never exist in source control or configuration files.

**Acceptance Criteria:**
- [ ] External Secrets Operator installed
- [ ] AWS Secrets Manager (or GCP Secret Manager) configured
- [ ] ExternalSecret CRD created for Service 0 secrets
  - `DATABASE_URL`
  - `JWT_PRIVATE_KEY`
  - `SENDGRID_API_KEY`
  - `KAFKA_BOOTSTRAP_SERVERS`
- [ ] Secrets automatically synced to Kubernetes Secrets
- [ ] Service 0 consumes secrets from Kubernetes Secrets (not env vars in deployment YAML)
- [ ] Secret rotation tested (update secret in AWS Secrets Manager → verify Service 0 receives new value within 5 minutes)

**Technical Implementation:**
```bash
# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets-system --create-namespace

# Create SecretStore (connects to AWS Secrets Manager)
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
  namespace: platform-dev
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
EOF

# Create ExternalSecret (syncs secrets from AWS to K8s)
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: service-0-secrets
  namespace: platform-dev
spec:
  refreshInterval: 5m
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: service-0-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: /platform/dev/service-0/database-url
    - secretKey: jwt-private-key
      remoteRef:
        key: /platform/dev/service-0/jwt-private-key
    - secretKey: sendgrid-api-key
      remoteRef:
        key: /platform/dev/service-0/sendgrid-api-key
EOF
```

---

#### User Story 2.4: @workflow/llm-sdk Library Foundation
**Story ID:** LIB-001
**Story Points:** 13
**Priority:** P1 (High)
**Business Value:** Eliminates 200-500ms latency per LLM call, foundational for all AI services

**Description:**
As an AI engineer, I need a shared LLM integration library so that all services can call LLMs efficiently without going through a gateway.

**Acceptance Criteria:**
- [ ] Python package `@workflow/llm-sdk` created
- [ ] Model routing logic (GPT-4, GPT-3.5-turbo, Claude)
  - Simple queries → GPT-3.5-turbo (cheaper)
  - Complex queries → GPT-4 or Claude (premium)
- [ ] Semantic caching with Helicone integration (40-60% cost reduction)
- [ ] Token usage tracking per tenant (`organization_id`)
- [ ] Error handling and retries (exponential backoff)
- [ ] Streaming support for chat completions
- [ ] OpenAI, Anthropic, and fallback providers
- [ ] Unit tests (80%+ coverage)
- [ ] Published to private PyPI or shared via Git submodule

**Technical Implementation:**
```python
# @workflow/llm-sdk/llm_client.py
from openai import AsyncOpenAI
from anthropic import AsyncAnthropic
import time

class LLMClient:
    def __init__(self, organization_id: str, helicone_api_key: str):
        self.organization_id = organization_id
        self.openai_client = AsyncOpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            default_headers={
                "Helicone-Auth": f"Bearer {helicone_api_key}",
                "Helicone-Cache-Enabled": "true",
                "Helicone-User-Id": organization_id
            }
        )
        self.anthropic_client = AsyncAnthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

    async def chat(self, prompt: str, complexity: str = "auto") -> str:
        """
        Send chat completion request with automatic model routing.

        Args:
            prompt: User prompt
            complexity: "simple" (GPT-3.5), "complex" (GPT-4), "auto" (infer)

        Returns:
            Assistant response
        """
        # Auto-detect complexity if not specified
        if complexity == "auto":
            complexity = self._infer_complexity(prompt)

        model = "gpt-3.5-turbo" if complexity == "simple" else "gpt-4-turbo"

        start_time = time.time()
        try:
            response = await self.openai_client.chat.completions.create(
                model=model,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1000
            )
            duration = time.time() - start_time

            # Track usage
            self._track_usage(
                model=model,
                prompt_tokens=response.usage.prompt_tokens,
                completion_tokens=response.usage.completion_tokens,
                duration=duration
            )

            return response.choices[0].message.content

        except Exception as e:
            # Fallback to Anthropic if OpenAI fails
            return await self._fallback_anthropic(prompt)

    def _infer_complexity(self, prompt: str) -> str:
        """Infer query complexity based on length and keywords."""
        if len(prompt) > 500:
            return "complex"
        if any(kw in prompt.lower() for kw in ["analyze", "explain", "design", "architecture"]):
            return "complex"
        return "simple"

    def _track_usage(self, model: str, prompt_tokens: int, completion_tokens: int, duration: float):
        """Track token usage and latency for cost analysis."""
        # Publish metrics to Prometheus or write to TimescaleDB
        pass
```

**Usage Example:**
```python
# In Service 1 (Research Engine)
from workflow.llm_sdk import LLMClient

llm = LLMClient(organization_id=current_tenant_id, helicone_api_key=HELICONE_KEY)
summary = await llm.chat(
    prompt=f"Summarize this company research: {research_data}",
    complexity="simple"
)
```

---

### Technical Implementation Details

#### Services to Implement
1. **@workflow/llm-sdk library** - Shared LLM integration library
2. **No new microservices in Sprint 2** - focus is infrastructure

#### Infrastructure Components
- **Linkerd Service Mesh:** Control plane + data plane (proxies auto-injected)
- **Prometheus:** Metrics collection and storage
- **Grafana:** Visualization and dashboards
- **Jaeger:** Distributed tracing backend
- **Loki:** Log aggregation (lightweight alternative to ELK)
- **AlertManager:** Alert routing and notification
- **External Secrets Operator:** Secret synchronization from AWS Secrets Manager

---

### Architecture Decisions

#### Decision 2.1: Observability Backend Choice (Jaeger vs Tempo)
**Context:**
Need to select distributed tracing backend for OpenTelemetry traces.

**Options Considered:**
1. Jaeger (mature, battle-tested, Elasticsearch/Cassandra storage)
2. Tempo (newer, Grafana-native, S3-based storage)

**Chosen Approach:**
Jaeger with Elasticsearch backend

**Rationale:**
- Mature ecosystem with extensive documentation
- Better query performance for high-cardinality traces
- Team familiarity (less learning curve)
- Can migrate to Tempo later if needed (both use OpenTelemetry)

---

#### Decision 2.2: Logging Solution (ELK vs Loki)
**Context:**
Need centralized logging for all services.

**Options Considered:**
1. ELK Stack (Elasticsearch, Logstash, Kibana) - powerful, resource-heavy
2. Loki + Promtail - lightweight, Grafana-native

**Chosen Approach:**
Loki + Promtail

**Rationale:**
- 90% less resource usage (no indexing full log content)
- Native Grafana integration (unified observability)
- Sufficient for initial needs (can upgrade to ELK if needed)
- LogQL query language similar to PromQL (consistent learning)

---

### Dependencies & Prerequisites

**Technical Dependencies:**
- Sprint 1 complete (Service 0 deployed, Kubernetes cluster operational)
- AWS Secrets Manager account and IAM permissions
- Helicone API key for semantic caching

**External Dependencies:**
- None

**Blockers:**
- None anticipated

---

### Testing Strategy

#### Integration Testing
- **External Secrets Operator:**
  - Create secret in AWS Secrets Manager
  - Verify ExternalSecret syncs to Kubernetes Secret within 5 minutes
  - Update secret in AWS Secrets Manager
  - Verify Service 0 picks up new secret (restart may be required)

- **Linkerd:**
  - Send request from Service 0 to itself (loopback)
  - Verify mTLS handshake in Linkerd dashboard
  - Verify golden metrics (success rate, latency) appear

#### Performance Testing
- **@workflow/llm-sdk:**
  - Benchmark latency: Direct LLM call vs. hypothetical gateway (should be 200-500ms faster)
  - Test semantic caching: Send identical prompt twice, verify second call is cached (near-instant)
  - Load test: 100 concurrent LLM calls, verify no rate limit errors

---

### DevOps & Deployment

#### Infrastructure Changes
- **Terraform Modules Added:**
  - `modules/monitoring` - Prometheus, Grafana, Jaeger, Loki
  - `modules/secrets-manager` - AWS Secrets Manager setup
  - `modules/linkerd` - Linkerd control plane installation (optional, can use Helm)

#### Deployment Strategy
- All monitoring components deployed to `monitoring` namespace
- Linkerd control plane deployed to `linkerd` namespace
- External Secrets Operator deployed to `external-secrets-system` namespace

---

### Observability

#### Metrics to Track
- **Linkerd Golden Metrics:**
  - `request_total` - Total requests
  - `response_total` - Total responses by status code
  - `response_latency_ms` - P50, P95, P99 latency
  - `tcp_open_connections` - Active connections

- **@workflow/llm-sdk Metrics:**
  - `llm_sdk_requests_total{model, complexity}` - LLM requests
  - `llm_sdk_duration_seconds{model}` - LLM latency
  - `llm_sdk_tokens_total{model, type=prompt|completion}` - Token usage
  - `llm_sdk_cache_hits_total` - Semantic cache hits (Helicone)
  - `llm_sdk_errors_total{model, error_type}` - LLM errors

#### Dashboards to Create
1. **Kubernetes Cluster Dashboard** (pre-built from kube-prometheus-stack)
   - Node CPU/memory usage
   - Pod status and restarts
   - Persistent volume usage

2. **Service 0 Dashboard**
   - Signup/login request rate
   - Signup/login latency (P50, P95, P99)
   - Error rate by endpoint
   - Database query latency
   - Kafka publish success rate

3. **Linkerd Dashboard**
   - Service-to-service traffic visualization
   - Request success rate by service
   - Latency heatmap
   - Active connection count

4. **LLM Cost Dashboard**
   - Token usage by tenant
   - Model distribution (GPT-3.5 vs GPT-4 usage %)
   - Cache hit rate (Helicone)
   - Estimated monthly cost projection

---

### Documentation

#### Technical Documentation
- **ADR:** `docs/adr/003-service-mesh-choice.md` (Linkerd vs Istio)
- **ADR:** `docs/adr/004-observability-stack.md` (Prometheus + Jaeger + Loki)
- **ADR:** `docs/adr/005-secrets-management.md` (External Secrets Operator)

#### Operational Runbooks
- **Runbook:** "Linkerd Control Plane Failure"
- **Runbook:** "Prometheus Disk Full"
- **Runbook:** "Secret Rotation Procedure"

---

### Risk Mitigation

**Risk 1: Linkerd Learning Curve**
- **Probability:** Medium (50%)
- **Impact:** Low (1-day delay)
- **Mitigation:** SRE completes Linkerd workshop before Sprint 2, pair programming for initial setup
- **Contingency:** Defer Linkerd to Sprint 3 if blockers occur, continue without service mesh temporarily

**Risk 2: External Secrets Operator Sync Delays**
- **Probability:** Low (20%)
- **Impact:** Low (secret updates delayed by 5+ minutes)
- **Mitigation:** Set `refreshInterval: 5m` in ExternalSecret, test with multiple secrets
- **Contingency:** If sync is too slow, use direct Kubernetes Secrets temporarily, revisit in Sprint 3

---

### Sprint Retrospective Preparation

#### Success Criteria
- [ ] Linkerd successfully meshing Service 0
- [ ] Prometheus scraping metrics from Service 0 and Kubernetes
- [ ] Grafana dashboards showing Service 0 metrics
- [ ] Jaeger collecting traces from Service 0
- [ ] Loki collecting logs from all pods
- [ ] External Secrets Operator syncing secrets to Service 0
- [ ] @workflow/llm-sdk published and tested (basic functionality)

#### Metrics to Measure
- **Story Points Completed:** Target 42
- **Velocity:** Adjust based on Sprint 1 baseline
- **Observability Coverage:** 100% of Service 0 instrumented
- **Secret Sync Time:** <5 minutes from AWS update to K8s Secret

---

---

## SPRINT 3: Core Services - Research Engine (Week 3)

### Sprint Goal
Implement Service 1 (Research Engine) with automated market research pipeline and @workflow/config-sdk library foundation.

### Sprint Metadata
- **Sprint Number:** 3
- **Duration:** 1 week
- **Team Velocity:** 60-70% of full capacity (baseline velocity established)
- **Key Milestone:** Automated company research with LLM-powered analysis

---

### Backlog Items

#### User Story 3.1: Service 1 - Research Engine Core
**Story ID:** SVC1-001
**Story Points:** 13
**Priority:** P0 (Critical)
**Business Value:** Automates 4-6 hours of manual research work per client

**Description:**
As a sales agent, I need automated market research so that I can understand a client's business without manual analysis.

**Acceptance Criteria:**
- [ ] API endpoints:
  - `POST /research/start` - Initiate research for client
  - `GET /research/{research_id}` - Get research status
  - `GET /research/{research_id}/results` - Get research results
- [ ] Web scraping pipeline (company website, LinkedIn, Crunchbase)
  - Respect robots.txt and rate limits
  - Extract company description, industry, size, funding
- [ ] LLM-powered analysis using @workflow/llm-sdk
  - Generate business model summary
  - Identify pain points and automation opportunities
  - Extract tech stack mentions
- [ ] Kafka producer for `research_events` (research_started, research_completed, research_failed)
- [ ] Kafka consumer for `client_events` (client_created → trigger research)
- [ ] PostgreSQL storage for research results (multi-tenant with RLS)
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests (end-to-end research flow)

**Technical Implementation:**
```python
# services/service-1/research_engine.py
from workflow.llm_sdk import LLMClient
import httpx
from bs4 import BeautifulSoup

class ResearchEngine:
    def __init__(self, organization_id: str, llm_client: LLMClient):
        self.organization_id = organization_id
        self.llm = llm_client

    async def research_company(self, company_name: str, website: str) -> dict:
        """
        Automated company research pipeline.

        Returns:
            {
                "company_name": str,
                "industry": str,
                "size": str,
                "business_model": str,
                "pain_points": List[str],
                "automation_opportunities": List[str],
                "tech_stack": List[str]
            }
        """
        # 1. Scrape company website
        website_content = await self._scrape_website(website)

        # 2. LLM analysis
        analysis_prompt = f"""
        Analyze this company based on their website content:

        Company: {company_name}
        Website Content: {website_content[:5000]}

        Extract:
        1. Industry and sector
        2. Company size (estimate: startup/SMB/enterprise)
        3. Business model (B2B/B2C/marketplace/etc)
        4. Key pain points they likely face
        5. Automation opportunities (where AI agents could help)
        6. Tech stack mentions (languages, frameworks, platforms)

        Format as JSON.
        """

        analysis = await self.llm.chat(analysis_prompt, complexity="complex")
        return json.loads(analysis)

    async def _scrape_website(self, url: str) -> str:
        """Scrape company website with rate limiting."""
        async with httpx.AsyncClient() as client:
            response = await client.get(url, follow_redirects=True, timeout=10.0)
            soup = BeautifulSoup(response.text, 'html.parser')

            # Extract main content
            return soup.get_text(separator=' ', strip=True)
```

**API Example:**
```bash
# Start research
POST /research/start
{
  "client_id": "550e8400-e29b-41d4-a716-446655440000",
  "company_name": "Acme Corp",
  "website": "https://acme.example.com"
}

# Response
{
  "research_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "status": "in_progress",
  "estimated_completion": "2025-10-10T14:35:00Z"
}

# Get results
GET /research/7c9e6679-7425-40de-944b-e07fc1f90ae7/results

# Response
{
  "research_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "status": "completed",
  "company_name": "Acme Corp",
  "industry": "E-commerce",
  "size": "SMB",
  "business_model": "B2C marketplace",
  "pain_points": [
    "High customer support volume",
    "Slow order processing",
    "Inventory management complexity"
  ],
  "automation_opportunities": [
    "Customer support chatbot",
    "Automated order confirmation",
    "Inventory forecasting with AI"
  ],
  "tech_stack": ["React", "Node.js", "MongoDB"],
  "completed_at": "2025-10-10T14:32:45Z"
}
```

---

#### User Story 3.2: @workflow/config-sdk Library Foundation
**Story ID:** LIB-002
**Story Points:** 8
**Priority:** P1 (High)
**Business Value:** Enables hot-reload of JSON configs across all services

**Description:**
As a backend engineer, I need a shared configuration management library so that services can load and hot-reload JSON configurations without restarts.

**Acceptance Criteria:**
- [ ] Python package `@workflow/config-sdk` created
- [ ] Load JSON configs from S3 with caching (Redis)
- [ ] JSON Schema validation before applying configs
- [ ] Hot-reload support (Redis pub/sub for config update notifications)
- [ ] Multi-tenant config isolation (configs namespaced by `organization_id`)
- [ ] Versioning support (semantic versioning for configs)
- [ ] Rollback capability (revert to previous config version)
- [ ] Unit tests (80%+ coverage)
- [ ] Published to private PyPI or shared via Git submodule

**Technical Implementation:**
```python
# @workflow/config-sdk/config_manager.py
import json
import redis
import boto3
from jsonschema import validate

class ConfigManager:
    def __init__(self, organization_id: str, redis_client: redis.Redis, s3_bucket: str):
        self.organization_id = organization_id
        self.redis = redis_client
        self.s3 = boto3.client('s3')
        self.s3_bucket = s3_bucket
        self.cache_key = f"config:{organization_id}"

    async def load_config(self, config_name: str, schema: dict) -> dict:
        """
        Load configuration from S3 with Redis caching.

        Args:
            config_name: Name of config file (e.g., "chatbot-config.json")
            schema: JSON Schema for validation

        Returns:
            Validated configuration dictionary
        """
        # Check cache first
        cached = self.redis.get(self.cache_key)
        if cached:
            return json.loads(cached)

        # Load from S3
        s3_key = f"configs/{self.organization_id}/{config_name}"
        response = self.s3.get_object(Bucket=self.s3_bucket, Key=s3_key)
        config = json.loads(response['Body'].read())

        # Validate schema
        validate(instance=config, schema=schema)

        # Cache in Redis (TTL: 5 minutes)
        self.redis.setex(self.cache_key, 300, json.dumps(config))

        return config

    def subscribe_to_updates(self, callback):
        """
        Subscribe to config update notifications via Redis pub/sub.

        Args:
            callback: Function to call when config updates (hot-reload)
        """
        pubsub = self.redis.pubsub()
        pubsub.subscribe(f"config_updates:{self.organization_id}")

        for message in pubsub.listen():
            if message['type'] == 'message':
                # Invalidate cache and reload config
                self.redis.delete(self.cache_key)
                callback()
```

---

#### User Story 3.3: Kafka Topic Setup for Pre-Sales Workflow
**Story ID:** PLAT-006
**Story Points:** 5
**Priority:** P0 (Critical)
**Business Value:** Event-driven coordination between Services 0, 1, 2, 3

**Description:**
As a platform engineer, I need Kafka topics for pre-sales workflow so that services can coordinate asynchronously.

**Acceptance Criteria:**
- [ ] Kafka topics created:
  - `client_events` (10 partitions, replication factor 3)
  - `research_events` (10 partitions, replication factor 3)
- [ ] Topic retention configured (7 days)
- [ ] Consumer groups created:
  - `service-1-client-events-consumer` (Service 1 consumes client_events)
  - `service-2-research-events-consumer` (Service 2 consumes research_events)
- [ ] Schema registry setup (optional, Avro schemas for event validation)
- [ ] Kafka monitoring enabled (Prometheus exporter)

---

#### User Story 3.4: Service 1 Dashboard in Grafana
**Story ID:** OBS-001
**Story Points:** 3
**Priority:** P2 (Medium)
**Business Value:** Visibility into research performance and costs

**Description:**
As an SRE, I need a Service 1 dashboard so that I can monitor research pipeline performance and LLM costs.

**Acceptance Criteria:**
- [ ] Grafana dashboard created with panels:
  - Research request rate (requests/minute)
  - Research completion time (P50, P95, P99)
  - Research success/failure rate
  - LLM cost per research (GPT-4 token usage)
  - Kafka lag (client_events consumer lag)

---

### Technical Implementation Details

#### Services to Implement
1. **Service 1: Research Engine** (FastAPI, @workflow/llm-sdk, BeautifulSoup)
2. **@workflow/config-sdk library** (Python, Redis, boto3)

#### APIs to Develop
- `POST /research/start` - Start research
- `GET /research/{id}` - Get research status
- `GET /research/{id}/results` - Get research results
- `DELETE /research/{id}` - Cancel research (optional)

#### Database Schema
```sql
CREATE TABLE research_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,  -- Multi-tenancy
  client_id UUID NOT NULL,
  company_name TEXT NOT NULL,
  website TEXT,
  industry TEXT,
  company_size TEXT,
  business_model TEXT,
  pain_points JSONB,
  automation_opportunities JSONB,
  tech_stack JSONB,
  status TEXT CHECK (status IN ('in_progress', 'completed', 'failed')),
  error_message TEXT,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  FOREIGN KEY (organization_id) REFERENCES organizations(id)
);

-- RLS policy
ALTER TABLE research_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY research_results_tenant_isolation ON research_results
  USING (organization_id = current_setting('app.current_tenant_id')::UUID);

-- Index for fast lookups
CREATE INDEX idx_research_client_id ON research_results(client_id);
CREATE INDEX idx_research_status ON research_results(status);
```

#### Integration Points
- **Service 0 → Kafka → Service 1:** `client_events` (client_created) triggers research
- **Service 1 → @workflow/llm-sdk:** LLM analysis of company data
- **Service 1 → Kafka:** Publish `research_events` (research_completed)
- **Service 1 → PostgreSQL:** Store research results with RLS

---

### Architecture Decisions

#### Decision 3.1: Web Scraping vs. API Integrations
**Context:**
Need to gather company data for research.

**Options Considered:**
1. Web scraping (flexible, no API keys required)
2. Third-party APIs (Clearbit, ZoomInfo) - expensive, limited data
3. Hybrid approach

**Chosen Approach:**
Web scraping with rate limiting + respect robots.txt

**Rationale:**
- Free (no API costs)
- Flexible (can scrape any public website)
- LLM can extract insights from unstructured HTML
- Upgrade to third-party APIs later if needed (not MVP-critical)

**Implementation Notes:**
- Use `httpx` for async HTTP requests
- Rate limit: 1 request per second per domain
- Timeout: 10 seconds per request
- Retry logic: 3 retries with exponential backoff

---

#### Decision 3.2: Config Storage (S3 vs. Database)
**Context:**
Need to store JSON configs for agent configurations.

**Options Considered:**
1. S3 (object storage, versioned, cheap)
2. PostgreSQL (relational, queryable, ACID)
3. Redis (fast, in-memory, no persistence by default)

**Chosen Approach:**
S3 for storage + Redis for caching

**Rationale:**
- S3 provides versioning out-of-the-box (rollback support)
- Cheap storage for large JSON configs
- Redis caching reduces S3 API calls (5-minute TTL)
- Clear separation: S3 = source of truth, Redis = performance layer

---

### Dependencies & Prerequisites

**Technical Dependencies:**
- Sprint 2 complete (@workflow/llm-sdk available, observability stack deployed)
- S3 bucket created for config storage
- Redis cluster operational

**External Dependencies:**
- None

**Blockers:**
- None anticipated

**Risk Mitigation:**
- **Risk:** LLM analysis produces incorrect results
  - **Mitigation:** Validate LLM outputs with structured prompts (JSON format), human review for first 10 research reports
- **Risk:** Web scraping blocked by anti-bot mechanisms
  - **Mitigation:** Use rotating user agents, add CAPTCHA solving later if needed, focus on simple websites in Sprint 3

---

### Testing Strategy

#### Unit Testing
- **Service 1:**
  - Web scraping logic (mock HTTP responses)
  - LLM prompt formatting (no actual LLM calls)
  - Kafka event publishing (mock Kafka producer)
  - Database operations (testcontainers with PostgreSQL)

#### Integration Testing
- **End-to-End Research Flow:**
  - Publish `client_events` → Service 1 consumes → Starts research → LLM analysis → Stores results → Publishes `research_events`
  - Verify research results stored in database
  - Verify Kafka events published correctly

**Example Test:**
```python
# tests/integration/test_research_flow.py
def test_client_created_triggers_research():
    # 1. Publish client_events
    kafka_producer.send('client_events', {
        "event_type": "client_created",
        "client_id": "550e8400-e29b-41d4-a716-446655440000",
        "company_name": "Acme Corp",
        "website": "https://acme.example.com"
    })

    # 2. Wait for Service 1 to process
    time.sleep(5)

    # 3. Verify research started
    response = client.get("/research?client_id=550e8400-e29b-41d4-a716-446655440000")
    assert response.status_code == 200
    assert response.json()["status"] == "completed"

    # 4. Verify Kafka event published
    events = consume_kafka_topic("research_events", timeout=5)
    assert any(e["event_type"] == "research_completed" for e in events)
```

#### Performance Testing
- **Research Latency:** Complete research in <30 seconds (95th percentile)
- **LLM Cost:** <$0.50 per research (GPT-4 tokens)

#### Security Testing
- **Tenant Isolation:** User from Tenant A cannot access research results from Tenant B
- **Web Scraping Safety:** Verify robots.txt respected, no DDOS-like behavior

---

### DevOps & Deployment

#### CI/CD Updates
- Add CI pipeline for Service 1 (similar to Service 0)
- Add CI pipeline for @workflow/config-sdk (unit tests + publish to PyPI)

#### Infrastructure Changes
- **S3 Bucket:** Create `workflow-automation-configs` bucket
- **Kafka Topics:** Create `client_events`, `research_events` via Terraform

**Terraform Example:**
```hcl
# terraform/kafka.tf
resource "aws_msk_topic" "client_events" {
  cluster_arn        = aws_msk_cluster.main.arn
  topic_name         = "client_events"
  partitions         = 10
  replication_factor = 3

  config = {
    "retention.ms" = "604800000"  # 7 days
  }
}
```

---

### Observability

#### Metrics to Track
- **Service 1 Metrics:**
  - `service1_research_requests_total` (counter)
  - `service1_research_duration_seconds` (histogram)
  - `service1_research_success_total` (counter)
  - `service1_research_failed_total` (counter)
  - `service1_llm_cost_dollars` (counter) - Estimated LLM cost per research
  - `service1_scraping_duration_seconds` (histogram) - Website scraping latency
  - `service1_kafka_lag` (gauge) - Consumer lag on client_events

#### Alerts to Configure
- **Critical:**
  - Service 1 unhealthy (no healthy pods for 2 minutes)
  - Kafka consumer lag >1000 messages
- **Warning:**
  - Research failure rate >10%
  - Research latency P95 >45 seconds
  - LLM cost >$1.00 per research (cost anomaly)

---

### Documentation

#### Technical Documentation
- **ADR:** `docs/adr/006-web-scraping-strategy.md`
- **ADR:** `docs/adr/007-config-storage-choice.md`
- **Service README:** `services/service-1/README.md`

#### API Documentation
- OpenAPI spec auto-generated from FastAPI
- Published to `https://api.workflow-automation.com/docs`

#### Operational Runbooks
- **Runbook:** "Service 1 - High Research Latency"
- **Runbook:** "Service 1 - Kafka Consumer Lag"

---

### Risk Mitigation

**Risk 1: LLM Hallucination in Research Analysis**
- **Probability:** Medium (60%)
- **Impact:** Medium (incorrect research results)
- **Mitigation:**
  - Use structured prompts with JSON output format
  - Validate LLM outputs with JSON Schema
  - Human review of first 10 research reports
  - Add confidence scores to LLM outputs
- **Contingency:** Fall back to keyword extraction if LLM analysis is unreliable

**Risk 2: Web Scraping Blocked by Anti-Bot**
- **Probability:** Medium (40%)
- **Impact:** High (research pipeline fails)
- **Mitigation:**
  - Rotate user agents
  - Respect robots.txt and rate limits
  - Add delays between requests (1 second)
- **Contingency:** Use third-party APIs (Clearbit) as fallback (adds cost but ensures reliability)

---

### Sprint Retrospective Preparation

#### Success Criteria
- [ ] Service 1 deployed to dev environment
- [ ] At least 5 successful end-to-end research flows
- [ ] @workflow/config-sdk published and tested
- [ ] Kafka topics operational with consumer lag <100 messages
- [ ] Service 1 dashboard in Grafana showing metrics

#### Metrics to Measure
- **Story Points Completed:** Target 29
- **Velocity:** Compare to Sprint 1-2 baseline
- **Research Success Rate:** Target 90%+
- **Average Research Latency:** Target <30 seconds P95
- **LLM Cost per Research:** Target <$0.50

---

### Task Breakdown & AI Productivity Classification

#### Well-Defined Implementation Tasks (High AI Productivity: 1.4-1.55x)
- **Estimated Effort without AI:** 30 hours
- **Estimated Effort with AI:** 19-21 hours
- **Tasks:**
  - API endpoint scaffolding
  - Database schema and migrations
  - Kafka producer/consumer boilerplate
  - @workflow/config-sdk basic implementation
  - Unit test scaffolding
  - Grafana dashboard JSON generation

#### Exploratory/Complex Tasks (Low AI Productivity: 0.8-1.0x)
- **Estimated Effort without AI:** 15 hours
- **Estimated Effort with AI:** 15-18 hours
- **Tasks:**
  - LLM prompt engineering (research analysis)
  - Web scraping strategy and anti-bot mitigation
  - Config hot-reload architecture
  - Performance optimization (research latency)

#### Total Sprint 3 Effort Estimate
- **Without AI:** 45 hours
- **With Strategic AI Use:** 34-39 hours (13-24% faster)
- **Team Capacity:** 6 engineers × 4 productive hours/day × 5 days = 120 hours available
- **Utilization:** 28-32% (conservative, allows time for research/experimentation)

---


## SPRINT 4: Demo Generator & Sales Documents (Week 4)

### Sprint Goal
Implement Services 2-3 (Demo Generator, Sales Document Generator) completing the pre-sales automation workflow.

### Sprint Metadata
- **Sprint Number:** 4
- **Duration:** 1 week
- **Team Velocity:** 70-80% of full capacity (baseline established)
- **Key Milestone:** End-to-end automation from research → demo → NDA/proposal

---

### Backlog Items

#### User Story 4.1: Service 2 - Demo Generator (Basic)
**Story ID:** SVC2-001 | **Story Points:** 13 | **Priority:** P0

**Description:** AI-powered demo generation based on research results.

**Key Deliverables:**
- API: `POST /demos/generate`, `GET /demos/{id}`, `PATCH /demos/{id}/approve`
- LLM prompt templates for demo script generation
- Kafka: Consume `research_events`, produce `demo_events`
- Database: Store demos with RLS
- Integration: Research results → Demo generation → Client approval workflow

**Architecture Decision 4.1: Demo Generation Strategy**
- **Chosen:** Template-based with LLM customization (simple + reliable for MVP)
- **Rationale:** Faster than full LLM generation, maintains quality control
- **Future:** Migrate to fully AI-generated demos in later sprints

---

#### User Story 4.2: Service 3 - Sales Document Generator
**Story ID:** SVC3-001 | **Story Points:** 13 | **Priority:** P0

**Description:** Unified service for NDA, pricing, and proposal generation with e-signature.

**Key Deliverables:**
- API: `POST /sales-docs/nda`, `POST /sales-docs/pricing`, `POST /sales-docs/proposal`
- DocuSign integration for e-signature
- PDF generation from templates (WeasyPrint or similar)
- Kafka: Consume `demo_events`, produce `sales_doc_events`
- Database: Store documents with RLS

**Architecture Decision 4.2: E-Signature Provider**
- **Chosen:** DocuSign API (industry standard, robust)
- **Rationale:** Best integration docs, trusted by enterprises
- **Alternative:** HelloSign (simpler but less features)

---

#### User Story 4.3: Kong API Gateway Configuration
**Story ID:** PLAT-007 | **Story Points:** 8 | **Priority:** P0

**Description:** Configure Kong for authentication, rate limiting, and routing.

**Key Deliverables:**
- Kong deployed to Kubernetes
- JWT validation plugin configured (Service 0 integration)
- Rate limiting per tenant (100 req/min free tier, 1000 req/min paid)
- Service routing rules (Service 0, 1, 2, 3)
- Admin API secured

---

#### User Story 4.4: Alpha Release Testing
**Story ID:** TEST-001 | **Story Points:** 8 | **Priority:** P1

**Description:** End-to-end testing of pre-sales workflow for Alpha release.

**Test Scenarios:**
1. Signup → Research → Demo → NDA → Approved
2. Multi-tenant isolation (2 orgs simultaneously)
3. Error handling (research fails, demo rejected)
4. Performance (research <30s P95, demo <60s P95)
5. Cost tracking (LLM costs per workflow)

---

### Technical Implementation Details

**Services to Implement:**
1. **Service 2: Demo Generator** (FastAPI, @workflow/llm-sdk, Jinja2 templates)
2. **Service 3: Sales Document Generator** (FastAPI, DocuSign SDK, WeasyPrint)

**Database Schemas:**
```sql
-- Service 2 schema
CREATE TABLE demos (
  id UUID PRIMARY KEY,
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  research_id UUID NOT NULL,
  script TEXT,
  status TEXT CHECK (status IN ('generated', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service 3 schema
CREATE TABLE sales_documents (
  id UUID PRIMARY KEY,
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  document_type TEXT CHECK (document_type IN ('nda', 'pricing', 'proposal')),
  pdf_url TEXT,
  signature_status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Integration Points:**
- Service 1 → Kafka (`research_events`) → Service 2
- Service 2 → Kafka (`demo_events`) → Service 3
- Service 3 → DocuSign API (e-signature)
- Kong → Services 0, 1, 2, 3 (routing + auth)

---

### Sprint Retrospective Metrics
- **Story Points:** Target 42
- **End-to-End Test Success Rate:** 95%+
- **Alpha Release:** Complete pre-sales workflow operational

---

## SPRINT 5-8 SUMMARY: Transition to 2-Week Sprints

**Note:** Starting Sprint 9, we transition to 2-week sprints for improved velocity and reduced context-switching.

---

## SPRINT 5: PRD Builder Foundation (Week 5)

**Goal:** Implement Service 6 (PRD Builder) basic functionality - PRD generation from research/demo data.

**Key Deliverables:**
- Service 6 API: `POST /prd/generate`, `GET /prd/{id}`, `PATCH /prd/{id}`
- LLM-powered PRD generation from structured inputs
- Kafka: Consume `sales_doc_events`, produce `prd_events`
- Village knowledge foundation (basic RAG with Qdrant)

**Story Points:** 34

---

## SPRINT 6: Automation Engine & Config Generation (Week 6)

**Goal:** Implement Service 7 (Automation Engine) - convert PRD to JSON config.

**Key Deliverables:**
- Service 7 API: `POST /configs/generate`, `GET /configs/{id}`, `POST /configs/{id}/deploy`
- JSON config generation from PRD
- JSON Schema validation
- Kafka: Consume `prd_events`, produce `config_events`
- @workflow/config-sdk integration

**Story Points:** 34

**Architecture Decision 6.1: Config Generation Strategy**
- **Chosen:** Rule-based extraction + LLM gap-filling
- **Rationale:** More reliable than pure LLM, easier to debug

---

## SPRINT 7: RAG Pipeline Foundation (Week 7)

**Goal:** Implement Service 17 (RAG Pipeline) - document ingestion and FAQ management.

**Key Deliverables:**
- Service 17 API: Document upload, FAQ CRUD
- Qdrant vector DB integration (embeddings with OpenAI)
- Neo4j graph DB integration (entity relationships)
- Multi-tenant namespaces in Qdrant/Neo4j
- Kafka: Produce `rag_events`

**Story Points:** 34

---

## SPRINT 8: Basic Chatbot Runtime (Week 8 - Alpha Release)

**Goal:** Implement Service 8 (Agent Orchestration) basic chatbot with LangGraph.

**Key Deliverables:**
- Service 8 API: `/chat`, `/sessions`, `/history`
- LangGraph two-node workflow (agent + tools)
- JSON config consumption via @workflow/config-sdk
- RAG integration (Service 17)
- Kafka: Produce `conversation_events`
- **Alpha Release:** Complete workflow through chatbot deployment

**Story Points:** 42

**Milestone:** Week 8 - Alpha Release Complete

---

## SPRINT 9-10: Billing & Service 22 (Weeks 9-10, 2-Week Sprint)

**Goal:** Implement Service 22 (Billing & Revenue Management) with Stripe integration.

**Key Deliverables:**
- Service 22 API: Subscription management, payment processing
- Stripe integration (Customer Portal, Webhooks)
- Dunning automation (failed payment retries)
- Kafka: Produce `billing_events`
- Tiered pricing (Free, Pro, Enterprise)

**Story Points:** 55

---

## SPRINT 11-12: Monitoring & Analytics (Weeks 11-16, 2 Sprints)

**Goal:** Implement Services 11-12 (Monitoring Engine, Analytics).

**Key Deliverables (Sprint 11):**
- Service 11: Real-time monitoring, anomaly detection, incident management
- Kafka: Produce `monitoring_incidents`
- Integration with Prometheus/Grafana

**Key Deliverables (Sprint 12):**
- Service 12: Analytics dashboards, conversation insights
- A/B testing framework (multi-armed bandit)
- Kafka: Produce `analytics_experiments`

**Story Points:** 55 per sprint (110 total)

**Milestone:** Week 16 - Beta Release (MVP)

---

## SPRINT 13-14: Voice Agent & LiveKit (Weeks 17-20, 2 Sprints)

**Goal:** Implement Service 9 (Voice Agent) with LiveKit VoicePipelineAgent.

**Key Deliverables:**
- Service 9: LiveKit integration (STT → LLM → TTS)
- Voice-specific config schema
- Cross-product coordination with Service 8
- Latency optimization (<500ms P95)
- Kafka: Produce `voice_events`, `cross_product_events`

**Story Points:** 55 per sprint (110 total)

**Architecture Decision 13.1: Voice Framework**
- **Chosen:** LiveKit VoicePipelineAgent
- **Rationale:** Purpose-built for low-latency voice, simpler than LangGraph for voice

---

## SPRINT 15-16: Customer Success & Support (Weeks 21-24, 2 Sprints)

**Goal:** Implement Services 13-14 (Customer Success, Support Engine).

**Key Deliverables (Sprint 15):**
- Service 13: Health scoring, playbook automation, QBR scheduling
- Kafka: Produce `customer_success_events`

**Key Deliverables (Sprint 16):**
- Service 14: Ticket management, escalation workflows, human handoff
- Kafka: Produce `support_events`, `escalation_events`

**Story Points:** 55 per sprint (110 total)

**Milestone:** Week 24 - Production Release v1.0

---

## SPRINT 17-18: CRM Integration & Communication (Weeks 25-28, 2 Sprints)

**Goal:** Implement Services 15, 20 (CRM Integration, Communication & Hyperpersonalization).

**Key Deliverables (Sprint 17):**
- Service 15: Salesforce/HubSpot/Zendesk bidirectional sync
- Kafka: Produce `crm_events`

**Key Deliverables (Sprint 18):**
- Service 20: Email/SMS campaigns, hyperpersonalization engine
- Kafka: Produce `communication_events`

**Story Points:** 55 per sprint (110 total)

---

## SPRINT 19-20: Agent Copilot & Final Polish (Weeks 29-32, 2 Sprints)

**Goal:** Implement Service 21 (Agent Copilot) and final system optimization.

**Key Deliverables (Sprint 19):**
- Service 21: Agent dashboard aggregating 21 Kafka topics
- Real-time context visualization
- Action recommendations
- Frontend: React dashboard with WebSocket

**Key Deliverables (Sprint 20):**
- Performance optimization (reduce P95 latencies)
- Security hardening (penetration testing)
- Load testing (1000+ concurrent sessions)
- Documentation completion
- Production readiness review

**Story Points:** 55 per sprint (110 total)

**Milestone:** Week 32 - Production Release v2.0 (Complete Platform)

---

## Testing Strategy (Platform-Wide)

### Test Pyramid
- **Unit Tests:** 80%+ coverage per service
- **Integration Tests:** All Kafka event flows tested
- **End-to-End Tests:** 10 critical user journeys
- **Performance Tests:** Load testing at 1000+ concurrent users
- **Security Tests:** Tenant isolation, OWASP Top 10, penetration testing

### Testing Tools
- **Unit:** pytest, pytest-cov
- **Integration:** testcontainers (PostgreSQL, Kafka, Redis)
- **E2E:** Playwright for frontend, Postman/REST for APIs
- **Load:** K6 (load testing), Locust (alternative)
- **Security:** Bandit, Safety, OWASP ZAP

### CI/CD Testing Gates
- All unit tests must pass (no exceptions)
- Integration tests must pass for main branch merges
- Code coverage must be ≥75% (service-level)
- Security scans must have 0 critical vulnerabilities

---

## DevOps & Deployment (Platform-Wide)

### Deployment Strategy
- **Development:** Continuous deployment on every merge to main
- **Staging:** Manual promotion after QA sign-off
- **Production:** Blue-green deployment with manual approval

### Infrastructure as Code
- **Terraform:** All infrastructure (Kubernetes, RDS, Redis, Kafka, S3)
- **Helm:** Service packaging and deployment
- **Argo CD:** GitOps continuous deployment

### Environments
- **dev:** Shared development environment (1 Kubernetes cluster)
- **staging:** Production-like environment (separate cluster)
- **production:** High-availability (multi-AZ, auto-scaling)

### Disaster Recovery
- **RTO (Recovery Time Objective):** 1 hour
- **RPO (Recovery Point Objective):** 15 minutes
- **Database Backups:** Daily full + continuous WAL archiving (PostgreSQL)
- **Config Backups:** S3 versioning enabled
- **Kafka Backups:** MirrorMaker 2.0 for cross-region replication (production only)

---

## Risk Management (Platform-Wide)

### High-Priority Risks

#### Risk 1: Multi-Tenancy Data Leakage
- **Probability:** Low (10%)
- **Impact:** Critical (regulatory breach, loss of trust)
- **Mitigation:**
  - PostgreSQL RLS enforced on ALL tables
  - Automated tenant isolation tests on every endpoint
  - Quarterly security audits
  - Bug bounty program post-launch
- **Contingency:** Immediate incident response, notify affected tenants within 24 hours

#### Risk 2: LLM Cost Explosion
- **Probability:** Medium (40%)
- **Impact:** High (budget overruns)
- **Mitigation:**
  - Per-tenant token budgets with hard limits
  - Semantic caching (Helicone) for 40-60% cost reduction
  - Model routing (GPT-3.5 for simple, GPT-4 for complex)
  - Real-time cost dashboards
- **Contingency:** Throttle LLM calls per tenant, upgrade pricing tiers

#### Risk 3: Latency SLA Violations (Voice Agent)
- **Probability:** Medium (50%)
- **Impact:** High (poor user experience)
- **Mitigation:**
  - Linkerd service mesh (163ms faster than Istio)
  - Direct LLM integration via @workflow/llm-sdk (no gateway)
  - LiveKit optimization (dedicated voice servers)
  - Continuous latency monitoring (P95 alerts)
- **Contingency:** Add more Kubernetes nodes, optimize LLM prompts, use streaming responses

#### Risk 4: Team Velocity Lower Than Estimated
- **Probability:** High (70%)
- **Impact:** Medium (delayed timelines)
- **Mitigation:**
  - Conservative sprint planning (30% capacity Sprint 1, ramping to 80%)
  - Track velocity and adjust sprint scope
  - AI productivity tools (Claude Code) for 10-20% acceleration
  - Pair programming for knowledge sharing
- **Contingency:** Descope non-MVP features, extend timeline by 2-4 weeks

---

## Quality Assurance (Platform-Wide)

### Code Quality Standards
- **Linting:** Black (Python formatting), Pylint (static analysis), mypy (type checking)
- **Code Review:** Mandatory for all PRs, 2 approvals for security-critical code
- **Documentation:** Every service has README, API documentation (OpenAPI), runbooks

### Performance Standards
- **API Latency:** P95 <500ms (chatbot), P95 <300ms (voicebot)
- **Database Query Latency:** P95 <50ms
- **Kafka Consumer Lag:** <100 messages during normal operation
- **Uptime:** 99.9% SLA for production

### Security Standards
- **Authentication:** JWT (RS256) on all endpoints
- **Authorization:** RLS + application-level tenant checks
- **Encryption:** TLS 1.3 in transit, AES-256 at rest
- **Secrets:** External Secrets Operator + AWS Secrets Manager (no secrets in Git)
- **Vulnerability Scanning:** Weekly dependency scans, quarterly penetration testing

---

## Sprint Planning Summary Table

| Sprint | Duration | Weeks | Key Deliverables | Story Points | Milestone |
|--------|----------|-------|------------------|--------------|-----------|
| 1 | 1 week | Week 1 | Service 0, Kubernetes, CI/CD | 34 | Foundation |
| 2 | 1 week | Week 2 | Observability, Linkerd, @workflow/llm-sdk | 42 | Infrastructure |
| 3 | 1 week | Week 3 | Service 1, @workflow/config-sdk | 29 | Research Engine |
| 4 | 1 week | Week 4 | Services 2-3, Kong, Alpha Testing | 42 | **Alpha Release** |
| 5 | 1 week | Week 5 | Service 6 (PRD Builder) | 34 | |
| 6 | 1 week | Week 6 | Service 7 (Automation Engine) | 34 | |
| 7 | 1 week | Week 7 | Service 17 (RAG Pipeline) | 34 | |
| 8 | 1 week | Week 8 | Service 8 (Basic Chatbot) | 42 | |
| 9-10 | 2 weeks | Weeks 9-10 | Service 22 (Billing) | 55 | |
| 11-12 | 2 weeks | Weeks 11-16 | Services 11-12 (Monitoring, Analytics) | 110 | **Beta (MVP)** |
| 13-14 | 2 weeks | Weeks 17-20 | Service 9 (Voice Agent) | 110 | |
| 15-16 | 2 weeks | Weeks 21-24 | Services 13-14 (Customer Success, Support) | 110 | **Prod v1.0** |
| 17-18 | 2 weeks | Weeks 25-28 | Services 15, 20 (CRM, Communication) | 110 | |
| 19-20 | 2 weeks | Weeks 29-32 | Service 21 (Agent Copilot), Polish | 110 | **Prod v2.0** |

**Total Story Points:** ~890
**Total Duration:** 32 weeks (8 months)
**Total Services:** 17 microservices + 2 libraries

---

## Appendix A: Glossary of Terms

- **RLS:** Row-Level Security (PostgreSQL multi-tenancy enforcement)
- **ADR:** Architecture Decision Record
- **SLA:** Service Level Agreement
- **P95:** 95th percentile (performance metric)
- **mTLS:** Mutual TLS (secure service-to-service communication)
- **GitOps:** Infrastructure as code managed via Git
- **RAG:** Retrieval-Augmented Generation (LLM + knowledge base)
- **Village Knowledge:** Shared insights across clients (privacy-preserving)

---

## Appendix B: Contact & Escalation

**Project Leadership:**
- **Tech Lead/Architect:** [Name] - Architecture decisions, code review
- **Product Manager:** [Name] - Backlog prioritization, stakeholder communication
- **SRE Lead:** [Name] - Infrastructure, incident response

**Escalation Path:**
1. **Technical Blockers:** Report to Tech Lead within 4 hours
2. **Production Incidents:** Page SRE Lead immediately (24/7 on-call)
3. **Scope Changes:** Product Manager approval required

---

## Document Maintenance

**Version History:**
- **v1.0 (2025-10-10):** Initial comprehensive sprint plan
- **Future Updates:** After each sprint retrospective, update velocity and adjust remaining sprints

**Review Schedule:**
- **Weekly:** Sprint planning (refine next sprint backlog)
- **Bi-weekly:** Retrospective (update sprint plan based on learnings)
- **Monthly:** Roadmap review (ensure alignment with business goals)

**Document Owner:** Tech Lead / Product Manager

---

**END OF COMPREHENSIVE SPRINT PLAN**
