# Technology & Process Decision Matrix

**Quick Reference Guide for Implementation Decisions**

---

## Service Mesh Selection

| Factor | Linkerd | Istio |
|--------|---------|-------|
| **Performance (P99 latency)** | ✅ 163ms faster | ❌ Higher latency |
| **Resource Usage** | ✅ 90% less CPU/memory | ❌ Heavy footprint |
| **Ease of Deployment** | ✅ Simple config | ❌ Complex setup |
| **Security (mTLS)** | ✅ Default on | ✅ Available |
| **Advanced Traffic Mgmt** | ⚠️ Basic | ✅ Comprehensive |
| **Multi-Cloud Support** | ❌ Kubernetes only | ✅ Multiple platforms |
| **Learning Curve** | ✅ Shallow | ❌ Steep |
| **Cost (Infrastructure)** | ✅ Low overhead | ❌ High overhead |

**DECISION: Linkerd** ✅
- Performance critical for voice agents (<500ms target)
- Resource optimization aligns with cost goals
- Simpler deployment fits 12-month timeline
- Features sufficient for B2B SaaS requirements

---

## Multi-Tenancy Strategy

| Strategy | Isolation | Complexity | Cost | Scalability | Recommended For |
|----------|-----------|------------|------|-------------|-----------------|
| **Database Per Tenant** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | Regulated industries, enterprises |
| **Schema Per Tenant** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Balanced approach |
| **Shared Schema + RLS** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | B2B SaaS, many small-medium tenants |

**DECISION: Shared Schema with Row-Level Security (RLS)** ✅
- Best scalability for 100+ tenants
- PostgreSQL RLS provides database-enforced isolation
- Simplest architecture (lowest complexity)
- Most cost-effective
- Supabase native support

**Implementation Requirements:**
- `tenant_id UUID NOT NULL` on EVERY table
- RLS policies on EVERY table
- Application sets `app.current_tenant` per request
- Automated tests for tenant isolation on EVERY endpoint

---

## Sprint Duration Selection

| Scenario | 1-Week Sprints | 2-Week Sprints |
|----------|----------------|----------------|
| **High uncertainty** | ✅ Recommended | ❌ Too slow |
| **New technology stack** | ✅ Recommended | ❌ Too slow |
| **Prototyping phase** | ✅ Recommended | ❌ Too slow |
| **Using AI for exploration** | ✅ Recommended | ❌ Too slow |
| **Stable architecture** | ❌ Too much overhead | ✅ Recommended |
| **Established velocity** | ❌ Meeting fatigue | ✅ Recommended |
| **Feature delivery focus** | ❌ Work rollover | ✅ Recommended |

**DECISION:**
- **Sprints 1-8:** 1-week sprints (foundation, high uncertainty)
- **Sprints 9-20:** 2-week sprints (stable architecture, feature delivery)

---

## CI/CD Tool Selection

| Tool | Kubernetes-Native | GitOps | UI Quality | Multi-Tenancy | Learning Curve |
|------|-------------------|--------|------------|---------------|----------------|
| **Argo CD** | ✅ Yes | ✅ Yes | ⭐⭐⭐⭐⭐ | ✅ Yes | ⭐⭐⭐ |
| **Flux CD** | ✅ Yes | ✅ Yes | ⭐⭐⭐ | ✅ Yes | ⭐⭐ |
| **Jenkins X** | ✅ Yes | ✅ Yes | ⭐⭐ | ⚠️ Limited | ⭐⭐⭐⭐ |
| **Spinnaker** | ⚠️ Partial | ❌ No | ⭐⭐⭐⭐ | ✅ Yes | ⭐⭐⭐⭐⭐ |

**DECISION: Argo CD** ✅
- Best UI for visualization and debugging
- Native GitOps with drift detection
- Multi-tenancy support built-in
- Large community and ecosystem
- RBAC integration

---

## Secret Management Solution

| Solution | K8s-Native | Auto-Rotation | Multi-Cloud | Cost | Complexity |
|----------|------------|---------------|-------------|------|------------|
| **External Secrets Operator + AWS** | ✅ Yes | ✅ Yes | ⚠️ AWS-focused | ⭐⭐ | ⭐⭐ |
| **HashiCorp Vault** | ⚠️ Via Agent | ✅ Yes | ✅ Yes | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Sealed Secrets** | ✅ Yes | ❌ Manual | ✅ Yes | ⭐ | ⭐ |
| **SOPS** | ⚠️ Via Plugin | ❌ Manual | ✅ Yes | ⭐ | ⭐⭐ |

**DECISION: External Secrets Operator + AWS Secrets Manager** ✅
- Kubernetes-native integration
- Automatic secret refresh
- GitOps compatible (no secrets in Git)
- AWS Secrets Manager handles rotation
- Lower operational complexity than Vault
- Cost-effective for AWS infrastructure

---

## Container Base Image Selection

| Base Image | Size | Security | Performance | Use Case |
|------------|------|----------|-------------|----------|
| **Alpine** | ⭐⭐⭐⭐⭐ (5MB) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | General purpose, production |
| **Distroless** | ⭐⭐⭐⭐ (20MB) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Maximum security, static binaries |
| **Debian Slim** | ⭐⭐⭐ (50MB) | ⭐⭐⭐ | ⭐⭐⭐ | Need specific tools, debugging |
| **Ubuntu** | ⭐ (100MB+) | ⭐⭐ | ⭐⭐ | Legacy apps, avoid if possible |

**DECISION: Alpine for most services** ✅
- 60-80% smaller images than full distros
- Faster deployments and scaling
- Adequate security for most use cases
- Large ecosystem (most official images have Alpine variants)

**Exception: Distroless for security-critical services** (auth, payment)

---

## AI Tool Usage by Task Type

| Task Type | AI Tool | Expected Multiplier | Human Review Required |
|-----------|---------|---------------------|----------------------|
| **Boilerplate/Scaffolding** | ✅ Use freely | 2-4x faster | ⚠️ Light review |
| **API Routes** | ✅ Use freely | 1.5-2x faster | ⚠️ Light review |
| **Database Migrations** | ✅ Use carefully | 1.5x faster | ✅ Mandatory |
| **Configuration Files** | ✅ Use freely | 2-3x faster | ⚠️ Light review |
| **Unit Tests** | ✅ Use freely | 1.5-2x faster | ⚠️ Verify edge cases |
| **Documentation** | ✅ Use freely | 2-3x faster | ⚠️ Light review |
| **Business Logic** | ⚠️ Use with caution | 1.2-1.4x faster | ✅ Mandatory |
| **Authentication** | ❌ Human-led, AI assist | 1.1x faster | ✅ Security review |
| **Multi-Tenant RLS** | ❌ Human-led, AI assist | 1.0x (no benefit) | ✅ Security review |
| **Kafka Schemas** | ❌ Human-led, AI assist | 1.1x faster | ✅ Architecture review |
| **Complex Debugging** | ❌ Minimal benefit | 0.8-1.0x | ✅ Senior dev only |
| **Architecture Decisions** | ❌ Human only | N/A | N/A |

**Legend:**
- ✅ Use freely: Generate with AI, light human review
- ⚠️ Use with caution: AI generates draft, thorough human review
- ❌ Human-led: Human designs, AI assists with implementation

---

## Event Schema Versioning Strategy

| Strategy | Backward Compat | Forward Compat | Complexity | Recommended |
|----------|----------------|----------------|------------|-------------|
| **Semantic Versioning in Topic** | ❌ No | ❌ No | ⭐ | ❌ Avoid |
| **Schema Registry + Avro** | ✅ Yes | ✅ Yes | ⭐⭐⭐ | ✅ Recommended |
| **JSON Schema in Header** | ⚠️ Manual | ⚠️ Manual | ⭐⭐ | ⚠️ Acceptable |
| **Protobuf** | ✅ Yes | ✅ Yes | ⭐⭐⭐⭐ | ✅ Alternative |

**DECISION: Schema Registry (Confluent) + JSON Schema** ✅
- Centralized schema management
- Automatic compatibility checking
- Schema evolution support
- JSON (not Avro) for simplicity during early development
- Migrate to Avro if performance becomes critical

**Implementation:**
```json
{
  "schema_version": "1.0.0",
  "event_type": "prd.created",
  "tenant_id": "uuid",
  "payload": { ... }
}
```

---

## Database Query Optimization Priority

| Optimization | Impact | Effort | Priority | When to Apply |
|--------------|--------|--------|----------|---------------|
| **Indexes on tenant_id** | ⭐⭐⭐⭐⭐ | ⭐ | 🔴 Critical | Day 1, every table |
| **Composite indexes** | ⭐⭐⭐⭐ | ⭐⭐ | 🟡 High | Sprint 2+ |
| **Connection pooling** | ⭐⭐⭐⭐ | ⭐ | 🔴 Critical | Day 1 |
| **Query result caching** | ⭐⭐⭐ | ⭐⭐⭐ | 🟢 Medium | Sprint 5+ |
| **Read replicas** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 🟢 Medium | Sprint 10+ (if needed) |
| **Partitioning by tenant** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 🔵 Low | Sprint 15+ (if 1000+ tenants) |

**Critical Day 1 Requirements:**
```sql
-- Always create index on tenant_id
CREATE INDEX idx_tablename_tenant_id ON tablename(tenant_id);

-- Composite indexes for common queries
CREATE INDEX idx_users_tenant_email ON users(tenant_id, email);
```

**Connection Pool Configuration:**
```javascript
const pool = new Pool({
  max: 20,  // Per microservice
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

---

## Observability Stack Selection

| Component | Tool | Why | Alternative |
|-----------|------|-----|-------------|
| **Metrics** | Prometheus + Grafana | ✅ Industry standard, free | Datadog ($$$) |
| **Logging** | Loki | ✅ Grafana integration | ELK Stack (heavy) |
| **Tracing** | Jaeger | ✅ OpenTelemetry compatible | Zipkin, Datadog |
| **APM** | Grafana Stack | ✅ Free, integrated | New Relic, Datadog |
| **Error Tracking** | Sentry | ✅ Best-in-class, affordable | Rollbar |

**DECISION: Grafana Stack (Prometheus + Loki + Tempo)** ✅
- Single UI for metrics, logs, and traces
- Open source and free
- Kubernetes-native
- Large community

**Add Sentry** for production error tracking (affordable, excellent DX)

---

## Service Communication Pattern

| Pattern | Latency | Coupling | Complexity | Use Case |
|---------|---------|----------|------------|----------|
| **Synchronous (HTTP/gRPC)** | ⚠️ Higher | ❌ Tight | ⭐ | Real-time queries, low traffic |
| **Asynchronous (Kafka)** | ✅ Lower | ✅ Loose | ⭐⭐⭐ | Event notifications, high traffic |
| **Request-Reply over Kafka** | ⚠️ Higher | ⭐⭐⭐ | ⭐⭐⭐⭐ | Avoid if possible |

**DECISION:**
- **Query operations:** Synchronous HTTP (e.g., "Get user profile")
- **Commands & Events:** Asynchronous Kafka (e.g., "PRD created")
- **Service-to-Service:** gRPC for low latency (if needed)

**Example:**
```
Frontend → Kong → User Service (HTTP GET)
                     ↓
                 Kafka: user.created
                     ↓
              Analytics Service (async processing)
```

---

## Testing Strategy by Layer

| Layer | Tool | Coverage Target | AI Assistance |
|-------|------|----------------|---------------|
| **Unit Tests** | Jest/Vitest | 80%+ | ✅ AI generates |
| **Integration Tests** | Testcontainers | 70%+ critical paths | ⚠️ AI assists |
| **Multi-Tenant Tests** | Custom fixtures | 100% endpoints | ❌ Human writes |
| **E2E Tests** | Playwright/Cypress | 50% user journeys | ⚠️ AI assists |
| **Load Tests** | k6 | Key endpoints | ⚠️ AI assists |
| **Chaos Tests** | Chaos Mesh | Critical services | ❌ Human designs |

**Critical Multi-Tenant Test Pattern:**
```javascript
describe('Tenant Isolation', () => {
  it('Tenant A cannot access Tenant B data', async () => {
    const userA = await createUser({ tenantId: 'tenant-a' });
    const usersB = await fetchUsersWithTenant('tenant-b');

    expect(usersB).not.toContainEqual(userA);
  });
});
```

**Coverage Gates:**
- Unit tests: 80% required for merge
- Integration tests: All API endpoints
- Multi-tenant tests: 100% data access paths

---

## Deployment Strategy

| Strategy | Risk | Speed | Rollback | Use Case |
|----------|------|-------|----------|----------|
| **Recreate** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Dev only |
| **Rolling Update** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Staging |
| **Blue/Green** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Production (low traffic) |
| **Canary** | ⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | Production (high traffic) |

**DECISION:**
- **Dev:** Recreate (fast feedback)
- **Staging:** Rolling update (mirrors production process)
- **Production:** Canary (10% → 50% → 100% over 1 hour)

**Argo CD Configuration:**
```yaml
spec:
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {duration: 10m}
      - setWeight: 50
      - pause: {duration: 20m}
      - setWeight: 100
```

---

## Cost Optimization Priority

| Optimization | Savings Potential | Effort | Priority |
|--------------|------------------|--------|----------|
| **Right-size pods (requests/limits)** | ⭐⭐⭐⭐ | ⭐ | 🔴 Critical |
| **HPA (auto-scaling)** | ⭐⭐⭐⭐⭐ | ⭐⭐ | 🔴 Critical |
| **Cluster autoscaling** | ⭐⭐⭐⭐ | ⭐⭐ | 🔴 Critical |
| **LLM semantic caching** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 🟡 High |
| **Spot instances** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 🟢 Medium |
| **Reserved instances** | ⭐⭐⭐ | ⭐ | 🟢 Medium |

**Day 1 Actions:**
1. Set resource requests/limits on all pods
2. Configure HPA for all services (min 2, max 10)
3. Enable cluster autoscaling
4. Monitor and adjust after 2 weeks

**Sprint 5+ Actions:**
1. Implement semantic caching for LLM calls (can save 30-50% token costs)
2. Evaluate spot instances for non-critical workloads
3. Consider reserved instances after 3 months (predictable baseline)

---

## Security Checklist (Pre-Production)

| Item | Critical | Tool/Method | Status |
|------|----------|-------------|--------|
| **Image scanning** | ✅ | Trivy | ☐ |
| **Secret scanning** | ✅ | Git pre-commit hook | ☐ |
| **RLS policies on all tables** | ✅ | Manual review | ☐ |
| **Network policies** | ✅ | Kubernetes manifests | ☐ |
| **RBAC configured** | ✅ | Kubernetes RBAC | ☐ |
| **Pod security standards** | ✅ | Restricted profile | ☐ |
| **Encryption at rest** | ✅ | AWS KMS | ☐ |
| **Encryption in transit** | ✅ | Linkerd mTLS | ☐ |
| **Rate limiting** | ✅ | Kong | ☐ |
| **Tenant isolation tests** | ✅ | Automated tests | ☐ |
| **Vulnerability patching process** | ✅ | Dependabot + Renovate | ☐ |
| **Incident response plan** | ✅ | Runbook | ☐ |

**Pre-Production Gate:** ALL items must be checked before production deployment

---

## Decision Log Template

When making architecture decisions not covered above:

```markdown
## Decision: [Title]

**Date:** YYYY-MM-DD
**Status:** Proposed / Accepted / Deprecated
**Deciders:** [Names]

### Context
[What is the issue we're facing?]

### Options Considered
1. Option A
2. Option B
3. Option C

### Decision
[Chosen option with rationale]

### Consequences
**Positive:**
- ...

**Negative:**
- ...

**Risks:**
- ...

**Mitigation:**
- ...
```

---

**Document Version:** 1.0
**Last Updated:** October 10, 2025
**Review Frequency:** After each major milestone (every 4 sprints)
