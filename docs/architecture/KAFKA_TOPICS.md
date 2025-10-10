# Kafka Topics Registry

**Canonical Source of Truth for Event-Driven Architecture**

This document defines all Kafka topics used across the 17-microservice platform. All services MUST reference this registry for topic names, schemas, and integration patterns.

**Last Updated:** 2025-10-10
**Total Active Topics:** 23

---

## Topic Naming Convention

- **`{domain}_events`**: General event streams (e.g., `auth_events`, `prd_events`)
- **`{domain}_incidents`**: Problem/alert streams (e.g., `monitoring_incidents`)
- **`{domain}_experiments`**: A/B testing streams (e.g., `analytics_experiments`)

---

## Active Kafka Topics

### Foundation & Identity (Service 0)

#### 1. **auth_events**
- **Producer:** Service 0 (Organization & Identity Management)
- **Consumers:** Services 1 (Research Engine), 2 (Demo Generator), 21 (Agent Copilot)
- **Purpose:** User authentication and account lifecycle tracking
- **Key Events:** `user_signed_up`, `email_verified`, `user_logged_in`, `password_reset`, `assisted_account_created`, `assisted_account_claimed`, `claim_link_sent`, `claim_link_resent`, `assisted_account_expired`, `assisted_account_access_granted`, `account_ownership_transferred`
- **Schema:** TBD (implementation phase)

#### 2. **agent_events**
- **Producer:** Service 0 (Organization & Identity Management)
- **Consumers:** Services 13 (Customer Success), 21 (Agent Copilot)
- **Purpose:** Human agent lifecycle management - assignments, handoffs, status changes, specialist invitations
- **Key Events:** `agent_registered`, `client_assigned_to_agent`, `handoff_initiated`, `handoff_accepted`, `handoff_rejected`, `specialist_invited`, `specialist_joined`, `specialist_handoff_back`, `agent_status_updated`, `agent_availability_changed`, `workload_redistributed`
- **Schema:** TBD (implementation phase)

#### 3. **org_events**
- **Producer:** Service 0 (Organization & Identity Management)
- **Consumers:** Service 21 (Agent Copilot)
- **Purpose:** Organization-level management events
- **Key Events:** `organization_created`, `member_invited`, `member_joined`, `member_removed`, `role_updated`, `config_permissions_updated`
- **Schema:** TBD (implementation phase)

#### 4. **client_events**
- **Producer:** Service 0 (Organization & Identity Management)
- **Consumers:** Multiple services (Services 1, 2, 3, 6, 13, 21)
- **Purpose:** Client profile and business lifecycle tracking
- **Key Events:** `client_created`, `client_updated`, `research_completed`, `nda_signed`, `pilot_agreed`, `requirements_validation_completed`
- **Schema:** TBD (implementation phase)

---

### Pre-Sales & Revenue (Services 1-3, 22)

#### 5. **research_events**
- **Producer:** Service 1 (Research Engine)
- **Consumers:** Services 2 (Demo Generator), 21 (Agent Copilot)
- **Purpose:** Research data collection and analysis workflow
- **Key Events:** `research_started`, `research_completed`, `research_failed`
- **Schema:** TBD (implementation phase)

#### 6. **demo_events**
- **Producer:** Service 2 (Demo Generator)
- **Consumers:** Services 3 (Sales Document Generator), 21 (Agent Copilot)
- **Purpose:** Demo generation and approval workflow tracking
- **Key Events:** `demo_created`, `demo_completed`, `demo_generated`, `demo_approved`, `demo_failed`, `client_agreed_pilot`
- **Schema:** TBD (implementation phase)

#### 7. **sales_doc_events**
- **Producer:** Service 3 (Sales Document Generator)
- **Consumers:** Services 6 (PRD Builder), 22 (Billing), 21 (Agent Copilot)
- **Purpose:** Unified sales document workflow (NDA, pricing, proposal)
- **Key Events:** `nda_signed`, `nda_fully_signed`, `pricing_sent`, `proposal_accepted`, `proposal_signed`
- **Note:** Consolidated topic replacing deprecated `nda_events`, `pricing_events`, `proposal_events`
- **Schema:** TBD (implementation phase)

#### 8. **billing_events**
- **Producer:** Service 22 (Billing & Revenue Management)
- **Consumers:** Services 8 (Agent Orchestration), 9 (Voice Agent), 13 (Customer Success), 20 (Communication & Hyperpersonalization), 21 (Agent Copilot)
- **Purpose:** Payment processing, subscription management, dunning automation
- **Key Events:** `payment_succeeded`, `payment_failed`, `subscription_updated`
- **Schema:** TBD (implementation phase)

---

### Implementation & Configuration (Services 6-7)

#### 9. **prd_events**
- **Producer:** Service 6 (PRD Builder & Configuration Workspace)
- **Consumers:** Services 7 (Automation Engine), 21 (Agent Copilot)
- **Purpose:** PRD creation, approval, and modification tracking
- **Key Events:** `prd_created`, `prd_approved`, `prd_updated`, `prd_feedback_received`, `feedback_received`, `flow_modification_requested`, `dependency_completed`
- **Schema:** TBD (implementation phase)

#### 10. **collaboration_events**
- **Producer:** Service 6 (PRD Builder & Configuration Workspace)
- **Consumers:** Service 21 (Agent Copilot)
- **Purpose:** Real-time human-AI collaboration during PRD sessions
- **Key Events:** `help_requested`, `agent_joined_session`, `canvas_edited`, `collaboration_ended`
- **Schema:** TBD (implementation phase)

#### 11. **config_events**
- **Producer:** Services 7 (Automation Engine), 6 (PRD Builder for client self-service)
- **Consumers:** Services 8 (Agent Orchestration), 9 (Voice Agent), 21 (Agent Copilot)
- **Purpose:** JSON configuration deployment, updates, hot-reload triggers
- **Key Events:** `config_generation_started`, `config_deployed`, `config_failed`, `config_updated`, `config_updated_by_client`, `config_rollback`, `hot_reload_required`, `config_version_compared`, `config_preview_generated`, `config_branch_created`, `tool_attached_to_config`, `credential_created`, `credential_rotated`, `credential_deleted`
- **Schema:** TBD (implementation phase)

---

### Runtime Services (Services 8-9, 17)

#### 12. **conversation_events**
- **Producer:** Services 8 (Agent Orchestration), 9 (Voice Agent)
- **Consumers:** Services 11 (Monitoring Engine), 12 (Analytics), 20 (Communication & Hyperpersonalization), 21 (Agent Copilot)
- **Purpose:** Chatbot and voicebot interaction tracking
- **Key Events:** `conversation_started`, `conversation_escalated`, `conversation_completed`, `escalation_requested`
- **Schema:** TBD (implementation phase)

#### 13. **voice_events**
- **Producer:** Service 9 (Voice Agent)
- **Consumers:** Services 11 (Monitoring Engine), 12 (Analytics), 21 (Agent Copilot)
- **Purpose:** Voice call lifecycle tracking
- **Key Events:** `call_initiated`, `call_completed`, `call_transferred`, `call_ended`, `voicemail_left`
- **Schema:** TBD (implementation phase)

#### 14. **cross_product_events**
- **Producer:** Services 8 (Agent Orchestration), 9 (Voice Agent)
- **Consumers:** Services 8, 9, 21 (Agent Copilot)
- **Purpose:** Coordination between chatbot and voicebot products (e.g., image processing during voice call)
- **Key Events:** `voicebot_paused`, `chatbot_paused`, `image_processed`, `data_shared`, `product_switched`, `cross_product_image_processed`, `chatbot_image_processed`, `voicebot_session_ended`
- **Schema:** TBD (implementation phase)

#### 15. **rag_events**
- **Producer:** Service 17 (RAG Pipeline)
- **Consumers:** Services 8 (Agent Orchestration), 9 (Voice Agent)
- **Purpose:** Document ingestion and FAQ management for knowledge base
- **Key Events:** `continuous_sync_started`, `faq_created`
- **Schema:** TBD (implementation phase)

---

### Monitoring & Analytics (Services 11-12)

#### 16. **monitoring_incidents**
- **Producer:** Service 11 (Monitoring Engine)
- **Consumers:** Services 13 (Customer Success), 21 (Agent Copilot)
- **Purpose:** Real-time system health, anomaly detection, incident management
- **Key Events:** `incident_created`, `incident_resolved`, `incidents_created`, `incidents_resolved`
- **Schema:** TBD (implementation phase)

#### 17. **analytics_experiments**
- **Producer:** Service 12 (Analytics)
- **Consumers:** Services 8 (Agent Orchestration), 9 (Voice Agent), 20 (Communication & Hyperpersonalization), 21 (Agent Copilot)
- **Purpose:** A/B testing and experimentation tracking
- **Key Events:** `experiment_started`, `experiment_completed`, `experiments_completed`
- **Schema:** TBD (implementation phase)

---

### Customer Lifecycle (Services 13-14)

#### 18. **customer_success_events**
- **Producer:** Service 13 (Customer Success Service)
- **Consumers:** Services 20 (Communication & Hyperpersonalization), 21 (Agent Copilot)
- **Purpose:** Customer health tracking, lifecycle messaging, upsell opportunities
- **Key Events:** `health_score_changed`, `playbook_triggered`, `qbr_completed`
- **Schema:** TBD (implementation phase)

#### 19. **support_events**
- **Producer:** Service 14 (Support Engine)
- **Consumers:** Services 13 (Customer Success), 21 (Agent Copilot)
- **Purpose:** Support ticket lifecycle management
- **Key Events:** `ticket_created`, `ticket_resolved`, `ticket_escalated`
- **Schema:** TBD (implementation phase)

#### 20. **escalation_events**
- **Producer:** Service 14 (Support Engine)
- **Consumers:** Services 0 (Organization & Identity Management), 21 (Agent Copilot)
- **Purpose:** Human escalation workflow tracking
- **Key Events:** `escalation_created`, `escalation_resolved`, `conversation_escalated`, `human_handoff_triggered`
- **Schema:** TBD (implementation phase)

---

### Client Operations (Service 20-21)

#### 21. **communication_events**
- **Producer:** Service 20 (Communication & Hyperpersonalization)
- **Consumers:** Services 8 (Agent Orchestration), 9 (Voice Agent), 21 (Agent Copilot)
- **Purpose:** Unified communication tracking (outreach + personalization)
- **Key Events:** `email_sent`, `email_opened`, `email_clicked`, `sms_delivered`, `manual_ticket_created`
- **Note:** Consolidated topic replacing deprecated `outreach_events` and `personalization_events`
- **Schema:** TBD (implementation phase)

#### 22. **agent_action_events**
- **Producer:** Service 21 (Agent Copilot)
- **Consumers:** TBD (implementation phase)
- **Purpose:** Track agent actions taken through the copilot system
- **Key Events:** TBD (implementation phase)
- **Schema:** TBD (implementation phase)

---

### CRM Integration (Service 15)

#### 23. **crm_events**
- **Producer:** Service 15 (CRM Integration)
- **Consumers:** Service 21 (Agent Copilot)
- **Purpose:** CRM synchronization tracking and activity logging across Salesforce, HubSpot, Zendesk
- **Key Events:**
  - `opportunity_created` - New opportunity created in CRM
  - `opportunity_updated` - Opportunity stage/amount/close date changed
  - `opportunity_closed_won` - Deal closed successfully
  - `opportunity_closed_lost` - Deal lost with reason
  - `contact_created` - New contact added to CRM
  - `contact_updated` - Contact information changed
  - `account_created` - New account/company created
  - `account_updated` - Account details changed
  - `activity_logged` - Call, email, meeting logged to CRM
  - `task_created` - Task/follow-up created for agent
  - `sync_completed` - Full CRM sync completed successfully
  - `sync_failed` - CRM sync failed with error details
  - `field_mapping_conflict` - Data conflict during sync requiring resolution
- **Use Cases:**
  - Real-time CRM status updates in Agent Copilot dashboard
  - Audit trail for all CRM modifications
  - Trigger workflows based on opportunity stage changes
  - Alert agents to sync failures or conflicts
  - Analytics on CRM activity patterns
- **Schema:** TBD (implementation phase)

---

## Deprecated Topics

These topics were consolidated during architecture optimization and should NOT be used:

### **nda_events** (DEPRECATED)
- **Status:** Consolidated into `sales_doc_events`
- **Reason:** Service 3 consolidation unified NDA/Pricing/Proposal workflows
- **Migration:** Use `sales_doc_events` with event types `nda_signed`, `nda_fully_signed`

### **pricing_events** (DEPRECATED)
- **Status:** Consolidated into `sales_doc_events`
- **Reason:** Service 3 consolidation unified NDA/Pricing/Proposal workflows
- **Migration:** Use `sales_doc_events` with event type `pricing_sent`

### **proposal_events** (DEPRECATED)
- **Status:** Consolidated into `sales_doc_events`
- **Reason:** Service 3 consolidation unified NDA/Pricing/Proposal workflows
- **Migration:** Use `sales_doc_events` with event types `proposal_accepted`, `proposal_signed`

### **outreach_events** (DEPRECATED)
- **Status:** Consolidated into `communication_events`
- **Reason:** Service 20 consolidation unified outreach and personalization
- **Migration:** Use `communication_events` for all outbound communication tracking

### **personalization_events** (DEPRECATED)
- **Status:** Consolidated into `communication_events`
- **Reason:** Service 20 consolidation unified outreach and personalization
- **Migration:** Use `communication_events` for hyperpersonalization tracking

---

## Event Schema Standards

### General Event Structure (All Topics)

```json
{
  "event_id": "uuid",
  "event_type": "string",
  "timestamp": "ISO 8601",
  "tenant_id": "uuid",
  "organization_id": "uuid",
  "source_service": "string",
  "version": "semver",
  "payload": {
    "...event-specific data..."
  },
  "metadata": {
    "correlation_id": "uuid",
    "causation_id": "uuid",
    "idempotency_key": "string"
  }
}
```

### Idempotency Requirements

- All event handlers MUST be idempotent
- Use `idempotency_key` in metadata for duplicate detection
- Store processed event IDs for at least 7 days
- Implement retry logic with exponential backoff

### Multi-Tenancy Requirements

- ALWAYS include `tenant_id` and `organization_id` in every event
- Never bypass tenant filtering in event handlers
- Use namespace isolation in consumers (Qdrant, Neo4j, Redis)

---

## Topic Configuration Standards

### Kafka Topic Settings

- **Partitions:** 10 (default, adjust based on throughput requirements)
- **Replication Factor:** 3 (production), 1 (development)
- **Retention:** 7 days (default), 30 days (audit topics)
- **Compression:** GZIP (balance between CPU and network)

### Consumer Group Naming

Format: `{service_name}_{topic_name}_consumer`

Example: `agent_orchestration_config_events_consumer`

---

## Service 21 (Agent Copilot) Topic Consumption Matrix

Service 21 aggregates **21 Kafka topics** for unified agent dashboard:

1. `auth_events` - User authentication tracking
2. `agent_events` - Human agent lifecycle management
3. `org_events` - Organization-level management
4. `client_events` - Client profile and lifecycle
5. `research_events` - Research workflow status
6. `demo_events` - Demo generation tracking
7. `sales_doc_events` - NDA/pricing/proposal status
8. `billing_events` - Payment and subscription status
9. `prd_events` - PRD creation and approval
10. `collaboration_events` - Real-time PRD collaboration
11. `config_events` - Configuration deployment tracking
12. `conversation_events` - Chatbot/voicebot interactions
13. `voice_events` - Voice call tracking
14. `cross_product_events` - Chatbot/voicebot coordination
15. `monitoring_incidents` - System health and incidents
16. `analytics_experiments` - A/B test results
17. `customer_success_events` - Health scores and lifecycle
18. `support_events` - Ticket management
19. `escalation_events` - Human escalation tracking
20. `communication_events` - Outreach and personalization
21. `crm_events` - CRM synchronization and activity tracking

---

## Future Topics (Under Consideration)

### **knowledge_events** (NOT YET IMPLEMENTED)
- **Proposed Producer:** Service 17 (RAG Pipeline) or Service 21 (Agent Copilot)
- **Proposed Consumers:** TBD
- **Purpose:** Village knowledge sharing across clients
- **Key Events:** TBD - `knowledge_contributed`, `pattern_identified`, `best_practice_shared`
- **Status:** Referenced in WORKFLOW.md but not documented in architecture specs
- **Decision Required:** Define producer, consumer, and event schemas

---

## Maintenance & Governance

### Adding New Topics

1. **Propose new topic** in architecture review meeting
2. **Document** in this registry with full producer/consumer/schema details
3. **Create Kafka topic** with standard configuration
4. **Update Service Index** to reflect new integrations
5. **Version event schemas** using semantic versioning

### Modifying Existing Topics

1. **Use backward-compatible changes only** (add optional fields, don't remove/rename)
2. **Version event schemas** when making breaking changes
3. **Update this registry** with schema version history
4. **Communicate changes** to all consumer teams
5. **Implement gradual rollout** with dual-write during migration

### Deprecating Topics

1. **Mark as deprecated** in this registry with migration path
2. **Communicate timeline** to all producer/consumer teams
3. **Monitor usage** to ensure safe removal
4. **Remove topic** only after 90-day deprecation period
5. **Archive event data** before deletion

---

## References

- **WORKFLOW.md**: Complete workflow documentation with topic usage patterns
- **MICROSERVICES_ARCHITECTURE*.md**: Technical architecture across 17 microservices
- **SERVICE_21_AGENT_COPILOT.md**: Agent Copilot integration details

---

**Document Owner:** Platform Architecture Team
**Review Frequency:** Monthly or when adding/deprecating topics
**Last Reviewed:** 2025-10-10
