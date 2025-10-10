# Microservices Architecture Specification (Part 2)
## Complete Workflow Automation System - Remaining Services

---

## 6. PRD Builder & Configuration Workspace Service

**Service Consolidation**: Service 6 now includes functionality previously in Service 19 (Client Configuration Portal). This consolidation unifies the client-facing workspace, providing a single location for both PRD creation and self-service configuration management.

#### Objectives
- **Primary Purpose**: AI-powered generation of comprehensive Product Requirement Documents (PRDs) for chatbot and voicebot products through conversational interface with cross-questioning and village knowledge integration, plus self-service configuration management with version control and conversational editing
- **Business Value**:
  - PRD Creation: Reduces PRD creation from 20+ hours to 2-3 hours, leverages multi-client learnings, ensures completeness through AI-driven edge case analysis
  - Configuration Management: 80% reduction in configuration support tickets, instant config changes, client autonomy, improved time-to-value
- **Product Differentiation**: Supports both chatbot (LangGraph-based) and voicebot (LiveKit-based) product types with product-specific requirements, sprint planning, and integration architecture
- **Scope Boundaries**:
  - **Does**: Generate PRDs via webchat UI, integrate village knowledge, suggest new objectives, design A/B flows, plan integrations and escalations, differentiate chatbot vs voicebot requirements, enable conversational config via AI agent, visual config dashboard, member permission management, version control UI, change classification, config preview/testing, rollback management
  - **Does Not**: Write code, deploy solutions, manage infrastructure, validate schemas (Configuration Management Service does), implement tools (developers do)

#### Requirements

**Functional Requirements:**

*PRD Builder:*
1. Conversational PRD generation via webchat UI with cross-questioning
2. Integration with village knowledge (what's working for other clients)
3. Automatic objective suggestion based on business context and AI intelligence
4. A/B flow design for each objective with KPI measurement framework
5. Baseline data requirement assessment (what data exists, what's needed)
6. Integration architecture definition (when to escalate, tool ecosystem mapping)
7. Sprint planning with 95% automation roadmap (12-month timeline)
8. Log event tracking for uptime monitoring
9. Iterative refinement until client satisfaction

*Configuration Management (from Service 19):*
10. Natural language configuration via conversational AI agent
11. Visual configuration dashboard with product-specific controls (chatbot vs voicebot)
12. Member-based permission system for configuration changes
13. Git-style version control with commit messages and rollback
14. Change classification (system_prompt, tool, voice_param, integration, etc.)
15. Real-time configuration preview and testing sandbox
16. Automated change risk assessment with approval workflows
17. Human agent coordination for complex configuration needs

*Dependency Tracking (Feature 5):*
18. Automatic dependency extraction during PRD creation (API keys, webhooks, credentials, approvals, data access)
19. Dependency categorization by type (technical, business, compliance, data)
20. Dependency ownership assignment with contact tracking
21. Due date management with timeline visualization
22. Automated follow-up email scheduling based on dependency status and due dates
23. Dependency status tracking (pending, in_progress, blocked, completed, overdue)
24. Dependency completion verification workflow
25. Escalation alerts for overdue dependencies (7-day warning, 14-day escalation)
26. Dependency impact analysis (blocking vs non-blocking)
27. Integration with Service 20 for automated follow-up communications

**Non-Functional Requirements:**
- Initial PRD generation: <15 minutes for standard use case
- Support 50 concurrent PRD sessions
- Village knowledge retrieval: <2s latency
- Configuration change application: <2 minutes from request to live deployment
- Conversational config response time: <3s for classification and preview generation
- Support 10,000+ organizations with isolated configuration access
- 99.9% uptime for PRD generation and configuration portal
- Multi-client knowledge isolation (no data leakage)
- Version history retention: 1 year minimum

**Dependencies:**
- **NDA Generator** *[See MICROSERVICES_ARCHITECTURE.md Service 3]* (consumes nda_fully_signed event to trigger PRD session)
- **Demo Generator** *[See MICROSERVICES_ARCHITECTURE.md Service 2]* (demo data provides use case context for PRD)
- **Research Engine** *[See MICROSERVICES_ARCHITECTURE.md Service 1]* (volume predictions inform PRD volume requirements)
- **Agent Orchestration Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 8]* (village knowledge retrieval, applies chatbot config changes)
- **Voice Agent Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 9]* (applies voicebot config changes)
- **Pricing Model Generator** *[See MICROSERVICES_ARCHITECTURE.md Service 4]* (PRD approval triggers pricing generation via prd_approved event)
- **Configuration Management Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 10]* (stores/distributes configs, validates schemas)
- **Automation Engine** *[See Service 7 below]* (initial config generation)
- **Organization Management Service** *[See MICROSERVICES_ARCHITECTURE.md Service 0]* (member roles and permissions)
- **Analytics Service** (historical KPI data for benchmarking)

**Data Storage:**
- PostgreSQL: PRD metadata, versions, client feedback, approval status, config change log, member permissions, version metadata, approval workflows
- Qdrant: Village knowledge embeddings (successful patterns, KPIs, flows)
- Neo4j: Integration dependency graphs, workflow relationships
- S3: PRD documents (markdown, PDF exports), version snapshots, config diff visualizations
- Redis: Conversational state (chat context for both PRD and config), config draft cache

#### Features

**Must-Have:**

*PRD Builder Features:*
1. ✅ Conversational PRD builder with AI cross-questioning
2. ✅ Village knowledge integration (multi-tenant learnings)
3. ✅ Objective suggestion engine (cross-sell, upsell, surveys)
4. ✅ A/B flow designer with visual workflow builder
5. ✅ KPI framework definition with baseline assessment
6. ✅ Integration architecture planner (escalation rules, tool mapping)
7. ✅ Sprint roadmap generator (12-month automation plan)
8. ✅ Collaborative editing with client feedback loop
9. ✅ **Help button with shareable code generation** (expiring codes for human agent collaboration)
10. ✅ **Real-time collaborative canvas** (multi-user editing with cursor tracking)
11. ✅ **Human agent join capability** (agents can join PRD sessions to help clients)
12. ✅ **Collaboration chat** (side-by-side chat during PRD building)

*Configuration Management Features (from Service 19):*
13. ✅ Conversational configuration agent with change classification
14. ✅ Visual dashboard for chatbot configuration (system prompt, tools, integrations)
15. ✅ Visual dashboard for voicebot configuration (voice parameters, model settings, stop speaking plan)
16. ✅ Member permission matrix (Admin, Config Manager, Viewer, Developer roles)
17. ✅ Git-style version control with commit messages
18. ✅ Side-by-side diff viewer (before/after comparison)
19. ✅ One-click rollback to previous versions
20. ✅ Configuration testing sandbox with preview
21. ✅ Change risk assessment (low/medium/high) with automated approval for low-risk changes
22. ✅ Human agent escalation for complex configuration requests

*Dependency Tracking Features (Feature 5):*
23. ✅ Automatic dependency detection during PRD generation
24. ✅ Dependency dashboard with status overview
25. ✅ Dependency categorization and ownership management
26. ✅ Timeline visualization with due dates
27. ✅ Automated follow-up email scheduling via Service 20
28. ✅ Overdue dependency alerts with escalation workflow
29. ✅ Dependency completion verification and sign-off
30. ✅ Blocking dependency identification and impact analysis

**Nice-to-Have:**

*PRD Builder:*
31. 🔄 Auto-generated user stories from PRD
32. 🔄 Competitive analysis integration
33. 🔄 Risk assessment and mitigation planning
34. 🔄 ROI calculator based on automation metrics

*Configuration Management:*
35. 🔄 AI-powered configuration optimization suggestions
36. 🔄 Configuration templates marketplace (share configs across organizations)
37. 🔄 Automated regression testing for config changes
38. 🔄 Configuration import/export (JSON)
39. 🔄 Multi-environment support (dev/staging/production branches)

*Dependency Tracking:*
40. 🔄 Dependency templates for common integration patterns
41. 🔄 Slack/Teams integration for dependency notifications
42. 🔄 Dependency health score and risk metrics
43. 🔄 Automated dependency resolution suggestions

**Feature Interactions:**

*PRD Builder:*
- NDA signing → Auto-triggers PRD session (consumes nda_fully_signed event)
- PRD approval → Triggers pricing model generation (publishes prd_approved event to prd_events topic)
- Pricing completion → Proposal generation uses both PRD and pricing data
- Village knowledge → Suggests objectives client didn't request
- Help button clicked → Generates shareable code → Publishes help_requested event → Human agent joins → Real-time collaboration begins
- Collaboration ended → Session resumes with AI PRD builder → Client continues independently
- Requirements form data → Validates client-stated volumes against PRD technical requirements

*Configuration Management (from Service 19):*
- Client requests config change via chat → Agent classifies → Shows preview → Client approves → Hot-reload applied
- Visual slider changed (voicebot speed) → Immediate preview in test call → Save creates new version
- Risky change detected → Requires organization admin approval → Sends notification
- Configuration error after deployment → Auto-rollback triggered → Platform engineer alerted

*Dependency Tracking (Feature 5):*
- PRD generation → AI extracts dependencies from requirements → Creates dependency records with due dates
- Dependency created → Scheduled follow-up emails sent via Service 20 based on due date
- Due date approaching (7 days) → Warning email sent to dependency owner
- Dependency overdue (14 days) → Escalation email sent to onboarding specialist and client admin
- Dependency completed → Triggers verification workflow → Updates PRD implementation status
- Blocking dependency overdue → Alerts Automation Engine (Service 7) to pause deployment
- All dependencies completed → PRD marked as ready for implementation → Publishes prd_dependencies_completed event

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
  "product_types": ["chatbot", "voicebot"],  // Required: chatbot | voicebot | both
  "initial_context": {
    "business_type": "e-commerce",
    "use_cases": ["customer_support", "lead_qualification"],
    "current_tools": ["salesforce", "zendesk", "shopify"],
    "team_size": 15,
    "customer_volume_monthly": 5000,
    "chatbot_channels": ["website", "whatsapp"],  // Only if chatbot in product_types
    "voicebot_channels": ["inbound_calls", "outbound_calls"]  // Only if voicebot in product_types
  },
  "enable_village_knowledge": true
}

Response (201 Created):
{
  "session_id": "uuid",
  "prd_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "status": "active",
  "webchat_url": "https://prd.workflow.com/chat/uuid",
  "ai_agent": {
    "name": "PRD Builder Assistant",
    "capabilities": ["cross_questioning", "objective_suggestion", "flow_design", "knowledge_integration"],
    "product_context": "Building PRD for chatbot (LangGraph) and voicebot (LiveKit) products"
  },
  "initial_message": "I'll help you build a comprehensive PRD for your chatbot and voicebot products. Let's start with chatbot requirements. What are the top 3 customer support pain points you want to solve via web chat?",
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
  "product_types": ["chatbot", "voicebot"],
  "status": "in_progress",
  "completion_percent": 75,
  "sections": {
    "executive_summary": "This PRD outlines the implementation of AI-powered customer support automation (chatbot via LangGraph and voicebot via LiveKit) for Acme Corp...",
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
      "product_type": "chatbot",  // Integrations are chatbot-specific (voicebots don't use external integrations)
      "existing_tools": ["salesforce", "zendesk", "shopify"],
      "new_integrations_needed": [
        {
          "tool": "sentiment_api",
          "product_compatibility": ["chatbot"],  // Only applies to chatbot product
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
    "sprint_roadmap_chatbot": {
      "product_type": "chatbot",
      "framework": "LangGraph two-node workflow (agent + tools)",
      "sprint_1_2": {
        "goal": "Basic chatbot with intent classification",
        "automation_target": "20%",
        "deliverables": ["intent_classifier", "zendesk_integration", "basic_responses", "langgraph_setup"]
      },
      "sprint_3_4": {
        "goal": "A/B flow implementation",
        "automation_target": "40%",
        "deliverables": ["ab_framework", "kpi_tracking", "shopify_integration", "external_integrations"]
      },
      "sprint_5_12": {
        "goal": "Advanced personalization and optimization",
        "automation_target": "80%",
        "deliverables": ["sentiment_analysis", "upsell_engine", "workflow_optimization"]
      },
      "month_12_target": "95% automation for Tier 1 queries"
    },
    "sprint_roadmap_voicebot": {
      "product_type": "voicebot",
      "framework": "LiveKit VoicePipelineAgent (STT-LLM-TTS)",
      "sprint_1_2": {
        "goal": "Basic voicebot with LiveKit integration",
        "automation_target": "15%",
        "deliverables": ["livekit_setup", "deepgram_stt", "elevenlabs_tts", "basic_call_handling"]
      },
      "sprint_3_4": {
        "goal": "Advanced voice features",
        "automation_target": "35%",
        "deliverables": ["barge_in_support", "sentiment_detection", "call_transfer", "sip_integration"]
      },
      "sprint_5_12": {
        "goal": "Voice optimization and analytics",
        "automation_target": "75%",
        "deliverables": ["latency_optimization", "voice_analytics", "multi_language_support"]
      },
      "month_12_target": "90% automation for inbound call handling"
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
  "product_types": ["chatbot", "voicebot"],
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
    "automation_engine_json_generation",
    "github_issues_creation",
    "sprint_planning"
  ]
}

Event Published to Kafka:
Topic: prd_events
{
  "event_type": "prd_approved",
  "prd_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "organization_id": "uuid",
  "approved_by_user_id": "uuid",
  "timestamp": "2025-10-10T14:00:00Z"
}
```

**7. Request Help (Generate Shareable Code)**
```http
POST /api/v1/prd/sessions/{session_id}/request-help
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "help_reason": "Need guidance on integration architecture for complex API requirements",
  "urgency": "medium",
  "context": {
    "current_section": "integration_architecture",
    "specific_question": "How to handle OAuth2 flows for third-party integrations?"
  }
}

Response (201 Created):
{
  "help_request_id": "uuid",
  "session_id": "uuid",
  "shareable_code": "HELP-ACME-X7K9-2025",
  "expires_at": "2025-10-04T14:00:00Z",
  "join_url": "https://prd.workflow.com/collaborate/HELP-ACME-X7K9-2025",
  "status": "waiting_for_agent",
  "estimated_wait_time": "5 minutes",
  "message": "Your help request has been created. Share the code 'HELP-ACME-X7K9-2025' with our support team, or wait for an agent to join automatically."
}

Event Published to Kafka:
Topic: collaboration_events
{
  "event_type": "help_requested",
  "help_request_id": "uuid",
  "session_id": "uuid",
  "organization_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "requested_by": "uuid",
  "urgency": "medium",
  "timestamp": "2025-10-04T12:00:00Z"
}
```

**8. Join PRD Session (Human Agent)**
```http
POST /api/v1/prd/collaborate/join
Authorization: Bearer {agent_jwt_token}
Content-Type: application/json

Request Body:
{
  "shareable_code": "HELP-ACME-X7K9-2025",
  "agent_id": "uuid",
  "agent_name": "Mike Thompson"
}

Response (200 OK):
{
  "collaboration_session_id": "uuid",
  "prd_session_id": "uuid",
  "organization": {
    "organization_id": "uuid",
    "organization_name": "Acme Corp"
  },
  "client_users": [
    {
      "user_id": "uuid",
      "full_name": "John Doe",
      "role": "admin",
      "currently_active": true
    }
  ],
  "session_context": {
    "prd_id": "uuid",
    "completion_percent": 65,
    "current_section": "integration_architecture",
    "help_reason": "Need guidance on integration architecture for complex API requirements"
  },
  "collaboration_url": "https://prd.workflow.com/collaborate/uuid",
  "capabilities": {
    "can_chat": true,
    "can_edit_canvas": true,
    "can_view_prd": true,
    "can_suggest_changes": true
  },
  "joined_at": "2025-10-04T12:05:00Z"
}

Event Published to Kafka:
Topic: collaboration_events
{
  "event_type": "agent_joined_session",
  "collaboration_session_id": "uuid",
  "session_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "agent_id": "uuid",
  "timestamp": "2025-10-04T12:05:00Z"
}
```

**9. Send Collaboration Chat Message**
```http
POST /api/v1/prd/collaborate/{collaboration_session_id}/chat
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "For OAuth2 flows, I recommend using the Authorization Code flow with PKCE. I'll add this to the integration architecture section.",
  "attachments": [
    {
      "type": "code_snippet",
      "content": "// OAuth2 PKCE Flow Example\nconst authUrl = generateAuthUrl({ flow: 'pkce', ... });"
    }
  ],
  "metadata": {
    "sender_type": "human_agent",
    "sender_name": "Mike Thompson"
  }
}

Response (200 OK):
{
  "collaboration_session_id": "uuid",
  "message_id": "uuid",
  "message": "For OAuth2 flows, I recommend using the Authorization Code flow with PKCE. I'll add this to the integration architecture section.",
  "sender": {
    "user_id": "uuid",
    "name": "Mike Thompson",
    "type": "human_agent"
  },
  "timestamp": "2025-10-04T12:10:00Z",
  "delivered_to": [
    {"user_id": "uuid", "name": "John Doe", "delivered_at": "2025-10-04T12:10:00Z"}
  ]
}

WebSocket Broadcast to Session:
{
  "event": "new_chat_message",
  "collaboration_session_id": "uuid",
  "message_id": "uuid",
  "sender": "Mike Thompson (Support Agent)",
  "message": "...",
  "timestamp": "2025-10-04T12:10:00Z"
}
```

**10. Edit Canvas (Collaborative PRD Editing)**
```http
POST /api/v1/prd/collaborate/{collaboration_session_id}/canvas/edit
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "section": "integration_architecture.oauth_flows",
  "operation": "add",
  "content": {
    "flow_name": "OAuth2 with PKCE",
    "description": "Authorization Code flow with Proof Key for Code Exchange for enhanced security",
    "tools": ["salesforce", "hubspot", "google_workspace"],
    "implementation_notes": "Use PKCE to prevent authorization code interception attacks"
  },
  "editor": {
    "user_id": "uuid",
    "name": "Mike Thompson",
    "type": "human_agent"
  }
}

Response (200 OK):
{
  "collaboration_session_id": "uuid",
  "edit_id": "uuid",
  "section": "integration_architecture.oauth_flows",
  "operation": "add",
  "status": "applied",
  "prd_version": 5,
  "applied_at": "2025-10-04T12:12:00Z"
}

WebSocket Broadcast to Session:
{
  "event": "canvas_updated",
  "collaboration_session_id": "uuid",
  "edit_id": "uuid",
  "section": "integration_architecture.oauth_flows",
  "operation": "add",
  "editor": "Mike Thompson (Support Agent)",
  "content": {...},
  "timestamp": "2025-10-04T12:12:00Z"
}

Event Published to Kafka:
Topic: collaboration_events
{
  "event_type": "canvas_edited",
  "collaboration_session_id": "uuid",
  "prd_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "editor_id": "uuid",
  "editor_type": "human_agent",
  "section": "integration_architecture.oauth_flows",
  "timestamp": "2025-10-04T12:12:00Z"
}
```

**11. End Collaboration Session**
```http
POST /api/v1/prd/collaborate/{collaboration_session_id}/end
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "ended_by": "uuid",
  "end_reason": "issue_resolved",
  "summary": "Added OAuth2 PKCE flow guidance and updated integration architecture section. Client is ready to continue independently.",
  "follow_up_required": false
}

Response (200 OK):
{
  "collaboration_session_id": "uuid",
  "status": "ended",
  "duration_minutes": 15,
  "ended_at": "2025-10-04T12:20:00Z",
  "ended_by": {
    "user_id": "uuid",
    "name": "Mike Thompson",
    "type": "human_agent"
  },
  "session_summary": {
    "chat_messages": 8,
    "canvas_edits": 3,
    "sections_updated": ["integration_architecture"],
    "client_satisfaction": null
  },
  "prd_session_continues": true
}

Event Published to Kafka:
Topic: collaboration_events
{
  "event_type": "collaboration_ended",
  "collaboration_session_id": "uuid",
  "session_id": "uuid",
  "product_types": ["chatbot", "voicebot"],
  "duration_minutes": 15,
  "ended_by": "uuid",
  "timestamp": "2025-10-04T12:20:00Z"
}
```

**Kafka Topic Documentation:**
- **Topic Name**: `collaboration_events`
- **Purpose**: Tracks human agent collaboration sessions with clients on PRD documents
- **Producers**: PRD Builder Service
- **Consumers**: Monitoring Engine, Analytics Service, Customer Success Service
- **Event Types**: `help_requested`, `agent_joined_session`, `canvas_edited`, `collaboration_ended`
- **Retention**: 30 days
- **Partitioning**: By organization_id for ordering guarantees

**12. Get Active Collaboration Sessions (Agent Dashboard)**
```http
GET /api/v1/prd/collaborate/active
Authorization: Bearer {agent_jwt_token}

Response (200 OK):
{
  "active_sessions": [
    {
      "help_request_id": "uuid",
      "shareable_code": "HELP-ACME-X7K9-2025",
      "organization_name": "Acme Corp",
      "requested_by": "John Doe",
      "help_reason": "Need guidance on integration architecture",
      "urgency": "medium",
      "wait_time_minutes": 3,
      "status": "waiting_for_agent"
    },
    {
      "collaboration_session_id": "uuid",
      "shareable_code": "HELP-BETA-M3P8-2025",
      "organization_name": "Beta Corp",
      "client_users": ["Sarah Johnson"],
      "agent": "Alice Chen",
      "started_at": "2025-10-04T12:00:00Z",
      "duration_minutes": 10,
      "status": "in_progress"
    }
  ],
  "queue_length": 2,
  "average_wait_time_minutes": 4
}
```

**WebSocket - Real-Time Collaboration**
```
wss://prd.workflow.com/collaborate/{collaboration_session_id}
Authorization: Bearer {jwt_token}

Server → Client Events:

1. Agent Joined:
{
  "event": "agent_joined",
  "agent_id": "uuid",
  "agent_name": "Mike Thompson",
  "timestamp": "2025-10-04T12:05:00Z"
}

2. User Typing Indicator:
{
  "event": "user_typing",
  "user_id": "uuid",
  "user_name": "John Doe",
  "user_type": "client",
  "timestamp": "2025-10-04T12:10:00Z"
}

3. Canvas Cursor Position (Real-Time):
{
  "event": "cursor_moved",
  "user_id": "uuid",
  "user_name": "Mike Thompson",
  "section": "integration_architecture",
  "position": {"x": 245, "y": 678},
  "timestamp": "2025-10-04T12:11:00Z"
}

4. Canvas Selection:
{
  "event": "selection_changed",
  "user_id": "uuid",
  "user_name": "John Doe",
  "section": "integration_architecture.oauth_flows",
  "timestamp": "2025-10-04T12:11:30Z"
}

5. Collaboration Ended:
{
  "event": "collaboration_ended",
  "ended_by": "uuid",
  "summary": "Issue resolved. Client ready to continue.",
  "timestamp": "2025-10-04T12:20:00Z"
}
```

**Rate Limiting:**
- 10 PRD sessions per day per tenant
- 200 chat messages per hour per session
- 5 help requests per day per PRD session
- 50 canvas edits per hour per collaboration session
- 1000 API requests per minute per tenant

#### Post-Launch Flow Modification

**Purpose**: Enable clients to request modifications to deployed chatbot/voicebot flows after launch without creating a new PRD from scratch, with impact analysis and rollback support.

**Modification Types:**

1. **Flow Logic Changes:**
   - Add/remove conversation steps
   - Change step order or branching logic
   - Update conditional routing rules
   - Modify error handling paths

2. **Content Updates:**
   - Update response templates
   - Modify system prompts
   - Change greeting messages
   - Update FAQ answers

3. **Integration Changes:**
   - Add new external integrations (e.g., add Slack after launching with Zendesk)
   - Remove deprecated integrations
   - Update integration parameters (API endpoints, credentials)

4. **Performance Optimizations:**
   - Adjust timeout values
   - Modify retry logic
   - Change escalation thresholds
   - Update caching strategies

**API Specification:**

**1. Request Flow Modification**
```http
POST /api/v1/prd/{prd_id}/flow-modifications
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "prd_id": "uuid",
  "modification_type": "flow_logic_change",  // flow_logic_change | content_update | integration_change | performance_optimization
  "modification_request": {
    "title": "Add SMS notification step after ticket creation",
    "description": "Currently, users only get email confirmation. We want to add SMS notification as an additional step.",
    "affected_flows": ["support_ticket_creation_flow"],
    "priority": "medium",  // low | medium | high | urgent
    "business_justification": "Customer feedback shows 60% prefer SMS over email for immediate notifications",
    "requested_by": {
      "name": "Jane Doe",
      "email": "jane@acmecorp.com",
      "role": "Product Manager"
    }
  },
  "proposed_changes": {
    "add_steps": [
      {
        "step_id": "send_sms_notification",
        "step_description": "Send SMS confirmation with ticket number",
        "position_after": "create_ticket",
        "tool_required": "twilio_send_sms",
        "tool_status": "implemented"
      }
    ],
    "update_steps": [],
    "remove_steps": []
  }
}

Response (201 Created):
{
  "modification_id": "mod_uuid",
  "prd_id": "uuid",
  "modification_type": "flow_logic_change",
  "status": "impact_analysis_pending",
  "impact_analysis": {
    "status": "queued",
    "estimated_completion": "2025-10-16T10:00:00Z"
  },
  "created_at": "2025-10-15T20:00:00Z",
  "tracking_number": "MOD-2025-00456"
}

Event Published to Kafka:
Topic: prd_events
{
  "event_type": "flow_modification_requested",
  "modification_id": "mod_uuid",
  "prd_id": "uuid",
  "client_id": "uuid",
  "modification_type": "flow_logic_change",
  "timestamp": "2025-10-15T20:00:00Z"
}
```

**2. Submit Impact Analysis**
```http
POST /api/v1/prd/flow-modifications/{modification_id}/impact-analysis
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "modification_id": "mod_uuid",
  "impact_assessment": {
    "technical_complexity": "low",  // low | medium | high
    "estimated_implementation_hours": 4,
    "affected_components": [
      "JSON config (support_ticket_creation_flow)",
      "Tool execution layer (Twilio integration)"
    ],
    "dependencies": [
      {
        "dependency": "twilio_send_sms tool",
        "status": "already_implemented",
        "action_required": "none"
      }
    ],
    "testing_requirements": [
      "Unit test new step",
      "Integration test with Twilio",
      "End-to-end flow test",
      "Load test (100 concurrent SMS sends)"
    ],
    "rollback_strategy": "Config version rollback to previous state",
    "risks": [
      "SMS delivery failures if Twilio is down (mitigation: fallback to email only)",
      "Additional cost per SMS sent (estimated $0.01/message)"
    ]
  },
  "cost_estimate": {
    "implementation_cost_usd": 500,  // Developer time
    "ongoing_cost_per_month_usd": 150,  // SMS costs (15K messages/month * $0.01)
    "cost_breakdown": "Assumes 15,000 tickets/month. SMS cost: $0.01/message."
  },
  "timeline": {
    "implementation_days": 2,
    "testing_days": 1,
    "deployment_window": "2025-10-20 - 2025-10-22"
  },
  "recommendation": "Approve. Low technical complexity, high customer value. Recommend phased rollout (10% traffic for 24h, then 100%).",
  "analyzed_by": "platform_engineer_uuid",
  "analyzed_at": "2025-10-16T09:30:00Z"
}

Response (200 OK):
{
  "modification_id": "mod_uuid",
  "impact_analysis_id": "analysis_uuid",
  "status": "awaiting_approval",
  "approval_required_from": ["client_decision_maker", "platform_engineer"],
  "next_steps": [
    "Client reviews cost estimate",
    "Client approves modification",
    "Platform engineer schedules implementation"
  ],
  "submitted_at": "2025-10-16T09:30:00Z"
}
```

**3. Approve/Reject Modification**
```http
PATCH /api/v1/prd/flow-modifications/{modification_id}/approval
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "decision": "approved",  // approved | rejected
  "approval_notes": "Approved. Please proceed with phased rollout as recommended.",
  "approved_by": "client_decision_maker_uuid",
  "approved_at": "2025-10-16T14:00:00Z"
}

Response (200 OK):
{
  "modification_id": "mod_uuid",
  "status": "approved",
  "scheduled_implementation": {
    "start_date": "2025-10-20T10:00:00Z",
    "estimated_completion": "2025-10-22T17:00:00Z",
    "assigned_engineer": "engineer_uuid"
  },
  "updated_at": "2025-10-16T14:00:00Z"
}
```

**4. Track Modification Implementation**
```http
GET /api/v1/prd/flow-modifications/{modification_id}/status
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "modification_id": "mod_uuid",
  "tracking_number": "MOD-2025-00456",
  "status": "in_progress",  // pending | impact_analysis | awaiting_approval | approved | in_progress | testing | deployed | rolled_back | rejected
  "implementation_progress": {
    "current_phase": "testing",
    "phases_completed": ["code_implementation", "unit_testing"],
    "phases_remaining": ["integration_testing", "deployment"],
    "percent_complete": 70
  },
  "deployment_plan": {
    "rollout_strategy": "phased",
    "phase_1": {
      "traffic_percentage": 10,
      "start_date": "2025-10-21T10:00:00Z",
      "status": "completed",
      "success_metrics": {
        "sms_delivery_rate": 0.98,
        "error_rate": 0.01,
        "customer_satisfaction_delta": "+0.3"
      }
    },
    "phase_2": {
      "traffic_percentage": 100,
      "start_date": "2025-10-22T10:00:00Z",
      "status": "scheduled"
    }
  },
  "last_updated": "2025-10-21T16:30:00Z"
}
```

**5. Rollback Modification**
```http
POST /api/v1/prd/flow-modifications/{modification_id}/rollback
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "rollback_reason": "SMS delivery failures exceeded 10% threshold. Reverting to email-only notifications.",
  "initiated_by": "platform_engineer_uuid",
  "initiated_at": "2025-10-21T18:00:00Z"
}

Response (200 OK):
{
  "modification_id": "mod_uuid",
  "status": "rolled_back",
  "rollback_completed_at": "2025-10-21T18:05:00Z",
  "config_version_restored": 3,  // Previous version before modification
  "impact": {
    "affected_conversations": 245,  // In-progress conversations using new flow
    "action_taken": "Completed in-progress conversations with new flow, new conversations use rolled-back flow"
  }
}
```

**6. Get Modification History**
```http
GET /api/v1/prd/{prd_id}/flow-modifications/history
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "prd_id": "uuid",
  "total_modifications": 12,
  "modifications": [
    {
      "modification_id": "mod_uuid_1",
      "tracking_number": "MOD-2025-00456",
      "modification_type": "flow_logic_change",
      "title": "Add SMS notification step after ticket creation",
      "status": "deployed",
      "requested_at": "2025-10-15T20:00:00Z",
      "deployed_at": "2025-10-22T10:00:00Z",
      "implementation_days": 7
    },
    {
      "modification_id": "mod_uuid_2",
      "tracking_number": "MOD-2025-00445",
      "modification_type": "integration_change",
      "title": "Add Slack integration for agent notifications",
      "status": "rolled_back",
      "requested_at": "2025-10-10T15:00:00Z",
      "deployed_at": "2025-10-12T14:00:00Z",
      "rolled_back_at": "2025-10-13T09:00:00Z",
      "rollback_reason": "Slack API rate limiting caused notification delays"
    }
  ]
}
```

**Modification Workflow:**

1. **Request Submission** → 2. **Impact Analysis** → 3. **Client Approval** → 4. **Implementation** → 5. **Testing** → 6. **Phased Deployment** → 7. **Validation** → 8. **Full Rollout** (or **Rollback** if issues detected)

**Integration with JSON Config Management:**

- Modifications generate new JSON config versions via Service 7 (Automation Engine)
- Hot-reload mechanism applies changes without service restart
- Config versioning enables instant rollback to previous state
- In-progress conversations complete with current config version, new conversations use updated version

**Data Storage:**
- **PostgreSQL**: Modification requests, impact analyses, approval logs, deployment history
- **Git**: Version-controlled JSON config snapshots

**Database Schema:**
```sql
CREATE TABLE flow_modifications (
  modification_id UUID PRIMARY KEY,
  prd_id UUID NOT NULL REFERENCES prds(prd_id),
  client_id UUID NOT NULL REFERENCES clients(client_id),
  tracking_number VARCHAR(50) UNIQUE NOT NULL,
  modification_type VARCHAR(100) NOT NULL,
  modification_request JSONB NOT NULL,
  proposed_changes JSONB,
  impact_analysis JSONB,
  cost_estimate JSONB,
  status VARCHAR(50) NOT NULL,  -- pending | impact_analysis | awaiting_approval | approved | in_progress | testing | deployed | rolled_back | rejected
  approved_by UUID,
  approved_at TIMESTAMP,
  deployed_at TIMESTAMP,
  rolled_back_at TIMESTAMP,
  rollback_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_flow_mods_prd ON flow_modifications(prd_id);
CREATE INDEX idx_flow_mods_client ON flow_modifications(client_id);
CREATE INDEX idx_flow_mods_status ON flow_modifications(status);
CREATE INDEX idx_flow_mods_created ON flow_modifications(created_at);

-- Row-Level Security
ALTER TABLE flow_modifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY flow_mods_tenant_isolation ON flow_modifications
  USING (client_id = current_setting('app.current_tenant_id')::UUID);
```

**Integration Points:**
- **Service 7 (Automation Engine)**: Generate updated JSON configs, manage config versions
- **Service 8 (Agent Orchestration)**: Hot-reload updated configs, handle version transitions
- **Service 11 (Monitoring)**: Track post-modification performance metrics
- **Service 12 (Analytics)**: Generate A/B test comparisons (before/after modification)

**Automation:**
- Auto-generate impact analysis for simple content updates (templates, prompts)
- Auto-approve low-risk changes (<$100 cost, <4 implementation hours)
- Auto-rollback if error rate exceeds 5% within first 24 hours of deployment

**Frontend Component:**
- Component: `FlowModificationManager.tsx`
- Features:
  - Visual flow editor showing current vs proposed changes
  - Side-by-side comparison view
  - Impact analysis summary dashboard
  - Approval workflow interface
  - Deployment progress tracker with real-time metrics
  - Rollback button with confirmation dialog

---

### Configuration Management APIs (from Service 19)

**1. Conversational Configuration Chat**
```http
POST /api/v1/client-config/chat
Authorization: Bearer {client_jwt}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "message": "Make the voicebot speak slower and add a refund tool",
  "conversation_id": "uuid",
  "product_type": "voicebot"
}

Response (200 OK):
{
  "response": "I'll help you with that. I've detected two changes:\n\n1. **Voice speed adjustment** (slower)\n   - Current: 1.0x speed\n   - Proposed: 0.7x speed\n   \n2. **Adding refund tool**\n   - Found 'initiate_refund' in our catalog\n   - Status: Implemented and ready\n   \nWould you like me to apply these changes?",
  "detected_changes": [
    {
      "type": "voice_parameter_change",
      "parameter": "speed",
      "current_value": 1.0,
      "proposed_value": 0.7,
      "confidence": 0.95,
      "risk_level": "low"
    },
    {
      "type": "tool_change",
      "action": "add",
      "tool_name": "initiate_refund",
      "tool_status": "implemented",
      "confidence": 0.88,
      "risk_level": "medium"
    }
  ],
  "preview_url": "https://config.workflow.com/preview/uuid",
  "requires_approval": false,
  "conversation_id": "uuid"
}
```

**2. Visual Configuration Update**
```http
POST /api/v1/client-config/visual/update
Authorization: Bearer {client_jwt}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "product_type": "voicebot",
  "changes": {
    "voice_settings": {
      "background_sound": {
        "type": "office",
        "custom_url": null
      },
      "input_min_characters": 10,
      "punctuation_boundaries": [".", "!", "?", "..."],
      "model_settings": {
        "model": "gpt-4",
        "clarity_similarity": 0.75,
        "speed": 0.8,
        "style_exaggeration": 0,
        "optimize_streaming_latency": 3,
        "use_speaker_boost": true,
        "auto_mode": false
      },
      "max_tokens": 150,
      "stop_speaking_plan": {
        "number_of_words": 5,
        "voice_seconds": 0.7,
        "back_off_seconds": 3
      }
    }
  },
  "commit_message": "Adjusted voice speed and interruption handling",
  "apply_immediately": false
}

Response (200 OK):
{
  "version": "v48",
  "status": "pending_approval",
  "preview_url": "https://config.workflow.com/preview/uuid",
  "test_call_url": "https://config.workflow.com/test-call/uuid",
  "validation": {
    "valid": true,
    "warnings": [],
    "estimated_impact": "Low - voice parameter changes only",
    "affected_conversations": 0
  },
  "diff": {
    "voice_settings.speed": {"old": 1.0, "new": 0.8},
    "voice_settings.stop_speaking_plan.number_of_words": {"old": 3, "new": 5}
  },
  "created_at": "2025-10-15T14:23:00Z"
}
```

**3. Get Version History**
```http
GET /api/v1/client-config/{config_id}/versions
Authorization: Bearer {client_jwt}
Query Parameters:
- limit: 20 (default)
- offset: 0

Response (200 OK):
{
  "config_id": "uuid",
  "product_type": "chatbot",
  "current_version": "v48",
  "versions": [
    {
      "version": "v48",
      "commit_message": "Changed tone to casual, added refund tool",
      "author": {
        "user_id": "uuid",
        "email": "jane@acme.com",
        "role": "organization_admin"
      },
      "changes": [
        {"type": "system_prompt_change", "field": "tone", "old_value": "professional", "new_value": "casual"},
        {"type": "tool_change", "action": "add", "tool_name": "initiate_refund"}
      ],
      "risk_level": "low",
      "applied_at": "2025-10-15T14:23:00Z",
      "rollback_available": true
    }
  ],
  "total_versions": 48,
  "pagination": {
    "has_more": true,
    "next_offset": 20
  }
}
```

**4. Rollback to Previous Version**
```http
POST /api/v1/client-config/{config_id}/rollback
Authorization: Bearer {client_jwt}
Content-Type: application/json

Request Body:
{
  "target_version": "v47",
  "reason": "New voice speed causing customer complaints",
  "notify_team": true
}

Response (200 OK):
{
  "config_id": "uuid",
  "rolled_back_from": "v48",
  "rolled_back_to": "v47",
  "new_current_version": "v49",
  "commit_message": "Rollback to v47: New voice speed causing customer complaints",
  "applied_at": "2025-10-15T15:00:00Z",
  "kafka_event_published": true,
  "estimated_propagation_time": "60 seconds"
}
```

**5. Get Member Configuration Permissions**
```http
GET /api/v1/client-config/permissions
Authorization: Bearer {client_jwt}
Query Parameters:
- organization_id: uuid

Response (200 OK):
{
  "organization_id": "uuid",
  "members": [
    {
      "user_id": "uuid",
      "email": "jane@acme.com",
      "role": "organization_admin",
      "config_permissions": {
        "view_config": true,
        "edit_system_prompt": true,
        "add_remove_tools": true,
        "modify_integrations": true,
        "change_voice_params": true,
        "deploy_to_production": true,
        "rollback_versions": true,
        "manage_permissions": true
      }
    }
  ]
}
```

**Dependency Tracking Endpoints (Feature 5)**

**16. Get PRD Dependencies**
```http
GET /api/v1/prd/{prd_id}/dependencies
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "prd_id": "uuid",
  "dependencies": [
    {
      "dependency_id": "uuid",
      "type": "technical",
      "category": "api_key",
      "description": "Shopify API key for order history integration",
      "owner_name": "John Smith",
      "owner_email": "john@acme.com",
      "owner_role": "Technical Lead",
      "status": "pending",
      "due_date": "2025-10-25",
      "is_blocking": true,
      "created_at": "2025-10-10T10:00:00Z",
      "last_follow_up_sent": null,
      "completion_date": null
    },
    {
      "dependency_id": "uuid",
      "type": "business",
      "category": "approval",
      "description": "Privacy team approval for customer data access",
      "owner_name": "Jane Doe",
      "owner_email": "jane@acme.com",
      "owner_role": "Chief Privacy Officer",
      "status": "in_progress",
      "due_date": "2025-10-22",
      "is_blocking": true,
      "created_at": "2025-10-10T10:00:00Z",
      "last_follow_up_sent": "2025-10-18T09:00:00Z",
      "completion_date": null
    },
    {
      "dependency_id": "uuid",
      "type": "data",
      "category": "data_access",
      "description": "Database read access for agent to query customer order history",
      "owner_name": "DevOps Team",
      "owner_email": "devops@acme.com",
      "owner_role": "Infrastructure",
      "status": "completed",
      "due_date": "2025-10-18",
      "is_blocking": false,
      "created_at": "2025-10-10T10:00:00Z",
      "last_follow_up_sent": "2025-10-15T09:00:00Z",
      "completion_date": "2025-10-17T14:23:00Z"
    }
  ],
  "summary": {
    "total_dependencies": 3,
    "pending": 1,
    "in_progress": 1,
    "completed": 1,
    "overdue": 0,
    "blocking": 2,
    "completion_percentage": 33.3
  }
}
```

**17. Create Dependency**
```http
POST /api/v1/prd/{prd_id}/dependencies
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "type": "technical",
  "category": "webhook",
  "description": "Zendesk webhook endpoint configuration for ticket escalation",
  "owner_name": "Support Team Lead",
  "owner_email": "support-lead@acme.com",
  "owner_role": "Support Operations",
  "due_date": "2025-10-28",
  "is_blocking": true,
  "follow_up_schedule": {
    "initial_days": 3,
    "reminder_days": 7,
    "escalation_days": 14
  }
}

Response (201 Created):
{
  "dependency_id": "uuid",
  "prd_id": "uuid",
  "type": "technical",
  "category": "webhook",
  "description": "Zendesk webhook endpoint configuration for ticket escalation",
  "owner_name": "Support Team Lead",
  "owner_email": "support-lead@acme.com",
  "status": "pending",
  "due_date": "2025-10-28",
  "is_blocking": true,
  "created_at": "2025-10-20T11:00:00Z",
  "next_follow_up_date": "2025-10-23T09:00:00Z"
}
```

**18. Update Dependency Status**
```http
PUT /api/v1/prd/dependencies/{dep_id}/status
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "status": "completed",
  "completion_notes": "API key provided and verified in sandbox environment",
  "verification_url": "https://sandbox.workflow.com/test/shopify-integration"
}

Response (200 OK):
{
  "dependency_id": "uuid",
  "status": "completed",
  "completion_date": "2025-10-24T15:30:00Z",
  "completed_by": "uuid",
  "completion_notes": "API key provided and verified in sandbox environment",
  "verification_url": "https://sandbox.workflow.com/test/shopify-integration"
}

Event Published to Kafka:
Topic: prd_events
{
  "event_type": "dependency_completed",
  "prd_id": "uuid",
  "dependency_id": "uuid",
  "dependency_type": "technical",
  "is_blocking": true,
  "timestamp": "2025-10-24T15:30:00Z"
}
```

**19. Get Overdue Dependencies**
```http
GET /api/v1/prd/dependencies/overdue
Authorization: Bearer {jwt_token}
Query Parameters: ?onboarding_specialist_id={uuid}

Response (200 OK):
{
  "overdue_dependencies": [
    {
      "prd_id": "uuid",
      "client_name": "Acme Corp",
      "dependency_id": "uuid",
      "description": "Shopify API key for order history integration",
      "owner_email": "john@acme.com",
      "due_date": "2025-10-25",
      "days_overdue": 5,
      "is_blocking": true,
      "status": "pending",
      "last_follow_up_sent": "2025-10-28T09:00:00Z",
      "escalation_level": "warning"
    }
  ],
  "summary": {
    "total_overdue": 1,
    "blocking_overdue": 1,
    "warning_level": 1,
    "escalation_level": 0,
    "critical_level": 0
  }
}
```

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

**6. Help Button & Request Modal**
- Component: `HelpRequestModal.tsx`
- Features:
  - Floating help button in PRD interface
  - Help request form (reason, urgency, context)
  - Shareable code generator with QR code
  - Wait time indicator
  - Auto-copy shareable code
  - Agent availability status

**7. Collaborative Canvas**
- Component: `CollaborativeCanvas.tsx`
- Features:
  - Split-pane view (PRD content + collaboration chat)
  - Real-time cursor tracking (multi-user)
  - User presence indicators (avatars with names)
  - Collaborative text editing (OT/CRDT-based)
  - Section-level locking (prevent conflicts)
  - Inline comments and suggestions
  - Change highlighting (who edited what)
  - Undo/redo with conflict resolution

**8. Collaboration Chat Panel**
- Component: `CollaborationChatPanel.tsx`
- Features:
  - Side-by-side chat interface (client + agent)
  - Typing indicators
  - Code snippet sharing with syntax highlighting
  - File/image attachments
  - Message reactions
  - Agent identity badge
  - Chat history with timestamps
  - Notification sounds on agent messages

**9. Agent Join Notification**
- Component: `AgentJoinNotification.tsx`
- Features:
  - Toast notification when agent joins
  - Agent profile card (name, photo, expertise)
  - "Wave" button to greet agent
  - Session info (duration, purpose)
  - End session button (client can end anytime)

**10. Agent Collaboration Dashboard (Internal)**
- Component: `AgentCollaborationDashboard.tsx`
- Features:
  - Active help requests queue
  - Filter by urgency, wait time, organization
  - One-click join with shareable code input
  - Session context preview (PRD completion, current section)
  - Multi-session management (handle multiple clients)
  - Session notes for internal tracking
  - Collaboration metrics (avg duration, client satisfaction)

**11. Configuration Chat Interface (from Service 19)**
- Component: `ConfigChatInterface.tsx`
- Features:
  - Conversational config editing with AI agent
  - Change detection and classification
  - Preview generation inline
  - Approval workflow UI
  - Confidence indicators for detected changes

**12. Voicebot Configuration Panel (from Service 19)**
- Component: `VoicebotConfigPanel.tsx`
- Features:
  - Visual sliders for voice parameters (speed, clarity, style)
  - Background sound selector
  - Model settings configurator
  - Stop speaking plan editor
  - Real-time preview with test call button
  - Matches provided design mockups

**13. Chatbot Configuration Panel (from Service 19)**
- Component: `ChatbotConfigPanel.tsx`
- Features:
  - System prompt editor with tone presets
  - Tool catalog with add/remove controls
  - Integration connection manager
  - Escalation rule builder
  - Live chat preview

**14. Version History Timeline (from Service 19)**
- Component: `VersionHistoryTimeline.tsx`
- Features:
  - Git-style commit history
  - Side-by-side diff viewer
  - One-click rollback button
  - Filter by change type
  - Author attribution with avatars
  - Risk level badges

**15. Permission Matrix (from Service 19)**
- Component: `PermissionMatrix.tsx`
- Features:
  - Member list with role badges
  - Permission toggle grid
  - Role templates (Admin, Manager, Viewer)
  - Invite member workflow
  - Permission change audit log

**State Management:**
- Zustand for chat state, PRD content, and config state
- React Query for API data fetching
- WebSocket for real-time AI responses and config hot-reload notifications
- IndexedDB for offline draft support

#### Database Schema

**Dependency Tracking Tables (Feature 5):**
```sql
CREATE TABLE prd_dependencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prd_id UUID NOT NULL REFERENCES prds(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'technical', 'business', 'compliance', 'data'
  category VARCHAR(100), -- 'api_key', 'webhook', 'approval', 'credentials', 'data_access'
  description TEXT NOT NULL,
  owner_name VARCHAR(255),
  owner_email VARCHAR(255),
  owner_role VARCHAR(100),
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'in_progress', 'blocked', 'completed', 'overdue'
  due_date DATE,
  is_blocking BOOLEAN DEFAULT false,
  last_follow_up_sent TIMESTAMPTZ,
  completion_date TIMESTAMPTZ,
  completed_by UUID,
  completion_notes TEXT,
  verification_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
  INDEX idx_prd_id (prd_id),
  INDEX idx_organization_id (organization_id),
  INDEX idx_status (status),
  INDEX idx_due_date (due_date),
  INDEX idx_is_blocking (is_blocking)
);

CREATE TABLE dependency_follow_ups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dependency_id UUID NOT NULL REFERENCES prd_dependencies(id) ON DELETE CASCADE,
  follow_up_type VARCHAR(50) NOT NULL, -- 'initial', 'reminder', 'warning', 'escalation'
  scheduled_date DATE NOT NULL,
  sent_at TIMESTAMPTZ,
  recipient_email VARCHAR(255),
  email_template_id VARCHAR(100),
  status VARCHAR(50) DEFAULT 'scheduled', -- 'scheduled', 'sent', 'failed', 'canceled'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  INDEX idx_dependency_id (dependency_id),
  INDEX idx_scheduled_date (scheduled_date),
  INDEX idx_status (status)
);

-- Row-Level Security for multi-tenant isolation
ALTER TABLE prd_dependencies ENABLE ROW LEVEL SECURITY;
CREATE POLICY dependency_isolation ON prd_dependencies
  USING (organization_id = current_setting('app.current_organization_id')::UUID);

ALTER TABLE dependency_follow_ups ENABLE ROW LEVEL SECURITY;
CREATE POLICY follow_up_isolation ON dependency_follow_ups
  USING (dependency_id IN (SELECT id FROM prd_dependencies WHERE organization_id = current_setting('app.current_organization_id')::UUID));
```

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

4. **PRD Collaboration Support Agent (Human)**
   - Role: Joins PRD sessions to help clients with complex questions, provides expert guidance
   - Access: Join PRD sessions via shareable code, read/write canvas, chat with clients
   - Permissions: join:collaboration_sessions, read:prd, write:canvas, chat:clients
   - Workflows: Monitors help request queue → Joins session via shareable code → Chats with client → Edits canvas collaboratively → Resolves issue → Ends session
   - Approval: None (agent-initiated collaboration on client request)

5. **Organization Admin (Client) - from Service 19**
   - Role: Full configuration control, permission management for deployed products
   - Access: All configuration features for their organization's chatbot/voicebot
   - Permissions: All config_permissions enabled (view, edit, deploy, rollback, manage permissions)
   - Workflows: Changes config via chat/visual UI, manages team permissions, reviews version history
   - Approval: Can approve high-risk configuration changes

6. **Config Manager (Client) - from Service 19**
   - Role: Day-to-day configuration management for deployed products
   - Access: Most configuration features except deployment and permission management
   - Permissions: View, edit prompts/voice params, rollback (no deployment, no permission management)
   - Workflows: Adjusts chatbot tone, modifies voice settings, tests changes

7. **Config Viewer (Client) - from Service 19**
   - Role: Read-only config access for stakeholders
   - Access: View-only dashboard
   - Permissions: view_config only
   - Workflows: Reviews current configuration, views change history

8. **Support Agent (Platform) - from Service 19**
   - Role: Assists clients with complex configuration requests
   - Access: Join client config sessions, create GitHub tool requests
   - Permissions: read:client_configs, create:github_issues, join:config_sessions
   - Workflows: Receives escalation from config agent, helps client configure advanced features, creates tool requests

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

5. **Configuration Assistant Agent (from Service 19)**
   - Responsibility: Classifies configuration requests, generates previews, validates changes
   - Tools: LLM for intent classification, tool catalog search, config diff generator, schema validator
   - Autonomy: Fully autonomous for low-risk changes (auto-apply), requests approval for medium/high risk
   - Escalation: Human support agent for unrecognized requests or failed classifications

6. **Config Validation Agent (from Service 19)**
   - Responsibility: Validates configuration changes before deployment, detects breaking changes
   - Tools: JSON Schema validator, conflict detector, impact analyzer
   - Autonomy: Fully autonomous validation
   - Escalation: Platform engineer alert for validation failures or high-risk changes

**Approval Workflows:**

*PRD Builder:*
1. PRD Creation → Auto-approved for standard use cases, Product Manager review for complex
2. Village Knowledge Suggestions → Client acceptance required (opt-in)
3. A/B Flow Design → Technical Architect approval for >3 variants or complex logic
4. Integration Architecture → Technical Architect approval for custom integrations
5. Final PRD → Client Business Owner approval required
6. Sprint Roadmap → Product Manager + Technical Architect alignment required

*Configuration Management (from Service 19):*
7. Low-risk changes (voice params, tone adjustments) → Auto-approved
8. Medium-risk changes (tool additions, escalation rules) → Organization Admin approval
9. High-risk changes (integration modifications, tool removals) → Organization Admin + Platform Engineer approval
10. Failed changes (validation errors) → Auto-rollback + Support Agent notification

---

## 7. Automation Engine Service

#### Objectives
- **Primary Purpose**: Converts approved PRDs into executable JSON configurations, manages dynamic agent behavior, orchestrates tool and integration lifecycle
- **Business Value**: Enables configuration-driven agent deployment, automates GitHub issue creation for missing tools/integrations, supports 1000+ concurrent JSON configs
- **Scope Boundaries**:
  - **Does**: Generate JSON configs, manage tool/integration GitHub issues, hot-reload configurations, validate and version configs
  - **Does Not**: Implement tools/integrations (developers do), train models, deploy infrastructure

#### Requirements

**Functional Requirements:**
1. Generate JSON configuration from approved PRD with webchat UI interface
2. Define system prompts, tools, integrations, and metadata per config
3. Auto-create GitHub issues for missing tools/integrations with detailed specs
4. Track tool/integration implementation status and auto-update configs
5. Validate JSON against JSON Schema before deployment
6. Support config versioning with blue-green deployment
7. Hot-reload configs without service restart
8. Multi-tenant config isolation with namespace-based segregation

**Non-Functional Requirements:**
- JSON generation: <5 minutes from PRD approval
- Config validation: <2 seconds
- Hot-reload propagation: <60 seconds across all services
- Support 10,000+ JSON configs with tenant isolation
- 99.9% config availability

**Dependencies:**
- **Proposal Generator** *[See MICROSERVICES_ARCHITECTURE.md Service 5]* (consumes proposal_signed event to trigger JSON config generation)
- **PRD Builder** *[See Service 6 above]* (provides PRD data for config population)
- **Agent Orchestration Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 8]* (loads JSON configs for chatbot runtime)
- **Voice Agent Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 9]* (loads JSON configs for voicebot runtime)
- **Configuration Management Service** *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 10]* (stores and distributes configs)
- **GitHub API** (issue creation, status tracking)

**Technical Architecture by Product Type:**

1. **Chatbot Products** (LangGraph-based):
   - **Runtime Service**: Agent Orchestration Service
   - **Framework**: LangGraph two-node workflow (agent node + tools node)
   - **Architecture Reference**: https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/
   - **JSON Config Features**:
     - StateGraph implementation with checkpointing
     - `external_integrations` field (Salesforce, Zendesk, etc.)
     - Dynamic tool loading from JSON
     - PostgreSQL-backed state persistence
   - **Config Consumption**: Agent Orchestration Service reads chatbot JSON configs
   - **Documentation**: See MICROSERVICES_ARCHITECTURE_PART3.md (Agent Orchestration Service)

2. **Voicebot Products** (LiveKit-based):
   - **Runtime Service**: Voice Agent Service
   - **Framework**: LiveKit Agents (Python SDK) with VoicePipelineAgent
   - **Architecture Components**:
     - STT Pipeline: Deepgram Nova-3 streaming transcription
     - LLM Integration: Same as chatbot but optimized for voice latency
     - TTS Pipeline: ElevenLabs Flash v2.5 with dual streaming
     - SIP Integration: Twilio (primary), Telnyx (failover)
   - **JSON Config Features**:
     - NO `external_integrations` field (voice-only channel)
     - SIP endpoint configured separately via SIP trunk provisioning
     - Voice-specific config: STT/TTS providers, voice_id, turn detection
     - Tool execution via LiveKit agent callbacks
   - **Config Consumption**: Voice Agent Service reads voicebot JSON configs
   - **Documentation**: See MICROSERVICES_ARCHITECTURE_PART3.md (Voice Agent Service)

3. **Hybrid Deployments**:
   - Requires **separate JSON configs** for chatbot and voicebot
   - PRD includes distinct sprint roadmaps per product type
   - Shared PRD objectives but product-specific implementations
   - Cross-product communication via `cross_product_events` Kafka topic

**Data Storage:**
- PostgreSQL: Config metadata, versions, GitHub issue mapping, validation logs
- S3: JSON config files, config snapshots
- Git Repository: Version-controlled config storage
- Redis: Hot-reload notification queue

#### Features

**Must-Have:**
1. ✅ JSON config generation from PRD
2. ✅ Webchat UI for config refinement
3. ✅ Canvas editor for manual JSON editing
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
- PRD approval → Auto-generates JSON config
- GitHub issue closed (tool implemented) → Auto-updates config
- Config validation failure → Rollback to previous version

#### API Specification

**1. Generate JSON Config**
```http
POST /api/v1/automation/configs/generate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "prd_id": "uuid",
  "client_id": "uuid",
  "config_name": "acme_support_bot",
  "product_type": "chatbot",  // Required: chatbot | voicebot
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
  "product_type": "chatbot",
  "client_id": "uuid",
  "timestamp": "2025-10-10T14:05:00Z"
}
```

**2. Get JSON Config**
```http
GET /api/v1/automation/configs/{config_id}
Authorization: Bearer {jwt_token}
Accept: application/json

Response (200 OK - JSON):
{
  "config_id": "uuid",
  "client_id": "uuid",
  "status": "generated",
  "config_name": "acme_support_bot",
  "json_content": "...",
  "parsed_config": {
    "config_metadata": {
      "config_id": "uuid",
      "product_type": "chatbot",
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
        "product_compatibility": ["chatbot"],
        "type": "input_channel",
        "status": "implemented",
        "config": {
          "endpoint": "https://api.salesforce.com/...",
          "auth_type": "oauth2"
        }
      },
      {
        "integration_name": "whatsapp_business",
        "product_compatibility": ["chatbot"],
        "type": "input_channel",
        "status": "implemented"
      },
      {
        "integration_name": "sentiment_api",
        "product_compatibility": ["chatbot", "voicebot"],
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
```

**Example: Voicebot JSON Config (LiveKit-based)**
```json
{
  "config_metadata": {
    "config_id": "uuid_voicebot",
    "product_type": "voicebot",
    "client_id": "uuid",
    "version": 1,
    "environment": "staging",
    "created_at": "2025-10-10T15:00:00Z"
  },
  "system_prompt": {
    "role": "healthcare_appointment_scheduler",
    "instructions": "You are a friendly voice assistant for HealthCare Plus. Help patients schedule, reschedule, or cancel medical appointments. Always confirm appointment details before booking.",
    "constraints": [
      "Never share patient medical records over the phone",
      "Verify patient identity before any changes",
      "Escalate to human for emergency requests"
    ],
    "tone": "empathetic_professional",
    "voice_specific": {
      "speaking_rate": "normal",
      "interruption_sensitivity": "medium",
      "silence_timeout_ms": 2000
    }
  },
  "tools_available": [
    {
      "tool_name": "check_appointment_availability",
      "status": "implemented"
    },
    {
      "tool_name": "book_appointment",
      "status": "implemented"
    },
    {
      "tool_name": "send_sms_confirmation",
      "status": "missing",
      "github_issue": "https://github.com/workflow/tools/issues/201"
    }
  ],
  "integrations": [],
  "_comment": "NOTE: Voicebot products do NOT have external_integrations field. Voice channel is the ONLY input method via SIP trunks",
  "sip_config": {
    "primary_provider": "twilio",
    "primary_endpoint": "+14155551234",
    "failover_provider": "telnyx",
    "failover_endpoint": "+14155555678",
    "inbound_calls_enabled": true,
    "outbound_calls_enabled": true,
    "call_recording": true,
    "recording_retention_days": 90
  },
  "livekit_config": {
    "room_prefix": "healthcare_plus",
    "stt_provider": "deepgram",
    "stt_model": "nova-3",
    "stt_language": "en-US",
    "tts_provider": "elevenlabs",
    "tts_voice_id": "ErXwobaYiN019PkySvjV",
    "tts_model": "flash_v2_5",
    "vad_enabled": true,
    "vad_threshold": 0.5
  },
  "llm_config": {
    "provider": "openai",
    "model": "gpt-4o-mini",
    "_comment": "Voicebots use faster/cheaper models for low-latency responses",
    "parameters": {
      "temperature": 0.6,
      "max_tokens": 150,
      "top_p": 0.9
    },
    "fallback": {
      "provider": "anthropic",
      "model": "claude-sonnet-4"
    }
  },
  "workflow_features": {
    "pii_collection": {
      "enabled": true,
      "fields": ["patient_name", "date_of_birth", "phone"]
    },
    "human_escalation": {
      "enabled": true,
      "triggers": [
        {
          "condition": "patient_requests_doctor",
          "action": "immediate_transfer"
        },
        {
          "condition": "emergency_keywords_detected",
          "action": "immediate_transfer"
        },
        {
          "condition": "ai_confidence < 0.4",
          "action": "suggest_transfer"
        }
      ]
    },
    "call_transfer": {
      "enabled": true,
      "transfer_destinations": [
        {
          "name": "front_desk",
          "phone": "+14155556789"
        },
        {
          "name": "emergency_line",
          "phone": "+14155559999"
        }
      ]
    },
    "voicemail": {
      "enabled": true,
      "max_duration_seconds": 120,
      "transcription_enabled": true
    },
    "outbound_calling": {
      "enabled": true,
      "triggers": [
        {
          "event": "appointment_reminder_24h",
          "template": "reminder_script"
        },
        {
          "event": "appointment_confirmation",
          "template": "confirmation_script"
        }
      ]
    }
  },
  "database_config": {
    "type": "supabase",
    "tables": ["call_logs", "appointments", "patient_records"],
    "rls_enabled": true
  },
  "vector_db_config": {
    "type": "pinecone",
    "index_name": "healthcare_knowledge_base",
    "namespace": "healthcare_plus"
  }
}
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
Content-Type: application/json

Request Body (JSON):
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
  "tool_name": "initiate_refund",
  "github_issue": 156,
  "timestamp": "2025-10-12T10:00:00Z"
}

Hot-Reload Event Published:
Topic: config_events
{
  "event_type": "config_updated",
  "config_id": "uuid",
  "product_type": "chatbot",
  "version": 4,
  "changes": ["tool_initiate_refund_now_available"],
  "reload_required": true,
  "timestamp": "2025-10-12T10:00:05Z"
}

**Note on Hot-Reload Implementation:**
The hot-reload mechanism uses version pinning to ensure in-progress conversations continue with their original config version while new conversations use the updated config. This prevents breaking changes mid-conversation. Implementation details including version pinning logic, conversation state tracking, and config caching strategy are documented in **MICROSERVICES_ARCHITECTURE_PART3.md** (Agent Orchestration Service, lines 410-583).
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
  - Right: JSON canvas editor (Monaco Editor)
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
- Monaco Editor for JSON editing
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
   - Responsibility: Converts PRD to JSON config, identifies dependencies, creates GitHub issues
   - Tools: JSON generators, JSON Schema validators, GitHub API, template engine
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

#### Credential Vault System

**Purpose**: Secure, multi-tenant credential management system (n8n-style) for storing and managing API keys, webhooks, OAuth tokens, and other sensitive configuration data required by chatbot/voicebot integrations.

**Key Features:**

1. **Credential Types Supported:**
   - API Keys (REST APIs, third-party services)
   - OAuth 2.0 tokens (Google, Microsoft, Salesforce)
   - Basic Auth credentials
   - Webhook URLs and secrets
   - Database connection strings
   - SSL/TLS certificates
   - Custom credential schemas

2. **Security Architecture:**
   - **Encryption at rest**: AES-256 encryption for all stored credentials
   - **Encryption in transit**: TLS 1.3 for all API communication
   - **Key Management**: AWS KMS or HashiCorp Vault integration for encryption key rotation
   - **Access Control**: Row-Level Security (RLS) with tenant_id isolation
   - **Audit Logging**: All credential access logged with timestamp, user_id, action
   - **Secrets masking**: Credentials never returned in plaintext via API (masked as *****)
   - **Time-limited access tokens**: Temporary decryption tokens with 5-minute TTL

3. **Credential Lifecycle:**
   - **Creation**: Client/Platform Engineer creates credential via UI or API
   - **Validation**: Auto-test credential validity (e.g., test API call for API keys)
   - **Rotation**: Support manual and automatic credential rotation with version history
   - **Expiration**: Auto-expire credentials with expiration dates, send alerts 7 days before
   - **Revocation**: Immediate revocation with cascade updates to affected JSON configs
   - **Archival**: Soft-delete with 90-day retention for audit compliance

4. **Integration with JSON Configs:**
   - **Credential References**: JSON configs reference credentials by ID, not plaintext
   ```json
   {
     "integrations": [
       {
         "integration_name": "salesforce_crm",
         "credentials": {
           "credential_id": "cred_uuid_12345",
           "credential_type": "oauth2"
         }
       }
     ]
   }
   ```
   - **Runtime Resolution**: Agent Orchestration Service (Service 8) fetches decrypted credentials at runtime using temporary access tokens
   - **Hot-Reload Support**: Credential updates trigger config reload events without restarting agents
   - **Validation**: Config deployment blocked if referenced credentials are missing or expired

**API Specification:**

**1. Create Credential**
```http
POST /api/v1/automation/credentials
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "credential_name": "salesforce_production_oauth",
  "credential_type": "oauth2",
  "provider": "salesforce",
  "credentials": {
    "client_id": "salesforce_client_id",
    "client_secret": "salesforce_secret",
    "access_token": "oauth_access_token",
    "refresh_token": "oauth_refresh_token",
    "expires_at": "2025-12-31T23:59:59Z"
  },
  "metadata": {
    "environment": "production",
    "auto_rotate": true,
    "rotation_days": 90
  }
}

Response (201 Created):
{
  "credential_id": "cred_uuid_12345",
  "client_id": "uuid",
  "credential_name": "salesforce_production_oauth",
  "credential_type": "oauth2",
  "provider": "salesforce",
  "status": "active",
  "validation_status": "passed",
  "created_at": "2025-10-10T15:00:00Z",
  "expires_at": "2025-12-31T23:59:59Z",
  "rotation_schedule": {
    "auto_rotate": true,
    "next_rotation": "2026-01-08T15:00:00Z"
  }
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "credential_created",
  "credential_id": "cred_uuid_12345",
  "client_id": "uuid",
  "credential_type": "oauth2",
  "timestamp": "2025-10-10T15:00:00Z"
}
```

**2. Get Credential (Masked)**
```http
GET /api/v1/automation/credentials/{credential_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "credential_id": "cred_uuid_12345",
  "client_id": "uuid",
  "credential_name": "salesforce_production_oauth",
  "credential_type": "oauth2",
  "provider": "salesforce",
  "status": "active",
  "credentials_masked": {
    "client_id": "sales*****",
    "client_secret": "*****",
    "access_token": "*****",
    "refresh_token": "*****"
  },
  "expires_at": "2025-12-31T23:59:59Z",
  "created_at": "2025-10-10T15:00:00Z",
  "last_used": "2025-10-15T10:30:00Z",
  "usage_count": 1547
}
```

**3. Request Credential Decryption Token (Runtime)**
```http
POST /api/v1/automation/credentials/{credential_id}/decrypt-token
Authorization: Bearer {service_jwt_token}
Content-Type: application/json

Request Body:
{
  "service_name": "agent_orchestration",
  "conversation_id": "conv_uuid",
  "reason": "salesforce_api_call"
}

Response (200 OK):
{
  "credential_id": "cred_uuid_12345",
  "decryption_token": "temp_token_xyz",
  "expires_at": "2025-10-15T10:35:00Z",
  "ttl_seconds": 300
}

// Service then uses decryption_token to fetch plaintext credentials
GET /api/v1/automation/credentials/{credential_id}/decrypt
Authorization: Bearer {decryption_token}

Response (200 OK):
{
  "credential_id": "cred_uuid_12345",
  "credentials": {
    "client_id": "actual_salesforce_client_id",
    "client_secret": "actual_salesforce_secret",
    "access_token": "actual_oauth_access_token",
    "refresh_token": "actual_oauth_refresh_token"
  },
  "expires_at": "2025-12-31T23:59:59Z"
}
```

**4. List Credentials**
```http
GET /api/v1/automation/credentials?client_id={uuid}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "credentials": [
    {
      "credential_id": "cred_uuid_12345",
      "credential_name": "salesforce_production_oauth",
      "credential_type": "oauth2",
      "provider": "salesforce",
      "status": "active",
      "expires_at": "2025-12-31T23:59:59Z",
      "last_used": "2025-10-15T10:30:00Z"
    },
    {
      "credential_id": "cred_uuid_67890",
      "credential_name": "zendesk_api_key",
      "credential_type": "api_key",
      "provider": "zendesk",
      "status": "expiring_soon",
      "expires_at": "2025-10-20T00:00:00Z",
      "last_used": "2025-10-14T18:20:00Z"
    }
  ],
  "total": 2
}
```

**5. Update/Rotate Credential**
```http
PATCH /api/v1/automation/credentials/{credential_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "credentials": {
    "access_token": "new_oauth_access_token",
    "refresh_token": "new_oauth_refresh_token",
    "expires_at": "2026-01-15T23:59:59Z"
  },
  "rotation_reason": "scheduled_rotation"
}

Response (200 OK):
{
  "credential_id": "cred_uuid_12345",
  "version": 2,
  "status": "active",
  "rotation_history": [
    {
      "version": 1,
      "rotated_at": "2025-10-10T15:00:00Z",
      "reason": "initial_creation"
    },
    {
      "version": 2,
      "rotated_at": "2025-10-15T11:00:00Z",
      "reason": "scheduled_rotation"
    }
  ],
  "updated_at": "2025-10-15T11:00:00Z"
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "credential_rotated",
  "credential_id": "cred_uuid_12345",
  "client_id": "uuid",
  "version": 2,
  "timestamp": "2025-10-15T11:00:00Z"
}
```

**6. Delete Credential**
```http
DELETE /api/v1/automation/credentials/{credential_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "credential_id": "cred_uuid_12345",
  "status": "deleted",
  "archived_until": "2026-01-13T11:05:00Z",
  "dependent_configs": [
    {
      "config_id": "uuid",
      "config_name": "acme_support_bot",
      "affected_integration": "salesforce_crm",
      "action_required": "update_credential_reference"
    }
  ]
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "credential_deleted",
  "credential_id": "cred_uuid_12345",
  "client_id": "uuid",
  "affected_configs": ["uuid"],
  "timestamp": "2025-10-15T11:05:00Z"
}
```

**Data Storage:**
- **PostgreSQL**: Credential metadata, audit logs, rotation history (plaintext values NOT stored)
- **AWS Secrets Manager / HashiCorp Vault**: Encrypted credential values
- **Redis**: Decryption token cache (5-minute TTL)

**Database Schema:**
```sql
CREATE TABLE credentials (
  credential_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  credential_name VARCHAR(255) NOT NULL,
  credential_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100),
  secrets_manager_ref VARCHAR(500) NOT NULL, -- Reference to AWS Secrets Manager ARN
  status VARCHAR(50) NOT NULL,
  version INTEGER DEFAULT 1,
  expires_at TIMESTAMP,
  auto_rotate BOOLEAN DEFAULT FALSE,
  rotation_days INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_used TIMESTAMP,
  usage_count INTEGER DEFAULT 0
);

CREATE INDEX idx_credentials_client ON credentials(client_id);
CREATE INDEX idx_credentials_status ON credentials(status);

-- Row-Level Security
ALTER TABLE credentials ENABLE ROW LEVEL SECURITY;
CREATE POLICY credentials_tenant_isolation ON credentials
  USING (client_id = current_setting('app.current_tenant_id')::UUID);

CREATE TABLE credential_audit_logs (
  audit_id UUID PRIMARY KEY,
  credential_id UUID REFERENCES credentials(credential_id),
  action VARCHAR(50) NOT NULL, -- create, read, update, delete, rotate
  performed_by UUID, -- user_id or service_id
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_credential ON credential_audit_logs(credential_id);
CREATE INDEX idx_audit_timestamp ON credential_audit_logs(timestamp);
```

**Security Best Practices:**
1. **Least Privilege Access**: Only services that need credentials can request decryption tokens
2. **Audit Trail**: Every credential access logged with who, when, why
3. **Temporary Tokens**: Decryption tokens expire after 5 minutes to limit exposure window
4. **Validation**: Auto-test credentials on creation/update to catch invalid keys early
5. **Alerting**: Notify Platform Engineers when:
   - Credential expires within 7 days
   - Credential validation fails
   - Unusual access patterns detected (e.g., 100+ decryptions in 1 minute)
   - Credential deletion affects active configs

**Integration Points:**
- **Service 8 (Agent Orchestration)**: Fetches credentials at runtime for chatbot integrations (Salesforce, Zendesk, etc.)
- **Service 9 (Voice Agent)**: Does NOT use Credential Vault (voicebots have no external integrations, only SIP trunks)
- **Service 7 (Automation Engine)**: Validates credential references in JSON configs before deployment
- **Service 11 (Monitoring)**: Monitors credential expiration, rotation schedules, access patterns
- **Service 14 (Support Engine)**: Creates support tickets when credentials fail validation or expire

**Frontend Component:**
- Component: `CredentialVaultManager.tsx`
- Features:
  - Credential creation wizard (guided OAuth flow)
  - Credential list with expiration warnings
  - Test credential button (validates via mock API call)
  - Rotation scheduler interface
  - Usage analytics dashboard (which configs use which credentials)
  - Audit log viewer

**Rate Limiting:**
- 10 credential creations per hour per tenant
- 100 credential reads per minute per tenant
- 1000 decryption token requests per minute per service

---

## 16. LLM Gateway Service → CONVERTED TO LIBRARY

**Service 16 has been converted to @workflow/llm-sdk library** - See "Supporting Libraries" section below for complete specification.

**Rationale**: Service 16 was a pass-through microservice adding 200-500ms latency to every LLM call. Converting to a library eliminates this network hop, allowing services to call LLM providers (OpenAI, Anthropic) directly while still benefiting from model routing, semantic caching, and token counting features.

**Migration Impact**:
- Services 8, 9, 21, 13, 14 now import `@workflow/llm-sdk` directly
- No API calls to Service 16
- LLM API keys managed per-service (already required for autonomy)
- 200-500ms latency improvement per LLM call

**Benefits**:
- Eliminates network hop and service orchestration overhead
- Reduces single point of failure
- Simpler observability (direct tracing to LLM provider)
- Service autonomy (each service manages own LLM interactions)
- Cost tracking still maintained via library instrumentation

---

## 17. RAG Pipeline Service

#### Objectives
- **Primary Purpose**: Retrieval-Augmented Generation for knowledge injection across conversations, demos, and PRDs using vector search and graph-based reasoning
- **Business Value**: Enables AI to leverage historical knowledge (village knowledge), improves response accuracy by 40%, reduces hallucinations
- **Scope Boundaries**:
  - **Does**: Ingest documents into vector DB, perform semantic search, rank results, inject context into LLM prompts, support GraphRAG
  - **Does Not**: Generate responses (LLM Gateway does), train embedding models, manage document storage

#### Requirements

**Functional Requirements:**
1. Document ingestion with chunking and embedding generation
2. Semantic search across multi-tenant namespaces (Qdrant)
3. Hybrid search (vector + keyword + graph traversal)
4. Context ranking and relevance scoring
5. Multi-hop reasoning with Neo4j graph traversal (GraphRAG)
6. Knowledge base management (add, update, delete documents)
7. Metadata filtering (date, source, document type)

**Non-Functional Requirements:**
- Search latency: <200ms P95
- Support 10,000+ documents per tenant
- Ingestion throughput: 1000 documents/hour
- 99.9% uptime
- Multi-tenant namespace isolation (zero data leakage)

**Dependencies:**
- LLM Gateway (embedding generation)
- Agent Orchestration Service (primary consumer)
- PRD Builder (village knowledge retrieval)
- Qdrant (vector storage)
- Neo4j (knowledge graph)

**Data Storage:**
- Qdrant: Vector embeddings with namespace-per-tenant isolation
- Neo4j: Knowledge graphs (entities, relationships, concepts)
- PostgreSQL: Document metadata, ingestion logs, tenant namespaces
- S3: Original documents (PDF, markdown, text)

#### Features

**Must-Have:**
1. ✅ Document ingestion with automatic chunking
2. ✅ Semantic vector search (Qdrant)
3. ✅ Multi-tenant namespace isolation
4. ✅ Metadata filtering (date, source, type)
5. ✅ Context ranking by relevance
6. ✅ GraphRAG (Neo4j traversal for multi-hop reasoning)
7. ✅ Knowledge base CRUD operations

**Nice-to-Have:**
8. 🔄 Automatic document summarization
9. 🔄 Entity extraction and knowledge graph auto-population
10. 🔄 Citation generation (source tracking)

#### API Specification

**1. Query Knowledge Base**
```http
POST /api/v1/rag/query
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "query": "How do other clients handle payment failures in e-commerce workflows?",
  "namespace": "village_knowledge",  // tenant-specific namespace
  "top_k": 5,
  "filters": {
    "document_type": ["prd", "demo"],
    "industry": "e-commerce",
    "date_range": {
      "start": "2024-01-01",
      "end": "2025-10-06"
    }
  },
  "enable_graph_rag": true  // Use Neo4j for multi-hop reasoning
}

Response (200 OK):
{
  "results": [
    {
      "content": "For e-commerce payment failures, most clients implement a 3-step retry workflow...",
      "score": 0.92,
      "metadata": {
        "source": "acme-corp-prd",
        "document_type": "prd",
        "industry": "e-commerce",
        "created_at": "2024-08-15"
      },
      "chunk_id": "uuid"
    },
    {
      "content": "Payment failure handling best practices include email notifications...",
      "score": 0.87,
      "metadata": {
        "source": "demo-shopify-integration",
        "document_type": "demo",
        "industry": "e-commerce",
        "created_at": "2024-09-20"
      },
      "chunk_id": "uuid"
    }
  ],
  "graph_insights": [
    {
      "entity": "payment_retry_workflow",
      "related_concepts": ["email_notification", "fallback_payment_method", "fraud_detection"],
      "confidence": 0.85
    }
  ],
  "latency_ms": 145
}
```

**2. Ingest Document**
```http
POST /api/v1/rag/ingest
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "document_id": "prd-acme-corp-2025",
  "content": "# PRD: Acme Corp E-commerce Automation\n\n## Payment Processing...",
  "namespace": "village_knowledge",
  "metadata": {
    "document_type": "prd",
    "industry": "e-commerce",
    "client_id": "uuid",
    "created_at": "2025-10-01"
  },
  "chunking_strategy": "semantic",  // semantic | fixed_size | paragraph
  "chunk_size": 500
}

Response (202 Accepted):
{
  "job_id": "uuid",
  "status": "processing",
  "estimated_completion": "2025-10-06T10:35:00Z",
  "chunks_to_process": 42
}
```

**3. Get Ingestion Status**
```http
GET /api/v1/rag/ingest/{job_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "job_id": "uuid",
  "status": "completed",
  "chunks_processed": 42,
  "chunks_total": 42,
  "embeddings_generated": 42,
  "graph_entities_extracted": 18,
  "completed_at": "2025-10-06T10:33:00Z",
  "namespace": "village_knowledge"
}
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Platform Engineer**
   - Role: Manages knowledge bases, monitors ingestion jobs, optimizes search performance
   - Access: All namespaces, ingestion logs, performance metrics
   - Permissions: admin:rag_pipeline, manage:namespaces, configure:search
   - Workflows: Reviews knowledge quality, tunes chunk sizes, manages graph schemas

**AI Agents:**

1. **Document Chunking Agent**
   - Responsibility: Splits documents into optimal chunks, preserves context boundaries
   - Tools: Semantic splitters, paragraph detectors, token counters
   - Autonomy: Fully autonomous
   - Escalation: Alerts on documents that cannot be chunked (malformed format)

2. **Knowledge Graph Builder Agent**
   - Responsibility: Extracts entities and relationships, populates Neo4j graph
   - Tools: NER models, relation extractors, graph writers
   - Autonomy: Fully autonomous
   - Escalation: Manual review for low-confidence entity extractions (<70%)

#### Multi-Source Document Ingestion

**Purpose**: Comprehensive document ingestion pipeline supporting multiple file formats and data sources for chatbot/voicebot knowledge bases.

**Supported Document Sources:**

1. **File Uploads:**
   - **Word Documents**: .docx, .doc (Microsoft Word)
   - **PDFs**: .pdf (with text extraction and OCR for scanned PDFs)
   - **Spreadsheets**: .xlsx, .xls, .csv (Excel, Google Sheets exports)
   - **Text Files**: .txt, .md (Markdown), .rtf
   - **Presentations**: .pptx, .ppt (PowerPoint)
   - **Web Pages**: HTML files, URLs for web scraping

2. **API Integrations:**
   - **Google Drive**: Automatic sync of selected folders
   - **Sharepoint/OneDrive**: Microsoft 365 document libraries
   - **Confluence**: Wiki pages and documentation
   - **Notion**: Workspace pages and databases
   - **Zendesk**: Knowledge base articles
   - **Intercom**: Help center articles
   - **Custom REST APIs**: Webhook-based document push

3. **Cloud Storage:**
   - **Google Cloud Storage (GCS)**: Bucket monitoring with auto-ingestion
   - **AWS S3**: S3 bucket monitoring with event-driven ingestion
   - **Dropbox**: Folder sync with change detection
   - **Box**: Enterprise file sync

4. **Database Sources:**
   - **PostgreSQL**: Direct table queries for structured data
   - **MySQL**: Database table exports
   - **MongoDB**: Collection exports
   - **Airtable**: Base/table sync

**Document Processing Pipeline:**

1. **Upload/Fetch** → 2. **Format Detection** → 3. **Text Extraction** → 4. **Chunking** → 5. **Embedding** → 6. **Vector Storage** → 7. **Metadata Indexing**

**API Specification:**

**1. Ingest from File Upload**
```http
POST /api/v1/rag/ingest/file
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: multipart/form-data

Request Body (multipart):
{
  "file": <binary_file>,
  "namespace": "client_knowledge_base",
  "metadata": {
    "document_type": "product_manual",
    "category": "technical_documentation",
    "language": "en",
    "version": "2.1"
  },
  "processing_options": {
    "ocr_enabled": true,  // For scanned PDFs
    "table_extraction": true,  // Extract tables from Excel/Word
    "image_extraction": false,  // Extract images (for Gemini Vision integration)
    "chunking_strategy": "semantic"
  }
}

Response (202 Accepted):
{
  "job_id": "uuid",
  "document_id": "doc_uuid",
  "status": "processing",
  "file_name": "Product_Manual_v2.1.pdf",
  "file_size_bytes": 2458000,
  "detected_format": "pdf",
  "estimated_chunks": 85,
  "estimated_completion": "2025-10-15T14:35:00Z"
}
```

**2. Ingest from URL (Web Scraping)**
```http
POST /api/v1/rag/ingest/url
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "url": "https://docs.example.com/api/v2/authentication",
  "namespace": "client_knowledge_base",
  "metadata": {
    "document_type": "api_documentation",
    "category": "developer_docs"
  },
  "processing_options": {
    "follow_links": false,  // Crawl related pages
    "max_depth": 1,  // Link depth to follow
    "include_images": false
  }
}

Response (202 Accepted):
{
  "job_id": "uuid",
  "document_id": "doc_uuid",
  "status": "processing",
  "url": "https://docs.example.com/api/v2/authentication",
  "estimated_completion": "2025-10-15T14:25:00Z"
}
```

**3. Ingest from Google Drive**
```http
POST /api/v1/rag/ingest/google-drive
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "credential_id": "cred_google_drive_oauth",  // Reference to Credential Vault
  "folder_id": "google_drive_folder_id",
  "namespace": "client_knowledge_base",
  "sync_mode": "one_time",  // one_time | continuous
  "file_filters": {
    "file_types": ["document", "spreadsheet", "presentation"],
    "modified_after": "2025-01-01T00:00:00Z"
  },
  "processing_options": {
    "table_extraction": true,
    "chunking_strategy": "semantic"
  }
}

Response (202 Accepted):
{
  "sync_job_id": "uuid",
  "status": "syncing",
  "files_discovered": 47,
  "sync_mode": "one_time",
  "estimated_completion": "2025-10-15T15:00:00Z"
}
```

**4. Ingest from API (Custom Integration)**
```http
POST /api/v1/rag/ingest/api
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "api_endpoint": "https://api.zendesk.com/v2/help_center/articles",
  "credential_id": "cred_zendesk_api_key",
  "namespace": "client_knowledge_base",
  "metadata": {
    "document_type": "faq",
    "category": "customer_support"
  },
  "api_config": {
    "method": "GET",
    "headers": {
      "Accept": "application/json"
    },
    "pagination": {
      "type": "cursor",
      "cursor_field": "next_page"
    },
    "data_path": "articles",  // JSON path to extract documents
    "content_field": "body",  // Field containing document text
    "title_field": "title"
  }
}

Response (202 Accepted):
{
  "sync_job_id": "uuid",
  "status": "syncing",
  "api_endpoint": "https://api.zendesk.com/v2/help_center/articles",
  "estimated_documents": 120,
  "estimated_completion": "2025-10-15T14:45:00Z"
}
```

**5. Ingest from Cloud Storage (S3/GCS)**
```http
POST /api/v1/rag/ingest/cloud-storage
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "provider": "s3",  // s3 | gcs | dropbox | box
  "bucket_name": "acme-corp-documents",
  "credential_id": "cred_aws_s3",
  "namespace": "client_knowledge_base",
  "path_prefix": "knowledge-base/",  // Optional: filter by path
  "sync_mode": "continuous",  // continuous | one_time
  "file_filters": {
    "file_extensions": [".pdf", ".docx", ".md"],
    "modified_after": "2025-01-01T00:00:00Z"
  },
  "event_driven": true  // Use S3 event notifications for real-time sync
}

Response (202 Accepted):
{
  "sync_job_id": "uuid",
  "status": "syncing",
  "provider": "s3",
  "bucket_name": "acme-corp-documents",
  "sync_mode": "continuous",
  "files_discovered": 203,
  "estimated_completion": "2025-10-15T16:00:00Z"
}

Event Published to Kafka (for continuous sync):
Topic: rag_events
{
  "event_type": "continuous_sync_started",
  "sync_job_id": "uuid",
  "provider": "s3",
  "bucket_name": "acme-corp-documents",
  "namespace": "client_knowledge_base",
  "timestamp": "2025-10-15T14:00:00Z"
}
```

**6. Get Sync/Ingestion Status**
```http
GET /api/v1/rag/ingest/status/{job_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "job_id": "uuid",
  "status": "completed",  // processing | completed | failed | partial_failure
  "source_type": "google_drive",
  "total_documents": 47,
  "processed_documents": 47,
  "failed_documents": 0,
  "total_chunks": 2150,
  "embeddings_generated": 2150,
  "failed_files": [],
  "started_at": "2025-10-15T14:00:00Z",
  "completed_at": "2025-10-15T14:58:00Z",
  "namespace": "client_knowledge_base"
}
```

**7. List Ingestion Jobs**
```http
GET /api/v1/rag/ingest/jobs?namespace={namespace}&status={status}
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}

Response (200 OK):
{
  "jobs": [
    {
      "job_id": "uuid_1",
      "source_type": "google_drive",
      "status": "completed",
      "total_documents": 47,
      "started_at": "2025-10-15T14:00:00Z",
      "completed_at": "2025-10-15T14:58:00Z"
    },
    {
      "job_id": "uuid_2",
      "source_type": "s3",
      "status": "in_progress",
      "total_documents": 203,
      "processed_documents": 145,
      "started_at": "2025-10-15T14:00:00Z"
    }
  ],
  "total": 2
}
```

**Document Processing Features:**

1. **OCR (Optical Character Recognition)**:
   - Automatically detect scanned PDFs
   - Extract text using Tesseract OCR
   - Support for 100+ languages
   - Preserve layout and formatting

2. **Table Extraction**:
   - Extract tables from Excel, Word, PDFs
   - Convert to structured format (JSON/CSV)
   - Maintain column headers and relationships
   - Support for merged cells and complex layouts

3. **Image Extraction** (for Gemini Vision):
   - Extract images from documents
   - Store in S3 with document association
   - Generate image embeddings for visual search
   - Link to parent document chunks

4. **Metadata Enrichment**:
   - Auto-detect document language
   - Extract creation/modification dates
   - Identify document type (contract, invoice, manual, etc.)
   - Extract author/creator information

**Data Storage:**
- **S3**: Original document files (retention: permanent)
- **PostgreSQL**: Document metadata, ingestion job logs, sync schedules
- **Qdrant**: Vector embeddings with namespace isolation
- **Neo4j**: Cross-document entity relationships

**Database Schema Additions:**
```sql
CREATE TABLE documents (
  document_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  namespace VARCHAR(255) NOT NULL,
  source_type VARCHAR(50) NOT NULL,  -- file_upload | url | google_drive | s3 | api
  source_reference VARCHAR(500),  -- S3 key, Drive file ID, URL, etc.
  file_name VARCHAR(500),
  file_type VARCHAR(50),  -- pdf, docx, xlsx, etc.
  file_size_bytes BIGINT,
  status VARCHAR(50) NOT NULL,  -- processed | processing | failed
  total_chunks INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

CREATE INDEX idx_documents_client ON documents(client_id);
CREATE INDEX idx_documents_namespace ON documents(namespace);
CREATE INDEX idx_documents_status ON documents(status);

-- Row-Level Security
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY documents_tenant_isolation ON documents
  USING (client_id = current_setting('app.current_tenant_id')::UUID);

CREATE TABLE ingestion_jobs (
  job_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  namespace VARCHAR(255) NOT NULL,
  source_type VARCHAR(50) NOT NULL,
  sync_mode VARCHAR(50),  -- one_time | continuous
  status VARCHAR(50) NOT NULL,  -- syncing | completed | failed
  total_documents INTEGER DEFAULT 0,
  processed_documents INTEGER DEFAULT 0,
  failed_documents INTEGER DEFAULT 0,
  total_chunks INTEGER DEFAULT 0,
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  error_message TEXT,
  configuration JSONB
);

CREATE INDEX idx_jobs_client ON ingestion_jobs(client_id);
CREATE INDEX idx_jobs_status ON ingestion_jobs(status);

CREATE TABLE continuous_sync_configs (
  sync_config_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  namespace VARCHAR(255) NOT NULL,
  source_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100),  -- google_drive | s3 | dropbox | etc.
  credential_id UUID REFERENCES credentials(credential_id),
  sync_schedule VARCHAR(50),  -- real_time | hourly | daily
  last_sync_at TIMESTAMP,
  next_sync_at TIMESTAMP,
  status VARCHAR(50) NOT NULL,  -- active | paused | failed
  configuration JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sync_configs_client ON continuous_sync_configs(client_id);
CREATE INDEX idx_sync_configs_status ON continuous_sync_configs(status);
```

**Integration Points:**
- **Service 7 (Automation Engine)**: Credential Vault integration for API keys and OAuth tokens
- **Service 8 (Agent Orchestration)**: Consumes ingested documents for chatbot knowledge
- **Service 9 (Voice Agent)**: Consumes ingested documents for voicebot knowledge
- **Service 11 (Monitoring)**: Monitors ingestion job health, sync failures, storage usage

**Frontend Component:**
- Component: `DocumentIngestionManager.tsx`
- Features:
  - Multi-source upload interface (drag-and-drop, URL input, cloud integration)
  - Ingestion job queue with progress tracking
  - File preview with text extraction preview
  - Sync schedule configuration for continuous sources
  - Error log viewer with retry options
  - Storage usage analytics dashboard

**Rate Limiting:**
- 100 file uploads per hour per tenant
- 10 continuous sync configurations per tenant
- 50 API ingestion jobs per hour per tenant

#### FAQ Management System

**Purpose**: Structured FAQ management system optimized for chatbot/voicebot knowledge retrieval with question-answer pairing, categorization, and confidence-based routing.

**Key Features:**

1. **FAQ CRUD Operations:**
   - Create, read, update, delete FAQ entries
   - Support for multiple FAQs per client/product
   - Version control for FAQ content changes
   - Bulk import/export (CSV, JSON, Excel)

2. **FAQ Structure:**
   - **Question**: Natural language question (primary)
   - **Answer**: Detailed answer text (with markdown support)
   - **Alternate Questions**: Synonyms, rephrased questions for better matching
   - **Category**: FAQ category for filtering (e.g., "Billing", "Technical Support")
   - **Tags**: Searchable tags for classification
   - **Metadata**: Language, priority, visibility (public/internal)

3. **Search & Matching:**
   - Semantic search using vector embeddings
   - Fuzzy matching for typos and variations
   - Category-based filtering
   - Confidence scoring for answer quality
   - Multi-language support

4. **Integration with Chatbot/Voicebot:**
   - Auto-inject FAQ answers into agent responses
   - Confidence threshold for auto-response (e.g., >0.85 = auto-reply, <0.85 = human review)
   - Fallback to general knowledge base if FAQ not found
   - Track FAQ hit rate and effectiveness

**API Specification:**

**1. Create FAQ**
```http
POST /api/v1/rag/faq
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "namespace": "acme_support_faq",
  "category": "billing",
  "question": "How do I update my payment method?",
  "alternate_questions": [
    "Change payment method",
    "Update credit card",
    "Modify billing information"
  ],
  "answer": "To update your payment method:\n1. Go to Account Settings\n2. Click Billing & Payments\n3. Select Update Payment Method\n4. Enter new card details\n5. Click Save",
  "tags": ["billing", "payment", "account_settings"],
  "metadata": {
    "language": "en",
    "priority": "high",
    "visibility": "public"
  }
}

Response (201 Created):
{
  "faq_id": "faq_uuid",
  "namespace": "acme_support_faq",
  "category": "billing",
  "question": "How do I update my payment method?",
  "answer": "To update your payment method:\n1. Go to Account Settings...",
  "alternate_questions": ["Change payment method", "Update credit card", "Modify billing information"],
  "tags": ["billing", "payment", "account_settings"],
  "version": 1,
  "created_at": "2025-10-15T15:00:00Z",
  "vector_embedding_status": "generated"
}

Event Published to Kafka:
Topic: rag_events
{
  "event_type": "faq_created",
  "faq_id": "faq_uuid",
  "namespace": "acme_support_faq",
  "client_id": "uuid",
  "timestamp": "2025-10-15T15:00:00Z"
}
```

**2. Search FAQs**
```http
POST /api/v1/rag/faq/search
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "query": "change my credit card info",
  "namespace": "acme_support_faq",
  "top_k": 3,
  "filters": {
    "category": "billing",
    "language": "en",
    "visibility": "public"
  },
  "confidence_threshold": 0.7
}

Response (200 OK):
{
  "results": [
    {
      "faq_id": "faq_uuid",
      "question": "How do I update my payment method?",
      "answer": "To update your payment method:\n1. Go to Account Settings...",
      "category": "billing",
      "tags": ["billing", "payment", "account_settings"],
      "confidence_score": 0.94,
      "matched_via": "alternate_question",  // question | alternate_question | semantic_search
      "metadata": {
        "language": "en",
        "priority": "high"
      }
    },
    {
      "faq_id": "faq_uuid_2",
      "question": "What payment methods do you accept?",
      "answer": "We accept Visa, MasterCard, American Express...",
      "category": "billing",
      "confidence_score": 0.72,
      "matched_via": "semantic_search"
    }
  ],
  "total_results": 2,
  "auto_response_enabled": true,  // true if top result > threshold
  "recommended_answer": "To update your payment method:\n1. Go to Account Settings..."
}
```

**3. Update FAQ**
```http
PATCH /api/v1/rag/faq/{faq_id}
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "answer": "To update your payment method:\n1. Log in to your account\n2. Navigate to Settings > Billing\n3. Click 'Update Payment Method'\n4. Enter new card details and save",
  "tags": ["billing", "payment", "account_settings", "self_service"]
}

Response (200 OK):
{
  "faq_id": "faq_uuid",
  "version": 2,
  "updated_fields": ["answer", "tags"],
  "updated_at": "2025-10-15T16:00:00Z",
  "vector_embedding_status": "regenerated"
}
```

**4. Delete FAQ**
```http
DELETE /api/v1/rag/faq/{faq_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "faq_id": "faq_uuid",
  "status": "deleted",
  "deleted_at": "2025-10-15T16:05:00Z"
}
```

**5. Bulk Import FAQs**
```http
POST /api/v1/rag/faq/import
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: multipart/form-data

Request Body (multipart):
{
  "file": <faq_import.csv>,
  "namespace": "acme_support_faq",
  "import_mode": "merge",  // merge | replace
  "mapping": {
    "question_column": "Question",
    "answer_column": "Answer",
    "category_column": "Category",
    "tags_column": "Tags"
  }
}

Response (202 Accepted):
{
  "import_job_id": "uuid",
  "status": "processing",
  "total_rows": 350,
  "estimated_completion": "2025-10-15T16:20:00Z"
}
```

**6. Get FAQ Analytics**
```http
GET /api/v1/rag/faq/analytics?namespace={namespace}&date_range=30d
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}

Response (200 OK):
{
  "namespace": "acme_support_faq",
  "date_range": "2025-09-15 to 2025-10-15",
  "total_faqs": 350,
  "total_searches": 12500,
  "avg_confidence_score": 0.83,
  "top_faqs": [
    {
      "faq_id": "faq_uuid",
      "question": "How do I update my payment method?",
      "hit_count": 450,
      "avg_confidence": 0.91
    },
    {
      "faq_id": "faq_uuid_2",
      "question": "How do I reset my password?",
      "hit_count": 380,
      "avg_confidence": 0.89
    }
  ],
  "low_confidence_queries": [
    {
      "query": "refund policy for cancelled orders",
      "search_count": 35,
      "avg_confidence": 0.58,
      "suggestion": "Create FAQ for refund policy"
    }
  ],
  "category_breakdown": {
    "billing": 120,
    "technical_support": 95,
    "account_management": 80,
    "product_features": 55
  }
}
```

**Data Storage:**
- **PostgreSQL**: FAQ metadata, categories, tags, version history
- **Qdrant**: FAQ vector embeddings (question + alternate questions)
- **Redis**: FAQ search result cache (1-hour TTL)

**Database Schema:**
```sql
CREATE TABLE faqs (
  faq_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  namespace VARCHAR(255) NOT NULL,
  category VARCHAR(255),
  question TEXT NOT NULL,
  alternate_questions TEXT[],
  answer TEXT NOT NULL,
  tags TEXT[],
  version INTEGER DEFAULT 1,
  status VARCHAR(50) DEFAULT 'active',  -- active | archived
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_faqs_client ON faqs(client_id);
CREATE INDEX idx_faqs_namespace ON faqs(namespace);
CREATE INDEX idx_faqs_category ON faqs(category);
CREATE INDEX idx_faqs_status ON faqs(status);
CREATE INDEX idx_faqs_tags ON faqs USING GIN(tags);

-- Row-Level Security
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY faqs_tenant_isolation ON faqs
  USING (client_id = current_setting('app.current_tenant_id')::UUID);

CREATE TABLE faq_search_logs (
  search_log_id UUID PRIMARY KEY,
  client_id UUID NOT NULL REFERENCES clients(client_id),
  namespace VARCHAR(255) NOT NULL,
  query TEXT NOT NULL,
  faq_id UUID REFERENCES faqs(faq_id),
  confidence_score DECIMAL(3,2),
  matched_via VARCHAR(50),  -- question | alternate_question | semantic_search
  conversation_id UUID,  -- Link to chatbot conversation
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_search_logs_client ON faq_search_logs(client_id);
CREATE INDEX idx_search_logs_namespace ON faq_search_logs(namespace);
CREATE INDEX idx_search_logs_timestamp ON faq_search_logs(timestamp);

CREATE TABLE faq_versions (
  version_id UUID PRIMARY KEY,
  faq_id UUID REFERENCES faqs(faq_id),
  version INTEGER NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  alternate_questions TEXT[],
  changed_by UUID,
  changed_at TIMESTAMP DEFAULT NOW(),
  change_reason TEXT
);

CREATE INDEX idx_faq_versions_faq ON faq_versions(faq_id);
```

**Integration Points:**
- **Service 8 (Agent Orchestration)**: FAQ search integration for chatbot auto-responses
- **Service 9 (Voice Agent)**: FAQ search for voicebot responses
- **Service 11 (Monitoring)**: Track FAQ hit rates, low-confidence queries, search failures
- **Service 14 (Support Engine)**: Suggest FAQ creation from repeated support queries

**Frontend Component:**
- Component: `FAQManager.tsx`
- Features:
  - FAQ CRUD interface with rich text editor
  - Category/tag management
  - Bulk import wizard (CSV/Excel upload)
  - FAQ analytics dashboard (hit rates, confidence scores)
  - Low-confidence query report (suggests new FAQs)
  - FAQ version history viewer
  - A/B testing for FAQ answers

**AI-Powered Features:**

1. **FAQ Suggestion from Support Tickets:**
   - Analyze support tickets to identify common questions
   - Auto-generate FAQ draft from ticket patterns
   - Platform Engineer approval before publishing

2. **Answer Quality Scoring:**
   - Evaluate answer completeness using LLM
   - Suggest improvements for low-scoring answers
   - Track user satisfaction per FAQ

3. **Automatic Categorization:**
   - Auto-assign categories based on question content
   - Suggest tags using entity extraction

**Rate Limiting:**
- 100 FAQ creations per hour per tenant
- 1000 FAQ searches per minute per tenant
- 10 bulk imports per day per tenant

---

## 18. Outbound Communication Service → CONSOLIDATED

**Service 18 has been consolidated into Service 20 (Communication & Hyperpersonalization Engine)** - *[See MICROSERVICES_ARCHITECTURE_PART3.md Service 20]* for complete specification.

**Rationale**: Service 18 (Outbound Communication) and Service 20 (Hyperpersonalization Engine) shared significant overlap in functionality:
- Both services managed email/SMS delivery (via SendGrid and Twilio)
- Both services handled template management and variable substitution
- Both services tracked engagement metrics (opens, clicks, deliverability)
- Both services consumed similar Kafka events for triggering communications

This consolidation:
- ✅ Eliminates duplicate email/SMS sending logic
- ✅ Unifies template management into single service
- ✅ Reduces complexity of outbound communication workflows
- ✅ Enables unified tracking of all customer communications (transactional + personalized)
- ✅ Simplifies integration points for Services 13 (Customer Success) and 14 (Support Engine)

**Kafka Topic Change**:
- `outreach_events` and `personalization_events` → `communication_events` (unified)

**Functionality Now in Service 20**:
1. Email delivery via SendGrid (transactional and personalized)
2. SMS delivery via Twilio (alerts and personalized messaging)
3. Requirements form generation and distribution
4. Follow-up sequence automation (drip campaigns)
5. Email/SMS template management with variable substitution
6. Delivery tracking and analytics (open rates, click rates, bounce rates)
7. Customer cohort segmentation and lifecycle messaging
8. A/B/N experimentation for message optimization

---

## Supporting Libraries

### @workflow/llm-sdk

**Purpose**: Direct LLM inference with intelligent routing, semantic caching, and cost optimization

**Replaces**: Service 16 (LLM Gateway microservice)

**Installation**:
```bash
# Python
pip install workflow-llm-sdk

# Node.js
npm install @workflow/llm-sdk
```

**Used By**:
- Service 8 (Agent Orchestration) - *[See MICROSERVICES_ARCHITECTURE_PART3.md]*
- Service 9 (Voice Agent) - *[See MICROSERVICES_ARCHITECTURE_PART3.md]*
- Service 13 (Customer Success) - *[See MICROSERVICES_ARCHITECTURE_PART3.md]*
- Service 14 (Support Engine) - *[See MICROSERVICES_ARCHITECTURE_PART3.md]*
- Service 21 (Agent Copilot) - *[See MICROSERVICES_ARCHITECTURE_PART3.md]*

**Key Features**:
1. **Model Routing**: Automatically route requests to GPT-4, GPT-3.5, Claude based on complexity
2. **Semantic Caching**: Cache similar prompts to reduce API costs (40-60% cost reduction)
3. **Token Counting**: Accurate token estimation before API calls
4. **Cost Tracking**: Per-tenant LLM usage tracking with real-time cost analytics
5. **Fallback Strategy**: Automatic failover to backup models on provider failures
6. **Streaming Support**: Server-Sent Events (SSE) for real-time response streaming
7. **Multi-Provider**: OpenAI, Anthropic, Google Gemini, Azure OpenAI

**Benefits**:
- ✅ Eliminates 200-500ms latency per LLM call (no network hop)
- ✅ Reduces single point of failure
- ✅ Simpler observability (direct tracing to LLM provider)
- ✅ Service autonomy (each service manages own LLM interactions)
- ✅ Cost tracking still maintained via library instrumentation

**Usage Example (Python)**:
```python
from workflow_llm_sdk import LLMClient

llm = LLMClient(
    api_key=os.getenv("OPENAI_API_KEY"),
    fallback_api_key=os.getenv("ANTHROPIC_API_KEY"),
    enable_caching=True,
    tenant_id="org_123"
)

# Automatic routing based on complexity
response = llm.complete(
    prompt="Generate a comprehensive PRD for...",
    max_tokens=2000,
    temperature=0.7,
    model_preference="balanced"  # cheap | balanced | premium
)

print(f"Response: {response.content}")
print(f"Model used: {response.model_used}")
print(f"Cost: ${response.usage.estimated_cost_usd}")
print(f"Cache hit: {response.cache_hit}")
```

**Usage Example (Node.js)**:
```typescript
import { LLMClient } from '@workflow/llm-sdk';

const llm = new LLMClient({
  apiKey: process.env.OPENAI_API_KEY,
  fallbackApiKey: process.env.ANTHROPIC_API_KEY,
  enableCaching: true,
  tenantId: 'org_123'
});

const response = await llm.complete({
  prompt: 'Generate a comprehensive PRD for...',
  maxTokens: 2000,
  temperature: 0.7,
  modelPreference: 'balanced'
});

console.log(`Response: ${response.content}`);
console.log(`Model used: ${response.modelUsed}`);
console.log(`Cost: $${response.usage.estimatedCostUsd}`);
console.log(`Cache hit: ${response.cacheHit}`);
```

**Configuration**:
- Primary model: GPT-4 (for complex tasks requiring premium quality)
- Secondary model: GPT-3.5 (for simple tasks requiring speed/cost efficiency)
- Fallback: Claude Opus-4 (when OpenAI unavailable)
- Cache TTL: 1 hour (configurable per tenant)
- Cost threshold for auto-routing: Estimate tokens, use cheaper model if <500 tokens

**Model Routing Logic**:
```
User requests "cheap":
  → Route to gpt-3.5-turbo (OpenAI) or Claude Instant (Anthropic)
  → Fallback: Gemini Pro (Google)

User requests "balanced":
  → Route to gpt-4-turbo (OpenAI) or Claude Sonnet (Anthropic)
  → Fallback: gpt-3.5-turbo

User requests "premium":
  → Route to gpt-4 (OpenAI) or Claude Opus (Anthropic)
  → Fallback: gpt-4-turbo
```

**Semantic Caching Implementation**:
```
1. Generate embedding for incoming prompt (text-embedding-3-small)
2. Search Redis for similar embeddings (cosine similarity > 0.95)
3. If cache hit:
   a. Return cached response
   b. Log cache hit, save cost
   c. Increment cache_hit_rate metric
4. If cache miss:
   a. Call LLM provider
   b. Store embedding + response in Redis (TTL: 1 hour)
   c. Return response
```

**Cost Analytics**:
The library automatically tracks:
- Token usage per tenant, per service, per model
- Cost per request with real-time totals
- Cache hit rates and cost savings
- Daily/monthly cost trends

Data is stored in:
- PostgreSQL: Token usage logs, cost attribution per tenant
- TimescaleDB: Time-series cost analytics, usage trends
- Redis: Semantic cache storage, rate limiting counters

**Error Handling**:
- Provider failures → Automatic failover to backup provider
- Rate limits → Exponential backoff with retry
- Invalid requests → Validation errors with clear messages
- Cost budget exceeded → Alert + optional throttling

---

### @workflow/config-sdk

**Purpose**: S3-based configuration storage with JSON Schema validation and hot-reload

**Replaces**: Service 10 (Configuration Management microservice) - *documented in MICROSERVICES_ARCHITECTURE_PART3.md*

**Installation**:
```bash
# Python
pip install workflow-config-sdk

# Node.js
npm install @workflow/config-sdk
```

**Used By**: All services requiring JSON configuration (Services 8, 9, and others)

**Key Features**:
1. **Direct S3 Access**: No intermediate service, read configs directly from S3
2. **JSON Schema Validation**: Client-side config validation before applying
3. **Client-Side Caching**: Redis-backed caching for performance
4. **Hot-Reload Support**: Watch for config changes via Redis pub/sub
5. **Version Control**: Track config versions with rollback support

**Benefits**:
- ✅ Eliminates 50-100ms latency per config fetch
- ✅ Simpler architecture (no Config Management service needed)
- ✅ Service autonomy (each service manages own config access)
- ✅ Reduced infrastructure overhead

**See**: MICROSERVICES_ARCHITECTURE_PART3.md "Supporting Libraries" section for complete @workflow/config-sdk documentation

---

*Continued in MICROSERVICES_ARCHITECTURE_PART3.md with services 8-15*

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
