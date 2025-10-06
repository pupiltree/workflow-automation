# Microservices Architecture Specification (Part 3 - Final)
## Complete Workflow Automation System - Core Runtime & Support Services

---

## 8. Agent Orchestration Service

#### Objectives
- **Primary Purpose**: Core LangGraph-based orchestration engine that powers all chatbot/voicebot workflows using dynamic YAML configurations
- **Business Value**: Enables multi-tenant agent deployment with configuration-driven behavior, supports 10,000+ concurrent conversations, 99.9% uptime
- **Scope Boundaries**:
  - **Does**: Load YAML configs, orchestrate multi-agent workflows, manage conversation state, execute tools, handle escalations
  - **Does Not**: Generate configs (Automation Engine does), implement tools (developers do), manage voice infrastructure

#### Requirements

**Functional Requirements:**
1. Load and hot-reload YAML configs per tenant
2. Implement LangGraph two-node workflow (agent node + tools node)
3. Manage conversation state with PostgreSQL checkpointing
4. Execute tools based on YAML config
5. Handle human escalation triggers
6. Support multi-turn conversations with memory management
7. Implement PII collection and storage
8. Enable cross-sell/upsell based on config
9. Concurrent conversation handling (1000+ per instance)

**Non-Functional Requirements:**
- Response time: <2s P95 latency for chatbot
- Checkpoint persistence: <100ms
- Tool execution timeout: 30s with graceful fallback
- Memory management: Compress context >10K tokens
- Horizontal scalability: 1000+ conversations per pod

**Dependencies:**
- Automation Engine (YAML config source)
- Configuration Management (config distribution)
- LLM Gateway Service (model inference)
- RAG Pipeline Service (knowledge retrieval)
- CRM Integration Service (tool execution)
- Supabase PostgreSQL (state checkpoints, conversation logs)

**Data Storage:**
- PostgreSQL: Conversation threads, checkpoints, PII data, analytics events
- Redis: Short-term memory cache, active session state
- Pinecone: Long-term memory (user preferences, historical facts)

#### Features

**Must-Have:**
1. ✅ YAML-driven agent configuration
2. ✅ LangGraph two-node orchestration (agent + tools)
3. ✅ State checkpointing with fault tolerance
4. ✅ Tool execution framework (dynamic tool loading)
5. ✅ Human escalation workflows
6. ✅ PII collection and storage
7. ✅ Cross-sell/upsell execution
8. ✅ Memory management (short-term + long-term)
9. ✅ Multi-tenant isolation

**Nice-to-Have:**
10. 🔄 Autonomous agents with planning capabilities
11. 🔄 Multi-agent collaboration (supervisor-worker patterns)
12. 🔄 Streaming responses with tool call visibility
13. 🔄 Context window optimization (RAG-based retrieval)

**Feature Interactions:**
- Config hot-reload → Gracefully updates agent behavior mid-conversation
- Tool execution failure → Fallback to alternative tool or escalate
- PII detected → Auto-store with encryption, update user profile

#### API Specification

**1. Start Conversation**
```http
POST /api/v1/orchestration/conversations
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "channel": "webchat",
  "user_id": "uuid",
  "initial_message": "I want to check my order status",
  "context": {
    "customer_id": "C12345",
    "session_id": "uuid",
    "user_agent": "Mozilla/5.0...",
    "ip_address": "192.168.1.1"
  }
}

Response (201 Created):
{
  "conversation_id": "uuid",
  "thread_id": "uuid",
  "status": "active",
  "agent_response": {
    "message": "I'd be happy to help you check your order status! Could you please provide your order number?",
    "message_id": "uuid",
    "metadata": {
      "intent": "order_inquiry",
      "confidence": 0.92,
      "tool_calls": [],
      "escalation_suggested": false
    }
  },
  "conversation_state": {
    "turn_count": 1,
    "pii_collected": {},
    "checkpoint_id": "uuid"
  },
  "created_at": "2025-10-11T10:00:00Z"
}
```

**2. Continue Conversation**
```http
POST /api/v1/orchestration/conversations/{conversation_id}/messages
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "message": "My order number is ORD-78945",
  "attachments": []
}

Response (200 OK):
{
  "conversation_id": "uuid",
  "message_id": "uuid",
  "agent_response": {
    "message": "Thank you! I've found your order ORD-78945. It's currently in transit and expected to arrive on October 15th. Would you like me to send tracking details to your email?",
    "metadata": {
      "intent": "order_status_check",
      "confidence": 0.95,
      "tool_calls": [
        {
          "tool": "fetch_order_status",
          "input": {"order_id": "ORD-78945"},
          "output": {
            "status": "in_transit",
            "expected_delivery": "2025-10-15",
            "tracking_number": "1Z999AA10123456784"
          },
          "execution_time_ms": 345
        }
      ],
      "escalation_suggested": false
    }
  },
  "conversation_state": {
    "turn_count": 2,
    "pii_collected": {
      "order_id": "ORD-78945",
      "email": "john@example.com"
    },
    "checkpoint_id": "uuid"
  },
  "cross_sell_opportunity": {
    "detected": true,
    "product": "Premium Shipping Upgrade",
    "suggestion": "For future orders, would you be interested in our Premium Shipping for guaranteed next-day delivery?",
    "confidence": 0.78
  },
  "updated_at": "2025-10-11T10:02:00Z"
}
```

**3. Trigger Human Escalation**
```http
POST /api/v1/orchestration/conversations/{conversation_id}/escalate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "trigger": "user_requested",
  "reason": "Customer wants to speak with manager about delayed delivery",
  "urgency": "high"
}

Response (200 OK):
{
  "conversation_id": "uuid",
  "escalation_id": "uuid",
  "status": "escalated",
  "assigned_agent": {
    "agent_id": "uuid",
    "name": "Sarah Johnson",
    "role": "Senior Support Agent",
    "status": "available",
    "estimated_response_time": "2 minutes"
  },
  "handoff_summary": {
    "conversation_history": "User inquired about order ORD-78945...",
    "pii_collected": {"order_id": "ORD-78945", "email": "john@example.com"},
    "tools_used": ["fetch_order_status"],
    "sentiment_score": 0.32,
    "issue_category": "delivery_delay"
  },
  "escalated_at": "2025-10-11T10:05:00Z"
}

Event Published to Kafka:
Topic: escalation_events
{
  "event_type": "conversation_escalated",
  "conversation_id": "uuid",
  "escalation_id": "uuid",
  "trigger": "user_requested",
  "assigned_agent_id": "uuid",
  "timestamp": "2025-10-11T10:05:00Z"
}
```

**4. Get Conversation State**
```http
GET /api/v1/orchestration/conversations/{conversation_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "conversation_id": "uuid",
  "thread_id": "uuid",
  "config_id": "uuid",
  "status": "active",
  "channel": "webchat",
  "user_id": "uuid",
  "turn_count": 5,
  "messages": [
    {
      "message_id": "uuid",
      "role": "user",
      "content": "I want to check my order status",
      "timestamp": "2025-10-11T10:00:00Z"
    },
    {
      "message_id": "uuid",
      "role": "assistant",
      "content": "I'd be happy to help...",
      "tool_calls": [],
      "timestamp": "2025-10-11T10:00:15Z"
    },
    ...
  ],
  "pii_collected": {
    "order_id": "ORD-78945",
    "email": "john@example.com",
    "phone": "+1-555-123-4567"
  },
  "tools_executed": [
    {"tool": "fetch_order_status", "count": 1},
    {"tool": "send_tracking_email", "count": 1}
  ],
  "cross_sell_attempted": true,
  "cross_sell_accepted": false,
  "sentiment_trajectory": [0.8, 0.7, 0.65, 0.32, 0.45],
  "checkpoint_ids": ["uuid1", "uuid2", "uuid3", "uuid4", "uuid5"],
  "created_at": "2025-10-11T10:00:00Z",
  "updated_at": "2025-10-11T10:08:00Z"
}
```

**5. Execute Survey**
```http
POST /api/v1/orchestration/conversations/{conversation_id}/survey
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "questions": [
    {
      "question_id": "uuid",
      "question": "How did you hear about us?",
      "type": "single_choice",
      "options": ["Google Search", "Social Media", "Friend Referral", "Advertisement"]
    },
    {
      "question_id": "uuid",
      "question": "On a scale of 1-10, how likely are you to recommend us?",
      "type": "nps_scale"
    }
  ]
}

Response (200 OK):
{
  "conversation_id": "uuid",
  "survey_id": "uuid",
  "status": "sent",
  "agent_message": "Before we finish, I'd love to get your quick feedback! How did you hear about us?",
  "survey_context": {
    "embedded_in_chat": true,
    "skippable": true
  }
}

Survey Response Handling:
{
  "survey_id": "uuid",
  "responses": [
    {"question_id": "uuid", "answer": "Google Search"},
    {"question_id": "uuid", "answer": 9}
  ],
  "nps_score": 9,
  "nps_category": "promoter",
  "stored_at": "2025-10-11T10:10:00Z"
}
```

**6. Handle Unavailable Human Agent**
```http
GET /api/v1/orchestration/escalations/{escalation_id}/status
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "escalation_id": "uuid",
  "conversation_id": "uuid",
  "status": "agent_unavailable",
  "fallback_action": "queue_callback",
  "queue_position": 3,
  "estimated_wait_time": "15 minutes",
  "callback_options": [
    {
      "option": "schedule_callback",
      "description": "We can call you back when an agent is available",
      "estimated_callback_time": "2025-10-11T10:20:00Z"
    },
    {
      "option": "email_support",
      "description": "Send your issue via email and we'll respond within 2 hours"
    },
    {
      "option": "continue_with_ai",
      "description": "Continue working with our AI assistant"
    }
  ],
  "agent_message": "I'm sorry, all our agents are currently assisting other customers. You're #3 in queue with an estimated wait time of 15 minutes. Would you like to schedule a callback, email us, or continue working with me?"
}
```

**Rate Limiting:**
- 1000 concurrent conversations per tenant
- 100 messages per minute per conversation
- 50 tool executions per minute per conversation
- Escalations: 500 per hour per tenant

#### Frontend Components

**1. Chat Widget (Embeddable)**
- Component: `ChatWidget.tsx`
- Features:
  - Customizable branding (colors, logo)
  - Message bubbles with typing indicators
  - Tool execution status (loading states)
  - File upload support
  - Emoji picker
  - Read receipts

**2. Conversation Dashboard (Admin)**
- Component: `ConversationDashboard.tsx`
- Features:
  - Live conversation monitoring
  - Real-time metrics (active, queued, escalated)
  - Agent performance stats
  - Filters (status, sentiment, channel)
  - Bulk actions (reassign, close, export)

**3. Escalation Queue**
- Component: `EscalationQueue.tsx`
- Features:
  - Priority-sorted queue
  - Agent assignment interface
  - Conversation context preview
  - Sentiment indicators
  - SLA countdown timers
  - Bulk assignment

**4. PII Collection Tracker**
- Component: `PIICollectionTracker.tsx`
- Features:
  - Real-time PII detection visualization
  - Field completeness indicators
  - Data enrichment suggestions
  - Encryption status
  - Export capabilities (encrypted)

**5. Cross-Sell Dashboard**
- Component: `CrossSellDashboard.tsx`
- Features:
  - Opportunity detection metrics
  - Conversion rates by product
  - A/B test results
  - Revenue attribution
  - Recommendation quality scores

**State Management:**
- WebSocket for real-time conversation updates
- Redux Toolkit for conversation state
- React Query for API data fetching
- Optimistic UI updates for message sending

---

## Config Hot-Reload Strategy

### Overview

When tools/integrations are completed or config changes are pushed, services must reload configurations WITHOUT restarting and WITHOUT disrupting active conversations.

### Hot-Reload Trigger

**Event-Driven Reload:**
```
Developer closes GitHub issue (#156: "Implement initiate_refund tool")
  ↓
GitHub webhook → Automation Engine
  ↓
Automation Engine publishes to Kafka:
Topic: config_events
{
  "event_type": "config_updated",
  "config_id": "uuid",
  "organization_id": "uuid",
  "updated_by": "github_issue_closed_webhook",
  "changes": ["tool_attached:initiate_refund"],
  "hot_reload_required": true,
  "timestamp": "2025-10-20T10:00:00Z"
}
  ↓
Agent Orchestration Service & Voice Agent Service (Kafka consumers) receive event
```

### Active Conversation Handling (CRITICAL)

**Strategy: Version Pinning + Graceful Migration**

#### For In-Flight Conversations:
1. **Continue with Current Config Version:**
   - Active conversations (mid-flow) continue using config version they started with
   - Conversation state stores `config_version: "v3"` in checkpoint
   - No mid-conversation config changes (prevents tool disappearing/appearing unexpectedly)

2. **Config Version Tracking:**
```python
# Stored in conversation checkpoint
{
  "thread_id": "uuid",
  "config_id": "uuid",
  "config_version": "v3",  # Locked at conversation start
  "conversation_state": {...},
  "created_at": "2025-10-20T10:00:00Z"
}
```

#### For New Conversations:
1. **Use Latest Config Version:**
   - New conversations (started AFTER hot-reload event) use config version v4
   - `config_version: "v4"` stamped in checkpoint at conversation creation

2. **Config Version Lookup:**
```python
# On conversation start
if new_conversation:
    config_version = get_latest_config_version(config_id)  # Returns "v4"
else:
    config_version = load_from_checkpoint(thread_id).config_version  # Returns "v3"
```

### Implementation Details

**Service-Level Hot-Reload Process:**

1. **Agent Orchestration Service receives `config_updated` event**

2. **Background Config Fetch:**
   - Call Configuration Management Service: `GET /api/v1/configs/{config_id}`
   - Download new YAML config (v4)
   - Parse and validate config schema
   - Load new tools into tool registry

3. **Version Registry Update:**
```python
# In-memory version registry
config_versions = {
    "uuid": {
        "v3": {...},  # Old config still in memory for active conversations
        "v4": {...}   # New config loaded
    }
}
```

4. **Active Conversation Check:**
   - Query PostgreSQL: `SELECT COUNT(*) FROM conversations WHERE config_id = 'uuid' AND status = 'active'`
   - If active conversations exist using v3:
     - Keep v3 in memory (DO NOT unload)
     - Log: "Config v3 retained for 12 active conversations"

5. **Garbage Collection:**
   - Monitor conversation completion events
   - When last conversation using v3 completes:
     - Wait 5 minutes (grace period)
     - Unload v3 from memory
     - Log: "Config v3 unloaded - no active conversations"

### Breaking Config Changes

**Non-Breaking Changes (Auto Hot-Reload):**
- Tool added (e.g., `initiate_refund`)
- Integration added
- System prompt updated
- Escalation rule tweaked

**Breaking Changes (Require Manual Intervention):**
- Tool removed (active conversations may be calling it)
- Required PII field removed (violates schema)
- Conversation flow restructured (state incompatible)

**Breaking Change Detection:**
```yaml
# In config YAML metadata
metadata:
  version: "v4"
  breaking_change: true  # Platform Engineer sets this manually
  migration_required: true
  migration_script: "migrate_v3_to_v4.py"
```

**Breaking Change Workflow:**
1. Platform Engineer marks `breaking_change: true` in new config
2. Hot-reload event includes `breaking_change: true`
3. Services receive event but DO NOT auto-reload
4. Platform Engineer dashboard shows alert: "Manual migration required for config_id={uuid}"
5. Platform Engineer:
   - Drains active conversations (soft block new conversations using v3)
   - Runs migration script to upgrade checkpoints to v4 schema
   - Manually triggers reload: `POST /api/v1/orchestration/reload-config/{config_id}`

### Rollback Strategy

**If Hot-Reload Fails (>10% error rate):**

1. **Auto-Rollback Trigger:**
```
Hot-reload event processed → 15% of new conversations fail with errors
  ↓
Monitoring Engine detects spike in conversation_failed events
  ↓
Auto-rollback triggered within 60 seconds
```

2. **Rollback Process:**
   - Publish `config_rollback` event to Kafka
   - Services revert to previous config version (v3)
   - New conversations use v3 again
   - Alert Platform Engineer: "Config v4 rolled back due to high error rate"

3. **Manual Investigation:**
   - Platform Engineer reviews error logs
   - Identifies root cause (e.g., tool syntax error in v4)
   - Fixes config offline
   - Re-deploys with fix validation

### Monitoring & Alerts

**Metrics to Track:**
- `config_reload_success_rate` (target: >99%)
- `active_conversations_per_config_version` (for GC decisions)
- `config_reload_latency` (target: <5s)
- `conversation_error_rate_post_reload` (auto-rollback threshold: >10%)

**Alerts:**
- Hot-reload failed for config_id={uuid}
- Breaking change detected, manual intervention required
- Config version v3 retained for >24 hours (possible memory leak)
- Rollback triggered for config_id={uuid}

---

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Support Agent**
   - Role: Handles escalated conversations
   - Access: Assigned conversations, escalation queue
   - Permissions: read:escalated_conversations, write:messages, resolve:tickets
   - Workflows: Receives escalation, reviews context, resolves issue, collects feedback

2. **Support Manager**
   - Role: Monitors agent performance, manages escalations
   - Access: All conversations, analytics
   - Permissions: read:all_conversations, reassign:escalations, admin:agents
   - Workflows: Monitors queues, reassigns complex cases, reviews performance metrics

3. **Platform Engineer**
   - Role: Monitors orchestration health, manages configs
   - Access: All conversations (read-only), config management
   - Permissions: admin:orchestration, debug:conversations, manage:configs
   - Workflows: Investigates failures, optimizes performance, deploys config updates

**AI Agents:**

1. **LangGraph Agent (Primary)**
   - Responsibility: Conducts conversations, invokes tools, manages state
   - Tools: Dynamic (loaded from YAML config)
   - Autonomy: Fully autonomous within config constraints
   - Escalation: Human handoff triggered by config rules (sentiment, complexity, user request)

2. **Memory Management Agent**
   - Responsibility: Compresses context, manages checkpoints, retrieves long-term memory
   - Tools: Token counters, summarizers, Pinecone retrieval
   - Autonomy: Fully autonomous
   - Escalation: Alerts on checkpoint failures

3. **PII Collection Agent**
   - Responsibility: Detects and extracts PII, validates formats, encrypts storage
   - Tools: NER models, regex patterns, encryption libraries
   - Autonomy: Fully autonomous
   - Escalation: None (runs in background)

4. **Cross-Sell Agent**
   - Responsibility: Identifies opportunities, generates recommendations, tracks acceptance
   - Tools: Recommendation engines, product catalogs, CRM data
   - Autonomy: Suggests only (user approval required)
   - Escalation: None

**Approval Workflows:**
1. Conversation Start → Auto-approved
2. Tool Execution → Auto-executed (config-defined tools)
3. Human Escalation → Auto-routed to available agent
4. Cross-Sell Recommendation → User acceptance required
5. Survey Sending → Auto-sent at conversation end (if config enabled)

---

## 9. Voice Agent Service

#### Objectives
- **Primary Purpose**: Real-time voice conversation handling using LiveKit infrastructure with sub-500ms latency
- **Business Value**: Enables voice automation for phone support/sales, reduces call costs from $13/call to $2-3/call
- **Scope Boundaries**:
  - **Does**: Handle voice calls, STT/TTS processing, LiveKit session management, SIP integration, voice-specific workflows
  - **Does Not**: Generate configs (Automation Engine), implement business logic (Agent Orchestration does via YAML)

#### Requirements

**Functional Requirements:**
1. LiveKit-based voice session management
2. STT integration (Deepgram Nova-3) with streaming
3. TTS integration (ElevenLabs Flash v2.5) with low latency
4. LangGraph workflow for voice (same as chatbot, YAML-driven)
5. SIP integration for phone calls (Twilio/Telnyx)
6. DTMF support for IVR navigation
7. Hot transfer to human agents
8. Call recording and transcription
9. Turn detection optimization (<300ms)

**Non-Functional Requirements:**
- End-to-end latency: <500ms P95
- Concurrent calls: 10-25 per worker pod
- STT accuracy: >90% for clear audio
- TTS naturalness: >4.0/5.0 rating
- Uptime: 99.9%

**Dependencies:**
- Automation Engine (YAML configs)
- Agent Orchestration Service (business logic)
- Configuration Management (voice-specific configs)
- External: LiveKit Cloud/Self-hosted, Deepgram, ElevenLabs, Twilio/Telnyx

**Data Storage:**
- PostgreSQL: Call metadata, transcripts, analytics
- S3: Call recordings (encrypted)
- Redis: Active session state

#### Features

**Must-Have:**
1. ✅ LiveKit distributed mesh architecture
2. ✅ Deepgram STT streaming
3. ✅ ElevenLabs TTS with dual streaming
4. ✅ YAML-driven voice workflows
5. ✅ SIP integration for PSTN calls
6. ✅ Human agent hot transfer
7. ✅ Call recording and storage
8. ✅ Turn detection optimization

**Nice-to-Have:**
9. 🔄 Noise cancellation (Krisp AI)
10. 🔄 Emotion detection from voice
11. 🔄 Multi-language support
12. 🔄 Voice biometrics authentication

#### API Specification

**1. Initiate Voice Call (Outbound)**
```http
POST /api/v1/voice/calls/initiate
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "phone_number": "+15551234567",
  "caller_id": "+15559876543",
  "context": {
    "customer_id": "C12345",
    "call_purpose": "followup",
    "campaign_id": "uuid"
  }
}

Response (202 Accepted):
{
  "call_id": "uuid",
  "status": "initiating",
  "sip_session_id": "uuid",
  "estimated_connect_time": "5 seconds"
}

Event Published to Kafka:
Topic: voice_events
{
  "event_type": "call_initiated",
  "call_id": "uuid",
  "phone_number": "+15551234567",
  "timestamp": "2025-10-11T11:00:00Z"
}
```

**2. Get Call Status**
```http
GET /api/v1/voice/calls/{call_id}
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "call_id": "uuid",
  "status": "in_progress",
  "phone_number": "+15551234567",
  "direction": "outbound",
  "started_at": "2025-10-11T11:00:05Z",
  "duration_seconds": 145,
  "transcript": [
    {
      "speaker": "agent",
      "text": "Hello! This is Sarah from Acme Corp. Is this John?",
      "timestamp": "2025-10-11T11:00:07Z",
      "confidence": 0.98
    },
    {
      "speaker": "user",
      "text": "Yes, this is John.",
      "timestamp": "2025-10-11T11:00:10Z",
      "confidence": 0.95
    },
    ...
  ],
  "tools_executed": [
    {"tool": "fetch_account_info", "timestamp": "2025-10-11T11:00:12Z"}
  ],
  "sentiment_score": 0.72,
  "recording_url": "https://storage.workflow.com/recordings/uuid.mp3",
  "livekit_room_id": "room_xyz",
  "participant_count": 2
}
```

**3. Transfer to Human Agent**
```http
POST /api/v1/voice/calls/{call_id}/transfer
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "agent_id": "uuid",
  "transfer_type": "hot",
  "reason": "complex_technical_issue",
  "summary": "Customer needs help with API integration issue"
}

Response (200 OK):
{
  "call_id": "uuid",
  "transfer_id": "uuid",
  "status": "transferring",
  "target_agent": {
    "agent_id": "uuid",
    "name": "Technical Support - Mike",
    "phone_number": "+15551112222",
    "estimated_connect_time": "10 seconds"
  },
  "call_summary": {
    "transcript": "...",
    "pii_collected": {...},
    "tools_used": [...]
  }
}

Event Published to Kafka:
Topic: voice_events
{
  "event_type": "call_transferred",
  "call_id": "uuid",
  "transfer_type": "hot",
  "target_agent_id": "uuid",
  "timestamp": "2025-10-11T11:02:30Z"
}
```

**4. WebSocket - Live Transcription**
```
wss://voice.workflow.com/calls/{call_id}/transcript
Authorization: Bearer {jwt_token}

Server → Client Events:
{
  "event": "transcript_interim",
  "speaker": "user",
  "text": "I'm having trouble with...",
  "is_final": false,
  "timestamp": "2025-10-11T11:01:45Z"
}

{
  "event": "transcript_final",
  "speaker": "user",
  "text": "I'm having trouble with my API integration.",
  "confidence": 0.94,
  "timestamp": "2025-10-11T11:01:48Z"
}

{
  "event": "agent_response",
  "speaker": "agent",
  "text": "I understand you're having API integration issues. Let me pull up your account details.",
  "tool_calls": [
    {"tool": "fetch_account_info", "status": "executing"}
  ],
  "timestamp": "2025-10-11T11:01:50Z"
}

{
  "event": "sentiment_update",
  "sentiment_score": 0.45,
  "emotion": "frustrated",
  "escalation_suggested": true,
  "timestamp": "2025-10-11T11:01:51Z"
}
```

**5. End Call**
```http
POST /api/v1/voice/calls/{call_id}/end
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "reason": "completed",
  "resolution_status": "resolved",
  "followup_required": false
}

Response (200 OK):
{
  "call_id": "uuid",
  "status": "ended",
  "ended_at": "2025-10-11T11:05:00Z",
  "duration_seconds": 295,
  "summary": {
    "transcript_url": "https://storage.workflow.com/transcripts/uuid.txt",
    "recording_url": "https://storage.workflow.com/recordings/uuid.mp3",
    "pii_collected": {
      "phone": "+15551234567",
      "account_id": "A78945"
    },
    "tools_executed": ["fetch_account_info", "create_support_ticket"],
    "sentiment_avg": 0.68,
    "resolution_status": "resolved",
    "csat_score": null
  },
  "analytics": {
    "stt_latency_avg_ms": 350,
    "tts_latency_avg_ms": 75,
    "llm_latency_avg_ms": 1200,
    "total_latency_p95_ms": 480
  }
}

Event Published to Kafka:
Topic: voice_events
{
  "event_type": "call_ended",
  "call_id": "uuid",
  "duration_seconds": 295,
  "resolution_status": "resolved",
  "timestamp": "2025-10-11T11:05:00Z"
}
```

**6. Get Call Analytics**
```http
GET /api/v1/voice/analytics?start_date=2025-10-01&end_date=2025-10-11
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "period": {
    "start": "2025-10-01",
    "end": "2025-10-11"
  },
  "total_calls": 1547,
  "call_breakdown": {
    "inbound": 892,
    "outbound": 655
  },
  "avg_call_duration_seconds": 287,
  "completion_rate": 0.94,
  "transfer_rate": 0.12,
  "resolution_rate": 0.88,
  "performance_metrics": {
    "avg_latency_ms": 425,
    "stt_accuracy": 0.92,
    "tts_naturalness": 4.3
  },
  "cost_analysis": {
    "total_cost": 4641.00,
    "cost_per_call": 3.00,
    "breakdown": {
      "stt": 1200.00,
      "tts": 980.00,
      "llm": 1850.00,
      "telephony": 611.00
    }
  },
  "top_escalation_reasons": [
    {"reason": "complex_technical_issue", "count": 87},
    {"reason": "user_frustrated", "count": 52},
    {"reason": "billing_dispute", "count": 43}
  ]
}
```

**Rate Limiting:**
- 1000 concurrent calls per tenant
- 100 outbound calls per hour per tenant (configurable)
- 1000 API requests per minute per tenant

#### Frontend Components

**1. Voice Call Dashboard**
- Component: `VoiceCallDashboard.tsx`
- Features:
  - Active calls grid (real-time status)
  - Call controls (mute, hold, transfer, end)
  - Live transcription viewer
  - Sentiment indicators
  - Recording playback

**2. Live Transcription Panel**
- Component: `LiveTranscriptionPanel.tsx`
- Features:
  - Real-time transcript streaming
  - Speaker diarization visualization
  - Confidence scores
  - Keyword highlighting
  - Export options

**3. Call Transfer Interface**
- Component: `CallTransferInterface.tsx`
- Features:
  - Available agent directory
  - Transfer type selector (hot, warm, cold)
  - Call summary auto-population
  - Conference call option
  - Transfer history

**4. Voice Analytics Dashboard**
- Component: `VoiceAnalyticsDashboard.tsx`
- Features:
  - Call volume charts (hourly, daily, weekly)
  - Performance metrics (latency, accuracy)
  - Cost analysis with trends
  - Escalation pattern analysis
  - Quality scorecards

**State Management:**
- WebSocket for real-time call updates
- Redux Toolkit for call state management
- React Query for analytics data
- Audio player components for recording playback

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Phone Support Agent**
   - Role: Handles transferred voice calls
   - Access: Assigned calls, transfer queue
   - Permissions: receive:transfers, read:call_context, end:calls
   - Workflows: Receives transfer, reviews context, resolves issue

2. **Voice Operations Manager**
   - Role: Monitors voice infrastructure, manages quality
   - Access: All calls, analytics, infrastructure metrics
   - Permissions: admin:voice, monitor:calls, manage:agents
   - Workflows: Monitors performance, investigates quality issues, optimizes configs

**AI Agents:**

1. **Voice Agent (LangGraph-based)**
   - Responsibility: Conducts voice conversations, same logic as chatbot
   - Tools: YAML-configured tools (same as Agent Orchestration)
   - Autonomy: Fully autonomous within config constraints
   - Escalation: Hot transfer triggered by config rules

2. **Turn Detection Agent**
   - Responsibility: Detects speaker turns, minimizes latency
   - Tools: VAD models, audio processing
   - Autonomy: Fully autonomous
   - Escalation: None

3. **Audio Quality Agent**
   - Responsibility: Monitors audio quality, triggers noise cancellation
   - Tools: Audio analyzers, Krisp AI, quality metrics
   - Autonomy: Fully autonomous
   - Escalation: Alerts operations on persistent quality issues

**Approval Workflows:**
1. Outbound Calls → Auto-approved within quota limits
2. Human Transfer → Auto-routed to available agent
3. Call Recording → Auto-enabled (GDPR/compliance consent pre-obtained)
4. Call Analytics → Auto-generated

---

## Voice Infrastructure Architecture (SIP Provider Details)

### SIP Provider: Twilio Elastic SIP Trunking (Primary)

**Why Twilio:**
- 99.999% uptime SLA (vs. Telnyx 99.99%)
- Global PSTN coverage (150+ countries)
- Mature LiveKit integration libraries
- Enterprise support (response < 1 hour)

**Cost Structure:**
- SIP trunk capacity: $2/month per channel
- Inbound calls: $0.0085/minute (US)
- Outbound calls: $0.0100/minute (US)
- Phone numbers: $1/month per number
- Estimated monthly cost (1000 concurrent calls): $2,000 + $510/hr usage

### Configuration

**SIP Trunk Provisioning:**
```
Trunk Name: workflow-prod-trunk-1
SIP URI: sip:workflow.pstn.twilio.com
Capacity: 1000 concurrent channels
Authentication: IP ACL (LiveKit SIP bridge IPs)
Codec Priority: PCMU (G.711), Opus
```

**Phone Number Pool:**
- **Auto-Provisioning**: 100 numbers per tenant (configurable)
- **Number Types**: Local (US), Toll-Free (800/888/etc.), International
- **Assignment Strategy**: Geographic (match tenant headquarters location)
- **Example**: Tenant "Acme Corp" (HQ: San Francisco) → +1 (415) xxx-xxxx

**Inbound SIP URI Routing:**
```
PSTN Call → Twilio SIP Trunk → LiveKit SIP Bridge
  ↓
SIP INVITE with header: X-Tenant-Slug: acme-corp
  ↓
LiveKit SIP bridge extracts tenant_slug
  ↓
Configuration Management Service: GET /api/v1/tenants/acme-corp/config_id
  ↓
Returns: config_id = "uuid"
  ↓
Voice Agent Service initializes session with config_id
  ↓
STT → Agent Orchestration → TTS → Caller (PSTN)
```

**Outbound Call Flow:**
```
Voice Agent Service: POST /api/v1/voice/calls/initiate
  ↓
LiveKit creates SIP session
  ↓
LiveKit SIP bridge → Twilio SIP Trunk
  ↓
Twilio routes to PSTN (caller ID: tenant's phone number)
  ↓
Call connects to recipient +15551234567
  ↓
Voice conversation begins (STT → Agent → TTS)
```

### Failover Strategy: Telnyx (Secondary)

**Automatic Failover Conditions:**
- Twilio SIP trunk unavailable (>5 minutes)
- Error rate >20% on Twilio
- Manual failover trigger by Platform Engineer

**Failover Process:**
1. Monitoring Engine detects Twilio degradation
2. Publishes `sip_provider_failover` event to Kafka
3. Voice Agent Service receives event
4. New calls routed to Telnyx SIP URI: `sip:workflow.sip.telnyx.com`
5. Existing calls continue on Twilio (no mid-call transfer)
6. Alert: "SIP provider failed over to Telnyx"

**Telnyx Configuration:**
```
Trunk Name: workflow-backup-trunk
Capacity: 500 concurrent channels (50% of primary)
Cost: $0.0095/minute (slightly cheaper, lower capacity)
Geographic: US-only (no international support)
```

### International Calling Support

**Supported Countries (Tier 1 - Low Cost):**
- US, Canada: $0.0100/min
- UK, Germany, France: $0.0150/min
- Australia: $0.0180/min

**Supported Countries (Tier 2 - Medium Cost):**
- India: $0.0250/min
- Mexico: $0.0220/min
- Brazil: $0.0300/min

**Unsupported Countries:**
- Cuba, North Korea, Syria (OFAC sanctions)
- Countries with poor PSTN quality (fallback to chat only)

**Compliance:**
- **GDPR Call Recording**: Explicit consent banner ("This call will be recorded") before STT starts
- **TCPA Compliance**: Outbound calls only to opted-in numbers, respect Do-Not-Call lists
- **PCI-DSS**: Credit card numbers detected in voice → masked in transcript, not stored

### Phone Number Management

**Provisioning API:**
```http
POST /api/v1/voice/numbers/provision
Authorization: Bearer {platform_admin_jwt}
Content-Type: application/json

Request Body:
{
  "tenant_id": "uuid",
  "number_type": "local",  // local | toll_free | international
  "area_code": "415",  // Optional, for local numbers
  "quantity": 10
}

Response (201 Created):
{
  "numbers": [
    {
      "phone_number": "+14155551001",
      "number_type": "local",
      "tenant_id": "uuid",
      "provisioned_at": "2025-10-20T10:00:00Z",
      "monthly_cost_usd": 1.00
    },
    ...
  ],
  "total_monthly_cost_usd": 10.00
}
```

**Number Rotation (Anti-Spam):**
- Outbound campaign calls rotate through 10+ numbers
- Prevents carrier spam flags on single number
- Auto-rotation every 500 calls

### Monitoring & SLAs

**SIP Trunk Health Metrics:**
- `sip_trunk_availability` (target: >99.99%)
- `call_connect_success_rate` (target: >95%)
- `call_quality_mos_score` (Mean Opinion Score, target: >4.0)
- `sip_latency_ms` (target: <100ms for SIP negotiation)

**Alerts:**
- SIP trunk capacity >80% (scale up warning)
- Call quality degradation (MOS < 3.5 for 5 minutes)
- Failover to Telnyx triggered
- International call to unsupported country attempted

**Cost Budgeting:**
- Daily limit per tenant: $500 (prevents runaway costs)
- Alert at 80% of daily budget
- Auto-pause outbound calls at 100% budget (emergency stop)

---

## 10. Configuration Management Service

#### Objectives
- **Primary Purpose**: Centralized configuration storage and hot-reload distribution for all microservices
- **Business Value**: Enables dynamic behavior changes without deployments, supports feature flags, ensures config consistency
- **Scope Boundaries**:
  - **Does**: Store configs in S3, watch for changes, validate configs, propagate updates via Kafka, manage feature flags
  - **Does Not**: Generate configs (Automation Engine does), implement business logic

#### Requirements

**Functional Requirements:**
1. Store YAML configs in versioned S3 buckets
2. Validate config schema before storage
3. Propagate config updates via Kafka events
4. Provide config retrieval by config_id, organization_id, or tenant_slug
5. Version management with rollback capability
6. Feature flag management per tenant

**Non-Functional Requirements:**
- Config retrieval: <50ms P95
- S3 → Kafka propagation: <2 seconds
- 99.99% uptime (critical for hot-reload)

**Dependencies:**
- Automation Engine (generates configs)
- Agent Orchestration Service (consumes configs)
- Voice Agent Service (consumes configs)
- S3 (config storage)
- Kafka (config update events)

**Data Storage:**
- S3: YAML config files (versioned, immutable)
- PostgreSQL: Config metadata, version history
- Redis: Config cache (hot configs)

#### API Specification

**1. Get Config by ID**
```http
GET /api/v1/configs/{config_id}
Authorization: Bearer {jwt_token}
X-Service-Name: agent_orchestration

Response (200 OK):
{
  "config_id": "uuid",
  "organization_id": "uuid",
  "version": 4,
  "yaml_content": "...",  // Full YAML config
  "metadata": {
    "created_at": "2025-10-17T15:00:00Z",
    "updated_at": "2025-10-20T10:00:00Z",
    "status": "active",
    "breaking_change": false
  },
  "s3_url": "s3://workflow-configs/org-uuid/config-uuid/v4.yaml"
}
```

**2. Get Config by Tenant Slug**
```http
GET /api/v1/tenants/{tenant_slug}/config
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "config_id": "uuid",
  "tenant_slug": "acme-corp",
  "organization_id": "uuid",
  "version": 4,
  "yaml_content": "...",
  "cached": true
}
```

**3. Get Latest Config for Organization**
```http
GET /api/v1/configs/latest
Authorization: Bearer {jwt_token}
Query Parameters:
- organization_id: uuid

Response (200 OK):
{
  "config_id": "uuid",
  "organization_id": "uuid",
  "version": 4,
  "yaml_content": "...",
  "status": "active"
}
```

**4. Validate Config**
```http
POST /api/v1/configs/validate
Authorization: Bearer {platform_admin_jwt}
Content-Type: application/json

Request Body:
{
  "yaml_content": "...",
  "config_id": "uuid"  // Optional, for update validation
}

Response (200 OK):
{
  "valid": true,
  "errors": [],
  "warnings": ["Tool 'initiate_refund' not yet implemented"],
  "schema_version": "1.0",
  "breaking_change_detected": false
}

Response (400 Bad Request - Validation Failed):
{
  "valid": false,
  "errors": [
    {
      "field": "system_prompt",
      "message": "Required field missing",
      "severity": "error"
    },
    {
      "field": "tools[0].name",
      "message": "Tool name must be snake_case",
      "severity": "error"
    }
  ]
}
```

**5. Get Config Versions**
```http
GET /api/v1/configs/{config_id}/versions
Authorization: Bearer {jwt_token}

Response (200 OK):
{
  "config_id": "uuid",
  "versions": [
    {
      "version": 4,
      "created_at": "2025-10-20T10:00:00Z",
      "created_by": "github_webhook",
      "status": "active",
      "breaking_change": false,
      "changes": ["tool_attached:initiate_refund"]
    },
    {
      "version": 3,
      "created_at": "2025-10-17T15:00:00Z",
      "created_by": "automation_engine",
      "status": "archived",
      "breaking_change": false,
      "changes": ["initial_generation"]
    }
  ]
}
```

**6. Rollback to Previous Version**
```http
POST /api/v1/configs/{config_id}/rollback
Authorization: Bearer {platform_admin_jwt}
Content-Type: application/json

Request Body:
{
  "target_version": 3,
  "reason": "Version 4 causing high error rate"
}

Response (200 OK):
{
  "config_id": "uuid",
  "rolled_back_from": 4,
  "rolled_back_to": 3,
  "active_version": 3,
  "kafka_event_published": true
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "config_rollback",
  "config_id": "uuid",
  "from_version": 4,
  "to_version": 3,
  "reason": "high_error_rate",
  "timestamp": "2025-10-20T11:00:00Z"
}
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Platform Engineer**
   - Role: Manages configs, validates schemas, performs rollbacks
   - Access: All configs, version history
   - Permissions: admin:configs, rollback:configs, validate:configs
   - Workflows: Reviews config updates, validates breaking changes, performs emergency rollbacks

**AI Agents:**

1. **Config Watcher Agent**
   - Responsibility: Monitors S3 for config changes, publishes Kafka events
   - Tools: S3 event notifications, Kafka producers
   - Autonomy: Fully autonomous
   - Escalation: Alerts on S3 bucket access failures

2. **Schema Validator Agent**
   - Responsibility: Validates YAML configs against JSON schema
   - Tools: JSON Schema validators, YAML parsers
   - Autonomy: Fully autonomous
   - Escalation: Blocks invalid configs from being saved

---

## 11. Monitoring Engine Service

#### Objectives
- **Primary Purpose**: Proactive monitoring of all workflows, LLM quality, integration health, and system uptime
- **Business Value**: Prevents downtime, detects quality degradation, enables rapid incident response
- **Scope**: Event tracking, incident creation, alerting, RCA generation, SLA monitoring

**Key APIs:**
- POST /api/v1/monitoring/events (log events)
- GET /api/v1/monitoring/health (service health)
- POST /api/v1/monitoring/incidents (create incident)
- GET /api/v1/monitoring/incidents/{id} (incident details)

**Stakeholders:** Platform Engineers, SREs, Client Success Managers

---

## 12. Analytics Service

#### Objectives
- **Primary Purpose**: Real-time and batch analytics for conversations, KPIs, business metrics, and A/B testing
- **Business Value**: Data-driven optimization, client reporting, revenue attribution
- **Scope**: Conversation analytics, KPI calculation, A/B test analysis, custom dashboards

**Key APIs:**
- POST /api/v1/analytics/events (track events)
- GET /api/v1/analytics/kpis (KPI dashboard)
- POST /api/v1/analytics/experiments (create A/B test)
- GET /api/v1/analytics/reports (generate reports)

**Stakeholders:** Data Analysts, Product Managers, Client Business Owners

---

## 13. Customer Success Service

#### Objectives
- **Primary Purpose**: Automated customer success workflows with AI-driven insights and proactive engagement
- **Business Value**: Reduces churn, identifies expansion opportunities, automates QBRs
- **Scope**: KPI tracking, insight generation, meeting automation, playbook suggestions

**Key APIs:**
- GET /api/v1/customer-success/metrics/{client_id} (client metrics)
- POST /api/v1/customer-success/insights (generate insights)
- POST /api/v1/customer-success/meetings (schedule QBR)
- GET /api/v1/customer-success/playbooks (recommended actions)

**Stakeholders:** Customer Success Managers, Account Executives

---

## 14. Support Engine Service

#### Objectives
- **Primary Purpose**: AI-powered internal support for client issues with escalation workflows
- **Business Value**: Automates 70% of support queries, enables 24/7 coverage
- **Scope**: Email-based support AI, ticket management, support documentation generation

**Key APIs:**
- POST /api/v1/support/tickets (create ticket)
- GET /api/v1/support/tickets/{id} (ticket details)
- POST /api/v1/support/tickets/{id}/resolve (AI resolution)
- POST /api/v1/support/docs/generate (generate support docs)

**Stakeholders:** Support Engineers, Support Managers, Clients

---

## 15. CRM Integration Service

#### Objectives
- **Primary Purpose**: Bidirectional sync with CRMs (Salesforce, HubSpot) for lead/customer data
- **Business Value**: Unified customer view, automated CRM updates, closed-loop attribution
- **Scope**: CRM sync, webhook handlers, field mapping, conflict resolution

**Key APIs:**
- POST /api/v1/crm/sync (trigger sync)
- GET /api/v1/crm/mappings/{client_id} (field mappings)
- POST /api/v1/crm/webhooks (CRM webhook receiver)
- GET /api/v1/crm/conflicts (conflict resolution)

**Stakeholders:** Sales Ops, Marketing Ops, CRM Admins

---

## Inter-Service Communication Patterns

### Event-Driven (Primary)

**Kafka Topics:**
- `auth_events`: User signed up, email verified, user logged in, password reset, assisted account created, assisted account claimed, claim link sent, claim link resent, assisted account expired, assisted account access granted, account ownership transferred
- `org_events`: Organization created, member invited, member joined, member removed, role updated
- `agent_events`: Agent registered, client assigned to agent, handoff initiated, handoff accepted, handoff rejected, specialist invited, specialist joined, specialist handoff back, agent status updated, agent availability changed, workload redistributed
- `collaboration_events`: Help requested, agent joined session, canvas edited, collaboration ended
- `client_events`: Research completed, NDA signed, pilot agreed
- `demo_events`: Demo generated, approved, failed
- `prd_events`: PRD created, approved, updated, feedback received
- `config_events`: Config generated, deployed, hot-reloaded
- `conversation_events`: Started, escalated, completed
- `voice_events`: Call initiated, transferred, ended
- `analytics_events`: KPIs calculated, experiments completed
- `monitoring_events`: Incidents created, resolved
- `escalation_events`: Human handoff triggered
- `outreach_events`: Email sent, email opened, email clicked, manual ticket created
- `research_events`: Research started, research completed, research failed

---

## Event Schema Registry

Complete mapping of Kafka topics to event types, schemas, producers, and consumers.

### auth_events

**Producers:** Organization Management & Authentication Service
**Consumers:** Monitoring Engine, Analytics Service, Human Agent Management Service, Outbound Communication Service

**Event Types:**

1. **user_signed_up**
```json
{
  "event_type": "user_signed_up",
  "user_id": "uuid",
  "organization_id": "uuid",
  "email": "user@example.com",
  "user_type": "client",
  "timestamp": "2025-10-06T10:00:00Z"
}
```

2. **assisted_account_created**
```json
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
```
**Consumer Actions:**
- Human Agent Management: Auto-assign client to creating agent
- Outbound Communication: Send claim link email

3. **assisted_account_claimed**
```json
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
**Consumer Actions:**
- Monitoring Engine: Track conversion metrics
- Analytics: Update funnel statistics

---

### agent_events

**Producers:** Human Agent Management Service
**Consumers:** Analytics Service, Monitoring Engine, Organization Management Service

**Event Types:**

1. **client_assigned_to_agent**
```json
{
  "event_type": "client_assigned_to_agent",
  "client_id": "uuid",
  "organization_id": "uuid",
  "agent_id": "uuid",
  "agent_name": "Sam Peterson",
  "agent_role": "sales_agent",
  "assignment_type": "auto_on_assisted_signup",
  "lifecycle_stage": "sales",
  "timestamp": "2025-10-05T10:30:00Z"
}
```
**Consumer Actions:**
- Analytics: Track agent workload
- Monitoring: Alert if agent capacity exceeded

2. **handoff_initiated**
```json
{
  "event_type": "handoff_initiated",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "from_agent_id": "uuid",
  "from_role": "sales_agent",
  "to_role": "onboarding_specialist",
  "lifecycle_stage_from": "sales",
  "lifecycle_stage_to": "onboarding",
  "context_notes": "Client signed proposal, needs technical onboarding for e-commerce integration",
  "timestamp": "2025-10-15T14:00:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Queue handoff for acceptance by onboarding agents
- Analytics: Track handoff latency

3. **handoff_accepted**
```json
{
  "event_type": "handoff_accepted",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "accepted_by_agent_id": "uuid",
  "accepted_by_agent_name": "Rahul Kumar",
  "accepted_at": "2025-10-15T15:00:00Z",
  "timestamp": "2025-10-15T15:00:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Update client assignment, mark handoff complete
- Outbound Communication: Send handoff confirmation email to client

4. **handoff_rejected**
```json
{
  "event_type": "handoff_rejected",
  "handoff_id": "uuid",
  "client_id": "uuid",
  "rejected_by_agent_id": "uuid",
  "reason": "at_capacity",
  "reassignment_queued": true,
  "timestamp": "2025-10-15T15:00:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Auto-reassign to next available agent

5. **specialist_invited**
```json
{
  "event_type": "specialist_invited",
  "invitation_id": "uuid",
  "client_id": "uuid",
  "invited_by_agent_id": "uuid",
  "specialist_role": "sales_specialist",
  "invitation_reason": "upsell_voice_addon",
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Queue invitation for specialist acceptance
- Analytics: Track upsell opportunities

---

### prd_events

**Producers:** PRD Builder Engine Service
**Consumers:** Automation Engine, Analytics Service, Monitoring Engine

**Event Types:**

1. **prd_created**
```json
{
  "event_type": "prd_created",
  "prd_id": "uuid",
  "organization_id": "uuid",
  "client_id": "uuid",
  "prd_title": "E-commerce Payment Automation",
  "status": "draft",
  "timestamp": "2025-10-16T10:00:00Z"
}
```
**Consumer Actions:**
- None (informational)

2. **prd_approved**
```json
{
  "event_type": "prd_approved",
  "prd_id": "uuid",
  "organization_id": "uuid",
  "approved_by_user_id": "uuid",
  "timestamp": "2025-10-17T14:00:00Z"
}
```
**Consumer Actions:**
- **Automation Engine: Trigger YAML config generation** (CRITICAL FLOW)
- Analytics: Track PRD approval rate

---

### config_events

**Producers:** Automation Engine, Configuration Management Service
**Consumers:** Agent Orchestration Service, Voice Agent Service, Monitoring Engine

**Event Types:**

1. **config_generated**
```json
{
  "event_type": "config_generated",
  "config_id": "uuid",
  "organization_id": "uuid",
  "prd_id": "uuid",
  "status": "pending_deployment",
  "missing_tools": ["initiate_refund", "check_inventory"],
  "missing_integrations": ["shopify_api"],
  "timestamp": "2025-10-17T15:00:00Z"
}
```
**Consumer Actions:**
- Automation Engine: Create GitHub issues for missing tools/integrations
- Monitoring: Track config generation success rate

2. **config_updated**
```json
{
  "event_type": "config_updated",
  "config_id": "uuid",
  "organization_id": "uuid",
  "updated_by": "github_issue_closed_webhook",
  "changes": ["tool_attached:initiate_refund"],
  "hot_reload_required": true,
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- **Agent Orchestration: Hot-reload config for active sessions** (CRITICAL FLOW)
- **Voice Agent: Hot-reload config for new calls** (CRITICAL FLOW)

---

### outreach_events

**Producers:** Outbound Communication Service
**Consumers:** Human Agent Management Service, Analytics Service

**Event Types:**

1. **email_sent**
```json
{
  "event_type": "email_sent",
  "email_id": "uuid",
  "recipient_email": "client@example.com",
  "template_id": "research_completed_outreach",
  "sent_at": "2025-10-06T10:30:00Z",
  "timestamp": "2025-10-06T10:30:00Z"
}
```
**Consumer Actions:**
- Analytics: Track email delivery metrics

2. **manual_outreach_ticket_created**
```json
{
  "event_type": "manual_outreach_ticket_created",
  "ticket_id": "uuid",
  "client_id": "uuid",
  "assigned_agent_id": "uuid",
  "reason": "research_completed_no_auto_email",
  "timestamp": "2025-10-06T10:30:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Add ticket to agent's queue

---

### Synchronous REST (Secondary)

**Use Cases:**
- User-facing operations (demo generation, proposal creation)
- External integrations (CRM sync, e-signature)
- Admin operations (config validation, incident creation)

### gRPC (Internal High-Performance)

**Use Cases:**
- Agent-to-tool communication
- Service mesh data plane
- High-frequency metric collection

---

## Deployment & Infrastructure Considerations

### Kubernetes Architecture

**Namespace Strategy:**
- `core-services`: Research, Demo, NDA, Pricing, Proposal, PRD, Automation
- `runtime-services`: Agent Orchestration, Voice, Configuration Management
- `support-services`: Monitoring, Analytics, Customer Success, Support, CRM
- `infrastructure`: Kafka, Redis, PostgreSQL, Vector DBs
- `tenants-staging`: Tenant-specific staging environments
- `tenants-prod`: Tenant-specific production (enterprise tier)

### Scaling Strategy

**Horizontal Pod Autoscaling (HPA):**
- Agent Orchestration: CPU 70%, custom metric (active conversations)
- Voice Agent: GPU utilization 60%, queue depth
- API Gateway (Kong): Request rate, P95 latency
- Analytics: Kafka lag, processing queue depth

**Vertical Pod Autoscaling (VPA):**
- LLM Gateway: Memory-intensive (model loading)
- RAG Pipeline: Memory for embedding caching

**Cluster Autoscaling (Karpenter):**
- GPU nodes for voice workers (T4 instances)
- Spot instances for batch analytics
- Reserved instances for core services

### Database Architecture

**PostgreSQL (Supabase) - Shared Core:**
- Authentication and authorization (auth.users)
- Billing and subscriptions
- Cross-service metadata

**PostgreSQL - Per Service:**
- Agent Orchestration: Conversations, checkpoints
- Voice: Call metadata, transcripts
- Analytics: Aggregated metrics, experiments
- Monitoring: Incidents, alerts

**Citus Sharding (>10K tenants):**
- Shard key: tenant_id
- Schema-per-tenant for compliance isolation

### Caching Strategy

**L1 (In-Memory per Pod):**
- Config: YAML configs, feature flags
- Static: Prompt templates, tool schemas

**L2 (Redis Cluster):**
- Session state, rate limit counters
- LLM response cache (60min TTL)
- Hot configuration data

**L3 (CDN - Cloudflare):**
- Static assets (JS bundles, images)
- Public API responses (anonymized)

---

## Security & Compliance Considerations

### Data Protection

**Encryption:**
- At Rest: AES-256 (KMS-managed keys, tenant-specific for enterprise)
- In Transit: TLS 1.3 (mTLS for service mesh)
- PII: Separate encryption keys, automatic rotation (90 days)

**Access Control:**
- Kong API Gateway: JWT-based auth, tenant_id validation
- Linkerd Service Mesh: mTLS for inter-service communication
- PostgreSQL RLS: tenant_id filtering on every query
- S3: Bucket policies, IAM roles with least privilege

### Compliance Frameworks

**SOC 2 Type II:**
- Comprehensive audit logging (Kafka event sourcing)
- Security policies documented and enforced
- Quarterly penetration testing
- Annual third-party audit

**HIPAA (Healthcare Tenants):**
- Dedicated infrastructure (physical isolation)
- BAA with all service providers
- 6-year audit log retention
- Encrypted PHI at rest and in transit

**GDPR (EU Operations):**
- Data residency (GCP europe-west1, AWS eu-central-1)
- Right to erasure (30-day data deletion)
- Data portability (JSON export)
- Consent management for optional processing

**PCI-DSS (Payment Processing):**
- Tokenization (no card data storage)
- Network segmentation
- Quarterly vulnerability scans
- Two-factor authentication for admin access

### Incident Response

**Detection:**
- Real-time anomaly detection (Datadog Security)
- Failed auth alerts (>10 failures in 5min)
- Unusual data access (ML-based patterns)
- DDoS protection (Cloudflare WAF)

**Response Playbook:**
1. Containment (isolate affected systems, revoke credentials)
2. Forensics (preserve logs, identify attack vector)
3. Notification (72hr GDPR, 60-day HIPAA)
4. Remediation (patch vulnerabilities, update policies)
5. Post-Incident Review (RCA, preventive measures)

**Disaster Recovery:**
- Multi-region deployment (active-passive)
- Database backups every 4 hours (PITR)
- Config backups to separate region
- Quarterly DR drills
- RTO: <5min, RPO: <15min

---

## Inter-Service Communication Summary

### Event Flow Examples

**1. Client Onboarding Flow (Self-Service):**
```
User Signup (Org Management) → user_signed_up event
  ↓
Email Verification → email_verified event
  ↓
Organization Creation → organization_created event
  ↓
(Optional) Team Member Invitations → member_invited events
  ↓
Research Engine (auto-triggered) → research_completed event
  ↓
Outbound Email → email_sent OR manual_outreach_ticket_created event
  ↓
Client Feedback → feedback_received event
  ↓
Demo Generator → demo_generated event
  ↓
Sales Meeting (external) → demo_approved + pilot_agreed events
  ↓
NDA Generator → nda_generated event
  ↓
Client Signs NDA → nda_fully_signed event
  ↓
Pricing Model Generator → pricing_generated event
  ↓
Proposal Generator → proposal_generated event
  ↓
Client Signs Proposal → proposal_signed event
  ↓
PRD Builder (with collaboration support) → prd_approved event
  ↓
Automation Engine → config_generated event
  ↓
Agent Orchestration + Voice → services_ready event
  ↓
Customer Success → monitoring_active event
```

**1b. Client Onboarding Flow (Assisted Signup with Human Agent Handoffs):**
```
═══════════════════════════════════════════════════════════════════════
STAGE 1: SALES (Human Agent: Sales Agent - Sam)
═══════════════════════════════════════════════════════════════════════
Sales Agent Creates Assisted Account → assisted_account_created event
  ↓
Agent Auto-Assignment → client_assigned_to_agent event (Sam - Sales Agent)
  ↓
Claim Link Sent to Client → claim_link_sent event
  ↓
Research Engine (auto-triggered by AI) → research_completed event
  ↓
Sales Agent Prepares Demo/Data → assisted_account_access_granted event
  ↓
Demo Generator (AI-assisted) → demo_generated event
  ↓
Client Receives Claim Link → (Pending client action)
  ↓
Client Claims Account → assisted_account_claimed event
  ↓
Account Ownership Transferred → account_ownership_transferred event
  ↓
Sales Meeting (Sales Agent facilitated) → demo_approved + pilot_agreed events
  ↓
NDA Generator (AI-generated, Sales Agent reviews) → nda_generated event
  ↓
Client Signs NDA (Sales Agent follows up) → nda_fully_signed event
  ↓
Pricing Model Generator (AI-generated) → pricing_generated event
  ↓
Proposal Generator (AI-generated, Sales Agent reviews) → proposal_generated event
  ↓
Client Signs Proposal (Sales Agent closes) → proposal_signed event
  ↓
═══════════════════════════════════════════════════════════════════════
HANDOFF: Sales Agent (Sam) → Onboarding Specialist (Rahul)
═══════════════════════════════════════════════════════════════════════
Sales Agent Initiates Handoff → handoff_initiated event
  ↓  (Context: All sales docs, client prefs, technical requirements)
Onboarding Specialist Accepts → handoff_accepted event
  ↓
═══════════════════════════════════════════════════════════════════════
STAGE 2: ONBOARDING (Human Agent: Onboarding Specialist - Rahul)
Duration: 1-2 weeks | Automation: 60% | Human: 40% (supervision + tie shoelaces)
═══════════════════════════════════════════════════════════════════════
Onboarding Specialist Reviews Context → agent_assigned event
  ↓
PRD Builder (AI-driven, Human collaborates when needed) → prd_created event
  ↓  (Human uses Help button if stuck, AI handles 80% of questions)
Client Requests Help → help_requested event (Onboarding Specialist joins)
  ↓
Collaboration Session → agent_joined_session event
  ↓  (Human provides expert guidance, edits canvas)
Collaboration Ended → collaboration_ended event (AI resumes)
  ↓
PRD Approved → prd_approved event
  ↓
Automation Engine (AI-generated YAML) → config_generated event
  ↓
Onboarding Specialist Reviews Config → config_reviewed event
  ↓
Config Deployed (Human supervises) → config_deployed event
  ↓
Agent Orchestration + Voice Launch → services_ready event
  ↓
Week 1 Handholding (Human monitors AI performance daily)
  ↓  (AI Supervisor reviews quality metrics)
AI Quality Check Passed → onboarding_week1_complete event
  ↓
═══════════════════════════════════════════════════════════════════════
HANDOFF: Onboarding Specialist (Rahul) → Support + Success (Parallel)
═══════════════════════════════════════════════════════════════════════
Onboarding Specialist Initiates Dual Handoff:
  ↓
  ├─→ Support Specialist (Technical issues) → handoff_initiated event (to Support)
  │   ↓
  │   Support Specialist Accepts → handoff_accepted event
  │
  └─→ Success Manager (KPIs, adoption) → handoff_initiated event (to Success)
      ↓
      Success Manager Accepts → handoff_accepted event
  ↓
═══════════════════════════════════════════════════════════════════════
STAGE 3: ONGOING SUPPORT + SUCCESS (Dual Human Agents - Long-term)
Automation: 90% | Human: 10% (exceptions + supervision + strategy)
═══════════════════════════════════════════════════════════════════════
[SUPPORT TRACK - Support Specialist monitors AI agent health]
  │
  ├─→ AI Handles 90% of Support Tickets → conversation_completed events
  │   ↓
  ├─→ Complex Issues Escalate to Human → escalation_triggered event
  │   ↓  (Support Specialist intervenes)
  ├─→ Support Specialist Resolves → ticket_resolved event
  │   ↓
  └─→ AI Supervision (config tuning, prompt updates) → config_updated events

[SUCCESS TRACK - Success Manager drives adoption]
  │
  ├─→ AI Monitors KPIs Daily → kpi_calculated events
  │   ↓
  ├─→ Success Manager Reviews QBR Metrics (Monthly) → qbr_scheduled event
  │   ↓
  ├─→ Success Manager Identifies Upsell Opportunity → opportunity_identified event
  │   ↓
  │   SUCCESS MANAGER INVITES SPECIALIST:
  │   ↓
  │   Invite Sales Specialist (Voice addon) → specialist_invited event
  │   ↓
  │   Sales Specialist Accepts → specialist_joined event
  │   ↓
  │   Sales Specialist Pitches → expansion_proposal_created event
  │   ↓
  │   Client Agrees → upsell_closed event
  │   ↓
  │   Sales Specialist Exits → specialist_handoff_back event
  │   ↓
  │   Success Manager Continues → client_expanded event
  │
  └─→ Continuous Adoption Monitoring → monitoring_active event

═══════════════════════════════════════════════════════════════════════
OPTIONAL: ITERATION / FLOW CHANGES (Success Manager drives)
═══════════════════════════════════════════════════════════════════════
Success Manager Identifies Iteration Need → iteration_requested event
  ↓
Invite Onboarding Specialist (or AI Workflow Designer) → specialist_invited event
  ↓
Specialist Accepts → specialist_joined event
  ↓
PRD Updated → prd_updated event
  ↓
Config Regenerated (AI-driven, human reviews) → config_generated event
  ↓
Deployed → config_deployed event
  ↓
Specialist Exits → specialist_handoff_back event
  ↓
Success Manager Continues Monitoring → monitoring_active event

Note: If account not claimed within expiry period:
Client Doesn't Claim → assisted_account_expired event
  ↓
Sales Agent Notified → manual_followup_required event
```

**2. Conversation Flow:**
```
User Message → Agent Orchestration
  ↓
LLM Gateway (inference)
  ↓
RAG Pipeline (knowledge retrieval if needed)
  ↓
Tool Execution (CRM Integration Service)
  ↓
Response to User
  ↓
Analytics Service (event logging)
  ↓
Monitoring Engine (quality check)
  ↓
If escalation needed → Escalation event → Human Agent
```

**3. Voice Call Flow:**
```
Inbound Call → Voice Agent Service
  ↓
STT (Deepgram) → Agent Orchestration (business logic)
  ↓
LLM Gateway (inference)
  ↓
TTS (ElevenLabs) → Voice playback
  ↓
If transfer → Transfer event → Human Agent (SIP bridge)
  ↓
Call End → Recording storage → Analytics
```

**4. PRD Collaboration Flow:**
```
Client working on PRD → Needs help → Clicks Help Button
  ↓
PRD Builder generates shareable code (e.g., HELP-ACME-X7K9-2025)
  ↓
help_requested event published to collaboration_events topic
  ↓
Human Agent sees request in Agent Collaboration Dashboard
  ↓
Agent joins session using shareable code
  ↓
agent_joined_session event published
  ↓
WebSocket connection established (real-time collaboration)
  ↓
Agent and client chat + edit canvas collaboratively
  ↓
canvas_edited events published for each edit
  ↓
Agent resolves issue → Ends collaboration session
  ↓
collaboration_ended event published
  ↓
Client continues with AI PRD builder independently
```

---

## Cost Optimization Summary

### LLM Cost Reduction (35-50% savings)

**Strategies:**
1. **Model Routing:** GPT-4o-mini for simple queries, GPT-4 for complex
2. **Semantic Caching:** 20-30% cache hit rate (Helicone/Redis)
3. **Prompt Optimization:** 40% token reduction via compression
4. **Fine-Tuning:** GPT-3.5-turbo fine-tuned for specialized tasks (10× cost reduction)

**Target:** $0.50-0.70 per conversation (down from $1.20)

### Infrastructure Cost Reduction (40-60% savings)

**Strategies:**
1. **Right-Sizing:** VPA-optimized resource requests
2. **Spot Instances:** 60-90% savings for batch jobs
3. **Tiered Storage:** Hot (SSD) → Warm (HDD) → Cold (S3 Glacier)
4. **Connection Pooling:** PgBouncer reduces DB costs 80%
5. **Vector DB Optimization:** Quantization reduces memory 4-8×

**Target:** $1,500-3,000/month infrastructure (100K conversations)

### Voice Cost Reduction (30-40% savings)

**Strategies:**
1. **STT Optimization:** Deepgram Nova-3 (balance of speed + cost)
2. **TTS Optimization:** OpenAI TTS for cost, ElevenLabs for quality
3. **Turn Detection:** Custom VAD reduces silence costs
4. **Dual Streaming:** Begin TTS before LLM completion

**Target:** $0.05-0.07/min (down from $0.10/min)

---

## Performance Targets

### Service-Level Objectives (SLOs)

**API Latency:**
- P95: <2s for chatbot responses
- P95: <500ms for voice agent responses
- P95: <5s for demo generation
- P95: <10s for PRD generation

**Availability:**
- Core services: 99.9% uptime (43min downtime/month)
- Voice services: 99.95% uptime (21min downtime/month)
- Analytics: 99.5% uptime (3.6hr downtime/month)

**Throughput:**
- 10,000 concurrent conversations (chatbot)
- 1,000 concurrent calls (voice)
- 1M events/sec (analytics pipeline)

**Error Budgets:**
- If SLO violated: Halt feature development, focus on reliability
- Monthly review: Adjust SLOs based on business needs

---

## Summary & Next Steps

This microservices architecture provides a **production-ready foundation** for an AI workflow automation platform scaling from prototype to millions of users. The 15 specialized microservices enable:

✅ **Modular Development:** Independent service deployment, sprint-based roadmap
✅ **Multi-Tenant Isolation:** Support 10,000+ clients with namespace/RLS segregation
✅ **Event-Driven Scalability:** Kafka-based loose coupling, horizontal scaling
✅ **Configuration-Driven Agents:** YAML-based dynamic behavior without code changes
✅ **Cost Optimization:** 80% reduction in customer service costs
✅ **Security & Compliance:** SOC 2, HIPAA, GDPR, PCI-DSS ready

### Implementation Roadmap

**Phase 1 (Months 1-4):** Core services (Research, Demo, NDA, Pricing, Proposal)
**Phase 2 (Months 5-8):** PRD & Automation (PRD Builder, Automation Engine, Config Mgmt)
**Phase 3 (Months 9-12):** Runtime services (Agent Orchestration, Voice, Monitoring)
**Phase 4 (Months 13-16):** Support services (Analytics, Customer Success, CRM Integration)
**Phase 5 (Months 17-20):** Production hardening (Security, compliance, multi-region)

### Success Metrics

**Operational:**
- 95% automation rate within 12 months
- 99.9% uptime SLA achievement
- <2s API response time (P95)
- <500ms voice latency (P95)

**Business:**
- 80% reduction in support costs
- 90%+ client satisfaction (CSAT >4.5)
- 50% reduction in time-to-deployment (PRD → production)
- 10× increase in concurrent client capacity

### Technical Debt Prevention

1. **Service Ownership:** Each service has a dedicated engineering team
2. **API Contracts:** OpenAPI specs, contract testing (Pact)
3. **Observability:** Comprehensive logging, tracing, metrics from day one
4. **Documentation:** Auto-generated API docs, architecture decision records (ADRs)
5. **Code Quality:** Pre-commit hooks, test coverage >80%, security scanning

---

**This completes the comprehensive microservices architecture specification for the Complete Workflow Automation System.**
