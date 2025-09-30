# Workflow Automation Platform - Technical Architecture Document

**Version:** 1.0
**Date:** 2025-09-30
**Status:** Design Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Overview](#system-overview)
3. [Architecture Principles](#architecture-principles)
4. [Core Technology Stack](#core-technology-stack)
5. [Microservices Architecture](#microservices-architecture)
6. [LangGraph Workflow Engine](#langgraph-workflow-engine)
7. [LiveKit Voice Integration](#livekit-voice-integration)
8. [YAML-Driven Configuration System](#yaml-driven-configuration-system)
9. [Data Architecture](#data-architecture)
10. [Integration Layer](#integration-layer)
11. [Security & Compliance](#security--compliance)
12. [Deployment & Infrastructure](#deployment--infrastructure)
13. [Monitoring & Observability](#monitoring--observability)
14. [Development Workflow](#development-workflow)
15. [Implementation Roadmap](#implementation-roadmap)
16. [Appendices](#appendices)

---

## Executive Summary

The Workflow Automation Platform is an **AI-powered microservices system** that automates client acquisition, onboarding, and customer success workflows using conversational AI (chatbots and voicebots). The platform leverages proven patterns from production systems (krishna-diagnostics, centuryproptax, ai-shopify) while introducing multi-tenant, configuration-driven architecture for horizontal scaling.

### Key Architectural Decisions

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| **LangGraph 2-Node Pattern** | Proven in production, simple, maintainable | Multi-agent complex graphs |
| **YAML-First Configuration** | Dynamic client onboarding, no code changes | Database-driven configs |
| **FastAPI Microservices** | Async-first, type safety, proven stack | Django, Node.js |
| **Supabase/PostgreSQL** | Managed service, row-level security, real-time | Raw PostgreSQL, MongoDB |
| **LiveKit Agents** | Best-in-class voice AI framework | Custom WebRTC implementation |
| **Model Context Protocol** | Tool integration standard, future-proof | Custom tool interface |

### Critical Success Factors

1. **Configuration Isolation**: Each client's YAML config operates in isolated environment
2. **Horizontal Scalability**: Add capacity by deploying more instances, not code changes
3. **Voice Quality**: <500ms latency, natural conversation flow
4. **Developer Velocity**: New client onboarding in <2 days vs weeks
5. **Operational Excellence**: 99.9% uptime with automated incident response

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLIENT INTERACTION LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   WhatsApp   │  │  Instagram   │  │    Voice     │             │
│  │   Messages   │  │   Messages   │  │    Calls     │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
└─────────┼──────────────────┼──────────────────┼────────────────────┘
          │                  │                  │
          └──────────────────┴──────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                         API GATEWAY (Kong/NGINX)                     │
│                     Rate Limiting │ Auth │ Routing                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                      MICROSERVICES LAYER                             │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │   Research   │  │     Demo     │  │    PRD       │              │
│  │   Engine     │  │  Generator   │  │   Builder    │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                  │                  │                      │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐              │
│  │  Automation  │  │  Monitoring  │  │   Customer   │              │
│  │   Engine     │  │   Engine     │  │   Success    │              │
│  └──────┬───────┘  └──────────────┘  └──────────────┘              │
└─────────┼──────────────────────────────────────────────────────────┘
          │
┌─────────▼──────────────────────────────────────────────────────────┐
│                    CORE WORKFLOW LAYER                               │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              LangGraph Orchestrator                          │   │
│  │                                                               │   │
│  │  ┌──────────┐          ┌──────────┐        ┌──────────┐    │   │
│  │  │  Agent   │◄────────►│   Tool   │◄──────►│  State   │    │   │
│  │  │   Node   │          │   Node   │        │  Store   │    │   │
│  │  └──────────┘          └──────────┘        └──────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              LiveKit Voice Agent Layer                       │   │
│  │    VAD → STT → LLM → TTS → Audio Streaming                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                         DATA LAYER                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  PostgreSQL  │  │   Pinecone   │  │    Redis     │              │
│  │ (Transact.)  │  │  (Vectors)   │  │  (Cache)     │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└──────────────────────────────────────────────────────────────────┘
```

### System Components

#### External-Facing Services (12)
1. **Research Engine** - Web scraping, social media analysis, competitive research
2. **Demo Generator** - Dynamic chatbot/voicebot creation with mock data
3. **NDA Generator** - Legal document templating and e-signature workflow
4. **Pricing Model Generator** - Dynamic pricing based on use case analysis
5. **Proposal Generator** - Collaborative document editing with canvas UI
6. **PRD Builder Engine** - Conversational requirements gathering
7. **Automation Engine** - YAML config generation and bot orchestration
8. **Monitoring Engine** - System health, flow quality, proactive alerts
9. **Customer Success Engine** - KPI calculation, insight generation, PPT automation
10. **KPI Finder Agent** - A/B testing, baseline measurement, optimization
11. **Support Automation** - Email triage, ticket routing, documentation
12. **CRM Integration Service** - Client lifecycle tracking across humans and AI

#### Internal Services (6)
13. **Config Manager** - YAML validation, versioning, hot-reloading
14. **Tool Registry** - Dynamic tool loading, GitHub issue automation
15. **Integration Manager** - API connectors, webhook handlers, retry logic
16. **State Manager** - Conversation persistence, checkpoint management
17. **Analytics Service** - Metrics aggregation, reporting, dashboards
18. **Auth Service** - OAuth 2.1, token management, RBAC

---

## Architecture Principles

### Design Philosophy

1. **Configuration Over Code**: New clients onboarded via YAML, not deployments
2. **Event-Driven First**: Async messaging for scalability and resilience
3. **Stateless Services**: All state in databases, enable horizontal scaling
4. **Contract-First API**: OpenAPI specs drive implementation
5. **Observability Built-In**: Every service exports metrics, logs, traces
6. **Security by Default**: Zero-trust, encryption everywhere, least privilege

### Proven Patterns from Production

From **krishna-diagnostics**, **centuryproptax**, **ai-shopify**:

```python
# ✅ Proven: 2-Node LangGraph Architecture
StateGraph → Agent Node (LLM) + Tool Node (Functions)

# ✅ Proven: Simple State Structure
State = TypedDict({
    "messages": Annotated[list[AnyMessage], add_messages],
    "user_context": dict,  # Customer profile data
    "session_id": str
})

# ✅ Proven: Conditional Routing
builder.add_conditional_edges(
    "agent",
    tools_condition,  # Built-in: routes to tools or END
    ["tools", END]
)

# ✅ Proven: LiveKit Voice Pattern
AgentSession(
    vad=silero.VAD.load(),
    stt=deepgram.STT(model="nova-3"),
    llm=openai.LLM(model="gpt-4o-mini"),
    tts=elevenlabs.TTS()
)
```

### New Patterns for Multi-Tenancy

```python
# 🆕 YAML-Driven Bot Initialization
config = load_client_config(config_id)  # From YAML
tools = [registry.get_tool(t) for t in config.tools]
llm = model_factory.create(config.llm_config)

# 🆕 Client Isolation
@with_client_context(config_id)
async def handle_message(message, ctx):
    # Automatic DB, cache, metrics isolation
    state = await ctx.state_store.get(session_id)
```

---

## Core Technology Stack

### Primary Technologies

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| **Workflow Engine** | LangGraph | 0.2.0+ | Stateful agent orchestration, proven in production |
| **Voice AI** | LiveKit Agents | 1.0+ | Real-time audio, framework for voicebots |
| **API Framework** | FastAPI | 0.115+ | Async-first, auto-docs, type safety |
| **LLM Provider** | OpenAI/Anthropic | GPT-4o/Claude-3.5 | Best accuracy for complex reasoning |
| **Database** | Supabase (PostgreSQL) | 15+ | Managed, RLS, real-time subscriptions |
| **Vector DB** | Pinecone | Latest | Semantic search, RAG capabilities |
| **Cache/Sessions** | Redis | 7.0+ | Sub-ms latency, pub/sub for real-time |
| **Message Queue** | RabbitMQ | 3.12+ | Reliable async processing, retry logic |
| **Observability** | Langfuse + Grafana | Latest | LLM tracing + infrastructure metrics |

### Supporting Technologies

```python
# requirements.txt (derived from production systems)
fastapi>=0.115.0
uvicorn[standard]>=0.30.0
langgraph>=0.2.0
langchain>=0.3.0
langchain-openai>=0.2.0
langchain-anthropic>=0.2.0
livekit-agents[openai,deepgram,elevenlabs,silero]>=1.0
pydantic>=2.0
sqlalchemy[asyncio]>=2.0
asyncpg>=0.29.0
redis[asyncio]>=5.0
pinecone-client>=3.0
supabase-py>=2.0
langfuse>=2.50.0
pyyaml>=6.0
jinja2>=3.1.0  # Document templates
aiohttp>=3.9.0
python-jose[cryptography]>=3.3.0  # JWT
passlib[bcrypt]>=1.7.4
playwright>=1.40.0  # Web scraping
beautifulsoup4>=4.12.0
pydantic-settings>=2.0
python-dotenv>=1.0.0
structlog>=24.0.0
prometheus-client>=0.20.0
opentelemetry-api>=1.20.0
opentelemetry-sdk>=1.20.0
```

### Third-Party Services

| Service | Purpose | Fallback Strategy |
|---------|---------|-------------------|
| **OpenAI API** | Primary LLM | Anthropic Claude |
| **Deepgram** | Speech-to-Text | Google STT |
| **ElevenLabs** | Text-to-Speech | OpenAI TTS |
| **Twilio** | Phone/SMS | Plivo |
| **Supabase** | Database hosting | Self-hosted PostgreSQL |
| **Pinecone** | Vector search | pgvector extension |
| **Adobe Sign** | E-signatures | DocuSign |

---

## Microservices Architecture

### Service Breakdown

#### 1. Research Engine Service

**Responsibility**: Automated prospect research from multiple data sources

**Technology**:
- Playwright for web scraping (JavaScript rendering)
- BeautifulSoup4 for HTML parsing
- LangChain for LLM-powered analysis
- Redis for rate limiting external APIs

**API Endpoints**:
```python
POST /research/initiate
  → Body: { client_name, domains, social_profiles }
  → Returns: { research_id, estimated_completion }

GET /research/{research_id}/status
  → Returns: { status, progress_pct, partial_results }

GET /research/{research_id}/report
  → Returns: {
      company_profile,
      social_metrics,
      competitors,
      talking_points,
      pain_points
    }
```

**Data Sources**:
- Instagram Graph API (engagement metrics)
- Facebook Pages API (reviews, posts)
- Google Maps API (reviews, ratings)
- Reddit API (community sentiment)
- Manual calls (human-in-the-loop research via support agents)

**Architecture**:
```
FastAPI Service → Async Task Queue (Celery/RQ) → Research Workers
                                                      │
                  ┌───────────────────────────────────┴────────────────┐
                  │                                                     │
            Web Scraper Pool                                    LLM Analyzer
         (Playwright instances)                          (OpenAI/Claude API)
                  │                                                     │
                  └──────────────►  Redis (Results) ◄─────────────────┘
```

#### 2. Demo Generator Service

**Responsibility**: Create functional chatbot/voicebot demos with mock data

**Key Features**:
- Generate LangGraph workflow from use case description
- Create mock tools (fake API responses for demos)
- Deploy to sandbox environment with unique URL
- Developer iteration loop for fixes

**Demo Generation Flow**:
```python
class DemoGenerator:
    async def generate_demo(
        self,
        research_data: ResearchReport,
        use_case: str,
        modality: Literal["chat", "voice", "both"]
    ) -> Demo:
        # 1. Extract relevant industry context
        context = await self.llm.extract_context(research_data)

        # 2. Generate system prompt
        prompt = await self.prompt_builder.create(use_case, context)

        # 3. Select mock tools
        tools = await self.tool_selector.select_for_usecase(use_case)

        # 4. Create YAML config
        config = self.config_builder.build(prompt, tools, modality)

        # 5. Deploy to sandbox
        demo_url = await self.deployer.deploy_sandbox(config)

        # 6. Run automated tests
        test_results = await self.tester.run_smoke_tests(demo_url)

        return Demo(url=demo_url, config=config, tests=test_results)
```

**Architecture**:
```
Demo Generator API → Config Builder → Sandbox Orchestrator
                                            │
                    ┌───────────────────────┴───────────────┐
                    │                                       │
            Docker Container                          Kubernetes Pod
         (Isolated Environment)                  (LiveKit Voice Agent)
                    │                                       │
                    └─────────► Load Balancer ◄────────────┘
                                      │
                              Demo URL (public)
```

#### 3. Automation Engine Service

**Responsibility**: YAML config management and multi-client bot orchestration

**Core Logic**:
```python
# config_loader.py
class ConfigManager:
    def __init__(self):
        self.configs: dict[str, ClientConfig] = {}
        self.watcher = FileSystemWatcher()

    async def load_config(self, config_id: str) -> ClientConfig:
        """Load and validate YAML config"""
        yaml_path = f"configs/{config_id}.yaml"
        config = await self.validator.validate(yaml_path)

        # Check tool availability
        missing_tools = []
        for tool_name in config.tools:
            if not self.tool_registry.has(tool_name):
                issue = await self.github.create_tool_issue(tool_name)
                missing_tools.append((tool_name, issue.url))

        # Check integration availability
        missing_integrations = []
        for integration in config.integrations:
            if not self.integration_manager.has(integration):
                issue = await self.github.create_integration_issue(integration)
                missing_integrations.append((integration, issue.url))

        config.missing_tools = missing_tools
        config.missing_integrations = missing_integrations

        return config

    async def watch_for_changes(self):
        """Hot-reload configs on file change"""
        async for event in self.watcher.watch("configs/"):
            if event.type == "modified":
                config_id = Path(event.path).stem
                await self.reload_config(config_id)
                await self.notify_running_agents(config_id)
```

**YAML Config Schema**:
```yaml
# Example: configs/acme-corp-sales.yaml
version: "1.0"
client:
  id: "acme-corp"
  name: "Acme Corporation"
  use_case: "inbound_sales"
  vertical: "b2b_saas"

workflow:
  system_prompt: |
    You are a sales assistant for Acme Corp, a B2B SaaS company...

  tools:
    - name: "search_product_catalog"
      enabled: true
    - name: "check_pricing"
      enabled: true
      config:
        discount_authority: 0.15  # Max 15% discount
    - name: "schedule_demo"
      enabled: true
    - name: "create_crm_lead"
      enabled: true
      integration: "salesforce"
    - name: "transfer_to_human"
      enabled: true
      config:
        business_hours: "9am-5pm EST"
        overflow_message: "Our team will call you back within 2 hours"

  integrations:
    input_channels:
      - type: "whatsapp"
        phone_number: "+1234567890"
      - type: "instagram"
        page_id: "acme_official"
      - type: "web_chat"
        widget_url: "https://acme.com/chat"

    output_channels:
      - type: "email"
        from: "support@acme.com"
      - type: "sms"
        provider: "twilio"

    crm:
      type: "salesforce"
      instance_url: "https://acme.salesforce.com"
      credentials_secret: "salesforce-acme-prod"

    database:
      type: "supabase"
      project_ref: "acme-prod"
      schema: "public"
      tables:
        leads: "acme_leads"
        conversations: "acme_conversations"

voice:
  enabled: true
  config:
    vad: "silero"
    stt:
      provider: "deepgram"
      model: "nova-3"
      language: "en-US"
    llm:
      provider: "openai"
      model: "gpt-4o-realtime-preview"
    tts:
      provider: "elevenlabs"
      voice_id: "professional_male_1"
      stability: 0.7
      similarity_boost: 0.8

behavior:
  pii_collection:
    enabled: true
    fields:
      - name
      - email
      - phone
      - company

  follow_ups:
    enabled: true
    triggers:
      - condition: "no_response_24h"
        action: "send_followup_email"
      - condition: "high_intent_no_booking"
        action: "schedule_outbound_call"

  cross_sell_upsell:
    enabled: true
    products:
      - "premium_plan"
      - "addon_analytics"

  human_handoff:
    triggers:
      - "explicit_request"
      - "negative_sentiment_3_consecutive"
      - "complex_technical_question"
      - "pricing_above_authority"
    mode: "warm_transfer"  # or "create_ticket"

  survey_questions:
    - "How did you hear about us?"
    - "What's your primary use case?"
    - "What's your timeline for implementation?"

monitoring:
  log_events:
    - "conversation_start"
    - "tool_invocation"
    - "human_handoff"
    - "error_occurred"
    - "conversation_end"

  alerts:
    - metric: "error_rate"
      threshold: 0.05
      window: "5m"
      severity: "critical"
    - metric: "average_response_time"
      threshold: 2000  # ms
      window: "1m"
      severity: "warning"
```

**Bot Orchestration**:
```python
class BotOrchestrator:
    """Manages lifecycle of all client bots"""

    def __init__(self):
        self.running_bots: dict[str, BotInstance] = {}
        self.config_manager = ConfigManager()

    async def start_bot(self, config_id: str):
        """Initialize and start a bot for a client"""
        config = await self.config_manager.load_config(config_id)

        # Create LangGraph workflow
        workflow = self.workflow_factory.create(config)

        # Initialize LiveKit agent if voice enabled
        voice_agent = None
        if config.voice.enabled:
            voice_agent = self.voice_factory.create(config)

        # Start message consumers for input channels
        consumers = await self.start_consumers(config)

        bot = BotInstance(
            config=config,
            workflow=workflow,
            voice_agent=voice_agent,
            consumers=consumers
        )

        self.running_bots[config_id] = bot
        await bot.start()

    async def handle_message(
        self,
        config_id: str,
        channel: str,
        message: Message
    ):
        """Route incoming message to appropriate bot"""
        bot = self.running_bots[config_id]

        # Get or create session
        session = await bot.get_session(message.user_id)

        # Invoke LangGraph workflow
        result = await bot.workflow.ainvoke(
            {"messages": [message.to_langchain()]},
            config={"configurable": {"session_id": session.id}}
        )

        # Send response via output channel
        await bot.send_response(channel, result["messages"][-1])
```

#### 4. Monitoring Engine Service

**Responsibility**: System health, LLM quality, proactive alerting

**Monitoring Layers**:
```
┌─────────────────────────────────────────────────────────────┐
│                     Monitoring Engine                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Infrastructure│  │  Application │  │     LLM      │     │
│  │   Metrics     │  │    Metrics   │  │   Quality    │     │
│  │               │  │              │  │              │     │
│  │ • CPU/Memory  │  │ • Latency    │  │ • Sentiment  │     │
│  │ • Disk I/O    │  │ • Throughput │  │ • Coherence  │     │
│  │ • Network     │  │ • Errors     │  │ • Hallucin.  │     │
│  └──────┬────────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
│                   ┌────────▼────────┐                       │
│                   │  Alert Manager  │                       │
│                   │  (Prometheus)   │                       │
│                   └────────┬────────┘                       │
│                            │                                │
│         ┌──────────────────┼──────────────────┐            │
│         │                  │                  │            │
│    ┌────▼────┐      ┌──────▼──────┐    ┌─────▼─────┐      │
│    │ PagerDuty│      │   Slack     │    │   Email   │      │
│    │ (On-call)│      │ (Team)      │    │  (Client) │      │
│    └──────────┘      └─────────────┘    └───────────┘      │
└──────────────────────────────────────────────────────────────┘
```

**LLM Quality Monitoring**:
```python
class LLMQualityMonitor:
    """Monitor conversation quality in real-time"""

    async def analyze_conversation(
        self,
        config_id: str,
        session_id: str,
        messages: list[Message]
    ) -> QualityMetrics:
        # 1. Sentiment Analysis
        sentiment = await self.sentiment_analyzer.analyze(messages)

        # 2. Coherence Check (topic drift)
        coherence = await self.coherence_checker.check(messages)

        # 3. Hallucination Detection
        hallucinations = await self.hallucination_detector.detect(messages)

        # 4. Response Appropriateness
        appropriateness = await self.appropriateness_checker.check(
            messages,
            context=await self.get_client_context(config_id)
        )

        metrics = QualityMetrics(
            sentiment=sentiment,
            coherence=coherence,
            hallucinations=hallucinations,
            appropriateness=appropriateness
        )

        # Trigger alerts if thresholds breached
        if metrics.requires_intervention():
            await self.alert_manager.send_alert(
                severity="high",
                message=f"Quality issue in {config_id}/{session_id}",
                metrics=metrics
            )

        return metrics
```

**Incident Response Automation**:
```python
class IncidentManager:
    """Automated incident response"""

    async def handle_incident(self, incident: Incident):
        # 1. Create incident ticket
        ticket = await self.ticketing.create(
            title=incident.title,
            severity=incident.severity,
            affected_clients=[incident.config_id]
        )

        # 2. Notify on-call engineer
        await self.pagerduty.trigger(ticket)

        # 3. If client SLA breached, auto-refund calculation
        if incident.breaches_sla:
            refund = await self.calculate_sla_refund(incident)
            await self.billing.queue_credit(incident.config_id, refund)

        # 4. Generate RCA template
        rca = await self.rca_generator.generate_template(incident)
        await self.ticketing.attach_rca(ticket.id, rca)

        # 5. Client notification
        await self.notify_client(
            config_id=incident.config_id,
            incident=incident,
            ticket=ticket
        )
```

---

## LangGraph Workflow Engine

### Core Architecture Pattern

**Proven 2-Node Design** (from production systems):

```python
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.checkpoint.memory import InMemorySaver
from typing import Annotated, TypedDict
from langchain_core.messages import AnyMessage, add_messages

# State Definition
class ConversationState(TypedDict):
    """Minimal state structure for maintainability"""
    messages: Annotated[list[AnyMessage], add_messages]
    session_id: str
    config_id: str
    user_context: dict  # Customer profile, conversation history

# Workflow Builder
class WorkflowFactory:
    """Creates LangGraph workflows from YAML configs"""

    def create(self, config: ClientConfig) -> StateGraph:
        # Initialize LLM with client-specific config
        llm = self._create_llm(config.workflow.llm_config)

        # Load tools
        tools = [
            self.tool_registry.get(t.name)
            for t in config.workflow.tools
            if t.enabled
        ]

        # Bind tools to LLM
        llm_with_tools = llm.bind_tools(tools)

        # Create graph
        builder = StateGraph(ConversationState)

        # Agent node: LLM reasoning
        def agent(state: ConversationState) -> dict:
            # Add system prompt
            system_message = SystemMessage(content=config.workflow.system_prompt)
            messages = [system_message] + state["messages"]

            # Invoke LLM
            response = llm_with_tools.invoke(messages)

            return {"messages": [response]}

        # Tool node: Function execution
        tool_node = ToolNode(tools)

        # Build graph
        builder.add_node("agent", agent)
        builder.add_node("tools", tool_node)

        # Routing logic
        builder.add_edge(START, "agent")
        builder.add_conditional_edges(
            "agent",
            tools_condition,  # Routes to "tools" if tool calls, else END
            ["tools", END]
        )
        builder.add_edge("tools", "agent")  # Loop back after tool execution

        # Add checkpointing for conversation persistence
        checkpointer = self._create_checkpointer(config)

        return builder.compile(checkpointer=checkpointer)
```

### Tool System

**Dynamic Tool Loading**:
```python
class ToolRegistry:
    """Central registry for all tools across clients"""

    def __init__(self):
        self.tools: dict[str, ToolDefinition] = {}
        self._discover_tools()

    def _discover_tools(self):
        """Auto-discover tools from tools/ directory"""
        for module in Path("tools/").glob("*.py"):
            tools = self._extract_tools(module)
            for tool in tools:
                self.register(tool)

    def register(self, tool: ToolDefinition):
        """Register a tool for use in workflows"""
        self.tools[tool.name] = tool

    def get(self, name: str) -> BaseTool:
        """Retrieve tool by name"""
        if name not in self.tools:
            raise ToolNotFoundError(
                f"Tool '{name}' not found. "
                f"GitHub issue may exist for implementation."
            )
        return self.tools[name].create_instance()

# Example Tool Definition
from langchain_core.tools import tool

@tool
async def search_product_catalog(
    query: str,
    filters: dict = None,
    ctx: RunContext = None
) -> list[dict]:
    """Search product catalog for relevant items.

    Args:
        query: Natural language search query
        filters: Optional filters (category, price range, etc)
        ctx: Runtime context (client config, session, etc)

    Returns:
        List of matching products with details
    """
    client_config = ctx.config
    db = ctx.database

    # Client-specific catalog
    products = await db.query(
        "SELECT * FROM products WHERE client_id = $1 AND search @@ $2",
        client_config.client.id,
        query
    )

    if filters:
        products = [p for p in products if matches_filters(p, filters)]

    return products
```

**Tool Interface Specification**:
```python
class ToolDefinition:
    name: str
    description: str
    input_schema: dict  # JSON Schema for validation
    output_schema: dict
    requires_auth: bool = False
    timeout_seconds: int = 30
    retry_policy: RetryPolicy = RetryPolicy.EXPONENTIAL

    # GitHub automation
    github_issue_template: str = """
    ## Tool: {name}

    ### Description
    {description}

    ### Input Schema
    ```json
    {input_schema}
    ```

    ### Output Schema
    ```json
    {output_schema}
    ```

    ### Required By
    - Config: {config_id}
    - Use Case: {use_case}

    ### Implementation Notes
    - Timeout: {timeout_seconds}s
    - Authentication: {requires_auth}
    - Retry: {retry_policy}
    """
```

### State Management

**Conversation Persistence**:
```python
class StateManager:
    """Manages conversation state with multi-backend support"""

    def __init__(self, config: ClientConfig):
        # Use Redis for high-frequency access
        self.cache = RedisCheckpointer(
            url=config.integrations.cache_url,
            ttl=3600  # 1 hour
        )

        # Use PostgreSQL for long-term storage
        self.storage = PostgresCheckpointer(
            db=config.integrations.database
        )

    async def save_checkpoint(
        self,
        session_id: str,
        state: ConversationState
    ):
        """Save conversation checkpoint"""
        checkpoint = {
            "session_id": session_id,
            "state": state,
            "timestamp": datetime.utcnow(),
            "config_id": state["config_id"]
        }

        # Write-through cache
        await self.cache.set(session_id, checkpoint)
        await self.storage.save(checkpoint)

    async def load_checkpoint(
        self,
        session_id: str
    ) -> ConversationState | None:
        """Load conversation checkpoint"""
        # Try cache first
        checkpoint = await self.cache.get(session_id)
        if checkpoint:
            return checkpoint["state"]

        # Fallback to storage
        checkpoint = await self.storage.load(session_id)
        if checkpoint:
            # Warm cache
            await self.cache.set(session_id, checkpoint)
            return checkpoint["state"]

        return None
```

---

## LiveKit Voice Integration

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    LiveKit Voice Agent                       │
│                                                              │
│  Audio In → VAD → STT → LangGraph → LLM → TTS → Audio Out  │
│             │     │                   │      │               │
│          Silero Deepgram           OpenAI  ElevenLabs       │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
from livekit.agents import (
    Agent, AgentSession, JobContext, WorkerOptions, cli
)
from livekit.plugins import deepgram, elevenlabs, openai, silero

class VoiceAgentFactory:
    """Creates LiveKit voice agents from YAML configs"""

    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager

    async def create_entrypoint(self, config_id: str):
        """Generate entrypoint function for LiveKit worker"""
        config = await self.config_manager.load_config(config_id)

        async def entrypoint(ctx: JobContext):
            await ctx.connect()

            # Create agent with client-specific config
            agent = Agent(
                instructions=config.workflow.system_prompt,
                tools=self._load_tools(config)
            )

            # Configure voice pipeline
            session = AgentSession(
                vad=silero.VAD.load(),
                stt=self._create_stt(config.voice.config.stt),
                llm=self._create_llm(config.voice.config.llm),
                tts=self._create_tts(config.voice.config.tts)
            )

            # Start session
            await session.start(agent=agent, room=ctx.room)

            # Generate greeting
            await session.generate_reply(
                instructions="Greet the user and ask how you can help"
            )

        return entrypoint

    def _create_stt(self, stt_config: STTConfig) -> STT:
        """Create Speech-to-Text provider"""
        if stt_config.provider == "deepgram":
            return deepgram.STT(
                model=stt_config.model,
                language=stt_config.language
            )
        elif stt_config.provider == "openai":
            return openai.STT()
        else:
            raise ValueError(f"Unknown STT provider: {stt_config.provider}")

    def _create_llm(self, llm_config: LLMConfig) -> LLM:
        """Create LLM provider for voice"""
        if llm_config.provider == "openai":
            # Use Realtime API for low latency
            return openai.realtime.RealtimeModel(
                model=llm_config.model,
                voice=llm_config.get("voice", "alloy")
            )
        elif llm_config.provider == "anthropic":
            return anthropic.LLM(model=llm_config.model)
        else:
            raise ValueError(f"Unknown LLM provider: {llm_config.provider}")

    def _create_tts(self, tts_config: TTSConfig) -> TTS:
        """Create Text-to-Speech provider"""
        if tts_config.provider == "elevenlabs":
            return elevenlabs.TTS(
                voice_id=tts_config.voice_id,
                stability=tts_config.stability,
                similarity_boost=tts_config.similarity_boost
            )
        elif tts_config.provider == "openai":
            return openai.TTS(voice=tts_config.voice_id)
        else:
            raise ValueError(f"Unknown TTS provider: {tts_config.provider}")

    def _load_tools(self, config: ClientConfig) -> list[BaseTool]:
        """Load tools for voice agent"""
        tools = []
        for tool_config in config.workflow.tools:
            if tool_config.enabled:
                tool = self.tool_registry.get(tool_config.name)
                tools.append(tool)
        return tools

# Worker Launcher
class VoiceWorkerManager:
    """Manages LiveKit voice workers for all clients"""

    def __init__(self):
        self.workers: dict[str, LiveKitWorker] = {}

    async def start_worker(self, config_id: str):
        """Start LiveKit worker for client config"""
        config = await self.config_manager.load_config(config_id)

        if not config.voice.enabled:
            return

        entrypoint = await self.voice_factory.create_entrypoint(config_id)

        worker = cli.run_app(
            WorkerOptions(entrypoint_fnc=entrypoint),
            background=True
        )

        self.workers[config_id] = worker
```

### Voice-Specific Features

**Human Handoff Detection**:
```python
class VoiceHandoffDetector:
    """Detects when to transfer voice call to human"""

    async def should_handoff(
        self,
        conversation: list[Message],
        config: ClientConfig
    ) -> bool:
        triggers = config.behavior.human_handoff.triggers

        # Check explicit request
        if "explicit_request" in triggers:
            if await self._detect_explicit_request(conversation):
                return True

        # Check sentiment
        if "negative_sentiment_3_consecutive" in triggers:
            if await self._detect_negative_sentiment(conversation, n=3):
                return True

        # Check complexity
        if "complex_technical_question" in triggers:
            if await self._detect_complex_question(conversation):
                return True

        return False

    async def _detect_explicit_request(
        self,
        conversation: list[Message]
    ) -> bool:
        """Detect phrases like 'speak to a human', 'transfer me'"""
        keywords = [
            "human", "person", "agent", "representative",
            "transfer", "escalate", "speak to someone"
        ]
        last_message = conversation[-1].content.lower()
        return any(kw in last_message for kw in keywords)
```

**Voice Analytics**:
```python
class VoiceAnalytics:
    """Track voice-specific metrics"""

    async def analyze_call(self, call_id: str) -> VoiceMetrics:
        call = await self.db.get_call(call_id)

        return VoiceMetrics(
            duration_seconds=call.duration,
            interruptions=self._count_interruptions(call.transcript),
            sentiment=await self._analyze_sentiment(call.transcript),
            response_latency_ms=self._calculate_latency(call.events),
            user_satisfaction=await self._infer_satisfaction(call),
            handoff_occurred=call.handoff_timestamp is not None
        )
```

---

## YAML-Driven Configuration System

### Config Lifecycle

```
1. Create     → YAML file in configs/
2. Validate   → Schema check, tool/integration availability
3. Deploy     → Bot instance created, consumers started
4. Hot-Reload → File change detected, bot updated without downtime
5. Version    → Git-based versioning, rollback capability
```

### Config Validation

```python
from pydantic import BaseModel, Field, validator
from typing import Literal

class ClientConfig(BaseModel):
    """Validated YAML config schema"""

    version: Literal["1.0"]
    client: ClientInfo
    workflow: WorkflowConfig
    voice: VoiceConfig | None
    behavior: BehaviorConfig
    monitoring: MonitoringConfig

    @validator("workflow")
    def validate_tools(cls, v, values):
        """Check tool availability"""
        tool_registry = get_tool_registry()
        missing = []

        for tool in v.tools:
            if not tool_registry.has(tool.name):
                missing.append(tool.name)

        if missing:
            raise ValueError(
                f"Missing tools: {missing}. "
                f"GitHub issues will be created automatically."
            )

        return v

    @validator("workflow")
    def validate_integrations(cls, v, values):
        """Check integration availability"""
        integration_manager = get_integration_manager()
        missing = []

        for integration in v.integrations.all():
            if not integration_manager.has(integration.type):
                missing.append(integration.type)

        if missing:
            raise ValueError(
                f"Missing integrations: {missing}. "
                f"GitHub issues will be created automatically."
            )

        return v

class ConfigValidator:
    """Comprehensive config validation"""

    async def validate(self, yaml_path: Path) -> ClientConfig:
        # 1. YAML syntax
        try:
            with open(yaml_path) as f:
                data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise ConfigError(f"Invalid YAML syntax: {e}")

        # 2. Schema validation (Pydantic)
        try:
            config = ClientConfig(**data)
        except ValidationError as e:
            raise ConfigError(f"Schema validation failed: {e}")

        # 3. Business logic validation
        await self._validate_business_rules(config)

        # 4. Security checks
        await self._validate_security(config)

        return config

    async def _validate_business_rules(self, config: ClientConfig):
        """Validate business logic constraints"""
        # Check pricing authority limits
        for tool in config.workflow.tools:
            if tool.name == "check_pricing":
                if tool.config.get("discount_authority", 0) > 0.20:
                    raise ConfigError(
                        "Discount authority cannot exceed 20%"
                    )

        # Check voice config if enabled
        if config.voice and config.voice.enabled:
            if not config.voice.config:
                raise ConfigError(
                    "Voice config required when voice.enabled=true"
                )

    async def _validate_security(self, config: ClientConfig):
        """Security validation"""
        # No hardcoded credentials
        config_str = yaml.dump(config.dict())
        if any(pattern in config_str for pattern in [
            "password", "api_key", "secret", "token"
        ]):
            raise ConfigError(
                "Hardcoded credentials detected. "
                "Use secrets manager references."
            )

        # Validate secrets exist
        for secret_ref in config.get_secret_refs():
            if not await self.secrets_manager.exists(secret_ref):
                raise ConfigError(
                    f"Secret not found: {secret_ref}"
                )
```

### GitHub Issue Automation

```python
class GitHubIntegration:
    """Automate GitHub issue creation for missing tools/integrations"""

    def __init__(self, repo: str, token: str):
        self.client = Github(token)
        self.repo = self.client.get_repo(repo)

    async def create_tool_issue(
        self,
        tool_name: str,
        config_id: str,
        use_case: str
    ) -> Issue:
        """Create GitHub issue for missing tool"""
        tool_def = self._get_tool_definition_from_config(tool_name)

        issue_body = f"""
## Tool Implementation Request

**Tool Name:** `{tool_name}`

**Required By:**
- Config ID: `{config_id}`
- Use Case: `{use_case}`

**Expected Interface:**

```python
@tool
async def {tool_name}(
    {self._generate_args(tool_def.input_schema)}
) -> {tool_def.output_type}:
    \"\"\"
    {tool_def.description}
    \"\"\"
    pass
```

**Input Schema:**
```json
{json.dumps(tool_def.input_schema, indent=2)}
```

**Output Schema:**
```json
{json.dumps(tool_def.output_schema, indent=2)}
```

**Implementation Notes:**
- Timeout: {tool_def.timeout_seconds}s
- Authentication Required: {tool_def.requires_auth}
- Retry Policy: {tool_def.retry_policy}

**Acceptance Criteria:**
- [ ] Tool implements expected interface
- [ ] Unit tests added with >80% coverage
- [ ] Integration test with LangGraph workflow
- [ ] Documentation in tools/README.md
- [ ] Added to ToolRegistry
"""

        issue = self.repo.create_issue(
            title=f"Implement Tool: {tool_name}",
            body=issue_body,
            labels=["tool", "automation-required", "priority:high"]
        )

        return issue

    async def create_integration_issue(
        self,
        integration_type: str,
        config_id: str,
        details: dict
    ) -> Issue:
        """Create GitHub issue for missing integration"""
        issue_body = f"""
## Integration Implementation Request

**Integration Type:** `{integration_type}`

**Required By:**
- Config ID: `{config_id}`

**Configuration:**
```yaml
{yaml.dump(details, indent=2)}
```

**Implementation Requirements:**
- [ ] Connector class for {integration_type}
- [ ] Authentication/authorization handling
- [ ] Rate limiting and retry logic
- [ ] Error handling and logging
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests with real API (sandboxed)
- [ ] Documentation in integrations/README.md
- [ ] Added to IntegrationManager

**API Documentation:**
{self._get_api_docs_link(integration_type)}
"""

        issue = self.repo.create_issue(
            title=f"Implement Integration: {integration_type}",
            body=issue_body,
            labels=["integration", "automation-required", "priority:high"]
        )

        return issue
```

---

## Data Architecture

### Database Schema

**Multi-Tenant PostgreSQL with Row-Level Security (RLS)**:

```sql
-- Enable RLS
ALTER TABLE ALL IN SCHEMA public ENABLE ROW LEVEL SECURITY;

-- Client Isolation
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    config_id VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policy
CREATE POLICY client_isolation ON clients
    FOR ALL
    USING (config_id = current_setting('app.current_config_id'));

-- Customer Profiles (per client)
CREATE TABLE customer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_id VARCHAR(100) NOT NULL REFERENCES clients(config_id),

    -- Identity
    external_id VARCHAR(255),  -- Client's customer ID
    phone VARCHAR(50),
    email VARCHAR(255),
    name VARCHAR(255),

    -- Engagement
    first_contact_date TIMESTAMPTZ,
    last_contact_date TIMESTAMPTZ,
    total_conversations INT DEFAULT 0,

    -- PII Collected
    pii_data JSONB,

    -- Metadata
    source_channel VARCHAR(50),  -- whatsapp, instagram, web
    user_context JSONB,  -- Client-specific data

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Indexes
    UNIQUE(config_id, external_id),
    INDEX idx_customer_phone (config_id, phone),
    INDEX idx_customer_email (config_id, email)
);

-- RLS Policy
CREATE POLICY customer_isolation ON customer_profiles
    FOR ALL
    USING (config_id = current_setting('app.current_config_id'));

-- Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_id VARCHAR(100) NOT NULL REFERENCES clients(config_id),
    customer_id UUID NOT NULL REFERENCES customer_profiles(id),

    -- Session Info
    session_id VARCHAR(255) NOT NULL,
    channel VARCHAR(50) NOT NULL,  -- chat, voice, email

    -- Content
    messages JSONB NOT NULL,  -- Full conversation history
    checkpoint JSONB,  -- LangGraph state checkpoint

    -- Metadata
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    duration_seconds INT,

    -- Quality Metrics
    sentiment_score FLOAT,
    quality_score FLOAT,
    human_handoff_occurred BOOLEAN DEFAULT FALSE,

    INDEX idx_conversation_session (config_id, session_id),
    INDEX idx_conversation_customer (config_id, customer_id),
    INDEX idx_conversation_date (config_id, started_at)
);

CREATE POLICY conversation_isolation ON conversations
    FOR ALL
    USING (config_id = current_setting('app.current_config_id'));

-- Message Log (detailed)
CREATE TABLE message_log (
    id BIGSERIAL PRIMARY KEY,
    config_id VARCHAR(100) NOT NULL,
    conversation_id UUID NOT NULL REFERENCES conversations(id),

    -- Message Details
    role VARCHAR(20) NOT NULL,  -- user, assistant, system, tool
    content TEXT NOT NULL,

    -- Tool Invocations
    tool_calls JSONB,
    tool_results JSONB,

    -- Metadata
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    latency_ms INT,
    token_count INT,
    model_used VARCHAR(100),

    -- Partitioning by date for performance
    PARTITION BY RANGE (timestamp)
);

-- Tools & Integrations Tracking
CREATE TABLE tool_invocations (
    id BIGSERIAL PRIMARY KEY,
    config_id VARCHAR(100) NOT NULL,
    conversation_id UUID REFERENCES conversations(id),

    tool_name VARCHAR(100) NOT NULL,
    input_args JSONB NOT NULL,
    output_result JSONB,

    -- Performance
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_ms INT,

    -- Status
    status VARCHAR(50),  -- success, error, timeout
    error_message TEXT,

    INDEX idx_tool_name (config_id, tool_name),
    INDEX idx_tool_date (config_id, started_at)
);

-- Follow-ups & Scheduled Actions
CREATE TABLE scheduled_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_id VARCHAR(100) NOT NULL,
    customer_id UUID NOT NULL REFERENCES customer_profiles(id),

    action_type VARCHAR(100) NOT NULL,  -- followup_email, outbound_call, etc
    scheduled_for TIMESTAMPTZ NOT NULL,

    payload JSONB NOT NULL,

    status VARCHAR(50) DEFAULT 'pending',
    executed_at TIMESTAMPTZ,
    result JSONB,

    INDEX idx_scheduled_actions (config_id, scheduled_for, status)
);

-- Analytics Tables
CREATE TABLE daily_metrics (
    id BIGSERIAL PRIMARY KEY,
    config_id VARCHAR(100) NOT NULL,
    date DATE NOT NULL,

    -- Volume
    total_conversations INT DEFAULT 0,
    total_messages INT DEFAULT 0,
    unique_customers INT DEFAULT 0,

    -- Quality
    avg_sentiment FLOAT,
    avg_quality_score FLOAT,
    human_handoffs INT DEFAULT 0,

    -- Performance
    avg_response_time_ms INT,
    p95_response_time_ms INT,
    error_rate FLOAT,

    UNIQUE(config_id, date)
);

-- Incidents
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_id VARCHAR(100),

    title VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL,

    description TEXT,
    affected_components JSONB,

    started_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,

    status VARCHAR(50) DEFAULT 'open',

    -- SLA
    breaches_sla BOOLEAN DEFAULT FALSE,
    sla_impact_minutes INT,

    -- RCA
    root_cause TEXT,
    mitigation_steps JSONB,

    INDEX idx_incidents_date (started_at),
    INDEX idx_incidents_status (status)
);
```

### Vector Database (Pinecone)

**RAG for Client Knowledge**:

```python
from pinecone import Pinecone, ServerlessSpec

class VectorStoreManager:
    """Manage vector embeddings for semantic search"""

    def __init__(self):
        self.pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
        self.index_name = "client-knowledge-base"

    async def create_client_namespace(self, config_id: str):
        """Create isolated namespace for client data"""
        # Namespaces in Pinecone provide logical separation
        # Each client gets their own namespace
        pass

    async def index_documents(
        self,
        config_id: str,
        documents: list[Document]
    ):
        """Index client documents for RAG"""
        index = self.pc.Index(self.index_name)

        # Generate embeddings
        embeddings = await self.embed_documents(documents)

        # Upsert to client namespace
        vectors = [
            {
                "id": doc.id,
                "values": emb,
                "metadata": {
                    "config_id": config_id,
                    "source": doc.source,
                    "title": doc.title,
                    "content": doc.content[:1000]  # Preview
                }
            }
            for doc, emb in zip(documents, embeddings)
        ]

        index.upsert(
            vectors=vectors,
            namespace=config_id  # Isolation
        )

    async def semantic_search(
        self,
        config_id: str,
        query: str,
        top_k: int = 5
    ) -> list[Document]:
        """Search client knowledge base"""
        index = self.pc.Index(self.index_name)

        # Embed query
        query_embedding = await self.embed_query(query)

        # Search in client namespace
        results = index.query(
            vector=query_embedding,
            top_k=top_k,
            namespace=config_id,
            include_metadata=True
        )

        return [
            Document(
                id=match.id,
                content=match.metadata["content"],
                score=match.score
            )
            for match in results.matches
        ]
```

### Redis Architecture

**Use Cases**:
1. **Session State**: Conversation checkpoints (hot data)
2. **Rate Limiting**: API throttling per client
3. **Pub/Sub**: Real-time updates (new message notifications)
4. **Caching**: Frequently accessed data (configs, tool results)

```python
class RedisManager:
    """Multi-purpose Redis usage"""

    def __init__(self):
        self.redis = aioredis.from_url(
            os.getenv("REDIS_URL"),
            decode_responses=True
        )

    # 1. Session State
    async def save_session(
        self,
        session_id: str,
        state: ConversationState
    ):
        """Save conversation checkpoint"""
        key = f"session:{session_id}"
        await self.redis.setex(
            key,
            3600,  # 1 hour TTL
            json.dumps(state)
        )

    # 2. Rate Limiting
    async def check_rate_limit(
        self,
        config_id: str,
        endpoint: str,
        limit: int = 100
    ) -> bool:
        """Check if rate limit exceeded"""
        key = f"rate:{config_id}:{endpoint}"
        current = await self.redis.incr(key)

        if current == 1:
            await self.redis.expire(key, 60)  # 1 minute window

        return current <= limit

    # 3. Pub/Sub
    async def publish_message(
        self,
        config_id: str,
        message: Message
    ):
        """Publish new message event"""
        channel = f"messages:{config_id}"
        await self.redis.publish(
            channel,
            json.dumps(message.dict())
        )

    async def subscribe_messages(
        self,
        config_id: str
    ) -> AsyncIterator[Message]:
        """Subscribe to message stream"""
        pubsub = self.redis.pubsub()
        await pubsub.subscribe(f"messages:{config_id}")

        async for message in pubsub.listen():
            if message["type"] == "message":
                yield Message(**json.loads(message["data"]))

    # 4. Caching
    async def cache_config(
        self,
        config_id: str,
        config: ClientConfig
    ):
        """Cache client config"""
        key = f"config:{config_id}"
        await self.redis.setex(
            key,
            300,  # 5 minutes
            config.json()
        )

    async def get_cached_config(
        self,
        config_id: str
    ) -> ClientConfig | None:
        """Retrieve cached config"""
        key = f"config:{config_id}"
        data = await self.redis.get(key)
        if data:
            return ClientConfig.parse_raw(data)
        return None
```

---

## Integration Layer

### Message Queue Architecture (RabbitMQ)

```
Producer Services → Exchange → Queues → Consumer Services

Research Engine    ─┐
Demo Generator     ─┤
PRD Builder        ─┼─→ [Topic Exchange] ─┬─→ [email.queue] → Email Service
Automation Engine  ─┤                      ├─→ [sms.queue] → SMS Service
Monitoring Engine  ─┘                      ├─→ [crm.queue] → CRM Service
                                            └─→ [webhook.queue] → Webhook Service
```

**Implementation**:
```python
import aio_pika

class MessageBus:
    """RabbitMQ message bus for async workflows"""

    def __init__(self):
        self.connection = None
        self.channel = None

    async def connect(self):
        """Establish connection"""
        self.connection = await aio_pika.connect_robust(
            os.getenv("RABBITMQ_URL")
        )
        self.channel = await self.connection.channel()
        await self.channel.set_qos(prefetch_count=10)

    async def publish(
        self,
        exchange: str,
        routing_key: str,
        message: dict,
        priority: int = 0
    ):
        """Publish message to exchange"""
        exchange_obj = await self.channel.declare_exchange(
            exchange,
            aio_pika.ExchangeType.TOPIC,
            durable=True
        )

        await exchange_obj.publish(
            aio_pika.Message(
                body=json.dumps(message).encode(),
                priority=priority,
                content_type="application/json"
            ),
            routing_key=routing_key
        )

    async def consume(
        self,
        queue_name: str,
        callback: Callable
    ):
        """Consume messages from queue"""
        queue = await self.channel.declare_queue(
            queue_name,
            durable=True
        )

        async with queue.iterator() as queue_iter:
            async for message in queue_iter:
                async with message.process():
                    try:
                        data = json.loads(message.body)
                        await callback(data)
                    except Exception as e:
                        logger.error(f"Error processing message: {e}")
                        # Message will be requeued for retry

# Example: Email notification consumer
class EmailService:
    async def process_email_task(self, task: dict):
        """Process email sending task"""
        config_id = task["config_id"]
        customer_id = task["customer_id"]
        template = task["template"]
        variables = task["variables"]

        # Render email template
        email_html = await self.render_template(template, variables)

        # Send via provider (SendGrid, AWS SES, etc)
        await self.send_email(
            to=task["to"],
            subject=task["subject"],
            html=email_html
        )

        # Log in database
        await self.db.log_email_sent(config_id, customer_id, task)

# Start consumer
async def start_email_consumer():
    bus = MessageBus()
    await bus.connect()

    service = EmailService()
    await bus.consume("email.queue", service.process_email_task)
```

### External API Integrations

#### CRM Integration (Salesforce, HubSpot)

```python
class CRMIntegration:
    """Unified CRM interface"""

    def __init__(self, config: CRMConfig):
        if config.type == "salesforce":
            self.client = SalesforceClient(config)
        elif config.type == "hubspot":
            self.client = HubSpotClient(config)
        else:
            raise ValueError(f"Unknown CRM: {config.type}")

    async def create_lead(
        self,
        customer: CustomerProfile
    ) -> str:
        """Create lead in CRM"""
        lead_data = {
            "firstName": customer.name.split()[0],
            "lastName": " ".join(customer.name.split()[1:]),
            "email": customer.email,
            "phone": customer.phone,
            "source": customer.source_channel,
            "customFields": customer.pii_data
        }

        lead_id = await self.client.create_lead(lead_data)
        return lead_id

    async def update_lead_status(
        self,
        lead_id: str,
        status: str
    ):
        """Update lead status"""
        await self.client.update_lead(lead_id, {"status": status})

    async def log_activity(
        self,
        lead_id: str,
        activity_type: str,
        notes: str
    ):
        """Log activity in CRM"""
        await self.client.create_activity({
            "leadId": lead_id,
            "type": activity_type,
            "notes": notes,
            "timestamp": datetime.utcnow()
        })
```

#### Messaging Integrations (WhatsApp, Instagram)

```python
class MessagingIntegration:
    """Handle inbound/outbound messages"""

    def __init__(self):
        self.whatsapp = WhatsAppClient()
        self.instagram = InstagramClient()

    async def handle_inbound_webhook(
        self,
        channel: str,
        payload: dict
    ):
        """Process inbound message webhook"""
        if channel == "whatsapp":
            message = self.whatsapp.parse_webhook(payload)
        elif channel == "instagram":
            message = self.instagram.parse_webhook(payload)

        # Route to automation engine
        config_id = await self.resolve_config_id(
            channel,
            message.from_number
        )

        await self.orchestrator.handle_message(
            config_id=config_id,
            channel=channel,
            message=message
        )

    async def send_outbound(
        self,
        config_id: str,
        channel: str,
        to: str,
        content: str
    ):
        """Send outbound message"""
        config = await self.config_manager.get(config_id)

        if channel == "whatsapp":
            await self.whatsapp.send_message(
                from_number=config.integrations.whatsapp.phone_number,
                to_number=to,
                content=content
            )
        elif channel == "instagram":
            await self.instagram.send_message(
                from_account=config.integrations.instagram.page_id,
                to_user=to,
                content=content
            )
```

---

## Security & Compliance

### Authentication & Authorization

**OAuth 2.1 + JWT**:
```python
from jose import jwt
from datetime import datetime, timedelta

class AuthService:
    """Handle authentication and authorization"""

    def __init__(self):
        self.secret_key = os.getenv("JWT_SECRET_KEY")
        self.algorithm = "HS256"
        self.access_token_expire_minutes = 30

    async def authenticate_user(
        self,
        username: str,
        password: str
    ) -> User | None:
        """Authenticate user credentials"""
        user = await self.db.get_user_by_username(username)
        if not user:
            return None

        if not self.verify_password(password, user.hashed_password):
            return None

        return user

    def create_access_token(
        self,
        user: User,
        scopes: list[str]
    ) -> str:
        """Create JWT access token"""
        expire = datetime.utcnow() + timedelta(
            minutes=self.access_token_expire_minutes
        )

        to_encode = {
            "sub": user.id,
            "username": user.username,
            "scopes": scopes,
            "exp": expire
        }

        return jwt.encode(
            to_encode,
            self.secret_key,
            algorithm=self.algorithm
        )

    async def verify_token(self, token: str) -> TokenPayload:
        """Verify JWT token"""
        try:
            payload = jwt.decode(
                token,
                self.secret_key,
                algorithms=[self.algorithm]
            )
            return TokenPayload(**payload)
        except jwt.JWTError:
            raise AuthenticationError("Invalid token")

# RBAC
class RBACMiddleware:
    """Role-Based Access Control"""

    roles = {
        "admin": ["*"],  # All permissions
        "developer": [
            "config:read", "config:write",
            "tool:read", "tool:write",
            "logs:read"
        ],
        "operator": [
            "config:read",
            "logs:read",
            "incidents:write"
        ],
        "viewer": [
            "config:read",
            "logs:read"
        ]
    }

    async def check_permission(
        self,
        user: User,
        permission: str
    ) -> bool:
        """Check if user has permission"""
        user_permissions = self.roles.get(user.role, [])

        if "*" in user_permissions:
            return True

        return permission in user_permissions
```

### Data Encryption

```python
from cryptography.fernet import Fernet

class EncryptionService:
    """Encrypt sensitive data at rest"""

    def __init__(self):
        key = os.getenv("ENCRYPTION_KEY").encode()
        self.cipher = Fernet(key)

    def encrypt(self, data: str) -> str:
        """Encrypt plaintext"""
        return self.cipher.encrypt(data.encode()).decode()

    def decrypt(self, encrypted: str) -> str:
        """Decrypt ciphertext"""
        return self.cipher.decrypt(encrypted.encode()).decode()

# Usage in models
class CustomerProfile(BaseModel):
    email: str
    phone: str

    def save_to_db(self):
        """Encrypt PII before storing"""
        encrypted = {
            "email": encryption.encrypt(self.email),
            "phone": encryption.encrypt(self.phone)
        }
        db.save(encrypted)

    @classmethod
    def load_from_db(cls, record):
        """Decrypt PII after loading"""
        return cls(
            email=encryption.decrypt(record["email"]),
            phone=encryption.decrypt(record["phone"])
        )
```

### Compliance (SOC 2, GDPR)

**Audit Logging**:
```python
class AuditLogger:
    """Comprehensive audit trail"""

    async def log_access(
        self,
        user_id: str,
        resource_type: str,
        resource_id: str,
        action: str,
        ip_address: str
    ):
        """Log access to sensitive resources"""
        await self.db.insert("audit_log", {
            "timestamp": datetime.utcnow(),
            "user_id": user_id,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "action": action,
            "ip_address": ip_address
        })

    async def log_data_export(
        self,
        user_id: str,
        data_type: str,
        record_count: int
    ):
        """Log data exports (GDPR compliance)"""
        await self.db.insert("audit_log", {
            "timestamp": datetime.utcnow(),
            "user_id": user_id,
            "action": "data_export",
            "data_type": data_type,
            "record_count": record_count
        })
```

**GDPR Data Rights**:
```python
class DataRightsService:
    """Handle GDPR data subject requests"""

    async def export_user_data(
        self,
        config_id: str,
        customer_id: str
    ) -> dict:
        """Export all user data (GDPR Right to Access)"""
        customer = await self.db.get_customer(config_id, customer_id)
        conversations = await self.db.get_conversations(config_id, customer_id)

        data = {
            "profile": customer.dict(),
            "conversations": [c.dict() for c in conversations],
            "exported_at": datetime.utcnow()
        }

        await self.audit_logger.log_data_export(
            user_id=customer_id,
            data_type="customer_data",
            record_count=1 + len(conversations)
        )

        return data

    async def delete_user_data(
        self,
        config_id: str,
        customer_id: str
    ):
        """Delete all user data (GDPR Right to Erasure)"""
        # Anonymize instead of hard delete for audit compliance
        await self.db.anonymize_customer(config_id, customer_id)

        await self.audit_logger.log_access(
            user_id="system",
            resource_type="customer",
            resource_id=customer_id,
            action="anonymize",
            ip_address="internal"
        )
```

---

## Deployment & Infrastructure

### Kubernetes Architecture

```yaml
# Platform Services Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: automation-engine
spec:
  replicas: 3
  selector:
    matchLabels:
      app: automation-engine
  template:
    metadata:
      labels:
        app: automation-engine
    spec:
      containers:
      - name: automation-engine
        image: workflow-automation/automation-engine:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secrets
              key: url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "2000m"
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
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: automation-engine
spec:
  selector:
    app: automation-engine
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
---
# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: automation-engine-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: automation-engine
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -r requirements-dev.txt

    - name: Run tests
      run: |
        pytest tests/ --cov=src --cov-report=xml

    - name: Upload coverage
      uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Build Docker images
      run: |
        docker build -t automation-engine:${{ github.sha }} -f services/automation/Dockerfile .
        docker build -t research-engine:${{ github.sha }} -f services/research/Dockerfile .

    - name: Push to registry
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push automation-engine:${{ github.sha }}
        docker push research-engine:${{ github.sha }}

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/automation-engine \
          automation-engine=automation-engine:${{ github.sha }}
        kubectl rollout status deployment/automation-engine
```

### Infrastructure as Code (Terraform)

```hcl
# infrastructure/main.tf
provider "aws" {
  region = "us-east-1"
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "workflow-automation"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      desired_size = 3
      min_size     = 3
      max_size     = 20

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "main" {
  identifier        = "workflow-automation"
  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t3.large"
  allocated_storage = 100

  db_name  = "workflow_automation"
  username = var.db_username
  password = var.db_password

  backup_retention_period = 7
  multi_az               = true

  tags = {
    Environment = "production"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "workflow-automation"
  engine               = "redis"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 2
  parameter_group_name = "default.redis7"

  tags = {
    Environment = "production"
  }
}
```

---

## Monitoring & Observability

### Metrics Stack

**Prometheus + Grafana**:
```python
from prometheus_client import Counter, Histogram, Gauge, Info

# Metrics
conversation_counter = Counter(
    'conversations_total',
    'Total conversations processed',
    ['config_id', 'channel']
)

response_latency = Histogram(
    'response_latency_seconds',
    'Response latency distribution',
    ['config_id', 'channel'],
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0]
)

active_conversations = Gauge(
    'active_conversations',
    'Currently active conversations',
    ['config_id']
)

tool_invocations = Counter(
    'tool_invocations_total',
    'Tool invocation count',
    ['config_id', 'tool_name', 'status']
)

# Instrumentation
class InstrumentedBotOrchestrator(BotOrchestrator):
    async def handle_message(self, config_id, channel, message):
        conversation_counter.labels(
            config_id=config_id,
            channel=channel
        ).inc()

        active_conversations.labels(config_id=config_id).inc()

        start = time.time()
        try:
            result = await super().handle_message(config_id, channel, message)
            return result
        finally:
            duration = time.time() - start
            response_latency.labels(
                config_id=config_id,
                channel=channel
            ).observe(duration)

            active_conversations.labels(config_id=config_id).dec()
```

**Grafana Dashboard Config**:
```json
{
  "dashboard": {
    "title": "Workflow Automation - Overview",
    "panels": [
      {
        "title": "Conversations/sec",
        "targets": [
          {
            "expr": "rate(conversations_total[5m])"
          }
        ]
      },
      {
        "title": "Response Latency (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, response_latency_seconds_bucket)"
          }
        ]
      },
      {
        "title": "Active Conversations",
        "targets": [
          {
            "expr": "sum(active_conversations) by (config_id)"
          }
        ]
      },
      {
        "title": "Tool Success Rate",
        "targets": [
          {
            "expr": "rate(tool_invocations_total{status='success'}[5m]) / rate(tool_invocations_total[5m])"
          }
        ]
      }
    ]
  }
}
```

### Distributed Tracing (Langfuse)

```python
from langfuse import Langfuse
from langfuse.decorators import observe

langfuse = Langfuse()

class TracedWorkflow:
    @observe()
    async def invoke_workflow(
        self,
        config_id: str,
        message: Message
    ):
        """Traced LangGraph workflow invocation"""
        trace = langfuse.trace(
            name="conversation",
            user_id=message.user_id,
            metadata={
                "config_id": config_id,
                "channel": message.channel
            }
        )

        with trace.span(name="llm_call") as span:
            response = await self.llm.ainvoke(message.content)
            span.end(
                output=response,
                metadata={
                    "model": self.llm.model_name,
                    "tokens": response.usage_metadata
                }
            )

        if response.tool_calls:
            with trace.span(name="tool_execution") as span:
                results = await self.execute_tools(response.tool_calls)
                span.end(output=results)

        return response
```

### Alerting Rules

```yaml
# prometheus/alerts.yml
groups:
- name: workflow_automation
  interval: 30s
  rules:
  - alert: HighErrorRate
    expr: |
      rate(conversations_total{status="error"}[5m])
      / rate(conversations_total[5m]) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate for {{ $labels.config_id }}"
      description: "Error rate is {{ $value | humanizePercentage }}"

  - alert: SlowResponseTime
    expr: |
      histogram_quantile(0.95, response_latency_seconds_bucket) > 2
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Slow response time for {{ $labels.config_id }}"
      description: "P95 latency is {{ $value }}s"

  - alert: LLMQualityDegraded
    expr: |
      avg(conversation_quality_score) by (config_id) < 0.7
    for: 10m
    labels:
      severity: high
    annotations:
      summary: "LLM quality degraded for {{ $labels.config_id }}"
      description: "Average quality score is {{ $value }}"
```

---

## Development Workflow

### Local Development Setup

```bash
# 1. Clone repository
git clone https://github.com/your-org/workflow-automation.git
cd workflow-automation

# 2. Set up Python environment
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 3. Set up infrastructure (Docker Compose)
docker-compose up -d postgres redis rabbitmq

# 4. Run database migrations
alembic upgrade head

# 5. Load sample configs
cp configs/examples/sample-sales.yaml configs/acme-corp.yaml

# 6. Start development server
uvicorn src.main:app --reload --port 8000

# 7. Start LiveKit worker (separate terminal)
python services/voice/worker.py dev

# 8. Run tests
pytest tests/ --cov=src
```

### Docker Compose for Local Dev

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: workflow_automation
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"  # Management UI
    environment:
      RABBITMQ_DEFAULT_USER: dev
      RABBITMQ_DEFAULT_PASS: devpass

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus:/etc/prometheus

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  postgres_data:
  grafana_data:
```

### Testing Strategy

```python
# tests/test_automation_engine.py
import pytest
from unittest.mock import AsyncMock, MagicMock
from src.automation_engine import BotOrchestrator

@pytest.fixture
async def orchestrator():
    config_manager = AsyncMock()
    tool_registry = MagicMock()
    return BotOrchestrator(config_manager, tool_registry)

@pytest.mark.asyncio
async def test_handle_message(orchestrator):
    """Test message handling flow"""
    config_id = "test-client"
    message = Message(
        user_id="user123",
        content="Hello",
        channel="whatsapp"
    )

    # Mock config
    orchestrator.config_manager.load_config.return_value = ClientConfig(
        client=ClientInfo(id=config_id, name="Test Client"),
        workflow=WorkflowConfig(system_prompt="You are helpful")
    )

    # Invoke
    result = await orchestrator.handle_message(config_id, "whatsapp", message)

    # Assertions
    assert result is not None
    assert len(result["messages"]) > 0
    orchestrator.config_manager.load_config.assert_called_once_with(config_id)

# Integration tests
@pytest.mark.integration
async def test_full_conversation_flow(test_db):
    """End-to-end conversation test"""
    # Create client config
    config = await create_test_config("e2e-test")

    # Start conversation
    session_id = "session123"
    messages = [
        Message(role="user", content="I want to book a demo"),
        Message(role="user", content="My email is test@example.com")
    ]

    # Process messages
    for msg in messages:
        result = await orchestrator.handle_message(
            config.client.id,
            "chat",
            msg
        )

    # Verify state
    session = await test_db.get_session(session_id)
    assert session.pii_data["email"] == "test@example.com"
    assert len(session.messages) == 4  # 2 user + 2 assistant
```

---

## Implementation Roadmap

### Phase 1: Foundation (Months 1-3)

**Sprint 1-2: Infrastructure Setup**
- [ ] Kubernetes cluster provisioning (AWS EKS)
- [ ] Database setup (Supabase PostgreSQL + RLS)
- [ ] Redis cluster for caching/sessions
- [ ] RabbitMQ for message bus
- [ ] CI/CD pipelines (GitHub Actions)
- [ ] Monitoring stack (Prometheus + Grafana + Langfuse)

**Sprint 3-4: Core Workflow Engine**
- [ ] LangGraph 2-node architecture implementation
- [ ] Tool registry system
- [ ] State management (PostgreSQL + Redis checkpointing)
- [ ] Basic FastAPI service structure
- [ ] Unit tests (>80% coverage)

**Sprint 5-6: Research Engine + Demo Generator**
- [ ] Web scraping infrastructure (Playwright)
- [ ] Social media API integrations
- [ ] LLM-powered research synthesis
- [ ] Demo config generation
- [ ] Sandbox deployment system

### Phase 2: Automation (Months 4-6)

**Sprint 7-8: YAML Configuration System**
- [ ] Config schema design (Pydantic models)
- [ ] Config validation engine
- [ ] Hot-reload functionality
- [ ] GitHub issue automation for missing tools/integrations
- [ ] Config versioning (Git-based)

**Sprint 9-10: Automation Engine**
- [ ] Bot orchestrator (multi-client management)
- [ ] Dynamic tool loading from configs
- [ ] Integration manager (CRM, messaging channels)
- [ ] Message routing and session management

**Sprint 11-12: LiveKit Voice Integration**
- [ ] Voice agent factory from YAML configs
- [ ] STT/TTS provider abstraction
- [ ] Human handoff detection
- [ ] Voice quality monitoring
- [ ] Pilot client deployment

### Phase 3: Scale (Months 7-9)

**Sprint 13-14: Advanced Monitoring**
- [ ] LLM quality monitoring (sentiment, coherence, hallucination)
- [ ] Incident management system
- [ ] Automated RCA generation
- [ ] SLA tracking and auto-refunds
- [ ] Client notification system

**Sprint 15-16: Customer Success Engine**
- [ ] KPI calculation and storage
- [ ] Insight generation from conversation data
- [ ] Cross-client learning (village knowledge)
- [ ] Automated PPT generation for quarterly reviews

**Sprint 17-18: A/B Testing Framework**
- [ ] Baseline measurement system
- [ ] A/B flow configuration
- [ ] Statistical significance testing
- [ ] Automated system prompt optimization

### Phase 4: Enterprise (Months 10-12)

**Sprint 19-20: Security & Compliance**
- [ ] OAuth 2.1 authentication
- [ ] RBAC implementation
- [ ] Data encryption (at rest + in transit)
- [ ] GDPR compliance (data export/deletion)
- [ ] SOC 2 audit preparation

**Sprint 21-22: Advanced Integrations**
- [ ] Contract automation (NDA, proposals)
- [ ] E-signature workflow (Adobe Sign/DocuSign)
- [ ] Pricing model generator
- [ ] PRD builder engine

**Sprint 23-24: Performance Optimization**
- [ ] Database query optimization
- [ ] Caching strategy refinement
- [ ] Load testing (10k concurrent conversations)
- [ ] Multi-region deployment
- [ ] Documentation and handoff

---

## Appendices

### Appendix A: API Specifications

**REST API Endpoints**:

```
Authentication:
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout

Configs:
GET    /configs
GET    /configs/{config_id}
POST   /configs
PUT    /configs/{config_id}
DELETE /configs/{config_id}
POST   /configs/{config_id}/validate

Conversations:
POST   /conversations
GET    /conversations/{conversation_id}
GET    /conversations/{conversation_id}/messages
POST   /conversations/{conversation_id}/messages

Customers:
GET    /customers?config_id={config_id}
GET    /customers/{customer_id}
PUT    /customers/{customer_id}

Analytics:
GET    /analytics/daily?config_id={config_id}&start={date}&end={date}
GET    /analytics/realtime?config_id={config_id}

Tools:
GET    /tools
GET    /tools/{tool_name}
POST   /tools/{tool_name}/test

Integrations:
GET    /integrations
GET    /integrations/{integration_type}
POST   /integrations/{integration_type}/test

Incidents:
GET    /incidents
GET    /incidents/{incident_id}
POST   /incidents
PUT    /incidents/{incident_id}/resolve
```

### Appendix B: Data Models

**Core Domain Models**:

```python
# Customer
class CustomerProfile(BaseModel):
    id: UUID
    config_id: str
    external_id: str | None
    phone: str | None
    email: str | None
    name: str | None
    pii_data: dict
    source_channel: str
    user_context: dict
    created_at: datetime
    updated_at: datetime

# Conversation
class Conversation(BaseModel):
    id: UUID
    config_id: str
    customer_id: UUID
    session_id: str
    channel: str
    messages: list[Message]
    checkpoint: dict
    started_at: datetime
    ended_at: datetime | None
    sentiment_score: float | None
    quality_score: float | None
    human_handoff_occurred: bool

# Message
class Message(BaseModel):
    role: Literal["user", "assistant", "system", "tool"]
    content: str
    timestamp: datetime
    tool_calls: list[ToolCall] | None
    tool_results: list[ToolResult] | None

# Config
class ClientConfig(BaseModel):
    version: str
    client: ClientInfo
    workflow: WorkflowConfig
    voice: VoiceConfig | None
    behavior: BehaviorConfig
    monitoring: MonitoringConfig
```

### Appendix C: Cost Estimation

**Monthly Operational Costs** (100 clients, 10k conversations/day):

| Component | Cost | Notes |
|-----------|------|-------|
| **Compute (AWS EKS)** | $1,500 | 10 t3.xlarge nodes |
| **Database (RDS)** | $500 | db.t3.large + storage |
| **Redis (ElastiCache)** | $200 | 2 cache.t3.medium |
| **LLM APIs (OpenAI)** | $8,000 | ~2M tokens/day @ $0.004/1k |
| **Voice (LiveKit Cloud)** | $3,000 | ~1k hrs/month @ $3/hr |
| **STT (Deepgram)** | $600 | ~1k hrs @ $0.60/hr |
| **TTS (ElevenLabs)** | $1,200 | ~1k hrs @ $1.20/hr |
| **Vector DB (Pinecone)** | $300 | Standard plan |
| **Monitoring (Grafana Cloud)** | $100 | Pro plan |
| **Misc (S3, CloudWatch, etc)** | $200 | Storage + logs |
| **Total** | **$15,600/month** | ~$0.05 per conversation |

**Revenue Model**:
- Per-conversation pricing: $0.15 - $0.50 (3-10x cost)
- Monthly subscription: $500 - $5,000/client (based on volume)
- Implementation fees: $10,000 - $50,000 one-time

### Appendix D: Success Metrics Dashboard

**KPIs to Track**:

```python
class ClientKPIs(BaseModel):
    # Volume
    total_conversations: int
    unique_customers: int
    messages_per_conversation: float

    # Quality
    avg_sentiment: float  # -1 to 1
    quality_score: float  # 0 to 1
    human_handoff_rate: float  # 0 to 1

    # Performance
    avg_response_time_ms: int
    p95_response_time_ms: int
    error_rate: float

    # Business Impact
    conversion_rate: float  # leads to demos
    demo_booking_rate: float
    nps_score: int  # -100 to 100
```

---

## Conclusion

This technical architecture provides a **production-ready blueprint** for building the Workflow Automation Platform using:

1. **Proven patterns** from existing codebases (2-node LangGraph, LiveKit voice)
2. **Modern microservices** with event-driven architecture
3. **YAML-first configuration** for rapid client onboarding
4. **Comprehensive monitoring** with LLM quality tracking
5. **Enterprise security** (OAuth 2.1, encryption, GDPR compliance)

### Key Innovations

- **Dynamic tool/integration loading** from YAML configs
- **Automated GitHub issue creation** for missing components
- **Hot-reload** config changes without downtime
- **Multi-tenant isolation** at database, cache, and metric levels
- **Proactive quality monitoring** with automatic escalation

### Next Steps

1. **Review & Approve**: Stakeholder sign-off on architecture
2. **Team Formation**: Hire 2-3 senior engineers to lead implementation
3. **Sprint 0**: Infrastructure provisioning and repo setup
4. **Sprint 1**: Begin Phase 1 development

**Estimated Timeline**: 12 months to full production
**Team Size**: 12-15 engineers
**Total Budget**: $2M (development) + $200k/year (operations)

---

**Document Prepared By**: Claude Code Agent
**Last Updated**: 2025-09-30
**Status**: Ready for Implementation