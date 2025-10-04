# Microservices Architecture Specification (Part 2)
## Complete Workflow Automation System - Remaining Services

---

## 6. PRD Builder Engine Service

#### Objectives
- **Primary Purpose**: AI-powered generation of comprehensive Product Requirement Documents (PRDs) through conversational interface with cross-questioning and village knowledge integration
- **Business Value**: Reduces PRD creation from 20+ hours to 2-3 hours, leverages multi-client learnings, ensures completeness through AI-driven edge case analysis
- **Scope Boundaries**:
  - **Does**: Generate PRDs via webchat UI, integrate village knowledge, suggest new objectives, design A/B flows, plan integrations and escalations
  - **Does Not**: Write code, deploy solutions, manage infrastructure

#### Requirements

**Functional Requirements:**
1. Conversational PRD generation via webchat UI with cross-questioning
2. Integration with village knowledge (what's working for other clients)
3. Automatic objective suggestion based on business context and AI intelligence
4. A/B flow design for each objective with KPI measurement framework
5. Baseline data requirement assessment (what data exists, what's needed)
6. Integration architecture definition (when to escalate, tool ecosystem mapping)
7. Sprint planning with 95% automation roadmap (12-month timeline)
8. Log event tracking for uptime monitoring
9. Iterative refinement until client satisfaction

**Non-Functional Requirements:**
- Initial PRD generation: <15 minutes for standard use case
- Support 50 concurrent PRD sessions
- Village knowledge retrieval: <2s latency
- 99% uptime for PRD generation service
- Multi-client knowledge isolation (no data leakage)

**Dependencies:**
- Proposal Generator (consumes proposal_signed event)
- Agent Orchestration Service (village knowledge retrieval)
- Automation Engine (triggers YAML config generation)
- Analytics Service (historical KPI data for benchmarking)

**Data Storage:**
- PostgreSQL: PRD metadata, versions, client feedback, approval status
- Qdrant: Village knowledge embeddings (successful patterns, KPIs, flows)
- Neo4j: Integration dependency graphs, workflow relationships
- S3: PRD documents (markdown, PDF exports)

#### Features

**Must-Have:**
1. ✅ Conversational PRD builder with AI cross-questioning
2. ✅ Village knowledge integration (multi-tenant learnings)
3. ✅ Objective suggestion engine (cross-sell, upsell, surveys)
4. ✅ A/B flow designer with visual workflow builder
5. ✅ KPI framework definition with baseline assessment
6. ✅ Integration architecture planner (escalation rules, tool mapping)
7. ✅ Sprint roadmap generator (12-month automation plan)
8. ✅ Collaborative editing with client feedback loop

**Nice-to-Have:**
9. 🔄 Auto-generated user stories from PRD
10. 🔄 Competitive analysis integration
11. 🔄 Risk assessment and mitigation planning
12. 🔄 ROI calculator based on automation metrics

**Feature Interactions:**
- Proposal signing → Auto-triggers PRD session
- PRD approval → Triggers automation engine YAML generation
- Village knowledge → Suggests objectives client didn't request

#### API Specification

**1. Create PRD Session**
```http
POST /api/v1/prd/sessions
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "proposal_id": "uuid",
  "initial_context": {
    "business_type": "e-commerce",
    "use_cases": ["customer_support", "lead_qualification"],
    "current_tools": ["salesforce", "zendesk", "shopify"],
    "team_size": 15,
    "customer_volume_monthly": 5000
  },
  "enable_village_knowledge": true
}

Response (201 Created):
{
  "session_id": "uuid",
  "prd_id": "uuid",
  "status": "active",
  "webchat_url": "https://prd.workflow.com/chat/uuid",
  "ai_agent": {
    "name": "PRD Builder Assistant",
    "capabilities": ["cross_questioning", "objective_suggestion", "flow_design", "knowledge_integration"]
  },
  "initial_message": "I'll help you build a comprehensive PRD. Let's start by understanding your customer support objectives. What are the top 3 pain points you're trying to solve?",
  "created_at": "2025-10-10T09:00:00Z"
}
```

**2. Chat with PRD Builder**
```http
POST /api/v1/prd/sessions/{session_id}/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "We need to reduce response time from 4 hours to under 15 minutes, provide 24/7 coverage, and handle common queries automatically.",
  "attachments": []
}

Response (200 OK):
{
  "session_id": "uuid",
  "message_id": "uuid",
  "ai_response": {
    "message": "Great objectives! Let me dig deeper:\n\n1. What percentage of your current queries could be fully automated vs requiring human handoff?\n2. Do you have historical data on query types and volumes by hour?\n3. What's your current escalation process when agents are unavailable?\n\nBased on village knowledge, similar e-commerce clients achieved 78% automation for Tier 1 support queries. Would you like me to design A/B flows for automated triage?",
    "suggested_objectives": [
      {
        "objective": "Implement proactive upsell during support interactions",
        "rationale": "E-commerce clients saw 12% increase in AOV with contextual product recommendations during support chats",
        "source": "village_knowledge",
        "confidence": 0.87
      },
      {
        "objective": "Collect post-interaction NPS for continuous improvement",
        "rationale": "Automated feedback loops improve CSAT by 23% over 6 months",
        "source": "ai_intelligence",
        "confidence": 0.76
      }
    ],
    "data_requirements": [
      {
        "data_type": "historical_query_logs",
        "purpose": "Train query classification model",
        "availability": "unknown",
        "priority": "high"
      },
      {
        "data_type": "customer_order_history",
        "purpose": "Enable contextual upsell recommendations",
        "availability": "exists_in_shopify",
        "priority": "medium"
      }
    ],
    "next_questions": [
      "What's your tolerance for automation errors (false positives)?",
      "Should the AI agent access customer order history for personalization?"
    ]
  },
  "prd_updates": {
    "sections_added": ["Objectives", "Success Metrics"],
    "fields_populated": 8,
    "completion_percent": 35
  },
  "timestamp": "2025-10-10T09:05:00Z"
}
```

**3. Design A/B Flow**
```http
POST /api/v1/prd/{prd_id}/flows
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "objective_id": "uuid",
  "flow_type": "ab_test",
  "variants": [
    {
      "variant_id": "control",
      "name": "Direct Agent Escalation",
      "description": "Route complex queries directly to human agent",
      "workflow": {
        "steps": [
          {"step": "intent_classification", "tool": "llm_classifier"},
          {"step": "complexity_check", "condition": "complexity > 0.7"},
          {"step": "agent_handoff", "tool": "zendesk_api"}
        ]
      }
    },
    {
      "variant_id": "treatment",
      "name": "AI Attempt Before Escalation",
      "description": "Let AI attempt resolution before human handoff",
      "workflow": {
        "steps": [
          {"step": "intent_classification", "tool": "llm_classifier"},
          {"step": "ai_resolution_attempt", "tool": "gpt4_agent", "max_turns": 3},
          {"step": "success_check", "condition": "user_satisfied == true"},
          {"step": "agent_handoff", "tool": "zendesk_api", "condition": "user_satisfied == false"}
        ]
      }
    }
  ],
  "kpis": [
    {"name": "resolution_time", "target": "<15 min", "measurement": "timestamp_diff"},
    {"name": "automation_rate", "target": ">80%", "measurement": "ai_resolutions / total_queries"},
    {"name": "csat_score", "target": ">4.5", "measurement": "post_chat_survey"}
  ],
  "traffic_split": {"control": 30, "treatment": 70}
}

Response (201 Created):
{
  "flow_id": "uuid",
  "prd_id": "uuid",
  "objective_id": "uuid",
  "status": "designed",
  "visual_workflow_url": "https://prd.workflow.com/flows/uuid/visual",
  "mermaid_diagram": "graph TD\n  A[User Query] --> B[Intent Classification]\n  B --> C{Complexity Check}\n  ...",
  "data_requirements": [
    {
      "source": "zendesk",
      "fields": ["ticket_history", "agent_availability"],
      "integration_status": "exists"
    },
    {
      "source": "customer_db",
      "fields": ["order_history", "support_tier"],
      "integration_status": "needs_implementation"
    }
  ],
  "baseline_assessment": {
    "current_avg_resolution_time": "4.2 hours",
    "current_automation_rate": "12%",
    "current_csat": "3.8",
    "data_availability": {
      "has_historical_logs": true,
      "has_customer_context": "partial",
      "has_sentiment_data": false
    },
    "recommendations": "Implement sentiment tracking for better CSAT measurement"
  },
  "created_at": "2025-10-10T09:30:00Z"
}
```

**4. Get PRD Document**
```http
GET /api/v1/prd/{prd_id}
Authorization: Bearer {jwt_token}
Accept: application/json | application/pdf | text/markdown

Response (200 OK - JSON):
{
  "prd_id": "uuid",
  "client_id": "uuid",
  "status": "in_progress",
  "completion_percent": 75,
  "sections": {
    "executive_summary": "This PRD outlines the implementation of AI-powered customer support automation for Acme Corp...",
    "objectives": [
      {
        "objective_id": "uuid",
        "title": "Reduce Response Time to <15 Minutes",
        "description": "Implement automated triage and resolution for Tier 1 queries",
        "success_metrics": ["response_time < 15min", "automation_rate > 80%"],
        "source": "client_requested"
      },
      {
        "objective_id": "uuid",
        "title": "Implement Proactive Upsell",
        "description": "Contextual product recommendations during support interactions",
        "success_metrics": ["aov_increase > 10%", "recommendation_ctr > 15%"],
        "source": "ai_suggested",
        "client_approved": true
      }
    ],
    "ab_flows": [
      {
        "flow_id": "uuid",
        "objective_id": "uuid",
        "variants": [...],
        "kpis": [...],
        "traffic_split": {...}
      }
    ],
    "integration_architecture": {
      "existing_tools": ["salesforce", "zendesk", "shopify"],
      "new_integrations_needed": [
        {
          "tool": "sentiment_api",
          "purpose": "Real-time CSAT measurement",
          "priority": "high",
          "estimated_effort": "2 sprints"
        }
      ],
      "escalation_rules": [
        {"trigger": "user_frustrated", "action": "immediate_agent_handoff"},
        {"trigger": "complex_technical_issue", "action": "route_to_tier2"},
        {"trigger": "vip_customer", "action": "priority_queue"}
      ],
      "human_collaboration": {
        "mode": "alongside",
        "handoff_triggers": ["complexity_threshold", "user_request", "ai_confidence_low"],
        "unavailable_agent_action": "queue_with_callback_offer"
      }
    },
    "data_baseline": {
      "existing_data": {
        "zendesk_tickets": {"availability": "yes", "quality": "high", "volume": "50K records"},
        "customer_profiles": {"availability": "partial", "quality": "medium", "volume": "15K records"}
      },
      "required_data": {
        "sentiment_scores": {"availability": "no", "source": "needs_implementation", "impact": "Better CSAT measurement"},
        "product_catalog": {"availability": "yes", "source": "shopify", "impact": "Enable upsell recommendations"}
      },
      "data_sharing_requirements": [
        {"data_type": "customer_pii", "client_consent": "pending", "alternative": "Use anonymized IDs"}
      ]
    },
    "sprint_roadmap": {
      "sprint_1_2": {
        "goal": "Basic chatbot with intent classification",
        "automation_target": "20%",
        "deliverables": ["intent_classifier", "zendesk_integration", "basic_responses"]
      },
      "sprint_3_4": {
        "goal": "A/B flow implementation",
        "automation_target": "40%",
        "deliverables": ["ab_framework", "kpi_tracking", "shopify_integration"]
      },
      "sprint_5_12": {
        "goal": "Advanced personalization and optimization",
        "automation_target": "80%",
        "deliverables": ["sentiment_analysis", "upsell_engine", "workflow_optimization"]
      },
      "month_12_target": "95% automation for Tier 1 queries"
    },
    "log_events": [
      {"event": "user_query_received", "purpose": "Track uptime and volume"},
      {"event": "llm_call_initiated", "purpose": "Monitor LLM performance"},
      {"event": "tool_invocation", "purpose": "Track integration health"},
      {"event": "escalation_triggered", "purpose": "Analyze handoff patterns"},
      {"event": "conversation_completed", "purpose": "Calculate success metrics"}
    ],
    "village_knowledge_insights": [
      {
        "insight": "E-commerce clients with product recommendation during support see 12% AOV increase",
        "source": "client_xyz_implementation",
        "confidence": 0.87,
        "applicability": "high"
      },
      {
        "insight": "Sentiment-based escalation reduces churn by 18% for frustrated users",
        "source": "client_abc_results",
        "confidence": 0.92,
        "applicability": "high"
      }
    ]
  },
  "version": 3,
  "created_at": "2025-10-10T09:00:00Z",
  "updated_at": "2025-10-10T11:45:00Z"
}

Response (200 OK - PDF):
Binary PDF content with formatted PRD

Response (200 OK - Markdown):
# Product Requirement Document
## AI-Powered Customer Support Automation
...
```

**5. Submit Client Feedback**
```http
POST /api/v1/prd/{prd_id}/feedback
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "feedback_type": "revision_request",
  "comments": [
    {
      "section": "integration_architecture",
      "comment": "We also use Intercom, not just Zendesk. Please add Intercom integration.",
      "priority": "high"
    },
    {
      "section": "objectives",
      "comment": "Love the upsell suggestion! Let's prioritize this in Sprint 3-4.",
      "priority": "medium",
      "action": "reprioritize"
    }
  ],
  "overall_satisfaction": 4,
  "ready_for_approval": false
}

Response (200 OK):
{
  "prd_id": "uuid",
  "feedback_id": "uuid",
  "status": "revision_in_progress",
  "ai_response": "I've noted your feedback. I'll add Intercom integration to the architecture and reprioritize the upsell objective. Let me update the PRD and show you the changes.",
  "estimated_revision_time": "5 minutes",
  "next_version": 4
}

Event Published to Kafka:
Topic: prd_events
{
  "event_type": "prd_feedback_received",
  "prd_id": "uuid",
  "client_id": "uuid",
  "ready_for_approval": false,
  "timestamp": "2025-10-10T12:00:00Z"
}
```

**6. Approve PRD**
```http
POST /api/v1/prd/{prd_id}/approve
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "approved_by": "uuid",
  "approval_notes": "PRD is comprehensive and addresses all our needs. Ready to proceed with implementation.",
  "client_signature": "electronic_signature_token"
}

Response (200 OK):
{
  "prd_id": "uuid",
  "status": "approved",
  "final_version": 4,
  "approved_at": "2025-10-10T14:00:00Z",
  "approved_by": {
    "id": "uuid",
    "name": "John Smith",
    "role": "CEO"
  },
  "next_steps": [
    "automation_engine_yaml_generation",
    "github_issues_creation",
    "sprint_planning"
  ]
}

Event Published to Kafka:
Topic: prd_events
{
  "event_type": "prd_approved",
  "prd_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-10T14:00:00Z"
}
```

**Rate Limiting:**
- 10 PRD sessions per day per tenant
- 200 chat messages per hour per session
- 1000 API requests per minute per tenant

#### Frontend Components

**1. PRD Chat Interface**
- Component: `PRDChatInterface.tsx`
- Features:
  - Full-screen chat with AI PRD builder
  - Message history with context preservation
  - Rich media support (diagrams, tables, code blocks)
  - Suggested objectives cards (accept/reject)
  - Data requirement checklist
  - Live PRD preview pane (collapsible)

**2. A/B Flow Designer**
- Component: `ABFlowDesigner.tsx`
- Features:
  - Visual workflow builder (drag-and-drop nodes)
  - Split traffic configurator
  - KPI definition wizard
  - Mermaid diagram generator
  - Baseline data mapper
  - Integration dependency visualizer

**3. Village Knowledge Explorer**
- Component: `VillageKnowledgeExplorer.tsx`
- Features:
  - Searchable knowledge base (successful patterns, KPIs)
  - Similarity-based recommendations
  - Filter by industry, use case, metric
  - Anonymized client success stories
  - "Apply to my PRD" quick actions

**4. Sprint Roadmap Planner**
- Component: `SprintRoadmapPlanner.tsx`
- Features:
  - Interactive timeline (12-month view)
  - Automation target tracker (progress bars)
  - Deliverable checklist per sprint
  - Dependency visualization
  - Resource allocation estimator

**5. PRD Document Viewer**
- Component: `PRDDocumentViewer.tsx`
- Features:
  - Tabbed sections (Objectives, Flows, Integrations, Roadmap)
  - Export options (PDF, Markdown, DOCX)
  - Comment threading on sections
  - Version comparison
  - Client approval workflow

**State Management:**
- Zustand for chat state and PRD content
- React Query for API data fetching
- WebSocket for real-time AI responses
- IndexedDB for offline draft support

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Product Manager (Internal)**
   - Role: Facilitates PRD sessions, ensures completeness
   - Access: Full access to all PRDs, facilitation tools
   - Permissions: create:prd, read:all_prds, update:prd, approve:internal
   - Workflows: Initiates PRD session, guides conversation, validates technical feasibility

2. **Client Business Owner**
   - Role: Provides business context, approves objectives and flows
   - Access: Read/write access to assigned PRD
   - Permissions: read:assigned_prd, chat:prd, approve:prd
   - Workflows: Answers AI questions, reviews suggestions, provides feedback, final approval
   - Approval: Final PRD approval required before automation

3. **Technical Architect (Internal)**
   - Role: Reviews integration architecture, validates technical feasibility
   - Access: Read access to all PRDs, approval rights for complex integrations
   - Permissions: read:all_prds, approve:technical_architecture
   - Workflows: Reviews integration requirements, assesses effort estimates, approves complex flows
   - Approval: Required for custom integrations, complex A/B flows

**AI Agents:**

1. **PRD Builder Agent**
   - Responsibility: Conducts conversational PRD creation, cross-questions, populates document
   - Tools: LLM (GPT-4), village knowledge retriever, template engine
   - Autonomy: Fully autonomous for standard questions and suggestions
   - Escalation: Product Manager review for ambiguous requirements

2. **Village Knowledge Agent**
   - Responsibility: Retrieves relevant patterns from other clients, suggests proven objectives
   - Tools: Qdrant semantic search, anonymization filters, success pattern matcher
   - Autonomy: Fully autonomous for knowledge retrieval and suggestion
   - Escalation: None (suggestions are always optional)

3. **Integration Planner Agent**
   - Responsibility: Maps integration architecture, identifies missing tools, estimates effort
   - Tools: Neo4j integration graph, API catalogs, effort estimation models
   - Autonomy: Fully autonomous for standard integrations
   - Escalation: Technical Architect approval for custom/complex integrations

4. **Baseline Assessment Agent**
   - Responsibility: Analyzes available data, identifies gaps, recommends collection strategies
   - Tools: Data profilers, schema analyzers, LLM for gap analysis
   - Autonomy: Fully autonomous
   - Escalation: Alerts on critical data gaps that block objectives

**Approval Workflows:**
1. PRD Creation → Auto-approved for standard use cases, Product Manager review for complex
2. Village Knowledge Suggestions → Client acceptance required (opt-in)
3. A/B Flow Design → Technical Architect approval for >3 variants or complex logic
4. Integration Architecture → Technical Architect approval for custom integrations
5. Final PRD → Client Business Owner approval required
6. Sprint Roadmap → Product Manager + Technical Architect alignment required

---

## 7. Automation Engine Service

#### Objectives
- **Primary Purpose**: Converts approved PRDs into executable YAML configurations, manages dynamic agent behavior, orchestrates tool and integration lifecycle
- **Business Value**: Enables configuration-driven agent deployment, automates GitHub issue creation for missing tools/integrations, supports 1000+ concurrent YAML configs
- **Scope Boundaries**:
  - **Does**: Generate YAML configs, manage tool/integration GitHub issues, hot-reload configurations, validate and version configs
  - **Does Not**: Implement tools/integrations (developers do), train models, deploy infrastructure

#### Requirements

**Functional Requirements:**
1. Generate YAML configuration from approved PRD with webchat UI interface
2. Define system prompts, tools, integrations, and metadata per config
3. Auto-create GitHub issues for missing tools/integrations with detailed specs
4. Track tool/integration implementation status and auto-update configs
5. Validate YAML against JSON Schema before deployment
6. Support config versioning with blue-green deployment
7. Hot-reload configs without service restart
8. Multi-tenant config isolation with namespace-based segregation

**Non-Functional Requirements:**
- YAML generation: <5 minutes from PRD approval
- Config validation: <2 seconds
- Hot-reload propagation: <60 seconds across all services
- Support 10,000+ YAML configs with tenant isolation
- 99.9% config availability

**Dependencies:**
- PRD Builder (consumes prd_approved event)
- Agent Orchestration Service (loads YAML configs for chatbot runtime)
- Voice Agent Service (loads YAML configs for voicebot runtime)
- Configuration Management Service (stores and distributes configs)
- GitHub API (issue creation, status tracking)

**Data Storage:**
- PostgreSQL: Config metadata, versions, GitHub issue mapping, validation logs
- S3: YAML config files, config snapshots
- Git Repository: Version-controlled config storage
- Redis: Hot-reload notification queue

#### Features

**Must-Have:**
1. ✅ YAML config generation from PRD
2. ✅ Webchat UI for config refinement
3. ✅ Canvas editor for manual YAML editing
4. ✅ GitHub issue auto-creation for missing dependencies
5. ✅ Tool/integration status tracking with auto-attachment
6. ✅ JSON Schema validation
7. ✅ Config versioning with rollback
8. ✅ Hot-reload via Kafka events

**Nice-to-Have:**
9. 🔄 AI-powered config optimization suggestions
10. 🔄 Config diff analyzer (compare configs across clients)
11. 🔄 Automated regression testing for config changes
12. 🔄 Config template marketplace

**Feature Interactions:**
- PRD approval → Auto-generates YAML config
- GitHub issue closed (tool implemented) → Auto-updates config
- Config validation failure → Rollback to previous version

#### API Specification

**1. Generate YAML Config**
```http
POST /api/v1/automation/configs/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "prd_id": "uuid",
  "client_id": "uuid",
  "config_name": "acme_support_bot",
  "config_type": "chatbot",
  "environment": "staging"
}

Response (202 Accepted):
{
  "config_id": "uuid",
  "status": "generating",
  "webchat_url": "https://automation.workflow.com/chat/uuid",
  "estimated_completion": "2025-10-10T14:10:00Z"
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "config_generation_started",
  "config_id": "uuid",
  "client_id": "uuid",
  "timestamp": "2025-10-10T14:05:00Z"
}
```

**2. Get YAML Config**
```http
GET /api/v1/automation/configs/{config_id}
Authorization: Bearer {jwt_token}
Accept: application/json | text/yaml

Response (200 OK - JSON):
{
  "config_id": "uuid",
  "client_id": "uuid",
  "status": "generated",
  "config_name": "acme_support_bot",
  "yaml_content": "...",
  "parsed_config": {
    "config_metadata": {
      "config_id": "uuid",
      "client_id": "uuid",
      "version": 1,
      "environment": "staging",
      "created_at": "2025-10-10T14:08:00Z"
    },
    "system_prompt": {
      "role": "customer_support_agent",
      "instructions": "You are a helpful customer support agent for Acme Corp. Your goal is to resolve customer queries efficiently...",
      "constraints": [
        "Never share customer PII",
        "Escalate to human if user is frustrated",
        "Always confirm order numbers before actions"
      ],
      "tone": "friendly_professional"
    },
    "tools_available": [
      {
        "tool_name": "fetch_order_status",
        "status": "implemented",
        "github_issue": null
      },
      {
        "tool_name": "update_shipping_address",
        "status": "implemented",
        "github_issue": null
      },
      {
        "tool_name": "initiate_refund",
        "status": "missing",
        "github_issue": "https://github.com/workflow/tools/issues/156"
      }
    ],
    "tools_needed": [
      {
        "tool_name": "initiate_refund",
        "input_schema": {
          "order_id": "string",
          "refund_amount": "number",
          "reason": "string"
        },
        "output_schema": {
          "refund_id": "string",
          "status": "string",
          "estimated_days": "number"
        },
        "metadata": {
          "priority": "high",
          "estimated_effort": "3 days",
          "assigned_to": "developer_uuid"
        }
      }
    ],
    "integrations": [
      {
        "integration_name": "salesforce_crm",
        "type": "input_channel",
        "status": "implemented",
        "config": {
          "endpoint": "https://api.salesforce.com/...",
          "auth_type": "oauth2"
        }
      },
      {
        "integration_name": "whatsapp_business",
        "type": "input_channel",
        "status": "implemented"
      },
      {
        "integration_name": "sentiment_api",
        "type": "utility",
        "status": "missing",
        "github_issue": "https://github.com/workflow/integrations/issues/89"
      }
    ],
    "integrations_needed": [
      {
        "integration_name": "sentiment_api",
        "purpose": "Real-time sentiment analysis for escalation triggers",
        "details": {
          "provider": "AWS Comprehend",
          "api_endpoint": "https://comprehend.us-east-1.amazonaws.com",
          "authentication": "AWS IAM",
          "rate_limit": "100 requests/second"
        },
        "metadata": {
          "priority": "medium",
          "estimated_effort": "5 days",
          "assigned_to": null
        }
      }
    ],
    "llm_config": {
      "provider": "openai",
      "model": "gpt-4o",
      "parameters": {
        "temperature": 0.7,
        "max_tokens": 500,
        "top_p": 0.9
      },
      "fallback": {
        "provider": "anthropic",
        "model": "claude-opus-4"
      }
    },
    "database_config": {
      "type": "supabase",
      "tables": ["conversations", "customer_leads", "analytics_events"],
      "rls_enabled": true
    },
    "vector_db_config": {
      "type": "pinecone",
      "index_name": "acme_knowledge_base",
      "namespace": "acme_corp"
    },
    "workflow_features": {
      "pii_collection": {
        "enabled": true,
        "fields": ["email", "phone", "name", "order_id"]
      },
      "followup_scheduling": {
        "enabled": true,
        "channels": ["email", "sms"],
        "triggers": ["unresolved_query", "abandoned_cart"]
      },
      "cross_sell_upsell": {
        "enabled": true,
        "recommendation_engine": "collaborative_filtering",
        "max_suggestions": 3
      },
      "survey_questions": {
        "enabled": true,
        "questions": [
          "How did you hear about us?",
          "On a scale of 1-10, how likely are you to recommend us?"
        ]
      },
      "human_escalation": {
        "enabled": true,
        "triggers": [
          {"condition": "sentiment_score < 0.3", "action": "immediate_handoff"},
          {"condition": "user_requests_human", "action": "immediate_handoff"},
          {"condition": "ai_confidence < 0.5", "action": "suggest_handoff"}
        ],
        "unavailable_action": "queue_callback"
      },
      "outbound_retargeting": {
        "enabled": true,
        "triggers": [
          {"event": "cart_abandoned_24h", "channel": "email", "template": "cart_reminder"},
          {"event": "support_ticket_unresolved_48h", "channel": "sms", "template": "followup"}
        ]
      }
    }
  },
  "validation_status": "passed",
  "github_issues_created": [
    {
      "issue_number": 156,
      "url": "https://github.com/workflow/tools/issues/156",
      "type": "tool",
      "title": "Implement initiate_refund tool",
      "status": "open",
      "assigned_to": "developer_uuid"
    },
    {
      "issue_number": 89,
      "url": "https://github.com/workflow/integrations/issues/89",
      "type": "integration",
      "title": "Add sentiment_api integration (AWS Comprehend)",
      "status": "open",
      "assigned_to": null
    }
  ],
  "created_at": "2025-10-10T14:08:00Z"
}

Response (200 OK - YAML):
config_metadata:
  config_id: uuid
  client_id: uuid
  version: 1
  environment: staging
  created_at: 2025-10-10T14:08:00Z

system_prompt:
  role: customer_support_agent
  instructions: "You are a helpful customer support agent..."
  constraints:
    - Never share customer PII
    - Escalate to human if user is frustrated
  tone: friendly_professional

tools_available:
  - tool_name: fetch_order_status
    status: implemented
  - tool_name: initiate_refund
    status: missing
    github_issue: https://github.com/workflow/tools/issues/156
...
```

**3. Update Config via Webchat**
```http
POST /api/v1/automation/configs/{config_id}/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "Change the LLM temperature to 0.5 and add a tool for checking product availability",
  "session_id": "uuid"
}

Response (200 OK):
{
  "config_id": "uuid",
  "chat_response": "I've updated the LLM temperature to 0.5. I've also added a new tool 'check_product_availability' to the tools_needed list. Since this tool doesn't exist yet, I've created GitHub issue #157 for implementation. Would you like to review the updated config?",
  "changes_made": [
    {
      "section": "llm_config.parameters.temperature",
      "old_value": 0.7,
      "new_value": 0.5
    },
    {
      "section": "tools_needed",
      "action": "added",
      "new_tool": {
        "tool_name": "check_product_availability",
        "input_schema": {"product_id": "string"},
        "output_schema": {"available": "boolean", "stock_count": "number"}
      }
    }
  ],
  "github_issue_created": {
    "issue_number": 157,
    "url": "https://github.com/workflow/tools/issues/157",
    "title": "Implement check_product_availability tool"
  },
  "version": 2,
  "validation_status": "passed"
}
```

**4. Manual Edit Config (Canvas)**
```http
PATCH /api/v1/automation/configs/{config_id}
Authorization: Bearer {jwt_token}
Content-Type: text/yaml

Request Body (YAML):
system_prompt:
  instructions: "You are a VERY helpful customer support agent..."
  constraints:
    - Never share customer PII
    - Escalate to human if user is frustrated
    - Always verify user identity before refunds

Response (200 OK):
{
  "config_id": "uuid",
  "version": 3,
  "validation_status": "passed",
  "changes_detected": [
    {
      "field": "system_prompt.instructions",
      "change_type": "modified"
    },
    {
      "field": "system_prompt.constraints",
      "change_type": "added_item",
      "new_item": "Always verify user identity before refunds"
    }
  ],
  "updated_at": "2025-10-10T14:25:00Z"
}
```

**5. Validate Config**
```http
POST /api/v1/automation/configs/{config_id}/validate
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "config_id": "uuid",
  "validation_status": "passed",
  "checks": [
    {"check": "json_schema_compliance", "status": "passed"},
    {"check": "required_fields_present", "status": "passed"},
    {"check": "tool_dependencies_met", "status": "failed", "details": "Tool 'initiate_refund' not implemented"},
    {"check": "integration_dependencies_met", "status": "failed", "details": "Integration 'sentiment_api' not configured"},
    {"check": "llm_config_valid", "status": "passed"},
    {"check": "circular_dependencies", "status": "passed"}
  ],
  "warnings": [
    "2 tools pending implementation - config will work with reduced functionality",
    "1 integration pending - sentiment-based escalation will not work"
  ],
  "deployment_ready": false,
  "deployment_blocked_by": [
    "Tool initiate_refund (GitHub issue #156)",
    "Integration sentiment_api (GitHub issue #89)"
  ]
}
```

**6. Deploy Config**
```http
POST /api/v1/automation/configs/{config_id}/deploy
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "environment": "production",
  "deployment_strategy": "blue_green",
  "rollout_percent": 10,
  "auto_rollback": true,
  "rollback_on_error_rate": 0.05
}

Response (202 Accepted):
{
  "config_id": "uuid",
  "deployment_id": "uuid",
  "status": "deploying",
  "environment": "production",
  "strategy": "blue_green",
  "rollout_status": {
    "blue_version": 2,
    "green_version": 3,
    "traffic_split": {
      "blue": 90,
      "green": 10
    }
  },
  "monitoring_url": "https://monitoring.workflow.com/deployments/uuid",
  "estimated_completion": "2025-10-10T14:35:00Z"
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "config_deployed",
  "config_id": "uuid",
  "deployment_id": "uuid",
  "environment": "production",
  "version": 3,
  "timestamp": "2025-10-10T14:30:00Z"
}
```

**7. GitHub Webhook - Tool/Integration Completed**
```http
POST /api/v1/automation/webhooks/github
Content-Type: application/json
X-GitHub-Event: issues
X-Hub-Signature-256: sha256_signature

Request Body (from GitHub):
{
  "action": "closed",
  "issue": {
    "number": 156,
    "title": "Implement initiate_refund tool",
    "labels": [{"name": "tool"}, {"name": "priority-high"}]
  },
  "repository": {
    "name": "workflow-tools"
  }
}

Response (200 OK):
{
  "received": true,
  "config_updates": [
    {
      "config_id": "uuid",
      "tool_name": "initiate_refund",
      "status_updated": "implemented",
      "version_incremented": 4
    }
  ]
}

Internal Event Published to Kafka:
Topic: config_events
{
  "event_type": "tool_attached_to_config",
  "config_id": "uuid",
  "tool_name": "initiate_refund",
  "github_issue": 156,
  "timestamp": "2025-10-12T10:00:00Z"
}

Hot-Reload Event Published:
Topic: config_reload
{
  "event_type": "config_updated",
  "config_id": "uuid",
  "version": 4,
  "changes": ["tool_initiate_refund_now_available"],
  "reload_required": true,
  "timestamp": "2025-10-12T10:00:05Z"
}
```

**Rate Limiting:**
- 50 config generations per day per tenant
- 100 config updates per hour per config
- 10 deployments per hour per tenant
- 1000 API requests per minute per tenant

#### Frontend Components

**1. Config Generation Wizard**
- Component: `ConfigGenerationWizard.tsx`
- Features:
  - PRD summary review
  - Config type selector (chatbot, voicebot, hybrid)
  - Environment selector (staging, production)
  - Auto-population preview
  - Dependency checker (tools, integrations)

**2. Config Editor (Split View)**
- Component: `ConfigEditor.tsx`
- Features:
  - Left: Webchat for conversational editing
  - Right: YAML canvas editor (Monaco Editor)
  - Syntax highlighting and validation
  - Auto-complete for config fields
  - Real-time validation indicators
  - Diff viewer for changes

**3. GitHub Integration Dashboard**
- Component: `GitHubIntegrationDashboard.tsx`
- Features:
  - Issue tracker (tools, integrations)
  - Status timeline (open → in progress → closed)
  - Developer assignment interface
  - Auto-update notifications
  - Issue dependency graph

**4. Deployment Manager**
- Component: `DeploymentManager.tsx`
- Features:
  - Blue-green deployment controls
  - Traffic split slider
  - Rollout monitoring (error rates, latency)
  - Auto-rollback configuration
  - Deployment history log

**5. Config Validation Panel**
- Component: `ConfigValidationPanel.tsx`
- Features:
  - Real-time validation checks
  - Error/warning categorization
  - Dependency status (tools, integrations)
  - Deployment readiness indicator
  - Fix suggestions

**State Management:**
- Zustand for config editor state
- Monaco Editor for YAML editing
- React Query for API data fetching
- WebSocket for real-time GitHub updates
- Service Worker for offline config drafts

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Platform Engineer**
   - Role: Reviews configs, manages deployments, monitors hot-reloads
   - Access: Full access to all configs and deployments
   - Permissions: admin:configs, deploy:production, manage:github_integration
   - Workflows: Reviews auto-generated configs, validates deployments, troubleshoots issues

2. **Developer (Tools/Integrations)**
   - Role: Implements missing tools and integrations from GitHub issues
   - Access: Read access to configs, write access to tool/integration repos
   - Permissions: read:configs, implement:tools, implement:integrations
   - Workflows: Receives GitHub issue assignment, implements tool/integration, closes issue (triggers auto-update)
   - Approval: Code review required before merge (triggers config attachment)

3. **Client Technical Contact**
   - Role: Reviews config before deployment, provides integration credentials
   - Access: Read-only access to assigned config
   - Permissions: read:assigned_config, approve:deployment
   - Workflows: Reviews config, provides API keys for integrations, approves production deployment
   - Approval: Required for production deployment

**AI Agents:**

1. **Config Generation Agent**
   - Responsibility: Converts PRD to YAML config, identifies dependencies, creates GitHub issues
   - Tools: YAML generators, JSON Schema validators, GitHub API, template engine
   - Autonomy: Fully autonomous for standard configs
   - Escalation: Platform Engineer review for complex custom logic

2. **Dependency Tracker Agent**
   - Responsibility: Monitors GitHub issues, auto-updates configs when tools/integrations ready
   - Tools: GitHub webhooks, config updaters, validation checkers
   - Autonomy: Fully autonomous
   - Escalation: Alerts Platform Engineer on validation failures after auto-update

3. **Deployment Orchestration Agent**
   - Responsibility: Manages blue-green deployments, monitors rollout health, triggers rollbacks
   - Tools: Kubernetes API, monitoring APIs (Prometheus), traffic routers
   - Autonomy: Fully autonomous for standard deployments
   - Escalation: Platform Engineer intervention for rollback failures

4. **Hot-Reload Agent**
   - Responsibility: Propagates config changes to running services, manages graceful reloads
   - Tools: Kafka producers, service discovery APIs, health checkers
   - Autonomy: Fully autonomous
   - Escalation: Alerts on reload failures, automatic rollback if >10% services fail to reload

**Approval Workflows:**
1. Config Generation → Auto-approved, Platform Engineer notification
2. Config Updates (via Chat/Canvas) → Auto-applied to staging, Platform Engineer approval for production
3. GitHub Issue Creation → Auto-created, Developer assignment by Platform Engineer
4. Tool/Integration Attachment → Auto-attached on GitHub issue closure, validation check before hot-reload
5. Production Deployment → Client Technical Contact + Platform Engineer approval required
6. Hot-Reload → Auto-executed, alerts on failures

---

*Due to length constraints, the remaining microservices (8-15) will be documented in MICROSERVICES_ARCHITECTURE_PART3.md*

**Remaining Services:**
8. Agent Orchestration Service
9. Voice Agent Service
10. Configuration Management Service
11. Monitoring Engine Service
12. Analytics Service
13. Customer Success Service
14. Support Engine Service
15. CRM Integration Service

---
