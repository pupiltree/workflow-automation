# AI-Powered Workflow Automation Platform - Modular Workflow Diagrams

This document breaks down the complete platform workflow into digestible, renderable diagrams organized by phase and concern.

**Architecture:** 17 microservices (16 core + 2 libraries) coordinated via 18 Kafka topics
**Performance:** 400-900ms faster workflows through service consolidation and direct library integration
**Agent Productivity:** Service 21 (Agent Copilot) provides unified dashboard for all human agents, enabling 3x capacity increase

---

## Table of Contents

1. [High-Level System Overview](#1-high-level-system-overview)
2. [Phase 0: Organization Setup & Agent Assignment](#2-phase-0-organization-setup--agent-assignment)
3. [Phase 1: Research & Requirements](#3-phase-1-research--requirements)
4. [Phase 2-3: Demo, Legal & Contracting](#4-phase-2-3-demo-legal--contracting)
5. [Phase 4: Implementation & Deployment](#5-phase-4-implementation--deployment)
6. [Phase 5: Runtime Operations (Chatbot)](#6-phase-5-runtime-operations-chatbot)
7. [Phase 5: Runtime Operations (Voicebot)](#7-phase-5-runtime-operations-voicebot)
8. [Phase 5: Support & Success Workflows](#8-phase-5-support--success-workflows)
9. [Phase 5: Client Self-Service & Personalization](#9-phase-5-client-self-service--personalization)
10. [Phase 6: Iteration & Expansion](#10-phase-6-iteration--expansion)
11. [Human Agent Handoff Workflows](#11-human-agent-handoff-workflows)
12. [Service 21: Agent Copilot Dashboard](#12-service-21-agent-copilot-dashboard)
13. [Event Flow Architecture](#13-event-flow-architecture)
14. [Service Dependencies](#14-service-dependencies)

---

## 1. High-Level System Overview

```mermaid
flowchart TB
    Start["Client Signup"] --> Research["Phase 1: Research & Requirements<br/>(40% Human)"]
    Research --> Demo["Phase 2: Demo & PoC<br/>(Sales Stage)"]
    Demo --> Legal["Phase 3: Legal & Contracting<br/>(PRD + Pricing + Proposal)"]
    Legal --> Impl["Phase 4: Implementation<br/>(40% Human - Onboarding)"]
    Impl --> Ops["Phase 5: Ongoing Operations<br/>(10% Human - Support + Success)"]
    Ops --> Iterate["Phase 6: Iteration & Expansion<br/>(Dynamic Specialist Handoffs)"]
    Iterate --> Ops

    style Start fill:#e1f5e1
    style Research fill:#fff3e0
    style Demo fill:#fff3e0
    style Legal fill:#fff3e0
    style Impl fill:#fff3e0
    style Ops fill:#e3f2fd
    style Iterate fill:#e3f2fd
```

**Automation Progression:**
- Week 1: 60% automated
- Month 3: 80% automated
- Month 6: 90% automated
- Month 12: 95%+ automated

---

## 2. Phase 0: Organization Setup & Agent Assignment

```mermaid
flowchart TB
    subgraph Paths["Two Signup Paths"]
        SelfService["👤 Self-Service Signup<br/>(Work Email)"]
        Assisted["🤝 Assisted Signup<br/>(Sales Agent Creates Account)"]
    end

    subgraph Service0["Service 0: Organization & Identity Management<br/>(Unified - includes agent orchestration)"]
        Verify["Email Verification"]
        CreateOrg["Create Organization"]
        Invite["Send Team Invitations"]
        AutoAssign["Auto-Assign to<br/>Sales Agent<br/>(Workload-Balanced)"]
        ClaimLink["Send Claim Link<br/>(via Service 20)"]
        ClientClaims["Client Claims<br/>Account Ownership"]
    end

    ResearchStart["✅ Trigger Research Engine<br/>(Service 1)"]

    %% Self-service path
    SelfService --> Verify
    Verify --> CreateOrg
    CreateOrg --> Invite
    CreateOrg --> AutoAssign
    AutoAssign -->|organization_created| ResearchStart

    %% Assisted path
    Assisted --> CreateOrg
    CreateOrg -->|assisted_account_created| AutoAssign
    AutoAssign --> ClaimLink
    ClaimLink --> ClientClaims
    ClientClaims -->|assisted_account_claimed| ResearchStart

    style SelfService fill:#e1f5e1
    style Assisted fill:#fff3e0
    style ResearchStart fill:#f3e5f5
```

---

## 3. Phase 1: Research & Requirements

```mermaid
flowchart TB
    Trigger["organization_created /<br/>assisted_account_claimed"]

    subgraph Service1["Service 1: Research Engine"]
        Collect["🤖 AUTO: Multi-Source Collection<br/>• LinkedIn (company profile)<br/>• Crunchbase (funding)<br/>• Website scraping<br/>• Competitor analysis"]
        Analyze["🤖 AUTO: AI Analysis<br/>• Volume predictions<br/>• Use case identification<br/>• Integration requirements"]
        Complete["research_completed"]
    end

    subgraph Service20["Service 20: Communication & Hyperpersonalization"]
        Draft["🤖 AUTO: Generate<br/>Requirements Draft<br/>• Predicted volumes<br/>• Suggested use cases"]
        HumanReview["👤 HUMAN: Sales Agent<br/>Reviews & Approves"]
        SendForm["🤖 AUTO: Send<br/>Requirements Form<br/>(Email/SMS Delivery)"]
        ClientValidate["👤 CLIENT: Validates<br/>& Corrects Data"]
        Validated["requirements_validation_completed"]
    end

    DemoTrigger["✅ Trigger Demo Generator<br/>(Service 2)"]

    Trigger --> Collect
    Collect --> Analyze
    Analyze --> Complete
    Complete -->|research_completed| Draft
    Draft --> HumanReview
    HumanReview -->|requirements_draft_approved| SendForm
    SendForm --> ClientValidate
    ClientValidate --> Validated
    Validated --> DemoTrigger

    style Collect fill:#e1f5e1
    style Analyze fill:#e1f5e1
    style Draft fill:#e1f5e1
    style HumanReview fill:#fff3e0
    style ClientValidate fill:#fff3e0
    style DemoTrigger fill:#f3e5f5
```

---

## 4. Phase 2-3: Demo, Legal & Contracting

```mermaid
flowchart TB
    Start["requirements_validation_completed"]

    subgraph Phase2["Phase 2: Demo & Proof of Concept"]
        subgraph Service2["Service 2: Demo Generator"]
            Design["🤖 AUTO: Demo Design<br/>• LangGraph config<br/>• LiveKit voice setup<br/>• Mock data generation"]
            Generate["🤖 AUTO: Generate Demo<br/>• Chatbot (LangGraph)<br/>• Voicebot (LiveKit)"]
        end

        Meeting["👤 HUMAN: Sales Meeting<br/>Demo Presentation & Q&A"]
        Approved["demo_approved + pilot_agreed"]
    end

    subgraph Phase3["Phase 3: Legal & Contracting"]
        subgraph Service3["Service 3: Sales Document Generator<br/>(Unified - 150-300ms faster)"]
            NDA["🤖 AUTO: Generate NDA"]
            SignNDA["🤖 AUTO: E-Signature<br/>(DocuSign)"]
            NDADone["sales_doc_events.nda_signed"]
        end

        subgraph Service6["Service 6: PRD Builder & Configuration Workspace"]
            PRDConv["🤖 AUTO: Conversational<br/>PRD Builder<br/>• Village knowledge<br/>• A/B flows<br/>• KPI framework<br/>• 12-month roadmap"]
            HelpBtn["👤 HUMAN: Help Button<br/>Real-time Collaboration"]
            PRDApp["prd_approved"]
        end

        subgraph Service3b["Service 3: Sales Document Generator (continued)"]
            Price["🤖 AUTO: Volume-Based<br/>Pricing & Cost Modeling"]
            Proposal["🤖 AUTO: Generate Proposal<br/>Research + Demo + PRD + Pricing"]
            SignProp["🤖 AUTO: E-Signature"]
            PropDone["sales_doc_events.proposal_signed"]
        end
    end

    AutoEngine["✅ Trigger Automation Engine<br/>(Service 7)<br/>(400-900ms faster workflow)"]

    Start --> Design
    Design --> Generate
    Generate --> Meeting
    Meeting --> Approved
    Approved --> NDA
    NDA --> SignNDA
    SignNDA --> NDADone
    NDADone --> PRDConv
    PRDConv -.->|help_requested| HelpBtn
    HelpBtn -.-> PRDConv
    PRDConv --> PRDApp
    PRDApp --> Price
    Price --> Proposal
    Proposal --> SignProp
    SignProp --> PropDone
    PropDone --> AutoEngine

    style Design fill:#e1f5e1
    style Generate fill:#e1f5e1
    style Meeting fill:#fff3e0
    style HelpBtn fill:#fff3e0
    style AutoEngine fill:#f3e5f5
```

---

## 5. Phase 4: Implementation & Deployment

```mermaid
flowchart TB
    Start["proposal_signed"]

    subgraph Handoff1["Human Agent Handoff (Service 0)"]
        SalesTo["handoff_initiated<br/>Sales → Onboarding"]
        OnboardAccept["Onboarding Specialist<br/>handoff_accepted"]
    end

    subgraph Service7["Service 7: Automation Engine"]
        Convert["🤖 AUTO: PRD → JSON<br/>• System prompts<br/>• Tool configs<br/>• Voice parameters"]
        GitHub["🤖 AUTO: Create GitHub Issues<br/>for Missing Tools"]
        Wait["⏳ Platform Engineers<br/>Develop Tools"]
        ConfigGen["config_generated"]
    end

    subgraph ConfigSDK["@workflow/config-sdk Library<br/>(50-100ms faster than service)"]
        Validate["🤖 AUTO: Validate Config<br/>• JSON schema<br/>• S3 upload (versioned)<br/>• Redis cache invalidation"]
        Deploy["config_deployed"]
    end

    subgraph Runtime["Runtime Services (use @workflow/llm-sdk)"]
        Service8["Service 8:<br/>Agent Orchestration<br/>(Chatbot)<br/>(200-500ms faster LLM calls)"]
        Service9["Service 9:<br/>Voice Agent<br/>(Voicebot)<br/>(200-500ms faster LLM calls)"]
        Ready["services_ready"]
    end

    Week1["👤 HUMAN: Week 1 Handholding<br/>Onboarding Specialist<br/>Daily Monitoring & Tuning"]
    Complete["onboarding_week1_complete"]

    subgraph Handoff2["Parallel Handoff (Service 0)"]
        ToSupport["→ Support Specialist"]
        ToSuccess["→ Success Manager"]
    end

    Operations["✅ Enter Operations Phase<br/>(Total speedup: 400-900ms)"]

    Start --> SalesTo
    SalesTo --> OnboardAccept
    OnboardAccept --> Convert
    Convert --> GitHub
    GitHub --> Wait
    Wait -->|github_issue_closed| ConfigGen
    ConfigGen --> Validate
    Validate --> Deploy
    Deploy --> Service8
    Deploy --> Service9
    Service8 --> Ready
    Service9 --> Ready
    Ready --> Week1
    Week1 --> Complete
    Complete --> ToSupport
    Complete --> ToSuccess
    ToSupport --> Operations
    ToSuccess --> Operations

    style Convert fill:#e1f5e1
    style Validate fill:#e1f5e1
    style Week1 fill:#fff3e0
```

---

## 6. Phase 5: Runtime Operations (Chatbot)

```mermaid
flowchart TB
    User["User Message"]

    subgraph Personalization["Service 20: Communication & Hyperpersonalization"]
        Cohort["Assign Cohort<br/>trial / active / power_user<br/>at_risk / churned"]
        Variant["Assign A/B Variant<br/>(Thompson Sampling)"]
    end

    subgraph Service8["Service 8: Agent Orchestration (LangGraph)"]
        Agent["Agent Node<br/>• Stateful conversation<br/>• Tool selection<br/>• Escalation logic"]
        Tools["Tools Node<br/>• CRM Integration<br/>• Support Engine<br/>• Custom tools"]
    end

    subgraph LLMSDK["@workflow/llm-sdk Library<br/>(200-500ms faster - no gateway hop)"]
        Route["Model Routing<br/>GPT-4 vs GPT-3.5"]
        Cache["Semantic Caching<br/>(40-60% cost reduction)"]
    end

    subgraph Service17["Service 17: RAG Pipeline"]
        Vector["Vector Search<br/>(Qdrant)"]
        Graph["Graph Reasoning<br/>(Neo4j)"]
        Knowledge["Village Knowledge<br/>Retrieval"]
    end

    Response["Chatbot Response<br/>(200-500ms faster)"]

    subgraph Analytics["Service 12: Analytics"]
        Track["Track Engagement"]
        UpdateWeights["Update A/B Weights<br/>Success: α+1<br/>Failure: β+1"]
    end

    Monitor["Service 11: Monitoring<br/>Quality Checks & Alerts"]

    User --> Cohort
    Cohort --> Variant
    Variant --> Agent
    Agent --> Route
    Route --> Cache
    Cache -.->|if knowledge needed| Vector
    Vector --> Graph
    Graph --> Knowledge
    Knowledge --> Cache
    Cache --> Agent
    Agent --> Tools
    Tools --> Agent
    Agent --> Response
    Response --> Track
    Track --> UpdateWeights
    UpdateWeights --> Variant
    Response --> Monitor

    style Agent fill:#e3f2fd
    style Route fill:#e1f5e1
    style Cache fill:#e1f5e1
```

---

## 7. Phase 5: Runtime Operations (Voicebot)

```mermaid
flowchart TB
    Call["Inbound Call"]

    subgraph Service9["Service 9: Voice Agent (LiveKit)"]
        STT["STT Node<br/>(Deepgram Nova-3)<br/>Speech → Text"]
        LLM["LLM Node<br/>(via Service 8)<br/>Business Logic"]
        TTS["TTS Node<br/>(ElevenLabs/OpenAI)<br/>Text → Speech<br/>Dual Streaming"]
    end

    subgraph LLMSDK["@workflow/llm-sdk Library<br/>(200-500ms faster per call)"]
        Route["Model Routing"]
        Cache["Semantic Caching"]
    end

    subgraph CrossProduct["Cross-Product Coordination"]
        ChatbotPause["voicebot_session_started<br/>→ Chatbot pauses"]
        ImageShare["chatbot_image_processed<br/>→ Voice agent receives data"]
    end

    Interrupt["Barge-in Handling"]
    Transfer["Human Transfer<br/>(SIP Bridge - Twilio)"]
    Response["Voice Response<br/>(<300ms latency target)<br/>(200ms improvement)"]

    Recording["Call Recording → S3"]
    Transcript["Transcript → PostgreSQL"]

    Analytics["Service 12: Analytics<br/>Call Metrics & Quality"]

    Call --> STT
    STT --> LLM
    LLM --> Route
    Route --> Cache
    Cache --> LLM
    LLM --> TTS
    TTS --> Interrupt
    TTS --> Response
    Interrupt --> STT
    LLM -.->|escalation| Transfer
    Response --> Recording
    Response --> Transcript
    Response --> Analytics

    ChatbotPause -.-> Service9
    ImageShare -.-> LLM

    style STT fill:#e3f2fd
    style TTS fill:#e3f2fd
    style Response fill:#e1f5e1
```

---

## 8. Phase 5: Support & Success Workflows

```mermaid
flowchart TB
    subgraph SupportTrack["Support Track (90% Automation)"]
        Ticket["ticket_created"]
        AISupport["🤖 AUTO: AI Support Engine<br/>• Knowledge base lookup<br/>• Automated resolution<br/>• Config tuning suggestions"]
        Complex["Complex Issue?"]
        HumanEsc["👤 HUMAN: Support Specialist<br/>Escalation Handling"]
        Resolved["ticket_resolved"]
        Supervision["🤖 AUTO: AI Supervision<br/>Pattern Analysis"]
        ConfigUpdate["config_updated<br/>→ Hot-Reload"]
    end

    subgraph SuccessTrack["Success Track"]
        DailyKPI["🤖 AUTO: Daily KPI Monitoring<br/>• Usage analytics<br/>• Health scoring<br/>• Churn prediction"]
        MonthlyQBR["👤 HUMAN: Success Manager<br/>Monthly QBR Review"]
        Upsell["opportunity_identified"]

        subgraph UpsellFlow["Upsell Workflow"]
            InviteSpec["Success Manager<br/>Invites Sales Specialist"]
            Pitch["Sales Specialist<br/>Expansion Pitch"]
            Close["upsell_closed"]
            HandoffBack["specialist_handoff_back<br/>→ Success Manager"]
        end
    end

    Ticket --> AISupport
    AISupport --> Complex
    Complex -->|Yes - 10%| HumanEsc
    Complex -->|No - 90%| Resolved
    HumanEsc --> Resolved
    Resolved --> Supervision
    Supervision --> ConfigUpdate

    DailyKPI --> MonthlyQBR
    MonthlyQBR --> Upsell
    Upsell --> InviteSpec
    InviteSpec --> Pitch
    Pitch --> Close
    Close --> HandoffBack
    HandoffBack --> MonthlyQBR

    style AISupport fill:#e1f5e1
    style HumanEsc fill:#fff3e0
    style MonthlyQBR fill:#fff3e0
```

---

## 9. Phase 5: Client Self-Service & Personalization

```mermaid
flowchart TB
    subgraph SelfService["Service 6: PRD Builder & Configuration Workspace<br/>(Unified - includes client self-service)"]
        ChatAgent["🤖 Conversational Agent<br/>(Claude AI)<br/>Natural language editing"]
        Dashboard["📊 Visual Dashboard<br/>• Version control<br/>• Sandbox testing<br/>• Rollback"]
        Permissions["Member Permissions<br/>• Role-based access<br/>• Risk levels<br/>• Approval workflows"]
    end

    Change["client_config_change_requested"]
    Validate["🤖 AUTO: Validate & Assess Risk"]
    Preview["config_preview_generated<br/>Sandbox Environment"]
    Approve["Client Approves"]
    Apply["client_config_applied"]

    subgraph ConfigSDK["@workflow/config-sdk Library<br/>(50-100ms faster than service)"]
        HotReload["🔄 Hot-Reload<br/><1s deployment<br/>(50-100ms improvement)"]
        Runtime["Agent Orchestration +<br/>Voice Agent"]
    end

    subgraph Personalization["Service 20: Communication & Hyperpersonalization<br/>(Unified outreach + personalization)"]
        CohortEngine["Cohort Assignment Engine<br/>RFM Analysis"]
        ABEngine["A/B Testing Engine<br/>Thompson Sampling<br/>Multi-Armed Bandit"]
        EngageTrack["Engagement Tracking"]
        WeightUpdate["Variant Weight Updates<br/>Beta(α, β) distribution"]
    end

    ChatAgent --> Change
    Dashboard --> Change
    Change --> Validate
    Validate --> Preview
    Preview --> Approve
    Approve --> Apply
    Apply --> HotReload
    HotReload --> Runtime

    CohortEngine --> ABEngine
    ABEngine --> Runtime
    Runtime --> EngageTrack
    EngageTrack --> WeightUpdate
    WeightUpdate --> ABEngine

    style ChatAgent fill:#e3f2fd
    style HotReload fill:#e1f5e1
    style ABEngine fill:#e1f5e1
```

---

## 10. Phase 6: Iteration & Expansion

```mermaid
flowchart TB
    Identify["👤 HUMAN: Success Manager<br/>Identifies Iteration Need<br/>• New use cases<br/>• Feature expansion<br/>• Integration additions"]

    subgraph Service0["Service 0: Organization & Identity Management<br/>(Handles all agent handoffs)"]
        InviteOnboard["specialist_invited<br/>Success → Onboarding Specialist"]
        Accept["Specialist Accepts"]
    end

    subgraph Service6["Service 6: PRD Builder & Configuration Workspace"]
        UpdatePRD["👤 HUMAN + 🤖 AI:<br/>Update PRD<br/>Collaborative Editing"]
        Approve["prd_updated"]
    end

    subgraph Service7["Service 7: Automation Engine"]
        Regen["🤖 AUTO: Regenerate Config<br/>Incremental Changes"]
    end

    Deploy["config_deployed<br/>Hot-Reload via @workflow/config-sdk<br/>(50-100ms faster)"]

    Exit["specialist_handoff_back<br/>→ Success Manager<br/>(via Service 0)"]
    Continue["Continue Success Track"]

    Identify --> InviteOnboard
    InviteOnboard --> Accept
    Accept --> UpdatePRD
    UpdatePRD --> Approve
    Approve --> Regen
    Regen --> Deploy
    Deploy --> Exit
    Exit --> Continue

    style UpdatePRD fill:#e3f2fd
    style Regen fill:#e1f5e1
```

---

## 11. Human Agent Handoff Workflows

```mermaid
flowchart TB
    subgraph Lifecycle["Client Lifecycle with Human Agents"]
        Start["Organization Created"]

        subgraph Sales["Sales Stage (40% Human)"]
            SalesAgent["Sales Agent<br/>• Research review<br/>• Demo presentation<br/>• Negotiation"]
        end

        subgraph Onboarding["Onboarding Stage (40% Human)"]
            OnboardSpec["Onboarding Specialist<br/>• PRD collaboration<br/>• Config review<br/>• Week 1 monitoring"]
        end

        subgraph Operations["Operations Stage (10% Human)"]
            SupportSpec["Support Specialist<br/>• Complex escalations<br/>• Config tuning<br/>• Quality supervision"]

            SuccessMgr["Success Manager<br/>• Monthly QBRs<br/>• Expansion identification<br/>• Strategic planning"]
        end

        subgraph Specialists["Dynamic Specialists"]
            SalesSpec["Sales Specialist<br/>(Upsell/Expansion)"]
            OnboardSpec2["Onboarding Specialist<br/>(Iteration Projects)"]
        end
    end

    subgraph Handoffs["Handoff Triggers"]
        H1["proposal_signed<br/>Sales → Onboarding"]
        H2["onboarding_week1_complete<br/>Onboarding → Support + Success<br/>(Parallel)"]
        H3["opportunity_identified<br/>Success → Sales Specialist"]
        H4["iteration_requested<br/>Success → Onboarding Specialist"]
        H5["upsell_closed /<br/>iteration_complete<br/>Specialist → Success Manager"]
    end

    Start --> SalesAgent
    SalesAgent -->|H1| OnboardSpec
    OnboardSpec -->|H2| SupportSpec
    OnboardSpec -->|H2| SuccessMgr
    SuccessMgr -->|H3| SalesSpec
    SuccessMgr -->|H4| OnboardSpec2
    SalesSpec -->|H5| SuccessMgr
    OnboardSpec2 -->|H5| SuccessMgr

    style SalesAgent fill:#fff3e0
    style OnboardSpec fill:#fff3e0
    style SuccessMgr fill:#fff3e0
```

---

## 12. Service 21: Agent Copilot Dashboard

```mermaid
flowchart TB
    subgraph HumanAgents["Human Agents (All Roles)"]
        Sales["Sales Agent"]
        Onboard["Onboarding Specialist"]
        Support["Support Specialist"]
        Success["Success Manager"]
        SalesSpec["Sales Specialist"]
    end

    subgraph Service21["Service 21: Agent Copilot"]
        Dashboard["Unified Dashboard<br/>WebSocket Real-Time Updates"]

        subgraph CoreFeatures["7 Core Features"]
            Context["Context Aggregation<br/>(17 Kafka Topics)"]
            ActionPlan["AI Action Planning<br/>(@workflow/llm-sdk)"]
            CommDraft["Communication Drafting<br/>(Emails, Agendas, QBRs)"]
            Approval["Approval Orchestration<br/>(Intelligent Routing)"]
            CRMSync["CRM Auto-Sync<br/>(Salesforce, HubSpot, Zendesk)"]
            Village["Village Knowledge<br/>(Semantic Search - Qdrant)"]
            Perf["Performance Dashboard<br/>(Metrics, Coaching, Benchmarks)"]
        end
    end

    subgraph EventSources["Event Sources (17 Kafka Topics)"]
        Auth["auth_events<br/>agent_events"]
        Research["research_events"]
        Demo["demo_events"]
        SalesDoc["sales_doc_events"]
        Billing["billing_events"]
        PRD["prd_events"]
        Config["config_events"]
        Conv["conversation_events"]
        Voice["voice_events"]
        Monitor["monitoring_incidents"]
        Analytics["analytics_experiments"]
        CS["customer_success_events"]
        SupportE["support_events"]
        Comm["communication_events"]
        Escal["escalation_events"]
        Cross["cross_product_events"]
        CRM["crm_events"]
    end

    subgraph Integrations["External Integrations"]
        LLMSDK["@workflow/llm-sdk<br/>(Action Planning)"]
        Service15["Service 15: CRM Integration"]
        Service17["Service 17: RAG Pipeline<br/>(Village Knowledge)"]
    end

    Sales --> Dashboard
    Onboard --> Dashboard
    Support --> Dashboard
    Success --> Dashboard
    SalesSpec --> Dashboard

    Dashboard --> Context
    Dashboard --> ActionPlan
    Dashboard --> CommDraft
    Dashboard --> Approval
    Dashboard --> CRMSync
    Dashboard --> Village
    Dashboard --> Perf

    Auth --> Context
    Research --> Context
    Demo --> Context
    SalesDoc --> Context
    Billing --> Context
    PRD --> Context
    Config --> Context
    Conv --> Context
    Voice --> Context
    Monitor --> Context
    Analytics --> Context
    CS --> Context
    SupportE --> Context
    Comm --> Context
    Escal --> Context
    Cross --> Context
    CRM --> Context

    ActionPlan --> LLMSDK
    CommDraft --> LLMSDK
    CRMSync --> Service15
    Village --> Service17

    style Dashboard fill:#e3f2fd
    style Context fill:#e1f5e1
    style ActionPlan fill:#fff3e0
    style CommDraft fill:#fff3e0
    style Village fill:#f3e5f5
```

**Service 21 Benefits:**
- **3x Agent Capacity:** Agents manage 3x more clients with AI assistance
- **Context Switching Eliminated:** From 10+ systems → 1 unified dashboard
- **Decision Time Reduced:** AI action planning reduces decision time from hours to minutes
- **Quality Consistency:** Communication drafting ensures brand voice across all agents
- **Knowledge Sharing:** Village knowledge surfaces best practices from 100+ implementations

---

## 13. Event Flow Architecture

```mermaid
flowchart LR
    subgraph Producers["Event Producers (17 Services)"]
        S0["Service 0:<br/>Auth + Agent Events"]
        S1["Service 1:<br/>Research Events"]
        S2["Service 2:<br/>Demo Events"]
        S3["Service 3:<br/>Sales Doc Events<br/>(NDA+Pricing+Proposal)"]
        S6["Service 6:<br/>PRD Events"]
        S7["Service 7:<br/>Config Events"]
        S8["Service 8:<br/>Conversation Events"]
        S9["Service 9:<br/>Voice Events"]
        S13["Service 13:<br/>Customer Success Events"]
        S20["Service 20:<br/>Communication Events<br/>(Outreach+Personalization)"]
        S21["Service 21:<br/>Agent Action Events"]
        S22["Service 22:<br/>Billing Events"]
    end

    subgraph Kafka["Apache Kafka (18 Topics - Optimized)"]
        T1["auth_events"]
        T2["agent_events"]
        T3["research_events"]
        T4["communication_events"]
        T5["client_events"]
        T6["demo_events"]
        T7["sales_doc_events"]
        T8["prd_events"]
        T9["billing_events"]
        T11["config_events"]
        T12["conversation_events"]
        T13["voice_events"]
        T14["cross_product_events"]
        T15["monitoring_incidents"]
        T16["analytics_experiments"]
        T17["support_events"]
        T18["customer_success_events"]
        T19["crm_events"]
    end

    subgraph Consumers["Event Consumers (Services + Libraries)"]
        C_Research["Research Engine<br/>Triggers"]
        C_Demo["Demo Generator<br/>Triggers"]
        C_Sales["Sales Doc Generator<br/>Triggers"]
        C_PRD["PRD Builder<br/>Triggers"]
        C_Auto["Automation Engine<br/>Triggers"]
        C_Runtime["Runtime Services<br/>(Hot-Reload via<br/>@workflow/config-sdk)"]
        C_Copilot["Agent Copilot<br/>(Consumes 17 Topics)"]
        C_Analytics["Analytics Service<br/>(All Events)"]
        C_Monitor["Monitoring Engine<br/>(All Events)"]
    end

    S0 --> T1
    S0 --> T2
    S0 --> T5
    S1 --> T3
    S2 --> T6
    S3 --> T7
    S6 --> T8
    S7 --> T11
    S8 --> T12
    S9 --> T13
    S20 --> T4

    S1 --> T3
    S2 --> T6
    S3 --> T7
    S6 --> T8
    S7 --> T11
    S8 --> T12
    S9 --> T13
    S13 --> T18
    S20 --> T4
    S22 --> T9

    T1 --> C_Research
    T4 --> C_Demo
    T6 --> C_Sales
    T7 --> C_PRD
    T8 --> C_Auto
    T11 --> C_Runtime

    T1 --> C_Copilot
    T2 --> C_Copilot
    T3 --> C_Copilot
    T4 --> C_Copilot
    T6 --> C_Copilot
    T7 --> C_Copilot
    T9 --> C_Copilot
    T8 --> C_Copilot
    T11 --> C_Copilot
    T12 --> C_Copilot
    T13 --> C_Copilot
    T15 --> C_Copilot
    T16 --> C_Copilot
    T17 --> C_Copilot
    T18 --> C_Copilot
    T19 --> C_Copilot

    T1 --> C_Analytics
    T2 --> C_Analytics
    T3 --> C_Analytics
    T4 --> C_Analytics
    T5 --> C_Analytics
    T6 --> C_Analytics
    T7 --> C_Analytics
    T8 --> C_Analytics
    T9 --> C_Analytics
    T11 --> C_Analytics
    T12 --> C_Analytics
    T13 --> C_Analytics

    T1 --> C_Monitor
    T11 --> C_Monitor
    T12 --> C_Monitor
    T13 --> C_Monitor

    style Kafka fill:#f3e5f5
    style C_Copilot fill:#e3f2fd
```

---

## 14. Service Dependencies

```mermaid
flowchart TB
    subgraph Tier0["Tier 0: Critical Infrastructure (System-wide impact if down)"]
        Kong["Kong API Gateway"]
        Auth["Service 0: Organization &<br/>Identity Management"]
        LLMSDK["@workflow/llm-sdk Library<br/>(200-500ms faster)"]
        ConfigSDK["@workflow/config-sdk Library<br/>(50-100ms faster)"]
        Kafka["Apache Kafka"]
        Redis["Redis Cluster"]
    end

    subgraph Tier1["Tier 1: Customer-Facing (Conversation impact)"]
        AgentOrch["Service 8: Agent Orchestration<br/>(uses @workflow/llm-sdk)"]
        VoiceAgent["Service 9: Voice Agent<br/>(uses @workflow/llm-sdk)"]
        RAG["Service 17: RAG Pipeline"]
    end

    subgraph Tier2["Tier 2: Feature Services (Degraded functionality)"]
        Monitor["Service 11: Monitoring"]
        Analytics["Service 12: Analytics"]
        Comm["Service 20: Communication &<br/>Hyperpersonalization"]
        Copilot["Service 21: Agent Copilot<br/>(uses @workflow/llm-sdk)"]
    end

    subgraph Tier3["Tier 3: Background Services (Manual fallback)"]
        Research["Service 1: Research"]
        Demo["Service 2: Demo Generator"]
        Sales["Service 3: Sales Doc Generator"]
        Success["Service 13: Customer Success<br/>(uses @workflow/llm-sdk)"]
        Support["Service 14: Support Engine<br/>(uses @workflow/llm-sdk)"]
        Billing["Service 22: Billing & Revenue Management"]
    end

    Kong --> Auth
    Auth --> Kafka

    AgentOrch --> LLMSDK
    AgentOrch --> ConfigSDK
    AgentOrch --> RAG
    AgentOrch --> Comm

    VoiceAgent --> LLMSDK
    VoiceAgent --> ConfigSDK

    Copilot --> LLMSDK
    Copilot --> Kafka
    Copilot --> RAG

    LLMSDK --> Redis
    ConfigSDK --> Redis

    Research --> Kafka
    Demo --> Kafka
    Sales --> Kafka
    Success --> Analytics
    Support --> Auth
    Billing --> Kafka

    Analytics --> Kafka
    Monitor --> Kafka

    style Tier0 fill:#fce4ec
    style Tier1 fill:#fff3e0
    style Tier2 fill:#e3f2fd
    style Tier3 fill:#f3e5f5
    style Copilot fill:#e3f2fd
```

---

## Summary

These modular diagrams break down the complete platform workflow into digestible sections that will render properly in GitHub, Notion, or any mermaid-compatible viewer.

**Architecture Consolidation (22 → 17 Services):**
- **Service 0.5 → Service 0:** Unified organization & agent management
- **Services 3, 4, 5 → Service 3:** Unified sales document generation (150-300ms faster)
- **Service 18 → Service 20:** Unified communication & hyperpersonalization
- **Service 19 → Service 6:** Client self-service integrated into PRD workspace
- **Service 10 → @workflow/config-sdk:** Direct config access (50-100ms faster)
- **Service 16 → @workflow/llm-sdk:** Direct LLM calls (200-500ms faster per call)
- **Service 21: Agent Copilot:** NEW - AI-powered unified dashboard for human agents (3x capacity increase)
- **Service 22: Billing & Revenue Management:** NEW - Subscription, invoicing, payment processing

**Performance Improvements:**
- **Sales pipeline:** 150-300ms faster (3-service → 1-service)
- **LLM calls:** 200-500ms faster per call (no gateway hop)
- **Config operations:** 50-100ms faster (direct S3 access)
- **Agent productivity:** 3x capacity increase (Service 21 unified dashboard)
- **Total workflow:** 400-900ms faster per complete client lifecycle

**Kafka Topics:** 18 topics (optimized from 19 original topics)
- `sales_doc_events` replaces `nda_events`, `pricing_events`, `proposal_events`
- `communication_events` replaces `outreach_events`, `personalization_events`
- `billing_events` added for Service 22 (payment processing, subscription management)
- **Service 21 consumes 17 topics** for real-time agent context aggregation

**Key Patterns Across Diagrams:**
- **Green boxes** (🤖 AUTO): Fully automated by AI/system
- **Orange boxes** (👤 HUMAN): Requires human intervention
- **Blue boxes** (🤝 HYBRID): AI-driven with optional human collaboration
- **Purple boxes**: Events triggering next steps
- **Red boxes**: Critical infrastructure dependencies

**Navigation Guide:**
1. Start with **High-Level System Overview** for the big picture
2. Follow the phases sequentially (0→6) for the complete journey
3. Dive into **Runtime Operations** (6-7) to see chatbot/voicebot workflows
4. Review **Human Agent Handoffs** (11) for understanding human orchestration
5. See **Service 21: Agent Copilot Dashboard** (12) for human agent productivity system
6. Study **Event Flow** (13) and **Dependencies** (14) for technical architecture

