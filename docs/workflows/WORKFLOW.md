# AI-Powered Workflow Automation Platform

## Overview

This platform automates the complete B2B SaaS client lifecycle from research to customer success, achieving 95% automation within 12 months through 17 microservices (16 core services + 2 supporting libraries: @workflow/config-sdk and @workflow/llm-sdk) orchestrated via Kafka event-driven architecture. The system supports both **Chatbot** (LangGraph) and **Voicebot** (LiveKit) products with YAML-driven configuration and hot-reload capabilities.

**Performance Benefits:** Service consolidation delivers 400-900ms faster workflows (3-service sales pipeline → 1-service, LLM gateway elimination saves 200-500ms per call, direct S3 config access saves 50-100ms).

**Target:** 60% automation (sales/onboarding) → 90% automation (support/success) → 80% client self-service

---

## Architecture Foundation

### 17 Microservices Across 6 Phases

**Foundation Service (0)**
- **Service 0: Organization & Identity Management** - Multi-tenant auth, user management, JWT tokens, agent orchestration, lifecycle handoffs, specialist routing

**Pre-Sales Services (1-3, 22)** - Research, Demo, Sales Document Generation, Billing & Revenue Management
**Implementation Services (6-7)** - PRD Builder & Configuration Workspace, Automation Engine (YAML generation)
**Runtime Services (8-9)** - Agent Orchestration (chatbot), Voice Agent (voicebot)
**Monitoring Services (11-12)** - Monitoring Engine, Analytics
**Customer Lifecycle (13-15)** - Customer Success, Support, CRM Integration
**Infrastructure (17)** - RAG Pipeline
**Client Operations (20, 21)** - Communication & Hyperpersonalization, Agent Copilot
**Supporting Services (22)** - Billing & Revenue Management

**Agent Productivity**
- **Service 21: Agent Copilot** - AI-powered context management and action planning for human agents (Sales, Onboarding, Support, Success). Unified dashboard aggregating 17 Kafka topics, AI action planning, communication drafting, approval orchestration, CRM auto-sync, village knowledge integration, performance tracking.

**Supporting Libraries**
- **@workflow/config-sdk** - Direct S3 config access library (replaces Service 10)
- **@workflow/llm-sdk** - Direct LLM integration library (replaces Service 16)

### Event-Driven Coordination (18 Kafka Topics)

- `auth_events`, `agent_events`, `org_events` - Foundation layer
- `research_events`, `demo_events`, `sales_doc_events`, `billing_events` - Pre-sales & revenue flow (unified NDA/Pricing/Proposal)
- `prd_events`, `voice_events`, `cross_product_events` - Implementation & runtime coordination
- `communication_events`, `escalation_events`, `collaboration_events` - Client engagement & optimization (unified outreach/personalization)
- `client_events`, `monitoring_events`, `analytics_events` - Operations & intelligence
- `support_events`, `success_events`, `customer_success_events`, `crm_events`, `knowledge_events` - Customer lifecycle

**Service 21 (Agent Copilot) consumes 17 of these topics** to provide real-time context aggregation for human agents across all lifecycle stages.

### Product Differentiation

| **Aspect** | **Chatbot** | **Voicebot** |
|------------|-------------|--------------|
| Framework | LangGraph (two-node: agent + tools) | LiveKit (VoicePipelineAgent, STT-LLM-TTS) |
| YAML Config | Includes `external_integrations` | NO `external_integrations`, includes voice params |
| Channels | Webchat, WhatsApp, SMS, Slack | Inbound/outbound calls via Twilio/Telnyx SIP |
| Latency Target | <2s P95 | <500ms P95 |
| Service | Agent Orchestration (Service 8) | Voice Agent (Service 9) |

**Cross-Product Coordination:** Voicebot active → Chatbot silent processing mode. Example: User uploads prescription image during voice call → Chatbot processes silently → Voicebot receives extracted data → Continues conversation with context.

---

## Phase 0: Human-Assisted Sales (40% Human Touch)

**Automation:** Research, demo generation, NDA/proposal creation, volume prediction
**Human:** Relationship building, negotiation, strategic decisions, requirements review

### Step 1: Organization Setup & Assignment

**Organization & Identity Management (Service 0) handles both account creation AND agent assignment:**

**Self-Signup Path:**
1. Client creates account via self-service portal
2. Service 0 auto-assigns to Sales agent (workload-balanced)
3. Research Engine (Service 1) runs automatically

**Assisted Signup Path:**
1. Sales agent creates account for client (high-touch enterprise deals)
2. Service 0 auto-assigns client to creating Sales agent
3. Research Engine runs automatically

### Step 2: Research & Requirements Validation

**Research Engine (Service 1)** performs multi-source data collection:
- **Primary Research:** Instagram, Facebook, TikTok, Google Maps, Google reviews scraping
- **Deep Research:** Reddit, industry forums, competitor analysis
- **Human Intelligence:** Sales agent talks to target customer's sales/support teams to identify loopholes (response quality, response time, work hours coverage)

**AI Analysis:**
- Volume prediction (expected conversation volume)
- Requirements draft generation based on research findings
- Business objectives identification

**Sales Agent Review:**
- Reviews AI-generated requirements draft
- Modifies based on insights from human intelligence gathering
- Sends requirements form to client for validation

**Client Validation:**
- Client reviews/corrects volumes and requirements
- Confirms business objectives
- Publishes `client_events.requirements_validation_completed` → Triggers demo generation

**Outreach Automation:**
- Communication & Hyperpersonalization Service (Service 20) sends requirements draft
- Tracks email opens, responses
- Creates manual outreach tickets for Sales agent if no response

### Step 3: Demo Generation & Presentation

**Demo Generator (Service 2)** creates demo based on validated requirements:
- Product type selection: chatbot or voicebot
- Mock data and mock tools generated
- Web UI demo with conversational flow
- Developer tests and fixes any issues

**Sales Agent:**
- Meets with client to showcase demo
- Gathers feedback and answers questions
- If client agrees to pilot → Initiates NDA workflow

### Step 4: Sales Document Generation (NDA, Pricing, Proposal)

**Sales Document Generator (Service 3) - Unified 150-300ms faster than separate services:**
- Generates templatized NDA based on client's business type
- Sends via AdobeSign or similar e-signature platform
- Fully-signed NDA publishes `sales_doc_events.nda_signed` → Triggers PRD session
- After PRD approval, generates pricing model and proposal in single workflow
- Unified template management and e-signature integration
- Publishes `sales_doc_events.proposal_signed` → Triggers automation engine

---

## Phase 1: Onboarding (40% Human Touch)

**Automation:** PRD AI cross-questioning, YAML config generation, GitHub ticket creation
**Human:** PRD supervision, architecture review, config validation, launch oversight

### Step 5: PRD Builder & Configuration Workspace with Village Knowledge

**PRD Builder & Configuration Workspace (Service 6)** - Conversational AI interface with integrated client self-service:

**Intelligent Cross-Questioning:**
- Asks about use cases and business objectives
- Brainstorms edge cases
- Takes KPIs from existing implementations for other clients
- Designs A/B flows based on objectives using data sources for personalization

**Village Knowledge Integration:**
- Learns from multi-client implementations
- Suggests objectives clients didn't ask for (cross-sell, upsell, rapport building for support)
- Offers new revenue centers and cost-saving opportunities
- Examples: "Based on 15 healthcare chatbots we've deployed, adding appointment reminder follow-ups increased show-up rates by 23%"

**Integration Planning:**
- When to escalate to human
- Works alongside humans vs. independently
- Ecosystem tool integration (CRM, ticketing systems)
- What tickets at what triggers should be created

**A/B Flow Design:**
- For each objective, designs 2-3 A/B flows
- Defines KPIs for each flow
- Baseline determination: Reality check of available data (client's existing data + what they're willing to share)
- Log events to track uptime across whole flow

**Human Agent Collaboration:**
- Onboarding Specialist can request PRD help via shareable code
- Conversational AI joins collaboration session
- Human can override AI suggestions
- Publishes `collaboration_events` for real-time coordination

**Sprint Planning:**
- Sprint-by-sprint roadmap with 95% automation goal in 12 months
- Defines: 1) What AI platform team automates, 2) Where humans tie shoelaces, 3) Where platform engineers handle critical bugs/downtime

**PRD Approval:**
- Iterative feedback loop until client and onboarding team satisfied
- PRD approved → Publishes `prd_events.prd_approved` → Triggers Sales Document Generator (Service 3) for pricing & proposal

**Note:** Service 6 now includes client configuration portal functionality, enabling clients to manage configs post-deployment through the same conversational interface used during PRD creation.

### Step 6: YAML Config Generation & Tool Orchestration

**Automation Engine (Service 7)** - Webchat UI interface:

**YAML Config Generation:**
- Takes approved PRD as input
- Generates YAML config with:
  - `product_type`: `chatbot` or `voicebot`
  - `system_prompt`: Use case-specific instructions
  - `tools`: List of required tools (available + missing)
  - `external_integrations`: Salesforce, Zendesk, Stripe (chatbot only)
  - `voice_parameters`: Speed, clarity, background sound (voicebot only)
  - `escalation_rules`: When to transfer to human
  - `organization_id`, `config_id`: Multi-tenant isolation

**GitHub Ticket Creation:**
- For missing tools: Auto-creates GitHub issue with `tool_name`, `input`, `output`, metadata
- For missing integrations: Auto-creates GitHub issue with integration details
- Developer manually implements → Merges → Auto-attaches to YAML config via `config_id`
- Services use @workflow/config-sdk library for direct S3 config access (50-100ms faster than service-based approach)

**Canvas Editing:**
- Right-side canvas shows generated YAML
- Editable via chat feedback or manual editing
- Version control with Git-style commits

**Onboarding Specialist Review:**
- Validates technical architecture
- Reviews config for security and performance
- Approves deployment to production

### Step 7: Deployment & Handoff

**Configuration Deployment (@workflow/config-sdk library):**
- Services access YAML configs directly from S3 (versioned) using @workflow/config-sdk
- Configs cached in Redis for fast retrieval (50-100ms faster than service-based routing)
- Config updates propagated via Kafka `config_events` (<2s latency)
- Agent Orchestration (chatbot) or Voice Agent (voicebot) loads config directly

**Onboarding → Support + Success Handoff (Service 0):**
- Onboarding Specialist creates DUAL handoff (parallel assignment) via Service 0
- Context notes, client preferences, technical requirements included
- Support Specialist + Success Manager accept handoff
- Onboarding assignment marked 'completed'
- Confirmation emails sent to client via Service 20

---

## Phase 2: Support (10% Human Touch)

**Automation:** 90% ticket resolution, config application, SLA tracking
**Human:** Complex escalations, edge cases, quality supervision

### Automated Support

**Support Engine (Service 14):**
- Deployed chatbot/voicebot handles 90% of tickets autonomously
- Ticket management with SLA enforcement
- Escalation routing for complex queries
- Human Support Specialist coordination

**Hot-Reload for New Tools:**
- Developer finishes tool implementation → Merges to main
- Automation Engine publishes `config_events.config_updated` with `hot_reload_required: true`
- Services using @workflow/config-sdk detect config update via Redis cache invalidation
- Active conversations use pinned config version (NO mid-conversation disruption)
- NEW conversations immediately use latest config with new tool (50-100ms faster config load)
- Support Specialist monitors rollout, tests new tool functionality

**Monitoring & Escalation:**
- Monitoring Engine (Service 11) tracks SLAs, auto-escalates violations
- High error rate or low success rate → Auto-rollback trigger
- Alert Platform engineer → Create RCA → Implement mitigation

### Human Escalation Workflow

**Escalation Triggers:**
- AI confidence below threshold
- Explicit user request ("I want to talk to a human")
- SLA violation detected
- Complex query not documented in support matrix

**Support Specialist Actions:**
- Reviews ticket context (transcript, previous interactions)
- Takes over conversation or provides guidance to AI
- Documents resolution for future AI training
- Updates support matrix if new pattern identified

---

## Phase 3: Success (10% Human Touch)

**Automation:** 90% daily monitoring, health scores, lifecycle messaging, upsell detection
**Human:** QBRs, strategic opportunities, renewal negotiation

### Automated Customer Success

**Customer Success Service (Service 13):**

**Lifecycle Stage Tracking:**
- Trial (0-14 days), Active, At-Risk, Renewal Approaching, Churned
- Automated transitions based on engagement metrics

**Health Score Calculation:**
- Daily KPI monitoring (conversation volume, resolution rate, user satisfaction)
- Engagement metrics (logins, feature usage, API calls)
- Support ticket frequency and complexity
- Calculates health score: 0-100 (red <60, yellow 60-80, green >80)

**Automated Lifecycle Messaging:**
- Trial Day 1: Enthusiastic welcome, quick wins, template exploration CTA
- Trial Day 7: Encouraging, success stories, demo call CTA
- Trial Day 13: Urgent, conversion-focused, upgrade CTA
- Active Month 6: ROI check-in, advanced features highlight
- Active Month 11: Renewal preparation, case studies, contract review CTA

**Upsell Opportunity Detection:**
- High usage patterns → Premium tier suggestion
- Multiple escalations to human → Voice addon recommendation
- Specific feature requests → Custom integration opportunity

### Human Success Management

**Success Manager Actions:**

**Quarterly Business Reviews (QBRs):**
- Customer Success Engine auto-generates PPT with:
  - KPI dashboards (baseline vs. current performance)
  - A/B test results and optimizations implemented
  - Conversation analytics and user behavior insights
  - ROI calculation and cost savings
  - Recommendations for next quarter
- Success Manager reviews, customizes for client context
- Conducts QBR meeting, discusses strategic opportunities

**Specialist Invitation Workflow:**
- Success Manager identifies upsell opportunity
- Creates specialist invitation with opportunity type, reason, context
- Sales Specialist accepts → Temporary assignment
- Specialist completes work → Logs outcome (deal closed, revenue) → Assignment ends
- Returns to Success Manager for ongoing lifecycle management

**Village Knowledge Sharing:**
- Analytics Service (Service 12) identifies patterns across multiple clients
- Success Manager uses insights from one client to help others
- Example: "Client A's rapport-building script increased cross-sell by 18%, recommend testing for Client B"

---

## Phase 4: Upsell/Iteration

**Trigger:** Success Manager or client requests new features/products

### Iteration Workflow

1. **Success Manager identifies need:** Voice addon, premium tier, custom integration, new use case
2. **Invites Sales Specialist:** Temporary assignment for upsell/cross-sell
3. **New PRD session:** Sales Specialist works with client to define new requirements
4. **Back to Phase 1:** Onboarding workflow for new product/features
5. **Specialist exits:** Logs outcome, returns client to Success Manager
6. **Dual product coordination:** If both chatbot + voicebot active → Cross-product events enable seamless data sharing

---

## Phase 5: Client Self-Service (80% Autonomy Target)

**Automation:** Config classification, preview generation, low-risk changes, rollback
**Human:** Complex config requests, high-risk approvals, tool development

**Note:** Client configuration portal functionality is now integrated into Service 6 (PRD Builder & Configuration Workspace), providing a unified conversational interface for both PRD creation and ongoing config management.

### PRD Builder & Configuration Workspace (Service 6) - Client Self-Service

**Conversational Config Agent:**
- LangGraph two-node workflow (agent + tools)
- Client requests change via chat: "Make the bot more concise" or "Add Salesforce integration"
- AI classifies change type: `system_prompt`, `tool`, `voice_param`, `integration`, `escalation_rule`
- Confidence threshold 0.85-0.92 depending on change type
- Risk level assessment: low (auto-approved), medium (requires review), high (requires admin approval)

**Visual Configuration Dashboard:**

**Chatbot-Specific Controls:**
- System prompt editor with AI-assisted writing
- Tool library (enable/disable tools, search available tools)
- External integrations (Salesforce, Zendesk, Stripe connectors)
- Escalation rule builder (triggers, actions, conditions)

**Voicebot-Specific Controls:**
- **Voice Parameters:** Speed slider (0.5x-2.0x), clarity/similarity (0-1), style exaggeration (0-1), background sound selector
- **Model Settings:** GPT-4/GPT-3.5/Claude selection, optimize streaming latency (0-4), speaker boost toggle, max tokens (50-500)
- **Stop Speaking Plan:** Interruption detection words (1-10), voice seconds threshold (0.1-2.0s), back off seconds (1-5s)
- **Input Configuration:** Min characters before processing (5-50), punctuation boundaries

**Configuration Preview & Testing:**
- Sandbox environment (1-hour expiry)
- WebSocket preview sessions: `wss://sandbox.workflow.ai/preview/{preview_id}`
- Test scenario execution with sample conversations
- Visual preview before applying to production
- Approve → Publishes `config_events.client_config_change_applied` → Hot-reload

**Version Control & Rollback:**
- Git-style versioning with commit messages
- Side-by-side diff viewer
- One-click rollback to previous version
- Branch management (dev/staging/prod)
- Version history retention: 1 year minimum

**Member Permission Matrix:**
- **Admin:** Full config access, high-risk approvals, member permissions management
- **Config Manager:** Low/medium risk changes, cannot approve high-risk
- **Viewer:** Read-only access to configs and version history
- **Developer:** Request new tools via GitHub ticket, test configs in sandbox

**Risk-Based Approval Workflows:**
- **Low Risk** (system prompt tweaks, voice params): Auto-approved, instant hot-reload
- **Medium Risk** (tool changes, escalation rules): Config Manager or Admin approval required
- **High Risk** (integration changes, credential rotation): Admin approval + platform engineer review

**Human Agent Escalation:**
- Complex config requests → "Create support ticket" button
- Agent assistance chat interface for real-time collaboration
- Missing tool detected → "Request tool development" → GitHub issue auto-created

### Hot-Reload Strategy

**Active Conversation Handling (CRITICAL):**
- **NEVER** hot-reload mid-conversation (breaks context, confuses users)
- Pin config version at conversation start
- Wait for conversation end OR explicit user restart
- NEW conversations immediately use latest config
- Exception: Critical security fixes → Force reload with user notification

**Kafka Event Flow:**
1. PRD Builder & Configuration Workspace (Service 6) publishes `config_events.client_config_change_applied`
2. @workflow/config-sdk library updates S3 + invalidates Redis cache (<1s, 50-100ms faster)
3. Agent Orchestration (chatbot) or Voice Agent (voicebot) detects cache invalidation
4. Active conversations continue with pinned version
5. New conversations load latest version directly from S3 via @workflow/config-sdk

**Rollback Triggers:**
- Client-initiated rollback via portal
- Monitoring Engine detects degradation (high error rate, low success rate, SLA violations)
- Auto-rollback event published → Hot-reload to previous version
- Alert platform engineer → Investigate issue

---

## Phase 6: Hyperpersonalization (Continuous Optimization)

**Goal:** 30% improvement in engagement, 25% increase in conversions, 15% churn reduction

### Communication & Hyperpersonalization Service (Service 20)

**Unified Communication & Personalization:**
- Handles ALL outbound communication (requirements forms, follow-ups, transactional emails)
- Integrates hyperpersonalization for dynamic response optimization
- Consolidates former Service 18 (Outbound Communication) functionality

**Customer Cohort Segmentation:**
- **New Trial Users** (0-14 days): Educational nurture, feature exploration
- **Active Power Users** (>1000 conversations/month): Upsell premium features, efficiency focus
- **At-Risk Churners** (declining engagement, 2+ support tickets): Retention intervention, value reinforcement
- **Renewal Approaching** (0-30 days until renewal): Renewal value reinforcement, success stories

**Dynamic Response Personalization:**
- **System Prompt Overrides:** Per-cohort tone, focus, keywords
  - New users: "enthusiastic guide", educational, patient, proactive tips
  - Power users: "efficient expert", concise, technical, API-focused
  - At-risk: "empathetic problem-solver", value-driven, success stories
- **Response Templates:** Greeting, feature highlights, CTAs customized per cohort
- **Content Injection:** Show examples (new users), usage stats (power users), success metrics (at-risk)

**Multi-Armed Bandit Experimentation (Thompson Sampling):**
- **50-100 variants** tested simultaneously per cohort
- **Metrics tracked:** Click-through rate (CTR), conversion rate, session duration, feature adoption
- **Auto-optimization:** Variant weights updated in real-time based on performance
  - Example: "educational_helpful" variant: 0.789 conversion rate → weight increased from 0.25 to 0.38
  - Example: "professional_direct" variant: 0.666 conversion rate → weight decreased from 0.25 to 0.18
- **Statistical significance:** Min sample size 1000 per variant, 95% confidence level
- **Auto-promote winner:** Winning variant becomes default when significance reached

**Engagement Event Tracking:**
- Real-time feedback loop: Events → Update variant weights → Assign next user to best-performing variant
- Experiment performance dashboards for analytics
- Publishes `communication_events` for coordination (unified topic for outreach + personalization)

**Integration with Runtime Services:**
- Agent Orchestration (chatbot) fetches cohort context before response generation
- Voice Agent (voicebot) applies cohort-specific voice parameters and messaging
- Personalization decision latency: <50ms (must not impact conversation response time)

---

## Technical Architecture Deep Dive

### LangGraph Two-Node Workflow (Chatbot)

**Agent Orchestration Service (Service 8):**

**Standard Pattern:**
- **Agent Node:** LLM reasoning, tool selection, response generation
- **Tools Node:** Tool execution, integration calls, database operations
- Reference: https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/

**YAML-Driven Configuration:**
- `system_prompt`: Dynamic per use case
- `tools`: List of available tools (e.g., `fetch_user_flight_information`, `search_flights`, `book_car_rental`)
- `external_integrations`: Salesforce, Zendesk, Stripe, HubSpot (chatbot-specific)
- `escalation_rules`: When to transfer to human agent

**State Management:**
- StateGraph with PostgreSQL checkpointing (Supabase)
- Conversation state persisted for fault tolerance
- Strict TypedDict/Pydantic models for state typing

**Multi-Tenancy:**
- Row-Level Security (RLS): ALWAYS filter by `tenant_id` in PostgreSQL queries
- Namespace isolation in Qdrant (vector DB), Neo4j (graph DB)
- Never bypass tenant filtering, even for admin operations

### LiveKit Voice Agent Workflow (Voicebot)

**Voice Agent Service (Service 9):**

**VoicePipelineAgent Architecture:**
- **STT (Speech-to-Text):** Deepgram (primary), fallback to Whisper
- **LLM:** GPT-4/GPT-3.5/Claude via @workflow/llm-sdk library (200-500ms faster per call, no gateway hop)
- **TTS (Text-to-Speech):** ElevenLabs (primary), fallback to Google TTS
- Reference codebase: ../kishna_diagnostics/services/voice

**SIP Integration:**
- Twilio (primary) for inbound/outbound PSTN calls
- Telnyx (failover) for redundancy
- Call routing, recording, transfer to human

**YAML-Driven Configuration:**
- `system_prompt`: Voice-optimized instructions
- `tools`: Voice-specific tools (NO external integrations in YAML)
- `voice_parameters`: Speed, clarity, style exaggeration, background sound
- `stop_speaking_plan`: Interruption detection configuration

**Latency Optimization:**
- Target: <500ms P95 for voice responses
- Streaming TTS for faster perceived latency
- Predictive LLM response generation (start TTS before full response)
- Connection pooling for STT/TTS providers

**LiveKit Room State:**
- Real-time room state management
- Redis for session state caching
- Participant tracking, audio quality monitoring

### Cross-Product Coordination

**Kafka Topic:** `cross_product_events`

**Use Case: Medical Prescription During Voice Call**
1. User on voice call with healthcare voicebot
2. Uploads prescription image via chatbot widget
3. Chatbot processes image silently (OCR + LLM parsing), NO conversational response
4. Chatbot publishes `chatbot_image_processed` with extracted data (medication, dosage, doctor, date)
5. Voicebot receives event, adds data to conversation context
6. Voicebot continues call: "I see you've uploaded a prescription for Amoxicillin 500mg, 3 times daily from Dr. Sarah Johnson. Would you like me to help you with a refill?"
7. Chatbot remains silent until `voicebot_session_ended`

**Coordination Rules:**
- Voicebot active → Chatbot silent processing mode (no conversational responses)
- Chatbot processes images/forms → Publishes extracted data → Voicebot consumes
- Voice call ends → Chatbot resumes normal conversational mode

### LLM SDK & Cost Optimization (@workflow/llm-sdk library)

**Direct LLM Integration (200-500ms faster per call):**
- Services 8, 9, 21, 13, 14 use @workflow/llm-sdk for direct LLM calls (no gateway hop)
- Eliminates Service 16 latency overhead
- Maintains all gateway functionality (routing, caching, monitoring) within library

**Model Routing:**
- Simple tasks (FAQs, greetings) → GPT-3.5 (cheaper)
- Complex tasks (reasoning, multi-step flows) → GPT-4 or Claude (premium)
- Auto-routing based on complexity score

**Semantic Caching (Helicone):**
- Cache similar prompts to reduce LLM calls
- 40-60% token savings for common queries
- Namespace-per-tenant for isolation

**Token Monitoring:**
- Track LLM token usage per tenant, per workflow
- Alert when approaching budget limits
- Monthly cost dashboards for clients

### Multi-Tenancy Architecture

**Row-Level Security (RLS):**
- PostgreSQL policies enforce `tenant_id` filtering
- NEVER bypass tenant filtering, even for admin operations
- Test isolation thoroughly: Every test verifies data cannot leak between tenants

**Namespace Isolation:**
- Qdrant: Vector DB with namespace-per-tenant
- Neo4j: Graph DB with tenant namespace
- Redis: Tenant-aware caching with key prefixes

**Configuration Isolation:**
- YAML configs stored with `organization_id`
- S3 bucket structure: `/configs/{organization_id}/{config_id}.yaml`
- @workflow/config-sdk library enforces tenant isolation at SDK level
- Hot-reload only affects target tenant

---

## Monitoring & Analytics

### Monitoring Engine (Service 11)

**Real-Time System Health:**
- Service uptime tracking (99.9% SLA target)
- API response time monitoring (<2s P95 chatbot, <500ms P95 voicebot)
- Error rate tracking per service, per tenant

**Anomaly Detection:**
- Sudden spike in errors → Alert platform engineer
- LLM hallucination detection (quality monitoring)
- Integration failures (Salesforce API down, Stripe webhook timeout)

**SLA Tracking:**
- Track SLAs per client contract
- Auto-escalate violations to Support Specialist
- Refund billing if SLA breached (if minimum clause exists)

**Auto-Rollback Triggers:**
- High error rate (>5% in 5 minutes)
- Low success rate (<85% conversation completion)
- SLA violation detected
- Publishes `config_events.config_rollback` → Revert to previous version

**Incident Management:**
- Creates incident ticket with severity level
- Alert platform engineer (Slack, PagerDuty)
- Client informed via email/SMS
- RCA (Root Cause Analysis) generated post-resolution
- Prevention plan implemented to avoid future occurrences

### Analytics Service (Service 12)

**Conversation Metrics:**
- Total conversations, conversation completion rate
- Average conversation duration, user satisfaction scores
- Resolution rate (first-contact resolution, escalation rate)

**KPI Dashboards:**
- Per-client, per-config, per-cohort dashboards
- Funnel analysis (lead → qualified → converted)
- A/B test performance tracking
- Village knowledge insights (cross-client patterns)

**Agent Performance Tracking:**
- Human agent metrics (response time, resolution rate, CSAT)
- AI agent metrics (confidence scores, tool success rate, escalation frequency)
- Comparative analysis (AI vs. human performance)

---

## Automation Progression & Success Metrics

### Automation by Phase

| **Phase** | **Automation %** | **Automated Tasks** | **Human Tasks** |
|-----------|------------------|---------------------|-----------------|
| Phase 0: Sales | 60% | Research, demo generation, NDA/proposal creation | Relationship building, negotiation, strategic decisions |
| Phase 1: Onboarding | 60% | PRD AI cross-questioning, YAML config generation, GitHub tickets | PRD supervision, architecture review, config validation |
| Phase 2: Support | 90% | Ticket resolution, config application, SLA tracking | Complex escalations, edge cases, quality supervision |
| Phase 3: Success | 90% | Daily KPI monitoring, health scores, lifecycle messaging | QBRs, strategic opportunities, renewal negotiation |
| Phase 4: Client Self-Service | 80% | Config classification, preview generation, low-risk changes | Complex configs, high-risk approvals, tool development |

### Success Metrics

**Cost Savings:**
- 80% reduction in customer service costs ($13/call → $2-3/call)
- 40-60% LLM cost savings through semantic caching

**Performance:**
- <2s API response time (P95) for chatbot
- <500ms voice latency (P95) for voicebot
- 99.9% uptime SLA

**Efficiency:**
- 50% reduction in time-to-deployment (PRD → production)
- 10× increase in concurrent client capacity
- 80% of config changes by clients without platform support
- 95% config change success rate (no rollbacks needed)

**Engagement:**
- 30% improvement in engagement metrics (CTR, session duration)
- 25% increase in conversion rates
- 15% reduction in churn

---

## Human Agent Lifecycle & Handoffs

### Agent Roles & Responsibilities

**Sales Agent (40% human touch):**
- Assisted signups, research oversight
- Demo presentation, client meetings
- NDA/proposal management, negotiation
- Requirements draft review and client validation
- **Uses Service 21 (Agent Copilot)** for unified client context, AI action planning, communication drafting

**Onboarding Specialist (40% human touch):**
- PRD supervision and collaboration
- Config review and technical architecture validation
- Launch oversight and deployment monitoring
- Handoff to Support + Success (dual assignment)
- **Uses Service 21 (Agent Copilot)** for PRD collaboration tracking, handoff management, onboarding progress dashboard

**Support Specialist (10% human touch):**
- Complex ticket resolution
- Config tuning and troubleshooting
- Escalation handling from AI agents
- Support matrix documentation
- **Uses Service 21 (Agent Copilot)** for ticket context aggregation, SLA monitoring, AI-powered resolution suggestions

**Success Manager (10% human touch):**
- KPI monitoring and health score review
- Quarterly Business Reviews (QBRs)
- Upsell identification and specialist invitations
- Renewal management and strategic opportunities
- **Uses Service 21 (Agent Copilot)** for health score tracking, QBR deck generation, strategic recommendation AI, village knowledge insights

**Sales Specialist (Dynamic invitations):**
- Temporarily assigned for upsell/cross-sell during success stage
- Works on specific opportunities (voice addon, premium tier, custom integration)
- Returns client to Success Manager after completion
- **Uses Service 21 (Agent Copilot)** for opportunity context, communication drafting, CRM sync

**AI Supervisor:**
- Monitors AI quality across all agents
- Tunes configurations for improved performance
- Handles edge cases and anomaly resolution

**Platform Admin/Engineer:**
- Infrastructure management, system administration
- Critical bug resolution, platform downtime handling
- RCA creation and mitigation implementation

---

### Service 21: Agent Copilot - The Human Agent Operating System

**Service 21 provides a unified dashboard and AI-powered assistance for ALL human agents**, eliminating context-switching across 10+ systems and enabling agents to manage 3x more clients.

**Core Capabilities:**

1. **Unified Agent Dashboard**
   - Single pane of glass for all client context (aggregates 17 Kafka topics in real-time)
   - Role-based views customized for Sales, Onboarding, Support, Success roles
   - Timeline of all client interactions across all services
   - WebSocket real-time updates for instant notifications

2. **AI-Powered Action Planning**
   - Daily prioritized action plan with next-best-action recommendations
   - Predictive outcome modeling (success probability, impact, effort estimates)
   - Action sequence optimization based on historical success patterns
   - Continuous learning from action execution results
   - Dynamic reprioritization based on real-time events (SLA breaches, escalations, health score drops)

3. **Communication Drafting**
   - AI-generated emails, meeting agendas, QBR decks
   - Context-aware drafting referencing recent interactions and client history
   - Brand voice consistency enforcement
   - Multi-language support
   - Edit and regenerate workflow with agent feedback

4. **Approval Orchestration**
   - Intelligent approval routing (discounts, refunds, exceptions, escalations)
   - Risk-based routing (type + amount thresholds → appropriate manager)
   - SLA monitoring with auto-escalation for overdue approvals
   - Delegation support and audit trails

5. **CRM Auto-Sync**
   - Bi-directional sync with Salesforce, HubSpot, Zendesk
   - Automatic opportunity stage updates (demo completed → proposal sent)
   - Activity logging (calls, emails, meetings logged to CRM)
   - Conflict resolution and retry logic

6. **Village Knowledge Integration**
   - Semantic search for best practices from similar client situations
   - Success pattern identification (what worked for similar clients)
   - Failure pattern avoidance (warning signs from churned clients)
   - Knowledge contribution by agents with upvoting system

7. **Performance Dashboard**
   - Agent metrics (response time, resolution rate, CSAT, NPS)
   - Goal tracking and peer benchmarking
   - AI coaching suggestions for improvement areas
   - Time allocation breakdown (sales vs. onboarding vs. support vs. success)

**Integration Points:**
- **Consumes:** 17 Kafka topics for real-time context (auth, research, demo, sales_doc, billing, prd, config, conversation, voice, monitoring, analytics, customer_success, support, communication, escalation, cross_product, crm)
- **Produces:** `agent_action_events`, `approval_events`, `performance_events`
- **Uses:** @workflow/llm-sdk for action planning and communication drafting (200-500ms faster)
- **Uses:** Service 15 (CRM Integration) for Salesforce/HubSpot/Zendesk sync
- **Uses:** Service 17 (RAG Pipeline) for village knowledge semantic search

**Business Impact:**
- **3x agent capacity:** Agents manage 3x more clients with copilot assistance
- **Context switching eliminated:** From 10+ systems → 1 unified dashboard
- **Response time reduced:** AI action planning reduces decision time from hours to minutes
- **Quality consistency:** Communication drafting ensures brand voice and reduces errors
- **Knowledge sharing:** Village knowledge surfaces best practices across all agents

### Lifecycle Handoff Flow

**1. Assisted Signup → Sales Agent (Auto-assigned)**
- Workload-balanced assignment (least loaded agent)
- Research Engine runs automatically
- Sales agent reviews requirements draft

**2. NDA Signed → Sales → Onboarding Handoff**
- Sales agent creates handoff with context notes, client preferences, technical requirements
- Handoff queued for Onboarding agents (workload-balanced)
- Onboarding Specialist accepts → Client assignment updated
- Confirmation email sent to client
- Sales agent assignment marked 'completed'

**3. PRD Approved & Deployed → Onboarding → Support + Success (DUAL Handoff)**
- Onboarding Specialist creates DUAL handoff (parallel assignment to both Support + Success)
- Support Specialist accepts → Handles ongoing tickets and escalations
- Success Manager accepts → Monitors KPIs and conducts QBRs
- Onboarding assignment marked 'completed'

**4. Upsell Opportunity → Success → Sales Specialist (Temporary Assignment)**
- Success Manager identifies upsell (e.g., voice addon, premium tier, custom integration)
- Creates specialist invitation with opportunity type, reason, context
- Sales Specialist accepts → Temporary assignment begins
- Specialist completes work → Logs outcome (deal closed, revenue, next steps)
- Specialist assignment marked 'completed' → Returns to Success Manager

### Agent Capacity & Availability

**Real-Time Status:**
- Online, Busy, Offline, Away
- Capacity limits: `max_concurrent_clients` (e.g., 15), `max_active_handoffs` (e.g., 3)

**Auto-Assignment Logic:**
- Workload balancing (least loaded agent with available capacity)
- Agent goes offline → Queue redistributed automatically
- Specialist invitation → Matched by expertise and availability

**Human-in-the-Loop Philosophy:**
- Humans provide relationship, strategy, expert guidance
- AI handles repetitive tasks, data processing, 24/7 availability
- Collaboration: AI generates, human reviews/approves

---

## CRM Integration & Internal KPIs

### CRM Integration Service (Service 15)

**Supported CRMs:**
- Salesforce, HubSpot, Zendesk (bidirectional sync)
- Webhook handling for real-time updates
- Custom CRM integrations via API

**Lifecycle Tracking:**
- Track client lifecycle stage: Lead → Trial → Active → At-Risk → Renewal → Churned
- Assign, review, and get insights into collaboration across Sales, Onboarding, Support, Success
- Dynamic CRM flow adapts as automation increases

### Internal KPIs & Review Frameworks

**AI Agent KPIs:**
- Correct judgments with fewer iterations
- Reliable performance (uptime, consistency)
- Quick resolutions (response time, first-contact resolution)
- User growth and retention

**Human Agent KPIs:**
- Response time, resolution rate, CSAT scores
- Handoff quality (context transfer completeness)
- Client retention and upsell success rates
- QBR completion and action item follow-through

**Platform KPIs:**
- System uptime (99.9% SLA)
- Client growth rate, churn rate
- Revenue per client, LTV (Lifetime Value)
- Token cost per conversation, gross margin

---

## Future Enhancements

### Fine-Tuning & RL (Future Modules)

**When Data Available:**
- Fine-tune SOTA models for onboarding agents and customer success agents
- Expected 30-50% performance improvement

**Automated Fine-Tuning & RL:**
- Each client can have their own LLM managed by platform
- Continuous updates: A) As client gathers more data, B) When better open-source models release (GPT-4 OS → GPT-5 OS)
- Expected 30-50% decrease in costs AND 30-50% increase in reliability

**Engagement Strategy:**
- Hire top experts to architect key modules we can't internally optimize
- Modularize whole system to enable expert engagement on specific challenges

---

## Conclusion

This platform achieves 95% automation within 12 months through:

1. **Optimized Event-Driven Architecture:** 17 microservices (16 core + 2 libraries) coordinated via 18 Kafka topics, delivering 400-900ms faster workflows through service consolidation
2. **YAML-Driven Configuration:** Chatbot (LangGraph) and Voicebot (LiveKit) powered by dynamic configs with hot-reload via @workflow/config-sdk (50-100ms faster)
3. **Human-in-the-Loop Orchestration:** Structured lifecycle handoffs (Sales → Onboarding → Support → Success) managed by Service 0, with automation percentages increasing from 60% → 90% → 80%
4. **Agent Copilot (Service 21):** AI-powered unified dashboard for human agents aggregating 17 event streams, enabling 3x agent capacity through intelligent action planning, communication drafting, and village knowledge integration
5. **Client Self-Service:** Unified PRD Builder & Configuration Workspace (Service 6) enables 80% autonomy for config changes
6. **Unified Communication & Hyperpersonalization:** Service 20 combines outbound communication with multi-armed bandit experimentation (50-100 variants) achieving 30% engagement improvement
7. **Direct LLM Integration:** @workflow/llm-sdk library eliminates gateway hop, saving 200-500ms per LLM call
8. **Village Knowledge:** Cross-client learnings drive continuous optimization and proactive recommendations
9. **Cost Optimization:** Semantic caching, model routing, and token monitoring reduce LLM costs by 40-60%

**Architecture Consolidation Benefits:**
- **22 → 17 services:** Simplified architecture, easier maintenance
- **3-service sales pipeline → 1-service:** 150-300ms faster (Service 3 unifies NDA/Pricing/Proposal)
- **LLM gateway elimination:** 200-500ms faster per call (@workflow/llm-sdk)
- **Config service elimination:** 50-100ms faster config operations (@workflow/config-sdk)
- **Total workflow speedup:** 400-900ms per complete client lifecycle

**The result:** 10× increase in concurrent client capacity, 3× increase in per-agent capacity (via Service 21 Agent Copilot), 80% reduction in customer service costs, <1.5s chatbot latency (400-900ms improvement), <300ms voicebot latency (200-500ms improvement), 99.9% uptime, and a leaner, faster platform that evolves with every client deployment.
