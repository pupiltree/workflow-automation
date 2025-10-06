# Microservices Architecture Specification
## Complete Workflow Automation System

---

## Executive Summary

This document defines the comprehensive microservices architecture for an AI-powered workflow automation platform that automates client onboarding, demo generation, PRD creation, implementation, monitoring, and customer success. The architecture decomposes a complex workflow into **18 specialized microservices** (Services 0, 0.5, 1-16), leveraging event-driven patterns, multi-tenant isolation, and AI agent orchestration to achieve 95% automation within 12 months.

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
│   Topics: auth_events, org_events, agent_events,                │
│   collaboration_events, client_events, prd_events,              │
│   demo_events, config_events, conversation_events,              │
│   voice_events, analytics_events                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┴──────────────────────┐
         │                                           │
         ▼                                           ▼
┌─────────────────┐                        ┌──────────────────┐
│  Core Services  │                        │  Support Services│
├─────────────────┤                        ├──────────────────┤
│ 0. Org Mgmt &   │                        │ 11. Monitoring   │
│    Auth         │                        │ 12. Analytics    │
│ 0.5 Human Agent │                        │ 13. Customer     │
│     Management  │◄───────────────────────┤     Success      │
│ 1. Research     │  (Handoffs & Routing)  │ 14. Support      │
│ 2. Demo Gen     │                        │ 15. CRM          │
│ 3. NDA Gen      │                        │     Integration  │
│ 4. Pricing      │                        └──────────────────┘
│ 5. Proposal     │
│ 6. PRD Builder  │
│ 7. Automation   │
│ 8. Agent Orch   │
│ 9. Voice Agent  │
│ 10. Config Mgmt │
└─────────────────┘

Data Layer:
- PostgreSQL (Supabase) with RLS: Transactional data, multi-tenant isolation
- Qdrant: Vector storage for RAG, namespace-per-tenant
- Neo4j: Knowledge graphs for GraphRAG
- Redis: Caching, session state, rate limiting, auth tokens
- TimescaleDB: Time-series metrics and analytics
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

### 0. Organization Management & Authentication Service

#### Objectives
- **Primary Purpose**: Self-service client signup, organization creation, team member management, and authentication/authorization for the entire platform
- **Business Value**: Enables product-led growth with self-service onboarding BEFORE sales engagement, reduces sales friction, enables team collaboration from day one
- **Scope Boundaries**:
  - **Does**: User signup/login, organization creation, team invitations, role-based permissions, work email verification, session management, OAuth integrations
  - **Does Not**: Handle billing (separate service), generate content, manage workflows

#### Requirements

**Functional Requirements:**
1. Work email signup with email verification
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

**Non-Functional Requirements:**
- Signup completion: <30 seconds
- Support 100K+ organizations
- Auth latency: <100ms P95
- 99.99% uptime (authentication is critical path)
- GDPR/SOC 2 compliance for user data

**Dependencies:**
- Research Engine (triggered after org creation)
- PRD Builder (uses org/user context for permissions)
- Configuration Management (org-level feature flags)
- External: SendGrid (email verification), Auth0/Supabase Auth (optional managed auth)

**Data Storage:**
- PostgreSQL: Users, organizations, memberships, roles, permissions, audit logs
- Redis: Session tokens, email verification codes, rate limiting

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
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, organization_id)
);

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
```

#### Features

**Must-Have:**
1. ✅ Work email signup with domain validation
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

**Nice-to-Have:**
11. 🔄 SAML SSO for enterprise customers
12. 🔄 Directory sync (Okta, Azure AD)
13. 🔄 IP allowlisting
14. 🔄 Advanced MFA (biometric, hardware keys)

**Feature Interactions:**
- Organization created (self-service) → Triggers initial research job creation
- Organization created (assisted) → Creates account with claim token, sends claim email, triggers research job
- Team member joins → Sends welcome email with PRD Builder access
- Admin updates permissions → Real-time permission sync across services
- Assisted account claimed → Transfers ownership, converts to full account, sends confirmation email
- Assisted account nearing expiry (7 days) → Automated reminder email sent to client
- Assisted account expired unclaimed → Account locked, platform admin notified for follow-up

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

### 0.5. Human Agent Management Service

#### Objectives
- **Primary Purpose**: Unified management of all human agents across the platform with role-based access, multi-role assignments, handoff workflows, and specialist routing
- **Business Value**: Enables structured client lifecycle management with seamless handoffs (Sales → Onboarding → Support → Success), maintains human-in-the-loop supervision while maximizing automation, supports 1000+ human agents with specialized roles
- **Scope Boundaries**:
  - **Does**: Manage agent profiles and roles, orchestrate client handoffs, track agent activities, route specialists, manage agent availability, supervise AI workflows
  - **Does Not**: Execute business logic (services do), train agents, manage HR/payroll

#### Requirements

**Functional Requirements:**
1. Agent registration and profile management with multi-role assignments
2. Role-based access control with granular permissions per service
3. Client handoff workflow orchestration (Sales → Onboarding → Support → Success → Upsell)
4. Specialist matching and routing based on skills, availability, and workload
5. Real-time agent availability and status management
6. Activity tracking and performance metrics per role
7. Queue management for each role type
8. Agent invitation and cross-selling workflow
9. Supervision mode for AI agent oversight
10. Handoff approval workflow with notes and context transfer
11. Agent workload balancing and auto-assignment

**Non-Functional Requirements:**
- Agent lookup: <50ms P95
- Handoff processing: <2 seconds
- Support 1000+ concurrent agents
- 99.99% uptime (critical for handoffs)
- Real-time availability updates <500ms

**Dependencies:**
- Organization Management (agent authentication)
- All microservices (consume agent assignments and handoffs)
- Analytics Service (agent performance metrics)
- Monitoring Engine (agent activity tracking)

**Data Storage:**
- PostgreSQL: Agent profiles, roles, permissions, handoff history, activity logs
- Redis: Real-time agent availability, queue state, active assignments
- TimescaleDB: Agent performance metrics, SLA tracking

**Database Schema:**

```sql
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
  agent_id UUID NOT NULL REFERENCES agent_profiles(agent_id),
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
  from_agent_id UUID NOT NULL REFERENCES agent_profiles(agent_id),
  from_role TEXT NOT NULL,
  to_agent_id UUID REFERENCES agent_profiles(agent_id),  -- NULL until accepted
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
  invited_by_agent_id UUID NOT NULL REFERENCES agent_profiles(agent_id),
  specialist_agent_id UUID REFERENCES agent_profiles(agent_id),  -- NULL until accepted
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
  agent_id UUID NOT NULL REFERENCES agent_profiles(agent_id),
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
1. ✅ Agent registration with multi-role assignment
2. ✅ Granular role-based permissions (per service + per action)
3. ✅ Client handoff workflow (Sales → Onboarding → Support → Success)
4. ✅ Specialist routing engine (skill-based matching)
5. ✅ Real-time availability management (online, busy, offline)
6. ✅ Agent queue management (per role, per client)
7. ✅ Activity tracking (time per client, actions performed)
8. ✅ Cross-sell/upsell agent invitation
9. ✅ Handoff approval with context notes
10. ✅ Workload balancing (auto-assignment based on capacity)
11. ✅ Supervision dashboard (AI oversight by human agents)
12. ✅ Agent performance metrics (response time, CSAT, handoff quality)

**Nice-to-Have:**
13. 🔄 AI-powered agent suggestions (best agent for client)
14. 🔄 Agent skill gap analysis
15. 🔄 Automated agent training recommendations
16. 🔄 Predictive workload forecasting

**Feature Interactions:**
- Client signup (assisted) → Auto-assign to Sales agent based on workload
- Sales completes → Handoff to Onboarding agent → Context transferred
- Onboarding completes → Handoff to dedicated Support + Success agents
- Success agent identifies upsell → Invites Sales specialist to join
- AI agent exceeds error threshold → Escalates to Supervision agent
- Agent goes offline → Queue automatically redistributed

#### API Specification

**1. Register Human Agent**
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
    },
    {
      "role_type": "onboarding_specialist",
      "primary": false,
      "skills": ["technical_onboarding", "integration_setup"],
      "certifications": [],
      "languages": ["english"]
    }
  ],
  "permissions": {
    "assisted_signup": ["create", "read", "update"],
    "research_engine": ["read", "trigger"],
    "demo_generator": ["read", "create", "approve"],
    "prd_builder": ["read", "collaborate"],
    "client_management": ["read", "update", "transfer"]
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
  "full_name": "Sam Peterson",
  "status": "active",
  "roles": [
    {
      "role_id": "uuid",
      "role_type": "sales_agent",
      "primary": true,
      "assigned_at": "2025-10-05T10:00:00Z"
    },
    {
      "role_id": "uuid",
      "role_type": "onboarding_specialist",
      "primary": false,
      "assigned_at": "2025-10-05T10:00:00Z"
    }
  ],
  "current_workload": {
    "active_clients": 0,
    "pending_handoffs": 0,
    "utilization_percent": 0
  },
  "created_at": "2025-10-05T10:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "agent_registered",
  "agent_id": "uuid",
  "roles": ["sales_agent", "onboarding_specialist"],
  "timestamp": "2025-10-05T10:00:00Z"
}
```

**2. Assign Client to Agent (Auto or Manual)**
```http
POST /api/v1/agents/assignments
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "organization_id": "uuid",
  "role_type": "sales_agent",
  "assignment_type": "auto",
  "assignment_reason": "new_assisted_signup",
  "priority": "normal",
  "context": {
    "company_name": "Teddy Corp",
    "industry": "e-commerce",
    "lead_source": "conference",
    "notes": "Interested in customer support automation"
  }
}

Response (201 Created):
{
  "assignment_id": "uuid",
  "client_id": "uuid",
  "assigned_agent": {
    "agent_id": "uuid",
    "full_name": "Sam Peterson",
    "role_type": "sales_agent",
    "contact_email": "sam@workflow.com"
  },
  "assignment_type": "auto",
  "assigned_at": "2025-10-05T10:15:00Z",
  "status": "active",
  "sla": {
    "first_contact_deadline": "2025-10-05T12:15:00Z",
    "expected_completion": "2025-10-12T10:15:00Z"
  }
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

**3. Initiate Client Handoff**
```http
POST /api/v1/agents/handoffs
Authorization: Bearer {agent_jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "organization_id": "uuid",
  "from_role": "sales_agent",
  "to_role": "onboarding_specialist",
  "handoff_reason": "sales_completed",
  "handoff_type": "warm",
  "context": {
    "current_stage": "nda_signed",
    "next_actions": ["setup_integrations", "configure_workflows"],
    "client_preferences": {
      "preferred_contact": "email",
      "timezone": "EST",
      "technical_level": "intermediate"
    },
    "completed_items": [
      {"item": "research", "completed_at": "2025-10-05T11:00:00Z"},
      {"item": "demo_approved", "completed_at": "2025-10-08T14:30:00Z"},
      {"item": "nda_signed", "completed_at": "2025-10-09T16:00:00Z"},
      {"item": "pricing_agreed", "completed_at": "2025-10-10T10:00:00Z"}
    ],
    "important_notes": "Client has custom API integration requirements. Technical contact is Jane (CTO)."
  },
  "target_agent_id": null,
  "urgency": "normal"
}

Response (201 Created):
{
  "handoff_id": "uuid",
  "client_id": "uuid",
  "from_agent": {
    "agent_id": "uuid",
    "full_name": "Sam Peterson",
    "role_type": "sales_agent"
  },
  "to_agent": {
    "agent_id": "uuid",
    "full_name": "Rahul Kumar",
    "role_type": "onboarding_specialist",
    "status": "pending_acceptance"
  },
  "handoff_type": "warm",
  "status": "pending",
  "context_summary": {
    "stage": "nda_signed",
    "next_actions_count": 2,
    "notes_count": 1
  },
  "sla": {
    "acceptance_deadline": "2025-10-10T18:00:00Z",
    "first_contact_deadline": "2025-10-11T10:00:00Z"
  },
  "created_at": "2025-10-10T14:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "handoff_initiated",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "from_agent_id": "uuid",
  "to_agent_id": "uuid",
  "from_role": "sales_agent",
  "to_role": "onboarding_specialist",
  "timestamp": "2025-10-10T14:00:00Z"
}
```

**4. Accept/Reject Handoff**
```http
POST /api/v1/agents/handoffs/{handoff_id}/accept
Authorization: Bearer {agent_jwt_token}
Content-Type: application/json

Request Body (Accept):
{
  "action": "accept",
  "agent_id": "uuid",
  "acceptance_notes": "Reviewed context. Ready to start onboarding. Will reach out to client within 24 hours.",
  "estimated_completion": "2025-10-24T14:00:00Z"
}

Response (200 OK):
{
  "handoff_id": "uuid",
  "status": "accepted",
  "accepted_by": {
    "agent_id": "uuid",
    "full_name": "Rahul Kumar",
    "role_type": "onboarding_specialist"
  },
  "accepted_at": "2025-10-10T15:00:00Z",
  "client_notification_sent": true,
  "previous_agent_notified": true
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "handoff_accepted",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "accepted_by_agent_id": "uuid",
  "timestamp": "2025-10-10T15:00:00Z"
}

Request Body (Reject):
{
  "action": "reject",
  "agent_id": "uuid",
  "rejection_reason": "At capacity - cannot take new clients this week",
  "suggested_agent_id": "uuid"
}

Response (200 OK):
{
  "handoff_id": "uuid",
  "status": "rejected",
  "rejected_by": {
    "agent_id": "uuid",
    "full_name": "Rahul Kumar",
    "role_type": "onboarding_specialist"
  },
  "rejection_reason": "At capacity - cannot take new clients this week",
  "reassignment_queued": true,
  "next_available_agent": {
    "agent_id": "uuid",
    "full_name": "Maria Garcia",
    "role_type": "onboarding_specialist",
    "estimated_availability": "2025-10-11T09:00:00Z"
  },
  "rejected_at": "2025-10-10T15:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "handoff_rejected",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "rejected_by_agent_id": "uuid",
  "reason": "at_capacity",
  "reassignment_queued": true,
  "timestamp": "2025-10-10T15:00:00Z"
}
```

**5. Invite Specialist to Client (Cross-sell/Upsell/Iteration)**
```http
POST /api/v1/agents/invitations
Authorization: Bearer {agent_jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "invited_by_agent_id": "uuid",
  "invited_role": "sales_specialist_voice",
  "invitation_reason": "upsell_opportunity",
  "context": {
    "opportunity_type": "voice_agent_addon",
    "estimated_value": 15000,
    "urgency": "medium",
    "background": "Client expressed interest in adding voice support to existing chatbot. Current utilization at 85%, strong ROI potential."
  },
  "target_agent_id": null,
  "collaboration_mode": "join_existing"
}

Response (201 Created):
{
  "invitation_id": "uuid",
  "client_id": "uuid",
  "invited_by": {
    "agent_id": "uuid",
    "full_name": "Sarah Chen",
    "role_type": "success_manager"
  },
  "invited_role": "sales_specialist_voice",
  "invited_agent": {
    "agent_id": "uuid",
    "full_name": "Mike Rodriguez",
    "role_type": "sales_specialist_voice",
    "status": "pending_acceptance"
  },
  "collaboration_mode": "join_existing",
  "estimated_value": 15000,
  "status": "pending",
  "created_at": "2025-11-01T10:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "specialist_invited",
  "invitation_id": "uuid",
  "client_id": "uuid",
  "invited_by_agent_id": "uuid",
  "invited_agent_id": "uuid",
  "reason": "upsell_opportunity",
  "timestamp": "2025-11-01T10:00:00Z"
}
```

**6. Get Agent Workload and Queue**
```http
GET /api/v1/agents/{agent_id}/workload
Authorization: Bearer {agent_jwt_token}

Response (200 OK):
{
  "agent_id": "uuid",
  "full_name": "Sam Peterson",
  "primary_role": "sales_agent",
  "all_roles": ["sales_agent", "onboarding_specialist"],
  "current_status": "online",
  "workload": {
    "active_clients": 8,
    "pending_handoffs": 2,
    "pending_invitations": 1,
    "max_capacity": 15,
    "utilization_percent": 53,
    "available_capacity": 7
  },
  "active_assignments": [
    {
      "assignment_id": "uuid",
      "client_name": "Teddy Corp",
      "organization_id": "uuid",
      "role": "sales_agent",
      "stage": "demo_scheduled",
      "assigned_since": "2025-10-05T10:15:00Z",
      "sla_status": "on_track",
      "next_action": "conduct_demo",
      "next_action_deadline": "2025-10-06T14:00:00Z"
    }
  ],
  "pending_items": {
    "handoffs_to_accept": 2,
    "invitations_to_respond": 1,
    "overdue_actions": 0
  },
  "performance": {
    "avg_response_time_hours": 2.5,
    "client_satisfaction_avg": 4.7,
    "handoff_quality_score": 92,
    "sla_compliance_percent": 98
  }
}
```

**7. Update Agent Availability**
```http
PATCH /api/v1/agents/{agent_id}/availability
Authorization: Bearer {agent_jwt_token}
Content-Type: application/json

Request Body:
{
  "status": "busy",
  "status_message": "In client meeting until 3 PM",
  "available_at": "2025-10-05T15:00:00Z",
  "auto_assign": false
}

Response (200 OK):
{
  "agent_id": "uuid",
  "status": "busy",
  "status_message": "In client meeting until 3 PM",
  "available_at": "2025-10-05T15:00:00Z",
  "auto_assign_enabled": false,
  "updated_at": "2025-10-05T13:00:00Z"
}

Event Published to Kafka:
Topic: agent_events
{
  "event_type": "agent_status_updated",
  "agent_id": "uuid",
  "status": "busy",
  "timestamp": "2025-10-05T13:00:00Z"
}
```

**8. Get Available Agents for Role**
```http
GET /api/v1/agents/available
Authorization: Bearer {jwt_token}
Query Parameters:
- role_type: sales_agent
- skills: b2b_saas,enterprise_sales
- min_capacity: 3
- sort_by: workload_asc

Response (200 OK):
{
  "role_type": "sales_agent",
  "available_agents": [
    {
      "agent_id": "uuid",
      "full_name": "Sam Peterson",
      "status": "online",
      "current_workload": 8,
      "available_capacity": 7,
      "skills_match": ["b2b_saas", "enterprise_sales"],
      "avg_response_time_hours": 2.5,
      "client_satisfaction": 4.7,
      "languages": ["english", "spanish"]
    },
    {
      "agent_id": "uuid",
      "full_name": "Alice Johnson",
      "status": "online",
      "current_workload": 5,
      "available_capacity": 10,
      "skills_match": ["b2b_saas"],
      "avg_response_time_hours": 3.2,
      "client_satisfaction": 4.5,
      "languages": ["english"]
    }
  ],
  "total_available": 12,
  "total_capacity": 145
}
```

**9. Get Agent Permissions (For Kong API Gateway Authorization)**
```http
GET /api/v1/agents/{agent_id}/permissions
Authorization: Bearer {internal_service_jwt}
X-Internal-Service: kong

Response (200 OK):
{
  "agent_id": "uuid",
  "user_id": "uuid",
  "primary_role": "sales_agent",
  "all_roles": ["sales_agent", "onboarding_specialist"],
  "permissions": {
    "assisted_signup": ["create", "read", "update"],
    "research_engine": ["read", "trigger"],
    "demo_generator": ["read", "create", "approve"],
    "prd_builder": ["read", "collaborate"],
    "client_management": ["read", "update", "transfer"]
  },
  "capacity": {
    "max_concurrent_clients": 15,
    "current_workload": 8,
    "available_capacity": 7
  },
  "status": "active",
  "availability": "online"
}

Response (404 Not Found):
{
  "error": "agent_not_found",
  "message": "Agent with ID {agent_id} does not exist"
}

Response (403 Forbidden):
{
  "error": "unauthorized",
  "message": "Only Kong API Gateway can access this endpoint"
}
```

**Note**: This endpoint is designed specifically for Kong API Gateway to check permissions during request authorization. It is NOT exposed to external clients and requires `X-Internal-Service: kong` header for authentication.

**10. Get Client Lifecycle Timeline**
```http
GET /api/v1/agents/clients/{client_id}/timeline
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "client_id": "uuid",
  "organization_name": "Teddy Corp",
  "current_stage": "onboarding",
  "current_agent": {
    "agent_id": "uuid",
    "full_name": "Rahul Kumar",
    "role_type": "onboarding_specialist",
    "assigned_since": "2025-10-10T15:00:00Z"
  },
  "lifecycle_timeline": [
    {
      "stage": "sales",
      "agent": {
        "agent_id": "uuid",
        "full_name": "Sam Peterson",
        "role_type": "sales_agent"
      },
      "start_date": "2025-10-05T10:15:00Z",
      "end_date": "2025-10-10T14:00:00Z",
      "duration_days": 5,
      "completed_items": ["research", "demo", "nda_signed", "pricing_agreed"],
      "handoff_quality_score": 95,
      "client_satisfaction": 5
    },
    {
      "stage": "onboarding",
      "agent": {
        "agent_id": "uuid",
        "full_name": "Rahul Kumar",
        "role_type": "onboarding_specialist"
      },
      "start_date": "2025-10-10T15:00:00Z",
      "end_date": null,
      "duration_days": 12,
      "status": "in_progress",
      "progress_percent": 60,
      "next_milestone": "prd_approval",
      "next_milestone_deadline": "2025-10-20T17:00:00Z"
    }
  ],
  "future_stages": [
    {
      "stage": "support",
      "role_type": "support_specialist",
      "expected_start": "2025-10-24T00:00:00Z",
      "assigned_agent": null
    },
    {
      "stage": "success",
      "role_type": "success_manager",
      "expected_start": "2025-10-24T00:00:00Z",
      "assigned_agent": null
    }
  ]
}
```

**10. Supervise AI Agent Activity**
```http
GET /api/v1/agents/supervision/ai-activity
Authorization: Bearer {supervisor_jwt_token}
Query Parameters:
- time_range: last_24h
- alert_level: warning,critical
- service: agent_orchestration,voice_agent

Response (200 OK):
{
  "supervision_dashboard": {
    "total_ai_conversations": 2547,
    "requiring_attention": 23,
    "escalated_to_human": 12,
    "quality_issues": 11
  },
  "alerts": [
    {
      "alert_id": "uuid",
      "severity": "critical",
      "ai_agent_type": "voice_agent",
      "client_id": "uuid",
      "organization_name": "Beta Corp",
      "issue": "High error rate (15%) in last 10 calls",
      "detected_at": "2025-10-05T14:30:00Z",
      "recommended_action": "Review call logs and update system prompt",
      "supervisor_assigned": null
    },
    {
      "alert_id": "uuid",
      "severity": "warning",
      "ai_agent_type": "chatbot",
      "client_id": "uuid",
      "organization_name": "Gamma Inc",
      "issue": "Low CSAT score (3.2) for last 50 conversations",
      "detected_at": "2025-10-05T13:00:00Z",
      "recommended_action": "Analyze conversation patterns and refine responses",
      "supervisor_assigned": {
        "agent_id": "uuid",
        "full_name": "Maria Garcia",
        "role_type": "ai_supervisor"
      }
    }
  ],
  "top_issues": [
    {"issue": "Low confidence responses", "occurrences": 45},
    {"issue": "Tool execution failures", "occurrences": 23},
    {"issue": "Sentiment drop during conversation", "occurrences": 18}
  ]
}
```

**Rate Limiting:**
- 1000 API requests per minute per tenant
- 50 handoffs per hour per agent
- 20 specialist invitations per day per agent
- 5 active specialist invitations per client (across all agents, prevents spam)
- 100 availability updates per hour per agent

#### Frontend Components

**1. Agent Dashboard**
- Component: `AgentDashboard.tsx`
- Features:
  - My active clients list (all roles)
  - Pending handoffs to accept
  - Pending specialist invitations
  - Today's tasks and deadlines
  - Quick actions (create handoff, update status)
  - Performance metrics widget

**2. Client Lifecycle View**
- Component: `ClientLifecycleView.tsx`
- Features:
  - Visual timeline of client journey
  - Stage indicators (Sales → Onboarding → Support → Success)
  - Agent handoff history
  - Context notes from previous agents
  - Upcoming milestones
  - Quick handoff button

**3. Handoff Workflow Manager**
- Component: `HandoffWorkflowManager.tsx`
- Features:
  - Initiate handoff form
  - Context builder (notes, next actions, client prefs)
  - Agent selector (auto or manual)
  - Handoff approval queue
  - Warm vs cold handoff toggle
  - Handoff quality feedback

**4. Specialist Invitation Panel**
- Component: `SpecialistInvitationPanel.tsx`
- Features:
  - Invite specialist form (role, reason, context)
  - Specialist availability checker
  - Collaboration mode selector
  - Estimated value calculator
  - Invitation queue (sent/received)
  - Quick accept/reject

**5. Agent Workload Monitor**
- Component: `AgentWorkloadMonitor.tsx`
- Features:
  - Real-time capacity gauge
  - Active clients grid
  - Queue length by role
  - SLA compliance tracker
  - Performance metrics (response time, CSAT)
  - Workload balancing recommendations

**6. AI Supervision Dashboard**
- Component: `AISupervisionDashboard.tsx`
- Features:
  - AI activity overview (conversations, escalations)
  - Alert feed (critical, warning, info)
  - Quality issue tracker
  - Conversation drill-down
  - Quick intervention tools (update prompt, pause config)
  - AI performance trends

**7. Multi-Role Agent Profile**
- Component: `MultiRoleAgentProfile.tsx`
- Features:
  - Role badges with primary indicator
  - Skills and certifications per role
  - Performance metrics by role
  - Capacity settings per role
  - Availability scheduler
  - Role request form (add new roles)

**8. Team View (Manager)**
- Component: `TeamViewDashboard.tsx`
- Features:
  - Team capacity heatmap
  - Agent status grid (online, busy, offline)
  - Workload distribution chart
  - Pending handoffs across team
  - Performance leaderboard
  - Agent assignment controls

**State Management:**
- Redux Toolkit for agent state
- React Query for API data
- WebSocket for real-time updates (availability, handoffs)
- Local storage for dashboard preferences

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Agent**
   - Role: Manages assisted signups, conducts demos, negotiates pricing, initiates handoffs
   - Access: Assisted signup, research, demos, NDA, pricing, proposal
   - Permissions: create:assisted_accounts, read:research, create:demos, approve:pricing, initiate:handoff
   - Workflows: Create assisted account → Research → Demo → NDA → Pricing → Proposal → Handoff to Onboarding
   - Multi-role: Can also be Sales Specialist (voice, enterprise, vertical-specific)

2. **Onboarding Specialist**
   - Role: Guides client through PRD creation, config setup, integration setup, initial launch
   - Access: PRD builder, automation engine, configuration, all client data
   - Permissions: read:all_client_data, collaborate:prd, review:configs, handoff:to_support
   - Workflows: Accept handoff from Sales → PRD collaboration → Config review → Integration setup → Week 1 support → Handoff to Support + Success
   - Duration: Typically 1-2 weeks per client

3. **Support Specialist**
   - Role: Dedicated ongoing support for technical issues, bug fixes, config updates
   - Access: All services (read), agent orchestration (debug), monitoring, support tickets
   - Permissions: read:all_services, debug:conversations, update:configs, escalate:to_engineering
   - Workflows: Accept handoff from Onboarding → Monitor client health → Respond to tickets → Ongoing support → Escalate complex issues
   - Long-term: Assigned to client for lifetime or contract duration

4. **Success Manager**
   - Role: Drives adoption, monitors KPIs, conducts QBRs, identifies expansion opportunities
   - Access: Analytics, customer success, all client metrics, usage data
   - Permissions: read:analytics, conduct:qbrs, identify:opportunities, invite:specialists
   - Workflows: Accept handoff from Onboarding → Monitor KPIs → Conduct QBRs → Identify upsell/crosssell → Invite Sales Specialist → Drive renewals
   - Long-term: Assigned to client for lifetime

5. **Sales Specialist (Cross-sell/Upsell)**
   - Role: Invited by Success Manager for expansion opportunities (voice, new products, enterprise features)
   - Access: Client history, current usage, analytics, pricing, proposals
   - Permissions: read:client_data, create:expansion_proposals, negotiate:upsell
   - Workflows: Receive invitation from Success Manager → Review client context → Pitch expansion → Create proposal → Close deal → Hand back to Success Manager
   - Temporary: Joins for specific expansion opportunity, then exits

6. **AI Supervisor**
   - Role: Monitors AI agent quality, reviews escalations, tunes prompts, approves config changes
   - Access: All AI conversations, monitoring dashboards, config management, analytics
   - Permissions: read:all_ai_activity, review:escalations, update:prompts, approve:config_changes
   - Workflows: Monitor AI quality → Review alerts → Investigate issues → Tune prompts → Approve updates → Continuous optimization

7. **Platform Engineer (Human Agent System)**
   - Role: Manages agent roles, permissions, handoff workflows, system health
   - Access: Admin panel, all agents, system configurations
   - Permissions: admin:agents, manage:roles, configure:handoffs, monitor:system
   - Workflows: Register agents → Assign roles → Configure handoffs → Monitor performance → Troubleshoot issues

**AI Agents:**

1. **Agent Routing AI**
   - Responsibility: Auto-assigns clients to best available agent based on workload, skills, performance
   - Tools: Workload analyzer, skill matcher, performance scorer
   - Autonomy: Fully autonomous for standard assignments
   - Escalation: Platform Engineer review for custom routing rules

2. **Handoff Quality AI**
   - Responsibility: Analyzes handoff quality, suggests improvements, alerts on missing context
   - Tools: NLP for context analysis, quality scorers, feedback aggregators
   - Autonomy: Fully autonomous
   - Escalation: None (suggestions only)

3. **Workload Balancer AI**
   - Responsibility: Monitors agent capacity, redistributes work, prevents burnout
   - Tools: Capacity trackers, SLA monitors, reassignment engine
   - Autonomy: Suggests reassignments, requires agent approval
   - Escalation: Manager intervention for urgent reassignments

**Approval Workflows:**
1. Agent Registration → Platform Engineer approval required
2. Client Assignment → Auto-approved (AI routing) or manual (manager assigned)
3. Handoff Initiation → Auto-created, receiving agent acceptance required
4. Specialist Invitation → Auto-sent, specialist acceptance required
5. Role Addition → Platform Engineer approval for new role types
6. AI Supervision Actions → AI Supervisor approval for prompt updates, auto-applied for config rollbacks

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

**Data Storage:**
- PostgreSQL: Research metadata, job status, findings summaries
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
- Research completion → Auto-send outbound email (if email available) OR create manual outreach ticket
- Client feedback on research → Triggers demo generation with confirmed requirements
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

4. **Research Chat Agent (RAG-powered)**
   - Responsibility: Answers questions about research findings in natural language
   - Tools: LLM (GPT-4), Qdrant semantic search on research data, source citation generator
   - Autonomy: Fully autonomous for Q&A
   - Escalation: None (read-only access to research data)

5. **Outbound Email Generation Agent**
   - Responsibility: Generates personalized outbound emails from research findings and proposed demo scope
   - Tools: LLM (GPT-4), email templates, personalization engine, research data accessors
   - Autonomy: Fully autonomous for email generation and sending (if email available)
   - Escalation: Creates manual outreach ticket if no email found in research

6. **Client Feedback Analysis Agent**
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
- **Primary Purpose**: Automated generation of client-specific AI chatbot/voicebot demos with mock data and tools
- **Business Value**: Reduces demo creation time from 40+ hours to <2 hours, enables rapid iteration, increases win rates through personalized demos
- **Scope Boundaries**:
  - **Does**: Generate functional web UI demos, create mock datasets, integrate mock tools, deploy to sandboxed environments, enable developer testing
  - **Does Not**: Access production client data, deploy to production, handle real transactions

#### Requirements

**Functional Requirements:**
1. Generate exceptional, smooth, beautiful demo UI with client branding (logo, colors)
2. **Dynamic Demo Generation** (Client-Specific):
   - Auto-generate system prompt from research findings
   - Auto-generate mock tools based on client's use case
   - Use LangGraph two-node workflow (agent node + tools node) per https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/
   - Create contextually relevant mock data (customer profiles, conversations)
   - Deploy to isolated sandbox for client viewing
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
   - Implement LangGraph two-node workflow (agent node + tools node)
   - Mock tool responses return realistic data based on research
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
  "demo_config": {
    "channels": ["webchat", "voice"],
    "use_cases": ["customer_support", "lead_qualification"],
    "auto_generate_system_prompt": true,
    "auto_generate_tools": true,
    "langgraph_workflow": {
      "type": "two_node",
      "nodes": ["agent", "tools"],
      "architecture_reference": "https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/"
    },
    "branding_from_research": true,
    "conversation_samples": 10
  }
}

Response (202 Accepted):
{
  "demo_id": "uuid",
  "demo_type": "dynamic",
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
