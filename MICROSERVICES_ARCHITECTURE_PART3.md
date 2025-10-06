# Microservices Architecture Specification (Part 3 - Final)
## Complete Workflow Automation System - Core Runtime & Support Services

---

## 8. Agent Orchestration Service

#### Objectives
- **Primary Purpose**: Core LangGraph-based orchestration engine that powers **chatbot workflows** using dynamic YAML configurations
- **Business Value**: Enables multi-tenant chatbot deployment with configuration-driven behavior, supports 10,000+ concurrent conversations, 99.9% uptime
- **Product Scope**: This service is **chatbot-specific** (product_type: chatbot). Voicebots use LiveKit framework instead (see Voice Agent Service).
- **Architecture Reference**: Implements the two-node pattern from [LangGraph Customer Support Tutorial](https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/)
- **Scope Boundaries**:
  - **Does**: Load YAML configs (with external integrations), orchestrate LangGraph chatbot workflows, manage conversation state, execute tools, handle escalations
  - **Does Not**: Generate configs (Automation Engine does), implement tools (developers do), manage voice infrastructure (Voice Service does), power voicebots (separate LiveKit implementation)

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
- **Automation Engine** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 7]* (YAML config source)
- **Configuration Management** *[See Service 10 below]* (config distribution)
- **LLM Gateway Service** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 16]* (model inference)
- **RAG Pipeline Service** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 17]* (knowledge retrieval)
- **CRM Integration Service** (tool execution)
- **Supabase PostgreSQL** (state checkpoints, conversation logs)

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

#### Chatbot LangGraph Architecture

**Framework Pattern**: Two-node workflow following [LangGraph Customer Support Tutorial](https://langchain-ai.github.io/langgraph/tutorials/customer-support/customer-support/)

**Core Components:**

1. **StateGraph Implementation**
   - **Agent Node**: LLM-powered decision making, tool selection, response generation
   - **Tools Node**: Dynamic tool execution based on YAML config
   - **Conditional Edges**: Routes between agent ↔ tools based on tool calls
   - **Checkpointing**: PostgreSQL-backed state persistence for fault tolerance

2. **State Schema (TypedDict)**
   ```python
   class ChatbotState(TypedDict):
       messages: List[BaseMessage]
       conversation_id: str
       user_id: str
       config_id: str
       pii_collected: Dict[str, Any]
       tool_history: List[ToolCall]
       escalation_triggered: bool
       checkpoint_id: str
   ```

3. **YAML Configuration Structure (Chatbot)**
   ```yaml
   product_type: chatbot  # Required: differentiates from voicebot
   system_prompt: "You are a helpful customer support agent..."
   tools:
     - name: fetch_order_status
       description: "Retrieves order status by order ID"
       parameters: {...}
     - name: initiate_refund
       description: "Initiates refund process"
       parameters: {...}
   external_integrations:  # ONLY in chatbot configs (NOT voicebot)
     - type: salesforce
       credentials_ref: "salesforce_prod"
       enabled: true
     - type: stripe
       credentials_ref: "stripe_live"
       enabled: true
   escalation_rules:
     - trigger: "user_frustrated"
       action: "human_handoff"
   ```

4. **Cross-Product Communication**
   - **Use Case**: Medical prescription image during voice call
   - **Flow**: Voicebot active → Chatbot receives image upload → Chatbot processes image silently (no conversational response) → Chatbot publishes `cross_product_image_processed` event → Voicebot receives event → Voicebot continues conversation with parsed prescription data
   - **Implementation**: Kafka topic `cross_product_events` (see Event Schemas section)

5. **Hot-Reload Mechanism**
   - Kafka `config_events` topic triggers config refresh
   - Version pinning prevents mid-conversation updates (waits for conversation end)
   - New conversations immediately use latest config

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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
      "escalation_suggested": false,
      "personalization_applied": {
        "cohort": "active_power_users",
        "system_prompt_override": true,
        "experiment_id": "uuid",
        "variant_id": "v3"
      }
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
  "organization_id": "uuid",
  "updated_by": "github_issue_closed_webhook",
  "changes": ["tool_attached:initiate_refund"],
  "hot_reload_required": true,
  "timestamp": "2025-10-20T10:00:00Z"
}
  ↓
Agent Orchestration Service & Voice Agent Service (Kafka consumers) receive event
  ↓
Each service filters by product_type:
  - Agent Orchestration: Only processes if product_type == "chatbot"
  - Voice Agent: Only processes if product_type == "voicebot"
  - Prevents unnecessary reloads for irrelevant product configs
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
   - Responsibility: Conducts conversations, invokes tools, manages state, applies personalization
   - Tools: Dynamic (loaded from YAML config)
   - Autonomy: Fully autonomous within config constraints
   - Escalation: Human handoff triggered by config rules (sentiment, complexity, user request)
   - Personalization Integration: Fetches cohort-based overrides from Hyperpersonalization Engine before generating responses

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

5. **Personalization Context Agent (NEW)**
   - Responsibility: Fetches user cohort, lifecycle stage, and experiment assignments from Hyperpersonalization Engine
   - Tools: Hyperpersonalization Engine API, Redis cache
   - Autonomy: Fully autonomous
   - Escalation: None (falls back to base config if unavailable)

**Approval Workflows:**
1. Conversation Start → Auto-approved
2. Tool Execution → Auto-executed (config-defined tools)
3. Human Escalation → Auto-routed to available agent
4. Cross-Sell Recommendation → User acceptance required
5. Survey Sending → Auto-sent at conversation end (if config enabled)

---

## 9. Voice Agent Service

#### Objectives
- **Primary Purpose**: Real-time voice conversation handling using **LiveKit Agents framework** with sub-500ms latency
- **Business Value**: Enables voice automation for phone support/sales, reduces call costs from $13/call to $2-3/call
- **Product Scope**: This service is **voicebot-specific** (product_type: voicebot). Chatbots use LangGraph framework instead (see Agent Orchestration Service).
- **Architecture**: Uses LiveKit VoicePipelineAgent (STT-LLM-TTS pipeline), NOT LangGraph. Shares conceptual agent+tools pattern but different implementation.
- **Scope Boundaries**:
  - **Does**: Handle voice calls, STT/TTS processing, LiveKit session management, SIP integration (Twilio/Telnyx), voicebot workflows with YAML-configured tools
  - **Does Not**: Generate configs (Automation Engine), use LangGraph (chatbot-only), include external integrations in YAML (SIP endpoint provided separately)

#### Requirements

**Functional Requirements:**
1. LiveKit-based voice session management
2. STT integration (Deepgram Nova-3) with streaming
3. TTS integration (ElevenLabs Flash v2.5) with low latency
4. VoicePipelineAgent workflow (LiveKit framework, YAML-driven tools only)
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
- **Automation Engine** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 7]* (YAML configs)
- **Agent Orchestration Service** *[See Service 8 above]* (business logic for cross-product coordination)
- **Configuration Management** *[See Service 10 below]* (voice-specific configs)
- **External**: LiveKit Cloud/Self-hosted, Deepgram, ElevenLabs, Twilio/Telnyx

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

#### Voicebot LiveKit Architecture

**Framework**: LiveKit Agents (Python SDK) - NOT LangGraph

**Core Components:**

1. **VoicePipelineAgent Implementation**
   - **STT Pipeline**: Deepgram Nova-3 streaming transcription
   - **LLM Integration**: Same LLM Gateway as chatbots, but optimized for voice latency
   - **TTS Pipeline**: ElevenLabs Flash v2.5 with dual streaming
   - **Turn Detection**: VAD (Voice Activity Detection) for <300ms latency
   - **Agent Logic**: Shares conceptual agent+tools pattern with chatbots but implemented in LiveKit framework

2. **LiveKit SIP Integration**
   - **SIP Bridge**: LiveKit SIP server connects PSTN calls to LiveKit rooms
   - **Providers**: Twilio (primary), Telnyx (failover)
   - **Inbound Flow**: PSTN → Twilio SIP → LiveKit SIP Bridge → VoicePipelineAgent
   - **Outbound Flow**: VoicePipelineAgent → LiveKit SIP Bridge → Twilio SIP → PSTN

3. **YAML Configuration Structure (Voicebot)**
   ```yaml
   product_type: voicebot  # Required: differentiates from chatbot
   system_prompt: "You are a helpful voice assistant..."
   tools:
     - name: fetch_account_info
       description: "Retrieves account information"
       parameters: {...}
     - name: schedule_appointment
       description: "Schedules an appointment"
       parameters: {...}
   # NO external_integrations field (unlike chatbot)
   # SIP endpoint configured separately via SIP trunk provisioning
   escalation_rules:
     - trigger: "user_frustrated"
       action: "human_transfer"
   voice_config:
     stt_provider: deepgram
     tts_provider: elevenlabs
     voice_id: "sarah_professional"
     turn_detection_threshold_ms: 300
     # Client-configurable voice parameters (matching visual UI)
     background_sound:
       type: "office"  # office | cafe | silence | custom
       custom_url: null
     input_min_characters: 10
     punctuation_boundaries: [".", "!", "?", "..."]
     model_settings:
       model: "gpt-4"
       clarity_similarity: 0.75
       speed: 1.0
       style_exaggeration: 0
       optimize_streaming_latency: 4
       use_speaker_boost: true
       auto_mode: false
     max_tokens: 150
     stop_speaking_plan:
       number_of_words: 3
       voice_seconds: 0.5
       back_off_seconds: 2
   ```

4. **Cross-Product Communication**
   - **Use Case**: Medical prescription image uploaded during voice call
   - **Flow**: Voicebot active on call → User uploads prescription image via chatbot widget → Chatbot processes image (OCR/LLM parsing) → Chatbot publishes `cross_product_image_processed` event → Voicebot receives event → Voicebot continues call: "I see you've uploaded a prescription for Amoxicillin 500mg..."
   - **Implementation**: Kafka topic `cross_product_events` enables coordination
   - **Key Constraint**: Chatbot does NOT send conversational responses when voicebot is active (silent processing only)

5. **Key Differences from Chatbot**
   | Aspect | Chatbot (LangGraph) | Voicebot (LiveKit) |
   |--------|---------------------|-------------------|
   | Framework | LangGraph | LiveKit Agents |
   | State Management | StateGraph + Checkpointing | LiveKit room state |
   | YAML Config | Includes `external_integrations` | NO `external_integrations` |
   | SIP Integration | N/A | Twilio/Telnyx SIP trunks |
   | Latency Target | <2s P95 | <500ms P95 |
   | Tool Execution | Via LangGraph tools node | Via LiveKit agent callbacks |

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
  "product_type": "voicebot",
  "status": "initiating",
  "sip_session_id": "uuid",
  "estimated_connect_time": "5 seconds"
}

Event Published to Kafka:
Topic: voice_events
{
  "event_type": "call_initiated",
  "call_id": "uuid",
  "product_type": "voicebot",
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
  "product_type": "voicebot",
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
  "product_type": "voicebot",
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
  "product_type": "voicebot",
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
  "product_type": "voicebot",
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
  "product_type": "voicebot",
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

1. **Voice Agent (LiveKit-based)**
   - Responsibility: Conducts voice conversations using VoicePipelineAgent
   - Tools: YAML-configured tools (similar pattern to chatbot but LiveKit implementation)
   - Framework: LiveKit Agents (NOT LangGraph)
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
- **Primary Purpose**: Centralized configuration storage, validation, and hot-reload distribution for chatbot and voicebot configurations
- **Business Value**: Enables dynamic behavior changes without deployments, supports feature flags, ensures config consistency, validates product type differentiation
- **Scope Boundaries**:
  - **Does**: Store configs in S3, watch for changes, validate configs (including product_type validation), propagate updates via Kafka, manage feature flags
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
- **Automation Engine** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 7]* (generates configs)
- **Agent Orchestration Service** *[See Service 8 above]* (consumes configs)
- **Voice Agent Service** *[See Service 9 above]* (consumes configs)
- **S3** (config storage)
- **Kafka** (config update events)

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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
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
  "breaking_change_detected": false,
  "product_type": "chatbot"  // or "voicebot"
}

Response (400 Bad Request - Validation Failed):
{
  "valid": false,
  "errors": [
    {
      "field": "product_type",
      "message": "Required field missing. Must be 'chatbot' or 'voicebot'",
      "severity": "error"
    },
    {
      "field": "external_integrations",
      "message": "Field not allowed for product_type: voicebot",
      "severity": "error"
    },
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
  "product_type": "chatbot",
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
Authorization: Bearer {platform_admin_jwt OR client_config_manager_jwt}
Content-Type: application/json

Request Body:
{
  "target_version": 3,
  "reason": "Version 4 causing high error rate",
  "initiated_by": "client_user",  // 'client_user' | 'platform_engineer'
  "user_id": "uuid"  // Client user ID if client-initiated
}

Response (200 OK):
{
  "config_id": "uuid",
  "product_type": "chatbot",
  "rolled_back_from": 4,
  "rolled_back_to": 3,
  "active_version": 3,
  "kafka_event_published": true,
  "initiated_by": "client_user"
}

Event Published to Kafka:
Topic: config_events
{
  "event_type": "config_rollback",
  "config_id": "uuid",
  "product_type": "chatbot",
  "from_version": 4,
  "to_version": 3,
  "reason": "high_error_rate",
  "initiated_by": "client_user",
  "timestamp": "2025-10-20T11:00:00Z"
}
```

**7. Compare Config Versions**
```http
POST /api/v1/configs/{config_id}/versions/compare
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "version_a": 3,
  "version_b": 4
}

Response (200 OK):
{
  "config_id": "uuid",
  "product_type": "chatbot",
  "version_a": 3,
  "version_b": 4,
  "diff": {
    "added": {
      "tools": [
        {
          "name": "initiate_refund",
          "description": "Process customer refund requests"
        }
      ]
    },
    "removed": {},
    "modified": {
      "system_prompt": {
        "old": "You are a helpful assistant...",
        "new": "You are a helpful and empathetic assistant..."
      }
    }
  },
  "breaking_changes": false,
  "risk_assessment": {
    "risk_level": "low",
    "reasons": ["Added new tool without removing existing functionality"]
  },
  "visual_diff_url": "https://s3.amazonaws.com/workflow-configs/diffs/config-uuid-v3-v4.html"
}
```

**8. Preview Configuration Changes**
```http
POST /api/v1/configs/{config_id}/preview
Authorization: Bearer {jwt_token}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "changes": {
    "system_prompt": "You are a casual and friendly assistant...",
    "voice_settings": {
      "speed": 1.2
    }
  },
  "test_scenarios": [
    {
      "user_message": "I need a refund",
      "expected_behavior": "Should trigger refund tool"
    }
  ]
}

Response (200 OK):
{
  "preview_id": "uuid",
  "config_id": "uuid",
  "sandbox_url": "wss://sandbox.workflow.ai/preview/{preview_id}",
  "expires_at": "2025-10-20T12:00:00Z",  // 1 hour expiry
  "test_results": [
    {
      "scenario": "I need a refund",
      "agent_response": "I'd be happy to help you with a refund. Let me process that for you...",
      "tool_called": "initiate_refund",
      "success": true
    }
  ],
  "validation": {
    "valid": true,
    "warnings": [],
    "errors": []
  }
}
```

**9. Create/Manage Config Branches**
```http
POST /api/v1/configs/{config_id}/branches
Authorization: Bearer {client_config_manager_jwt}
Content-Type: application/json

Request Body:
{
  "branch_name": "staging",
  "base_version": 4,
  "description": "Testing new empathy-focused prompts before production"
}

Response (201 Created):
{
  "branch_id": "uuid",
  "config_id": "uuid",
  "branch_name": "staging",
  "base_version": 4,
  "current_version": 4,
  "created_at": "2025-10-20T10:00:00Z",
  "status": "active"
}

# Merge branch to main
POST /api/v1/configs/{config_id}/branches/{branch_name}/merge
Authorization: Bearer {client_config_manager_jwt}

Response (200 OK):
{
  "config_id": "uuid",
  "branch_name": "staging",
  "merged_into": "main",
  "new_version": 5,
  "changes_applied": ["system_prompt", "voice_settings"]
}
```

**10. Get Config Change History (Client UI)**
```http
GET /api/v1/configs/{config_id}/history
Authorization: Bearer {client_jwt}
Query Parameters:
- limit: 50
- offset: 0
- author_type: 'client_user' | 'ai_agent' | 'all'

Response (200 OK):
{
  "config_id": "uuid",
  "product_type": "chatbot",
  "total_changes": 156,
  "changes": [
    {
      "change_id": "uuid",
      "version": "v5",
      "author": "john@acme.com",
      "author_type": "client_user",
      "change_type": "system_prompt",
      "commit_message": "Made tone more casual for better customer engagement",
      "risk_level": "low",
      "applied_at": "2025-10-20T10:30:00Z",
      "rolled_back": false
    },
    {
      "change_id": "uuid",
      "version": "v4",
      "author": "AI Config Agent",
      "author_type": "ai_agent",
      "change_type": "tool",
      "commit_message": "Added initiate_refund tool based on client feedback",
      "risk_level": "medium",
      "approved_by": "admin@acme.com",
      "applied_at": "2025-10-20T10:00:00Z",
      "rolled_back": false
    }
  ]
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
   - Responsibility: Validates YAML configs against JSON schema, enforces product type rules
   - Tools: JSON Schema validators, YAML parsers
   - Validation Rules:
     - product_type field required (chatbot | voicebot)
     - chatbot configs MUST include external_integrations
     - voicebot configs MUST NOT include external_integrations
     - Both require system_prompt, tools, escalation_rules
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

## 19. Client Configuration Portal Service

#### Objectives
- **Primary Purpose**: Enable clients to self-configure deployed chatbot/voicebot products via conversational AI and visual dashboard with version control and member-based permissions
- **Business Value**: 80% reduction in configuration support tickets, instant config changes, client autonomy, improved time-to-value
- **Product Scope**: Supports both chatbot and voicebot product configuration with product-specific UI controls
- **Scope Boundaries**:
  - **Does**: Conversational config via AI agent, visual config dashboard, member permission management, version control UI, change classification, config preview/testing, rollback management
  - **Does Not**: Generate initial configs (Automation Engine does), validate schemas (Configuration Management does), implement tools (developers do)

#### Requirements

**Functional Requirements:**
1. Natural language configuration via conversational AI agent
2. Visual configuration dashboard with product-specific controls (chatbot vs voicebot)
3. Member-based permission system for configuration changes
4. Git-style version control with commit messages and rollback
5. Change classification (system_prompt, tool, voice_param, integration, etc.)
6. Real-time configuration preview and testing sandbox
7. Automated change risk assessment with approval workflows
8. Human agent coordination for complex configuration needs

**Non-Functional Requirements:**
- Configuration change application: <2 minutes from request to live deployment
- Conversational response time: <3s for classification and preview generation
- Support 10,000+ organizations with isolated configuration access
- 99.9% uptime for configuration portal
- Version history retention: 1 year minimum

**Dependencies:**
- **Configuration Management Service** *[See Service 10 above]* (stores/distributes configs, validates schemas)
- **Automation Engine** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 7]* (initial config generation)
- **Organization Management Service** *[See MICROSERVICES_ARCHITECTURE.md Service 0]* (member roles and permissions)
- **Agent Orchestration Service** *[See Service 8 above]* (applies chatbot config changes)
- **Voice Agent Service** *[See Service 9 above]* (applies voicebot config changes)
- **LLM Gateway Service** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 16]* (powers conversational config agent)

**Data Storage:**
- PostgreSQL: Config change log, member permissions, version metadata, approval workflows
- S3: Version snapshots, config diff visualizations
- Redis: Conversational state (chat context), config draft cache

#### Features

**Must-Have:**
1. ✅ Conversational configuration agent with change classification
2. ✅ Visual dashboard for chatbot configuration (system prompt, tools, integrations)
3. ✅ Visual dashboard for voicebot configuration (voice parameters, model settings, stop speaking plan)
4. ✅ Member permission matrix (Admin, Config Manager, Viewer, Developer roles)
5. ✅ Git-style version control with commit messages
6. ✅ Side-by-side diff viewer (before/after comparison)
7. ✅ One-click rollback to previous versions
8. ✅ Configuration testing sandbox with preview
9. ✅ Change risk assessment (low/medium/high) with automated approval for low-risk changes
10. ✅ Human agent escalation for complex configuration requests

**Nice-to-Have:**
11. 🔄 AI-powered configuration optimization suggestions
12. 🔄 Configuration templates marketplace (share configs across organizations)
13. 🔄 Automated regression testing for config changes
14. 🔄 Configuration import/export (JSON/YAML)
15. 🔄 Multi-environment support (dev/staging/production branches)

**Feature Interactions:**
- Client requests config change via chat → Agent classifies → Shows preview → Client approves → Hot-reload applied
- Visual slider changed (voicebot speed) → Immediate preview in test call → Save creates new version
- Risky change detected → Requires organization admin approval → Sends notification
- Configuration error after deployment → Auto-rollback triggered → Platform engineer alerted

#### Conversational Configuration Agent Architecture

**LangGraph Agent Implementation:**

```python
class ConfigurationAgentState(TypedDict):
    messages: List[BaseMessage]
    config_id: str
    organization_id: str
    product_type: str  # chatbot | voicebot
    current_config: Dict[str, Any]
    detected_changes: List[Dict[str, Any]]
    classification_confidence: float
    preview_generated: bool
    approval_status: str  # pending | approved | rejected
    conversation_id: str

class ConfigurationAgent:
    """LangGraph agent for conversational configuration"""

    def __init__(self):
        self.tools = [
            classify_configuration_request,
            generate_system_prompt_update,
            search_available_tools,
            create_github_tool_request,
            update_voice_parameters,
            preview_configuration_change,
            validate_configuration,
            apply_configuration_change
        ]

        # Two-node workflow: agent + tools
        self.graph = StateGraph(ConfigurationAgentState)
        self.graph.add_node("agent", self.agent_node)
        self.graph.add_node("tools", ToolNode(self.tools))

        # Routing logic
        self.graph.add_conditional_edges(
            "agent",
            self.should_continue,
            {"tools": "tools", "end": END}
        )
        self.graph.add_edge("tools", "agent")
        self.graph.set_entry_point("agent")
```

**Change Classification Model:**

```yaml
change_types:
  system_prompt_change:
    keywords: ["tone", "casual", "professional", "friendly", "instructions", "behavior", "personality"]
    confidence_threshold: 0.85
    risk_level: low

  tool_change:
    keywords: ["add tool", "remove tool", "enable", "disable", "refund", "payment", "integration"]
    confidence_threshold: 0.90
    risk_level: medium
    requires_tool_lookup: true

  voice_parameter_change:
    keywords: ["speed", "slower", "faster", "clarity", "latency", "voice", "interruption"]
    confidence_threshold: 0.88
    risk_level: low

  external_service_change:
    keywords: ["salesforce", "zendesk", "integration", "connect", "api", "webhook"]
    confidence_threshold: 0.92
    risk_level: high

  escalation_rule_change:
    keywords: ["escalate", "human", "transfer", "handoff", "trigger"]
    confidence_threshold: 0.87
    risk_level: medium
```

#### API Specification

**1. Conversational Configuration Chat**
```http
POST /api/v1/client-config/chat
Authorization: Bearer {client_jwt}
Content-Type: application/json

Request Body:
{
  "config_id": "uuid",
  "message": "Make the voicebot speak slower and add a refund tool",
  "conversation_id": "uuid",  // Maintains context across messages
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
  "requires_approval": false,  // Auto-approved for this user's role
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
        "type": "office",  // office | cafe | silence | custom
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
  "commit_message": "Adjusted voice speed and interruption handling for better user experience",
  "apply_immediately": false  // If false, creates draft for review
}

Response (200 OK):
{
  "version": "v48",
  "status": "pending_approval",  // pending_approval | draft | applied
  "preview_url": "https://config.workflow.com/preview/uuid",
  "test_call_url": "https://config.workflow.com/test-call/uuid",  // Voicebot testing
  "validation": {
    "valid": true,
    "warnings": [],
    "estimated_impact": "Low - voice parameter changes only",
    "affected_conversations": 0  // No active conversations affected
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
    },
    {
      "version": "v47",
      "commit_message": "Added escalation rule for frustrated customers",
      "author": {
        "user_id": "uuid",
        "email": "john@acme.com",
        "role": "config_manager"
      },
      "changes": [
        {"type": "escalation_rule_change", "trigger": "sentiment_negative_3_turns", "action": "add"}
      ],
      "risk_level": "medium",
      "applied_at": "2025-10-14T11:15:00Z",
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
  "notify_team": true  // Notify all config managers
}

Response (200 OK):
{
  "config_id": "uuid",
  "rolled_back_from": "v48",
  "rolled_back_to": "v47",
  "new_current_version": "v49",  // Rollback creates new version
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
    },
    {
      "user_id": "uuid",
      "email": "john@acme.com",
      "role": "config_manager",
      "config_permissions": {
        "view_config": true,
        "edit_system_prompt": true,
        "add_remove_tools": true,
        "modify_integrations": false,
        "change_voice_params": true,
        "deploy_to_production": false,
        "rollback_versions": true,
        "manage_permissions": false
      }
    }
  ]
}
```

**6. Update Member Permissions**
```http
PUT /api/v1/client-config/permissions/{user_id}
Authorization: Bearer {org_admin_jwt}  // Only org admins can modify permissions
Content-Type: application/json

Request Body:
{
  "organization_id": "uuid",
  "config_permissions": {
    "view_config": true,
    "edit_system_prompt": true,
    "add_remove_tools": false,  // Revoke tool management
    "modify_integrations": false,
    "change_voice_params": true,
    "deploy_to_production": false,
    "rollback_versions": false,  // Revoke rollback capability
    "manage_permissions": false
  }
}

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "config_permissions": {...},
  "updated_at": "2025-10-15T15:10:00Z",
  "updated_by": "uuid"
}
```

#### Database Schema

```sql
-- Main configurations table (stores all chatbot/voicebot configurations)
CREATE TABLE configurations (
  config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  product_type VARCHAR(20) NOT NULL CHECK (product_type IN ('chatbot', 'voicebot')),
  version INT NOT NULL DEFAULT 1,
  yaml_content TEXT NOT NULL,
  s3_url TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived', 'draft')),
  breaking_change BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  INDEX idx_org_product_configs (organization_id, product_type),
  INDEX idx_config_version (config_id, version),
  INDEX idx_config_status (status) WHERE status = 'active',
  INDEX idx_config_s3 (s3_url),
  UNIQUE(organization_id, product_type, version)
);

-- Row-Level Security for multi-tenant isolation
ALTER TABLE configurations ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_configs ON configurations
  FOR ALL
  USING (organization_id IN (
    SELECT organization_id FROM team_memberships WHERE user_id = auth.uid()
  ));

-- Config change audit log
CREATE TABLE config_change_log (
  change_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL,
  version VARCHAR(20) NOT NULL,
  author_id UUID NOT NULL,
  author_type VARCHAR(20) NOT NULL,  -- 'client_user' | 'platform_agent' | 'ai_agent'
  author_email VARCHAR(255),
  change_type VARCHAR(50),  -- 'system_prompt' | 'tool' | 'voice_param' | 'integration' | 'escalation_rule' | 'hybrid'
  changes JSONB NOT NULL,
  commit_message TEXT,
  risk_level VARCHAR(20),  -- 'low' | 'medium' | 'high'
  approved_by UUID,
  approved_at TIMESTAMP,
  applied_at TIMESTAMP,
  rolled_back BOOLEAN DEFAULT false,
  rollback_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_config_version (config_id, version),
  INDEX idx_config_applied (config_id, applied_at),
  FOREIGN KEY (config_id) REFERENCES configurations(config_id)
);

-- Member configuration permissions
CREATE TABLE organization_member_config_permissions (
  permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  user_id UUID NOT NULL,
  config_permissions JSONB NOT NULL,  -- Permission matrix
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(organization_id, user_id),
  INDEX idx_org_permissions (organization_id),
  FOREIGN KEY (organization_id) REFERENCES organizations(organization_id),
  FOREIGN KEY (user_id) REFERENCES auth.users(user_id)
);

-- Conversational config sessions
CREATE TABLE config_conversation_sessions (
  conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL,
  user_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  product_type VARCHAR(20) NOT NULL,  -- 'chatbot' | 'voicebot'
  messages JSONB[],  -- Conversation history
  detected_changes JSONB[],
  status VARCHAR(20),  -- 'active' | 'pending_approval' | 'completed' | 'abandoned'
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  INDEX idx_config_conversations (config_id, started_at),
  FOREIGN KEY (config_id) REFERENCES configurations(config_id)
);

-- Configuration draft versions (before applying)
CREATE TABLE config_drafts (
  draft_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL,
  proposed_changes JSONB NOT NULL,
  diff JSONB,
  commit_message TEXT,
  created_by UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,  -- Drafts expire after 7 days
  applied BOOLEAN DEFAULT false,
  applied_at TIMESTAMP,
  INDEX idx_config_drafts (config_id, created_at),
  FOREIGN KEY (config_id) REFERENCES configurations(config_id)
);
```

#### Kafka Events

```json
// Published when client requests configuration change
{
  "event_type": "client_config_change_requested",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "voicebot",
  "requested_by": "client_user_id",
  "requested_via": "conversational_agent",  // conversational_agent | visual_dashboard
  "changes": [
    {
      "type": "voice_parameter_change",
      "parameter": "speed",
      "old_value": 1.0,
      "new_value": 0.8
    }
  ],
  "risk_level": "low",
  "auto_approved": true,
  "version": "v48",
  "timestamp": "2025-10-15T14:00:00Z"
}
```

```json
// Published when configuration is successfully applied
{
  "event_type": "client_config_applied",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "chatbot",
  "version": "v48",
  "changes": [...],
  "applied_by": "uuid",
  "commit_message": "Changed tone to casual",
  "hot_reload_required": true,
  "timestamp": "2025-10-15T14:01:00Z"
}
```

```json
// Published when configuration is rolled back
{
  "event_type": "client_config_rolled_back",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "voicebot",
  "rolled_back_from": "v48",
  "rolled_back_to": "v47",
  "new_version": "v49",
  "reason": "New voice speed causing customer complaints",
  "rolled_back_by": "uuid",
  "timestamp": "2025-10-15T15:00:00Z"
}
```

#### Frontend Components (React/Next.js)

**Routes:**
- `/dashboard/config` - Main configuration dashboard
- `/dashboard/config/chat` - Conversational configuration interface
- `/dashboard/config/visual/chatbot` - Visual chatbot configuration panel
- `/dashboard/config/visual/voicebot` - Visual voicebot configuration panel (matches provided images)
- `/dashboard/config/versions` - Version history timeline (git-style)
- `/dashboard/config/permissions` - Member permission management
- `/dashboard/config/preview` - Configuration testing sandbox

**Key Components:**

```tsx
// ConfigChatInterface.tsx
<ConfigChatInterface
  configId={configId}
  productType={productType}
  onChangeDetected={(changes) => showPreview(changes)}
  onApprovalRequired={(changes) => requestApproval(changes)}
/>

// VoicebotConfigPanel.tsx (matches provided images)
<VoicebotConfigPanel
  config={config}
  sections={[
    {
      title: "Additional Configuration",
      fields: [
        { type: "select", name: "background_sound", label: "Background Sound", options: ["Office", "Cafe", "Silence", "Custom"] },
        { type: "text", name: "background_sound_url", label: "Background Sound URL", placeholder: "https://www.soundjay.com/" },
        { type: "slider", name: "input_min_characters", label: "Input Min Characters", min: 10, max: 100, default: 10 }
      ]
    },
    {
      title: "Model Settings",
      fields: [
        { type: "select", name: "model", label: "Model" },
        { type: "slider", name: "clarity_similarity", label: "Clarity + Similarity", min: 0, max: 1, default: 0.75 },
        { type: "slider", name: "speed", label: "Speed", min: 0, max: 2, default: 1 },
        { type: "slider", name: "style_exaggeration", label: "Style Exaggeration", min: 0, max: 1, default: 0 },
        { type: "slider", name: "optimize_streaming_latency", label: "Optimize Streaming Latency", min: 0, max: 4, default: 4 },
        { type: "toggle", name: "use_speaker_boost", label: "Use Speaker Boost" },
        { type: "toggle", name: "auto_mode", label: "Auto Mode" }
      ]
    },
    {
      title: "Stop Speaking Plan",
      fields: [
        { type: "slider", name: "number_of_words", label: "Number of words", min: 0, max: 10, default: 3 },
        { type: "slider", name: "voice_seconds", label: "Voice seconds", min: 0, max: 1, step: 0.1, default: 0.5 },
        { type: "slider", name: "back_off_seconds", label: "Back off seconds", min: 0, max: 10, default: 2 }
      ]
    }
  ]}
  onSave={(changes) => applyConfigChanges(changes)}
  onPreview={() => openTestCall()}
/>

// VersionHistoryTimeline.tsx
<VersionHistoryTimeline
  configId={configId}
  versions={versions}
  onRollback={(version) => rollbackToVersion(version)}
  onDiffView={(v1, v2) => showDiffViewer(v1, v2)}
/>

// PermissionMatrix.tsx
<PermissionMatrix
  organizationId={organizationId}
  members={members}
  permissions={permissionSchema}
  onUpdatePermissions={(userId, permissions) => updateMemberPermissions(userId, permissions)}
  canEdit={currentUser.role === 'organization_admin'}
/>
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Organization Admin (Client)**
   - Role: Full configuration control, permission management
   - Access: All configuration features
   - Permissions: All config_permissions enabled
   - Workflows: Changes config via chat/visual UI, manages team permissions, reviews version history

2. **Config Manager (Client)**
   - Role: Day-to-day configuration management
   - Access: Most configuration features except deployment and permission management
   - Permissions: View, edit prompts/voice params, rollback (no deployment, no permission management)
   - Workflows: Adjusts chatbot tone, modifies voice settings, tests changes

3. **Config Viewer (Client)**
   - Role: Read-only config access
   - Access: View-only dashboard
   - Permissions: view_config only
   - Workflows: Reviews current configuration, views change history

4. **Support Agent (Platform)**
   - Role: Assists clients with complex configuration requests
   - Access: Join client config sessions, create GitHub tool requests
   - Permissions: read:client_configs, create:github_issues, join:config_sessions
   - Workflows: Receives escalation from config agent, helps client configure advanced features, creates tool requests

**AI Agents:**

1. **Configuration Assistant Agent**
   - Responsibility: Classifies configuration requests, generates previews, validates changes
   - Tools: LLM for intent classification, tool catalog search, config diff generator, schema validator
   - Autonomy: Fully autonomous for low-risk changes (auto-apply), requests approval for medium/high risk
   - Escalation: Human support agent for unrecognized requests or failed classifications

2. **Config Validation Agent**
   - Responsibility: Validates configuration changes before deployment, detects breaking changes
   - Tools: JSON Schema validator, conflict detector, impact analyzer
   - Autonomy: Fully autonomous validation
   - Escalation: Platform engineer alert for validation failures or high-risk changes

**Approval Workflows:**
1. Low-risk changes (voice params, tone adjustments) → Auto-approved
2. Medium-risk changes (tool additions, escalation rules) → Organization Admin approval
3. High-risk changes (integration modifications, tool removals) → Organization Admin + Platform Engineer approval
4. Failed changes (validation errors) → Auto-rollback + Support Agent notification

---

## 20. Hyperpersonalization Engine Service

#### Objectives
- **Primary Purpose**: AI-driven personalization of chatbot/voicebot responses based on customer lifecycle stage, cohort behavior, and real-time experimentation
- **Business Value**: Increase conversion rates by 25%, reduce churn by 15%, optimize engagement per customer segment
- **Inspired By**: JustWords.ai approach to lifecycle marketing hyperpersonalization
- **Scope Boundaries**:
  - **Does**: Customer cohort segmentation, dynamic response personalization, A/B/N testing at scale, lifecycle stage automation, engagement optimization
  - **Does Not**: Replace core agent logic, modify tool execution, handle PII storage (Agent Orchestration does)

#### Requirements

**Functional Requirements:**
1. Segment customers into cohorts based on lifecycle stage, usage patterns, engagement levels
2. Dynamically modify chatbot/voicebot responses per cohort without changing base config
3. Run 50-100 message variations simultaneously with multi-armed bandit optimization
4. Automate lifecycle-stage-specific messaging (trial, active, at-risk, renewal)
5. Learn individual user preferences and adapt messaging over time
6. Track engagement metrics (CTR, conversion rate, session duration) per variant
7. Auto-optimize variant weights based on success metrics

**Non-Functional Requirements:**
- Personalization decision: <50ms (must not impact conversation latency)
- Support 1M+ active customer profiles
- Experimentation throughput: 10,000+ variants tested daily
- 99.9% uptime for personalization engine

**Dependencies:**
- **Agent Orchestration Service** *[See Service 8 above]* (consumes personalization rules for chatbot)
- **Voice Agent Service** *[See Service 9 above]* (consumes personalization rules for voicebot)
- **Analytics Service** *[See Service 12 above]* (provides engagement metrics for optimization)
- **Customer Success Service** *[See Service 13 above]* (lifecycle stage data)
- **LLM Gateway Service** *[See MICROSERVICES_ARCHITECTURE_PART2.md Service 16]* (generates variant messaging)

**Data Storage:**
- PostgreSQL: Cohort definitions, personalization rules, experiment configurations
- Redis: Real-time user cohort assignments, variant weights
- Pinecone: Individual user preference embeddings
- ClickHouse: Engagement event logs (time-series), A/B test results

#### Features

**Must-Have:**
1. ✅ Customer cohort segmentation engine (behavioral clustering)
2. ✅ Lifecycle stage automation (trial/active/at-risk/renewal messaging)
3. ✅ Dynamic response personalization per cohort
4. ✅ Multi-armed bandit experimentation (Thompson Sampling)
5. ✅ Real-time variant weight optimization
6. ✅ Engagement metrics tracking (CTR, conversion, session duration)
7. ✅ Individual user preference learning (collaborative filtering)

**Nice-to-Have:**
8. 🔄 Predictive churn scoring (identify at-risk customers before lifecycle stage change)
9. 🔄 Cross-product personalization (chatbot learns from voicebot interactions)
10. 🔄 Seasonal/temporal messaging adjustments (holiday campaigns, product launches)
11. 🔄 Sentiment-driven personalization (adjust tone based on customer mood)

**Feature Interactions:**
- User starts conversation → Personalization Engine assigns cohort → Returns personalized system prompt override → Agent uses modified prompt
- Variant performs well (high CTR) → Weight increased automatically → More users see successful variant
- User moves from "trial" to "active" lifecycle stage → Messaging shifts from educational to efficiency-focused
- Experiment reaches statistical significance → Winning variant promoted to default

#### Personalization Architecture

**Customer Cohort Definitions:**

```yaml
customer_cohorts:
  - cohort_id: "new_trial_users"
    lifecycle_stage: "trial"
    filters:
      days_since_signup: { min: 0, max: 14 }
      engagement_level: "exploring"
      feature_adoption: { max: 3 }
    size_estimate: 1200
    personalization_strategy: "educational_nurture"

  - cohort_id: "active_power_users"
    lifecycle_stage: "active"
    filters:
      monthly_usage: { min: 1000, metric: "conversations" }
      engagement_level: "high"
      subscription_tier: "professional"
    size_estimate: 450
    personalization_strategy: "upsell_premium_features"

  - cohort_id: "at_risk_churners"
    lifecycle_stage: "active"
    filters:
      engagement_trend: "declining_30d"
      engagement_level: "low"
      support_tickets: { min: 2, timeframe: "30d" }
    size_estimate: 180
    personalization_strategy: "retention_intervention"

  - cohort_id: "renewal_approaching"
    lifecycle_stage: "active"
    filters:
      days_until_renewal: { min: 0, max: 30 }
      contract_value: { min: 50000 }
    size_estimate: 90
    personalization_strategy: "renewal_value_reinforcement"
```

**Dynamic Response Personalization Rules:**

```yaml
personalization_rules:
  - trigger: "cohort == new_trial_users"
    modifications:
      system_prompt_override: |
        You are an enthusiastic guide helping new users discover chatbot capabilities.
        Use an educational, patient tone. Highlight ease-of-use and quick wins.
        Proactively offer helpful tips and examples. End responses with encouraging CTAs.
      response_templates:
        greeting: "Welcome to Acme Chatbot! I'm here to help you get started. What would you like to build today?"
        feature_highlight: ["ease_of_use", "template_library", "drag_drop_builder", "24/7_support"]
        cta_priority: "schedule_onboarding_call"
      show_examples: true
      tone_keywords: ["easy", "simple", "guide", "show you", "let me help"]

  - trigger: "cohort == active_power_users"
    modifications:
      system_prompt_override: |
        You are an efficient expert assistant for power users. Be concise and technical.
        Assume user knowledge. Highlight advanced features and API capabilities.
        Focus on efficiency and ROI. Use data-driven language.
      response_templates:
        greeting: "Ready to optimize your workflows? What can I help you build?"
        feature_highlight: ["api_access", "custom_integrations", "advanced_analytics", "webhook_automation"]
        cta_priority: "upgrade_to_enterprise"
      show_usage_stats: true
      show_api_docs: true
      tone_keywords: ["optimize", "advanced", "integrate", "automate", "scale"]

  - trigger: "cohort == at_risk_churners"
    modifications:
      system_prompt_override: |
        You are an empathetic problem-solver focused on demonstrating value.
        Acknowledge challenges. Share success stories from similar companies.
        Offer proactive help. Highlight competitive advantages and ROI.
      response_templates:
        greeting: "I noticed you might need some help. I'm here to make sure you're getting the most value from Acme Chatbot."
        feature_highlight: ["success_stories", "roi_metrics", "cost_savings", "support_commitment"]
        cta_priority: "talk_to_success_manager"
      offer_incentive: "20_percent_discount_renewal"
      show_success_metrics: true
      tone_keywords: ["value", "help", "success", "support", "partnership"]
```

**Multi-Armed Bandit Experimentation:**

```yaml
experiments:
  - experiment_id: "greeting_optimization_trial_users"
    cohort: "new_trial_users"
    target_metric: "conversation_completion_rate"
    secondary_metrics: ["feature_adoption_rate", "time_to_first_action"]

    variants:
      - variant_id: "friendly_casual"
        system_prompt_override: |
          Start conversations with warm, casual greetings. Use friendly emojis sparingly.
          Make users feel welcomed and excited to explore.
        initial_weight: 0.25
        current_weight: 0.32  # Auto-adjusted based on performance
        trials: 1543
        conversions: 1122
        conversion_rate: 0.727

      - variant_id: "professional_direct"
        system_prompt_override: |
          Start with direct, value-focused messaging. Get straight to business.
          Emphasize time savings and efficiency.
        initial_weight: 0.25
        current_weight: 0.18  # Underperforming, weight reduced
        trials: 987
        conversions: 658
        conversion_rate: 0.666

      - variant_id: "educational_helpful"
        system_prompt_override: |
          Begin by offering helpful tips and guidance. Act as a patient teacher.
          Use step-by-step explanations. Reference documentation proactively.
        initial_weight: 0.25
        current_weight: 0.38  # Best performing, weight increased
        trials: 2011
        conversions: 1587
        conversion_rate: 0.789

      - variant_id: "personalized_contextual"
        system_prompt_override: |
          Reference user's company, industry, or previous interactions contextually.
          Make conversation feel tailored and relevant.
        initial_weight: 0.25
        current_weight: 0.12  # Low sample size, still exploring
        trials: 421
        conversions: 298
        conversion_rate: 0.708

    optimization_algorithm: "thompson_sampling"
    min_sample_size_per_variant: 1000
    confidence_level: 0.95
    auto_promote_winner: true  // Promote to default when significance reached
    status: "running"
    started_at: "2025-10-01T00:00:00Z"
```

**Lifecycle Stage Automation:**

```yaml
lifecycle_automations:
  - stage: "trial_day_1"
    trigger: "user_signed_up"
    day_offset: 0
    personalization:
      tone: "enthusiastic, welcoming"
      focus: "onboarding, quick wins"
      cta: "explore_templates"
      message_examples:
        - "Welcome! Let me show you how to build your first chatbot in under 5 minutes."
        - "Great to have you here! What type of chatbot are you interested in creating?"

  - stage: "trial_day_7"
    trigger: "user_signed_up"
    day_offset: 7
    personalization:
      tone: "encouraging, value-focused"
      focus: "success_stories, roi"
      cta: "schedule_demo_call"
      message_examples:
        - "You're halfway through your trial! Companies like yours see 40% cost reduction in month 1."
        - "Let's build something impactful together. Ready to see advanced features?"

  - stage: "trial_day_13"
    trigger: "user_signed_up"
    day_offset: 13
    personalization:
      tone: "urgent, conversion-focused"
      focus: "plan_comparison, easy_upgrade"
      cta: "upgrade_now"
      message_examples:
        - "Your trial ends in 24 hours. Upgrade now to keep your chatbots live!"
        - "Don't lose your progress! Click here to choose your plan."

  - stage: "active_month_6"
    trigger: "subscription_activated"
    day_offset: 180
    personalization:
      tone: "consultative, upsell"
      focus: "advanced_features, enterprise_benefits"
      cta: "upgrade_to_enterprise"
      message_examples:
        - "You're using 80% of your Professional plan. Unlock unlimited conversations with Enterprise."
        - "Ready to scale? Enterprise gives you API access, priority support, and custom integrations."

  - stage: "renewal_month_11"
    trigger: "subscription_activated"
    day_offset: 330
    personalization:
      tone: "grateful, value_reinforcement"
      focus: "impact_metrics, partnership"
      cta: "renew_early"
      message_examples:
        - "Amazing year together! You've automated 10,000 conversations and saved 200+ support hours."
        - "Let's plan 2026. Early renewal gets you 15% off + priority access to new features."
```

#### API Specification

**1. Evaluate Personalization**
```http
POST /api/v1/personalization/evaluate
Authorization: Bearer {platform_jwt}
Content-Type: application/json

Request Body:
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "product_type": "chatbot",
  "conversation_context": {
    "lifecycle_stage": "trial",
    "days_since_signup": 3,
    "previous_interactions": 7,
    "engagement_score": 0.72,
    "features_used": ["template_builder", "test_mode"],
    "support_tickets": 0
  },
  "message_intent": "greeting"  // greeting | feature_request | support | upsell
}

Response (200 OK):
{
  "cohort": "new_trial_users",
  "cohort_confidence": 0.94,
  "personalization_strategy": "educational_nurture",
  "recommended_modifications": {
    "tone": "educational, patient, encouraging",
    "features_to_highlight": ["template_library", "drag_drop_builder", "quick_start_guides"],
    "cta": "explore_demo_templates",
    "show_examples": true,
    "experiment_variant": "educational_helpful"
  },
  "system_prompt_override": "You are an enthusiastic guide helping new users discover chatbot capabilities. Use an educational, patient tone...",
  "response_templates": {
    "greeting": "Welcome back! Ready to continue building your chatbot?",
    "encouragement": "You're doing great! You've already explored templates and tested your bot."
  },
  "confidence": 0.89,
  "experiment_id": "greeting_optimization_trial_users",
  "variant_weight": 0.38,
  "cached": true,
  "cache_ttl": 300  // 5 minute cache
}
```

**2. Track Engagement Event**
```http
POST /api/v1/personalization/events
Authorization: Bearer {platform_jwt}
Content-Type: application/json

Request Body:
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "product_type": "voicebot",
  "event_type": "conversion",  // conversion | ctr | session_complete | feature_adopted | churn_signal
  "cohort": "active_power_users",
  "experiment_id": "greeting_optimization_trial_users",
  "variant_id": "educational_helpful",
  "context": {
    "session_duration": 420,  // seconds
    "messages_exchanged": 12,
    "cta_clicked": true,
    "feature_adopted": "api_integration"
  },
  "timestamp": "2025-10-15T14:30:00Z"
}

Response (202 Accepted):
{
  "event_id": "uuid",
  "status": "queued_for_processing",
  "variant_weight_will_update": true,
  "estimated_processing_time": "30 seconds"
}
```

**3. Get Cohort Assignment**
```http
GET /api/v1/personalization/cohorts/{user_id}
Authorization: Bearer {platform_jwt}
Query Parameters:
- organization_id: uuid

Response (200 OK):
{
  "user_id": "uuid",
  "organization_id": "uuid",
  "current_cohort": "new_trial_users",
  "lifecycle_stage": "trial",
  "cohort_assigned_at": "2025-10-12T10:00:00Z",
  "cohort_metadata": {
    "days_since_signup": 3,
    "engagement_level": "exploring",
    "feature_adoption_count": 2,
    "predicted_churn_risk": 0.15
  },
  "personalization_strategy": "educational_nurture",
  "active_experiments": [
    {
      "experiment_id": "greeting_optimization_trial_users",
      "variant_assigned": "educational_helpful",
      "assigned_at": "2025-10-12T10:00:00Z"
    }
  ]
}
```

**4. Create Experiment**
```http
POST /api/v1/personalization/experiments
Authorization: Bearer {platform_admin_jwt}
Content-Type: application/json

Request Body:
{
  "experiment_name": "CTA Optimization for At-Risk Users",
  "cohort_id": "at_risk_churners",
  "target_metric": "retention_rate",
  "secondary_metrics": ["session_duration", "support_ticket_resolution"],
  "variants": [
    {
      "variant_name": "discount_offer",
      "system_prompt_override": "Offer 20% renewal discount proactively. Emphasize partnership and support.",
      "initial_weight": 0.33
    },
    {
      "variant_name": "success_manager_intro",
      "system_prompt_override": "Introduce dedicated success manager. Offer personalized help and quarterly reviews.",
      "initial_weight": 0.33
    },
    {
      "variant_name": "feature_unlock",
      "system_prompt_override": "Unlock premium features temporarily. Show value through hands-on experience.",
      "initial_weight": 0.34
    }
  ],
  "min_sample_size": 500,
  "confidence_level": 0.95,
  "auto_promote_winner": false,  // Manual review required for high-value cohort
  "duration_days": 30
}

Response (201 Created):
{
  "experiment_id": "uuid",
  "status": "pending_approval",  // High-value cohort requires approval
  "estimated_sample_size": 180,
  "estimated_duration": "16 days",
  "approval_required_from": "platform_admin",
  "created_at": "2025-10-15T15:00:00Z"
}
```

**5. Get Experiment Results**
```http
GET /api/v1/personalization/experiments/{experiment_id}/results
Authorization: Bearer {platform_jwt}

Response (200 OK):
{
  "experiment_id": "uuid",
  "experiment_name": "greeting_optimization_trial_users",
  "cohort_id": "new_trial_users",
  "status": "completed",
  "winner": "educational_helpful",
  "statistical_significance": true,
  "confidence_level": 0.97,
  "started_at": "2025-10-01T00:00:00Z",
  "completed_at": "2025-10-14T18:00:00Z",
  "variants": [
    {
      "variant_id": "friendly_casual",
      "trials": 1543,
      "conversions": 1122,
      "conversion_rate": 0.727,
      "confidence_interval": [0.705, 0.749],
      "lift_vs_control": "+9.3%"
    },
    {
      "variant_id": "professional_direct",
      "trials": 987,
      "conversions": 658,
      "conversion_rate": 0.666,
      "confidence_interval": [0.636, 0.696],
      "lift_vs_control": "0% (control)"
    },
    {
      "variant_id": "educational_helpful",
      "trials": 2011,
      "conversions": 1587,
      "conversion_rate": 0.789,
      "confidence_interval": [0.769, 0.809],
      "lift_vs_control": "+18.5%",
      "winner": true
    },
    {
      "variant_id": "personalized_contextual",
      "trials": 421,
      "conversions": 298,
      "conversion_rate": 0.708,
      "confidence_interval": [0.665, 0.751],
      "lift_vs_control": "+6.3%"
    }
  ],
  "recommendation": "Promote 'educational_helpful' to default. Consider combining with 'personalized_contextual' elements."
}
```

#### Database Schema

```sql
-- Customer cohorts
CREATE TABLE customer_cohorts (
  cohort_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_name VARCHAR(100) NOT NULL,
  lifecycle_stage VARCHAR(50),  -- trial | active | at_risk | renewal
  filters JSONB NOT NULL,  -- Cohort membership criteria
  personalization_strategy VARCHAR(100),
  size_estimate INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  active BOOLEAN DEFAULT true
);

-- User cohort assignments (real-time)
CREATE TABLE user_cohort_assignments (
  assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  cohort_id UUID NOT NULL,
  lifecycle_stage VARCHAR(50),
  assigned_at TIMESTAMP DEFAULT NOW(),
  cohort_metadata JSONB,  // Engagement scores, feature adoption, etc.
  INDEX idx_user_cohort (user_id, assigned_at DESC),
  INDEX idx_org_cohort (organization_id, cohort_id),
  FOREIGN KEY (cohort_id) REFERENCES customer_cohorts(cohort_id)
);

-- Personalization rules
CREATE TABLE personalization_rules (
  rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cohort_id UUID,
  trigger_condition TEXT,  -- SQL-like condition
  modifications JSONB NOT NULL,  // System prompt overrides, feature highlights, etc.
  priority INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_cohort_rules (cohort_id, priority),
  FOREIGN KEY (cohort_id) REFERENCES customer_cohorts(cohort_id)
);

-- Experiments
CREATE TABLE personalization_experiments (
  experiment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  experiment_name VARCHAR(200) NOT NULL,
  cohort_id UUID NOT NULL,
  target_metric VARCHAR(100),
  secondary_metrics JSONB,
  min_sample_size INTEGER,
  confidence_level DECIMAL(3,2),
  optimization_algorithm VARCHAR(50) DEFAULT 'thompson_sampling',
  auto_promote_winner BOOLEAN DEFAULT false,
  status VARCHAR(50),  -- draft | pending_approval | running | completed | cancelled
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  created_by UUID,
  INDEX idx_experiment_status (status, started_at),
  FOREIGN KEY (cohort_id) REFERENCES customer_cohorts(cohort_id)
);

-- Experiment variants
CREATE TABLE experiment_variants (
  variant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  experiment_id UUID NOT NULL,
  variant_name VARCHAR(100),
  system_prompt_override TEXT,
  response_templates JSONB,
  initial_weight DECIMAL(5,4),
  current_weight DECIMAL(5,4),
  trials INTEGER DEFAULT 0,
  conversions INTEGER DEFAULT 0,
  conversion_rate DECIMAL(5,4),
  INDEX idx_experiment_variants (experiment_id),
  FOREIGN KEY (experiment_id) REFERENCES personalization_experiments(experiment_id)
);

-- Engagement events (time-series in ClickHouse for performance)
-- PostgreSQL stores aggregated summaries only
CREATE TABLE engagement_event_summary (
  summary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  experiment_id UUID,
  variant_id UUID,
  cohort_id UUID,
  date DATE NOT NULL,
  hour INTEGER,  -- 0-23 for hourly aggregation
  event_type VARCHAR(50),
  event_count INTEGER,
  total_conversions INTEGER,
  avg_session_duration DECIMAL(10,2),
  INDEX idx_experiment_summary (experiment_id, date, hour),
  FOREIGN KEY (experiment_id) REFERENCES personalization_experiments(experiment_id)
);

-- Individual user preferences (learned over time)
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY,
  organization_id UUID NOT NULL,
  preference_vector VECTOR(384),  // Embedding for collaborative filtering
  learned_preferences JSONB,  // Explicit preferences (tone, verbosity, etc.)
  last_updated TIMESTAMP DEFAULT NOW(),
  INDEX idx_org_users (organization_id)
);
```

#### Integration with Agent Orchestration & Voice Agent

**Modified Agent Workflow (with Personalization):**

```python
# In Agent Orchestration Service (Service 8) - Before generating response

async def generate_response(user_id, organization_id, message, config):
    # 1. Fetch personalization context
    personalization = await personalization_engine.evaluate(
        user_id=user_id,
        organization_id=organization_id,
        product_type="chatbot",
        conversation_context={
            "lifecycle_stage": get_lifecycle_stage(user_id),
            "days_since_signup": get_days_since_signup(user_id),
            "engagement_score": get_engagement_score(user_id)
        },
        message_intent=classify_intent(message)
    )

    # 2. Apply personalization overrides
    if personalization:
        # Override system prompt dynamically
        system_prompt = personalization.system_prompt_override or config.system_prompt

        # Filter/prioritize tools based on cohort
        available_tools = filter_tools_by_cohort(
            all_tools=config.tools,
            cohort=personalization.cohort
        )

        # Inject personalized response templates
        response_templates = personalization.response_templates
    else:
        # Use base config
        system_prompt = config.system_prompt
        available_tools = config.tools
        response_templates = {}

    # 3. Generate response with personalized context
    response = await llm_gateway.generate(
        system_prompt=system_prompt,
        user_message=message,
        tools=available_tools,
        response_templates=response_templates
    )

    # 4. Track engagement event for experiment optimization
    if personalization and personalization.experiment_id:
        await personalization_engine.track_event(
            user_id=user_id,
            event_type="message_generated",
            experiment_id=personalization.experiment_id,
            variant_id=personalization.variant_id,
            context={"response_length": len(response)}
        )

    return response
```

#### Stakeholders and Agents

**Human Stakeholders:**

1. **Marketing Manager (Client)**
   - Role: Defines lifecycle campaigns, reviews experiment results
   - Access: Experiment dashboard, cohort analytics
   - Permissions: create:experiments, read:analytics, approve:high_value_cohorts
   - Workflows: Creates A/B tests for messaging, reviews performance, adjusts cohort strategies

2. **Customer Success Manager (Platform)**
   - Role: Monitors cohort health, identifies at-risk customers
   - Access: Cohort assignments, lifecycle stage transitions
   - Permissions: read:all_cohorts, create:retention_campaigns, update:lifecycle_stages
   - Workflows: Reviews at-risk cohort daily, launches retention experiments, coordinates with sales

**AI Agents:**

1. **Cohort Assignment Agent**
   - Responsibility: Assigns users to cohorts based on behavior, updates assignments in real-time
   - Tools: Behavioral clustering algorithms, engagement scoring models
   - Autonomy: Fully autonomous cohort assignment
   - Escalation: None

2. **Experiment Optimization Agent**
   - Responsibility: Adjusts variant weights using Thompson Sampling, promotes winners automatically
   - Tools: Multi-armed bandit algorithms, statistical significance testing
   - Autonomy: Autonomous weight adjustment, approval required for winner promotion in high-value cohorts
   - Escalation: Marketing Manager approval for promoting experiment winners

**Approval Workflows:**
1. Standard experiments (trial users) → Auto-approved
2. High-value cohort experiments (enterprise customers) → Marketing Manager approval required
3. Winner promotion (trial users) → Auto-promoted when significant
4. Winner promotion (high-value cohorts) → Marketing Manager approval required

---

## Inter-Service Communication Patterns

### Event-Driven (Primary)

**Kafka Topics:**
- `auth_events`: User signed up, email verified, user logged in, password reset, assisted account created, assisted account claimed, claim link sent, claim link resent, assisted account expired, assisted account access granted, account ownership transferred
- `org_events`: Organization created, member invited, member joined, member removed, role updated, config permissions updated
- `agent_events`: Agent registered, client assigned to agent, handoff initiated, handoff accepted, handoff rejected, specialist invited, specialist joined, specialist handoff back, agent status updated, agent availability changed, workload redistributed
- `collaboration_events`: Help requested, agent joined session, canvas edited, collaboration ended
- `client_events`: Research completed, NDA signed, pilot agreed
- `demo_events`: Demo generated, approved, failed
- `prd_events`: PRD created, approved, updated, feedback received
- `config_events`: Config generated, deployed, hot-reloaded, config updated by client, config rollback, config version compared, config preview generated, config branch created
- `conversation_events`: Started, escalated, completed
- `voice_events`: Call initiated, transferred, ended
- `cross_product_events`: Voicebot paused, chatbot paused, image processed, data shared
- `analytics_events`: KPIs calculated, experiments completed
- `monitoring_events`: Incidents created, resolved
- `escalation_events`: Human handoff triggered
- `outreach_events`: Email sent, email opened, email clicked, manual ticket created
- `research_events`: Research started, research completed, research failed
- `personalization_events`: Cohort assigned, experiment variant assigned, engagement tracked, message variant performance updated

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

### cross_product_events

**Producers:** Agent Orchestration Service (chatbot), Voice Agent Service (voicebot)
**Consumers:** Agent Orchestration Service (chatbot), Voice Agent Service (voicebot)

**Purpose:** Enables coordination between chatbot and voicebot products when both are active for the same user session.

**Event Types:**

1. **voicebot_session_started**
```json
{
  "event_type": "voicebot_session_started",
  "call_id": "uuid",
  "user_id": "uuid",
  "organization_id": "uuid",
  "phone_number": "+15551234567",
  "config_id": "uuid",
  "timestamp": "2025-10-11T11:00:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration (chatbot): Pause conversational responses, enter silent processing mode
- Analytics: Track multi-channel engagement

2. **voicebot_session_ended**
```json
{
  "event_type": "voicebot_session_ended",
  "call_id": "uuid",
  "user_id": "uuid",
  "organization_id": "uuid",
  "duration_seconds": 295,
  "timestamp": "2025-10-11T11:05:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration (chatbot): Resume conversational responses if chatbot session active
- Analytics: Calculate session overlap metrics

3. **chatbot_image_processed**
```json
{
  "event_type": "chatbot_image_processed",
  "conversation_id": "uuid",
  "user_id": "uuid",
  "organization_id": "uuid",
  "image_type": "medical_prescription",
  "extracted_data": {
    "medication_name": "Amoxicillin",
    "dosage": "500mg",
    "frequency": "3 times daily",
    "prescribing_doctor": "Dr. Sarah Johnson",
    "prescription_date": "2025-10-11"
  },
  "processing_latency_ms": 1250,
  "timestamp": "2025-10-11T11:02:30Z"
}
```
**Consumer Actions:**
- Voice Agent Service: Incorporate extracted data into voice conversation context
- Voicebot responds: "I see you've uploaded a prescription for Amoxicillin 500mg, 3 times daily from Dr. Sarah Johnson. Would you like me to help you with a refill?"

4. **chatbot_data_shared**
```json
{
  "event_type": "chatbot_data_shared",
  "conversation_id": "uuid",
  "user_id": "uuid",
  "organization_id": "uuid",
  "data_type": "form_submission",
  "shared_data": {
    "field_1": "value_1",
    "field_2": "value_2"
  },
  "timestamp": "2025-10-11T11:03:00Z"
}
```
**Consumer Actions:**
- Voice Agent Service: Access shared form data during voice call

**Use Case Example: Medical Prescription During Voice Call**

**Scenario:** User is on voice call with healthcare voicebot, uploads prescription image via chatbot widget

**Flow:**
1. Voicebot active (voicebot_session_started published)
2. Chatbot receives image upload
3. Chatbot processes image silently (OCR + LLM parsing)
4. Chatbot publishes chatbot_image_processed with extracted prescription data
5. Voicebot receives event, adds data to conversation context
6. Voicebot continues call: "I see you've uploaded a prescription for Amoxicillin 500mg..."
7. Chatbot does NOT send conversational response (remains in silent mode until voicebot_session_ended)

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
- **Pricing Model Generator: Trigger pricing calculation** (NEW WORKFLOW - CRITICAL FLOW)
- Analytics: Track PRD approval rate
- Note: Automation Engine now triggers on proposal_signed event (not prd_approved)

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
  "product_type": "chatbot",
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
  "product_type": "chatbot",
  "updated_by": "github_issue_closed_webhook",
  "changes": ["tool_attached:initiate_refund"],
  "hot_reload_required": true,
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- **Agent Orchestration: Hot-reload config for active sessions** (CRITICAL FLOW)
- **Voice Agent: Hot-reload config for new calls** (CRITICAL FLOW)

3. **client_config_change_requested** (NEW)
```json
{
  "event_type": "client_config_change_requested",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "chatbot",
  "change_type": "system_prompt",
  "requested_by_user_id": "uuid",
  "request_source": "conversational_ai",
  "change_classification": {
    "type": "system_prompt_change",
    "confidence": 0.92,
    "detected_changes": [
      {
        "field": "system_prompt",
        "old_value": "You are a helpful assistant...",
        "new_value": "You are a casual and friendly assistant..."
      }
    ]
  },
  "risk_level": "low",
  "approval_required": false,
  "timestamp": "2025-10-20T11:00:00Z"
}
```
**Consumer Actions:**
- Configuration Management: Process change and create new version
- Client Configuration Portal: Update UI status

4. **client_config_change_applied** (NEW)
```json
{
  "event_type": "client_config_change_applied",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "voicebot",
  "version": "v5",
  "change_type": "voice_parameter_change",
  "applied_by_user_id": "uuid",
  "commit_message": "Increased voice speed for better user experience",
  "changes_summary": ["voice_config.speed: 1.0 → 1.2"],
  "hot_reload_triggered": true,
  "timestamp": "2025-10-20T11:05:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration/Voice Agent: Hot-reload with new config version
- Analytics: Track client self-service configuration changes

5. **config_rollback** (ENHANCED)
```json
{
  "event_type": "config_rollback",
  "config_id": "uuid",
  "product_type": "chatbot",
  "organization_id": "uuid",
  "from_version": 4,
  "to_version": 3,
  "reason": "high_error_rate",
  "initiated_by": "client_user",
  "initiated_by_user_id": "uuid",
  "timestamp": "2025-10-20T11:00:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration/Voice Agent: Hot-reload to previous version
- Monitoring: Alert on client-initiated rollbacks (indicates issue)

6. **config_preview_generated** (NEW)
```json
{
  "event_type": "config_preview_generated",
  "preview_id": "uuid",
  "config_id": "uuid",
  "organization_id": "uuid",
  "product_type": "chatbot",
  "sandbox_url": "wss://sandbox.workflow.ai/preview/uuid",
  "expires_at": "2025-10-20T12:00:00Z",
  "created_by_user_id": "uuid",
  "timestamp": "2025-10-20T11:00:00Z"
}
```
**Consumer Actions:**
- Client Configuration Portal: Provide sandbox testing link to client

7. **config_branch_created** (NEW)
```json
{
  "event_type": "config_branch_created",
  "branch_id": "uuid",
  "config_id": "uuid",
  "organization_id": "uuid",
  "branch_name": "staging",
  "base_version": 4,
  "created_by_user_id": "uuid",
  "description": "Testing new empathy-focused prompts",
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- Configuration Management: Track branch lifecycle
- Analytics: Monitor branch usage patterns

---

### org_events (ENHANCED)

**Producers:** Organization Management & Authentication Service
**Consumers:** Analytics Service, Monitoring Engine, Client Configuration Portal Service

**Event Types (existing events not shown, only new additions):**

8. **member_config_permissions_updated** (NEW)
```json
{
  "event_type": "member_config_permissions_updated",
  "organization_id": "uuid",
  "user_id": "uuid",
  "updated_by": "uuid",
  "old_permissions": {
    "can_view_configs": true,
    "can_edit_system_prompt": false,
    "max_risk_level": "low"
  },
  "new_permissions": {
    "can_view_configs": true,
    "can_edit_system_prompt": true,
    "can_edit_voice_params": true,
    "can_rollback_versions": true,
    "max_risk_level": "medium"
  },
  "timestamp": "2025-10-20T11:00:00Z"
}
```
**Consumer Actions:**
- Client Configuration Portal: Update permission checks for user
- Analytics: Track permission change patterns

---

### personalization_events (NEW)

**Producers:** Hyperpersonalization Engine (Service 20)
**Consumers:** Agent Orchestration Service, Analytics Service, Monitoring Engine

**Event Types:**

1. **user_cohort_assigned**
```json
{
  "event_type": "user_cohort_assigned",
  "user_id": "uuid",
  "organization_id": "uuid",
  "cohort_id": "active_power_users",
  "lifecycle_stage": "active",
  "assignment_reason": "monthly_usage_threshold_exceeded",
  "previous_cohort": "new_trial_users",
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration: Apply cohort-specific system prompt overrides
- Analytics: Track cohort transitions

2. **experiment_variant_assigned**
```json
{
  "event_type": "experiment_variant_assigned",
  "user_id": "uuid",
  "organization_id": "uuid",
  "experiment_id": "uuid",
  "variant_id": "v3",
  "variant_name": "empathetic_tone",
  "assignment_algorithm": "thompson_sampling",
  "expected_reward": 0.78,
  "timestamp": "2025-10-20T10:00:00Z"
}
```
**Consumer Actions:**
- Agent Orchestration: Use variant-specific message template
- Analytics: Track variant performance

3. **engagement_event_tracked**
```json
{
  "event_type": "engagement_event_tracked",
  "user_id": "uuid",
  "organization_id": "uuid",
  "experiment_id": "uuid",
  "variant_id": "v3",
  "event_type_detail": "message_sent",
  "engagement_metrics": {
    "click_through": true,
    "session_duration_seconds": 180,
    "conversion": false
  },
  "timestamp": "2025-10-20T10:05:00Z"
}
```
**Consumer Actions:**
- Hyperpersonalization Engine: Update variant weights with Thompson Sampling
- Analytics: Calculate experiment lift

4. **message_variant_performance_updated**
```json
{
  "event_type": "message_variant_performance_updated",
  "experiment_id": "uuid",
  "variant_id": "v3",
  "organization_id": "uuid",
  "performance_metrics": {
    "total_impressions": 1500,
    "click_through_rate": 0.23,
    "conversion_rate": 0.08,
    "average_session_duration": 165
  },
  "weight_updated": {
    "old_weight": 0.15,
    "new_weight": 0.22
  },
  "timestamp": "2025-10-20T11:00:00Z"
}
```
**Consumer Actions:**
- Analytics: Display experiment performance dashboard
- Monitoring: Alert if variant performance degrades

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

3. **requirements_draft_generated** (NEW)
```json
{
  "event_type": "requirements_draft_generated",
  "draft_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "research_job_id": "uuid",
  "research_summary": "Based on our research, Acme Corp is an e-commerce business...",
  "predicted_volumes": {
    "chat_volume_monthly": 1400,
    "call_volume_monthly": 450,
    "confidence_score": 0.85
  },
  "recommended_services": {
    "chatbot_types": ["Website chatbot", "WhatsApp chatbot"],
    "voicebot_types": ["Phone call (inbound/outbound)"]
  },
  "assigned_reviewer": "sales_agent_uuid",
  "timestamp": "2025-10-06T10:00:00Z"
}
```
**Consumer Actions:**
- Human Agent Management: Create review task in sales agent's queue
- Analytics: Track draft generation time from research completion

4. **requirements_draft_approved** (NEW)
```json
{
  "event_type": "requirements_draft_approved",
  "draft_id": "uuid",
  "form_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "approved_by": "sales_agent_uuid",
  "approved_at": "2025-10-06T11:00:00Z",
  "modifications_made": true,
  "sent_to_client": true,
  "timestamp": "2025-10-06T11:00:00Z"
}
```
**Consumer Actions:**
- Analytics: Track approval time, modification rate
- Monitoring: Track draft-to-send conversion rate

5. **requirements_form_sent** (NEW)
```json
{
  "event_type": "requirements_form_sent",
  "form_id": "uuid",
  "draft_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "recipient_email": "client@example.com",
  "research_job_id": "uuid",
  "sent_at": "2025-10-06T11:00:00Z",
  "expires_at": "2025-10-09T11:00:00Z",
  "timestamp": "2025-10-06T11:00:00Z"
}
```
**Consumer Actions:**
- Analytics: Track form delivery and completion rates
- Monitoring: Alert if form not completed within 72 hours

---

### client_events (UPDATED)

**Producers:** Organization Management, PRD Builder, Demo Generator
**Consumers:** Analytics Service, Human Agent Management Service

**Event Types:**

1. **requirements_validation_completed** (NEW - replaces requirements_form_completed)
```json
{
  "event_type": "requirements_validation_completed",
  "form_id": "uuid",
  "draft_id": "uuid",
  "client_id": "uuid",
  "organization_id": "uuid",
  "validation_response": {
    "research_findings_accurate": true,
    "volume_corrections": {
      "chat_volume": 1200,
      "call_volume": 450
    },
    "service_confirmations": {
      "chatbot_types": ["Website chatbot (chat widget)", "WhatsApp chatbot"],
      "voicebot_types": ["Phone call (inbound/outbound)"]
    },
    "additional_requirements": "Need Zendesk integration and Spanish language support.",
    "corrections_needed": "Evening traffic is higher - need 24/7 coverage prioritized."
  },
  "discrepancy_analysis": {
    "chat_volume_discrepancy": -14.3,
    "call_volume_discrepancy": 0,
    "flags_for_review": []
  },
  "timestamp": "2025-10-06T14:30:00Z"
}
```
**Consumer Actions:**
- **Demo Generator**: Use confirmed requirements and additional_requirements to generate demo (PRIMARY TRIGGER)
- PRD Builder: Use validated volumes and service confirmations for technical requirements
- Pricing Model Generator: Use corrected volumes for tier recommendations
- Human Agent Management: Create review task if flags_for_review not empty or corrections_needed present

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
AI Generates Requirements Draft → requirements_draft_generated event
  ↓
Human Agent Reviews/Approves Draft → requirements_draft_approved event
  ↓
Requirements Form Sent to Client → requirements_form_sent event
  ↓
Client Validates Research Findings → requirements_validation_completed event
  ↓
Outbound Email (if needed) → email_sent OR manual_outreach_ticket_created event
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
PRD Builder (with collaboration support) → prd_approved event
  ↓
Pricing Model Generator → pricing_generated event
  ↓
Proposal Generator → proposal_generated event
  ↓
Client Signs Proposal → proposal_signed event
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
AI Generates Requirements Draft → requirements_draft_generated event
  ↓
Sales Agent Reviews/Approves Draft → requirements_draft_approved event
  ↓
Requirements Form Sent to Client → requirements_form_sent event
  ↓
Client Validates Research Findings → requirements_validation_completed event
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
PRD Builder (AI-driven, Sales Agent collaborates when needed) → prd_approved event
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
**Phase 6 (Months 21-24):** Client Self-Service & Personalization (Client Configuration Portal, Hyperpersonalization Engine)

#### Phase 6 Detailed Sprint Plan (Months 21-24)

**Sprint 21 (Weeks 81-82): Client Configuration Portal - Foundation**
- Database schema: config_change_log, organization_member_config_permissions, config_permission_matrix
- Organization Management API enhancements for config permissions
- Basic permission validation middleware
- Success criteria: Admin can assign config permissions to team members

**Sprint 22 (Weeks 83-84): Conversational Configuration Agent**
- LangGraph two-node configuration agent implementation
- Change classification model (system_prompt, tool, voice_param, integration, escalation_rule)
- Tool implementations: classify_configuration_request, generate_system_prompt_update, search_available_tools
- Success criteria: Agent can classify and apply simple system prompt changes via chat

**Sprint 23 (Weeks 85-86): Visual Configuration Dashboard**
- React components: ConfigurationDashboard, ChatbotConfigPanel, VoicebotConfigPanel
- Voice parameter controls matching UI images (speed, clarity, stop speaking plan)
- Real-time config preview generation
- Success criteria: Client can visually adjust voicebot parameters and see instant preview

**Sprint 24 (Weeks 87-88): Version Control & Rollback**
- Git-style versioning with commit messages
- Config diff visualization (visual_diff_url generation)
- Rollback API with client permission support
- Branch management (dev/staging/prod)
- Success criteria: Client can rollback to previous config version with one click

**Sprint 25 (Weeks 89-90): Config Preview & Testing**
- Sandbox environment for config testing (1-hour expiry)
- WebSocket preview sessions
- Test scenario execution
- Config validation before deployment
- Success criteria: Client can test config changes in sandbox before applying to production

**Sprint 26 (Weeks 91-92): Hyperpersonalization Engine - Cohort Management**
- Database schema: customer_cohorts, cohort_rules, cohort_assignments
- Cohort segmentation logic (trial, active, at-risk, renewal)
- Lifecycle stage automation (day 1, day 7, day 13, month 6, month 11)
- Success criteria: Users automatically assigned to cohorts based on behavior

**Sprint 27 (Weeks 93-94): Multi-Armed Bandit Experimentation**
- Thompson Sampling algorithm implementation
- Experiment framework: variant creation, assignment, tracking
- A/B/N testing support (50-100 message variants)
- Real-time weight optimization based on engagement
- Success criteria: System automatically optimizes message variants based on CTR

**Sprint 28 (Weeks 95-96): Personalization Integration**
- Agent Orchestration Service integration (fetch cohort context before response)
- Dynamic system prompt overrides per cohort
- Response template injection based on experiment assignment
- Engagement event tracking
- Success criteria: Chatbot applies personalized system prompts based on user cohort

**Sprint 29 (Weeks 97-98): Client Config Event System**
- Kafka event schemas: client_config_change_requested, client_config_change_applied
- Hot-reload integration with client-initiated changes
- Config change audit trail
- Risk-based approval workflows (low/medium/high)
- Success criteria: Client config changes trigger hot-reload without service restart

**Sprint 30 (Weeks 99-100): Human Agent Coordination**
- Config help request system (complex changes escalate to support)
- Agent assistance chat interface
- Automated GitHub ticket creation for new tool requests
- Success criteria: Complex config requests automatically create support tickets

**Sprint 31 (Weeks 101-102): Analytics & Monitoring**
- Client self-service config change metrics
- Experiment performance dashboards (CTR, conversion, session duration)
- Cohort transition analytics
- Rollback rate monitoring
- Success criteria: Platform team can monitor client config health and experiment lift

**Sprint 32 (Weeks 103-104): Production Hardening & Documentation**
- Load testing: 1000+ concurrent config changes
- Security review: permission enforcement, SQL injection prevention
- API documentation for Client Configuration Portal
- Client training materials and video tutorials
- Success criteria: 500+ clients can self-configure without platform support

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

**Client Self-Service (Phase 6):**
- 80% of config changes done by clients without platform support
- <5 minutes average time for config change (request → applied)
- 95% config change success rate (no rollbacks needed)
- 30% improvement in engagement metrics via personalization
- 50+ A/B experiments running concurrently per organization

### Technical Debt Prevention

1. **Service Ownership:** Each service has a dedicated engineering team
2. **API Contracts:** OpenAPI specs, contract testing (Pact)
3. **Observability:** Comprehensive logging, tracing, metrics from day one
4. **Documentation:** Auto-generated API docs, architecture decision records (ADRs)
5. **Code Quality:** Pre-commit hooks, test coverage >80%, security scanning

---

**This completes the comprehensive microservices architecture specification for the Complete Workflow Automation System.**
