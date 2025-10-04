# Workflow Automation System - Technical Architecture Document

**Version**: 1.0
**Date**: October 2025
**Primary Cloud Provider**: Google Cloud Platform (GCP)
**Primary LLMs**: Gemini 2.5 Pro (reasoning) + Gemini 2.5 Flash (speed)

---

## Executive Summary

This document defines the production-ready technical architecture for an AI-powered workflow automation platform that automates customer sales and support across voice and chat channels. The architecture is designed to scale from prototype to enterprise production with 10,000+ concurrent users while maintaining cost efficiency and reliability.

### Key Architectural Decisions

**1. Agentic Framework: LangGraph**
- **Rationale**: Production-proven at LinkedIn, Uber, Elastic with 400+ companies deployed at scale
- **Benefits**: Stateful workflows, checkpoint-based fault tolerance, O(1) scaling on history length
- **Trade-offs**: Steeper learning curve vs higher-level abstractions, but doesn't require scaling off it

**2. Primary LLM Stack: Gemini 2.5 Pro + Flash**
- **Rationale**: Google's best-in-class price-performance with controllable thinking budget
- **Benefits**: First Flash model with thinking capabilities, 2M token context window, multimodal support
- **Trade-offs**: GCP vendor lock-in mitigated by LLM abstraction layer for multi-provider support

**3. Voice Infrastructure: LiveKit Server + SIP**
- **Rationale**: Maximum architectural control with distributed mesh supporting millions of concurrent users
- **Benefits**: Self-hosted or cloud deployment, comprehensive SIP integration, sub-500ms latency achievable
- **Trade-offs**: More operational complexity vs turnkey solutions (Retell AI, Vapi) but offers flexibility

**4. Knowledge Retrieval: Hybrid GraphRAG (Qdrant + Neo4j)**
- **Rationale**: 35% accuracy improvement over vector-only retrieval for relationship-heavy queries
- **Benefits**: Qdrant (4× performance gains) + Neo4j (entity reasoning) = optimal precision + recall
- **Trade-offs**: Higher computational cost justified by query quality requirements

**5. Multi-Tenancy: Payload-Based Partitioning**
- **Rationale**: Single collection approach scales to vast numbers of tenants with minimal overhead
- **Benefits**: Qdrant `is_tenant=true` co-locates tenant data for performance
- **Trade-offs**: Global queries slower, but per-tenant queries significantly faster

### Expected Benefits

- **95% automation rate** for customer sales and support workflows within 12 months
- **80% cost reduction** from $13/call to $2-3/call for voice interactions (Sierra AI benchmark)
- **Sub-500ms voice latency** with optimized LiveKit + Gemini integration
- **Horizontal scalability** from day one with event-driven microservices
- **35% cost savings** through semantic caching and model routing
- **99.9% uptime SLA** with multi-region GCP deployment

---

## System Architecture

### Microservices Breakdown

The architecture follows event-driven microservices with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kong API Gateway (GCP)                        │
│              Rate Limiting │ Auth │ LLM Routing                  │
└────────────────┬────────────────────────────────────────────────┘
                 │
      ┌──────────┴──────────┬──────────┬──────────┬──────────┐
      │                     │          │          │          │
┌─────▼──────┐  ┌──────────▼───┐ ┌────▼────┐ ┌──▼──────┐ ┌▼──────────┐
│ Agent      │  │ Voice Agent  │ │ RAG     │ │ LLM     │ │ Config    │
│ Orchestr.  │  │ Service      │ │ Pipeline│ │ Gateway │ │ Service   │
│ (LangGraph)│  │ (LiveKit)    │ │ Service │ │ Service │ │ (Go)      │
└─────┬──────┘  └──────┬───────┘ └────┬────┘ └──┬──────┘ └┬──────────┘
      │                │               │         │          │
      └────────┬───────┴───────┬───────┴─────────┴──────────┘
               │               │
       ┌───────▼────────┐  ┌──▼─────────────────┐
       │ Kafka Event    │  │  Redis Cache       │
       │ Stream (GCP)   │  │  (Memorystore)     │
       └───────┬────────┘  └────────────────────┘
               │
      ┌────────┴─────────┬──────────┬──────────┬──────────┐
      │                  │          │          │          │
┌─────▼──────┐  ┌───────▼────┐ ┌──▼──────┐ ┌─▼────────┐ ┌▼──────────┐
│ PRD Gen    │  │ Analytics  │ │ CRM     │ │ Customer │ │ Monitoring│
│ Service    │  │ Service    │ │ Integr. │ │ Success  │ │ Engine    │
└────────────┘  └────────────┘ └─────────┘ └──────────┘ └───────────┘
      │                │            │             │           │
      └────────────────┴────────────┴─────────────┴───────────┘
                                   │
                    ┌──────────────┴───────────────┐
                    │                              │
          ┌─────────▼──────────┐      ┌───────────▼──────────┐
          │ Supabase PostgreSQL│      │ Qdrant + Neo4j       │
          │ (RLS Multi-tenant) │      │ (Hybrid GraphRAG)    │
          └────────────────────┘      └──────────────────────┘
```

### Service Communication Patterns

**Synchronous (gRPC):**
- LLM Gateway ↔ Agent Orchestration (real-time inference)
- Voice Agent ↔ LLM Gateway (sub-500ms latency requirement)
- API Gateway ↔ User-facing services (REST fallback for client compatibility)

**Asynchronous (Kafka):**
- Agent decisions → Analytics Service
- Tool results → Agent Orchestration
- Configuration updates → All services
- CRM events → Agent workflows

**Caching Layer (Redis):**
- LLM response caching (20-30% cost savings)
- Session state (conversation context)
- Rate limit counters (distributed quota enforcement)

### Data Flow: Customer Interaction Example

```
1. Customer message arrives → Kong API Gateway
2. Gateway routes to Agent Orchestration Service
3. Agent Orchestration:
   a. Retrieves conversation state from Redis
   b. Fetches relevant knowledge from RAG Pipeline
   c. Calls LLM Gateway with context
4. LLM Gateway:
   a. Checks semantic cache (Redis)
   b. If miss, routes to Gemini 2.5 Flash/Pro
   c. Streams response back
5. Agent Orchestration:
   a. Executes tools if needed (create_order, check_status)
   b. Publishes agent_decision event to Kafka
   c. Saves checkpoint to PostgreSQL
6. Response streamed to customer via WebSocket
7. Analytics Service consumes Kafka event for metrics
```

---

## Technology Stack Detailed

### 1. Agentic Framework: LangGraph

**Version**: 0.6.0+ (2025 production release)
**Language**: Python (primary), TypeScript (Node.js support)

**Architecture Pattern**:
```python
# Agent Node + Tools Node Graph
from langgraph.graph import StateGraph, END
from langgraph.checkpoint.postgres import PostgresSaver

# Define state
class HealthcareState(TypedDict):
    messages: List[BaseMessage]
    tools_executed: List[str]
    customer_context: Dict

# Build graph
workflow = StateGraph(HealthcareState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tools_node)
workflow.add_conditional_edges("agent", should_continue)
workflow.set_entry_point("agent")

# PostgreSQL checkpointer for fault tolerance
checkpointer = PostgresSaver.from_conn_string(DATABASE_URL)
app = workflow.compile(checkpointer=checkpointer)
```

**Key Features Utilized**:
- **Checkpoint-based recovery**: Conversations persist across sessions, resilient to failures
- **Parallel execution**: Map-reduce patterns for multi-agent workflows (PRD generation)
- **Human-in-the-loop**: Interrupt patterns for approval workflows (payment confirmation)
- **Supervisor patterns**: Lead agent spawns 3-5 specialist subagents for complex queries
- **LangGraph Platform**: 1-click deploy option with integrated LangSmith observability

**Deployment Options**:
- **Self-hosted on GKE**: Full control, custom scaling policies
- **LangGraph Cloud**: Managed deployment with auto-scaling

**Why Not Alternatives**:
- **CrewAI**: Less production maturity, limited checkpoint functionality
- **AutoGen**: Less fine-grained control, harder to debug complex flows
- **Custom**: Reinventing solved problems (state management, recovery, observability)

### 2. LLM Gateway Service

**Primary Models**:
- **Gemini 2.5 Flash**: Large-scale processing, low-latency, high-volume tasks (chatbots, simple queries)
- **Gemini 2.5 Pro**: Complex reasoning, thinking capabilities for PRD generation and decision-making

**Gateway Architecture** (Python/FastAPI):

```python
class LLMGateway:
    """Unified abstraction for multiple LLM providers"""

    def __init__(self):
        self.providers = {
            "gemini": GeminiProvider(),
            "openai": OpenAIProvider(),
            "claude": ClaudeProvider(),
            "llama": LlamaProvider()
        }
        self.cache = SemanticCache(redis_client)
        self.circuit_breaker = CircuitBreaker()

    async def chat_completion(
        self,
        messages: List[Dict],
        model: str = "gemini-2.5-flash",
        stream: bool = True
    ):
        # Check semantic cache
        cache_key = self.cache.generate_key(messages, model)
        if cached := await self.cache.get(cache_key):
            return cached

        # Route based on complexity classifier
        provider = self.route_to_provider(messages, model)

        # Circuit breaker pattern for failover
        try:
            response = await self.circuit_breaker.call(
                provider.chat_completion,
                messages=messages,
                stream=stream
            )
        except ProviderError:
            # Failover to alternative provider
            response = await self.failover_provider.chat_completion(...)

        # Cache response
        await self.cache.set(cache_key, response, ttl=3600)
        return response
```

**Features**:
- **Model Routing**: Simple queries → Flash ($0.075/1M input tokens), Complex → Pro ($1.25/1M)
- **Semantic Caching**: 20-30% cost reduction via vector similarity matching
- **Circuit Breaker**: Auto-failover Gemini → Claude Opus if provider issues
- **Rate Limiting**: Exponential backoff, respects provider quotas
- **Observability**: Helicone proxy integration (50-80ms overhead)

**Cost Optimization**:
```python
def classify_query_complexity(messages: List[Dict]) -> str:
    """Route to appropriate model based on complexity"""
    # Heuristics: query length, tool requirements, conversation history
    if len(messages) > 20 or requires_reasoning(messages):
        return "gemini-2.5-pro"
    return "gemini-2.5-flash"
```

**Gemini Integration Best Practices**:
- **Thinking Budget**: Configure controllable reasoning budget for Flash model
- **Multimodal Support**: Process images, audio, video with 2M token context
- **Back-off Strategy**: Delay requests after rejection to avoid temporary blocking
- **SDK**: Use official `google-genai` Python SDK for easier integration

### 3. RAG Pipeline Service

**Architecture**: Hybrid GraphRAG (Qdrant + Neo4j)

**When to Use GraphRAG vs Standard RAG**:
- **GraphRAG**: Entity-relationship queries, multi-document reasoning, "explain connections"
- **Standard RAG**: Simple factual lookups, single-document answers, FAQ-style queries

**Document Processing Pipeline**:

```
Ingest → SPLICE Chunking → Embedding Generation → Dual Storage
   │            │                    │                    │
   │            │                    │                    └─→ Vectors (Qdrant)
   │            │                    └──────────────────────→ Entities (Neo4j)
   │            └─────────────────────→ 27% precision improvement
   └──────────────────────────────────→ PDF, docs, chat transcripts
```

**Qdrant Configuration** (Vector Search):

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PayloadSchemaType

client = QdrantClient(url="qdrant-cluster.gcp.example.com")

# Create collection with tenant isolation
client.create_collection(
    collection_name="knowledge_base",
    vectors_config=VectorParams(
        size=768,  # Domain-specific embedding dimension
        distance=Distance.COSINE
    ),
    # Enable tenant co-location optimization (v1.11.0+)
    quantization_config=None,
    on_disk_payload=True
)

# Upsert with tenant_id for multi-tenancy
client.upsert(
    collection_name="knowledge_base",
    points=[
        {
            "id": doc_id,
            "vector": embedding,
            "payload": {
                "tenant_id": tenant_id,  # Partition key
                "is_tenant": True,       # Co-location optimization
                "content": text,
                "metadata": {...}
            }
        }
    ]
)

# Query with tenant filter
results = client.search(
    collection_name="knowledge_base",
    query_vector=query_embedding,
    query_filter={
        "must": [{"key": "tenant_id", "match": {"value": tenant_id}}]
    },
    limit=10
)
```

**Neo4j Configuration** (Knowledge Graph):

```cypher
// Create knowledge graph with entity extraction
MERGE (e1:Entity {id: $entity1_id, tenant_id: $tenant_id})
SET e1.name = $entity1_name, e1.type = $entity1_type

MERGE (e2:Entity {id: $entity2_id, tenant_id: $tenant_id})
SET e2.name = $entity2_name, e2.type = $entity2_type

MERGE (e1)-[r:RELATED_TO {
    relationship: $relationship_type,
    confidence: $confidence_score
}]->(e2)

// Multi-hop traversal for GraphRAG
MATCH path = (start:Entity {tenant_id: $tenant_id})-[*1..3]-(end:Entity)
WHERE start.name CONTAINS $query_term
RETURN path, relationships(path), nodes(path)
```

**Hybrid Retrieval Flow**:

```python
async def hybrid_graphrag_retrieval(query: str, tenant_id: str):
    """Combines vector recall with graph precision"""

    # Step 1: Vector search for initial candidates (Qdrant)
    embedding = await embed_model.embed(query)
    vector_results = await qdrant_client.search(
        collection_name="knowledge_base",
        query_vector=embedding,
        query_filter={"tenant_id": tenant_id},
        limit=20  # Recall-focused
    )

    # Step 2: Extract entities from top candidates
    entities = extract_entities(vector_results)

    # Step 3: Graph traversal for relationship enrichment (Neo4j)
    graph_results = await neo4j_session.run("""
        MATCH path = (e:Entity {tenant_id: $tenant_id})-[*1..2]-(related)
        WHERE e.id IN $entity_ids
        RETURN path, related
    """, tenant_id=tenant_id, entity_ids=entities)

    # Step 4: Combine and rerank with ColBERT
    combined_context = merge_vector_and_graph_results(
        vector_results, graph_results
    )
    reranked = await colbert_reranker.rerank(query, combined_context)

    return reranked[:5]  # Top 5 precision-optimized results
```

**Performance Targets**:
- **Vector Search**: <10ms (Qdrant single-digit latency)
- **Graph Traversal**: <50ms (Neo4j with indexes)
- **End-to-end Retrieval**: <100ms (including reranking)
- **Accuracy**: 85%+ retrieval precision (vs 65% baseline RAG)

**Multi-Tenant Isolation**:
- **Qdrant**: Payload-based partitioning with `is_tenant=true` optimization
- **Neo4j**: Separate graphs for enterprise customers, shared graph with `tenant_id` property for standard
- **Supabase**: Row-Level Security as unified control plane for tenant metadata

### 4. Voice Agent Service

**Technology Stack**:
- **LiveKit Server**: Distributed mesh for WebRTC connectivity
- **LiveKit SIP**: Bridge to PSTN telephony (Twilio/Telnyx)
- **STT**: Deepgram Nova-3 (300-400ms streaming latency)
- **TTS**: ElevenLabs Flash v2.5 (75ms TTFB)
- **VAD**: Custom turn detection model (100-200ms latency)

**Architecture**:

```python
from livekit import rtc, agents
from livekit.agents import Agent, AgentSession, function_tool
from livekit.plugins.google.beta.realtime import RealtimeModel

class VoiceAgent(Agent):
    """Real-time voice interaction with sub-500ms latency"""

    def __init__(self):
        self.stt = DeepgramSTT(api_key=DEEPGRAM_KEY)
        self.tts = ElevenLabsTTS(api_key=ELEVENLABS_KEY)
        self.llm = GeminiRealtimeModel(api_key=GOOGLE_KEY)
        self.turn_detector = CustomVADModel()

    async def on_message(self, session: AgentSession, message: str):
        """Process voice input with streaming response"""

        # Preemptive generation: start LLM before end-of-turn confirmed
        llm_task = asyncio.create_task(
            self.llm.generate_streaming(message, session.context)
        )

        # Dual streaming: begin TTS as soon as first LLM chunk arrives
        async for chunk in llm_task:
            audio_chunk = await self.tts.synthesize_streaming(chunk)
            await session.send_audio(audio_chunk)

        # Update conversation state
        await self.save_checkpoint(session.session_id, session.state)
```

**LiveKit SIP Integration**:

```yaml
# sip_trunk_config.yaml
apiVersion: v1
kind: SIPTrunk
metadata:
  name: twilio-production
spec:
  provider: twilio
  inbound:
    - phoneNumber: "+1234567890"
      dispatchRule: "agent-voice-room"
  outbound:
    - trunkId: "twilio-trunk-1"
      authUsername: "AC_TWILIO_SID"
      authPassword: "AUTH_TOKEN"

  # SIP signaling and media ports
  signaling:
    port: 5060
    protocol: UDP
  media:
    portRange: "10000-20000"
    codec: "PCMU"  # G.711 for telephony compatibility
```

**Latency Optimization Techniques**:

1. **Service Co-location**: Deploy STT, LLM, TTS in same GCP region (5-10ms network latency)
2. **Streaming APIs**: Avoid waiting for full input before processing
3. **Preemptive Generation**: Start LLM inference before end-of-turn confirmed
4. **Dual Streaming**: Begin TTS generation before LLM completes full response
5. **Turn Detection**: Custom VAD model tuned for Indian English patterns (500ms prefix padding)
6. **Model Selection**: Gemini Flash TTFT <500ms (vs 400-500ms GPT-4o)

**Production Deployment**:

```yaml
# voice-agent-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: voice-agent
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: voice-agent
        image: gcr.io/project/voice-agent:latest
        resources:
          requests:
            cpu: "2000m"
            memory: "4Gi"
          limits:
            cpu: "4000m"
            memory: "8Gi"
      nodeSelector:
        workload-type: voice-agent
      tolerations:
      - key: "voice-workload"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: voice-agent-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: voice-agent
  minReplicas: 3
  maxReplicas: 50
  metrics:
  - type: External
    external:
      metric:
        name: livekit_room_count
      target:
        type: AverageValue
        averageValue: "10"  # 10-25 concurrent sessions per pod
```

**Performance Targets**:
- **End-to-end Latency**: <500ms (user speaks → hears AI response)
- **STT Latency**: 300-400ms (Deepgram Nova-3)
- **LLM TTFT**: <500ms (Gemini Flash)
- **TTS TTFB**: <75ms (ElevenLabs Flash v2.5)
- **Concurrent Sessions**: 10-25 per 4-core worker

### 5. Configuration Service

**Technology**: Go (high-performance file watching and hot-reloading)

**Architecture**:

```go
type ConfigService struct {
    storage      ObjectStorage    // GCS bucket
    validator    SchemaValidator  // JSON Schema
    eventBus     *kafka.Producer
    versionCtrl  GitOpsClient     // GitHub API
}

// YAML-based multi-tenant configuration
type TenantConfig struct {
    TenantID         string              `yaml:"tenant_id"`
    AgentIdentity    AgentIdentity       `yaml:"agent_identity"`
    Capabilities     []string            `yaml:"capabilities"`
    BehavioralRules  BehavioralRules     `yaml:"behavioral_rules"`
    PromptTemplates  []PromptTemplate    `yaml:"prompt_templates"`
    LLMParameters    LLMParameters       `yaml:"llm_parameters"`
    QuotaLimits      QuotaLimits         `yaml:"quota_limits"`
    FeatureFlags     map[string]bool     `yaml:"feature_flags"`
}

func (cs *ConfigService) WatchConfigurations() {
    ticker := time.NewTicker(60 * time.Second)
    for range ticker.C {
        changes := cs.storage.ListChanges("gs://configs/tenant_*/")

        for _, change := range changes {
            // Validate new configuration
            if err := cs.validator.Validate(change.Content); err != nil {
                log.Error("Invalid config", "error", err)
                cs.rollback(change.TenantID)
                continue
            }

            // Publish config_updated event to Kafka
            cs.eventBus.Publish("config_updated", kafka.Message{
                Key:   change.TenantID,
                Value: change.Content,
            })

            // Version control
            cs.versionCtrl.Commit(change.TenantID, change.Content)
        }
    }
}
```

**Hot-Reloading Implementation**:

```
1. Config Service detects file change (GCS bucket)
2. Validates new configuration (JSON Schema)
3. Publishes `config_updated` event to Kafka
4. Microservices subscribe to topic
5. Services reload affected components
6. Cached configurations invalidated
7. New requests use updated configuration
8. If reload fails → continue with cached config + alert ops team
```

**Feature Flag Integration** (LaunchDarkly):

```yaml
# tenant_12345_config.yaml
tenant_id: "12345"
agent_identity:
  name: "Krishna Healthcare Assistant"
  model_preference: "gemini-2.5-flash"

capabilities:
  - order_creation
  - payment_processing
  - appointment_booking

feature_flags:
  enable_graphrag: true          # Gradual rollout
  enable_voice_agent: false      # Not ready yet
  enable_sentiment_analysis: true

llm_parameters:
  temperature: 0.7
  max_tokens: 800
  top_p: 0.95
```

### 6. Model Context Protocol (MCP) Integration

**MCP Version**: 2025-06-18 specification
**Status**: Generally available (OpenAI, Microsoft, Google DeepMind support confirmed)

**Architecture**:

```
┌──────────────────────────────────────────────────────────────┐
│                    MCP Host (Agent App)                       │
│  - Manages multiple MCP client instances                     │
│  - Controls connection permissions & lifecycle                │
│  - Enforces security policies                                 │
└────────────────┬─────────────────────────────────────────────┘
                 │
      ┌──────────┴──────────┬──────────┬──────────┐
      │                     │          │          │
┌─────▼──────┐  ┌──────────▼───┐ ┌────▼────┐ ┌──▼──────┐
│ MCP Client │  │ MCP Client   │ │ MCP     │ │ MCP     │
│ (Google    │  │ (GitHub)     │ │ Client  │ │ Client  │
│ Drive)     │  │              │ │ (SQL)   │ │ (Slack) │
└─────┬──────┘  └──────┬───────┘ └────┬────┘ └──┬──────┘
      │                │               │         │
┌─────▼──────┐  ┌──────▼───────┐ ┌────▼────┐ ┌──▼──────┐
│ MCP Server │  │ MCP Server   │ │ MCP     │ │ MCP     │
│ (Google    │  │ (GitHub API) │ │ Server  │ │ Server  │
│ Drive API) │  │              │ │ (DB)    │ │ (Slack) │
└────────────┘  └──────────────┘ └─────────┘ └─────────┘
```

**MCP Primitives**:

1. **Tools**: Functions agents call to retrieve information or perform actions
2. **Resources**: Data included in model context (database records, images, files)
3. **Prompts**: Templates guiding how models interact with tools/resources

**Example MCP Server Implementation**:

```python
from mcp import Server, Tool, Resource

class CRMIntegrationMCPServer(Server):
    """MCP server for Salesforce/HubSpot integration"""

    @tool
    async def fetch_customer_data(self, customer_id: str) -> Dict:
        """Fetch customer profile from CRM"""
        return await self.crm_client.get_contact(customer_id)

    @tool
    async def create_lead(self, lead_data: Dict) -> str:
        """Create new lead in CRM"""
        return await self.crm_client.create_lead(lead_data)

    @resource
    async def get_pipeline_stages(self) -> List[str]:
        """Return available sales pipeline stages"""
        return await self.crm_client.list_pipeline_stages()
```

**Security Considerations** (April 2025 research findings):
- **Prompt Injection**: Implement input sanitization before MCP tool calls
- **Tool Permissions**: Least-privilege access, require approval for sensitive operations
- **Lookalike Tools**: Namespace isolation to prevent tool replacement attacks

**Benefits**:
- **Standardized Tool Access**: N×M problem reduced to N+M (N clients + M servers)
- **Discoverability**: Agents auto-discover available tools via MCP protocol
- **Interoperability**: Works across LangGraph, ADK, CrewAI, AutoGen frameworks

---

## Voicebot Architecture (Separate from Chatbot)

### Architectural Separation Rationale

**Voicebot** and **Chatbot** have fundamentally different requirements:

| Aspect | Voicebot | Chatbot |
|--------|----------|---------|
| **Latency** | <500ms (conversational) | <2s (acceptable) |
| **Infrastructure** | LiveKit + SIP + Telephony | WebSocket + REST APIs |
| **State Management** | Real-time session state | Persistent conversation threads |
| **Cost per interaction** | $0.05-0.07/min | $0.02-0.05/conversation |
| **Concurrency** | 10-25 per pod | 100+ per pod |
| **Scaling trigger** | LiveKit room count | Request rate |

### Voicebot-Specific Microservices

**1. LiveKit Server Cluster**:

```yaml
# livekit-server-deployment.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: livekit-server
spec:
  serviceName: livekit
  replicas: 3
  template:
    spec:
      containers:
      - name: livekit
        image: livekit/livekit-server:latest
        ports:
        - containerPort: 7880  # HTTP API
        - containerPort: 7881  # WebRTC
        - containerPort: 7882  # TURN/UDP
        env:
        - name: LIVEKIT_REDIS_URL
          value: "redis://memorystore.internal:6379"
        - name: LIVEKIT_NODE_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        volumeMounts:
        - name: livekit-config
          mountPath: /etc/livekit
      volumes:
      - name: livekit-config
        configMap:
          name: livekit-config
---
apiVersion: v1
kind: Service
metadata:
  name: livekit-loadbalancer
spec:
  type: LoadBalancer
  loadBalancerIP: "RESERVED_STATIC_IP"
  ports:
  - name: http
    port: 443
    targetPort: 7880
  - name: rtc
    port: 7881
    protocol: UDP
  selector:
    app: livekit-server
```

**2. LiveKit SIP Service**:

```yaml
# livekit-sip-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: livekit-sip
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: sip-service
        image: livekit/sip:latest
        ports:
        - containerPort: 5060  # SIP signaling
          protocol: UDP
        - containerPort: 10000-20000  # RTP media
          protocol: UDP
        env:
        - name: LIVEKIT_URL
          value: "wss://livekit.example.com"
        - name: REDIS_URL
          value: "redis://memorystore.internal:6379"
        - name: SIP_PORT
          value: "5060"
```

**3. Voice Agent Workers**:

```python
# voice_agent_worker.py
from livekit import agents, rtc
from livekit.plugins.google.beta.realtime import RealtimeModel

async def entrypoint(ctx: agents.JobContext):
    """Entry point for each voice session"""

    # Connect to room
    await ctx.connect()

    # Initialize voice assistant
    assistant = VoiceAssistant(
        llm=RealtimeModel(model="gemini-2.5-flash"),
        stt=DeepgramSTT(),
        tts=ElevenLabsTTS(),
        context=await load_customer_context(ctx.room.name)
    )

    # Start voice interaction
    session = VoiceSession(assistant)
    await session.start()

    # Monitor for human escalation
    if session.should_escalate():
        await transfer_to_human(ctx.room.name, session.transfer_reason)

if __name__ == "__main__":
    agents.cli.run_app(
        agents.WorkerOptions(entrypoint_fnc=entrypoint)
    )
```

### Voice Pipeline Architecture

```
Caller → Twilio/Telnyx → LiveKit SIP → LiveKit Room → Voice Agent Worker
                                             ↓
                              ┌──────────────┴─────────────┐
                              │                            │
                    ┌─────────▼────────┐       ┌──────────▼────────┐
                    │ Deepgram STT     │       │ Customer Context  │
                    │ (300-400ms)      │       │ (Database)        │
                    └─────────┬────────┘       └──────────┬────────┘
                              │                            │
                              └──────────┬─────────────────┘
                                         │
                              ┌──────────▼─────────┐
                              │ Gemini 2.5 Flash   │
                              │ (TTFT <500ms)      │
                              └──────────┬─────────┘
                                         │
                              ┌──────────▼─────────┐
                              │ Tool Execution     │
                              │ (Order, Payment)   │
                              └──────────┬─────────┘
                                         │
                              ┌──────────▼─────────┐
                              │ ElevenLabs TTS     │
                              │ (TTFB 75ms)        │
                              └──────────┬─────────┘
                                         │
                              ┌──────────▼─────────┐
                              │ LiveKit Audio Out  │
                              └────────────────────┘
                                         ↓
                                     Caller hears response
```

### Human Escalation Flow

```python
async def transfer_to_human(room_name: str, reason: str):
    """Transfer voice call to human agent"""

    # 1. Find available human agent
    agent = await find_available_agent(skill="customer_support")

    if not agent:
        # No agents available
        await play_voicemail_message(room_name)
        await create_callback_ticket(room_name, reason)
        return

    # 2. Create transfer using SIP REFER
    await livekit_sip.transfer_call(
        room_name=room_name,
        destination=agent.sip_uri,
        transfer_type="warm"  # AI stays on call during handoff
    )

    # 3. Send agent briefing
    await send_agent_context(
        agent_id=agent.id,
        call_summary=summarize_conversation(room_name),
        customer_sentiment=analyze_sentiment(room_name),
        reason=reason
    )

    # 4. Log transfer event
    await kafka_producer.send("call_transfers", {
        "room_name": room_name,
        "agent_id": agent.id,
        "reason": reason,
        "timestamp": datetime.utcnow()
    })
```

---

## GCP Infrastructure

### Service Mapping

| Component | GCP Service | Justification |
|-----------|-------------|---------------|
| **Agent Orchestration** | GKE (Kubernetes Engine) | Full control, stateful workloads, GPU scheduling |
| **Voice Agent Workers** | GKE with T4 GPUs | Real-time inference, low-latency requirements |
| **LLM Gateway** | Cloud Run (alternative: GKE) | Auto-scaling, pay-per-request for variable load |
| **API Gateway** | Cloud Endpoints / Apigee | Managed API management, DDoS protection |
| **Message Queue** | Pub/Sub | Native GCP integration, 1M+ messages/sec |
| **Event Streaming** | Confluent Cloud on GCP | Kafka compatibility, managed service |
| **Database (Transactional)** | Cloud SQL (PostgreSQL) | Managed Postgres, automatic backups, HA |
| **Vector Database** | Qdrant self-hosted on GKE | Cost control, performance optimization |
| **Graph Database** | Neo4j Aura (managed) | Fully managed, enterprise support |
| **Object Storage** | Cloud Storage (GCS) | Configuration files, document storage, backups |
| **Cache** | Memorystore (Redis) | Managed Redis, sub-millisecond latency |
| **Secret Management** | Secret Manager | Native integration, automatic rotation |
| **Monitoring** | Cloud Monitoring + Grafana | Native metrics + custom dashboards |
| **Logging** | Cloud Logging + Loki | Centralized logs, long-term retention |
| **Tracing** | Cloud Trace + Tempo | Distributed tracing, OpenTelemetry compatible |
| **CI/CD** | Cloud Build + Artifact Registry | Native Git integration, container registry |
| **Load Balancer** | Cloud Load Balancing | Global anycast, DDoS protection |
| **DNS** | Cloud DNS | Low-latency, DNSSEC support |
| **CDN** | Cloud CDN | Static assets, API response caching |

### Network Architecture

```
Internet
   │
   ├─→ Cloud Load Balancer (Global)
   │        │
   │        ├─→ Cloud CDN (Static Assets)
   │        │
   │        └─→ Cloud Armor (DDoS Protection)
   │                 │
   │                 └─→ Cloud Endpoints (API Gateway)
   │                          │
   │                          └─→ GKE Cluster (Multi-Zone)
   │                               ├─→ Agent Orchestration Pods
   │                               ├─→ Voice Agent Pods (GPU)
   │                               ├─→ LLM Gateway Pods
   │                               └─→ RAG Pipeline Pods
   │
   └─→ LiveKit Load Balancer (Regional)
            │
            └─→ LiveKit Server StatefulSet
                     │
                     └─→ LiveKit SIP Service
                              │
                              └─→ Twilio/Telnyx (PSTN)
```

**VPC Configuration**:

```yaml
# vpc-config.yaml
apiVersion: compute.cnrm.cloud.google.com/v1beta1
kind: ComputeNetwork
metadata:
  name: workflow-automation-vpc
spec:
  autoCreateSubnetworks: false
  routingMode: GLOBAL
---
apiVersion: compute.cnrm.cloud.google.com/v1beta1
kind: ComputeSubnetwork
metadata:
  name: gke-subnet
spec:
  ipCidrRange: "10.0.0.0/20"
  region: us-central1
  networkRef:
    name: workflow-automation-vpc
  secondaryIpRanges:
  - rangeName: pods
    ipCidrRange: "10.4.0.0/14"
  - rangeName: services
    ipCidrRange: "10.8.0.0/20"
  privateIpGoogleAccess: true
---
apiVersion: compute.cnrm.cloud.google.com/v1beta1
kind: ComputeSubnetwork
metadata:
  name: voice-subnet
spec:
  ipCidrRange: "10.1.0.0/20"
  region: us-central1
  networkRef:
    name: workflow-automation-vpc
  privateIpGoogleAccess: true
```

### Deployment Strategy

**GKE Cluster Configuration**:

```yaml
# gke-cluster.yaml
apiVersion: container.cnrm.cloud.google.com/v1beta1
kind: ContainerCluster
metadata:
  name: workflow-automation-cluster
spec:
  location: us-central1
  initialNodeCount: 1
  removeDefaultNodePool: true
  networkRef:
    name: workflow-automation-vpc
  subnetworkRef:
    name: gke-subnet

  # IP allocation for pods and services
  ipAllocationPolicy:
    clusterSecondaryRangeName: pods
    servicesSecondaryRangeName: services

  # Enable Workload Identity for secure GCP API access
  workloadIdentityConfig:
    workloadPool: PROJECT_ID.svc.id.goog

  # Enable monitoring and logging
  loggingService: logging.googleapis.com/kubernetes
  monitoringService: monitoring.googleapis.com/kubernetes

  # Enable autoscaling and auto-repair
  clusterAutoscaling:
    enabled: true
    autoscalingProfile: OPTIMIZE_UTILIZATION
---
# Node pool for general workloads
apiVersion: container.cnrm.cloud.google.com/v1beta1
kind: ContainerNodePool
metadata:
  name: general-pool
spec:
  clusterRef:
    name: workflow-automation-cluster
  initialNodeCount: 3
  autoscaling:
    minNodeCount: 3
    maxNodeCount: 20
  nodeConfig:
    machineType: n2-standard-4
    diskSizeGb: 100
    diskType: pd-ssd
    preemptible: false
    oauthScopes:
    - https://www.googleapis.com/auth/cloud-platform
---
# Node pool for GPU workloads (voice agents)
apiVersion: container.cnrm.cloud.google.com/v1beta1
kind: ContainerNodePool
metadata:
  name: gpu-pool
spec:
  clusterRef:
    name: workflow-automation-cluster
  initialNodeCount: 2
  autoscaling:
    minNodeCount: 2
    maxNodeCount: 10
  nodeConfig:
    machineType: n1-standard-4
    guestAccelerators:
    - type: nvidia-tesla-t4
      count: 1
    diskSizeGb: 100
    diskType: pd-ssd
    oauthScopes:
    - https://www.googleapis.com/auth/cloud-platform
  management:
    autoRepair: true
    autoUpgrade: true
```

### CI/CD Pipeline

```yaml
# cloudbuild.yaml
steps:
# Build Docker images
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/agent-orchestration:$SHORT_SHA', './services/agent-orchestration']

- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/voice-agent:$SHORT_SHA', './services/voice']

# Push to Artifact Registry
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/agent-orchestration:$SHORT_SHA']

- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/voice-agent:$SHORT_SHA']

# Run tests
- name: 'gcr.io/$PROJECT_ID/test-runner'
  args: ['pytest', 'tests/', '-v', '--cov']
  env:
  - 'DATABASE_URL=postgresql://test:test@localhost/test'

# Deploy to GKE (staging)
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'set'
  - 'image'
  - 'deployment/agent-orchestration'
  - 'agent-orchestration=gcr.io/$PROJECT_ID/agent-orchestration:$SHORT_SHA'
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=staging-cluster'

# Wait for rollout
- name: 'gcr.io/cloud-builders/kubectl'
  args: ['rollout', 'status', 'deployment/agent-orchestration', '--timeout=5m']
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=staging-cluster'

# Integration tests on staging
- name: 'gcr.io/$PROJECT_ID/integration-tester'
  args: ['./run-integration-tests.sh', 'staging']

# Promote to production (manual approval)
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'builds', 'approve', '$BUILD_ID']
  waitFor: ['-']  # Manual approval gate

# Deploy to production
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'set'
  - 'image'
  - 'deployment/agent-orchestration'
  - 'agent-orchestration=gcr.io/$PROJECT_ID/agent-orchestration:$SHORT_SHA'
  env:
  - 'CLOUDSDK_COMPUTE_REGION=us-central1'
  - 'CLOUDSDK_CONTAINER_CLUSTER=production-cluster'

timeout: 3600s
options:
  machineType: 'N1_HIGHCPU_8'
```

### Cost Optimization

**1. Right-Sizing Compute**:
- **GKE Autopilot Mode**: Auto-provisions optimally-sized nodes
- **Committed Use Discounts**: 57% discount for 3-year commitment on base capacity
- **Spot VMs**: 60-91% discount for fault-tolerant batch workloads (analytics, embeddings)

**2. Storage Tiering**:
- **Hot (SSD)**: Active conversations (last 30 days)
- **Warm (HDD)**: Recent history (30-90 days)
- **Cold (Nearline)**: Compliance archives (>90 days, $0.01/GB/month)

**3. Network Optimization**:
- **Regional Endpoints**: Minimize inter-region data transfer ($0.01/GB)
- **Cloud CDN**: Cache static assets and API responses
- **VPC Peering**: Free internal traffic between GCP services

**4. Gemini Cost Management**:
```python
# Model routing for 35%+ cost savings
def route_to_model(query_complexity: str, user_tier: str):
    if user_tier == "enterprise":
        return "gemini-2.5-pro"  # $1.25/1M input tokens
    elif query_complexity == "high":
        return "gemini-2.5-pro"
    else:
        return "gemini-2.5-flash"  # $0.075/1M input tokens (16× cheaper)
```

**Estimated Monthly Cost** (at 100K conversations/month):

| Category | Service | Cost |
|----------|---------|------|
| **Compute** | GKE (10 n2-standard-4 nodes) | $1,500 |
| **Compute** | GPU nodes (2 n1-standard-4 + T4) | $800 |
| **Database** | Cloud SQL (db-n1-standard-4) | $400 |
| **Cache** | Memorystore Redis (5GB) | $150 |
| **Storage** | GCS (500GB hot + 2TB cold) | $50 |
| **LLM** | Gemini (optimized routing) | $2,500 |
| **Voice** | Deepgram + ElevenLabs (50K calls) | $4,000 |
| **Networking** | Load balancing + egress | $300 |
| **Monitoring** | Cloud Monitoring + Grafana | $200 |
| **Total** | | **$9,900** |

**Cost per conversation**: $0.099 (~$0.10)
**Revenue per conversation** (enterprise): $0.50-2.00
**Gross margin**: 75-95%

---

## Context Engineering

### Context Management Strategy

**Problem**: Context windows are finite resources with diminishing returns

**Research Finding** (2025): Studies show "context rot"—as token count increases in context window, model's ability to accurately recall information decreases.

**Solution**: Hierarchical memory architecture with pruning and offloading

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT HIERARCHY                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  L1: System Prompt (Static)                        │     │
│  │  - Agent identity, capabilities, constraints       │     │
│  │  - 500-1000 tokens                                 │     │
│  └────────────────────────────────────────────────────┘     │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │  L2: Retrieved Knowledge (Dynamic)                 │     │
│  │  - GraphRAG results (top 5 chunks)                 │     │
│  │  - 2000-3000 tokens                                │     │
│  └────────────────────────────────────────────────────┘     │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │  L3: Conversation History (Compressed)             │     │
│  │  - Last 10 turns + summarized older context       │     │
│  │  - 1000-2000 tokens                                │     │
│  └────────────────────────────────────────────────────┘     │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐     │
│  │  L4: Customer Context (Selective)                  │     │
│  │  - Recent orders, preferences, support tickets    │     │
│  │  - 500-1000 tokens                                 │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Total Context Budget: ~5000-7500 tokens                    │
│  (Well within Gemini 2M limit, optimized for quality)       │
└─────────────────────────────────────────────────────────────┘
```

### Context Pruning Implementation

```python
class ContextManager:
    """Manages context window as finite resource"""

    def __init__(self, max_tokens: int = 7500):
        self.max_tokens = max_tokens
        self.tokenizer = tiktoken.get_encoding("cl100k_base")

    async def build_context(
        self,
        session_id: str,
        current_message: str
    ) -> List[Dict]:
        """Build optimized context within token budget"""

        # L1: Static system prompt
        system_prompt = await self.get_system_prompt(session_id)
        context = [{"role": "system", "content": system_prompt}]
        tokens_used = self.count_tokens(system_prompt)

        # L2: Retrieved knowledge (GraphRAG)
        relevant_knowledge = await self.retrieve_knowledge(
            query=current_message,
            max_tokens=3000
        )
        context.append({"role": "system", "content": relevant_knowledge})
        tokens_used += self.count_tokens(relevant_knowledge)

        # L3: Conversation history with compression
        history = await self.get_conversation_history(session_id)
        compressed_history = await self.compress_history(
            history,
            max_tokens=self.max_tokens - tokens_used - 1500  # Reserve for L4
        )
        context.extend(compressed_history)
        tokens_used += sum(self.count_tokens(msg["content"]) for msg in compressed_history)

        # L4: Customer context (selective fields)
        customer_context = await self.get_customer_context(
            session_id,
            max_tokens=self.max_tokens - tokens_used
        )
        if customer_context:
            context.append({"role": "system", "content": customer_context})

        return context

    async def compress_history(
        self,
        history: List[Dict],
        max_tokens: int
    ) -> List[Dict]:
        """Compress conversation history using summarization"""

        if self.count_tokens_list(history) <= max_tokens:
            return history

        # Keep last 10 turns verbatim
        recent_history = history[-10:]
        older_history = history[:-10]

        # Summarize older history
        summary = await self.llm.summarize(
            messages=older_history,
            max_tokens=max_tokens // 2
        )

        compressed = [
            {"role": "system", "content": f"Previous conversation summary: {summary}"}
        ]
        compressed.extend(recent_history)

        return compressed

    async def prune_conflicting_info(self, context: List[Dict]) -> List[Dict]:
        """Remove outdated or conflicting information"""

        # Track facts mentioned
        facts = defaultdict(list)
        for i, message in enumerate(context):
            extracted_facts = self.extract_facts(message["content"])
            for fact_type, fact_value in extracted_facts:
                facts[fact_type].append((i, fact_value))

        # Keep only most recent value for each fact
        to_remove = set()
        for fact_type, occurrences in facts.items():
            if len(occurrences) > 1:
                # Mark older occurrences for removal
                for idx, _ in occurrences[:-1]:
                    to_remove.add(idx)

        # Remove conflicting messages
        pruned = [msg for i, msg in enumerate(context) if i not in to_remove]
        return pruned
```

### Context Offloading: "Think" Tool

**Inspiration**: Anthropic's "think" tool gives models separate workspace

```python
@function_tool
async def think(reasoning: str) -> str:
    """
    Separate workspace for processing without cluttering main context.
    Use this for:
    - Complex calculations
    - Multi-step reasoning
    - Draft responses before finalizing
    """
    # Store in separate scratchpad (not added to main context)
    await redis_client.setex(
        f"scratchpad:{session_id}:{uuid4()}",
        ex=3600,  # 1 hour TTL
        value=reasoning
    )
    return "Reasoning saved to scratchpad. Continue with main response."
```

### Prompt Engineering Best Practices

**1. System Prompt Structure** (Clear altitude, specific yet flexible):

```yaml
# system_prompt_template.yaml
role: |
  You are Krishna Healthcare Assistant, an AI voice agent for Krishna Diagnostics.
  Your purpose is to help customers book diagnostic tests, check report status, and answer healthcare questions.

capabilities:
  - Book diagnostic tests (blood tests, imaging, health checkups)
  - Create payment links and process payments
  - Check report status and send reports via WhatsApp
  - Answer medical questions using verified knowledge base
  - Escalate to human agents when needed

behavioral_rules:
  tone: Professional, empathetic, conversational (Indian English)
  constraints:
    - Never provide medical diagnoses or treatment advice
    - Always verify customer identity before sharing reports
    - Escalate complex medical questions to doctors
    - Confirm payment details before processing

conversation_flow:
  - Greet warmly and ask how you can help
  - Gather necessary information systematically
  - Confirm details before executing actions
  - Provide clear next steps and follow-up information

examples:
  - |
    Customer: "I want to book a blood test"
    Assistant: "I'd be happy to help you book a blood test! Which test are you looking for? We offer CBC, lipid profile, thyroid panel, diabetes screening, and many more. Or I can help you find the right test based on your needs."
```

**2. Few-Shot Learning** (2-3 examples vs 10+):

```python
# Prompt compression: Use concise examples
few_shot_examples = [
    {
        "user": "Book CBC test for tomorrow",
        "assistant": "I'll book a CBC test for you. May I have your PIN code to check availability?",
        "reasoning": "Gathers essential info (PIN code) before proceeding"
    },
    {
        "user": "When will my report be ready?",
        "assistant": "I'll check your report status. Could you please provide your order ID or phone number?",
        "reasoning": "Requests identifier to look up specific report"
    }
]
```

**3. Dynamic Prompt Injection** (Context-aware instructions):

```python
def build_dynamic_instructions(session_state: Dict) -> str:
    """Add context-specific instructions to prompt"""

    instructions = []

    if session_state.get("pending_payment"):
        instructions.append(
            "IMPORTANT: Customer has pending payment link. "
            "Remind them to complete payment if they ask about order status."
        )

    if session_state.get("report_ready"):
        instructions.append(
            "GOOD NEWS: Customer's report is ready! "
            "Offer to send it via WhatsApp immediately."
        )

    if session_state.get("escalation_requested"):
        instructions.append(
            "Customer requested human agent. "
            "Acknowledge request and transfer immediately."
        )

    return "\n".join(instructions)
```

**4. Structured Output** (Improve parsing reliability):

```python
from pydantic import BaseModel

class AgentResponse(BaseModel):
    message: str
    action: Optional[str] = None
    action_params: Optional[Dict] = None
    requires_followup: bool = False
    escalate_to_human: bool = False

# Use structured output in prompt
structured_prompt = """
Respond in this JSON format:
{
  "message": "Your conversational response to the customer",
  "action": "tool_to_execute" | null,
  "action_params": {"param": "value"} | null,
  "requires_followup": true | false,
  "escalate_to_human": true | false
}

Example:
{
  "message": "I'll create an order for you. Could you confirm your address?",
  "action": "create_order",
  "action_params": {"test_type": "CBC", "customer_id": "12345"},
  "requires_followup": true,
  "escalate_to_human": false
}
"""
```

### Memory Management

**Short-term Memory** (Conversation Context):
- **Storage**: Redis with TTL (24 hours)
- **Scope**: Per session
- **Contents**: Current conversation turns, temporary state

**Long-term Memory** (Customer Profile):
- **Storage**: PostgreSQL with RLS
- **Scope**: Per customer (across sessions)
- **Contents**: Preferences, order history, medical notes

**Shared Memory** (Multi-agent Coordination):
- **Storage**: Redis (shared namespace)
- **Scope**: Per workflow execution
- **Contents**: Intermediate results, agent handoff context

```python
class MemoryManager:
    """Hierarchical memory for agents"""

    def __init__(self):
        self.redis = redis.Redis()
        self.postgres = PostgresClient()

    async def get_short_term_memory(self, session_id: str) -> Dict:
        """Retrieve current conversation context"""
        return json.loads(
            await self.redis.get(f"session:{session_id}") or "{}"
        )

    async def save_short_term_memory(
        self,
        session_id: str,
        context: Dict,
        ttl: int = 86400
    ):
        """Save conversation context with TTL"""
        await self.redis.setex(
            f"session:{session_id}",
            ttl,
            json.dumps(context)
        )

    async def get_long_term_memory(self, customer_id: str) -> Dict:
        """Retrieve customer profile and history"""
        return await self.postgres.fetchrow("""
            SELECT
                preferences,
                order_history,
                medical_notes
            FROM customers
            WHERE customer_id = $1
        """, customer_id)

    async def update_long_term_memory(
        self,
        customer_id: str,
        updates: Dict
    ):
        """Update customer profile"""
        await self.postgres.execute("""
            UPDATE customers
            SET preferences = preferences || $1
            WHERE customer_id = $2
        """, json.dumps(updates), customer_id)
```

---

## Industry Insights

### Learnings from YC AI Startups (2024-2025)

**1. Emergence ($97.2M Series A) - "Agents Creating Agents" Framework**

**Key Insight**: Autonomous agent spawning for complex enterprise workflows

**Application to Our System**:
- **PRD Generation Service** uses supervisor pattern with 4 worker agents (Requirements Extractor → Technical Analyzer → Pricing Calculator → Document Generator)
- Each worker can spawn sub-agents for specialized tasks
- Agents share results via Kafka events for coordination

**2. Sierra AI ($10B Valuation) - Enterprise Agent Orchestration**

**Key Insights**:
- **80% cost reduction** from $13/call to $2-3/call for customer service
- **Agent SDK** with pre-packaged building blocks
- **Voice Sims** for testing voice agents in real-world conditions before production

**Application to Our System**:
- Voice Agent testing framework with simulated customer interactions
- Reusable tool library (order_creation, payment_processing, report_status)
- Cost optimization through model routing and semantic caching

**3. Agno (6.9k GitHub stars) - Open-Source Multi-Modal Agent Framework**

**Key Insights**:
- Lightning-fast performance prioritization
- Memory and knowledge integration
- Tool-use standardization

**Application to Our System**:
- Multi-modal support for prescription image analysis
- Persistent memory architecture (short-term + long-term)
- MCP-standardized tool access across agents

### Comparative Analysis: Build vs Buy

| Aspect | Build (Our Architecture) | Buy (Retell AI, Vapi) |
|--------|--------------------------|----------------------|
| **Voice Latency** | <500ms (optimized) | <300ms (Retell) |
| **Customization** | Complete control | Limited to platform |
| **Cost (at scale)** | $0.03-0.05/min | $0.07-0.09/min |
| **LLM Flexibility** | Any provider | Platform-specific |
| **Data Sovereignty** | Full control (GCP) | Shared infrastructure |
| **Time to Production** | 12-16 weeks | 2-4 weeks |
| **Operational Overhead** | High (self-managed) | Low (fully managed) |

**Recommendation**:
- **Short-term** (MVP, 0-6 months): Consider Retell AI for rapid deployment
- **Long-term** (Scale, 6+ months): Self-hosted LiveKit for cost and control

### Best Practices from Production AI Companies

**1. Anthropic's Multi-Agent Systems**

**Finding**: Multi-agent systems use 15× more tokens but deliver 90% better performance on complex tasks

**Our Implementation**:
- **Cost-Quality Trade-off**: Use multi-agent only for high-value workflows (PRD generation, customer success analysis)
- **Single-agent**: Routine tasks (customer queries, order status checks)
- **Token Budget Management**: Set max_tokens per agent type to control costs

**2. LinkedIn's LangGraph Deployment**

**Finding**: Production deployment at scale with checkpoint-based recovery

**Our Implementation**:
- PostgreSQL checkpointer for conversation persistence
- Automatic resume on failure without losing context
- Distributed tracing for debugging multi-agent workflows

**3. Uber's Event-Driven Architecture**

**Finding**: Kafka as nervous system for agent coordination

**Our Implementation**:
- Event-driven microservices with Kafka (GCP Pub/Sub alternative)
- Event sourcing for audit trails and replay
- Real-time analytics pipeline (Kafka → Flink → ClickHouse)

---

## Implementation Roadmap

### Phased Approach (40-Week Roadmap)

This roadmap aligns with the sprints defined in WORKFLOW.md, prioritizing incremental delivery and validation.

### **Sprint 1-2: Foundation** (Weeks 1-4)

**Goal**: Deploy minimal viable chatbot on single tenant

**Services to Build**:
1. **Agent Orchestration Service** (TypeScript/Bun)
   - Basic LangGraph agent with 3-5 tools
   - Simple prompt template
   - In-memory state (no persistence)
   - Synchronous request-response

2. **LLM Gateway Service** (Python/FastAPI)
   - Gemini API integration only
   - Basic error handling
   - No caching initially

3. **User API Service** (TypeScript/Bun)
   - REST API for chat interactions
   - Basic authentication (API keys)
   - WebSocket for real-time streaming

4. **Database Setup**
   - Supabase PostgreSQL
   - Initial schema (users, conversations, tools_executed)

**Infrastructure**:
- Docker Compose for local development
- Single GCP Compute Engine instance for deployment
- Managed Supabase database
- GitHub Actions for CI/CD

**Success Criteria**:
- ✓ Handle 10 requests/min
- ✓ P95 latency <100ms
- ✓ Deploy via GitHub Actions
- ✓ Basic monitoring (Grafana Cloud free tier)

**Deliverables**:
- Working chatbot demo
- API documentation
- Deployment runbook

---

### **Sprint 3-4: Persistence & Multi-Agent** (Weeks 5-8)

**Goal**: Add conversation memory and multi-agent coordination

**Services to Add/Enhance**:
1. **Kafka Message Bus**
   - 3-broker cluster on GKE
   - Topics: `agent_decisions`, `tool_results`, `user_interactions`

2. **PostgreSQL Checkpointing**
   - LangGraph PostgresSaver integration
   - Checkpoint recovery on failure

3. **Supervisor-Worker Pattern**
   - Orchestrator agent spawns specialist agents
   - Example: Healthcare query → Medical RAG agent + Order Processing agent

4. **Basic RAG with pgvector**
   - Vector embeddings in PostgreSQL
   - Simple semantic search for knowledge retrieval

**Infrastructure**:
- GKE cluster (3 nodes, n2-standard-4)
- Kafka on Kubernetes (Strimzi operator)
- Helm charts per microservice

**Success Criteria**:
- ✓ Multi-session conversations persist
- ✓ Handle 500 requests/hour
- ✓ Checkpoint-based recovery tested
- ✓ Distributed tracing (OpenTelemetry + Tempo)

**Deliverables**:
- Multi-turn conversation demo
- Agent handoff example
- Monitoring dashboards

---

### **Sprint 5-6: Multi-Tenancy & Configuration** (Weeks 9-12)

**Goal**: Support 10+ tenants with dynamic configuration

**Services to Build**:
1. **Configuration Service** (Go)
   - YAML hot-reloading from GCS
   - JSON Schema validation
   - Kafka event propagation

2. **Tenant Authentication**
   - Supabase Auth integration
   - Row-Level Security policies
   - JWT-based tenant isolation

3. **Kong API Gateway**
   - Rate limiting per tenant tier
   - API key management
   - LLM routing capabilities

4. **Feature Flags** (LaunchDarkly)
   - Gradual rollout framework (5% → 25% → 100%)
   - Per-tenant feature toggles

**Infrastructure**:
- Kong deployed on GKE
- Redis (Memorystore) for quota tracking
- GCS for configuration storage

**Success Criteria**:
- ✓ 10 active tenants with isolated data
- ✓ Configuration hot-reload <60 seconds
- ✓ 1000 requests/hour across tenants
- ✓ Per-tenant analytics dashboard

**Deliverables**:
- Multi-tenant demo (3 distinct configurations)
- Tenant onboarding documentation
- Billing/quota enforcement

---

### **Sprint 7-8: RAG & Knowledge Management** (Weeks 13-16)

**Goal**: Production-grade knowledge retrieval

**Services to Build**:
1. **RAG Pipeline Service** (Python)
   - Document ingestion (PDF, DOCX, HTML)
   - SPLICE chunking (27% precision improvement)
   - Domain-specific embedding models

2. **Qdrant Vector Database**
   - 3-node cluster on GKE
   - Namespace-per-tenant isolation
   - Payload-based filtering

3. **Document Ingestion Pipeline**
   - GCS upload → Processing → Embedding → Vector storage
   - Batch and real-time ingestion

4. **Reranking with ColBERT**
   - Cross-encoder for precision optimization

**Infrastructure**:
- Qdrant cluster (3 nodes, 16GB RAM each)
- GPU instance for embedding generation (T4)
- GCS for document storage

**Success Criteria**:
- ✓ <100ms vector search latency (P95)
- ✓ 85%+ retrieval accuracy (vs ground truth)
- ✓ Support 1M vectors per tenant
- ✓ Document updates within 5 minutes

**Deliverables**:
- Knowledge base demo (medical Q&A)
- Accuracy evaluation report
- Ingestion API documentation

---

### **Sprint 9-10: Voice Infrastructure** (Weeks 17-20)

**Goal**: Deploy voice agent capabilities

**Services to Build**:
1. **Voice Agent Service** (Python/LiveKit)
   - LiveKit Agents framework
   - Gemini Realtime Model integration
   - Tool calling over voice

2. **LiveKit Server Cluster**
   - 3-node StatefulSet on GKE
   - Redis for coordination
   - WebRTC connectivity

3. **SIP Integration**
   - LiveKit SIP service
   - Twilio/Telnyx telephony provider
   - Inbound and outbound calling

4. **STT/TTS Integration**
   - Deepgram Nova-3 (STT)
   - ElevenLabs Flash v2.5 (TTS)
   - Custom VAD model

**Infrastructure**:
- GPU instances for voice workers (n1-standard-4 + T4)
- Static IP for SIP signaling
- Reserved phone numbers (Twilio)

**Success Criteria**:
- ✓ Handle 100 concurrent voice calls
- ✓ <500ms end-to-end latency (P95)
- ✓ 90%+ call completion rate
- ✓ Smooth handoff to human agents

**Deliverables**:
- Voice agent demo (healthcare booking)
- Latency benchmark report
- SIP trunk configuration guide

---

### **Sprint 11-12: Advanced Orchestration** (Weeks 21-24)

**Goal**: Implement GraphRAG and complex multi-agent workflows

**Services to Build**:
1. **Neo4j Knowledge Graph**
   - Entity extraction pipeline
   - Relationship graph construction
   - Multi-hop traversal queries

2. **GraphRAG Query Engine**
   - Hybrid retrieval (Qdrant + Neo4j)
   - Community detection (Leiden clustering)
   - Hierarchical summarization

3. **Advanced Agent Patterns**
   - Parallel tool execution
   - Map-reduce workflows
   - Conditional interrupts for human approval

**Infrastructure**:
- Neo4j AuraDB (managed) or self-hosted cluster
- Increased compute for LLM-based entity extraction

**Success Criteria**:
- ✓ 35% accuracy improvement on complex queries
- ✓ 3-5 parallel subagents per supervisor
- ✓ Event sourcing audit trail complete
- ✓ Human-in-the-loop approval flow working

**Deliverables**:
- GraphRAG comparison study (vs standard RAG)
- Multi-agent workflow examples
- Audit trail dashboard

---

### **Sprint 13-14: Automation Workflows** (Weeks 25-28)

**Goal**: PRD generation, demo creation, pricing automation

**Services to Build**:
1. **PRD Generation Service** (Python)
   - Multi-agent workflow (4 specialists)
   - GitHub API integration
   - Mermaid diagram generation

2. **Demo Provisioning Service**
   - Automated sandbox environment creation
   - Template-based chatbot deployment
   - Demo lifecycle management

3. **Pricing Calculator**
   - Cost estimation engine
   - Ashay's financial cost module integration
   - Pricing tier templates

**Infrastructure**:
- Template storage (GCS)
- GitHub Actions for demo deployment
- Sandbox Kubernetes namespace per demo

**Success Criteria**:
- ✓ Generate PRD in <5 minutes
- ✓ 90%+ client satisfaction with quality
- ✓ Automated demo deployment in <10 minutes
- ✓ Pricing accuracy within 5% of actual costs

**Deliverables**:
- PRD generation demo
- Demo provisioning portal
- Pricing model templates

---

### **Sprint 15-16: Observability & Analytics** (Weeks 29-32)

**Goal**: Production-grade monitoring and analytics

**Services to Build**:
1. **Analytics Service** (Python/Go)
   - Real-time metrics (Kafka → Flink → ClickHouse)
   - Batch analytics (S3 → dbt → Snowflake)
   - LLM-as-judge evaluation

2. **Monitoring Stack**
   - Helicone for LLM observability
   - Prometheus + Grafana for infrastructure
   - PagerDuty for alerting

3. **A/B Testing Framework**
   - Prompt versioning (Langfuse)
   - Model comparison
   - Statistical significance testing

4. **Conversation Analytics**
   - Intent classification
   - Topic clustering
   - Sentiment analysis

**Infrastructure**:
- ClickHouse cluster for real-time analytics
- Snowflake for batch warehouse
- TimescaleDB for time-series metrics

**Success Criteria**:
- ✓ <1 minute alert latency
- ✓ 95%+ metric accuracy
- ✓ A/B test significance in <1000 samples
- ✓ Cost tracking accurate to $0.01 per tenant

**Deliverables**:
- Executive analytics dashboard
- Quality evaluation framework
- Cost attribution report

---

### **Sprint 17-18: CRM & Integrations** (Weeks 33-36)

**Goal**: Enterprise integration capabilities

**Services to Build**:
1. **CRM Integration Service** (Go)
   - Salesforce bidirectional sync
   - HubSpot integration
   - OAuth 2.0 flows

2. **Webhook Handler**
   - CRM event receivers
   - Idempotent operations
   - Conflict resolution

3. **MCP Server Implementations**
   - Standardized tool access
   - Google Drive MCP server
   - GitHub MCP server
   - SQL database MCP server

**Infrastructure**:
- Circuit breaker for external APIs
- Retry queues (RabbitMQ)
- Audit logging (PostgreSQL)

**Success Criteria**:
- ✓ Real-time CRM updates (<5 second latency)
- ✓ 99.9% idempotency success
- ✓ Handle CRM API rate limits gracefully
- ✓ MCP tool discoverability working

**Deliverables**:
- CRM integration demos (Salesforce + HubSpot)
- MCP server library
- Integration testing framework

---

### **Sprint 19-20: Production Hardening** (Weeks 37-40)

**Goal**: Enterprise-ready deployment

**Activities**:
1. **Security Audit**
   - Penetration testing
   - Compliance certifications (SOC 2 Type II prep)
   - Secret rotation implementation

2. **Load Testing**
   - 10K concurrent user simulation
   - Stress testing (2× expected peak)
   - Sustained load (24-hour test)

3. **Disaster Recovery**
   - Multi-region deployment (primary + failover)
   - Automated backup/restore procedures
   - RTO <5 minutes, RPO <15 minutes

4. **Documentation**
   - Architecture documentation
   - Runbooks for common scenarios
   - Customer success portal

**Infrastructure**:
- Multi-region GKE (us-central1 + us-east1)
- WAF for DDoS protection (Cloud Armor)
- Secret rotation (HashiCorp Vault)

**Success Criteria**:
- ✓ 99.9% uptime SLA
- ✓ <5 minute RTO achieved
- ✓ Security audit passed
- ✓ Load test confirms 10K concurrent capacity
- ✓ Disaster recovery drill successful

**Deliverables**:
- Production readiness checklist
- Security audit report
- Disaster recovery playbook
- Customer-facing documentation

---

### Dependencies & Critical Path

**Critical Path** (sequential, cannot parallelize):
1. Sprint 1-2: Foundation → Sprint 3-4: Persistence
2. Sprint 3-4: Persistence → Sprint 5-6: Multi-tenancy
3. Sprint 7-8: RAG → Sprint 11-12: GraphRAG
4. Sprint 9-10: Voice → Production deployment

**Parallel Tracks** (can execute simultaneously):
- **Track A (Core Platform)**: Sprints 1-8 (Foundation → RAG)
- **Track B (Voice)**: Sprints 9-10 (Voice Infrastructure)
- **Track C (Automation)**: Sprints 13-14 (PRD Generation)
- **Track D (Observability)**: Sprints 15-16 (Analytics)
- **Track E (Integrations)**: Sprints 17-18 (CRM)

**Risk Mitigation**:
- **Voice Latency**: Allocate 2 weeks for optimization if <500ms not achieved in Sprint 9-10
- **GraphRAG Complexity**: Option to simplify to standard RAG if 35% improvement not realized
- **Multi-tenancy Scale**: Load test at Sprint 6 to validate 100+ tenant capacity

---

## Appendix

### References & Sources

**Industry Research**:
1. LangGraph Production Deployment (2025) - https://langchain-ai.github.io/langgraph/
2. Gemini 2.5 Flash/Pro API Documentation (2025) - https://ai.google.dev/gemini-api/docs
3. Model Context Protocol Specification (2025-06-18) - https://modelcontextprotocol.io/specification/
4. LiveKit Server & SIP Integration - https://docs.livekit.io/sip/
5. Qdrant Multi-Tenancy Architecture - https://qdrant.tech/documentation/guides/multiple-partitions/
6. GraphRAG vs RAG (AWS, 2025) - https://aws.amazon.com/blogs/machine-learning/improving-rag-accuracy-with-graphrag/
7. Sierra AI Technical Architecture Analysis (2025) - TechCrunch, Bloomberg
8. YC AI Startups Technical Approaches (2024-2025) - Y Combinator Company Directory

**Academic & Technical Papers**:
1. "Context Engineering: Bringing Engineering Discipline to Prompts" (2025)
2. "Hybrid GraphRAG: 35% Accuracy Improvement Study" - Lettria/AWS (2025)
3. "Multi-Agent Systems: 15× Token Usage, 90% Performance Gain" - Anthropic Research

**Open Source Projects**:
1. LangGraph GitHub - https://github.com/langchain-ai/langgraph
2. LiveKit GitHub - https://github.com/livekit/livekit
3. Qdrant GitHub - https://github.com/qdrant/qdrant

### Alternative Approaches Considered

**1. Alternative Agentic Frameworks**

| Framework | Pros | Cons | Decision |
|-----------|------|------|----------|
| **CrewAI** | Simpler API, faster development | Less production maturity, limited checkpointing | ❌ Rejected |
| **AutoGen** | Strong multi-agent coordination | Less granular control, harder debugging | ❌ Rejected |
| **Custom (Pure LangChain)** | Maximum flexibility | Reinvent state management, recovery, observability | ❌ Rejected |
| **LangGraph** ✓ | Production-proven, stateful, checkpoint-based | Steeper learning curve | ✅ **Selected** |

**2. Alternative Voice Solutions**

| Solution | Pros | Cons | Decision |
|----------|------|------|----------|
| **Retell AI** | Turnkey, <300ms latency, SOC 2/HIPAA | $0.07/min cost, limited customization | 🟡 Short-term option |
| **Vapi** | Customizable, bring-your-own models | $0.05/min + provider costs, more complexity | 🟡 Alternative |
| **Bland AI** | Self-hosted, guaranteed low latency | $0.09/min premium pricing | ❌ Rejected (cost) |
| **LiveKit** ✓ | Maximum control, $0.03/min at scale | Higher operational overhead | ✅ **Selected** (long-term) |

**3. Alternative LLM Providers**

| Provider | Pros | Cons | Decision |
|----------|------|------|----------|
| **OpenAI GPT-4o** | Fast TTFT (400-500ms), strong reasoning | $5-15/1M tokens, rate limits | 🟡 Backup provider |
| **Claude Opus 4** | Excellent reasoning, long context | $15/1M input, slower TTFT | 🟡 Complex tasks only |
| **Llama 3.1 (self-hosted)** | Full control, no token costs | Infrastructure overhead, fine-tuning needed | ❌ Rejected (complexity) |
| **Gemini 2.5** ✓ | Best price/performance, 2M context, thinking budget | GCP vendor lock-in (mitigated by abstraction) | ✅ **Selected** |

**4. Alternative Database Architectures**

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| **Database-per-tenant** | Maximum isolation, independent scaling | Operational nightmare at 100+ tenants | ❌ Rejected |
| **Schema-per-tenant** | Good isolation, manageable to 100s | Migration complexity, connection pooling issues | 🟡 Enterprise tier only |
| **RLS + Payload Partitioning** ✓ | Scales to millions, minimal overhead | Global queries slower | ✅ **Selected** |

### Future Enhancement Opportunities

**Phase 2 (Months 10-18)**:

1. **Fine-Tuned Models**
   - Fine-tune Gemini Flash on 1000+ customer interactions
   - Expected: 30-50% cost reduction + reliability improvement
   - Target: Intent classification, NER, standardized responses

2. **Automated RL (Reinforcement Learning)**
   - Per-client model training based on conversation outcomes
   - A/B test new models automatically
   - Roll out top performers without manual intervention

3. **Advanced Analytics**
   - Predictive analytics (churn prediction, upsell opportunities)
   - Conversation flow optimization via ML
   - Automated insight generation for customer success

4. **Global Expansion**
   - Multi-region deployment (Asia-Pacific, Europe)
   - Language support (Hindi, Spanish, etc.)
   - Regional compliance (GDPR, data residency)

5. **Agent Marketplace**
   - Template library for common use cases
   - Pre-built integrations (Shopify, Stripe, Zendesk)
   - Community-contributed tools and workflows

**Phase 3 (Months 18-36)**:

1. **On-Premise Deployment Option**
   - Kubernetes Helm charts for self-hosting
   - Air-gapped environment support
   - Enterprise security features (BYOK, audit trails)

2. **Video Agent Capabilities**
   - LiveKit video + screen sharing
   - Visual assistance (product demos, troubleshooting)
   - Multimodal understanding (see + hear customer)

3. **Industry Verticals**
   - Healthcare-specific compliance (HIPAA)
   - Finance-specific (PCI-DSS, SOX)
   - Legal-specific (client-attorney privilege)

---

## Conclusion

This technical architecture provides a production-ready foundation for scaling an AI-powered workflow automation platform from prototype to enterprise deployment. By leveraging battle-tested technologies (LangGraph, Gemini, LiveKit, Qdrant, GCP) and following industry best practices from companies like Sierra AI, LinkedIn, and Uber, the system is designed to achieve:

- **95% automation rate** within 12 months
- **80% cost reduction** vs traditional customer service
- **Sub-500ms voice latency** for conversational AI
- **99.9% uptime SLA** with multi-region deployment
- **Horizontal scalability** to 10,000+ concurrent users

The phased implementation roadmap enables incremental value delivery while maintaining architectural integrity, with clear success criteria and risk mitigation strategies at each sprint.

**Next Steps**:
1. Review and approve architecture with engineering team
2. Set up GCP project and initialize infrastructure (Sprint 1)
3. Begin development of foundation services (Sprints 1-2)
4. Establish monitoring and observability from day one

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Approved By**: [Engineering Lead, CTO]
**Next Review**: End of Sprint 4 (Week 8)
