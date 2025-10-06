# Microservices Architecture Specification (Part 2)
## Complete Workflow Automation System - Remaining Services

---

## 6. PRD Builder Engine Service

#### Objectives
- **Primary Purpose**: AI-powered generation of comprehensive Product Requirement Documents (PRDs) for chatbot and voicebot products through conversational interface with cross-questioning and village knowledge integration
- **Business Value**: Reduces PRD creation from 20+ hours to 2-3 hours, leverages multi-client learnings, ensures completeness through AI-driven edge case analysis
- **Product Differentiation**: Supports both chatbot (LangGraph-based) and voicebot (LiveKit-based) product types with product-specific requirements, sprint planning, and integration architecture
- **Scope Boundaries**:
  - **Does**: Generate PRDs via webchat UI, integrate village knowledge, suggest new objectives, design A/B flows, plan integrations and escalations, differentiate chatbot vs voicebot requirements
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
- **NDA Generator** (consumes nda_fully_signed event to trigger PRD session)
- **Demo Generator** (demo data provides use case context for PRD)
- **Research Engine** (volume predictions inform PRD volume requirements)
- Agent Orchestration Service (village knowledge retrieval)
- **Pricing Model Generator** (PRD approval triggers pricing generation via prd_approved event)
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
9. ✅ **Help button with shareable code generation** (expiring codes for human agent collaboration)
10. ✅ **Real-time collaborative canvas** (multi-user editing with cursor tracking)
11. ✅ **Human agent join capability** (agents can join PRD sessions to help clients)
12. ✅ **Collaboration chat** (side-by-side chat during PRD building)

**Nice-to-Have:**
13. 🔄 Auto-generated user stories from PRD
14. 🔄 Competitive analysis integration
15. 🔄 Risk assessment and mitigation planning
16. 🔄 ROI calculator based on automation metrics

**Feature Interactions:**
- NDA signing → Auto-triggers PRD session (consumes nda_fully_signed event)
- PRD approval → Triggers pricing model generation (publishes prd_approved event to prd_events topic)
- Pricing completion → Proposal generation uses both PRD and pricing data
- Village knowledge → Suggests objectives client didn't request
- Help button clicked → Generates shareable code → Publishes help_requested event → Human agent joins → Real-time collaboration begins
- Collaboration ended → Session resumes with AI PRD builder → Client continues independently
- Requirements form data → Validates client-stated volumes against PRD technical requirements

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
  "duration_minutes": 15,
  "ended_by": "uuid",
  "timestamp": "2025-10-04T12:20:00Z"
}
```

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

4. **PRD Collaboration Support Agent (Human)**
   - Role: Joins PRD sessions to help clients with complex questions, provides expert guidance
   - Access: Join PRD sessions via shareable code, read/write canvas, chat with clients
   - Permissions: join:collaboration_sessions, read:prd, write:canvas, chat:clients
   - Workflows: Monitors help request queue → Joins session via shareable code → Chats with client → Edits canvas collaboratively → Resolves issue → Ends session
   - Approval: None (agent-initiated collaboration on client request)

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
- **Proposal Generator** (consumes proposal_signed event to trigger YAML config generation)
- **PRD Builder** (provides PRD data for config population)
- Agent Orchestration Service (loads YAML configs for chatbot runtime)
- Voice Agent Service (loads YAML configs for voicebot runtime)
- Configuration Management Service (stores and distributes configs)
- GitHub API (issue creation, status tracking)

**Technical Architecture by Product Type:**

1. **Chatbot Products** (LangGraph-based):
   - **Runtime Service**: Agent Orchestration Service
   - **Framework**: LangGraph two-node workflow (agent node + tools node)
   - **Architecture Reference**: https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/
   - **YAML Config Features**:
     - StateGraph implementation with checkpointing
     - `external_integrations` field (Salesforce, Zendesk, etc.)
     - Dynamic tool loading from YAML
     - PostgreSQL-backed state persistence
   - **Config Consumption**: Agent Orchestration Service reads chatbot YAML configs
   - **Documentation**: See MICROSERVICES_ARCHITECTURE_PART3.md (Agent Orchestration Service)

2. **Voicebot Products** (LiveKit-based):
   - **Runtime Service**: Voice Agent Service
   - **Framework**: LiveKit Agents (Python SDK) with VoicePipelineAgent
   - **Architecture Components**:
     - STT Pipeline: Deepgram Nova-3 streaming transcription
     - LLM Integration: Same as chatbot but optimized for voice latency
     - TTS Pipeline: ElevenLabs Flash v2.5 with dual streaming
     - SIP Integration: Twilio (primary), Telnyx (failover)
   - **YAML Config Features**:
     - NO `external_integrations` field (voice-only channel)
     - SIP endpoint configured separately via SIP trunk provisioning
     - Voice-specific config: STT/TTS providers, voice_id, turn detection
     - Tool execution via LiveKit agent callbacks
   - **Config Consumption**: Voice Agent Service reads voicebot YAML configs
   - **Documentation**: See MICROSERVICES_ARCHITECTURE_PART3.md (Voice Agent Service)

3. **Hybrid Deployments**:
   - Requires **separate YAML configs** for chatbot and voicebot
   - PRD includes distinct sprint roadmaps per product type
   - Shared PRD objectives but product-specific implementations
   - Cross-product communication via `cross_product_events` Kafka topic

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

**Example: Voicebot YAML Config (LiveKit-based)**
```yaml
config_metadata:
  config_id: uuid_voicebot
  product_type: voicebot
  client_id: uuid
  version: 1
  environment: staging
  created_at: 2025-10-10T15:00:00Z

system_prompt:
  role: healthcare_appointment_scheduler
  instructions: "You are a friendly voice assistant for HealthCare Plus. Help patients schedule, reschedule, or cancel medical appointments. Always confirm appointment details before booking."
  constraints:
    - Never share patient medical records over the phone
    - Verify patient identity before any changes
    - Escalate to human for emergency requests
  tone: empathetic_professional
  voice_specific:
    speaking_rate: normal
    interruption_sensitivity: medium
    silence_timeout_ms: 2000

tools_available:
  - tool_name: check_appointment_availability
    status: implemented
  - tool_name: book_appointment
    status: implemented
  - tool_name: send_sms_confirmation
    status: missing
    github_issue: https://github.com/workflow/tools/issues/201

integrations: []
# NOTE: Voicebot products do NOT have external_integrations field
# Voice channel is the ONLY input method via SIP trunks

sip_config:
  primary_provider: twilio
  primary_endpoint: "+14155551234"
  failover_provider: telnyx
  failover_endpoint: "+14155555678"
  inbound_calls_enabled: true
  outbound_calls_enabled: true
  call_recording: true
  recording_retention_days: 90

livekit_config:
  room_prefix: healthcare_plus
  stt_provider: deepgram
  stt_model: nova-3
  stt_language: en-US
  tts_provider: elevenlabs
  tts_voice_id: ErXwobaYiN019PkySvjV
  tts_model: flash_v2_5
  vad_enabled: true
  vad_threshold: 0.5

llm_config:
  provider: openai
  model: gpt-4o-mini
  # Note: Voicebots use faster/cheaper models for low-latency responses
  parameters:
    temperature: 0.6
    max_tokens: 150
    top_p: 0.9
  fallback:
    provider: anthropic
    model: claude-sonnet-4

workflow_features:
  pii_collection:
    enabled: true
    fields: ["patient_name", "date_of_birth", "phone"]
  human_escalation:
    enabled: true
    triggers:
      - condition: patient_requests_doctor
        action: immediate_transfer
      - condition: emergency_keywords_detected
        action: immediate_transfer
      - condition: ai_confidence < 0.4
        action: suggest_transfer
  call_transfer:
    enabled: true
    transfer_destinations:
      - name: front_desk
        phone: +14155556789
      - name: emergency_line
        phone: +14155559999
  voicemail:
    enabled: true
    max_duration_seconds: 120
    transcription_enabled: true
  outbound_calling:
    enabled: true
    triggers:
      - event: appointment_reminder_24h
        template: reminder_script
      - event: appointment_confirmation
        template: confirmation_script

database_config:
  type: supabase
  tables: ["call_logs", "appointments", "patient_records"]
  rls_enabled: true

vector_db_config:
  type: pinecone
  index_name: healthcare_knowledge_base
  namespace: healthcare_plus
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

## 16. LLM Gateway Service

#### Objectives
- **Primary Purpose**: Centralized LLM inference with model routing, semantic caching, token monitoring, and cost optimization across all AI-powered services
- **Business Value**: Reduces LLM costs by 40-60% through caching and smart routing, provides unified interface for multi-provider support, enables real-time cost tracking
- **Scope Boundaries**:
  - **Does**: Route requests to optimal models, cache semantically similar prompts, track token usage, provide fallback mechanisms, support streaming responses
  - **Does Not**: Train models, fine-tune models, manage model deployment infrastructure

#### Requirements

**Functional Requirements:**
1. Multi-provider support (OpenAI GPT-4/3.5, Anthropic Claude, Google Gemini, Azure OpenAI)
2. Semantic caching with similarity threshold (e.g., 95% similar → cache hit)
3. Model routing based on complexity, cost, latency requirements
4. Token usage tracking per tenant, per service, per model
5. Streaming response support for real-time conversations
6. Fallback routing when primary model unavailable
7. Rate limiting per provider API limits
8. Cost budgeting and alerting

**Non-Functional Requirements:**
- Inference latency: <500ms P95 (excluding model processing time)
- Cache hit rate: >40% (target 60%)
- Support 10,000+ requests/second
- 99.99% uptime (critical for all AI workflows)
- Cost reduction: 40-60% vs. direct API calls

**Dependencies:**
- Agent Orchestration Service (primary consumer)
- Voice Agent Service (real-time inference)
- PRD Builder (document generation)
- Demo Generator (content creation)
- Redis (semantic cache storage)
- Analytics Service (cost tracking)

**Data Storage:**
- Redis: Semantic cache (prompt embeddings + responses), rate limiting counters
- PostgreSQL: Token usage logs, cost attribution per tenant
- TimescaleDB: Time-series cost analytics, usage trends

#### Features

**Must-Have:**
1. ✅ Multi-provider routing (OpenAI, Anthropic, Google)
2. ✅ Semantic caching with embedding-based similarity
3. ✅ Token usage tracking (per tenant, per service, per model)
4. ✅ Streaming response support (SSE)
5. ✅ Automatic fallback routing on provider failures
6. ✅ Cost budgeting with alerts (daily/monthly limits)
7. ✅ Model selection API (cheap, balanced, premium)
8. ✅ Real-time cost dashboard

**Nice-to-Have:**
9. 🔄 Fine-tuned model deployment
10. 🔄 A/B testing different models
11. 🔄 Prompt optimization suggestions
12. 🔄 Cost forecasting based on usage patterns

#### API Specification

**1. Chat Completion (Routed)**
```http
POST /api/v1/llm/chat
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
X-Service-Name: agent_orchestration
Content-Type: application/json

Request Body:
{
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is the capital of France?"}
  ],
  "model_preference": "balanced",  // cheap | balanced | premium
  "max_tokens": 500,
  "temperature": 0.7,
  "stream": false,
  "enable_cache": true
}

Response (200 OK):
{
  "id": "chatcmpl-uuid",
  "model_used": "gpt-3.5-turbo",  // Actual model routed to
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 8,
    "total_tokens": 33,
    "estimated_cost_usd": 0.000066
  },
  "cache_hit": false,
  "latency_ms": 420
}
```

**2. Streaming Chat Completion**
```http
POST /api/v1/llm/chat
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "messages": [...],
  "model_preference": "premium",
  "stream": true
}

Response (200 OK - Server-Sent Events):
data: {"delta": {"content": "The"}, "model_used": "gpt-4"}
data: {"delta": {"content": " capital"}}
data: {"delta": {"content": " of France is Paris."}}
data: {"usage": {"total_tokens": 33, "estimated_cost_usd": 0.00099}, "finish_reason": "stop"}
data: [DONE]
```

**3. Generate Embeddings**
```http
POST /api/v1/llm/embeddings
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "input": "Semantic search query text",
  "model": "text-embedding-3-small"  // or text-embedding-ada-002
}

Response (200 OK):
{
  "embeddings": [[0.023, -0.015, 0.042, ...]],  // 1536-dim vector
  "model_used": "text-embedding-3-small",
  "usage": {
    "prompt_tokens": 5,
    "total_tokens": 5,
    "estimated_cost_usd": 0.000001
  }
}
```

**4. Get Model Availability**
```http
GET /api/v1/llm/models
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "models": [
    {
      "id": "gpt-4",
      "provider": "openai",
      "tier": "premium",
      "status": "available",
      "cost_per_1k_tokens": 0.03,
      "max_tokens": 8192,
      "supports_streaming": true
    },
    {
      "id": "gpt-3.5-turbo",
      "provider": "openai",
      "tier": "cheap",
      "status": "available",
      "cost_per_1k_tokens": 0.002,
      "max_tokens": 4096,
      "supports_streaming": true
    },
    {
      "id": "claude-3-opus",
      "provider": "anthropic",
      "tier": "premium",
      "status": "unavailable",  // Fallback routing active
      "cost_per_1k_tokens": 0.015,
      "max_tokens": 200000,
      "supports_streaming": true
    }
  ]
}
```

**5. Get Cost Analytics**
```http
GET /api/v1/llm/analytics/costs
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Query Parameters:
- start_date: 2025-10-01
- end_date: 2025-10-06
- group_by: service | model | day

Response (200 OK):
{
  "total_cost_usd": 142.35,
  "total_tokens": 4750000,
  "cache_hit_rate": 0.58,
  "cost_saved_usd": 95.20,
  "breakdown": [
    {
      "service_name": "agent_orchestration",
      "model": "gpt-3.5-turbo",
      "total_tokens": 2100000,
      "cost_usd": 42.00,
      "requests": 12450
    },
    {
      "service_name": "voice_agent",
      "model": "gpt-4",
      "total_tokens": 850000,
      "cost_usd": 76.50,
      "requests": 3200
    }
  ],
  "daily_trend": [
    {"date": "2025-10-01", "cost_usd": 22.40, "tokens": 750000},
    {"date": "2025-10-02", "cost_usd": 28.75, "tokens": 960000}
  ]
}
```

#### Model Routing Logic

**Model Selection Strategy:**
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

**Semantic Caching:**
```
1. Generate embedding for incoming prompt
2. Search Redis for similar embeddings (cosine similarity > 0.95)
3. If cache hit:
   a. Return cached response
   b. Log cache hit, save cost
   c. Increment cache_hit_rate metric
4. If cache miss:
   a. Call LLM provider
   b. Store embedding + response in Redis (TTL: 24 hours)
   c. Return response
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Platform Engineer**
   - Role: Monitors LLM costs, adjusts routing logic, manages API keys
   - Access: Cost dashboards, model configuration
   - Permissions: admin:llm_gateway, manage:api_keys, configure:routing
   - Workflows: Reviews daily cost reports, adjusts budgets, optimizes caching

**AI Agents:**

1. **Cost Optimization Agent**
   - Responsibility: Analyzes usage patterns, suggests model downgrades, identifies cache opportunities
   - Tools: Analytics queries, cost calculators, usage pattern detectors
   - Autonomy: Recommendations only, human approval required for routing changes
   - Escalation: Alerts Platform Engineer when costs exceed budget

2. **Fallback Routing Agent**
   - Responsibility: Monitors provider health, switches to backup providers on failures
   - Tools: Health check APIs, circuit breakers, retry logic
   - Autonomy: Fully autonomous
   - Escalation: Alerts on sustained provider outages (>5 minutes)

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

---

## 18. Outbound Communication Service

#### Objectives
- **Primary Purpose**: Automated and manual email/SMS outreach for sales, onboarding reminders, claim links, and customer success communications
- **Business Value**: Automates 80% of outreach emails, tracks engagement metrics, enables sales agents to focus on high-value conversations
- **Scope Boundaries**:
  - **Does**: Send emails/SMS, track opens/clicks, manage templates, create manual outreach tickets, schedule campaigns
  - **Does Not**: Generate email content (AI does), make phone calls (Voice Agent does), manage CRM data (CRM Integration does)

#### Requirements

**Functional Requirements:**
1. Automated email sending triggered by events (research_completed, account_claimed, etc.)
2. Email template management with variable substitution
3. Manual outreach ticket system for sales agents
4. Email engagement tracking (opens, clicks, replies)
5. SMS notifications for high-priority alerts
6. Campaign scheduling and drip sequences
7. Unsubscribe management and compliance (CAN-SPAM, GDPR)
8. **Requirements draft generation** - AI auto-generates draft from research findings for human review
9. **Human approval workflow** - Sales agent reviews/approves requirements draft before sending to client
10. **Requirements validation form** - Presents research findings to client for confirmation/corrections
11. **Client feedback validation** - Compares client corrections against AI predictions, flags major discrepancies

**Non-Functional Requirements:**
- Email delivery latency: <5 seconds
- Deliverability rate: >95%
- Support 100,000+ emails/day
- SMS delivery: <10 seconds
- 99.9% uptime

**Dependencies:**
- Research Engine (consumes research_completed events)
- Organization Management (consumes assisted_account_created events)
- Human Agent Management (manual ticket assignment)
- SendGrid (email delivery)
- Twilio (SMS delivery)

**Data Storage:**
- PostgreSQL: Email templates, outreach tickets, engagement logs, unsubscribe lists
- Redis: Rate limiting, email queue
- S3: Email attachments

#### API Specification

**1. Send Automated Email**
```http
POST /api/v1/outreach/send-email
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "template_id": "research_completed_outreach",
  "recipient_email": "client@example.com",
  "variables": {
    "client_name": "Jane Smith",
    "company_name": "Example Corp",
    "research_summary": "We analyzed your industry and identified 3 automation opportunities...",
    "claim_link": "https://app.workflow.com/claim/CLAIM-ABC123"
  },
  "scheduled_at": null,  // Send immediately, or ISO timestamp for scheduling
  "track_engagement": true
}

Response (200 OK):
{
  "email_id": "uuid",
  "status": "sent",
  "sent_at": "2025-10-06T10:30:00Z",
  "tracking_enabled": true,
  "estimated_delivery": "2025-10-06T10:30:05Z"
}

Event Published to Kafka:
Topic: outreach_events
{
  "event_type": "email_sent",
  "email_id": "uuid",
  "recipient_email": "client@example.com",
  "template_id": "research_completed_outreach",
  "sent_at": "2025-10-06T10:30:00Z"
}
```

**2. Create Manual Outreach Ticket**
```http
POST /api/v1/outreach/tickets
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "organization_id": "uuid",
  "assigned_agent_id": "uuid",
  "ticket_type": "manual_email",  // manual_email | phone_call | linkedin_message
  "reason": "research_completed_no_auto_email",
  "notes": "Client requires custom introduction due to previous relationship",
  "priority": "high"
}

Response (201 Created):
{
  "ticket_id": "uuid",
  "status": "open",
  "assigned_agent": {
    "agent_id": "uuid",
    "agent_name": "Sam Peterson",
    "agent_role": "sales_agent"
  },
  "created_at": "2025-10-06T10:30:00Z",
  "due_date": "2025-10-07T18:00:00Z"
}
```

**3. Generate Requirements Draft (AI Auto-Generated)**
```http
POST /api/v1/outreach/requirements-draft/generate
Authorization: Bearer {jwt_token}
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "client_id": "uuid",
  "organization_id": "uuid",
  "research_job_id": "uuid"
}

Response (201 Created):
{
  "draft_id": "uuid",
  "client_id": "uuid",
  "research_summary": "Based on our research, Acme Corp is an e-commerce business with strong Instagram presence (15K followers, 3.2% engagement). Current customer service operates 9am-6pm with gaps in evening coverage.",
  "predicted_volumes": {
    "chat_volume_monthly": 1400,
    "call_volume_monthly": 450,
    "email_volume_monthly": 850,
    "website_traffic_monthly": 45000,
    "confidence_score": 0.85
  },
  "recommended_services": {
    "chatbot_types": ["Website chatbot (chat widget)", "WhatsApp chatbot", "Instagram chatbot"],
    "voicebot_types": ["Phone call (inbound/outbound)"],
    "rationale": "Instagram chatbot recommended due to high social engagement. Website chatbot for 24/7 coverage. Phone voicebot for existing call volume."
  },
  "status": "pending_review",
  "created_at": "2025-10-06T10:00:00Z"
}

Event Published to Kafka:
Topic: outreach_events
{
  "event_type": "requirements_draft_generated",
  "draft_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "research_job_id": "uuid",
  "assigned_reviewer": "sales_agent_uuid",
  "timestamp": "2025-10-06T10:00:00Z"
}
```

**4. Approve Requirements Draft (Human Agent)**
```http
POST /api/v1/outreach/requirements-draft/{draft_id}/approve
Authorization: Bearer {jwt_token}  // Sales Agent JWT
X-Tenant-ID: {tenant_id}
Content-Type: application/json

Request Body:
{
  "draft_id": "uuid",
  "approved_by": "sales_agent_uuid",
  "modifications": {
    "research_summary": "Optional: Updated summary text if agent makes changes",
    "recommended_services": {
      "chatbot_types": ["Website chatbot (chat widget)", "WhatsApp chatbot"]  // Agent removed Instagram
    }
  },
  "recipient_email": "client@example.com",
  "send_immediately": true,
  "expires_in_hours": 72
}

Response (200 OK):
{
  "draft_id": "uuid",
  "form_id": "uuid",  // Generated form ID for client submission
  "status": "approved_and_sent",
  "recipient_email": "client@example.com",
  "form_url": "https://app.workflow.com/forms/requirements/{form_id}",
  "sent_at": "2025-10-06T11:00:00Z",
  "expires_at": "2025-10-09T11:00:00Z"
}

Event Published to Kafka:
Topic: outreach_events
{
  "event_type": "requirements_draft_approved",
  "draft_id": "uuid",
  "form_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "approved_by": "sales_agent_uuid",
  "approved_at": "2025-10-06T11:00:00Z",
  "sent_to_client": true,
  "timestamp": "2025-10-06T11:00:00Z"
}

{
  "event_type": "requirements_form_sent",
  "form_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "draft_id": "uuid",
  "recipient_email": "client@example.com",
  "research_job_id": "uuid",
  "sent_at": "2025-10-06T11:00:00Z",
  "expires_at": "2025-10-09T11:00:00Z"
}
```

**5. Submit Requirements Validation (Client Validates Research Findings)**
```http
POST /api/v1/outreach/forms/{form_id}/submit
Authorization: Bearer {jwt_token}  // Client JWT
Content-Type: application/json

Request Body:
{
  "form_id": "uuid",
  "client_id": "uuid",
  "validation_response": {
    "research_findings_accurate": true,  // Client confirms research is accurate
    "volume_corrections": {
      "chat_volume": 1200,  // Client corrects from predicted 1400
      "call_volume": null  // null = agrees with prediction (450)
    },
    "service_confirmations": {
      "chatbot_types": ["Website chatbot (chat widget)", "WhatsApp chatbot"],  // Confirms 2 of 3 recommended
      "voicebot_types": ["Phone call (inbound/outbound)"]  // Confirms recommendation
    },
    "additional_requirements": "Need integration with existing Zendesk ticketing system. Also require Spanish language support.",
    "corrections_needed": "Our evening traffic is higher than research shows - we need 24/7 coverage prioritized."
  }
}

Response (200 OK):
{
  "submission_id": "uuid",
  "form_id": "uuid",
  "status": "completed",
  "validation_summary": {
    "research_confirmed": true,
    "corrections_provided": true,
    "discrepancy_analysis": {
      "chat_volume": {
        "ai_predicted": 1400,
        "client_corrected": 1200,
        "discrepancy_percent": -14.3,
        "flag_for_review": false  // <30% discrepancy
      },
      "call_volume": {
        "ai_predicted": 450,
        "client_confirmed": 450,  // Client agreed with prediction
        "discrepancy_percent": 0,
        "flag_for_review": false
      }
    },
    "additional_requirements_captured": true
  },
  "next_step": "demo_generation",
  "submitted_at": "2025-10-06T14:30:00Z"
}

Event Published to Kafka:
Topic: client_events
{
  "event_type": "requirements_validation_completed",
  "form_id": "uuid",
  "draft_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "validation_response": {
    "research_findings_accurate": true,
    "volume_corrections": {
      "chat_volume": 1200,  // Corrected from 1400
      "call_volume": 450  // Confirmed prediction
    },
    "service_confirmations": {
      "chatbot_types": ["Website chatbot (chat widget)", "WhatsApp chatbot"],
      "voicebot_types": ["Phone call (inbound/outbound)"]
    },
    "additional_requirements": "Need integration with existing Zendesk ticketing system. Also require Spanish language support.",
    "corrections_needed": "Our evening traffic is higher than research shows - we need 24/7 coverage prioritized."
  },
  "discrepancy_analysis": {
    "chat_volume_discrepancy": -14.3,
    "call_volume_discrepancy": 0,
    "flags_for_review": []  // Empty if all discrepancies <30%
  },
  "timestamp": "2025-10-06T14:30:00Z"
}
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Sales Agent**
   - Role: Reviews and approves AI-generated requirements drafts, handles manual outreach tickets, reviews engagement metrics
   - Access: Requirements draft review queue, assigned tickets, email templates, engagement dashboards
   - Permissions: approve:requirements_drafts, create:manual_tickets, send:emails, view:engagement
   - Workflows: Reviews requirements drafts from research, approves/modifies before sending to client, reviews open tickets, sends custom emails, tracks responses

**AI Agents:**

1. **Email Trigger Agent**
   - Responsibility: Listens to Kafka events (auth_events, research_events, etc.), triggers automated emails
   - Tools: Kafka consumers, email sender API, template renderer
   - Autonomy: Fully autonomous
   - Escalation: Creates manual ticket if email delivery fails 3+ times
   - **Event Handling**:
     - Consumes `assisted_account_created` from `auth_events` topic
     - Extracts `claim_token` from event payload
     - Constructs `claim_link` as: `https://app.workflow.com/claim/{claim_token}`
     - Renders email template with variables (client_name, company_name, claim_link)
     - Sends email via SendGrid API
     - Publishes `email_sent` event to `outreach_events` topic

2. **Requirements Draft Generator Agent**
   - Responsibility: Auto-generates requirements draft from research findings for human review
   - Tools: Research Engine API, LLM (for summarization), Kafka consumers
   - Autonomy: Fully autonomous for draft generation, requires human approval before sending
   - Escalation: N/A - always waits for human approval
   - **Event Handling**:
     - Consumes `research_completed` from `research_events` topic
     - Retrieves research report from Research Engine (GET /api/v1/research/jobs/{job_id}/report)
     - Extracts: business context, predicted volumes, recommended service types
     - Generates research summary using LLM
     - Creates requirements draft with recommendations
     - Publishes `requirements_draft_generated` event to `outreach_events` topic
     - Assigns to sales agent for review

3. **Requirements Validation Agent**
   - Responsibility: Analyzes client validation responses, flags significant discrepancies from AI predictions
   - Tools: Statistical analysis, discrepancy calculator, alert dispatcher
   - Autonomy: Fully autonomous for analysis, flags for human review if variance >30%
   - Escalation: Creates alert ticket for sales agent if high discrepancy detected or major corrections needed
   - **Validation Logic**:
     - Consumes `requirements_validation_completed` from `client_events` topic
     - Compares client corrections vs AI predictions for each volume metric
     - Calculates discrepancy percentage: ((corrected - predicted) / predicted) * 100
     - Flags for review if absolute discrepancy >30%
     - Captures additional_requirements and corrections_needed text
     - Publishes validation results to Demo Generator for confirmed requirements

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
