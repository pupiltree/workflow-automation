# Comprehensive Sprint-by-Sprint Implementation Plan
## AI-Powered Workflow Automation Platform for B2B SaaS

**Document Version:** 1.0
**Created:** 2025-10-10
**Sprint Duration:** 2 weeks (10 working days)
**Total Duration:** 18 months
**Total Sprints:** 39 sprints
**Methodology:** Agile Scrum with Event-Driven Microservices Architecture

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Implementation Roadmap Overview](#implementation-roadmap-overview)
3. [Phase-by-Phase Sprint Details](#phase-by-phase-sprint-details)
4. [Technology Stack & Architectural Decisions](#technology-stack--architectural-decisions)
5. [Team Structure & Resource Planning](#team-structure--resource-planning)
6. [Quality Assurance Strategy](#quality-assurance-strategy)
7. [Risk Mitigation & Contingency Plans](#risk-mitigation--contingency-plans)
8. [Success Metrics & KPIs](#success-metrics--kpis)

---

## Executive Summary

### Platform Vision
Build a fully automated B2B SaaS platform that handles the complete client lifecycle: **Research → Demo Generation → Sales Documents → Implementation → Monitoring → Customer Success**, targeting **95% automation** within 18 months.

### Architecture Overview
- **17 Active Microservices** (optimized from 22)
- **2 Supporting Libraries** (@workflow/llm-sdk, @workflow/config-sdk)
- **18 Kafka Event Topics** for event-driven orchestration
- **5 Databases** (PostgreSQL, Qdrant, Neo4j, Redis, TimescaleDB)
- **Multi-Tenant SaaS** with Row-Level Security (RLS)
- **AI-Powered** using LangGraph (chatbots) and LiveKit (voicebots)

### Implementation Approach
- **6 Phases** over **39 two-week sprints** (18 months)
- **Incremental delivery** with working software at end of each sprint
- **Infrastructure-first** approach (databases, Kafka, Kong before services)
- **Testing embedded** throughout (no mocks for infrastructure, comprehensive integration tests)
- **Security by design** (RLS from Sprint 1, OAuth, multi-tenant isolation)

### Key Milestones
- **Month 4 (Sprint 8)**: Client Acquisition Pipeline Live (Research → Demo → Sales → Billing)
- **Month 8 (Sprint 16)**: PRD & Automation Engine Complete
- **Month 12 (Sprint 24)**: Runtime Services Deployed (Chatbot + Voicebot + Monitoring)
- **Month 16 (Sprint 32)**: Customer Operations Complete (Analytics, Success, Support, CRM)
- **Month 18 (Sprint 39)**: Production-Ready with Security Certifications

---

## Implementation Roadmap Overview

### Phase Distribution

| Phase | Sprints | Duration | Services Built | Key Deliverables |
|-------|---------|----------|----------------|------------------|
| **Phase 1: Foundation & Client Acquisition** | 1-8 | Months 1-4 | Services 0, 1, 2, 3, 22 | Infrastructure + Sales Pipeline |
| **Phase 2: PRD & Automation** | 9-16 | Months 5-8 | Services 6, 7, 17 + Libraries | PRD Generation + Config Automation |
| **Phase 3: Runtime Services** | 17-24 | Months 9-12 | Services 8, 9, 11 | Chatbot + Voicebot + Monitoring |
| **Phase 4: Customer Operations** | 25-32 | Months 13-16 | Services 12, 13, 14, 15, 20 | Analytics + Success + Support + CRM + Comms |
| **Phase 5: Advanced Features** | 33-36 | Months 17-18 | Service 21 | Agent Copilot + Hyperpersonalization |
| **Phase 6: Production Hardening** | 37-39 | Month 18 | Security + Compliance | SOC 2, Load Testing, Multi-Region |

### Architecture Health Progression
- **Sprint 1**: Architecture Health = 4/10 (basic infrastructure)
- **Sprint 8**: Architecture Health = 6/10 (client acquisition working)
- **Sprint 16**: Architecture Health = 7.5/10 (automation complete)
- **Sprint 24**: Architecture Health = 8.5/10 (runtime services operational)
- **Sprint 32**: Architecture Health = 9/10 (customer operations integrated)
- **Sprint 39**: Architecture Health = 9.5/10 (production-ready, certified)

---

## Phase-by-Phase Sprint Details

---

## PHASE 1: Foundation & Client Acquisition
**Duration:** Sprints 1-8 (Months 1-4)
**Goal:** Establish infrastructure and build client acquisition pipeline (Research → Demo → Sales → Billing)
**Services:** 0, 1, 2, 3, 22
**Team Size:** 6-8 engineers (2 DevOps, 3 Backend, 2 Frontend, 1 QA)

---

### Sprint 1: Infrastructure Foundation & Development Environment
**Weeks 1-2 | Sprint Goal:** Establish core infrastructure and CI/CD pipelines

#### User Stories

**US-1.1: Infrastructure as Code Setup**
- **Story**: As a DevOps engineer, I need infrastructure as code so that environments are reproducible and version-controlled
- **Acceptance Criteria**:
  - Terraform scripts for AWS infrastructure (VPC, subnets, security groups)
  - PostgreSQL (RDS) provisioned with multi-AZ deployment
  - Redis (ElastiCache) cluster provisioned
  - S3 buckets created for configs and assets
  - IAM roles and policies defined
- **Story Points**: 8
- **Priority**: P0 (Blocker)
- **Business Value**: Foundation for all subsequent work

**US-1.2: Kubernetes Cluster Setup**
- **Story**: As a DevOps engineer, I need a Kubernetes cluster so that microservices can be deployed and scaled
- **Acceptance Criteria**:
  - EKS cluster provisioned with 3 worker nodes
  - Helm installed and configured
  - Namespaces created (dev, staging, prod)
  - kubectl access configured for team
  - Ingress controller installed (NGINX)
- **Story Points**: 8
- **Priority**: P0
- **Business Value**: Container orchestration platform

**US-1.3: PostgreSQL with Row-Level Security**
- **Story**: As a backend engineer, I need PostgreSQL with RLS enabled so that multi-tenant data is isolated
- **Acceptance Criteria**:
  - PostgreSQL 15+ deployed via Supabase or RDS
  - RLS policies template created
  - Database migration tool installed (Alembic or Flyway)
  - Connection pooling configured (PgBouncer)
  - Backup automation configured (daily snapshots)
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: Data isolation security

**US-1.4: CI/CD Pipeline**
- **Story**: As a developer, I need automated CI/CD so that code changes are tested and deployed automatically
- **Acceptance Criteria**:
  - GitHub Actions workflows for build/test/deploy
  - Docker image build and push to ECR
  - Automated testing on every PR
  - Deployment to dev environment on merge to main
  - Staging deployment via manual approval
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: Development velocity

#### Technical Implementation

**Infrastructure Components**:
- **Cloud Provider**: AWS (primary)
- **IaC Tool**: Terraform 1.6+
- **Container Registry**: Amazon ECR
- **Kubernetes**: Amazon EKS 1.28+
- **Database**: PostgreSQL 15+ (Supabase or RDS)
- **Cache**: Redis 7+ (ElastiCache)
- **Storage**: S3 for configs, assets, backups

**Development Environment**:
```bash
# Directory structure
/infrastructure
  /terraform
    - main.tf
    - variables.tf
    - outputs.tf
    /modules
      /eks
      /rds
      /redis
      /s3
/services (to be populated in future sprints)
/.github
  /workflows
    - ci.yml
    - deploy-dev.yml
    - deploy-staging.yml
```

**CI/CD Workflow**:
1. Developer pushes code to feature branch
2. GitHub Actions triggers:
   - Linting (flake8, eslint)
   - Unit tests (pytest, jest)
   - Docker image build
   - Security scan (Trivy)
3. On merge to main:
   - Build production Docker image
   - Push to ECR
   - Deploy to dev environment (auto)
4. Manual approval for staging deployment

#### Architecture Decisions

**AD-1.1: Why Terraform over AWS CDK?**
- **Context**: Need infrastructure as code for reproducible environments
- **Options**: Terraform, AWS CDK, Pulumi, CloudFormation
- **Decision**: Terraform
- **Rationale**:
  - Cloud-agnostic (future multi-cloud flexibility)
  - Mature ecosystem with extensive modules
  - Declarative syntax easier for team to review
  - State management with S3 backend + DynamoDB locking

**AD-1.2: Why Supabase PostgreSQL over RDS?**
- **Context**: Need PostgreSQL with RLS for multi-tenant isolation
- **Options**: Supabase, RDS PostgreSQL, Aurora PostgreSQL
- **Decision**: Supabase (with RDS fallback option)
- **Rationale**:
  - Built-in RLS policy management UI
  - Realtime subscriptions (future use for live updates)
  - Auth integration (optional, can use separately)
  - Cost-effective for startup phase
  - **Fallback**: RDS if Supabase limits hit (manual RLS setup)

**AD-1.3: Why EKS over ECS?**
- **Context**: Need container orchestration
- **Options**: EKS (Kubernetes), ECS (Fargate), Google GKE, self-hosted K8s
- **Decision**: Amazon EKS
- **Rationale**:
  - Kubernetes is industry standard (easier hiring)
  - Portable to other clouds if needed
  - Rich ecosystem (Helm charts, operators)
  - Team has Kubernetes experience

#### Dependencies & Prerequisites

**External Dependencies**:
- AWS account with appropriate IAM permissions
- GitHub organization and repository access
- Domain name registered (for API Gateway)
- SSL certificates (ACM or Let's Encrypt)

**Technical Dependencies**:
- None (this is the foundation sprint)

**Blockers**:
- ❗ AWS account approval (can take 1-2 days for new accounts)
- ❗ IAM permission setup (requires admin access)

#### Testing Strategy

**Infrastructure Testing**:
- **Unit Tests**: Terraform validation (`terraform validate`)
- **Integration Tests**:
  - Deploy to temporary test environment
  - Verify all resources created correctly
  - Tear down test environment
- **Security Tests**:
  - IAM policy linting (IAM Access Analyzer)
  - Security group rules validation (no 0.0.0.0/0 on non-public ports)
  - S3 bucket encryption enabled
  - RDS encryption at rest enabled

**CI/CD Testing**:
- **Pipeline Tests**:
  - Test PR workflow triggers correctly
  - Verify Docker build succeeds
  - Confirm deployment to dev environment works
  - Test manual approval gate for staging

**Acceptance Tests**:
```bash
# Verify infrastructure
terraform output | grep "cluster_endpoint"
kubectl get nodes
psql -h <db-endpoint> -U postgres -c "SELECT version();"
redis-cli -h <redis-endpoint> PING
```

#### DevOps & Deployment

**Deployment Strategy**:
- **Infrastructure**: Terraform apply to AWS (dev → staging → prod)
- **Order**:
  1. VPC, subnets, security groups
  2. RDS PostgreSQL
  3. ElastiCache Redis
  4. EKS cluster
  5. S3 buckets
  6. IAM roles

**Rollback Plan**:
- Terraform state stored in S3 with versioning enabled
- Can revert to previous Terraform state via `terraform state pull <version>`
- Database backups taken before any schema changes
- EKS cluster uses versioned AMIs (can recreate if needed)

**CI/CD Infrastructure**:
- GitHub Actions runners (hosted)
- Secrets stored in GitHub Secrets
- AWS credentials via OIDC (no long-lived keys)

#### Observability

**Metrics to Track**:
- Infrastructure provisioning time (target: <30 minutes for full stack)
- CI/CD pipeline duration (target: <10 minutes for build+test)
- Database connection pool metrics (idle, active, waiting)
- Redis cache hit rate (initial baseline)

**Logs to Collect**:
- Terraform apply logs (stored in S3)
- GitHub Actions workflow logs
- PostgreSQL slow query log (threshold: 1s)
- Kubernetes control plane logs

**Traces to Implement**:
- Not applicable (no services deployed yet)

**Alerts to Configure**:
- RDS CPU > 80% for 5 minutes
- Redis memory > 90%
- EKS node not ready
- Terraform apply failures

#### Documentation

**Technical Documentation**:
- `docs/infrastructure/SETUP.md`: Infrastructure setup guide
- `docs/infrastructure/TERRAFORM.md`: Terraform module documentation
- `docs/infrastructure/DATABASE.md`: PostgreSQL RLS policy templates
- `docs/infrastructure/CI_CD.md`: CI/CD pipeline documentation

**API Documentation**:
- Not applicable (no services yet)

**Deployment Guides**:
- `docs/deployment/DEV_ENVIRONMENT.md`: Local development setup
- `docs/deployment/KUBERNETES.md`: Kubernetes deployment guide

**Operational Runbooks**:
- `docs/runbooks/INFRASTRUCTURE_ROLLBACK.md`: How to rollback infrastructure changes
- `docs/runbooks/DATABASE_RESTORE.md`: How to restore PostgreSQL from backup
- `docs/runbooks/CLUSTER_SCALING.md`: How to scale EKS cluster

#### Risk Mitigation

**Identified Risks**:
1. **Risk**: AWS account quota limits (EKS cluster limit: 5 per region by default)
   - **Mitigation**: Request quota increase proactively
   - **Contingency**: Use different AWS region if quota denied

2. **Risk**: Terraform state corruption
   - **Mitigation**: S3 versioning enabled, DynamoDB state locking
   - **Contingency**: Restore from S3 version history

3. **Risk**: PostgreSQL RLS policy complexity
   - **Mitigation**: Create reusable policy templates, comprehensive testing
   - **Contingency**: Fallback to application-level filtering (temporary)

4. **Risk**: CI/CD pipeline downtime (GitHub Actions outage)
   - **Mitigation**: Manual deployment scripts as backup
   - **Contingency**: Jenkins self-hosted alternative (pre-configured)

**Risk Score**: MEDIUM (Infrastructure is new, team learning curve)

#### Sprint Retrospective Preparation

**Success Criteria**:
- [ ] All Terraform modules deploy successfully to dev environment
- [ ] PostgreSQL accessible with RLS policies template applied
- [ ] Redis cluster responding to PING
- [ ] EKS cluster with 3 nodes in ready state
- [ ] CI/CD pipeline deploys sample "Hello World" service
- [ ] All team members can access infrastructure via kubectl/psql

**Metrics to Measure**:
- Infrastructure deployment time: _____ minutes (target: <30 min)
- CI/CD pipeline success rate: _____ % (target: >95%)
- Number of rollbacks needed: _____ (target: 0)
- Team onboarding time: _____ hours (target: <4 hours per person)

**Lessons Learned Focus Areas**:
- What infrastructure setup steps took longer than expected?
- Any security configurations we missed?
- CI/CD pipeline bottlenecks identified?
- Team skill gaps in Kubernetes/Terraform?

---

### Sprint 2: Kong API Gateway & Service 0 Foundation
**Weeks 3-4 | Sprint Goal:** Deploy API Gateway and build Organization & Identity Management Service foundation

#### User Stories

**US-2.1: Kong API Gateway Deployment**
- **Story**: As a platform engineer, I need Kong API Gateway so that all services have centralized authentication, rate limiting, and routing
- **Acceptance Criteria**:
  - Kong deployed on Kubernetes (Helm chart)
  - Kong database (PostgreSQL) configured
  - Admin API accessible
  - DNS configured for api.workflow-automation.com
  - SSL certificate installed (Let's Encrypt)
  - Rate limiting plugin configured globally (1000 req/min per IP)
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: Security and routing foundation

**US-2.2: JWT Authentication Plugin**
- **Story**: As a security engineer, I need JWT authentication so that only authorized users can access services
- **Acceptance Criteria**:
  - Kong JWT plugin configured
  - JWT signing key generated and stored in AWS Secrets Manager
  - Token validation logic tested (valid token passes, expired token fails, invalid signature fails)
  - Custom header injection (X-User-ID, X-Tenant-ID) configured
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: Authentication enforcement

**US-2.3: Service 0 - Database Schema**
- **Story**: As a backend engineer, I need the Organization Management database schema so that users and organizations can be stored
- **Acceptance Criteria**:
  - Tables created: auth.users, organizations, team_memberships, audit_logs, agent_profiles, client_assignments
  - RLS policies applied to all tables (filter by tenant_id)
  - Foreign key constraints defined
  - Indexes created (user_id, organization_id, tenant_id)
  - Migration script tested (up and down)
- **Story Points**: 8
- **Priority**: P0
- **Business Value**: Data model foundation

**US-2.4: Service 0 - Signup API**
- **Story**: As a potential client, I want to sign up with my work email so that I can access the platform
- **Acceptance Criteria**:
  - POST /api/v1/auth/signup endpoint implemented
  - Work email validation (reject gmail/yahoo/hotmail)
  - Email verification code sent via SendGrid
  - Verification code stored in Redis (15-minute expiry)
  - RLS policy ensures user can only access own organization
- **Story Points**: 8
- **Priority**: P0
- **Business Value**: User acquisition

**US-2.5: Service 0 - Login API**
- **Story**: As a registered user, I want to log in with email and password so that I can access my account
- **Acceptance Criteria**:
  - POST /api/v1/auth/login endpoint implemented
  - Password hashing with bcrypt (cost factor: 12)
  - JWT token issued on successful login (24-hour expiry)
  - Refresh token support (7-day expiry)
  - Failed login attempts logged to audit_logs
  - Rate limiting: 5 attempts per 15 minutes per email
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: User authentication

#### Technical Implementation

**Service 0 Architecture**:
```
workflow-automation/
├── services/
│   └── organization-management/
│       ├── app/
│       │   ├── api/
│       │   │   ├── v1/
│       │   │   │   ├── auth.py (signup, login endpoints)
│       │   │   │   └── organizations.py (org CRUD)
│       │   ├── core/
│       │   │   ├── config.py
│       │   │   ├── security.py (JWT, password hashing)
│       │   │   └── database.py (SQLAlchemy engine)
│       │   ├── models/
│       │   │   ├── user.py
│       │   │   └── organization.py
│       │   ├── schemas/
│       │   │   ├── auth.py (Pydantic models)
│       │   │   └── organization.py
│       │   └── services/
│       │       └── auth_service.py (business logic)
│       ├── migrations/ (Alembic)
│       ├── tests/
│       ├── Dockerfile
│       ├── requirements.txt
│       └── main.py
```

**API Endpoints**:
```python
# POST /api/v1/auth/signup
{
  "email": "john@acme.com",
  "password": "SecurePass123!",
  "company_name": "Acme Corp",
  "first_name": "John",
  "last_name": "Doe"
}
# Response: {"user_id": "uuid", "message": "Verification email sent"}

# POST /api/v1/auth/verify-email
{
  "email": "john@acme.com",
  "verification_code": "123456"
}
# Response: {"message": "Email verified", "organization_id": "uuid"}

# POST /api/v1/auth/login
{
  "email": "john@acme.com",
  "password": "SecurePass123!"
}
# Response: {"access_token": "jwt...", "refresh_token": "jwt...", "expires_in": 86400}
```

**Database Schema**:
```sql
-- auth.users (shared by clients and agents)
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('client', 'agent')),
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON auth.users(email);
CREATE INDEX idx_users_type ON auth.users(user_type);

-- RLS Policy
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY users_isolation ON auth.users
  USING (id = current_setting('app.current_user_id')::UUID);

-- organizations
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  owner_id UUID NOT NULL REFERENCES auth.users(id),
  tenant_id UUID NOT NULL DEFAULT gen_random_uuid(),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_organizations_tenant ON organizations(tenant_id);
CREATE INDEX idx_organizations_owner ON organizations(owner_id);

-- RLS Policy
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY org_isolation ON organizations
  USING (tenant_id = current_setting('app.tenant_id')::UUID);

-- team_memberships
CREATE TABLE team_memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  role VARCHAR(50) DEFAULT 'member',
  config_permissions JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

ALTER TABLE team_memberships ENABLE ROW LEVEL SECURITY;
CREATE POLICY team_isolation ON team_memberships
  USING (organization_id IN (SELECT id FROM organizations));
```

**Kong Configuration**:
```yaml
# kong-values.yaml (Helm)
image:
  repository: kong
  tag: "3.4"

env:
  database: postgres
  pg_host: <rds-endpoint>
  pg_database: kong
  pg_user: kong
  pg_password: <from-secrets-manager>

ingressController:
  enabled: true
  installCRDs: false

proxy:
  enabled: true
  type: LoadBalancer
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: <acm-cert-arn>
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http

admin:
  enabled: true
  type: ClusterIP

plugins:
  configMaps:
    - name: kong-plugin-jwt
      pluginName: jwt
```

**JWT Configuration**:
```python
# app/core/security.py
from jose import jwt
from datetime import datetime, timedelta

SECRET_KEY = os.getenv("JWT_SECRET_KEY")  # From AWS Secrets Manager
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24 hours

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
```

#### Architecture Decisions

**AD-2.1: Why Kong over AWS API Gateway?**
- **Context**: Need API gateway for authentication, rate limiting, routing
- **Options**: Kong, AWS API Gateway, Nginx, Traefik
- **Decision**: Kong API Gateway
- **Rationale**:
  - Open-source with enterprise features available
  - Kubernetes-native (runs in-cluster)
  - Rich plugin ecosystem (JWT, rate limiting, logging)
  - No vendor lock-in (can move to any cloud)
  - Team has experience with Kong

**AD-2.2: Why JWT over Session Cookies?**
- **Context**: Need authentication mechanism for API access
- **Options**: JWT, Session cookies, OAuth2, SAML
- **Decision**: JWT (JSON Web Tokens)
- **Rationale**:
  - Stateless (no server-side session storage needed)
  - Works well with microservices (each service can validate independently)
  - Mobile-friendly (no cookie limitations)
  - Industry standard for API authentication

**AD-2.3: Why SendGrid over SES for Email?**
- **Context**: Need to send verification emails
- **Options**: SendGrid, AWS SES, Mailgun, Postmark
- **Decision**: SendGrid
- **Rationale**:
  - Better deliverability out of the box (pre-warmed IPs)
  - Template management UI
  - Email analytics (open rates, click rates)
  - Simpler setup than SES (no IP warm-up needed)
  - **Tradeoff**: Higher cost than SES at scale (will reconsider at 100K+ emails/month)

#### Dependencies & Prerequisites

**External Dependencies**:
- Sprint 1 infrastructure (PostgreSQL, Redis, EKS)
- SendGrid account and API key
- Domain name for API gateway (api.workflow-automation.com)
- SSL certificate (AWS ACM or Let's Encrypt)

**Technical Dependencies**:
- PostgreSQL connection from EKS pods (test connectivity)
- Redis connection from EKS pods
- AWS Secrets Manager access for service accounts

**Blockers**:
- ❗ DNS propagation time (can take 24-48 hours)
- ❗ SSL certificate validation (Let's Encrypt takes 5-10 minutes)

#### Testing Strategy

**Unit Tests**:
```python
# tests/test_auth_service.py
def test_signup_with_work_email():
    response = client.post("/api/v1/auth/signup", json={
        "email": "test@acme.com",
        "password": "SecurePass123!",
        "company_name": "Acme Corp",
        "first_name": "Test",
        "last_name": "User"
    })
    assert response.status_code == 201
    assert "user_id" in response.json()

def test_signup_with_personal_email_fails():
    response = client.post("/api/v1/auth/signup", json={
        "email": "test@gmail.com",  # Personal email
        "password": "SecurePass123!",
        "company_name": "Acme Corp"
    })
    assert response.status_code == 400
    assert "work email" in response.json()["detail"].lower()

def test_login_with_correct_password():
    # Setup: Create user
    # Act: Login
    response = client.post("/api/v1/auth/login", json={
        "email": "test@acme.com",
        "password": "SecurePass123!"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_login_with_wrong_password_fails():
    response = client.post("/api/v1/auth/login", json={
        "email": "test@acme.com",
        "password": "WrongPassword!"
    })
    assert response.status_code == 401
```

**Integration Tests**:
```python
# tests/integration/test_multi_tenant_isolation.py
def test_rls_policy_prevents_cross_tenant_access():
    # Create two separate organizations
    org1 = create_organization("Acme Corp")
    org2 = create_organization("TechCo")

    # User from org1 tries to access org2 data
    set_current_tenant(org1.tenant_id)
    result = db.query(Organization).filter(Organization.id == org2.id).first()

    # Should return None due to RLS policy
    assert result is None

def test_jwt_token_contains_tenant_id():
    token = create_access_token({"sub": user.id, "tenant_id": org.tenant_id})
    decoded = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    assert decoded["tenant_id"] == str(org.tenant_id)
```

**End-to-End Tests**:
```python
def test_full_signup_flow():
    # 1. Signup
    signup_response = client.post("/api/v1/auth/signup", json={...})
    assert signup_response.status_code == 201

    # 2. Check email sent (mock SendGrid)
    assert mock_sendgrid.send_email.called

    # 3. Verify email
    verify_response = client.post("/api/v1/auth/verify-email", json={
        "email": "test@acme.com",
        "verification_code": "123456"
    })
    assert verify_response.status_code == 200

    # 4. Login
    login_response = client.post("/api/v1/auth/login", json={
        "email": "test@acme.com",
        "password": "SecurePass123!"
    })
    assert login_response.status_code == 200
    assert "access_token" in login_response.json()

    # 5. Access protected endpoint with token
    token = login_response.json()["access_token"]
    profile_response = client.get("/api/v1/profile", headers={
        "Authorization": f"Bearer {token}"
    })
    assert profile_response.status_code == 200
```

**Security Tests**:
```python
def test_sql_injection_protection():
    response = client.post("/api/v1/auth/login", json={
        "email": "test@acme.com' OR '1'='1",
        "password": "anything"
    })
    assert response.status_code == 401  # Should not bypass auth

def test_rate_limiting():
    for i in range(6):  # Limit is 5 attempts per 15 minutes
        response = client.post("/api/v1/auth/login", json={
            "email": "test@acme.com",
            "password": "wrong"
        })

    # 6th attempt should be rate limited
    assert response.status_code == 429

def test_password_hashing():
    user = create_user(password="SecurePass123!")
    # Password should never be stored in plaintext
    assert user.password_hash != "SecurePass123!"
    assert len(user.password_hash) == 60  # bcrypt hash length
```

#### DevOps & Deployment

**Deployment Strategy**:
1. **Kong Deployment**:
   ```bash
   helm repo add kong https://charts.konghq.com
   helm install kong kong/kong -f kong-values.yaml -n kong --create-namespace
   ```

2. **Service 0 Deployment**:
   ```bash
   # Build Docker image
   docker build -t organization-management:v0.1.0 .
   docker tag organization-management:v0.1.0 <ecr-repo>/organization-management:v0.1.0
   docker push <ecr-repo>/organization-management:v0.1.0

   # Deploy to Kubernetes
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

3. **Database Migrations**:
   ```bash
   # Run migrations in init container
   alembic upgrade head
   ```

**Rollback Plan**:
- Kong rollback: `helm rollback kong <revision>`
- Service 0 rollback: `kubectl rollout undo deployment/organization-management`
- Database rollback: `alembic downgrade -1` (test in staging first!)

**Kubernetes Manifests**:
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: organization-management
  namespace: services
spec:
  replicas: 2
  selector:
    matchLabels:
      app: organization-management
  template:
    metadata:
      labels:
        app: organization-management
    spec:
      initContainers:
      - name: migrations
        image: <ecr-repo>/organization-management:v0.1.0
        command: ["alembic", "upgrade", "head"]
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
      containers:
      - name: api
        image: <ecr-repo>/organization-management:v0.1.0
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
        - name: JWT_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
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

#### Observability

**Metrics to Track**:
- Signup success rate (target: >80%)
- Login success rate (target: >95%)
- Email verification completion rate (target: >70%)
- API response time (P95 < 200ms)
- JWT token validation time (P95 < 50ms)
- RLS policy overhead (measure query time with/without RLS)

**Logs to Collect**:
- All authentication events (signup, login, logout, token refresh)
- Failed login attempts (for security monitoring)
- Email sending events (success, failure, bounce)
- RLS policy violations (should be zero, indicates bug if not)

**Traces to Implement**:
- OpenTelemetry instrumentation for all API endpoints
- Trace signup flow: API → Database → Redis → SendGrid
- Trace login flow: API → Database → JWT generation

**Alerts to Configure**:
- Signup API error rate > 5% for 5 minutes
- Login API error rate > 5% for 5 minutes
- SendGrid email delivery failure > 10% for 10 minutes
- RLS policy violation detected (immediate Slack alert)
- JWT secret key rotation needed (30 days before expiry)

#### Documentation

**Technical Documentation**:
- `docs/services/SERVICE_0_ORG_MANAGEMENT.md`: Service architecture overview
- `docs/api/AUTH_API.md`: Authentication API reference
- `docs/security/RLS_POLICIES.md`: Row-Level Security policy documentation
- `docs/security/JWT_IMPLEMENTATION.md`: JWT token structure and validation

**API Documentation** (OpenAPI/Swagger):
```yaml
openapi: 3.0.0
info:
  title: Organization Management API
  version: 1.0.0
paths:
  /api/v1/auth/signup:
    post:
      summary: User signup with work email
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 8
                company_name:
                  type: string
      responses:
        201:
          description: User created, verification email sent
        400:
          description: Invalid input (personal email, weak password)
```

**Deployment Guides**:
- `docs/deployment/KONG_DEPLOYMENT.md`: Kong API Gateway deployment guide
- `docs/deployment/SERVICE_0_DEPLOYMENT.md`: Service 0 deployment guide
- `docs/deployment/DATABASE_MIGRATIONS.md`: How to run database migrations

**Operational Runbooks**:
- `docs/runbooks/PASSWORD_RESET.md`: How to handle password reset requests
- `docs/runbooks/JWT_SECRET_ROTATION.md`: How to rotate JWT signing keys
- `docs/runbooks/RLS_POLICY_UPDATE.md`: How to update RLS policies safely

#### Risk Mitigation

**Identified Risks**:
1. **Risk**: Email deliverability issues (verification emails in spam)
   - **Mitigation**: Use SendGrid with domain authentication (SPF, DKIM, DMARC)
   - **Contingency**: Alternative verification method (SMS via Twilio)

2. **Risk**: RLS policy bugs causing data leakage
   - **Mitigation**: Comprehensive testing, manual code review of all queries
   - **Contingency**: Application-level filtering as backup (defense in depth)

3. **Risk**: JWT secret key compromise
   - **Mitigation**: Store in AWS Secrets Manager, rotate every 90 days
   - **Contingency**: Immediate key rotation, force re-login all users

4. **Risk**: Kong API Gateway single point of failure
   - **Mitigation**: Deploy Kong in HA mode (2+ replicas)
   - **Contingency**: Direct service access (bypass gateway) in emergency

5. **Risk**: Database connection pool exhaustion
   - **Mitigation**: PgBouncer connection pooling, max connections = 100
   - **Contingency**: Horizontal scaling of service pods, increase pool size

**Risk Score**: HIGH (Authentication is critical, any bug exposes all data)

#### Sprint Retrospective Preparation

**Success Criteria**:
- [ ] Kong API Gateway accessible at api.workflow-automation.com with SSL
- [ ] User can sign up with work email and receive verification email
- [ ] User can log in and receive valid JWT token
- [ ] JWT token validated by Kong, request forwarded to service
- [ ] RLS policies prevent cross-tenant data access (verified by tests)
- [ ] CI/CD pipeline deploys Service 0 to dev environment
- [ ] All tests pass (unit, integration, security)
- [ ] API documentation published (Swagger UI)

**Metrics to Measure**:
- Sprint velocity: _____ story points completed (planned: 31)
- Test coverage: _____ % (target: >80%)
- API response time P95: _____ ms (target: <200ms)
- Number of production bugs: _____ (target: 0)

**Lessons Learned Focus Areas**:
- Did RLS policy development take longer than estimated?
- Any JWT implementation challenges?
- Kong configuration issues encountered?
- Email deliverability problems?

---

### Sprint 3: Service 1 (Research Engine) + Kafka Foundation
**Weeks 5-6 | Sprint Goal:** Deploy Research Engine with Perplexity AI integration and establish Kafka event bus

#### User Stories

**US-3.1: Kafka Cluster Setup**
- **Story**: As a platform engineer, I need Kafka deployed so that services can communicate via events
- **Acceptance Criteria**:
  - Kafka 3.6+ deployed on Kubernetes (Strimzi operator or MSK)
  - 3 Kafka brokers in different AZs
  - Zookeeper ensemble (3 nodes) or KRaft mode
  - Topic auto-creation disabled (explicit topic creation)
  - Schema Registry deployed (Confluent or Apicurio)
  - Kafka UI deployed for monitoring (Kafdrop or AKHQ)
- **Story Points**: 8
- **Priority**: P0
- **Business Value**: Event-driven architecture foundation

**US-3.2: Kafka Topics Creation**
- **Story**: As a backend engineer, I need Kafka topics defined so that services can produce/consume events
- **Acceptance Criteria**:
  - Topics created: auth_events, research_events, client_events
  - Partitions: 3 per topic (for parallelism)
  - Replication factor: 2 (for durability)
  - Retention: 7 days (configurable)
  - Avro schemas registered for all event types
- **Story Points**: 3
- **Priority**: P0
- **Business Value**: Event infrastructure

**US-3.3: Service 1 - Research Engine Foundation**
- **Story**: As a backend engineer, I need the Research Engine scaffolding so that research can be automated
- **Acceptance Criteria**:
  - FastAPI service created with directory structure
  - Database schema: research_sessions, research_findings, enrichment_data
  - Kafka producer configured (publishes to research_events)
  - Kafka consumer configured (consumes from auth_events)
  - Health check endpoint: GET /health
  - Docker image builds successfully
- **Story Points**: 5
- **Priority**: P0
- **Business Value**: Service foundation

**US-3.4: Perplexity AI Integration**
- **Story**: As a sales person, I want automated market research so that I understand the client's industry before the first call
- **Acceptance Criteria**:
  - Perplexity API client implemented (sonar-medium-online model)
  - Research query generation from company name + domain
  - Response parsing and storage in research_findings table
  - Rate limiting: 10 requests/minute (API limit)
  - Error handling: retry with exponential backoff (max 3 retries)
  - API key stored in AWS Secrets Manager
- **Story Points**: 8
- **Priority**: P1
- **Business Value**: Automated research capability

**US-3.5: Competitor Analysis Feature**
- **Story**: As a sales person, I want to know the client's competitors so that I can position our product effectively
- **Acceptance Criteria**:
  - Competitor identification via Perplexity (query: "competitors of {company_name}")
  - Pricing intelligence extraction (if publicly available)
  - Competitor data stored in research_findings (type: "competitor")
  - Minimum 3 competitors identified per client
  - Fallback: WebScraper.io if Perplexity doesn't provide results
- **Story Points**: 5
- **Priority**: P2
- **Business Value**: Competitive intelligence

**US-3.6: Auto-Trigger Research on Organization Creation**
- **Story**: As a system, I want to automatically trigger research when a new organization signs up
- **Acceptance Criteria**:
  - Kafka consumer listens to auth_events (organization_created)
  - On event received, trigger research job
  - Research job runs asynchronously (Celery task)
  - Progress tracked in research_sessions table (status: pending, in_progress, completed, failed)
  - Event published to research_events on completion
- **Story Points**: 5
- **Priority**: P1
- **Business Value**: Automation

#### Technical Implementation

**Kafka Infrastructure**:
```yaml
# kafka-values.yaml (Strimzi)
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: workflow-kafka
  namespace: kafka
spec:
  kafka:
    version: 3.6.0
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    storage:
      type: persistent-claim
      size: 100Gi
      class: gp3
    config:
      offsets.topic.replication.factor: 2
      transaction.state.log.replication.factor: 2
      transaction.state.log.min.isr: 2
      default.replication.factor: 2
      min.insync.replicas: 2
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 10Gi
      class: gp3
  entityOperator:
    topicOperator: {}
    userOperator: {}
```

**Kafka Topics**:
```yaml
# topics/auth-events.yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: auth-events
  namespace: kafka
  labels:
    strimzi.io/cluster: workflow-kafka
spec:
  partitions: 3
  replicas: 2
  config:
    retention.ms: 604800000  # 7 days
    segment.bytes: 1073741824
    compression.type: snappy
```

**Avro Schema**:
```json
{
  "type": "record",
  "name": "OrganizationCreated",
  "namespace": "com.workflow.events",
  "fields": [
    {"name": "event_id", "type": "string"},
    {"name": "event_type", "type": "string", "default": "organization_created"},
    {"name": "timestamp", "type": "long"},
    {"name": "organization_id", "type": "string"},
    {"name": "tenant_id", "type": "string"},
    {"name": "company_name", "type": "string"},
    {"name": "domain", "type": ["null", "string"], "default": null},
    {"name": "industry", "type": ["null", "string"], "default": null}
  ]
}
```

**Service 1 Architecture**:
```
services/research-engine/
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── research.py
│   ├── core/
│   │   ├── config.py
│   │   └── kafka.py (producer/consumer setup)
│   ├── models/
│   │   └── research.py
│   ├── schemas/
│   │   └── research.py
│   ├── services/
│   │   ├── perplexity_client.py
│   │   ├── webscraper_client.py
│   │   └── research_service.py
│   ├── consumers/
│   │   └── org_created_consumer.py (Kafka consumer)
│   └── tasks/
│       └── research_tasks.py (Celery tasks)
├── migrations/
├── tests/
├── Dockerfile
└── requirements.txt
```

**Perplexity Integration**:
```python
# app/services/perplexity_client.py
import httpx
from typing import Dict, Any

class PerplexityClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.perplexity.ai"
        self.client = httpx.AsyncClient(timeout=30.0)

    async def research_company(self, company_name: str, domain: str = None) -> Dict[str, Any]:
        """
        Conduct market research on a company using Perplexity AI.
        """
        query = f"""
        Research {company_name} (domain: {domain if domain else 'unknown'}):
        1. What industry are they in?
        2. What products/services do they offer?
        3. What is their approximate company size?
        4. What are their main customer segments?
        5. What technology stack do they use (if publicly known)?
        """

        response = await self.client.post(
            f"{self.base_url}/chat/completions",
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            },
            json={
                "model": "sonar-medium-online",
                "messages": [
                    {"role": "system", "content": "You are a market research assistant."},
                    {"role": "user", "content": query}
                ],
                "max_tokens": 1000,
                "temperature": 0.2,
                "return_citations": True
            }
        )

        if response.status_code != 200:
            raise Exception(f"Perplexity API error: {response.text}")

        return response.json()

    async def find_competitors(self, company_name: str, industry: str = None) -> Dict[str, Any]:
        """
        Identify competitors of the company.
        """
        query = f"Who are the main competitors of {company_name}"
        if industry:
            query += f" in the {industry} industry"
        query += "? List top 5 competitors with brief descriptions."

        response = await self.client.post(
            f"{self.base_url}/chat/completions",
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json"
            },
            json={
                "model": "sonar-medium-online",
                "messages": [{"role": "user", "content": query}],
                "max_tokens": 800,
                "temperature": 0.2
            }
        )

        return response.json()
```

**Kafka Consumer**:
```python
# app/consumers/org_created_consumer.py
from confluent_kafka import Consumer, KafkaError
from app.tasks.research_tasks import trigger_research
import json

class OrganizationCreatedConsumer:
    def __init__(self, bootstrap_servers: str, group_id: str):
        self.consumer = Consumer({
            'bootstrap.servers': bootstrap_servers,
            'group.id': group_id,
            'auto.offset.reset': 'earliest',
            'enable.auto.commit': False
        })
        self.consumer.subscribe(['auth_events'])

    async def consume(self):
        """
        Consume organization_created events and trigger research.
        """
        while True:
            msg = self.consumer.poll(timeout=1.0)

            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                else:
                    print(f"Kafka error: {msg.error()}")
                    break

            try:
                event = json.loads(msg.value().decode('utf-8'))

                if event.get('event_type') == 'organization_created':
                    # Trigger async research task
                    trigger_research.delay(
                        organization_id=event['organization_id'],
                        company_name=event['company_name'],
                        domain=event.get('domain')
                    )

                # Commit offset after successful processing
                self.consumer.commit(msg)

            except Exception as e:
                print(f"Error processing event: {e}")
                # Don't commit offset on error (will retry)
```

**Celery Task**:
```python
# app/tasks/research_tasks.py
from celery import Celery
from app.services.perplexity_client import PerplexityClient
from app.services.research_service import ResearchService
from app.core.kafka import kafka_producer
import json

celery_app = Celery('research_engine', broker='redis://localhost:6379/0')

@celery_app.task(bind=True, max_retries=3)
async def trigger_research(self, organization_id: str, company_name: str, domain: str = None):
    """
    Asynchronous research task triggered by organization creation.
    """
    try:
        # Create research session
        research_service = ResearchService()
        session = await research_service.create_session(organization_id)

        # Conduct research via Perplexity
        perplexity = PerplexityClient(api_key=settings.PERPLEXITY_API_KEY)
        company_research = await perplexity.research_company(company_name, domain)
        competitor_research = await perplexity.find_competitors(company_name)

        # Store findings
        await research_service.store_findings(
            session_id=session.id,
            company_research=company_research,
            competitor_research=competitor_research
        )

        # Mark session complete
        await research_service.complete_session(session.id)

        # Publish research_completed event
        await kafka_producer.send(
            'research_events',
            value=json.dumps({
                'event_id': str(uuid.uuid4()),
                'event_type': 'research_completed',
                'timestamp': int(time.time() * 1000),
                'organization_id': organization_id,
                'research_session_id': str(session.id),
                'findings_count': 2
            }).encode('utf-8')
        )

    except Exception as exc:
        # Retry with exponential backoff
        raise self.retry(exc=exc, countdown=2 ** self.request.retries)
```

**Database Schema**:
```sql
-- research_sessions
CREATE TABLE research_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  tenant_id UUID NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_research_sessions_org ON research_sessions(organization_id);
CREATE INDEX idx_research_sessions_status ON research_sessions(status);

ALTER TABLE research_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY research_sessions_isolation ON research_sessions
  USING (tenant_id = current_setting('app.tenant_id')::UUID);

-- research_findings
CREATE TABLE research_findings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  research_session_id UUID NOT NULL REFERENCES research_sessions(id),
  finding_type VARCHAR(50) NOT NULL, -- 'company_info', 'competitor', 'volume_prediction'
  data JSONB NOT NULL,
  confidence_score DECIMAL(3,2), -- 0.00 to 1.00
  source VARCHAR(100), -- 'perplexity', 'webscraper'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_findings_session ON research_findings(research_session_id);
CREATE INDEX idx_findings_type ON research_findings(finding_type);
```

#### Architecture Decisions

**AD-3.1: Why Kafka over AWS SQS/SNS?**
- **Context**: Need event-driven communication between services
- **Options**: Apache Kafka, AWS SQS/SNS, RabbitMQ, Google Pub/Sub
- **Decision**: Apache Kafka
- **Rationale**:
  - Event streaming (not just messaging) - can replay events
  - High throughput (millions of events/sec)
  - Event sourcing support (retain all events)
  - Industry standard for microservices
  - **Tradeoff**: More operational complexity than SQS (managed via Strimzi or MSK)

**AD-3.2: Why Strimzi over AWS MSK?**
- **Context**: Need managed Kafka deployment
- **Options**: Strimzi (Kubernetes operator), AWS MSK, Confluent Cloud
- **Decision**: Strimzi (with MSK as fallback)
- **Rationale**:
  - Kubernetes-native (runs in our EKS cluster)
  - No vendor lock-in (can move to any Kubernetes)
  - Lower cost than MSK for <100K events/day
  - Team can learn Kafka internals
  - **Fallback to MSK if**: Event volume >100K/day or operational burden too high

**AD-3.3: Why Perplexity over OpenAI for Research?**
- **Context**: Need AI-powered market research
- **Options**: Perplexity AI, OpenAI GPT-4 with web search, Google Gemini
- **Decision**: Perplexity AI (sonar-medium-online)
- **Rationale**:
  - Purpose-built for research (includes citations)
  - Real-time web access (OpenAI doesn't have this natively)
  - Lower cost than GPT-4 with plugins
  - Faster response time than GPT-4 web browsing mode
  - **Tradeoff**: Less flexible than GPT-4 for complex reasoning

**AD-3.4: Why Celery over Kafka Streams?**
- **Context**: Need async task execution for research jobs
- **Options**: Celery, Kafka Streams, AWS Step Functions, Temporal
- **Decision**: Celery with Redis broker
- **Rationale**:
  - Simpler for basic async tasks
  - Retry mechanism built-in
  - Task result storage
  - Team familiar with Celery
  - **Tradeoff**: Not as scalable as Kafka Streams (will reconsider at 10K+ jobs/day)

#### Dependencies & Prerequisites

**External Dependencies**:
- Sprint 1: PostgreSQL, Redis, EKS
- Sprint 2: Service 0 (publishes organization_created events)
- Perplexity API account and API key ($20/month pro plan)
- WebScraper.io account (optional, fallback)

**Technical Dependencies**:
- Kafka cluster running and accessible from EKS
- Schema Registry for Avro schemas
- Celery workers deployed

**Blockers**:
- ❗ Perplexity API rate limits (10 req/min for pro plan)
- ❗ Kafka persistent volumes (requires EBS CSI driver)

#### Testing Strategy

**Unit Tests**:
```python
# tests/test_perplexity_client.py
@pytest.mark.asyncio
async def test_research_company():
    client = PerplexityClient(api_key="test_key")

    # Mock API response
    with respx.mock:
        respx.post("https://api.perplexity.ai/chat/completions").mock(
            return_value=Response(200, json={
                "choices": [{"message": {"content": "Research result"}}]
            })
        )

        result = await client.research_company("Acme Corp", "acme.com")
        assert "choices" in result

@pytest.mark.asyncio
async def test_find_competitors():
    client = PerplexityClient(api_key="test_key")
    result = await client.find_competitors("Acme Corp", "SaaS")
    assert "choices" in result
```

**Integration Tests** (with real Kafka):
```python
# tests/integration/test_kafka_events.py
def test_organization_created_event_triggers_research():
    # 1. Publish organization_created event to Kafka
    producer = KafkaProducer(bootstrap_servers='localhost:9092')
    event = {
        'event_type': 'organization_created',
        'organization_id': str(uuid.uuid4()),
        'company_name': 'Test Corp',
        'domain': 'test.com'
    }
    producer.send('auth_events', value=json.dumps(event).encode())
    producer.flush()

    # 2. Wait for consumer to process (max 10 seconds)
    time.sleep(10)

    # 3. Verify research session created
    session = db.query(ResearchSession).filter(
        ResearchSession.organization_id == event['organization_id']
    ).first()
    assert session is not None
    assert session.status in ['in_progress', 'completed']

    # 4. Verify research_completed event published
    consumer = KafkaConsumer('research_events', bootstrap_servers='localhost:9092')
    messages = consumer.poll(timeout_ms=5000)
    found_event = False
    for topic_partition, records in messages.items():
        for record in records:
            event_data = json.loads(record.value.decode())
            if event_data['event_type'] == 'research_completed':
                found_event = True
                break
    assert found_event
```

**End-to-End Tests**:
```python
def test_full_research_workflow():
    # 1. Create organization via Service 0
    response = client.post("/api/v1/auth/signup", json={...})
    org_id = response.json()['organization_id']

    # 2. Wait for research to complete (async)
    timeout = 60  # 1 minute
    start = time.time()
    while time.time() - start < timeout:
        research_response = client.get(f"/api/v1/research/{org_id}/results")
        if research_response.status_code == 200:
            break
        time.sleep(5)

    # 3. Verify research findings
    assert research_response.status_code == 200
    findings = research_response.json()
    assert len(findings) >= 2  # Company info + competitors
    assert findings[0]['finding_type'] in ['company_info', 'competitor']
```

**Performance Tests**:
```python
def test_research_concurrency():
    # Trigger 10 concurrent research jobs
    org_ids = [str(uuid.uuid4()) for _ in range(10)]

    for org_id in org_ids:
        trigger_research.delay(org_id, f"TestCorp{org_id[:4]}")

    # Wait for all to complete
    timeout = 120  # 2 minutes
    start = time.time()
    completed = 0
    while time.time() - start < timeout and completed < 10:
        completed = db.query(ResearchSession).filter(
            ResearchSession.status == 'completed',
            ResearchSession.organization_id.in_(org_ids)
        ).count()
        time.sleep(5)

    assert completed == 10  # All completed

    # Verify Perplexity rate limiting respected (10 req/min)
    # Should take at least 60 seconds for 10 requests
    assert time.time() - start >= 60
```

#### DevOps & Deployment

**Kafka Deployment**:
```bash
# 1. Install Strimzi operator
kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# 2. Deploy Kafka cluster
kubectl apply -f kafka-cluster.yaml -n kafka

# 3. Wait for cluster ready
kubectl wait kafka/workflow-kafka --for=condition=Ready --timeout=300s -n kafka

# 4. Create topics
kubectl apply -f topics/ -n kafka

# 5. Deploy Schema Registry
helm install schema-registry confluent/cp-schema-registry \
  --set kafka.bootstrapServers="PLAINTEXT://workflow-kafka-kafka-bootstrap:9092"
```

**Service 1 Deployment**:
```bash
# 1. Build and push Docker image
docker build -t research-engine:v0.1.0 .
docker push <ecr-repo>/research-engine:v0.1.0

# 2. Deploy Celery worker
kubectl apply -f k8s/celery-worker.yaml

# 3. Deploy API service
kubectl apply -f k8s/deployment.yaml

# 4. Deploy Kafka consumer (separate deployment)
kubectl apply -f k8s/consumer-deployment.yaml
```

**Rollback Plan**:
- Service rollback: `kubectl rollout undo deployment/research-engine`
- Kafka topic rollback: Delete and recreate (data loss acceptable in dev)
- Consumer offset reset: `kafka-consumer-groups --reset-offsets --group research-consumer --topic auth_events --to-earliest`

#### Observability

**Metrics to Track**:
- Kafka lag (consumer lag per partition)
- Research job success rate (target: >90%)
- Research job duration (P95 < 2 minutes)
- Perplexity API latency (P95 < 5 seconds)
- Celery task queue depth
- Kafka throughput (events/sec)

**Logs to Collect**:
- All Kafka consumer events
- Research job start/complete/failure
- Perplexity API calls (request/response)
- Celery task execution logs

**Traces to Implement**:
- Trace: organization_created event → research job → Perplexity API → research_completed event
- Span: Perplexity API call duration
- Span: Database write duration

**Alerts to Configure**:
- Kafka consumer lag > 1000 messages
- Research job failure rate > 10% for 15 minutes
- Perplexity API error rate > 5%
- Celery task queue depth > 100
- Research job duration > 5 minutes (stuck job)

#### Documentation

**Technical Documentation**:
- `docs/services/SERVICE_1_RESEARCH_ENGINE.md`
- `docs/infrastructure/KAFKA_SETUP.md`
- `docs/integrations/PERPLEXITY_API.md`
- `docs/event-driven/KAFKA_TOPICS.md`

**API Documentation**:
```yaml
paths:
  /api/v1/research/{organization_id}/results:
    get:
      summary: Get research findings for organization
      responses:
        200:
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    finding_type:
                      type: string
                    data:
                      type: object
                    confidence_score:
                      type: number
```

**Event Documentation**:
```markdown
# Event: research_completed

**Topic**: research_events

**Schema**:
- event_id (string): Unique event ID
- event_type (string): "research_completed"
- timestamp (long): Unix timestamp in milliseconds
- organization_id (string): Organization UUID
- research_session_id (string): Research session UUID
- findings_count (int): Number of findings generated

**Produced By**: Service 1 (Research Engine)

**Consumed By**: Service 2 (Demo Generator)

**Example**:
```json
{
  "event_id": "123e4567-e89b-12d3-a456-426614174000",
  "event_type": "research_completed",
  "timestamp": 1698765432000,
  "organization_id": "789e4567-e89b-12d3-a456-426614174000",
  "research_session_id": "456e4567-e89b-12d3-a456-426614174000",
  "findings_count": 5
}
```
```

#### Risk Mitigation

**Identified Risks**:
1. **Risk**: Perplexity API rate limiting breaks research flow
   - **Mitigation**: Implement rate limiter (10 req/min), queue excess requests
   - **Contingency**: Upgrade to Perplexity Enterprise (higher limits)

2. **Risk**: Kafka consumer crashes and loses events
   - **Mitigation**: Manual offset commit after successful processing
   - **Contingency**: Replay events from earliest offset (7-day retention)

3. **Risk**: Research quality poor (hallucinations, outdated info)
   - **Mitigation**: Include citations, verify with WebScraper fallback
   - **Contingency**: Human review queue for low-confidence findings

4. **Risk**: Celery task queue fills up (backlog)
   - **Mitigation**: Auto-scaling Celery workers based on queue depth
   - **Contingency**: Pause new signups until backlog cleared

5. **Risk**: Kafka cluster out of disk space
   - **Mitigation**: Monitoring alert when disk >70%, auto-expansion enabled
   - **Contingency**: Reduce retention from 7 days to 1 day temporarily

**Risk Score**: MEDIUM (Multiple external dependencies, event-driven complexity)

#### Sprint Retrospective Preparation

**Success Criteria**:
- [ ] Kafka cluster deployed with 3 brokers, accessible from all services
- [ ] Kafka topics created with proper partitions/replication
- [ ] Service 1 consumes organization_created events from Service 0
- [ ] Research triggered automatically on new organization signup
- [ ] Perplexity API integration working (company research + competitors)
- [ ] Research findings stored in database with RLS
- [ ] research_completed event published to Kafka
- [ ] All tests pass (unit, integration, E2E)
- [ ] Kafka UI deployed and accessible

**Metrics to Measure**:
- Sprint velocity: _____ story points (planned: 34)
- Kafka event throughput: _____ events/sec
- Research job completion time P95: _____ seconds (target: <120s)
- Test coverage: _____ % (target: >80%)

**Lessons Learned Focus Areas**:
- Was Kafka setup more complex than expected?
- Perplexity API quality meeting expectations?
- Celery task reliability issues?
- Event-driven debugging challenges?

---

*Note: This document continues with Sprint 4-39. Due to length constraints, I'm providing the first 3 sprints in detail. The full document would follow the same comprehensive structure for all 39 sprints.*

---

## Sprints 4-8 Summary (Phase 1 Completion)

### Sprint 4: Service 2 (Demo Generator) - Foundation
- Demo Generator scaffolding
- React demo UI components
- LangGraph simulation agent setup
- S3/CloudFront for demo hosting

### Sprint 5: Service 2 (Demo Generator) - Integration
- Research data integration (consume research_events)
- Demo customization based on findings
- Analytics tracking (Mixpanel)
- Demo sharing (shareable links, QR codes)

### Sprint 6: Service 3 (Sales Document Generator) - NDA
- Unified Sales Document Generator scaffolding
- NDA generation (Jinja2 templates)
- DocuSign integration
- E-signature webhook handling

### Sprint 7: Service 3 - Pricing & Proposal
- Dynamic pricing model generation
- Proposal customization
- Multi-document workflow (NDA → Pricing → Proposal)
- Contract versioning

### Sprint 8: Service 22 (Billing & Revenue Management)
- Subscription management
- Stripe integration
- Invoice generation
- Dunning automation
- **Phase 1 Complete**: Client Acquisition Pipeline Live

---

## PHASE 2: PRD & Automation (Sprints 9-16)

### Sprints 9-16 Summary

**Sprint 9-10**: @workflow/llm-sdk + @workflow/config-sdk libraries
**Sprint 11-12**: Service 6 (PRD Builder) - Conversational PRD generation
**Sprint 13-14**: Service 7 (Automation Engine) - PRD → JSON config
**Sprint 15**: Service 17 (RAG Pipeline) - Vector embeddings, Qdrant
**Sprint 16**: Phase 2 Integration & Testing

---

## PHASE 3: Runtime Services (Sprints 17-24)

### Sprints 17-24 Summary

**Sprint 17-19**: Service 8 (Agent Orchestration) - LangGraph chatbot runtime
**Sprint 20-22**: Service 9 (Voice Agent) - LiveKit voicebot runtime
**Sprint 23-24**: Service 11 (Monitoring Engine) - Prometheus/Grafana, quality assurance

---

## PHASE 4: Customer Operations (Sprints 25-32)

### Sprints 25-32 Summary

**Sprint 25-26**: Service 12 (Analytics) - TimescaleDB, Metabase dashboards
**Sprint 27-28**: Service 13 (Customer Success) - Health scoring, QBR automation
**Sprint 29-30**: Service 14 (Support Engine) + Service 15 (CRM Integration)
**Sprint 31-32**: Service 20 (Communication & Hyperpersonalization) - Multi-Armed Bandit experiments

---

## PHASE 5: Advanced Features (Sprints 33-36)

### Sprints 33-36 Summary

**Sprint 33-34**: Service 21 (Agent Copilot) - Unified dashboard, context aggregation
**Sprint 35-36**: Advanced Hyperpersonalization - Cohort segmentation, A/B/N testing

---

## PHASE 6: Production Hardening (Sprints 37-39)

### Sprints 37-39 Summary

**Sprint 37**: Security hardening (penetration testing, SOC 2 prep)
**Sprint 38**: Performance optimization (load testing, multi-region deployment)
**Sprint 39**: Documentation, training, production launch

---

## Technology Stack & Architectural Decisions

### Core Technologies

| Category | Technology | Rationale |
|----------|-----------|-----------|
| **Container Orchestration** | Kubernetes (EKS) | Industry standard, portable |
| **API Gateway** | Kong | Kubernetes-native, rich plugins |
| **Event Bus** | Apache Kafka (Strimzi) | Event streaming, replay capability |
| **Primary Database** | PostgreSQL 15 (Supabase) | RLS for multi-tenancy, mature |
| **Vector Database** | Qdrant | Best performance for embeddings |
| **Graph Database** | Neo4j | Integration dependency tracking |
| **Cache** | Redis 7 | Session management, queues |
| **Time-Series DB** | TimescaleDB | Analytics, metrics storage |
| **Chatbot Framework** | LangGraph | Stateful agents, checkpointing |
| **Voicebot Framework** | LiveKit Agents | Real-time voice, <500ms latency |
| **LLM Primary** | OpenAI GPT-4o-mini | Cost-effective, fast |
| **LLM Fallback** | Anthropic Claude Sonnet-4 | High quality reasoning |
| **Voice STT** | Deepgram Nova-3 | Best accuracy, low latency |
| **Voice TTS** | ElevenLabs Flash v2.5 | Natural voice, fast |
| **CI/CD** | GitHub Actions | Integrated with GitHub |
| **IaC** | Terraform | Cloud-agnostic, mature |
| **Observability** | Prometheus + Grafana | Kubernetes-native |
| **Tracing** | OpenTelemetry | Vendor-neutral, standard |

### Key Architectural Patterns

**Multi-Tenancy**:
- Row-Level Security (RLS) in PostgreSQL
- Namespace isolation in Qdrant/Neo4j
- tenant_id in every table, every query

**Event-Driven Architecture**:
- Saga pattern for distributed transactions
- Event sourcing for audit trails
- Idempotent event handlers

**JSON Configuration**:
- S3 storage with versioning
- Redis caching for hot-reload
- JSON Schema validation

**Service Communication**:
- Synchronous: Kong → Services (HTTP/REST)
- Asynchronous: Kafka events between services
- Libraries: @workflow/llm-sdk, @workflow/config-sdk (direct import)

---

## Team Structure & Resource Planning

### Recommended Team Composition

**Phase 1-2 (Sprints 1-16): 8 people**
- 1 Tech Lead / Architect
- 2 Backend Engineers (Python/FastAPI)
- 1 Frontend Engineer (React)
- 2 DevOps Engineers (Kubernetes, Terraform, Kafka)
- 1 QA Engineer (Testing automation)
- 1 Product Manager (Prioritization, stakeholder management)

**Phase 3-4 (Sprints 17-32): 12 people**
- 1 Tech Lead
- 4 Backend Engineers (2 on LangGraph/LiveKit, 2 on data services)
- 2 Frontend Engineers (Dashboard, configuration UI)
- 2 DevOps Engineers
- 1 ML Engineer (Churn prediction, experimentation)
- 1 QA Engineer
- 1 Product Manager

**Phase 5-6 (Sprints 33-39): 10 people**
- 1 Tech Lead
- 3 Backend Engineers
- 1 Frontend Engineer
- 2 DevOps Engineers
- 1 Security Engineer (SOC 2, penetration testing)
- 1 QA Engineer
- 1 Product Manager

### Skill Requirements

**Backend Engineers**:
- Python (FastAPI, SQLAlchemy)
- Event-driven architecture (Kafka)
- LangGraph / LangChain
- PostgreSQL, Redis

**Frontend Engineers**:
- React, TypeScript
- WebSocket (real-time updates)
- Charting libraries (D3.js, Recharts)

**DevOps Engineers**:
- Kubernetes (EKS)
- Terraform
- Kafka (Strimzi or MSK)
- CI/CD (GitHub Actions)
- Observability (Prometheus, Grafana, OpenTelemetry)

**QA Engineers**:
- pytest, jest
- Integration testing (real infrastructure, no mocks)
- Load testing (Locust, k6)

---

## Quality Assurance Strategy

### Testing Pyramid

```
        /\
       /  \  E2E Tests (10%)
      /____\
     /      \  Integration Tests (30%)
    /________\
   /          \  Unit Tests (60%)
  /____________\
```

### Testing Principles

1. **No Mocks for Infrastructure**: Real PostgreSQL, Kafka, Redis in tests
2. **Multi-Tenant Test Fixtures**: Every test creates data for 2+ tenants
3. **Event Replay Testing**: Verify idempotency by replaying events
4. **Comprehensive Coverage**: >80% code coverage required
5. **Load Testing**: Every phase ends with load testing

### Testing Strategy Per Service

**Service 0 (Auth)**:
- Unit: Password hashing, JWT generation
- Integration: RLS policies, multi-tenant isolation
- Security: SQL injection, rate limiting, session hijacking

**Service 1 (Research)**:
- Unit: Perplexity client, parsing logic
- Integration: Kafka consumer, event publishing
- Performance: 10+ concurrent research jobs

**Service 8/9 (Runtime)**:
- Unit: LangGraph state transitions, tool execution
- Integration: Config hot-reload, checkpoint recovery
- Load: 1000+ concurrent conversations

---

## Success Metrics & KPIs

### Platform Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Automation Rate** | 95% by Month 18 | % of client lifecycle automated |
| **Time to Production** | 18 months | Actual vs planned |
| **Architecture Health** | 9/10 by Month 18 | Microservices best practices scorecard |
| **Test Coverage** | >80% | Code coverage across all services |
| **System Uptime** | 99.9% | Availability SLA |
| **API Response Time** | P95 <500ms | Kong → Service latency |
| **Event Processing Lag** | <1 minute P95 | Kafka consumer lag |

### Business Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Client Acquisition Cost** | -60% | vs manual process |
| **Customer Service Cost** | -80% | vs human-only support |
| **Demo Conversion Rate** | 30% | Demo → NDA signed |
| **Churn Reduction** | -40% | via proactive success management |
| **Time to First Value** | <24 hours | Signup → agent live |

### Development Velocity Metrics

| Sprint Phase | Expected Velocity (Story Points) |
|--------------|----------------------------------|
| Sprints 1-4 (Learning) | 25-30 per sprint |
| Sprints 5-16 (Ramp-up) | 30-40 per sprint |
| Sprints 17-32 (Peak) | 40-50 per sprint |
| Sprints 33-39 (Hardening) | 30-35 per sprint |

---

## Risk Mitigation & Contingency Plans

### Top 10 Risks

1. **External API Rate Limits** (Perplexity, OpenAI)
   - Mitigation: Caching, rate limiters, quota monitoring
   - Contingency: Fallback providers, request queuing

2. **Multi-Tenant Data Leakage**
   - Mitigation: RLS policies, comprehensive testing, manual code review
   - Contingency: Application-level filtering as backup

3. **Kafka Operational Complexity**
   - Mitigation: Strimzi operator, monitoring, runbooks
   - Contingency: Fallback to AWS MSK (managed)

4. **LangGraph State Management Bugs**
   - Mitigation: Extensive checkpointing tests, state validation
   - Contingency: Conversation restart mechanism

5. **Voice Latency >500ms**
   - Mitigation: Model optimization, edge caching, lightweight TTS
   - Contingency: Async responses ("Let me check on that...")

6. **Database Connection Pool Exhaustion**
   - Mitigation: PgBouncer pooling, connection monitoring
   - Contingency: Horizontal service scaling, increase pool size

7. **JWT Secret Key Compromise**
   - Mitigation: AWS Secrets Manager, 90-day rotation
   - Contingency: Immediate rotation, force re-login all users

8. **Kafka Disk Space Exhaustion**
   - Mitigation: Auto-expansion, 70% alert threshold
   - Contingency: Reduce retention from 7 days to 1 day

9. **Security Vulnerabilities**
   - Mitigation: Automated scanning (Trivy), regular audits
   - Contingency: Hotfix deployment process, incident response plan

10. **Team Skill Gaps**
    - Mitigation: Training budget, pair programming, documentation
    - Contingency: External consultants for LangGraph/LiveKit

---

## Appendix: Full Sprint Plan (Sprints 4-39)

*[Due to document length, detailed sprint-by-sprint breakdowns for Sprints 4-39 would follow the same comprehensive format as Sprints 1-3, covering all user stories, technical implementation, architecture decisions, dependencies, testing strategy, DevOps, observability, documentation, and risk mitigation for each sprint.]*

---

**END OF SPRINT IMPLEMENTATION PLAN**

---

## Document Maintenance

**Versioning**: This document uses semantic versioning (MAJOR.MINOR.PATCH)
- MAJOR: Architecture changes, service consolidation
- MINOR: Sprint plan adjustments, new features
- PATCH: Corrections, clarifications

**Update Frequency**: Review and update at end of each phase (every 8 sprints)

**Owners**: Product Manager + Tech Lead

**Change Log**:
- v1.0.0 (2025-10-10): Initial sprint plan (39 sprints, 6 phases)

---
