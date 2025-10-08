# Microservices Architecture Specification
## Complete Workflow Automation System

---

## Executive Summary

This document defines the comprehensive microservices architecture for an AI-powered workflow automation platform that automates client onboarding, demo generation, PRD creation, implementation, monitoring, and customer success. The architecture decomposes a complex workflow into **15 specialized microservices** (Services 0, 1, 2, 3, 6, 7, 8, 9, 11-15, 17, 20, 21) plus 2 supporting libraries (@workflow/llm-sdk, @workflow/config-sdk).

**Architecture Optimization**: This architecture has been optimized from an initial 22-service design through strategic consolidation. The optimization eliminated distributed monolith anti-patterns, shared database issues, and unnecessary network hops, improving architecture health from 6.5/10 to 9+/10. Services 0.5, 4, 5, 10, 16, 18, 19 have been consolidated or converted to libraries.

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
- Structured human agent lifecycle (Sales → Onboarding → Support → Success) with seamless handoffs
- Human-in-the-loop supervision: Humans "tie shoelaces" (10-40% touch) while AI handles execution (60-90%)

**Human-in-the-Loop Philosophy:**
The architecture maintains **maximum automation while preserving human supervision and strategic decision-making**:

- **Sales Stage (40% human touch)**: AI handles research, demo generation, document creation; Human handles relationship building, negotiation, strategic decisions
- **Onboarding Stage (40% human touch)**: AI drives PRD creation, config generation, testing; Human provides expert guidance, reviews technical architecture, supervises launch
- **Support Stage (10% human touch)**: AI handles 90% of tickets autonomously; Human handles complex escalations, config tuning, quality supervision
- **Success Stage (10% human touch)**: AI monitors KPIs daily; Human conducts QBRs, identifies strategic opportunities, drives renewals
- **Upsell/Iteration**: Human specialists invited dynamically by Success Managers for expansion opportunities

Human agents work **alongside AI**, not **instead of AI**. Humans supervise, review, handle exceptions, and make strategic decisions while AI executes the tactical work at scale.

---

## Role Definitions & Authentication Model

This section clarifies the distinction between **organizational roles** (client-facing) and **operational roles** (human agents working the platform):

### Organizational Roles (Client-Side)
These are roles assigned to users within **client organizations**:
- **Organization Admin**: Client company administrator (e.g., Jane Smith from Example Corp)
- **Organization Member**: Standard user within client company
- **Organization Viewer**: Read-only access to client company data

### Operational Roles (Platform-Side Human Agents)
These are roles assigned to **human agents** who operate the platform on behalf of clients:
- **Platform Admin**: Full system access, can manage all organizations, agents, and configurations (rare, primarily for platform engineers)
- **Sales Agent**: Creates assisted signups, manages sales pipeline, demos, NDAs, proposals
- **Onboarding Specialist**: Conducts client onboarding, PRD creation, implementation setup
- **Support Specialist**: Handles support tickets, escalations, technical issues
- **Success Manager**: Monitors KPIs, conducts QBRs, identifies upsell/cross-sell opportunities
- **Sales Specialist**: Invited dynamically for upsell/cross-sell during success stage
- **AI Supervisor**: Monitors AI agent quality, tunes configurations, handles edge cases
- **Platform Engineer**: Infrastructure management, deployment, system administration

### Key Distinctions
- **Platform Admin ≠ Sales Agent**: Platform Admin is a system administrator role (infrastructure, full access); Sales Agent is an operational role (sales workflow, limited to assigned clients)
- **Multi-Role Support**: A single human can have multiple operational roles (e.g., Sam can be both Sales Agent AND Onboarding Specialist)
- **Permission Model**: Operational roles have granular permissions defined in Human Agent Management Service (0.5), not organizational permissions

### Authentication Architecture
All users (both client organization users AND platform human agents) authenticate through the **Organization Management & Authentication Service (0)**:

**For Client Organization Users:**
- Stored in `auth.users` table with `user_type: 'client'`
- Linked to specific organization via `organization_id`
- Role field contains: `admin`, `member`, `viewer`
- Multi-tenant isolation enforced via Row-Level Security (RLS)

**For Platform Human Agents:**
- Stored in `auth.users` table with `user_type: 'agent'`
- Linked to `agent_profiles` table in Human Agent Management Service
- Role field contains: `platform_admin`, `sales_agent`, `onboarding_specialist`, etc.
- Can have multiple roles stored in `agent_profiles.roles` (JSON array)
- Permissions stored in `agent_profiles.permissions` (JSON object)
- JWT tokens include `user_type: 'agent'` and `agent_id` for cross-service authorization

**JWT Token Structure for Human Agents:**
```json
{
  "user_id": "uuid",
  "user_type": "agent",
  "agent_id": "uuid",
  "email": "sam@workflow.com",
  "primary_role": "sales_agent",
  "all_roles": ["sales_agent", "onboarding_specialist"],
  "permissions": {
    "assisted_signup": ["create", "read", "update"],
    "research_engine": ["read", "trigger"],
    "demo_generator": ["read", "create", "approve"]
  },
  "organization_id": null,  // Agents don't belong to client orgs
  "exp": 1728392400
}
```

**Authorization Flow for Assisted Signup (Fixed - No Circular Dependency):**

**Authentication happens in Kong API Gateway (not in services):**

1. **Sales Agent Login** → Org Management Service authenticates → Returns JWT with:
   ```json
   {
     "user_id": "uuid",
     "user_type": "agent",
     "agent_id": "uuid",
     "primary_role": "sales_agent",
     "exp": 1728392400
   }
   ```

2. **Sales Agent calls** `POST /api/v1/auth/assisted-signup` → Request goes through **Kong API Gateway**

3. **Kong API Gateway Authorization:**
   - Validates JWT signature and expiration
   - Extracts `user_type` and `agent_id` from JWT
   - If `user_type === 'agent'`:
     - Calls `GET /api/v1/agents/{agent_id}/permissions` (Human Agent Management Service)
     - Receives permissions JSON: `{"assisted_signup": ["create", "read", "update"]}`
     - Checks if `assisted_signup.create` exists in permissions
   - If authorized: Injects `X-Agent-ID` and `X-Agent-Permissions` headers, forwards to Org Management
   - If unauthorized: Returns 403 Forbidden BEFORE reaching Org Management

4. **Org Management Service receives pre-authorized request:**
   - Trusts Kong's authorization (headers: `X-Agent-ID`, `X-Agent-Permissions`)
   - Creates assisted account
   - Publishes `assisted_account_created` event to Kafka

5. **Human Agent Management Service (Kafka consumer):**
   - Listens to `assisted_account_created` event
   - Auto-assigns client to creating agent
   - Publishes `client_assigned_to_agent` event

**No Circular Dependency:**
- Org Management NEVER calls Human Agent Management
- Kong API Gateway handles permission checks BEFORE routing
- Services remain decoupled and stateless

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
│   Topics (17): auth_events, org_events, agent_events,           │
│   client_events, prd_events, demo_events, sales_doc_events,     │
│   research_events, config_events, conversation_events,          │
│   voice_events, escalation_events, monitoring_incidents,        │
│   analytics_experiments, customer_success_events,               │
│   support_events, communication_events, cross_product_events    │
│   (Consolidated from 19 topics)                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴──────────────────────┐
         │                                           │
         ▼                                           ▼
┌─────────────────┐                        ┌──────────────────┐
│  Core Services  │                        │  Support Services│
├─────────────────┤                        ├──────────────────┤
│ 0. Org & ID     │                        │ 11. Monitoring   │
│    Management   │                        │ 12. Analytics    │
│    (merged 0.5) │◄───────────────────────┤ 13. Customer     │
│ 1. Research     │  (Handoffs & Routing)  │     Success      │
│ 2. Demo Gen     │                        │ 14. Support      │
│ 3. Sales Doc    │                        │ 15. CRM          │
│    Generator    │                        │     Integration  │
│    (merged 4,5) │                        │ 17. RAG Pipeline │
│ 6. PRD & Config │                        │ 20. Communication│
│    Workspace    │                        │     & Hyper-     │
│    (merged 19)  │                        │     personalize  │
│ 7. Automation   │                        │ 21. Agent Copilot│
│ 8. Agent Orch   │                        └──────────────────┘
│ 9. Voice Agent  │
└─────────────────┘

Supporting Libraries:
- @workflow/llm-sdk (formerly Service 16 - eliminates 200-500ms latency)
- @workflow/config-sdk (formerly Service 10 - eliminates 50-100ms latency)

Data Layer:
- PostgreSQL (Supabase) with RLS: Transactional data, multi-tenant isolation
- Qdrant: Vector storage for RAG, namespace-per-tenant
- Neo4j: Knowledge graphs for GraphRAG
- Redis: Caching, session state, rate limiting, auth tokens
- TimescaleDB: Time-series metrics and analytics

Architecture Optimization: 22 services → 15 services (30% reduction)
```

### Database Architecture Model

**Shared Core Database (Supabase PostgreSQL):**
- **auth.users** table: ALL users (clients + agents) with `user_type` discriminator
- **organizations** table: Client company organizations
- **team_memberships** table: Client organization memberships
- **agent_profiles** table: Human agent profiles (links to auth.users via user_id FK)

**Per-Service Databases (Dedicated PostgreSQL instances):**
- Agent Orchestration: conversations, checkpoints, thread_states
- PRD Builder: prd_documents, prd_versions, feedback
- Support Engine: tickets, ticket_messages, escalations
- Analytics: aggregated_metrics, usage_reports

**Cross-Service Foreign Keys:**
- **Shared Core → Per-Service:** Use `user_id`, `organization_id`, `agent_id` as references
- **No FK constraints across databases:** Services validate references via API calls
- **Example:** PRD Builder stores `organization_id` but validates existence by calling Org Management API `/api/v1/organizations/{id}`

**Multi-Tenant Isolation Strategy:**
1. **Shared Core:** Row-Level Security (RLS) on `organization_id` for client data
2. **Per-Service:** Application-level filtering on `organization_id`/`tenant_id`
3. **Agents:** Can access all organizations (RLS policy allows `user_type='agent'`)
4. **Vector DBs:** Namespace-per-tenant in Qdrant (e.g., `tenant_{org_id}`)

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

### 0. Organization & Identity Management Service

**Service Consolidation**: Service 0 now includes functionality previously in Service 0.5 (Human Agent Management). This consolidation eliminates the shared database anti-pattern where both services accessed the same `auth.users` table.

#### Objectives
- **Primary Purpose**: Self-service client signup, organization creation, team member management, human agent profile management, and authentication/authorization for the entire platform (both client users and platform agents)
- **Business Value**: Enables product-led growth with self-service onboarding BEFORE sales engagement, reduces sales friction, enables team collaboration from day one, supports structured human agent lifecycle management (Sales → Onboarding → Support → Success)
- **Scope Boundaries**:
  - **Does**: User signup/login (clients & agents), organization creation, team invitations, role-based permissions, work email verification, session management, OAuth integrations, human agent profile management, multi-role assignments, client-agent assignments, handoff orchestration
  - **Does Not**: Handle billing (separate service), generate content, manage workflows, train agents, manage HR/payroll

#### Requirements

**Functional Requirements:**
1. Work email signup with email verification (clients and agents)
2. Organization creation with admin role assignment
3. Team member invitation system with expiration
4. Role-based access control (Admin, Member, Viewer with custom permissions)
5. OAuth integration (Google, Microsoft, GitHub SSO)
6. Multi-factor authentication (MFA) support
7. Session management with JWT tokens
8. Organization-level settings and branding
9. Audit logging for security events
10. Team member removal and role updates
11. Assisted signup - create and maintain client accounts on their behalf with claim capability
12. Agent registration and profile management with multi-role assignments
13. Role-based access control for agents with granular permissions per service
14. Client handoff workflow orchestration (Sales → Onboarding → Support → Success → Upsell)
15. Specialist matching and routing based on skills, availability, and workload
16. Real-time agent availability and status management
17. Activity tracking and performance metrics per role
18. Queue management for each role type
19. Agent invitation and cross-selling workflow
20. Supervision mode for AI agent oversight
21. Handoff approval workflow with notes and context transfer
22. Agent workload balancing and auto-assignment

**Non-Functional Requirements:**
- Signup completion: <30 seconds
- Support 100K+ organizations
- Support 1000+ concurrent human agents
- Auth latency: <100ms P95
- Agent lookup: <50ms P95
- Handoff processing: <2 seconds
- Real-time availability updates: <500ms
- 99.99% uptime (authentication is critical path)
- GDPR/SOC 2 compliance for user data

**Dependencies:**
- Research Engine (triggered after org creation)
- PRD Builder (uses org/user context for permissions)
- Configuration Management (org-level feature flags)
- All microservices (consume agent assignments and handoffs)
- Analytics Service (agent performance metrics)
- Monitoring Engine (agent activity tracking)
- External: SendGrid (email verification), Auth0/Supabase Auth (optional managed auth)

**Data Storage:**
- PostgreSQL: Users, organizations, memberships, roles, permissions, audit logs, agent profiles, client assignments, handoffs, specialist invitations, agent activity logs
- Redis: Session tokens, email verification codes, rate limiting, real-time agent availability, queue state, active assignments
- TimescaleDB: Agent performance metrics, SLA tracking

**Database Schema:**

```sql
-- auth.users table (shared by both client users and human agents)
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  user_type TEXT NOT NULL CHECK (user_type IN ('client', 'agent')),
  organization_id UUID REFERENCES organizations(id),  -- NULL for agents
  role TEXT NOT NULL,  -- 'admin'|'member'|'viewer' for clients; 'sales_agent'|'platform_admin' etc for agents
  email_verified BOOLEAN DEFAULT FALSE,
  account_status TEXT DEFAULT 'active' CHECK (account_status IN ('active', 'assisted_unclaimed', 'claimed', 'suspended', 'deleted')),
  claim_token TEXT UNIQUE,  -- For assisted signup accounts only
  claim_token_expires_at TIMESTAMPTZ,
  created_by_agent_id UUID REFERENCES auth.users(id),  -- For assisted signup, references agent who created account
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- Row-Level Security (RLS) for multi-tenancy
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Policy: Clients can only see users in their organization
CREATE POLICY users_tenant_isolation ON auth.users
  FOR SELECT
  USING (
    user_type = 'client' AND organization_id = current_setting('app.current_organization_id')::UUID
    OR user_type = 'agent'  -- Agents can see all
  );

-- organizations table
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  website TEXT,
  industry TEXT,
  company_size TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- team_memberships table (links users to organizations with roles)
CREATE TABLE team_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'member', 'viewer')),
  permissions JSONB DEFAULT '{}',  -- Custom permissions per role
  config_permissions JSONB DEFAULT '{}',  -- Product configuration permissions (from Client Configuration Portal)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, organization_id)
);

-- config_permission_matrix (maps organization roles to config permissions)
CREATE TABLE config_permission_matrix (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'member', 'viewer', 'config_manager', 'config_viewer', 'developer')),
  permissions JSONB NOT NULL,  -- Detailed permission matrix for product configuration
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, role)
);

-- Default permission matrix structure (JSONB):
-- {
--   "can_view_configs": true,
--   "can_edit_system_prompt": false,
--   "can_edit_tools": false,
--   "can_edit_voice_params": false,
--   "can_edit_integrations": false,
--   "can_rollback_versions": false,
--   "can_deploy_configs": false,
--   "can_manage_permissions": false,
--   "max_risk_level": "low"  // low | medium | high
-- }

-- audit_logs table
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  organization_id UUID REFERENCES organizations(id),
  action TEXT NOT NULL,  -- 'login', 'signup', 'assisted_account_created', 'account_claimed', etc.
  resource_type TEXT,  -- 'user', 'organization', 'team_membership'
  resource_id UUID,
  metadata JSONB,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- agent_profiles table (extends auth.users where user_type='agent')
CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),  -- Separate agent ID for tracking
  roles JSONB NOT NULL,  -- Array of role objects with skills, certifications, languages
  -- Example: [{"role_type": "sales_agent", "primary": true, "skills": ["b2b_saas"], ...}]
  permissions JSONB NOT NULL DEFAULT '{}',  -- Granular permissions per service
  -- Example: {"assisted_signup": ["create", "read"], "demo_generator": ["read", "approve"]}
  capacity JSONB NOT NULL,  -- Max concurrent clients, handoffs, availability hours
  -- Example: {"max_concurrent_clients": 15, "max_active_handoffs": 3, "availability_hours": "09:00-18:00 EST"}
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  availability TEXT DEFAULT 'offline' CHECK (availability IN ('online', 'busy', 'offline', 'away')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- client_assignments table (tracks which clients are assigned to which agents)
CREATE TABLE client_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,  -- References client user_id from auth.users
  organization_id UUID NOT NULL REFERENCES organizations(id),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  assigned_role TEXT NOT NULL,  -- Which role is handling this client (sales_agent, onboarding_specialist, etc.)
  lifecycle_stage TEXT NOT NULL,  -- sales, onboarding, support, success
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assignment_type TEXT NOT NULL,  -- auto_on_assisted_signup, handoff, manual, specialist_invitation
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'transferred')),
  completed_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'
);

-- handoffs table (tracks client handoffs between agents/roles)
CREATE TABLE handoffs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  from_agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  from_role TEXT NOT NULL,
  to_agent_id UUID REFERENCES agent_profiles(id),  -- NULL until accepted
  to_role TEXT NOT NULL,
  lifecycle_stage_from TEXT NOT NULL,
  lifecycle_stage_to TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
  handoff_type TEXT NOT NULL,  -- standard, dual (parallel support+success), specialist_invitation
  context_notes TEXT,
  client_prefs JSONB,
  technical_requirements JSONB,
  initiated_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  rejected_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  rejection_reason TEXT
);

-- specialist_invitations table (tracks specialist invitations for upsell/cross-sell)
CREATE TABLE specialist_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  invited_by_agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  specialist_agent_id UUID REFERENCES agent_profiles(id),  -- NULL until accepted
  specialist_role TEXT NOT NULL,  -- sales_specialist, technical_specialist, etc.
  invitation_reason TEXT NOT NULL,  -- upsell, cross_sell, technical_consultation, iteration
  opportunity_type TEXT,  -- voice_addon, premium_tier, custom_integration, etc.
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')),
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,  -- When specialist exits after completing work
  outcome JSONB  -- Results: {deal_closed: true, revenue: 50000, next_steps: "..."}
);

-- agent_activity_logs table (tracks all agent actions)
CREATE TABLE agent_activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id),
  client_id UUID,
  organization_id UUID REFERENCES organizations(id),
  action_type TEXT NOT NULL,  -- client_assigned, handoff_initiated, demo_created, ticket_resolved, etc.
  action_role TEXT NOT NULL,  -- Which role was active during this action
  service_name TEXT,  -- Which microservice was accessed
  metadata JSONB DEFAULT '{}',
  duration_seconds INTEGER,  -- Time spent on this action
  timestamp TIMESTAMPTZ DEFAULT NOW()
);
```

**Indexes:**
```sql
CREATE INDEX idx_users_email ON auth.users(email);
CREATE INDEX idx_users_organization_id ON auth.users(organization_id);
CREATE INDEX idx_users_user_type ON auth.users(user_type);
CREATE INDEX idx_users_claim_token ON auth.users(claim_token) WHERE claim_token IS NOT NULL;
CREATE INDEX idx_users_created_by_agent ON auth.users(created_by_agent_id) WHERE created_by_agent_id IS NOT NULL;
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX idx_agent_profiles_agent_id ON agent_profiles(agent_id);
CREATE INDEX idx_agent_profiles_status ON agent_profiles(status);
CREATE INDEX idx_client_assignments_client_id ON client_assignments(client_id);
CREATE INDEX idx_client_assignments_agent_id ON client_assignments(agent_id);
CREATE INDEX idx_client_assignments_lifecycle_stage ON client_assignments(lifecycle_stage);
CREATE INDEX idx_handoffs_client_id ON handoffs(client_id);
CREATE INDEX idx_handoffs_from_agent ON handoffs(from_agent_id);
CREATE INDEX idx_handoffs_to_agent ON handoffs(to_agent_id);
CREATE INDEX idx_handoffs_status ON handoffs(status);
CREATE INDEX idx_specialist_invitations_client_id ON specialist_invitations(client_id);
CREATE INDEX idx_specialist_invitations_specialist_id ON specialist_invitations(specialist_agent_id);
CREATE INDEX idx_agent_activity_logs_agent_id ON agent_activity_logs(agent_id);
CREATE INDEX idx_agent_activity_logs_timestamp ON agent_activity_logs(timestamp DESC);
```

#### Features

**Must-Have:**
1. ✅ Work email signup with domain validation (clients and agents)
2. ✅ Email verification with expiring tokens
3. ✅ Organization creation wizard
4. ✅ Team member invitation system
5. ✅ Role-based permissions (Admin, Member, Viewer)
6. ✅ Custom permission sets per role
7. ✅ OAuth SSO (Google, Microsoft, GitHub)
8. ✅ Session management with refresh tokens
9. ✅ Organization settings dashboard
10. ✅ Audit logging for security events
11. ✅ Assisted signup - create accounts on behalf of clients
12. ✅ Account claim process - clients can claim assisted accounts
13. ✅ Temporary access tokens for assisted account management
14. ✅ Account ownership transfer from platform to client
15. ✅ Agent registration with multi-role assignment
16. ✅ Granular role-based permissions (per service + per action)
17. ✅ Client handoff workflow (Sales → Onboarding → Support → Success)
18. ✅ Specialist routing engine (skill-based matching)
19. ✅ Real-time availability management (online, busy, offline)
20. ✅ Agent queue management (per role, per client)
21. ✅ Activity tracking (time per client, actions performed)
22. ✅ Cross-sell/upsell agent invitation
23. ✅ Handoff approval with context notes
24. ✅ Workload balancing (auto-assignment based on capacity)
25. ✅ Supervision dashboard (AI oversight by human agents)
26. ✅ Agent performance metrics (response time, CSAT, handoff quality)

**Nice-to-Have:**
27. 🔄 SAML SSO for enterprise customers
28. 🔄 Directory sync (Okta, Azure AD)
29. 🔄 IP allowlisting
30. 🔄 Advanced MFA (biometric, hardware keys)
31. 🔄 AI-powered agent suggestions (best agent for client)
32. 🔄 Agent skill gap analysis
33. 🔄 Automated agent training recommendations
34. 🔄 Predictive workload forecasting

**Feature Interactions:**
- Organization created (self-service) → Triggers initial research job creation
- Organization created (assisted) → Creates account with claim token, sends claim email, triggers research job, auto-assigns to Sales agent
- Team member joins → Sends welcome email with PRD Builder access
- Admin updates permissions → Real-time permission sync across services
- Assisted account claimed → Transfers ownership, converts to full account, sends confirmation email
- Assisted account nearing expiry (7 days) → Automated reminder email sent to client
- Assisted account expired unclaimed → Account locked, platform admin notified for follow-up
- Client signup (assisted) → Auto-assign to Sales agent based on workload
- Sales completes → Handoff to Onboarding agent → Context transferred
- Onboarding completes → Handoff to dedicated Support + Success agents
- Success agent identifies upsell → Invites Sales specialist to join
- AI agent exceeds error threshold → Escalates to Supervision agent
- Agent goes offline → Queue automatically redistributed

#### API Specification

**1. Sign Up (Work Email)**
```http
POST /api/v1/auth/signup
Content-Type: application/json

Request Body:
{
  "email": "john@acme.com",
  "password": "SecurePass123!",
  "full_name": "John Doe",
  "company_name": "Acme Corp",
  "role_in_company": "Product Manager"
}

Response (201 Created):
{
  "user_id": "uuid",
  "email": "john@acme.com",
  "verification_status": "pending",
  "verification_email_sent": true,
  "message": "Please check your email to verify your account",
  "expires_at": "2025-10-05T10:30:00Z"
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "user_signed_up",
  "user_id": "uuid",
  "email": "john@acme.com",
  "company_name": "Acme Corp",
  "timestamp": "2025-10-04T10:30:00Z"
}
```

**2. Verify Email**
```http
POST /api/v1/auth/verify-email
Content-Type: application/json

Request Body:
{
  "email": "john@acme.com",
  "verification_code": "ABC123"
}

Response (200 OK):
{
  "user_id": "uuid",
  "email_verified": true,
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "uuid",
  "expires_in": 3600,
  "next_step": "create_organization"
}
```

**3. Create Organization**
```http
POST /api/v1/organizations
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "organization_name": "Acme Corp",
  "industry": "e-commerce",
  "company_size": "50-100",
  "website": "https://acme.com",
  "logo_url": "https://acme.com/logo.png"
}

Response (201 Created):
{
  "organization_id": "uuid",
  "organization_name": "Acme Corp",
  "slug": "acme-corp",
  "admin_user_id": "uuid",
  "created_at": "2025-10-04T10:35:00Z",
  "onboarding_status": "research_queued",
  "dashboard_url": "https://app.workflow.com/acme-corp"
}

Event Published to Kafka:
Topic: org_events
{
  "event_type": "organization_created",
  "organization_id": "uuid",
  "admin_user_id": "uuid",
  "industry": "e-commerce",
  "timestamp": "2025-10-04T10:35:00Z"
}
```

**4. Invite Team Member**
```http
POST /api/v1/organizations/{org_id}/invitations
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "email": "sarah@acme.com",
  "role": "member",
  "permissions": {
    "prd_builder": ["read", "write"],
    "research": ["read"],
    "demos": ["read"],
    "analytics": ["read"]
  },
  "custom_message": "Join our team to collaborate on PRDs!"
}

Response (201 Created):
{
  "invitation_id": "uuid",
  "email": "sarah@acme.com",
  "role": "member",
  "status": "sent",
  "invitation_link": "https://app.workflow.com/invite/abc123xyz",
  "expires_at": "2025-10-11T10:35:00Z",
  "created_by": "uuid",
  "created_at": "2025-10-04T10:35:00Z"
}

Event Published to Kafka:
Topic: org_events
{
  "event_type": "member_invited",
  "organization_id": "uuid",
  "invitation_id": "uuid",
  "invited_email": "sarah@acme.com",
  "invited_by": "uuid",
  "timestamp": "2025-10-04T10:35:00Z"
}
```

**5. Accept Invitation**
```http
POST /api/v1/invitations/{invitation_id}/accept
Content-Type: application/json

Request Body:
{
  "full_name": "Sarah Johnson",
  "password": "SecurePass456!"
}

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "role": "member",
  "permissions": {
    "prd_builder": ["read", "write"],
    "research": ["read"],
    "demos": ["read"],
    "analytics": ["read"]
  },
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "uuid",
  "dashboard_url": "https://app.workflow.com/acme-corp"
}

Event Published to Kafka:
Topic: org_events
{
  "event_type": "member_joined",
  "organization_id": "uuid",
  "user_id": "uuid",
  "role": "member",
  "timestamp": "2025-10-04T11:00:00Z"
}
```

**6. Update Member Role/Permissions (Admin Only)**
```http
PATCH /api/v1/organizations/{org_id}/members/{user_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "role": "admin",
  "permissions": {
    "prd_builder": ["read", "write", "admin"],
    "research": ["read", "write"],
    "demos": ["read", "write"],
    "analytics": ["read", "write"]
  },
  "config_permissions": {
    "can_view_configs": true,
    "can_edit_system_prompt": true,
    "can_edit_tools": true,
    "can_edit_voice_params": true,
    "can_edit_integrations": true,
    "can_rollback_versions": true,
    "can_deploy_configs": true,
    "can_manage_permissions": true,
    "max_risk_level": "high"
  }
}

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "role": "admin",
  "permissions": {
    "prd_builder": ["read", "write", "admin"],
    "research": ["read", "write"],
    "demos": ["read", "write"],
    "analytics": ["read", "write"]
  },
  "config_permissions": {
    "can_view_configs": true,
    "can_edit_system_prompt": true,
    "can_edit_tools": true,
    "can_edit_voice_params": true,
    "can_edit_integrations": true,
    "can_rollback_versions": true,
    "can_deploy_configs": true,
    "can_manage_permissions": true,
    "max_risk_level": "high"
  },
  "updated_at": "2025-10-04T11:30:00Z",
  "updated_by": "uuid"
}

Event Published to Kafka:
Topic: org_events
{
  "event_type": "member_role_updated",
  "organization_id": "uuid",
  "user_id": "uuid",
  "old_role": "member",
  "new_role": "admin",
  "updated_by": "uuid",
  "timestamp": "2025-10-04T11:30:00Z"
}
```

**7. Get Organization Members**
```http
GET /api/v1/organizations/{org_id}/members
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "organization_id": "uuid",
  "members": [
    {
      "user_id": "uuid",
      "email": "john@acme.com",
      "full_name": "John Doe",
      "role": "admin",
      "permissions": {...},
      "joined_at": "2025-10-04T10:35:00Z",
      "last_active": "2025-10-04T11:30:00Z",
      "status": "active"
    },
    {
      "user_id": "uuid",
      "email": "sarah@acme.com",
      "full_name": "Sarah Johnson",
      "role": "member",
      "permissions": {...},
      "joined_at": "2025-10-04T11:00:00Z",
      "last_active": "2025-10-04T11:15:00Z",
      "status": "active"
    }
  ],
  "total_members": 2,
  "pending_invitations": 1
}
```

**8. Remove Team Member (Admin Only)**
```http
DELETE /api/v1/organizations/{org_id}/members/{user_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "organization_id": "uuid",
  "user_id": "uuid",
  "status": "removed",
  "removed_at": "2025-10-04T12:00:00Z",
  "removed_by": "uuid",
  "access_revoked": true
}

Event Published to Kafka:
Topic: org_events
{
  "event_type": "member_removed",
  "organization_id": "uuid",
  "user_id": "uuid",
  "removed_by": "uuid",
  "timestamp": "2025-10-04T12:00:00Z"
}
```

**9. Login**
```http
POST /api/v1/auth/login
Content-Type: application/json

Request Body:
{
  "email": "john@acme.com",
  "password": "SecurePass123!"
}

Response (200 OK):
{
  "user_id": "uuid",
  "email": "john@acme.com",
  "organizations": [
    {
      "organization_id": "uuid",
      "organization_name": "Acme Corp",
      "role": "admin",
      "slug": "acme-corp"
    }
  ],
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "uuid",
  "expires_in": 3600
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "user_logged_in",
  "user_id": "uuid",
  "organization_id": "uuid",
  "timestamp": "2025-10-04T13:00:00Z"
}
```

**10. OAuth Login (Google/Microsoft/GitHub)**
```http
GET /api/v1/auth/oauth/{provider}/authorize
Query Parameters:
- redirect_uri: https://app.workflow.com/auth/callback
- state: random_state_token

Response (302 Redirect):
Location: https://accounts.google.com/o/oauth2/v2/auth?client_id=...&redirect_uri=...&scope=email+profile

Callback:
GET /api/v1/auth/oauth/{provider}/callback
Query Parameters:
- code: authorization_code
- state: random_state_token

Response (200 OK):
{
  "user_id": "uuid",
  "email": "john@acme.com",
  "provider": "google",
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "uuid",
  "first_login": false,
  "organizations": [...]
}
```

**11. Assisted Signup - Create Account on Behalf of Client (Platform Admin or Sales Agent)**
```http
POST /api/v1/auth/assisted-signup
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-User-Role: platform_admin | sales_agent

Request Body:
{
  "client_email": "client@example.com",
  "client_name": "Jane Smith",
  "company_name": "Example Corp",
  "company_website": "https://example.com",
  "industry": "e-commerce",
  "company_size": "10-50",
  "created_by_agent_id": "uuid",  // Human agent ID (sales_agent or platform_admin)
  "notes": "Lead from conference, requested demo"
}

Authorization Logic:
- Platform Admin: Full access, no restrictions
- Sales Agent: Requires 'assisted_signup' permission with 'create' action in agent permissions
- Verification: Check Human Agent Management Service for role and permissions before proceeding

Response (201 Created):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "email": "client@example.com",
  "account_status": "assisted_unclaimed",
  "claim_token": "CLAIM-ABC123-XYZ789",
  "claim_url": "https://app.workflow.com/claim/CLAIM-ABC123-XYZ789",
  "temporary_access_token": "temp_eyJhbGciOiJIUzI1NiIs...",
  "expires_at": "2025-11-04T10:30:00Z",
  "created_by_agent_id": "uuid",
  "created_by_agent_name": "Sam Peterson",
  "created_by_agent_role": "sales_agent",
  "created_at": "2025-10-05T10:30:00Z",
  "dashboard_url": "https://app.workflow.com/example-corp",
  "message": "Account created. Client can claim within 30 days using the claim link."
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "assisted_account_created",
  "user_id": "uuid",
  "organization_id": "uuid",
  "client_email": "client@example.com",
  "created_by_agent_id": "uuid",
  "created_by_agent_role": "sales_agent",
  "claim_token": "CLAIM-ABC123-XYZ789",
  "expires_at": "2025-11-04T10:30:00Z",
  "timestamp": "2025-10-05T10:30:00Z"
}

**Note on Client Assignment:**
The Organization Management Service publishes ONLY the `assisted_account_created` event above. The Human Agent Management Service (Service #2) consumes this event and performs the agent assignment logic, then publishes the `client_assigned_to_agent` event to the `agent_events` topic. This event-driven architecture separates authentication concerns from agent assignment concerns.
```

**12. Get Assisted Account Details (Platform Admin or Sales Agent)**
```http
GET /api/v1/auth/assisted-accounts/{user_id}
Authorization: Bearer {jwt_token}
X-User-Role: platform_admin | sales_agent

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "email": "client@example.com",
  "company_name": "Example Corp",
  "account_status": "assisted_unclaimed",
  "claim_token": "CLAIM-ABC123-XYZ789",
  "claim_url": "https://app.workflow.com/claim/CLAIM-ABC123-XYZ789",
  "created_by": "platform_admin_user_id",
  "created_at": "2025-10-05T10:30:00Z",
  "expires_at": "2025-11-04T10:30:00Z",
  "claimed_at": null,
  "last_activity": "2025-10-05T14:20:00Z",
  "activity_summary": {
    "research_completed": true,
    "demo_generated": true,
    "nda_sent": false,
    "prd_created": false
  },
  "notes": "Lead from conference, requested demo"
}
```

**13. Claim Assisted Account**
```http
POST /api/v1/auth/claim-account
Content-Type: application/json

Request Body:
{
  "claim_token": "CLAIM-ABC123-XYZ789",
  "password": "SecurePass123!",
  "accept_terms": true
}

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "email": "client@example.com",
  "company_name": "Example Corp",
  "account_status": "claimed",
  "role": "admin",
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "uuid",
  "dashboard_url": "https://app.workflow.com/example-corp",
  "inherited_data": {
    "research_reports": 1,
    "demos": 1,
    "ndas": 0,
    "prds": 0
  },
  "claimed_at": "2025-10-10T09:15:00Z",
  "message": "Account successfully claimed! You now have full access to your organization and all data created on your behalf."
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "assisted_account_claimed",
  "user_id": "uuid",
  "organization_id": "uuid",
  "email": "client@example.com",
  "claim_token": "CLAIM-ABC123-XYZ789",
  "claimed_at": "2025-10-10T09:15:00Z",
  "timestamp": "2025-10-10T09:15:00Z"
}
```

**14. Resend Claim Link (Platform Admin or Sales Agent)**
```http
POST /api/v1/auth/assisted-accounts/{user_id}/resend-claim
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-User-Role: platform_admin | sales_agent

Request Body:
{
  "custom_message": "Hi Jane, here's your account access link again. Let me know if you have questions!"
}

Response (200 OK):
{
  "user_id": "uuid",
  "email": "client@example.com",
  "claim_url": "https://app.workflow.com/claim/CLAIM-ABC123-XYZ789",
  "email_sent": true,
  "sent_at": "2025-10-06T11:00:00Z",
  "expires_at": "2025-11-04T10:30:00Z"
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "claim_link_resent",
  "user_id": "uuid",
  "organization_id": "uuid",
  "resent_by": "platform_admin_user_id",
  "timestamp": "2025-10-06T11:00:00Z"
}
```

**15. Manage Assisted Account (Platform Admin or Sales Agent Temporary Access)**
```http
POST /api/v1/auth/assisted-accounts/{user_id}/access
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-User-Role: platform_admin | sales_agent

Request Body:
{
  "reason": "Setting up demo and research data for client presentation",
  "duration_hours": 24
}

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "temporary_access_token": "temp_eyJhbGciOiJIUzI1NiIs...",
  "access_type": "full_admin",
  "granted_to": "platform_admin_user_id",
  "granted_at": "2025-10-05T10:35:00Z",
  "expires_at": "2025-10-06T10:35:00Z",
  "reason": "Setting up demo and research data for client presentation",
  "audit_logged": true
}

Event Published to Kafka:
Topic: auth_events
{
  "event_type": "assisted_account_access_granted",
  "user_id": "uuid",
  "organization_id": "uuid",
  "granted_to": "platform_admin_user_id",
  "reason": "Setting up demo and research data for client presentation",
  "duration_hours": 24,
  "timestamp": "2025-10-05T10:35:00Z"
}
```

**16. List All Assisted Accounts (Platform Admin or Sales Agent)**
```http
GET /api/v1/auth/assisted-accounts
Authorization: Bearer {jwt_token}
X-User-Role: platform_admin | sales_agent
Query Parameters:
- status: unclaimed|claimed|expired (optional)
- agent_id: {uuid} (optional, filter by assigned agent - auto-applied for sales_agent role)
- page: 1
- limit: 50
- sort_by: created_at|expires_at|claimed_at
- order: asc|desc

Authorization Logic:
- Platform Admin: Can view all assisted accounts across all agents
- Sales Agent: Can only view accounts assigned to them (agent_id auto-filtered)

Response (200 OK):
{
  "accounts": [
    {
      "user_id": "uuid",
      "organization_id": "uuid",
      "email": "client@example.com",
      "company_name": "Example Corp",
      "account_status": "assisted_unclaimed",
      "created_by": "platform_admin_user_id",
      "created_at": "2025-10-05T10:30:00Z",
      "expires_at": "2025-11-04T10:30:00Z",
      "claimed_at": null,
      "last_activity": "2025-10-05T14:20:00Z"
    },
    {
      "user_id": "uuid",
      "organization_id": "uuid",
      "email": "another@company.com",
      "company_name": "Another Company",
      "account_status": "claimed",
      "created_by": "platform_admin_user_id",
      "created_at": "2025-10-01T08:00:00Z",
      "expires_at": "2025-10-31T08:00:00Z",
      "claimed_at": "2025-10-03T15:30:00Z",
      "last_activity": "2025-10-05T16:45:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_accounts": 247,
    "per_page": 50
  },
  "summary": {
    "total_unclaimed": 134,
    "total_claimed": 98,
    "total_expired": 15
  }
}
```

**Rate Limiting:**
- Signup: 10 per hour per IP
- Login: 20 per hour per IP
- Email verification: 5 per hour per email
- Invitations: 100 per day per organization
- OAuth: 50 per hour per IP
- Assisted signup: 100 per day per platform admin
- Claim account: 5 per hour per claim token
- Resend claim link: 10 per day per assisted account
- Agent registration: 50 per day per platform admin
- Agent assignments: 500 per day per agent
- Handoff operations: 100 per day per agent

#### Agent Management API Endpoints

**Note**: The following agent management endpoints were consolidated from Service 0.5 (Human Agent Management) into Service 0.

**17. Register Human Agent**
```http
POST /api/v1/agents
Authorization: Bearer {platform_admin_jwt}
Content-Type: application/json

Request Body:
{
  "email": "sam@workflow.com",
  "full_name": "Sam Peterson",
  "roles": [
    {
      "role_type": "sales_agent",
      "primary": true,
      "skills": ["b2b_saas", "enterprise_sales", "demo_presentation"],
      "certifications": ["Salesforce_Certified"],
      "languages": ["english", "spanish"]
    }
  ],
  "permissions": {
    "assisted_signup": ["create", "read", "update"],
    "research_engine": ["read", "trigger"],
    "demo_generator": ["read", "create", "approve"]
  },
  "capacity": {
    "max_concurrent_clients": 15,
    "max_active_handoffs": 3,
    "availability_hours": "09:00-18:00 EST"
  }
}

Response (201 Created):
{
  "agent_id": "uuid",
  "email": "sam@workflow.com",
  "status": "active",
  "roles": ["sales_agent"],
  "created_at": "2025-10-05T10:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "agent_registered",
  "agent_id": "uuid",
  "roles": ["sales_agent"],
  "timestamp": "2025-10-05T10:00:00Z"
}
```

**18. Assign Client to Agent**
```http
POST /api/v1/agents/assignments
Authorization: Bearer {jwt_token}

Request Body:
{
  "client_id": "uuid",
  "organization_id": "uuid",
  "role_type": "sales_agent",
  "assignment_type": "auto"
}

Response (201 Created):
{
  "assignment_id": "uuid",
  "client_id": "uuid",
  "assigned_agent": {
    "agent_id": "uuid",
    "full_name": "Sam Peterson"
  },
  "assigned_at": "2025-10-05T10:15:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "client_assigned_to_agent",
  "assignment_id": "uuid",
  "client_id": "uuid",
  "agent_id": "uuid",
  "role_type": "sales_agent",
  "timestamp": "2025-10-05T10:15:00Z"
}
```

**19. Initiate Client Handoff**
```http
POST /api/v1/agents/handoffs
Authorization: Bearer {agent_jwt}

Request Body:
{
  "client_id": "uuid",
  "from_role": "sales_agent",
  "to_role": "onboarding_specialist",
  "lifecycle_stage_to": "onboarding",
  "context_notes": "Client ready for technical onboarding"
}

Response (201 Created):
{
  "handoff_id": "uuid",
  "status": "pending",
  "initiated_at": "2025-10-05T11:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "handoff_initiated",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "from_agent_id": "uuid",
  "to_role": "onboarding_specialist",
  "timestamp": "2025-10-05T11:00:00Z"
}
```

**20. Update Agent Availability**
```http
PATCH /api/v1/agents/{agent_id}/availability
Authorization: Bearer {agent_jwt}

Request Body:
{
  "availability": "online"
}

Response (200 OK):
{
  "agent_id": "uuid",
  "availability": "online",
  "updated_at": "2025-10-05T09:00:00Z"
}
```

**21. Get Agent Performance Metrics**
```http
GET /api/v1/agents/{agent_id}/metrics
Authorization: Bearer {agent_jwt}
Query Parameters:
- period: day|week|month
- role_type: sales_agent|onboarding_specialist (optional)

Response (200 OK):
{
  "agent_id": "uuid",
  "period": "week",
  "metrics": {
    "active_clients": 12,
    "completed_handoffs": 8,
    "avg_response_time_minutes": 15,
    "client_satisfaction_score": 4.7,
    "utilization_percent": 80
  }
}
```

#### Kafka Events Published

Service 0 publishes to three Kafka topics:

**1. auth_events** - User authentication and account lifecycle events
- `user_signed_up`
- `user_logged_in`
- `assisted_account_created`
- `assisted_account_claimed`
- `claim_link_resent`
- `assisted_account_access_granted`

**2. org_events** - Organization management events
- `organization_created`
- `team_member_invited`
- `team_member_added`
- `role_updated`
- `member_removed`

**3. agent_events** - Human agent management events (consolidated from Service 0.5)
- `agent_registered`
- `client_assigned_to_agent`
- `handoff_initiated`
- `handoff_accepted`
- `handoff_completed`
- `specialist_invited`
- `agent_availability_changed`

#### Frontend Components

**1. Signup Flow**
- Component: `SignupForm.tsx`
- Features:
  - Work email validation (no gmail/yahoo/hotmail)
  - Password strength indicator
  - Company autocomplete (Clearbit/similar)
  - Progressive disclosure (email → verify → create org)
  - OAuth buttons (Google, Microsoft, GitHub)

**2. Organization Creation Wizard**
- Component: `OrgCreationWizard.tsx`
- Features:
  - Step 1: Basic info (name, industry, size)
  - Step 2: Logo upload/scraping
  - Step 3: Invite teammates
  - Step 4: Research job auto-creation
  - Progress indicator

**3. Team Management Dashboard**
- Component: `TeamManagementDashboard.tsx`
- Features:
  - Member list with roles
  - Invite new members modal
  - Role/permission editor
  - Activity logs
  - Pending invitations management
  - Bulk actions (remove, update roles)

**4. Role & Permissions Editor**
- Component: `RolePermissionsEditor.tsx`
- Features:
  - Granular permission toggles
  - Role templates (Admin, Member, Viewer)
  - Custom role creation
  - Permission preview
  - Conflict resolution

**5. Organization Settings**
- Component: `OrgSettings.tsx`
- Features:
  - Organization profile editing
  - Branding (logo, colors)
  - SSO configuration
  - Security settings (MFA enforcement)
  - Audit log viewer
  - Danger zone (delete org)

**6. Assisted Signup Dashboard (Platform Admin)**
- Component: `AssistedSignupDashboard.tsx`
- Features:
  - Create assisted account form
  - List all assisted accounts (unclaimed, claimed, expired)
  - Search and filter accounts
  - View account activity summary
  - Resend claim links
  - Generate temporary access tokens
  - Bulk actions (resend, extend expiry)
  - Activity timeline per account

**7. Account Claim Flow (Client)**
- Component: `AccountClaimFlow.tsx`
- Features:
  - Claim token validation
  - Password setup form
  - Terms acceptance
  - Preview of inherited data (research, demos)
  - Welcome tour after claim
  - Account status indicator

**8. Assisted Account Manager (Platform Admin)**
- Component: `AssistedAccountManager.tsx`
- Features:
  - Temporary access request form
  - Active access sessions viewer
  - Audit log of admin actions
  - Account handoff checklist
  - Notes and communication history
  - Expiry management (extend/revoke)

**State Management:**
- Redux Toolkit for auth state
- React Query for org/member data
- Local storage for refresh tokens
- Session timeout handling with auto-refresh

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Organization Admin**
   - Role: Manages organization, invites members, sets permissions
   - Access: Full organization settings, team management
   - Permissions: admin:organization, manage:members, manage:permissions
   - Workflows: Create org → Invite team → Configure settings → Monitor activity

2. **Organization Member**
   - Role: Collaborates on PRDs, views research/demos
   - Access: PRD Builder, research results, demos (based on permissions)
   - Permissions: read:research, write:prd, read:demos
   - Workflows: Accept invitation → Complete profile → Start PRD collaboration

3. **Platform Admin**
   - Role: Monitors auth service health, manages fraud/abuse, creates assisted accounts
   - Access: All organizations (read-only), audit logs, security alerts, assisted account management
   - Permissions: admin:platform, view:all_orgs, manage:security, create:assisted_accounts, manage:assisted_accounts
   - Workflows:
     - Monitors suspicious activity, enforces ToS, resolves conflicts
     - Creates assisted accounts for leads/prospects
     - Manages account setup (research, demos) on behalf of clients
     - Sends claim links to clients
     - Monitors claim status and follows up
     - Transfers ownership when account is claimed

4. **Client (Assisted Account)**
   - Role: Prospect/lead who receives an assisted account
   - Access: Claim link, view-only access to inherited data until claimed
   - Permissions: claim:account (before claim), full admin (after claim)
   - Workflows:
     - Receives claim link via email
     - Reviews inherited data (research, demos)
     - Claims account with password setup
     - Gains full admin access to organization
     - Inherits all data created on their behalf

**AI Agents:**

1. **Email Verification Agent**
   - Responsibility: Sends verification emails, validates codes, handles bounces
   - Tools: SendGrid API, email validation services
   - Autonomy: Fully autonomous
   - Escalation: Alerts on high bounce rates

2. **Domain Validation Agent**
   - Responsibility: Validates work email domains, detects disposable emails
   - Tools: DNS lookups, email validator APIs, fraud detection
   - Autonomy: Fully autonomous
   - Escalation: Flags suspicious domains for manual review

3. **Onboarding Orchestration Agent**
   - Responsibility: Triggers research job after org creation, sends welcome emails
   - Tools: Kafka producer, SendGrid, Research Engine API
   - Autonomy: Fully autonomous
   - Escalation: None

4. **Assisted Account Manager Agent**
   - Responsibility: Manages assisted account lifecycle, sends claim reminders, handles expiry
   - Tools: SendGrid, claim token generator, expiry scheduler, audit logger
   - Autonomy: Fully autonomous
   - Escalation: Alerts platform admin when accounts near expiry without claims

**Approval Workflows:**
1. User Signup → Auto-approved (email verification required)
2. Organization Creation → Auto-approved
3. Team Member Invitation → Auto-sent (admin initiated)
4. Role Updates → Auto-applied (admin permission required)
5. Member Removal → Auto-executed (admin permission required)
6. Assisted Account Creation → Platform admin approval required
7. Claim Link Sending → Auto-sent immediately after assisted account creation
8. Account Claiming → Auto-approved (valid claim token required)
9. Temporary Admin Access → Platform admin approval with audit logging

---

**Note**: Service 0.5 (Human Agent Management) has been consolidated into Service 0 (Organization & Identity Management Service). All agent management functionality, database tables, API endpoints, and Kafka events are now part of Service 0.

---

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
2. Company logo scraping and storage (website, social media, Google Maps)
3. Decision maker identification via Apollo.io, LinkedIn Sales Navigator, and contact databases
4. Financial/funding news research via TechCrunch, YourStory, Crunchbase, PitchBook
5. Competitive workflow analysis through mystery shopping (human agent coordination)
6. Response quality assessment (speed, hours, coverage gaps)
7. Automated report generation with actionable insights
8. Data enrichment via third-party APIs (Clearbit, Apollo, ZoomInfo)
9. Duplicate detection and data deduplication
10. **Legal data collection**: Client's registered business address for NDA template population
11. **Volume metrics collection**: Current and historical chat volume, call volume, website traffic
12. **Marketing intelligence**: Google Ads campaigns via Google Ads Transparency Center, Meta (Facebook/Instagram) ad campaigns via Meta Ads Library
13. **Business volume prediction**: AI-powered prediction of actual chat/call volumes based on collected data to assess client prioritization and resource investment

**Non-Functional Requirements:**
- Research completion within 24-48 hours per client
- 95% data accuracy for structured fields (phone, email, hours)
- Support 100 concurrent research jobs
- PII compliance (GDPR, CCPA) - anonymize personal data
- Cost optimization: <$50/research job

**Dependencies:**
- Demo Generator Service (publishes research_completed event)
- Configuration Management Service (scraping rules, source priorities)
- RAG Pipeline Service (for Research Chat Q&A functionality)
- LLM Gateway Service (for chat responses and insight generation)
- External APIs:
  - Social media: Instagram, Facebook, TikTok APIs
  - Business data: Google Maps API, Yelp API
  - Decision makers: Apollo.io, LinkedIn Sales Navigator, ZoomInfo
  - Financial news: TechCrunch API, YourStory, Crunchbase, PitchBook
  - Data enrichment: Clearbit, Hunter.io
  - Web scraping: Bright Data, ScrapingBee proxy services
  - **Marketing intelligence**: Google Ads Transparency Center API, Meta Ads Library API
  - **Business registry data**: For registered business addresses (jurisdiction-specific APIs)

**Data Storage:**
- PostgreSQL: Research metadata, job status, findings summaries, **business address**, **volume metrics** (chat, call, website traffic - current & historical), **predicted volumes**, **ad campaign data**
- S3/Object Storage: Raw scraped data, screenshots, documents
- Qdrant: Semantic search on research findings for retrieval

#### Features

**Must-Have:**
1. ✅ Automated scraping orchestrator (Playwright/Puppeteer)
2. ✅ Multi-platform social media data extraction
3. ✅ Company logo scraping and optimization (multiple resolutions)
4. ✅ Google Maps business data scraping
5. ✅ Review aggregation and sentiment analysis
6. ✅ Decision maker research (Apollo.io, LinkedIn Sales Navigator integration)
7. ✅ Financial/funding news aggregation (TechCrunch, YourStory, Crunchbase, PitchBook)
8. ✅ Mystery shopping workflow (human agent task assignment)
9. ✅ Competitor workflow documentation
10. ✅ Research report generation (JSON + PDF formats)
11. ✅ Interactive chat interface for research Q&A (RAG-powered)
12. ✅ **Automated outbound email** (research findings + proposed demo scope + feedback request)
13. ✅ **Manual outreach ticket system** (when email unavailable, create ticket for human agent)

**Nice-to-Have:**
14. 🔄 Real-time data streaming (live social media monitoring)
15. 🔄 Predictive analytics (churn risk, expansion opportunities)
16. 🔄 Video content transcription and analysis
17. 🔄 Automated SWOT analysis generation

**Feature Interactions:**
- Research completion → Auto-generate requirements draft with research findings summary
- Requirements draft → Human agent (Sales/SDR) reviews and approves draft for sending
- Draft approved → Send requirements form to client (presenting research findings for validation)
- Client validates/corrects findings → Triggers demo generation with confirmed requirements
- Findings feed into PRD Builder for context (business address for NDA, predicted volumes for pricing)
- Competitive insights inform pricing model
- Client corrections flagged for sales review if major discrepancies detected

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
  "product_types": ["chatbot", "voicebot"],
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
  "product_types": ["chatbot", "voicebot"],
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
  "product_types": ["chatbot", "voicebot"],
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
  "product_types": ["chatbot", "voicebot"],
  "research_completed_at": "2025-10-05T15:30:00Z",
  "branding": {
    "company_name": "Acme Corp",
    "logo": {
      "primary_url": "https://storage.workflow.com/logos/acme-primary.png",
      "favicon_url": "https://storage.workflow.com/logos/acme-favicon.ico",
      "resolutions": {
        "512x512": "https://storage.workflow.com/logos/acme-512.png",
        "256x256": "https://storage.workflow.com/logos/acme-256.png",
        "128x128": "https://storage.workflow.com/logos/acme-128.png"
      },
      "source": "website",
      "background": "transparent",
      "format": "png"
    },
    "brand_colors": {
      "primary": "#1a73e8",
      "secondary": "#34a853",
      "extracted_from": "website"
    }
  },
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
  "business_data": {
    "registered_address": {
      "street": "123 Business Ave, Suite 400",
      "city": "San Francisco",
      "state": "CA",
      "postal_code": "94105",
      "country": "USA",
      "source": "business_registry",
      "verified": true
    },
    "volume_metrics": {
      "chat_volume": {
        "current_monthly": 1250,
        "historical": [
          {"month": "2024-09", "volume": 1100},
          {"month": "2024-08", "volume": 980},
          {"month": "2024-07", "volume": 850}
        ],
        "growth_trend": "+23% MoM"
      },
      "call_volume": {
        "current_monthly": 420,
        "historical": [
          {"month": "2024-09", "volume": 380},
          {"month": "2024-08", "volume": 350}
        ],
        "growth_trend": "+11% MoM"
      },
      "website_traffic": {
        "monthly_visitors": 45000,
        "bounce_rate": 42,
        "avg_session_duration": "3m 45s"
      }
    },
    "marketing_intelligence": {
      "google_ads": {
        "active_campaigns": 3,
        "estimated_monthly_spend": "$12000-$15000",
        "top_keywords": ["e-commerce automation", "chatbot for retail", "AI customer service"],
        "geographic_targets": ["US", "Canada", "UK"],
        "source": "google_ads_transparency_center"
      },
      "meta_ads": {
        "active_campaigns": 5,
        "platforms": ["Facebook", "Instagram"],
        "estimated_monthly_spend": "$8000-$10000",
        "ad_creative_themes": ["product_demo", "customer_testimonials", "limited_time_offers"],
        "source": "meta_ads_library"
      }
    },
    "predicted_volumes": {
      "chat_volume_prediction": {
        "predicted_monthly": 1400,
        "confidence_score": 0.85,
        "prediction_basis": ["historical_trend", "marketing_spend", "website_traffic", "seasonal_factors"],
        "range": {"min": 1200, "max": 1600}
      },
      "call_volume_prediction": {
        "predicted_monthly": 450,
        "confidence_score": 0.82,
        "prediction_basis": ["historical_trend", "business_hours_coverage", "google_maps_rating"],
        "range": {"min": 400, "max": 500}
      }
    }
  },
  "business_prioritization": {
    "priority_score": 85,
    "priority_tier": "high",
    "scoring_factors": {
      "predicted_chat_volume": 1400,
      "predicted_call_volume": 450,
      "marketing_spend_estimated": 23000,
      "growth_trajectory": "+23% MoM",
      "deal_size_potential": 250000,
      "weights_applied": {
        "volume": "30%",
        "marketing_spend": "25%",
        "growth": "20%",
        "deal_size": "15%",
        "engagement": "10%"
      }
    },
    "recommendation": "high_priority",
    "rationale": "Strong volume predictions (1400 chats/month, 450 calls/month) combined with $23K/month marketing spend indicates serious growth trajectory. Series B funding and 23% MoM growth suggest budget availability and expansion mindset. Estimated deal size $250K+ justifies dedicated resource allocation.",
    "invest_decision": true,
    "suggested_actions": [
      "Assign dedicated onboarding specialist (not shared pool)",
      "Fast-track to NDA within 48 hours",
      "Schedule executive-level demo with CEO/VP Ops",
      "Allocate premium support tier (24hr SLA)"
    ]
  },
  "recommendations": [
    "Target decision makers: John Smith (CEO) and Jane Doe (VP Ops) for pilot discussions",
    "Leverage Series B funding news as conversation starter about scaling operations",
    "Implement 24/7 chatbot for after-hours coverage (predicted volume: 1400 chats/month supports ROI)",
    "Automate response routing to reduce 4hr response time to <15min",
    "Add SMS/WhatsApp channels based on customer preferences",
    "Business address verified for NDA generation: 123 Business Ave, Suite 400, San Francisco, CA 94105",
    "Marketing spend indicates high-growth trajectory - prioritize for dedicated onboarding specialist"
  ]
}

Response (200 OK - PDF):
Binary PDF content with formatted report
```

**4. Chat with Research (Q&A Interface)**
```http
POST /api/v1/research/jobs/{job_id}/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "Who are the key decision makers we should target?",
  "session_id": "uuid",
  "include_sources": true
}

Response (200 OK):
{
  "job_id": "uuid",
  "message_id": "uuid",
  "response": {
    "answer": "Based on the research, you should target the following key decision makers:\n\n1. **John Smith (CEO)** - Primary decision maker for strategic initiatives. Best contact via email: john@acme.com or LinkedIn. Confidence: 95%\n\n2. **Jane Doe (VP Operations)** - Operational decision maker, directly responsible for customer support and workflow automation. Contact: jane@acme.com. Confidence: 88%\n\n3. **Mike Johnson (CTO)** - Technical decision maker for integration and platform decisions.\n\nRecommendation: Start with John Smith for high-level discussion, then involve Jane Doe for operational details.",
    "sources": [
      {
        "type": "decision_makers",
        "data": {
          "name": "John Smith",
          "title": "CEO",
          "source": "apollo.io"
        }
      },
      {
        "type": "org_chart",
        "data": {
          "hierarchy": "CEO → VP Ops, CTO, CFO"
        }
      }
    ],
    "related_insights": [
      "Acme Corp recently raised $15M Series B - use this as conversation starter",
      "Company is expanding to EU and India - automation needs likely growing"
    ]
  },
  "conversation_context": {
    "turn_count": 1,
    "topics_discussed": ["decision_makers"]
  },
  "timestamp": "2025-10-05T14:30:00Z"
}

Example Questions:
- "What are the main pain points we discovered?"
- "What's their funding status and recent news?"
- "How do they currently handle customer support?"
- "What are their business hours and coverage gaps?"
- "Who are their main competitors?"
- "What's the sentiment around their brand?"
- "Give me talking points for the first sales call"
```

**5. Trigger Mystery Shopping Task**
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

**6. Send Outbound Email (Auto-triggered on Research Completion)**
```http
POST /api/v1/research/jobs/{job_id}/send-outbound
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "auto_send": true,
  "email_template": "research_complete_outbound"
}

Response (200 OK - Email Available):
{
  "job_id": "uuid",
  "outbound_status": "email_sent",
  "sent_to": "john@acme.com",
  "sent_at": "2025-10-05T16:00:00Z",
  "email_content": {
    "subject": "We researched Acme Corp - Here's what we found and how we can help",
    "preview": "Hi John, We did comprehensive research about Acme Corp and identified key opportunities...",
    "includes": {
      "research_summary": true,
      "proposed_demo_scope": true,
      "feedback_request": true
    }
  },
  "tracking": {
    "email_id": "uuid",
    "open_tracking": true,
    "click_tracking": true,
    "reply_tracking": true
  },
  "next_steps": "awaiting_client_feedback"
}

Response (200 OK - No Email Available):
{
  "job_id": "uuid",
  "outbound_status": "ticket_created",
  "reason": "no_email_found_in_research",
  "ticket": {
    "ticket_id": "uuid",
    "type": "manual_outreach_required",
    "priority": "high",
    "assigned_to": "sales_team",
    "contact_channels_available": ["phone", "linkedin", "instagram_dm"],
    "instructions": "Manually reach out to client via available channels, share research findings, gather feedback on proposed demo scope",
    "dashboard_url": "https://dashboard.workflow.com/tickets/uuid"
  },
  "next_steps": "manual_agent_outreach_required"
}

Email Template Structure:
---
Subject: We researched {company_name} - Here's what we found and how we can help

Hi {decision_maker_name},

We did comprehensive research about {company_name} and discovered some interesting insights:

**What We Found:**
- Your current customer support operates Mon-Fri 9-6 with 4-hour average response time
- You're getting complaints about weekend unavailability
- You recently raised $15M Series B - congrats!

**What We Think You Need:**
We believe an AI-powered automation solution could help you:
- Achieve 24/7 customer coverage
- Reduce response time from 4 hours to <15 minutes
- Handle 80% of queries automatically

**Proposed Demo:**
We'd like to build a customized demo showing:
- AI chatbot handling your common customer queries
- Integration with your existing Zendesk setup
- Analytics dashboard for tracking automation metrics

**We Need Your Feedback:**
1. Does this align with your priorities?
2. Any specific features or use cases you'd like to see?
3. Any concerns or requirements we should address?

Reply to this email or click here to provide feedback: [Feedback Link]

Best regards,
{sales_engineer_name}
---

Event Published to Kafka:
Topic: research_events
{
  "event_type": "outbound_sent",
  "job_id": "uuid",
  "client_id": "uuid",
  "outbound_method": "email" | "ticket_created",
  "timestamp": "2025-10-05T16:00:00Z"
}
```

**7. Submit Client Feedback on Research**
```http
POST /api/v1/research/jobs/{job_id}/client-feedback
Authorization: Bearer {demo_access_token}
Content-Type: application/json

Request Body:
{
  "client_contact": {
    "name": "John Smith",
    "email": "john@acme.com",
    "role": "CEO"
  },
  "feedback": {
    "research_accuracy": 5,
    "proposed_demo_alignment": 4,
    "comments": "Great research! We'd also like to see SMS integration in the demo, not just chat.",
    "additional_requirements": [
      "Show SMS/WhatsApp channels",
      "Include multilingual support (English, Spanish)",
      "Demonstrate escalation to human agents"
    ],
    "priority_use_cases": ["customer_support", "lead_qualification"],
    "ready_for_demo": true
  }
}

Response (201 Created):
{
  "feedback_id": "uuid",
  "job_id": "uuid",
  "status": "feedback_received",
  "next_steps": {
    "action": "demo_generation_queued",
    "updated_demo_scope": {
      "channels": ["webchat", "sms", "whatsapp"],
      "languages": ["en", "es"],
      "use_cases": ["customer_support", "lead_qualification"],
      "required_features": ["human_escalation", "multilingual"]
    },
    "estimated_demo_ready": "2025-10-06T14:00:00Z"
  },
  "notification_sent_to": ["sales_engineer_uuid"],
  "created_at": "2025-10-05T18:30:00Z"
}

Event Published to Kafka:
Topic: research_events
{
  "event_type": "client_feedback_received",
  "job_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "ready_for_demo": true,
  "timestamp": "2025-10-05T18:30:00Z"
}

Triggers: Demo Generator Service (consumes client_feedback_received event)
```

**8. List Research Jobs**
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
      "outbound_status": "email_sent",
      "client_feedback_received": true,
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
  - Tabbed interface (Summary, Primary, Deep, Mystery Shopping, Decision Makers, Financial News)
  - Interactive charts (sentiment analysis, rating distributions)
  - Export options (PDF, JSON, CSV)
  - Annotation tools for sales team
  - Integration with Demo Generator (one-click demo creation)

**4. Research Chat Interface**
- Component: `ResearchChatInterface.tsx`
- Features:
  - Full-screen chat with RAG-powered research assistant
  - Ask questions about research findings in natural language
  - Source citations with clickable references
  - Suggested questions based on research content
  - Related insights auto-displayed
  - Export chat history with answers
  - Quick action buttons ("Generate talking points", "Find decision makers", "Summarize pain points")

**5. Outbound Email Preview & Tracking**
- Component: `OutboundEmailPreview.tsx`
- Features:
  - Email template preview before sending
  - Personalization variable preview (decision maker name, company details)
  - Send time scheduler
  - Email tracking dashboard (opens, clicks, replies)
  - A/B test different email versions

**6. Manual Outreach Ticket Dashboard**
- Component: `ManualOutreachTickets.tsx`
- Features:
  - Ticket queue (priority-sorted: high, medium, low)
  - Client info panel (available contact channels, research summary)
  - Quick actions (call, LinkedIn message, Instagram DM)
  - Outreach template library (email, LinkedIn, SMS)
  - Response tracking (contacted, responded, feedback collected)
  - Ticket resolution workflow (mark as contacted → awaiting response → feedback received → resolved)

**7. Client Feedback Collection Form**
- Component: `ClientFeedbackForm.tsx`
- Features:
  - Embedded in outbound email (one-click feedback link)
  - Standalone form for manual collection
  - Research accuracy rating
  - Proposed demo alignment rating
  - Additional requirements input (multi-select + free text)
  - Priority use cases selection
  - Ready for demo checkbox

**8. Mystery Shopping Task Manager**
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
- WebSocket integration for real-time updates (email opens, ticket status)
- Optimistic UI updates for job creation and outbound sending

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Team Lead**
   - Role: Initiates research jobs, reviews outbound emails, manages client relationships
   - Access: Full CRUD on research jobs for assigned clients
   - Permissions: create:research, read:research, update:research, send:outbound
   - Workflows: Reviews reports, approves outbound emails, tracks client feedback, triggers demo generation

2. **Sales Development Representative (SDR)**
   - Role: Handles manual outreach tickets when email unavailable
   - Access: Manual outreach ticket queue, client research data
   - Permissions: read:tickets, update:tickets, read:research
   - Workflows: Receives ticket assignment, reaches out via available channels (phone, LinkedIn, Instagram), collects client feedback, resolves ticket
   - Approval: Ticket resolution auto-updates research status

3. **Mystery Shopper Agents**
   - Role: Conduct manual competitor analysis and workflow testing
   - Access: Read-only on assigned tasks, write access to observations
   - Permissions: read:tasks, write:observations
   - Workflows: Receives task assignments, completes mystery shopping, submits findings
   - Approval: Task completions reviewed by QA before inclusion in reports

4. **Research Operations Manager**
   - Role: Oversees research quality, manages scraping infrastructure, monitors outbound performance
   - Access: Full admin access to all research jobs, outbound emails, and configurations
   - Permissions: admin:research, configure:scrapers, manage:agents, view:email_analytics
   - Workflows: Monitors job failures, optimizes scraping rules, reviews escalated issues, tracks outbound email performance

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

4. **Business Prioritization Agent**
   - Responsibility: Calculates priority score (0-100) based on predicted volumes, marketing spend, growth indicators, and deal size potential
   - Tools: ML scoring model (weighted algorithm), decision matrix, volume estimators, deal size calculator
   - Scoring Algorithm:
     - Predicted chat/call volume (30% weight)
     - Marketing spend indicators (25% weight)
     - Growth trajectory (20% weight)
     - Estimated deal size (15% weight)
     - Engagement signals (10% weight)
   - Priority Tiers:
     - Critical (90-100): Immediate executive demo, 24hr SLA, dedicated specialist
     - High (70-89): Fast-track to NDA within 48hrs, premium support
     - Medium (50-69): Standard 72hr SLA, shared resource pool
     - Low (<50): Automated nurture sequence, self-service onboarding
   - Autonomy: Fully autonomous for scoring and tier assignment
   - Escalation: Alerts Sales Manager for critical-priority clients (score >= 90)
   - Output: priority_score, priority_tier, invest_decision, suggested_actions
   - Impact: Drives agent assignment prioritization, SLA tier, and resource allocation decisions

5. **Research Chat Agent (RAG-powered)**
   - Responsibility: Answers questions about research findings in natural language
   - Tools: LLM (GPT-4), Qdrant semantic search on research data, source citation generator
   - Autonomy: Fully autonomous for Q&A
   - Escalation: None (read-only access to research data)

6. **Volume Prediction Agent**
   - Responsibility: Predicts actual chat/call volumes based on collected data (historical trends, marketing spend, website traffic, seasonal factors) to assess client prioritization and resource investment
   - Tools: ML prediction models, time-series analysis, Google Ads/Meta Ads spend estimators, LLM for confidence scoring
   - Autonomy: Fully autonomous for volume predictions
   - Escalation: Flags low-confidence predictions (<0.70) for sales agent review

6. **Outbound Email Generation Agent**
   - Responsibility: Generates personalized outbound emails from research findings and proposed demo scope
   - Tools: LLM (GPT-4), email templates, personalization engine, research data accessors
   - Autonomy: Fully autonomous for email generation and sending (if email available)
   - Escalation: Creates manual outreach ticket if no email found in research

7. **Client Feedback Analysis Agent**
   - Responsibility: Analyzes client feedback, extracts requirements, updates demo scope
   - Tools: LLM (GPT-4), sentiment analysis, requirement extractors
   - Autonomy: Fully autonomous for feedback analysis
   - Escalation: Alerts Sales Team Lead for negative feedback or unclear requirements

**Approval Workflows:**
1. Research Job Creation → Auto-approved for existing clients, requires Sales Lead approval for new clients
2. Research Completion → Auto-send outbound email (if email available) OR create manual outreach ticket
3. Outbound Email Sending → Auto-approved and sent with tracking
4. Manual Outreach Ticket → Auto-assigned to available SDR
5. Client Feedback Received → Auto-triggers demo generation with updated requirements
6. Mystery Shopping Tasks → Auto-assigned to available agents, QA review before report inclusion
7. Third-Party API Costs > $20 → Requires Research Operations Manager approval

---

### 2. Demo Generator Service

#### Objectives
- **Primary Purpose**: Automated generation of client-specific AI chatbot and voicebot demos with mock data and tools
- **Business Value**: Reduces demo creation time from 40+ hours to <2 hours, enables rapid iteration, increases win rates through personalized demos
- **Product Differentiation**: Supports both chatbot (LangGraph-based) and voicebot (LiveKit-based) demo generation with product-specific configurations
- **Scope Boundaries**:
  - **Does**: Generate functional web UI demos, create mock datasets, integrate mock tools, deploy to sandboxed environments, enable developer testing, support both chatbot and voicebot product types
  - **Does Not**: Access production client data, deploy to production, handle real transactions

#### Requirements

**Functional Requirements:**
1. Generate exceptional, smooth, beautiful demo UI with client branding (logo, colors)
2. **Dynamic Demo Generation** (Client-Specific):
   - Auto-generate system prompt from research findings
   - Auto-generate mock tools based on client's use case
   - **For Chatbot Demos**: Use LangGraph two-node workflow (agent node + tools node) per https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/
   - **For Voicebot Demos**: Use LiveKit VoicePipelineAgent with STT/TTS integration (NOT LangGraph)
   - Create contextually relevant mock data (customer profiles, conversations)
   - Deploy to isolated sandbox for client viewing
   - Support product_types differentiation (chatbot vs voicebot)
3. **Real Showcase Demos** (For Client Presentations):
   - Pre-built showcase demos (2-5 permanent demos) with real tools and integrations
   - Full admin dashboard access with appropriate permissions for clients to explore
   - Real integrations (Salesforce, Zendesk, Shopify, etc.) with sample data
   - NOT live production systems - dedicated showcase environments only
   - Used to demonstrate actual platform capabilities to prospects
4. Enable client feedback directly within demo interface (inline comments, ratings)
5. Display transparent agent workflow visualization (tool calls, reasoning steps)
6. Enable developer testing with issue tracking
7. Iterate on feedback until "demo perfect" status
8. Support A/B demo variations for same client

**Non-Functional Requirements:**
- Demo generation time: <30 minutes from research completion
- Demo availability: 99.5% uptime during client presentation window
- Concurrent demos: Support 100+ active sandbox environments
- Security: Complete tenant isolation, no cross-demo data leakage
- Performance: <2s initial load, <500ms chatbot response time
- UI/UX: Exceptional design quality, smooth animations, mobile-responsive

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
1. ✅ Exceptional UI generation with client branding (logo, brand colors from research)
2. ✅ Smooth, beautiful design with micro-animations and transitions
3. ✅ **Dynamic Demo Generation (Client-Specific)**:
   - Auto-generate system prompt from research (business context, pain points, use case)
   - Auto-generate mock tools (e.g., `fetch_order_status`, `schedule_appointment`, `process_refund`)
   - **Chatbot Demos**: Implement LangGraph two-node workflow (agent node + tools node)
   - **Voicebot Demos**: Implement LiveKit VoicePipelineAgent with mock STT/TTS
   - Mock tool responses return realistic data based on research
   - Product type selection (chatbot, voicebot, or both)
4. ✅ **Real Showcase Demos (For Client Presentations)**:
   - 2-5 pre-built permanent showcase demos with real integrations (Salesforce, Zendesk, Shopify)
   - Full admin dashboard accessible to clients with appropriate permissions
   - Analytics, user management, settings interfaces fully functional
   - Real-time monitoring and performance metrics
   - Sample data and multi-tenant views for comprehensive demonstration
   - Dedicated showcase environments (NOT live production systems)
5. ✅ Client feedback interface (inline comments, emoji reactions, ratings)
6. ✅ Transparent agent workflow visualization (tool calls, reasoning, data flow)
7. ✅ Sandbox environment provisioning (Kubernetes namespace per demo)
8. ✅ Developer testing workflow (issue creation, fix tracking)
9. ✅ Demo versioning and rollback
10. ✅ Shareable demo links with client-specific access controls

**Nice-to-Have:**
11. 🔄 Real-time collaboration on demo (multiplayer editing)
12. 🔄 Analytics on demo interactions (heatmaps, engagement)
13. 🔄 Auto-generated demo scripts for sales team
14. 🔄 Demo recording and playback

**Feature Interactions:**
- Research findings → Auto-populate demo context
- Developer fixes → Auto-update demo, notify sales team
- Demo approval → Trigger client meeting scheduling

#### API Specification

**1. Generate Dynamic Demo (Client-Specific)**
```http
POST /api/v1/demos/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "research_job_id": "uuid",
  "client_id": "uuid",
  "demo_type": "dynamic",
  "product_types": ["chatbot", "voicebot"],  // Can generate both or single product type
  "demo_config": {
    "channels": ["webchat", "voice"],
    "use_cases": ["customer_support", "lead_qualification"],
    "auto_generate_system_prompt": true,
    "auto_generate_tools": true,
    "chatbot_config": {  // Only if "chatbot" in product_types
      "framework": "langgraph",
      "workflow": {
        "type": "two_node",
        "nodes": ["agent", "tools"],
        "architecture_reference": "https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/"
      },
      "include_external_integrations": false  // Mock demo, no real integrations
    },
    "voicebot_config": {  // Only if "voicebot" in product_types
      "framework": "livekit",
      "stt_provider": "deepgram_mock",
      "tts_provider": "elevenlabs_mock",
      "voice_id": "sarah_professional"
    },
    "branding_from_research": true,
    "conversation_samples": 10
  }
}

Response (202 Accepted):
{
  "demo_id": "uuid",
  "demo_type": "dynamic",
  "product_types": ["chatbot", "voicebot"],
  "status": "generating",
  "generation_plan": {
    "system_prompt": "Auto-generating from research findings (business context, pain points)",
    "mock_tools": [
      {
        "tool_name": "fetch_order_status",
        "generated_from": "e-commerce context in research",
        "mock_response_type": "realistic_order_data"
      },
      {
        "tool_name": "schedule_appointment",
        "generated_from": "customer support use case",
        "mock_response_type": "calendar_slots"
      }
    ],
    "chatbot_implementation": {
      "framework": "langgraph",
      "workflow_type": "two_node",
      "state_management": "postgresql_checkpointing"
    },
    "voicebot_implementation": {
      "framework": "livekit",
      "stt_provider": "deepgram_mock",
      "tts_provider": "elevenlabs_mock",
      "latency_target_ms": 500
    },
    "branding": {
      "logo_url": "https://storage.workflow.com/logos/acme-primary.png",
      "primary_color": "#1a73e8",
      "source": "research_job_uuid"
    }
  },
  "estimated_completion": "2025-10-04T11:00:00Z",
  "webhook_url": "https://api.workflow.com/webhooks/demo-ready"
}

Error Responses:
400 Bad Request: Invalid research_job_id or missing required config
402 Payment Required: Tenant exceeded demo quota
422 Unprocessable Entity: Research data insufficient for demo generation
```

**1b. Generate Showcase Demo (Real Tools & Admin - For Client Presentations)**
```http
POST /api/v1/demos/generate-showcase
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "showcase_type": "full_platform",
  "demo_config": {
    "channels": ["webchat", "voice"],
    "use_cases": ["customer_support", "sales", "analytics"],
    "real_integrations": ["salesforce", "zendesk", "shopify"],
    "include_admin_dashboard": true,
    "include_analytics": true,
    "multi_tenant_demo": true,
    "sample_tenants": 3
  },
  "purpose": "client_presentation",
  "client_id": "uuid"
}

Response (202 Accepted):
{
  "demo_id": "uuid",
  "demo_type": "showcase",
  "status": "ready",
  "note": "Using pre-built showcase demo #2 (e-commerce template)",
  "includes": {
    "admin_dashboard": true,
    "real_integrations": ["salesforce", "zendesk", "shopify"],
    "analytics_dashboard": true,
    "user_management": true,
    "settings_interface": true,
    "multi_tenant_view": true,
    "sample_data": "realistic_e_commerce_data"
  },
  "access": {
    "demo_url": "https://showcase.workflow.com/e-commerce-demo",
    "admin_url": "https://showcase.workflow.com/e-commerce-demo/admin",
    "client_credentials": {
      "role": "admin_viewer",
      "username": "john@acme.com",
      "permissions": ["view_dashboard", "view_analytics", "view_settings", "test_chatbot"],
      "restrictions": ["no_delete", "no_user_management"]
    }
  },
  "showcase_environment": "dedicated (NOT production)",
  "available_showcase_demos": [
    "e-commerce (Shopify, Stripe, Zendesk)",
    "healthcare (Epic, Twilio, Salesforce Health Cloud)",
    "saas (Intercom, Stripe, HubSpot)",
    "financial_services (Plaid, Salesforce Financial Services)"
  ]
}
```

**2. Get Demo Status**
```http
GET /api/v1/demos/{demo_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "demo_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
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

**5. Submit Client Feedback on Demo**
```http
POST /api/v1/demos/{demo_id}/client-feedback
Authorization: Bearer {demo_access_token}
Content-Type: application/json

Request Body:
{
  "client_contact": {
    "name": "John Smith",
    "email": "john@acme.com",
    "role": "CEO"
  },
  "feedback_type": "inline_comment",
  "location": {
    "component": "chat_widget",
    "message_id": "msg_123",
    "timestamp": "2025-10-04T14:30:00Z"
  },
  "comment": "Love how the AI automatically detected my order issue! Can we also show product recommendations here?",
  "rating": {
    "type": "emoji",
    "value": "😍"
  },
  "overall_impression": {
    "rating": 5,
    "would_recommend": true,
    "comments": "This is exactly what we need. The transparent workflow view showing tool calls is very helpful to understand how it works."
  }
}

Response (201 Created):
{
  "feedback_id": "uuid",
  "demo_id": "uuid",
  "status": "received",
  "client_contact": {
    "name": "John Smith",
    "role": "CEO"
  },
  "feedback_summary": {
    "total_comments": 1,
    "avg_rating": 5,
    "sentiment": "very_positive"
  },
  "notification_sent_to": ["sales_engineer_uuid"],
  "created_at": "2025-10-04T14:31:00Z"
}

Event Published to Kafka:
Topic: demo_events
{
  "event_type": "client_feedback_received",
  "demo_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "feedback_id": "uuid",
  "sentiment": "very_positive",
  "timestamp": "2025-10-04T14:31:00Z"
}
```

**6. Mark Demo as Perfect**
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
  "product_types": ["chatbot", "voicebot"],
  "timestamp": "2025-10-04T15:00:00Z"
}
```

**7. Get Demo Analytics**
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

**2. Exceptional Demo UI (Client-Facing)**
- Component: `ClientDemoInterface.tsx`
- Features:
  - **Exceptional Design**: Smooth animations, micro-interactions, beautiful typography
  - **Client Branding**: Auto-applied logo and brand colors from research
  - **Transparent Workflow Visualization**:
    - Live agent reasoning display ("Analyzing your order status...")
    - Tool call cards ("🔧 Calling fetch_order_status with order_id: ORD-78945")
    - Data flow visualization (API → AI → Response)
    - Processing time indicators (STT: 320ms, LLM: 1.2s, TTS: 75ms)
  - **Client Feedback Interface**:
    - Inline comment bubbles on any message (💬 "Love this!")
    - Emoji reactions (😍 👍 🤔 😕)
    - Star ratings per interaction
    - Overall impression form (expandable)
  - **Mobile-Responsive**: Flawless experience on all devices
  - **Accessibility**: WCAG 2.1 AA compliant

**3. Demo Builder Canvas**
- Component: `DemoBuilderCanvas.tsx`
- Features:
  - Drag-and-drop UI editor with component library
  - Live preview mode (desktop, tablet, mobile)
  - Mock data editor (inline editing)
  - Version history with visual diff
  - Workflow visualization editor (customize what clients see)

**4. Developer Testing Dashboard**
- Component: `DevTestingDashboard.tsx`
- Features:
  - Issue tracker (Kanban board: Open, In Progress, Fixed, Verified)
  - Test execution logs
  - Screenshot annotations
  - Device/browser matrix testing status
  - Automated test results integration

**5. Demo Presentation View**
- Component: `DemoPresentationView.tsx`
- Features:
  - Fullscreen demo player
  - Presenter controls (pause, reset conversation, switch scenarios)
  - Toggle workflow visualization on/off
  - Side-by-side comparison (current vs proposed solution)
  - Real-time analytics overlay (engagement heatmap)
  - Screen recording with annotated commentary

**6. Client Feedback Dashboard**
- Component: `ClientFeedbackDashboard.tsx`
- Features:
  - Real-time feedback stream (comments, ratings, reactions)
  - Sentiment analysis visualization
  - Comment threading and replies
  - Feedback categorization (UI, functionality, feature requests)
  - Export to PDF for stakeholder reviews

**7. Demo Management Dashboard**
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

#### Technical Architecture: LangGraph Two-Node Workflow

**Dynamic Demo Implementation:**

Each demo uses the same LangGraph architecture with dynamically generated components:

```python
# Core LangGraph Workflow (Same for All Demos)
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage

# State Definition
class State(TypedDict):
    messages: Annotated[list, add_messages]

# Two-Node Architecture (per LangGraph tutorial)
workflow = StateGraph(State)

# Node 1: Agent Node (LLM Reasoning)
def agent_node(state):
    # Uses dynamically generated system prompt
    system_prompt = load_from_demo_config(demo_id, "system_prompt")
    response = llm.invoke([system_prompt] + state["messages"])
    return {"messages": [response]}

# Node 2: Tools Node (Tool Execution)
def tools_node(state):
    # Uses dynamically generated mock tools
    tools = load_from_demo_config(demo_id, "tools")
    tool_calls = state["messages"][-1].tool_calls
    responses = [execute_tool(tool_call, tools) for tool_call in tool_calls]
    return {"messages": responses}

# Workflow Definition
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tools_node)
workflow.add_conditional_edges("agent", should_continue, {"tools": "tools", "end": END})
workflow.add_edge("tools", "agent")
workflow.set_entry_point("agent")

app = workflow.compile()
```

**What Changes Per Demo:**
1. **System Prompt** (auto-generated from research):
   ```
   "You are a helpful customer support agent for {company_name}.
   The company specializes in {business_type} and customers frequently ask about {common_pain_points}.
   Your goal is to resolve issues quickly while maintaining a {tone} tone."
   ```

2. **Mock Tools** (auto-generated from use case):
   ```python
   # E-commerce demo gets:
   tools = [
       fetch_order_status(order_id: str) -> OrderStatus,
       schedule_delivery(order_id: str, date: str) -> Confirmation,
       process_refund(order_id: str, amount: float) -> RefundStatus
   ]

   # Healthcare demo gets:
   tools = [
       fetch_patient_record(patient_id: str) -> PatientRecord,
       schedule_appointment(patient_id: str, date: str) -> Appointment,
       check_insurance_coverage(patient_id: str) -> Coverage
   ]
   ```

3. **Mock Tool Responses** (realistic data from research):
   ```python
   def fetch_order_status_mock(order_id: str):
       # Returns data matching client's business context
       return {
           "order_id": order_id,
           "status": "in_transit",
           "items": generate_realistic_items(client_research),
           "delivery_date": "2025-10-15"
       }
   ```

**Showcase Demo Implementation:**

Pre-built showcase demos (2-5 permanent environments) use the same workflow but with:
- Real tool implementations (actual API calls to Salesforce, Zendesk, etc.)
- Dedicated showcase database (NOT production)
- Full admin dashboard with client-appropriate permissions
- Multi-tenant data (3 sample tenants with realistic data)
- Client access with view/test permissions only (no delete, no user management)

**Available Showcase Demo Templates:**
1. E-commerce: Shopify + Stripe + Zendesk integrations
2. Healthcare: Epic + Twilio + Salesforce Health Cloud
3. SaaS: Intercom + Stripe + HubSpot
4. Financial Services: Plaid + Salesforce Financial Services

**Reference:** https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/

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
   - Responsibility: Orchestrates exceptional UI generation with branding, mock data creation, deployment
   - Tools: Code generators (React component builder), brand asset processors (logo optimization), mock data synthesizers, Kubernetes API
   - Autonomy: Fully autonomous for standard demos
   - Escalation: Human approval required for custom integrations or non-standard templates

2. **Mock Data Synthesis Agent**
   - Responsibility: Creates realistic mock datasets from research context with client branding
   - Tools: LLM (GPT-4 for context understanding), data generators (Faker.js), domain knowledge bases
   - Autonomy: Fully autonomous within data volume limits (max 1000 mock records)
   - Escalation: Alerts on insufficient research data for quality mock generation

3. **Workflow Visualization Agent**
   - Responsibility: Generates real-time transparent workflow displays (tool calls, reasoning, timing)
   - Tools: Agent activity trackers, visualization renderers, animation libraries
   - Autonomy: Fully autonomous
   - Escalation: None (read-only display of agent operations)

4. **Issue Resolution Agent**
   - Responsibility: Analyzes developer feedback, suggests fixes, auto-patches simple issues
   - Tools: Code analysis (AST parsers), LLM for bug diagnosis, GitHub API
   - Autonomy: Auto-fixes for trivial issues (typos, CSS adjustments), suggests fixes for complex bugs
   - Escalation: Complex issues assigned to human developers with AI-generated fix recommendations

5. **Client Feedback Analysis Agent**
   - Responsibility: Analyzes client feedback sentiment, categorizes comments, prioritizes improvements
   - Tools: LLM (GPT-4 for sentiment analysis), categorization models, prioritization algorithms
   - Autonomy: Fully autonomous for analysis and recommendations
   - Escalation: High-priority feedback (negative sentiment) alerts Sales Engineer immediately

**Approval Workflows:**
1. Demo Generation → Auto-approved for standard templates, Sales Manager approval for custom/enterprise
2. Developer Fixes → Auto-deployed to sandbox, no approval required
3. Demo Approval (Perfect Status) → Sales Engineer approval, triggers client meeting scheduling
4. Demo Extension (>30 days) → Sales Manager approval required

---

### 3. Sales Document Generator Service

**Service Consolidation**: Service 3 is a unified Sales Document Generator that combines NDA generation (formerly Service 3), pricing model generation (formerly Service 4), and proposal generation (formerly Service 5). This consolidation eliminates the distributed monolith anti-pattern where three tightly-coupled services formed a sequential pipeline with shared templates and e-signature integration.

**Consolidation Benefits**:
- Eliminates 3-hop distributed transaction (150-300ms latency reduction)
- Single e-signature integration (DocuSign/HelloSign)
- Unified template management system
- Simplified saga pattern
- Single database for all sales documents

#### Objectives
- **Primary Purpose**: Automated generation and management of all sales documents (NDAs, pricing models, proposals) with e-signature workflow and interactive editing capabilities
- **Business Value**: Reduces sales cycle from 15+ days to <2 days, ensures compliance and consistency, eliminates distributed transaction overhead
- **Scope Boundaries**:
  - **Does**: Generate customized NDAs, pricing models, and proposals; manage e-signature workflow; provide conversational and canvas editing; track signature status; handle reminders and approvals
  - **Does Not**: Provide legal advice, handle complex contract negotiations beyond standard terms, manage payment processing or subscriptions

#### Requirements

**Functional Requirements:**

**NDA Generation (formerly Service 3):**
1. Generate NDAs from templates based on client business type and deal size
2. Populate client's registered business address from Research Engine data for legal accuracy
3. Integrate with e-signature platforms (AdobeSign, DocuSign, HelloSign)
4. Automated sending after pilot agreement in client meeting
5. Track signature status with automated reminders
6. Store executed NDAs with audit trail
7. Support multi-party NDAs (client + subcontractors)
8. Version control for NDA templates

**Pricing Model Generation (formerly Service 4):**
9. Generate pricing models from templatized structures based on use case complexity
10. Integrate Ashay's financial cost module (LLM costs, infrastructure, voice minutes)
11. Calculate pricing tiers (Starter, Professional, Enterprise) with margin targets
12. Support usage-based pricing (per conversation, per minute, per API call)
13. Include volume discounts and custom enterprise pricing
14. Generate pricing proposal documents (PDF, interactive web view)
15. Track pricing experiments and conversion rates (A/B testing)

**Proposal Generation (formerly Service 5):**
16. Generate proposals/agreements from templates based on PRD and pricing data
17. Provide webchat UI for conversational editing ("make payment terms NET-30")
18. Enable manual editing in side-by-side canvas (WYSIWYG editor)
19. Version control with change tracking and rollback
20. Collaborative editing with real-time updates (multi-user)
21. Export to multiple formats (PDF, DOCX, Google Docs)
22. E-signature integration for final agreement
23. Template library management (legal-approved templates for all document types)
24. Comment threads on document sections

**Non-Functional Requirements:**
- NDA generation: <2 minutes from trigger
- Pricing calculation: <10 seconds including cost modeling
- Proposal generation: <3 minutes for standard proposal
- E-signature delivery: <5 minutes after generation
- Real-time collaboration: Support 5 concurrent editors per document
- 99.9% uptime for signature verification
- GDPR/CCPA compliance for PII handling
- Support 1000+ concurrent pricing calculations
- Support 500 concurrent document workflows
- Auto-save every 30 seconds
- Margin accuracy: ±2% of target margin (30-50% depending on tier)
- Support documents up to 50 pages

**Dependencies:**
- Service 0 (Organization & Identity Management) - authentication and tenant isolation
- Service 1 (Research Engine) - retrieves client's registered business address for NDA template population, provides predicted volumes for pricing tier recommendations
- Service 2 (Demo Generator) - consumes demo_approved + client_agreed_pilot events to trigger NDA generation
- Service 6 (PRD Builder) - triggers PRD creation session after NDA signing; provides use case complexity, volume requirements, and technical scope for pricing; provides technical requirements for proposal scope section
- Configuration Management - NDA/pricing/proposal templates, client business classifications
- Financial Cost Module (Ashay's module) - cost calculations for pricing models
- External APIs: AdobeSign, DocuSign, HelloSign (e-signature), SendGrid (email delivery)

**Data Storage:**
- PostgreSQL: All sales document metadata (NDAs, pricing models, proposals), signature status, audit logs, versions, collaboration sessions, approval workflows, pricing experiments
- S3: Document files (PDF, DOCX), version snapshots, signature evidence (encrypted at rest)
- Redis: Cached cost calculations, pricing rules, real-time collaboration state (active editors, cursor positions)
- Vault: E-signature API credentials, client contact encryption

#### Features

**Must-Have:**

**NDA Features:**
1. ✅ Template-based NDA generation (legal-approved templates)
2. ✅ Dynamic field population (client name, date, business type, scope)
3. ✅ Multi-platform e-signature integration (AdobeSign primary, DocuSign fallback)
4. ✅ Automated sending workflow (email + SMS notifications)
5. ✅ Signature tracking dashboard
6. ✅ Automated reminder sequences (Day 2, 5, 7 if unsigned)
7. ✅ Audit trail (who accessed, when signed, IP address)

**Pricing Features:**
8. ✅ Template-based pricing model selection
9. ✅ Financial cost calculation integration (LLM, infrastructure, voice)
10. ✅ Margin-based pricing with tier variations
11. ✅ Usage-based pricing calculators
12. ✅ Volume discount automation (>1000 conversations = 15% off)
13. ✅ Custom enterprise pricing workflows
14. ✅ Pricing proposal PDF generation
15. ✅ A/B pricing experiment framework

**Proposal Features:**
16. ✅ Template-based proposal generation (SOW, MSA, Service Agreement)
17. ✅ Webchat UI for conversational editing
18. ✅ Side-by-side canvas editor (Quill/TipTap)
19. ✅ Version control with diff viewer
20. ✅ Real-time collaborative editing (Yjs/CRDT)
21. ✅ Export to multiple formats (PDF, DOCX, Google Docs)
22. ✅ E-signature workflow integration
23. ✅ Comment threads on sections

**Nice-to-Have:**
24. 🔄 AI-powered clause recommendations based on industry
25. 🔄 Multi-language support for all document types
26. 🔄 Bulk document generation for enterprise clients
27. 🔄 Integration with contract management systems (Ironclad, Concord, LegalSifter)
28. 🔄 Competitive pricing analysis (auto-fetch competitor pricing)
29. 🔄 Dynamic pricing based on market conditions
30. 🔄 Pricing optimization ML (recommend optimal price point)
31. 🔄 Multi-year contract discounting
32. 🔄 Redlining and track changes mode for proposals
33. 🔄 Smart templates with conditional logic

**Feature Interactions:**
- Pilot agreement in demo meeting → Auto-generates NDA
- NDA signed → Triggers PRD Builder session creation
- NDA expiry approaching → Alerts sales team for renewal
- PRD approved → Triggers pricing model generation (consumes prd_approved event)
- Use case complexity from PRD → Determines base pricing tier
- Predicted volumes from Research Engine → Informs tier recommendations
- Cost module integration → Ensures margin targets met
- Pricing approval → Triggers proposal generation
- PRD approved → Auto-populates technical scope section in proposal
- Pricing approval → Auto-populates proposal pricing section
- Proposal finalization → Triggers e-signature workflow

#### API Specification

**NDA Endpoints**

**1. Generate NDA**
```http
POST /api/v1/ndas/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "business_type": "e-commerce",
  "deal_size_estimate": 250000,
  "template_id": "standard_saas_nda_v3",
  "business_address": {
    "street": "123 Business Ave, Suite 400",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94105",
    "country": "USA"
  },
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

Note: The `business_address` is automatically populated from Research Engine data. The NDA Generation Agent retrieves the registered business address via GET /api/v1/research/jobs/{job_id}/report and extracts the verified business_data.registered_address fields.

Response (201 Created):
{
  "nda_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
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
  "product_types": ["chatbot", "voicebot"],
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
  "product_types": ["chatbot", "voicebot"],
  "signed_at": "2025-10-07T09:15:00Z",
  "effective_date": "2025-10-07",
  "expiration_date": "2027-10-07"
}
```

**Pricing Endpoints**

**7. Generate Pricing Model**
```http
POST /api/v1/pricing-models
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "nda_id": "uuid",
  "prd_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "use_case": {
    "type": "customer_support",
    "complexity": "medium",
    "expected_volume": {
      "conversations_per_month": 5000,
      "voice_minutes_per_month": 1200,
      "api_calls_per_month": 15000
    }
  },
  "pricing_strategy": "usage_based",
  "target_margin_percent": 40,
  "currency": "USD",
  "contract_term_months": 12
}

Response (201 Created):
{
  "pricing_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "cost_breakdown": {...},
  "pricing_tiers": [
    {
      "tier": "starter",
      "monthly_price": 1999.00,
      "margin_percent": 35.0
    },
    {
      "tier": "professional",
      "monthly_price": 3499.00,
      "margin_percent": 40.0
    },
    {
      "tier": "enterprise",
      "monthly_price": 6999.00,
      "margin_percent": 45.0
    }
  ],
  "proposal_url": "https://storage.workflow.com/pricing/acme-pricing.pdf"
}
```

**8. Get Pricing Model**
```http
GET /api/v1/pricing-models/:id
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "pricing_id": "uuid",
  "status": "approved",
  "cost_breakdown": {...},
  "pricing_tiers": [...],
  "selected_tier": "professional",
  "final_monthly_price": 3149.10,
  "contract_value_annual": 37789.20
}
```

**9. Update Pricing Model**
```http
PUT /api/v1/pricing-models/:id
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "adjust_margin_percent": 35,
  "apply_custom_discount_percent": 5,
  "custom_discount_reason": "Early adopter incentive"
}

Response (200 OK):
{
  "pricing_id": "uuid",
  "status": "updated",
  "version": 2,
  "new_pricing_tiers": [...]
}
```

**10. Approve Pricing**
```http
POST /api/v1/pricing-models/:id/approve
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "pricing_id": "uuid",
  "status": "approved",
  "approved_by": "uuid",
  "approved_at": "2025-10-09T14:00:00Z"
}
```

**Proposal Endpoints**

**11. Generate Proposal**
```http
POST /api/v1/proposals
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "pricing_id": "uuid",
  "prd_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "template_id": "saas_sow_v2",
  "proposal_type": "statement_of_work"
}

Response (201 Created):
{
  "proposal_id": "uuid",
  "client_id": "uuid",
  "status": "draft",
  "document_url": "https://proposals.workflow.com/acme-sow",
  "edit_url": "https://proposals.workflow.com/edit/uuid",
  "webchat_url": "https://proposals.workflow.com/chat/uuid",
  "version": 1
}
```

**12. Get Proposal**
```http
GET /api/v1/proposals/:id
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "proposal_id": "uuid",
  "client_id": "uuid",
  "status": "draft",
  "sections": [...],
  "version": 1,
  "created_at": "2025-10-09T11:00:00Z"
}
```

**13. Update Proposal via Webchat**
```http
POST /api/v1/proposals/:id/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "Change payment terms to NET-30",
  "session_id": "uuid"
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "chat_response": "I've updated the payment terms to NET-30...",
  "changes_made": [...],
  "version": 2
}
```

**14. Update Proposal Section (Canvas)**
```http
PUT /api/v1/proposals/:id/sections/:section_id
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "content": "<p>Updated content</p>",
  "editor_id": "uuid"
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "section_id": "uuid",
  "version": 3,
  "updated_at": "2025-10-09T11:30:00Z"
}
```

**15. Send Proposal for Signature**
```http
POST /api/v1/proposals/:id/send
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "recipients": [
    {
      "name": "John Smith",
      "email": "john@acme.com",
      "role": "CEO"
    }
  ],
  "enable_esignature": true
}

Response (200 OK):
{
  "proposal_id": "uuid",
  "status": "sent",
  "sent_at": "2025-10-09T12:00:00Z",
  "esignature_workflow_id": "adobesign_xyz456"
}
```

**16. Get Proposal Status**
```http
GET /api/v1/proposals/:id/status
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "proposal_id": "uuid",
  "status": "signed",
  "signed_at": "2025-10-10T14:00:00Z",
  "signed_by": "john@acme.com",
  "document_url": "https://storage.workflow.com/signed/acme-sow-signed.pdf"
}
```

**Shared Template Endpoints**

**17. List Templates**
```http
GET /api/v1/templates?type=nda|pricing|proposal
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "templates": [
    {
      "id": "uuid",
      "name": "Standard SaaS NDA v3",
      "type": "nda",
      "version": 3,
      "status": "approved"
    },
    {
      "id": "uuid",
      "name": "Professional Tier Pricing",
      "type": "pricing",
      "version": 2,
      "status": "approved"
    }
  ]
}
```

**18. Create Template**
```http
POST /api/v1/templates
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "name": "Enterprise NDA Template",
  "type": "nda",
  "content": "...",
  "variables": ["client_name", "effective_date"]
}

Response (201 Created):
{
  "template_id": "uuid",
  "name": "Enterprise NDA Template",
  "status": "draft",
  "requires_approval": true
}
```

**19. Check E-Signature Status (Unified)**
```http
GET /api/v1/signatures/:signature_id
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "signature_id": "uuid",
  "document_id": "uuid",
  "document_type": "nda|proposal",
  "provider": "docusign|hellosign|adobesign",
  "status": "completed",
  "signed_at": "2025-10-10T14:00:00Z",
  "signatories": [...]
}
```

**Rate Limiting:**
- 50 NDA generations per hour per tenant
- 100 pricing calculations per hour per tenant
- 20 proposal generations per hour per tenant
- 100 reminder sends per day per tenant
- 500 chat messages per hour per proposal
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
5. Standard Pricing Model → Auto-approved if margin ≥30%, Finance Manager approval if <30%
6. Custom Discount >10% → VP Sales approval required
7. Enterprise Pricing (>$500K ACV) → VP Sales + CFO approval required
8. Pricing Experiment Launch → VP Sales approval required
9. Proposal Generation (Standard Template) → Auto-approved
10. Proposal Generation (Custom Template) → Legal Counsel approval required
11. Legal Clause Modifications → Legal Counsel approval required
12. Payment Term Changes → Finance Manager approval required
13. Proposal Finalization (>$500K Deal) → VP Sales approval required

#### Database Schema

**NDA Tables:**
```sql
CREATE TABLE ndas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  template_id UUID REFERENCES sales_templates(id),
  content JSONB NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'generated', 'sent', 'partially_signed', 'fully_signed', 'voided'
  document_url TEXT,
  signature_workflow_id VARCHAR(255),
  effective_date DATE,
  expiration_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_client_id (client_id),
  INDEX idx_status (status)
);

CREATE TABLE nda_signatories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nda_id UUID NOT NULL REFERENCES ndas(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(100),
  signing_order INT,
  status VARCHAR(50), -- 'pending', 'sent', 'viewed', 'signed'
  signed_at TIMESTAMPTZ,
  ip_address INET,
  signature_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Pricing Tables:**
```sql
CREATE TABLE pricing_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  nda_id UUID REFERENCES ndas(id),
  prd_id UUID,
  product_types TEXT[],
  status VARCHAR(50), -- 'generated', 'updated', 'approved', 'rejected'
  cost_breakdown JSONB NOT NULL,
  pricing_tiers JSONB NOT NULL,
  selected_tier VARCHAR(50),
  final_monthly_price DECIMAL(10,2),
  contract_value_annual DECIMAL(12,2),
  margin_actual_percent DECIMAL(5,2),
  currency VARCHAR(3) DEFAULT 'USD',
  contract_term_months INT,
  approved_by UUID,
  approved_at TIMESTAMPTZ,
  version INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_client_id (client_id),
  INDEX idx_status (status)
);

CREATE TABLE pricing_experiments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  experiment_name VARCHAR(255) NOT NULL,
  description TEXT,
  variants JSONB NOT NULL,
  target_metric VARCHAR(100),
  status VARCHAR(50), -- 'active', 'paused', 'completed', 'archived'
  duration_days INT,
  min_sample_size INT,
  results JSONB,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Proposal Tables:**
```sql
CREATE TABLE proposals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  nda_id UUID REFERENCES ndas(id),
  pricing_id UUID REFERENCES pricing_models(id),
  prd_id UUID,
  product_types TEXT[],
  template_id UUID REFERENCES sales_templates(id),
  proposal_type VARCHAR(100), -- 'statement_of_work', 'msa', 'service_agreement'
  status VARCHAR(50), -- 'draft', 'sent', 'signed', 'voided'
  current_version INT DEFAULT 1,
  document_url TEXT,
  edit_url TEXT,
  webchat_url TEXT,
  esignature_workflow_id VARCHAR(255),
  signed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_client_id (client_id),
  INDEX idx_status (status)
);

CREATE TABLE proposal_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  section_order INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  editable BOOLEAN DEFAULT true,
  source VARCHAR(50), -- NULL, 'pricing_model', 'prd', 'template'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE proposal_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  version INT NOT NULL,
  snapshot JSONB NOT NULL,
  change_summary TEXT,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(proposal_id, version)
);

CREATE TABLE proposal_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  section_id UUID REFERENCES proposal_sections(id) ON DELETE CASCADE,
  commenter_id UUID NOT NULL,
  comment TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'open', -- 'open', 'resolved'
  visibility VARCHAR(20) DEFAULT 'internal', -- 'internal', 'client'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);
```

**Shared Tables:**
```sql
CREATE TABLE sales_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID,
  template_type VARCHAR(50) NOT NULL, -- 'nda', 'pricing', 'proposal'
  name VARCHAR(255) NOT NULL,
  content TEXT,
  variables JSONB,
  version INT DEFAULT 1,
  status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'approved', 'archived'
  approved_by UUID,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  INDEX idx_template_type (template_type),
  INDEX idx_status (status)
);

CREATE TABLE e_signatures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  document_id UUID NOT NULL,
  document_type VARCHAR(50) NOT NULL, -- 'nda', 'proposal'
  provider VARCHAR(50) NOT NULL, -- 'docusign', 'hellosign', 'adobesign'
  signature_request_id VARCHAR(255),
  status VARCHAR(50), -- 'pending', 'sent', 'viewed', 'completed', 'declined', 'voided'
  signed_at TIMESTAMPTZ,
  signatories JSONB,
  audit_trail JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  INDEX idx_document_id (document_id),
  INDEX idx_status (status)
);

CREATE TABLE approval_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  document_id UUID NOT NULL,
  document_type VARCHAR(50) NOT NULL, -- 'nda', 'pricing', 'proposal'
  workflow_type VARCHAR(100), -- 'custom_clause', 'margin_adjustment', 'enterprise_pricing', etc.
  approver_id UUID NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  INDEX idx_document_id (document_id),
  INDEX idx_approver_id (approver_id),
  INDEX idx_status (status)
);
```

**Row-Level Security (RLS) Policies:**
```sql
-- All tables must filter by organization_id for multi-tenant isolation
ALTER TABLE ndas ENABLE ROW LEVEL SECURITY;
CREATE POLICY ndas_isolation ON ndas
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE pricing_models ENABLE ROW LEVEL SECURITY;
CREATE POLICY pricing_isolation ON pricing_models
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;
CREATE POLICY proposals_isolation ON proposals
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE e_signatures ENABLE ROW LEVEL SECURITY;
CREATE POLICY signatures_isolation ON e_signatures
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE approval_workflows ENABLE ROW LEVEL SECURITY;
CREATE POLICY approvals_isolation ON approval_workflows
  USING (organization_id = current_setting('app.current_organization_id')::UUID);
```

#### Kafka Events

**Topic**: `sales_doc_events` (unified topic for all sales document events)

**Event Schema:**
```json
{
  "event_type": "nda_generated | nda_sent | nda_signed | pricing_generated | pricing_approved | proposal_generated | proposal_sent | proposal_signed",
  "document_id": "uuid",
  "document_type": "nda | pricing | proposal",
  "organization_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "metadata": {
    // Event-specific metadata
  },
  "timestamp": "2025-10-08T..."
}
```

**Published Events:**

1. **NDA Fully Signed**
```json
{
  "event_type": "nda_signed",
  "document_id": "uuid",
  "document_type": "nda",
  "organization_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "metadata": {
    "signed_at": "2025-10-07T09:15:00Z",
    "effective_date": "2025-10-07",
    "expiration_date": "2027-10-07"
  },
  "timestamp": "2025-10-07T09:15:00Z"
}
```
**Consumers**: PRD Builder (triggers PRD session creation)

2. **Pricing Approved**
```json
{
  "event_type": "pricing_approved",
  "document_id": "uuid",
  "document_type": "pricing",
  "organization_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "metadata": {
    "selected_tier": "professional",
    "final_monthly_price": 3499.00,
    "contract_value_annual": 41988.00,
    "margin_actual_percent": 40.0,
    "approved_by": "uuid"
  },
  "timestamp": "2025-10-09T14:00:00Z"
}
```
**Consumers**: Proposal Generator (within same service - triggers proposal generation), Monitoring Engine (track conversion metrics)

3. **Proposal Signed**
```json
{
  "event_type": "proposal_signed",
  "document_id": "uuid",
  "document_type": "proposal",
  "organization_id": "uuid",
  "client_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "metadata": {
    "pricing_id": "uuid",
    "prd_id": "uuid",
    "signed_by": "client_stakeholder_uuid",
    "signed_at": "2025-10-10T14:00:00Z",
    "esignature_provider": "adobesign",
    "document_url": "https://storage.workflow.com/signed/acme-sow-signed.pdf"
  },
  "timestamp": "2025-10-10T14:00:00Z"
}
```
**Consumers**: Automation Engine (triggers YAML config generation), Customer Success Service (initiates onboarding), Monitoring Engine (track conversion)

**Consumed Events:**
- `demo_approved` (from Demo Generator) → Triggers NDA generation
- `prd_approved` (from PRD Builder) → Triggers pricing model generation

---

### 22. Billing & Revenue Management Service

#### Objectives
- **Primary Purpose**: Automated billing, payment processing, subscription management, and revenue recognition for client accounts with integrated dunning and financial reporting
- **Business Value**: Automates 95% of billing operations, reduces payment collection time from 30+ days to <7 days, eliminates manual invoice generation, ensures accurate revenue recognition
- **Scope Boundaries**:
  - **Does**: Process credit card payments, generate invoices, manage subscriptions, handle failed payment recovery, track usage-based billing, integrate with accounting systems, send payment reminders, manage subscription lifecycle
  - **Does Not**: Provide tax advice, replace accounting system of record, handle complex revenue recognition scenarios requiring CPA review, manage payroll or vendor payments

#### Requirements

**Functional Requirements:**

**Credit Card Processing:**
1. Stripe integration for credit card processing (primary payment gateway)
2. Automatic charge scheduling based on subscription billing cycle
3. Failed payment handling with retry logic (3 attempts over 7 days)
4. Payment method storage and encryption (PCI compliance)
5. Support for multiple payment methods per customer
6. 3D Secure authentication for international transactions
7. Real-time payment confirmation and receipt generation
8. Refund and chargeback management
9. Fraud detection integration (Stripe Radar)

**Invoice Generation:**
10. Automated invoice generation from subscription plans and usage data
11. Usage-based billing calculation (conversations, voice minutes, API calls)
12. Invoice line item breakdown with service descriptions
13. Email delivery of invoices to billing contacts
14. Invoice payment tracking and status management
15. Support for proration during subscription changes
16. Multi-currency support (USD, EUR, GBP)
17. PDF invoice generation with company branding
18. Invoice reconciliation with payment transactions

**Subscription Management:**
19. Subscription creation from signed proposals (triggered by proposal_signed event)
20. Support for multiple subscription plans (Starter, Professional, Enterprise)
21. Subscription upgrades and downgrades with proration
22. Subscription pause and resume capabilities
23. Subscription cancellation with end-of-term or immediate options
24. Trial period management (14-30 days)
25. Annual/monthly billing cycle support
26. Volume-based discounting application
27. Enterprise custom pricing support

**Dunning Management:**
28. Automated follow-up sequences for overdue invoices
29. Escalation workflow: reminder at 7 days, warning at 14 days, suspension notice at 21 days
30. Account suspension for non-payment (>30 days overdue)
31. Service restoration upon payment
32. Dunning analytics and success metrics
33. Customizable dunning email templates
34. Integration with Customer Success for high-value account escalations

**Revenue Recognition & Reporting:**
35. Deferred revenue tracking for annual subscriptions
36. Monthly revenue recognition based on subscription period
37. Usage revenue recognition in real-time
38. Financial reporting dashboard (MRR, ARR, churn, LTV)
39. QuickBooks Online integration for accounting sync
40. Avalara integration for tax calculation and compliance
41. Revenue forecasting based on active subscriptions
42. Cohort analysis and retention metrics

**Non-Functional Requirements:**
- Payment processing: <3 seconds response time
- Invoice generation: <30 seconds from trigger
- Failed payment retry: Within 24, 72, 168 hours (1, 3, 7 days)
- Dunning emails: Sent within 1 hour of due date trigger
- 99.99% uptime for payment processing
- PCI DSS Level 1 compliance
- Support 10,000+ active subscriptions
- Support 50,000+ invoices per month
- Real-time revenue metrics (<5 minute lag)
- Audit trail for all financial transactions
- Data retention: 7 years for compliance

**Dependencies:**
- Service 0 (Organization & Identity Management) - authentication, tenant isolation, billing contact management
- Service 3 (Sales Document Generator) - consumes proposal_signed events to create subscriptions, retrieves pricing data
- Service 20 (Communication & Hyperpersonalization) - email delivery for invoices, receipts, dunning messages
- Service 12 (Analytics) - usage data for usage-based billing calculations
- External APIs: Stripe (payments), QuickBooks (accounting), Avalara (tax), SendGrid (email delivery via Service 20)

**Data Storage:**
- PostgreSQL: Subscriptions, invoices, payment methods (encrypted), payment transactions, billing history, dunning logs, revenue recognition schedules
- S3: Invoice PDFs, payment receipts, audit documents (encrypted at rest)
- Redis: Payment processing locks, billing cycle cache, real-time revenue metrics
- Vault: Stripe API keys, payment method encryption keys, QuickBooks credentials

#### Features

**Must-Have:**
1. ✅ Stripe credit card processing integration
2. ✅ Automatic recurring billing based on subscription cycle
3. ✅ Failed payment retry logic with 3 attempts
4. ✅ Automated invoice generation and email delivery
5. ✅ Usage-based billing calculation (conversations, voice minutes)
6. ✅ Subscription creation from signed proposals
7. ✅ Subscription upgrade/downgrade with proration
8. ✅ Subscription cancellation workflows
9. ✅ Dunning automation with 3-tier escalation (7/14/21 days)
10. ✅ Account suspension for non-payment (>30 days)
11. ✅ Payment method management (add/update/delete)
12. ✅ Invoice PDF generation with branding
13. ✅ Revenue recognition for subscriptions
14. ✅ Financial dashboard (MRR, ARR, churn)
15. ✅ QuickBooks Online integration
16. ✅ Audit trail for all transactions

**Nice-to-Have:**
17. 🔄 Multi-currency support with real-time exchange rates
18. 🔄 ACH/bank transfer payment support
19. 🔄 PayPal integration
20. 🔄 Avalara tax calculation integration
21. 🔄 Custom billing schedules (quarterly, semi-annual)
22. 🔄 Credit memo and adjustment management
23. 🔄 Billing portal for customers (self-service)
24. 🔄 Subscription analytics and churn prediction
25. 🔄 Automated dunning optimization (ML-based timing)
26. 🔄 Revenue forecasting with predictive analytics
27. 🔄 NetSuite integration for enterprise customers

**Feature Interactions:**
- Proposal signed → Creates subscription and schedules first invoice
- Subscription created → Generates initial invoice with prorated charges
- Usage data from Analytics → Calculates usage-based billing line items
- Payment succeeded → Generates receipt, updates revenue recognition schedule
- Payment failed → Triggers retry logic, publishes failed payment event
- 3rd payment failure → Triggers dunning sequence
- Invoice overdue 7 days → Sends first dunning reminder
- Invoice overdue 21 days → Publishes account_at_risk event to Customer Success
- Account suspended → Publishes suspension event to Services 8, 9 (agent runtime)
- Payment received after suspension → Restores service, notifies customer
- Subscription upgraded → Prorates charges, generates adjustment invoice
- End of billing period → Recognizes deferred revenue for the period

#### API Specification

**Subscription Endpoints**

**1. Create Subscription**
```http
POST /api/v1/billing/subscriptions
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "organization_id": "uuid",
  "client_id": "uuid",
  "proposal_id": "uuid",
  "plan_id": "uuid",
  "billing_cycle": "monthly",
  "start_date": "2025-10-15",
  "trial_days": 14,
  "payment_method_id": "pm_stripe_abc123",
  "billing_contact": {
    "name": "Jane Smith",
    "email": "billing@acme.com",
    "phone": "+1-415-555-0199"
  }
}

Response (201 Created):
{
  "subscription_id": "uuid",
  "organization_id": "uuid",
  "client_id": "uuid",
  "plan_id": "uuid",
  "status": "trial",
  "billing_cycle": "monthly",
  "current_period_start": "2025-10-15",
  "current_period_end": "2025-10-29",
  "trial_end": "2025-10-29",
  "next_billing_date": "2025-10-29",
  "amount": 3499.00,
  "currency": "USD",
  "created_at": "2025-10-15T10:00:00Z"
}

Error Responses:
400 Bad Request: Invalid plan_id or payment method
422 Unprocessable Entity: Missing required billing contact
503 Service Unavailable: Stripe API unavailable
```

**2. Get Subscription**
```http
GET /api/v1/billing/subscriptions/{id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "subscription_id": "uuid",
  "organization_id": "uuid",
  "client_id": "uuid",
  "plan_id": "uuid",
  "plan_name": "Professional Plan",
  "status": "active",
  "billing_cycle": "monthly",
  "current_period_start": "2025-11-15",
  "current_period_end": "2025-12-15",
  "next_billing_date": "2025-12-15",
  "amount": 3499.00,
  "currency": "USD",
  "payment_method": {
    "id": "pm_stripe_abc123",
    "type": "card",
    "last4": "4242",
    "brand": "visa",
    "exp_month": 12,
    "exp_year": 2026
  },
  "usage_summary": {
    "conversations": 4523,
    "voice_minutes": 1834,
    "api_calls": 12456
  },
  "created_at": "2025-10-15T10:00:00Z",
  "updated_at": "2025-11-15T10:00:00Z"
}
```

**3. Update Subscription (Upgrade/Downgrade)**
```http
PUT /api/v1/billing/subscriptions/{id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "plan_id": "uuid",
  "proration_behavior": "create_prorations",
  "effective_date": "immediate"
}

Response (200 OK):
{
  "subscription_id": "uuid",
  "plan_id": "uuid",
  "new_plan_name": "Enterprise Plan",
  "status": "active",
  "amount": 6999.00,
  "proration_amount": 1166.33,
  "next_billing_date": "2025-12-15",
  "updated_at": "2025-11-20T14:30:00Z"
}
```

**4. Cancel Subscription**
```http
POST /api/v1/billing/subscriptions/{id}/cancel
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "cancellation_type": "end_of_period",
  "reason": "Customer requested cancellation",
  "feedback": "Switching to competitor due to pricing"
}

Response (200 OK):
{
  "subscription_id": "uuid",
  "status": "canceling",
  "cancel_at": "2025-12-15T23:59:59Z",
  "canceled_at": "2025-11-22T10:00:00Z",
  "access_until": "2025-12-15T23:59:59Z"
}
```

**Invoice Endpoints**

**5. Generate Invoice**
```http
POST /api/v1/billing/invoices/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "subscription_id": "uuid",
  "billing_period_start": "2025-11-15",
  "billing_period_end": "2025-12-15",
  "line_items": [
    {
      "description": "Professional Plan - Monthly Subscription",
      "amount": 3499.00,
      "quantity": 1
    },
    {
      "description": "Additional Conversations (523 over plan limit)",
      "amount": 104.60,
      "quantity": 523,
      "unit_price": 0.20
    }
  ],
  "auto_send": true
}

Response (201 Created):
{
  "invoice_id": "uuid",
  "invoice_number": "INV-2025-11-001234",
  "subscription_id": "uuid",
  "organization_id": "uuid",
  "client_id": "uuid",
  "status": "sent",
  "subtotal": 3603.60,
  "tax": 288.29,
  "total": 3891.89,
  "currency": "USD",
  "due_date": "2025-12-15",
  "invoice_url": "https://billing.workflow.com/invoices/uuid",
  "pdf_url": "https://storage.workflow.com/invoices/INV-2025-11-001234.pdf",
  "sent_to": "billing@acme.com",
  "sent_at": "2025-11-15T10:05:00Z",
  "created_at": "2025-11-15T10:00:00Z"
}
```

**6. Get Invoice**
```http
GET /api/v1/billing/invoices/{id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "invoice_id": "uuid",
  "invoice_number": "INV-2025-11-001234",
  "subscription_id": "uuid",
  "organization_id": "uuid",
  "client_id": "uuid",
  "status": "paid",
  "subtotal": 3603.60,
  "tax": 288.29,
  "total": 3891.89,
  "amount_paid": 3891.89,
  "currency": "USD",
  "due_date": "2025-12-15",
  "paid_at": "2025-11-16T14:23:00Z",
  "payment_method": "Visa •••• 4242",
  "line_items": [...],
  "invoice_url": "https://billing.workflow.com/invoices/uuid",
  "pdf_url": "https://storage.workflow.com/invoices/INV-2025-11-001234.pdf",
  "created_at": "2025-11-15T10:00:00Z"
}
```

**7. Get Invoice Status**
```http
GET /api/v1/billing/invoices/{id}/status
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "invoice_id": "uuid",
  "invoice_number": "INV-2025-11-001234",
  "status": "overdue",
  "total": 3891.89,
  "amount_paid": 0.00,
  "amount_due": 3891.89,
  "due_date": "2025-12-15",
  "days_overdue": 3,
  "payment_attempts": [
    {
      "attempt_date": "2025-12-15T00:05:00Z",
      "status": "failed",
      "failure_reason": "insufficient_funds"
    },
    {
      "attempt_date": "2025-12-16T00:05:00Z",
      "status": "failed",
      "failure_reason": "insufficient_funds"
    }
  ],
  "next_retry_date": "2025-12-19T00:05:00Z"
}
```

**Payment Endpoints**

**8. Charge Payment Method**
```http
POST /api/v1/billing/payments/charge
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "invoice_id": "uuid",
  "payment_method_id": "pm_stripe_abc123",
  "amount": 3891.89,
  "currency": "USD",
  "idempotency_key": "charge_20251115_uuid"
}

Response (200 OK):
{
  "payment_id": "uuid",
  "invoice_id": "uuid",
  "status": "succeeded",
  "amount": 3891.89,
  "currency": "USD",
  "payment_method": "Visa •••• 4242",
  "receipt_url": "https://storage.workflow.com/receipts/receipt_uuid.pdf",
  "stripe_payment_intent_id": "pi_stripe_xyz789",
  "processed_at": "2025-11-16T14:23:00Z"
}

Error Responses:
402 Payment Required: Card declined
422 Unprocessable Entity: Invalid payment method
500 Internal Server Error: Stripe API error
```

**9. Add Payment Method**
```http
POST /api/v1/billing/payment-methods
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "organization_id": "uuid",
  "stripe_payment_method_id": "pm_stripe_xyz789",
  "set_as_default": true
}

Response (201 Created):
{
  "payment_method_id": "uuid",
  "organization_id": "uuid",
  "type": "card",
  "card": {
    "brand": "mastercard",
    "last4": "5555",
    "exp_month": 6,
    "exp_year": 2027
  },
  "is_default": true,
  "created_at": "2025-11-16T15:00:00Z"
}
```

**10. Update Payment Method**
```http
PUT /api/v1/billing/payment-methods/{id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "exp_month": 8,
  "exp_year": 2028,
  "billing_address": {
    "line1": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94105",
    "country": "US"
  }
}

Response (200 OK):
{
  "payment_method_id": "uuid",
  "updated_at": "2025-11-16T15:30:00Z"
}
```

**11. Delete Payment Method**
```http
DELETE /api/v1/billing/payment-methods/{id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "payment_method_id": "uuid",
  "status": "deleted",
  "deleted_at": "2025-11-16T16:00:00Z"
}
```

**Dunning Endpoints**

**12. Get Dunning Status**
```http
GET /api/v1/billing/dunning/{organization_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "organization_id": "uuid",
  "dunning_status": "warning",
  "overdue_invoices": [
    {
      "invoice_id": "uuid",
      "invoice_number": "INV-2025-11-001234",
      "amount_due": 3891.89,
      "days_overdue": 10,
      "dunning_stage": "warning",
      "last_reminder_sent": "2025-12-18T10:00:00Z"
    }
  ],
  "total_overdue_amount": 3891.89,
  "suspension_date": "2025-12-29",
  "days_until_suspension": 11
}
```

**13. Send Manual Dunning Reminder**
```http
POST /api/v1/billing/dunning/remind
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "invoice_id": "uuid",
  "reminder_type": "custom",
  "message": "We noticed your recent payment didn't go through. Please update your payment method to avoid service interruption."
}

Response (200 OK):
{
  "invoice_id": "uuid",
  "reminder_sent": true,
  "sent_to": "billing@acme.com",
  "sent_at": "2025-12-18T14:30:00Z"
}
```

**Reporting Endpoints**

**14. Get Revenue Metrics**
```http
GET /api/v1/billing/reports/revenue
Authorization: Bearer {jwt_token}
Query Parameters: ?period=month&start_date=2025-01-01&end_date=2025-12-31

Response (200 OK):
{
  "period": "month",
  "start_date": "2025-01-01",
  "end_date": "2025-12-31",
  "mrr": 125430.00,
  "arr": 1505160.00,
  "new_mrr": 18900.00,
  "expansion_mrr": 5200.00,
  "contraction_mrr": -1800.00,
  "churned_mrr": -3500.00,
  "net_new_mrr": 18800.00,
  "active_subscriptions": 42,
  "churn_rate": 2.8,
  "ltv": 45680.00,
  "currency": "USD"
}
```

**15. Get Subscription Analytics**
```http
GET /api/v1/billing/reports/subscriptions
Authorization: Bearer {jwt_token}
Query Parameters: ?period=quarter&year=2025&quarter=Q4

Response (200 OK):
{
  "period": "Q4 2025",
  "total_subscriptions": 42,
  "subscriptions_by_plan": {
    "starter": 15,
    "professional": 20,
    "enterprise": 7
  },
  "new_subscriptions": 8,
  "canceled_subscriptions": 3,
  "upgraded_subscriptions": 4,
  "downgraded_subscriptions": 1,
  "retention_rate": 92.5,
  "average_subscription_value": 2986.43
}
```

#### Human Agents & AI Agents

**Human Agents:**

1. **Finance Manager**
   - Role: Oversees billing operations, revenue recognition, financial reporting
   - Access: Full access to all billing data, reports, dunning management
   - Permissions: read:all_billing, manage:subscriptions, approve:refunds, manage:dunning
   - Workflows: Reviews monthly revenue, approves refunds, handles escalated billing disputes

2. **Billing Administrator**
   - Role: Manages day-to-day billing operations, invoice corrections, payment issues
   - Access: Create/edit subscriptions, manage invoices, process refunds
   - Permissions: create:subscription, update:invoice, process:refund, manage:payment_methods
   - Workflows: Corrects billing errors, processes manual adjustments, assists with payment issues

3. **Accountant**
   - Role: Manages revenue recognition, accounting system sync, tax compliance
   - Access: Read-only access to revenue data, full access to QuickBooks sync
   - Permissions: read:revenue, manage:accounting_sync, export:financial_reports
   - Workflows: Monthly revenue reconciliation, QuickBooks journal entry review, tax reporting

**AI Agents:**

1. **Billing Automation Agent**
   - Responsibility: Generates invoices, processes recurring billing, calculates usage charges
   - Tools: Stripe API, usage data aggregation, PDF generator, email service
   - Autonomy: Fully autonomous for standard billing cycles
   - Escalation: Finance Manager review required for invoices >$50K or unusual usage spikes

2. **Payment Processing Agent**
   - Responsibility: Processes payments, handles failed payment retries, updates payment status
   - Tools: Stripe API, payment retry logic, fraud detection
   - Autonomy: Fully autonomous for standard payments
   - Escalation: Billing Administrator review required for fraud alerts or 3+ consecutive failures

3. **Dunning Management Agent**
   - Responsibility: Sends dunning reminders, escalates overdue accounts, triggers suspensions
   - Tools: Email service (via Service 20), dunning sequence rules, escalation logic
   - Autonomy: Fully autonomous for standard dunning sequences
   - Escalation: Customer Success Manager notified for accounts >$10K ARR overdue >14 days

4. **Revenue Recognition Agent**
   - Responsibility: Calculates deferred revenue, recognizes monthly revenue, updates financial records
   - Tools: Subscription data, revenue recognition schedule, QuickBooks API
   - Autonomy: Fully autonomous for standard subscriptions
   - Escalation: Accountant review required for complex revenue scenarios (multi-year contracts, custom terms)

**Approval Workflows:**
1. Standard Invoice Generation → Auto-approved and sent
2. Invoice >$50K → Finance Manager review before sending
3. Refund Request <$500 → Billing Administrator approval
4. Refund Request ≥$500 → Finance Manager approval
5. Payment Dispute → Billing Administrator investigation, Finance Manager approval for resolution
6. Account Suspension → Auto-executed after 30 days overdue (notification sent to Customer Success)
7. Manual Dunning Override → Billing Administrator approval
8. Subscription Cancellation Refund → Finance Manager approval if prorated amount >$1K
9. Custom Payment Plan → Finance Manager approval
10. QuickBooks Sync Error → Accountant review and manual reconciliation

#### Database Schema

**Subscription Tables:**
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  proposal_id UUID REFERENCES proposals(id),
  plan_id UUID REFERENCES subscription_plans(id),
  status VARCHAR(50) NOT NULL, -- 'trial', 'active', 'past_due', 'canceled', 'suspended'
  billing_cycle VARCHAR(20) NOT NULL, -- 'monthly', 'annual'
  current_period_start DATE NOT NULL,
  current_period_end DATE NOT NULL,
  trial_start DATE,
  trial_end DATE,
  canceled_at TIMESTAMPTZ,
  cancel_at TIMESTAMPTZ,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  payment_method_id UUID REFERENCES payment_methods(id),
  stripe_subscription_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_client_id (client_id),
  INDEX idx_status (status)
);

CREATE TABLE subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  tier VARCHAR(50) NOT NULL, -- 'starter', 'professional', 'enterprise'
  monthly_price DECIMAL(10,2) NOT NULL,
  annual_price DECIMAL(10,2),
  included_conversations INT,
  included_voice_minutes INT,
  included_api_calls INT,
  overage_rate_conversations DECIMAL(5,2),
  overage_rate_voice_minutes DECIMAL(5,2),
  overage_rate_api_calls DECIMAL(5,4),
  features JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE subscription_changes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  change_type VARCHAR(50) NOT NULL, -- 'created', 'upgraded', 'downgraded', 'canceled', 'suspended', 'reactivated'
  old_plan_id UUID REFERENCES subscription_plans(id),
  new_plan_id UUID REFERENCES subscription_plans(id),
  proration_amount DECIMAL(10,2),
  reason TEXT,
  changed_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Invoice Tables:**
```sql
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  client_id UUID NOT NULL,
  subscription_id UUID REFERENCES subscriptions(id),
  invoice_number VARCHAR(100) UNIQUE NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'draft', 'sent', 'paid', 'overdue', 'void'
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  amount_paid DECIMAL(10,2) DEFAULT 0,
  amount_due DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  billing_period_start DATE NOT NULL,
  billing_period_end DATE NOT NULL,
  due_date DATE NOT NULL,
  paid_at TIMESTAMPTZ,
  invoice_url TEXT,
  pdf_url TEXT,
  stripe_invoice_id VARCHAR(255),
  sent_to VARCHAR(255),
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_client_id (client_id),
  INDEX idx_subscription_id (subscription_id),
  INDEX idx_status (status),
  INDEX idx_due_date (due_date)
);

CREATE TABLE invoice_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  quantity DECIMAL(10,2) DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  item_type VARCHAR(50), -- 'subscription', 'usage_overage', 'one_time', 'proration'
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'card', 'bank_account', 'paypal'
  stripe_payment_method_id VARCHAR(255) NOT NULL,
  card_brand VARCHAR(50),
  card_last4 VARCHAR(4),
  card_exp_month INT,
  card_exp_year INT,
  billing_address JSONB,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id)
);

CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  invoice_id UUID REFERENCES invoices(id),
  payment_method_id UUID REFERENCES payment_methods(id),
  status VARCHAR(50) NOT NULL, -- 'pending', 'succeeded', 'failed', 'refunded'
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  stripe_payment_intent_id VARCHAR(255),
  failure_reason TEXT,
  receipt_url TEXT,
  processed_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  refund_amount DECIMAL(10,2),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_invoice_id (invoice_id),
  INDEX idx_status (status)
);
```

**Billing History & Dunning Tables:**
```sql
CREATE TABLE billing_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  subscription_id UUID REFERENCES subscriptions(id),
  invoice_id UUID REFERENCES invoices(id),
  event_type VARCHAR(100) NOT NULL, -- 'invoice_created', 'payment_succeeded', 'payment_failed', 'subscription_canceled', etc.
  event_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_subscription_id (subscription_id),
  INDEX idx_event_type (event_type)
);

CREATE TABLE dunning_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  invoice_id UUID NOT NULL REFERENCES invoices(id),
  dunning_stage VARCHAR(50) NOT NULL, -- 'reminder', 'warning', 'suspension_notice'
  days_overdue INT NOT NULL,
  reminder_sent BOOLEAN DEFAULT false,
  sent_to VARCHAR(255),
  sent_at TIMESTAMPTZ,
  response_received BOOLEAN DEFAULT false,
  response_type VARCHAR(50), -- 'payment_updated', 'payment_promised', 'dispute', 'no_response'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_invoice_id (invoice_id),
  INDEX idx_dunning_stage (dunning_stage)
);

CREATE TABLE revenue_recognition (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  subscription_id UUID REFERENCES subscriptions(id),
  invoice_id UUID REFERENCES invoices(id),
  recognition_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  recognition_type VARCHAR(50), -- 'monthly_subscription', 'usage', 'one_time'
  deferred_revenue_balance DECIMAL(10,2),
  quickbooks_journal_entry_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_recognition_date (recognition_date)
);
```

**Row-Level Security (RLS) Policies:**
```sql
-- All tables must filter by organization_id for multi-tenant isolation
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY subscriptions_isolation ON subscriptions
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY invoices_isolation ON invoices
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
CREATE POLICY payment_methods_isolation ON payment_methods
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY transactions_isolation ON payment_transactions
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE billing_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY billing_history_isolation ON billing_history
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE dunning_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY dunning_isolation ON dunning_logs
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE revenue_recognition ENABLE ROW LEVEL SECURITY;
CREATE POLICY revenue_isolation ON revenue_recognition
  USING (organization_id = current_setting('app.current_organization_id')::UUID);
```

#### Kafka Events

**Topic**: `billing_events`

**Event Schema:**
```json
{
  "event_type": "subscription_created | subscription_updated | subscription_canceled | invoice_generated | payment_succeeded | payment_failed | dunning_reminder_sent | account_suspended | account_restored",
  "organization_id": "uuid",
  "client_id": "uuid",
  "subscription_id": "uuid",
  "invoice_id": "uuid",
  "metadata": {
    // Event-specific metadata
  },
  "timestamp": "2025-10-08T..."
}
```

**Published Events:**

1. **Subscription Created**
```json
{
  "event_type": "subscription_created",
  "organization_id": "uuid",
  "client_id": "uuid",
  "subscription_id": "uuid",
  "metadata": {
    "plan_id": "uuid",
    "plan_name": "Professional Plan",
    "billing_cycle": "monthly",
    "amount": 3499.00,
    "trial_end": "2025-10-29",
    "created_from_proposal": true
  },
  "timestamp": "2025-10-15T10:00:00Z"
}
```
**Consumers**: Customer Success (track new customer onboarding), Analytics (track subscription metrics)

2. **Payment Succeeded**
```json
{
  "event_type": "payment_succeeded",
  "organization_id": "uuid",
  "client_id": "uuid",
  "subscription_id": "uuid",
  "invoice_id": "uuid",
  "metadata": {
    "amount": 3891.89,
    "currency": "USD",
    "payment_method": "Visa •••• 4242",
    "receipt_url": "https://storage.workflow.com/receipts/receipt_uuid.pdf"
  },
  "timestamp": "2025-11-16T14:23:00Z"
}
```
**Consumers**: Communication Service (send receipt email), Analytics (track payment success rate)

3. **Payment Failed**
```json
{
  "event_type": "payment_failed",
  "organization_id": "uuid",
  "client_id": "uuid",
  "subscription_id": "uuid",
  "invoice_id": "uuid",
  "metadata": {
    "amount": 3891.89,
    "failure_reason": "insufficient_funds",
    "retry_attempt": 1,
    "next_retry_date": "2025-12-16T00:05:00Z"
  },
  "timestamp": "2025-12-15T00:05:00Z"
}
```
**Consumers**: Communication Service (send payment failure notification), Dunning Agent (track for escalation)

4. **Account Suspended**
```json
{
  "event_type": "account_suspended",
  "organization_id": "uuid",
  "client_id": "uuid",
  "subscription_id": "uuid",
  "metadata": {
    "suspension_reason": "payment_overdue",
    "days_overdue": 32,
    "amount_overdue": 3891.89,
    "suspended_at": "2025-12-30T00:00:00Z"
  },
  "timestamp": "2025-12-30T00:00:00Z"
}
```
**Consumers**: Agent Orchestration (Service 8), Voice Agent (Service 9) - disable runtime access; Customer Success (escalate to CSM)

5. **Dunning Reminder Sent**
```json
{
  "event_type": "dunning_reminder_sent",
  "organization_id": "uuid",
  "client_id": "uuid",
  "invoice_id": "uuid",
  "metadata": {
    "dunning_stage": "warning",
    "days_overdue": 14,
    "amount_due": 3891.89,
    "sent_to": "billing@acme.com"
  },
  "timestamp": "2025-12-25T10:00:00Z"
}
```
**Consumers**: Customer Success (high-value account alerts), Analytics (dunning effectiveness tracking)

**Consumed Events:**
- `proposal_signed` (from Service 3 Sales Document Generator) → Creates subscription and schedules first invoice
- `usage_reported` (from Service 12 Analytics) → Aggregates usage data for usage-based billing calculations

#### Stakeholders

**Internal Stakeholders:**
1. **Finance Team** - Revenue oversight, financial reporting, compliance
2. **Billing Administrators** - Day-to-day billing operations, customer billing support
3. **Accountants** - Revenue recognition, accounting system sync, tax compliance
4. **Customer Success Managers** - Notified of at-risk accounts (payment issues), coordinates payment recovery
5. **Product Management** - Pricing plan design, subscription metrics analysis

**External Stakeholders:**
1. **Clients (Billing Contacts)** - Receive invoices, manage payment methods, view billing history
2. **Stripe** - Primary payment processor
3. **QuickBooks** - Accounting system of record
4. **Avalara** - Tax calculation and compliance (Nice-to-Have)

**External Integrations:**
- **Stripe API** - Credit card processing, subscription management, webhook events
- **QuickBooks Online API** - Accounting sync, journal entries, revenue recognition
- **Avalara API** - Tax calculation for invoices (Nice-to-Have)
- **SendGrid** - Email delivery (via Service 20) for invoices, receipts, dunning messages

---

### 4. Pricing Model Generator Service → CONSOLIDATED INTO SERVICE 3

**This service has been consolidated into Service 3 (Sales Document Generator).**

**Rationale**: Services 3, 4, and 5 formed a distributed monolith with a tightly-coupled sequential workflow (NDA → Pricing → Proposal). This consolidation eliminates:
- 3-hop distributed transaction overhead
- 150-300ms latency reduction across the sales pipeline
- Duplicate e-signature integration complexity
- Template management fragmentation
- Complex saga pattern coordination

**Migration Impact**:
- All pricing endpoints now available under Service 3 at `/api/v1/pricing-models/*`
- Kafka topic changed from `pricing_events` to `sales_doc_events` (unified topic)
- Database tables consolidated into Service 3's sales document schema
- See Service 3 above for complete pricing functionality specification

**Former Objectives** (now part of Service 3):
- **Primary Purpose**: Automated generation of customized pricing proposals based on client use cases, tier selection, and financial cost modeling
- **Business Value**: Reduces pricing analysis from 8+ hours to <30 minutes, ensures margin consistency, enables dynamic pricing experiments
- **Scope Boundaries**:
  - **Does**: Calculate pricing tiers, incorporate Ashay's financial cost module, generate proposal PDFs, support A/B pricing tests
  - **Does Not**: Handle payment processing, manage subscriptions, provide financial advice

**All pricing functionality (APIs, database schemas, features, agents) is now documented in Service 3 above.**

---

### 5. Proposal & Agreement Draft Generator Service → CONSOLIDATED INTO SERVICE 3

**This service has been consolidated into Service 3 (Sales Document Generator).**

**Rationale**: Services 3, 4, and 5 formed a distributed monolith with a tightly-coupled sequential workflow (NDA → Pricing → Proposal). This consolidation eliminates:
- 3-hop distributed transaction overhead
- 150-300ms latency reduction across the sales pipeline
- Duplicate e-signature integration complexity
- Template management fragmentation
- Complex saga pattern coordination

**Migration Impact**:
- All proposal endpoints now available under Service 3 at `/api/v1/proposals/*`
- Kafka topic changed from `proposal_events` to `sales_doc_events` (unified topic)
- Database tables consolidated into Service 3's sales document schema
- See Service 3 above for complete proposal functionality specification

**Former Objectives** (now part of Service 3):
- **Primary Purpose**: AI-powered generation of comprehensive proposals and legal agreements with interactive editing capabilities
- **Business Value**: Reduces proposal creation from 10+ hours to <1 hour, ensures consistency, enables real-time collaboration
- **Scope Boundaries**:
  - **Does**: Generate proposals/agreements from templates, provide webchat UI for feedback-driven iteration, enable manual canvas editing, version control, e-signature integration
  - **Does Not**: Provide legal advice, handle complex contract negotiations beyond standard terms, replace legal review

**All proposal functionality (APIs, database schemas, features, agents) is now documented in Service 3 above.**

---

*Due to length constraints, the remaining microservices continue below. Services 3, 4, and 5 have been consolidated into Service 3 (Sales Document Generator).*

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
