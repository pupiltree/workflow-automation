# Master Agent Architecture: Recursive Intelligence System

**Version**: 1.0
**Created**: 2025-10-11
**Status**: Architecture Design Complete - Ready for Implementation
**Implementation Start**: Sprint 22 (after Service 13 completes)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Founder's Vision](#the-founders-vision)
3. [Core Concept: PRD Builder as General Problem Solver](#core-concept-prd-builder-as-general-problem-solver)
4. [The Business Goal Orchestration Mental Model](#the-business-goal-orchestration-mental-model)
5. [Technical Architecture](#technical-architecture)
   - [LangGraph Recursive Agent-Tools Pattern](#langgraph-recursive-agent-tools-pattern)
   - [State Management](#state-management)
   - [Runtime Graph Compilation](#runtime-graph-compilation) ⚡ **NEW**
   - [Intelligent Termination Conditions](#intelligent-termination-conditions) ⚡ **NEW**
   - [Agent Node: Reasoning](#agent-node-reasoning)
   - [Tools Node: Execution](#tools-node-execution-mix-of-functions--sub-agents)
   - [Sub-Agent Registry](#sub-agent-registry)
6. [Service 13 Integration](#service-13-integration)
7. [Samsung Store Example Walkthrough](#samsung-store-example-walkthrough)
8. [Implementation Roadmap](#implementation-roadmap)
9. [Code Examples](#code-examples)
10. [Self-Evolution Mechanism](#self-evolution-mechanism)
11. [Comparison: Current vs Master Agent](#comparison-current-vs-master-agent)
12. [Risk Assessment](#risk-assessment)
13. [Success Metrics](#success-metrics)

---

## Executive Summary

### What is the Master Agent?

**Master Agent** is a generalized problem-solving system that takes ambiguous business goals and autonomously figures out how to achieve them through **recursive decomposition** and **dynamic capability creation**.

**Key Insight**: Service 6 (PRD Builder) already implements this pattern for chatbot/voicebot requirements. The Master Agent extends this pattern to solve **any business problem**, not just PRD generation.

### The Technical Pattern

```
GOAL (ambiguous) → AGENT NODE (reasoning) → TOOLS NODE (actions) → RESULT (comprehensive solution)
                                             ↑                    ↓
                                             └── Tools = Mix of functions + SUB-AGENTS (recursive!)
```

### Why This Works

**LangGraph Research (2024-2025)**:
> "The supervisor can be thought of as an agent whose tools are other agents."

This enables:
- **Infinite recursion**: Agents can call agents that call agents (arbitrary depth)
- **Dynamic specialization**: Create new specialist agents when gaps detected
- **Self-evolution**: Learn from outcomes, store patterns, improve over time

### Implementation Timeline

**Sprint 22-27** (12 weeks / 3 months):
- Sprint 22-23: Abstract PRD Builder → `RequirementsIntelligenceEngine`
- Sprint 24-25: Build recursive sub-agent library
- Sprint 26-27: Integrate with Service 13 (Customer Success)

**After Integration**: Service 13 becomes platform-wide Master Agent orchestrator

---

## The Founder's Vision

### Original Master Agent PRD Goal

> "A goal-driven management system that can think strategically, act autonomously, and evolve continuously. When the system encounters a gap — a missing capability or role — it can design new Servant Agents, define their success metrics, and integrate them into future planning."

### Key Requirements

1. **Goal-Oriented Behavior**: Convert ambiguous business goals into measurable outcomes
2. **Strategic Orchestration**: Coordinate multiple specialized agents
3. **Self-Evolution**: Create new capabilities when gaps detected
4. **Data Intelligence**: Autonomous data analysis and insight generation
5. **Context Management**: Maintain relevant memory across all interactions
6. **Human-AI Collaboration**: Work alongside humans with appropriate oversight

### Founder's Key Insight

> "If we abstract PRD Builder to this level such that it can be used for any use case, then we will be able to literally solve any use case using this simple looping pattern: agents node, tools node, and the tools inside tools node can be subagents also."

**This insight is architecturally sound and matches LangGraph best practices.**

---

## Core Concept: PRD Builder as General Problem Solver

### What PRD Builder Actually Does (Abstracted)

**Service 6 (PRD Builder) Pattern**:

```
INPUT: Ambiguous business problem
  "I need better customer support"

PROCESS: Intelligent interrogation pattern
  1. Cross-question progressively deeper
     - "What percentage of queries could be automated?"
     - "Do you have historical query data?"
     - "What's your escalation process?"

  2. Retrieve similar solved problems (village knowledge)
     - "E-commerce clients achieved 78% automation for Tier 1 support"

  3. Think beyond stated requirements
     - Suggest: "Implement proactive upsell during support interactions"
     - Rationale: "12% increase in AOV from contextual recommendations"

  4. Detect gaps
     - Missing data: "Need historical query logs for classification model"
     - Missing integrations: "Need Zendesk API access"

  5. Validate against reality
     - Cross-check client claims vs industry benchmarks

  6. Iterative refinement
     - Client feedback loop refines requirements

OUTPUT: Comprehensive solution specification (PRD document)
```

### Domain-Agnostic Intelligence Pattern

**This exact pattern works for ANY domain**:

| Domain | Input | Output | Village Knowledge |
|--------|-------|--------|-------------------|
| **Chatbot PRD** | Business requirements | Product requirements doc | Client success patterns |
| **Medical Diagnosis** | Patient symptoms | Diagnostic report | Anonymized case studies |
| **Legal Case Analysis** | Client problem | Legal strategy | Case law precedents |
| **Business Consulting** | Company goal | Strategic roadmap | Industry best practices |
| **Samsung Store** | "Increase attach rate 20%" | Implementation strategy | Retail optimization patterns |

**Key Insight**: PRD Builder's intelligence comes from its **methodology**, not its domain knowledge. The methodology is 100% generalizable.

---

## The Business Goal Orchestration Mental Model

### How Master Agent Solves Business Problems

**Real-World Scenario from Goal-Oriented Hybrid Agent System**: Samsung India Franchise Store wants to increase re-orders, upsells, and cross-sells by 20%.

```
MASTER AGENT: "Store Growth Orchestrator" (thinks):

  1. ANALYZE THE SITUATION
     Do I understand current performance?
     → Check billing data, identify attach rate: 3%
     → Check ERP data, identify staff variance: 2-8%
     → Industry benchmark: 7%
     → GAP DETECTED: 57% below target

  2. IDENTIFY ROOT CAUSE
     Do I have capability to analyze this? → Check capabilities
     → Need deep data analysis: DON'T have this capability
     → SPIN UP SUB-AGENT: ResearchAgent
       ├─ Query staff performance by tenure
       ├─ Run statistical correlation analysis
       ├─ SPIN UP SUB-SUB-AGENT: DataAnalysisAgent
       │  └─ Result: Veteran staff (24+ months) underperform (3%)
       │            New staff (0-6 months) excel (8%)
       │            Correlation: r = -0.72 (burnout hypothesis)
       └─ Check village knowledge for similar patterns
          └─ Found: "Retail staff burnout after 18-24 months" pattern

  3. DESIGN INTERVENTION STRATEGY
     Do I have capability to design strategies? → Check capabilities
     → Need strategic intervention design: DON'T have this capability
     → SPIN UP SUB-AGENT: StrategyGeneratorAgent
       ├─ Evaluate options: Coaching vs Automation vs Hybrid
       ├─ SPIN UP SUB-SUB-AGENT: ABTestDesignerAgent
       │  └─ Result: Hybrid approach (Coaching + Automation)
       │            Expected lift: 4-5% (exceeds 20% goal)
       │            Confidence: 0.82
       └─ Result: "Hybrid Coaching + Chatbot Automation"

  4. CREATE IMPLEMENTATION PLAN
     Do I have capability to create playbooks? → Check capabilities
     → Need playbook generation: DON'T have this capability
     → SPIN UP SUB-AGENT: ImplementationPlannerAgent
       ├─ SPIN UP SUB-SUB-AGENT: PlaybookGeneratorAgent
       │  └─ Creates: "Staff Performance Monitor" playbook
       │            Triggers: Weekly batch + Real-time alerts
       │            Steps: Query staff performance → Alert coaches
       ├─ Resource estimation: 2 coaches, 1 IT dev, $9K budget
       └─ Risk mitigation: Change management plan

  5. DEPLOY & TRACK
     Deploy new capability (playbook ID #4521)
     Schedule outcome tracking (measure after 60 days)
     Store expected outcome: Attach rate 3% → 7%

  6. SELF-EVOLUTION (60 days later)
     Measure actual: 7.2% ✅ (exceeds 7% target)
     Store learning in village knowledge:
       - Problem: "low_retail_attach_rate"
       - Root cause: "veteran_staff_burnout"
       - Solution: "hybrid_coaching_and_automation"
       - Evidence: "Samsung Store 5: 3% → 7.2% in 58 days"
       - Confidence: 0.95 (validated)

  7. REUSE (next similar problem)
     Another store needs help with attach rate
     → Retrieve pattern from village knowledge
     → Recommend proven solution immediately
     → Solution delivered in 5 minutes (vs 2 hours first time)
     → This is SELF-EVOLUTION
```

### Master Agent = Strategic Business Orchestrator

**The exact same pattern in code**:

```python
class MasterAgent:
    async def solve_business_goal(self, goal: str):
        # Agent Node: Strategic Reasoning
        plan = await self.analyze_and_plan(goal)

        # Tools Node: Orchestrate specialists (mix of functions + sub-agents)
        results = []
        for action in plan:
            if action.type == "simple_tool":
                # Direct data access (check_database, calculate_metrics)
                result = await self.execute_function(action)

            elif action.type == "sub_agent":
                # Spin up specialist agent when capability gap detected
                if action.name == "research":
                    specialist = ResearchAgent()  # NEW AGENT CREATED
                elif action.name == "strategy":
                    specialist = StrategyGeneratorAgent()  # NEW AGENT CREATED
                elif action.name == "implementation":
                    specialist = ImplementationPlannerAgent()  # NEW AGENT CREATED

                # Sub-agent can spin up its own sub-agents (recursive!)
                result = await specialist.solve(action.params)

        # Self-Evolution: Store validated solution pattern
        if solution_successful:
            self.village_knowledge.insert({
                "problem_type": "low_attach_rate",
                "solution": results,
                "evidence": actual_outcomes,
                "confidence": 0.95
            })

        return results
```

### Key Behavioral Parallels from Founder's PRD

| Founder's Vision (Original PRD) | Master Agent Implementation | Example from Samsung Store |
|---------------------------------|----------------------------|---------------------------|
| **"Encounters a gap — missing capability"** | Master Agent checks: Do I have this capability? → NO | "Need root cause analysis" → Don't have ResearchAgent |
| **"Design new Servant Agents"** | `specialist = ResearchAgent()` → Spin up new agent | Creates ResearchAgent to analyze staff performance |
| **"Define their success metrics"** | Set Evals: Expected attach rate 7%, confidence 0.82 | Playbook success metric: "attach_rate >= 7%" |
| **"Integrate into future planning"** | Deploy playbook, track outcome, store in village knowledge | Playbook #4521 becomes reusable pattern |
| **"Writes its own queries"** | ResearchAgent → DataAnalysisAgent → SQL queries | `SELECT staff_id, tenure, AVG(attach_rate)...` |
| **"Requests data access"** | Master Agent detects: "Need sales-by-staff details" | Requests staff performance database access |
| **"Orchestrate Servants"** | Master → Research → DataAnalysis → Strategy → Implementation | 4-level recursive agent orchestration |
| **"Compacts learnings"** | Store structured notes: {problem, solution, outcome, confidence} | Village knowledge entry: "Staff burnout → Hybrid coaching + automation" |
| **"Self-Evolution"** | Actual 7.2% > Expected 7% → Update confidence model | Next similar problem solved in 5 min (vs 2 hrs first time) |

**Key Difference from Simple Task Automation**:
- Personal assistant task: "Fix fan" (single action, single domain)
- Master Agent goal: "Increase attach rate 20%" (ambiguous, multi-step, requires strategic thinking)
- Master Agent creates NEW CAPABILITIES (playbooks) that didn't exist before
- Master Agent LEARNS from outcomes and applies learnings to future problems

---

## Technical Architecture

### LangGraph Recursive Agent-Tools Pattern

**Core Pattern** (validated by LangGraph 2024-2025 docs):

```
┌─────────────────────────────────────────────────────┐
│           MASTER AGENT (Level 1)                    │
│                                                     │
│  ┌──────────────┐         ┌──────────────┐        │
│  │ AGENT NODE   │────────▶│ TOOLS NODE   │        │
│  │  (Reasoning) │         │  (Actions)   │        │
│  └──────────────┘         └──────┬───────┘        │
│         ▲                         │                │
│         │                         │                │
│         └─────────────────────────┘                │
│                   Loop until DONE                  │
└─────────────────────────────────────────────────────┘
                          │
                          │ Tools can be:
                          │ 1. Simple functions
                          │ 2. SUB-AGENTS (recursive!)
                          │
          ┌───────────────┴───────────────┐
          │                               │
          ▼                               ▼
    [Simple Tool]              [SUB-AGENT: ResearchAgent]
    check_database()            ┌──────────────────────────┐
                                │  AGENT NODE (Level 2)    │
                                │  (Sub-reasoning)         │
                                └──────────┬───────────────┘
                                           │
                                           ▼
                                ┌──────────────────────────┐
                                │  TOOLS NODE (Level 2)    │
                                │  (Sub-actions)           │
                                └──────────┬───────────────┘
                                           │
                        ┌──────────────────┴──────────────┐
                        │                                 │
                        ▼                                 ▼
                  [Simple Tool]              [SUB-SUB-AGENT: DataAnalyzer]
                  query_api()                 (RECURSIVE - Level 3!)
                                              └─── And so on... INFINITE DEPTH
```

### State Management

**LangGraph StateGraph with Checkpointing**:

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage

class MasterAgentState(TypedDict):
    """
    State maintained throughout agent execution.
    """
    # Input
    goal: str
    context: dict

    # Conversation history
    messages: Annotated[Sequence[BaseMessage], "The conversation messages"]

    # Progress tracking
    current_plan: list
    completed_steps: list
    pending_actions: list

    # Results
    findings: dict
    solution: dict

    # Self-evolution data
    learnings: list
    confidence_score: float

    # Termination tracking
    iteration_count: int
    max_iterations: int
    progress_score: float  # 0.0 to 1.0, measures goal completion

# Create workflow
workflow = StateGraph(MasterAgentState)

# Add nodes
workflow.add_node("agent", agent_reasoning_node)
workflow.add_node("tools", tools_execution_node)

# Add edges
workflow.add_conditional_edges(
    "agent",
    should_continue,  # Decides: continue, end, or escalate
    {
        "continue": "tools",
        "end": END,
        "escalate_to_human": "human_review"
    }
)

workflow.add_edge("tools", "agent")  # Tools always return to agent
workflow.set_entry_point("agent")

# Compile with checkpointing (PostgreSQL-backed) and recursion limit
app = workflow.compile(checkpointer=PostgresCheckpointer())
```

---

### Runtime Graph Compilation

**CRITICAL**: The Master Agent must be able to **dynamically rebuild its workflow graph** based on runtime configuration. This enables:
- Different graph structures for different clients/scenarios
- Dynamic tool/sub-agent availability per tenant
- A/B testing different workflows
- Adaptive complexity scaling (simple vs complex problem handling)

#### The Problem with Static Compilation

**Static compilation** (compile once, use everywhere):
```python
# ❌ ANTI-PATTERN: Static workflow doesn't adapt
workflow = StateGraph(MasterAgentState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tools_node)
# ... edges ...
app = workflow.compile()  # Compiled ONCE

# All clients get the SAME workflow
client_a_result = await app.invoke({"goal": "...", "client_id": "client_a"})
client_b_result = await app.invoke({"goal": "...", "client_id": "client_b"})
```

**Limitations**:
- Cannot customize graph structure per client (e.g., Client A has custom sub-agents, Client B doesn't)
- Cannot adapt complexity based on problem type (simple vs strategic goals)
- Cannot A/B test different workflows
- Cannot hot-reload new sub-agents without service restart

#### LangGraph Runtime Compilation Pattern (2024-2025)

**Dynamic compilation** (rebuild graph on each invocation):

```python
from langgraph.graph import StateGraph
from langgraph.checkpoint.postgres import PostgresCheckpointer
from langchain_core.runnables import RunnableConfig

def make_master_agent_graph(config: RunnableConfig) -> StateGraph:
    """
    Graph-making function that dynamically builds workflow based on runtime config.

    This function is called on EVERY invocation, allowing the graph to adapt
    to different clients, problem types, and available capabilities.
    """

    # Extract configuration
    client_id = config.get("configurable", {}).get("client_id")
    problem_complexity = config.get("configurable", {}).get("complexity", "standard")
    available_sub_agents = config.get("configurable", {}).get("sub_agents", [])

    # Create base workflow
    workflow = StateGraph(MasterAgentState)

    # Add core nodes (always present)
    workflow.add_node("agent", agent_reasoning_node)

    # DYNAMIC: Add tools node with client-specific capabilities
    tools_node_fn = create_tools_node(
        client_id=client_id,
        available_sub_agents=available_sub_agents
    )
    workflow.add_node("tools", tools_node_fn)

    # DYNAMIC: Conditional edges based on problem complexity
    if problem_complexity == "simple":
        # Simple problems: Direct execution, minimal recursion
        workflow.add_conditional_edges(
            "agent",
            should_continue_simple,  # More aggressive termination
            {
                "continue": "tools",
                "end": END
            }
        )
    elif problem_complexity == "strategic":
        # Strategic problems: Allow deeper recursion, human escalation
        workflow.add_conditional_edges(
            "agent",
            should_continue_strategic,  # More lenient termination
            {
                "continue": "tools",
                "end": END,
                "escalate_to_human": "human_review"
            }
        )
        # Add human review node for strategic decisions
        workflow.add_node("human_review", human_review_node)
        workflow.add_edge("human_review", "agent")

    # DYNAMIC: Add client-specific sub-agent nodes
    if "planner_agent" in available_sub_agents:
        # Client has access to advanced Planner sub-agent
        workflow.add_node("planner", planner_agent_node)
        workflow.add_edge("planner", "agent")

    # Standard edges
    workflow.add_edge("tools", "agent")
    workflow.set_entry_point("agent")

    return workflow

def create_tools_node(client_id: str, available_sub_agents: list):
    """
    Dynamically create tools node with client-specific capabilities.
    """

    # Load client-specific configuration
    client_config = load_client_config(client_id)

    # Build tool registry
    tools_registry = {
        # Core tools (always available)
        "check_database": check_database_tool,
        "calculate_metrics": calculate_metrics_tool,
    }

    # Add client-specific sub-agents
    if "research_agent" in available_sub_agents:
        tools_registry["research_agent"] = ResearchAgent

    if "strategy_generator" in available_sub_agents:
        tools_registry["strategy_generator"] = StrategyGeneratorAgent

    # Custom sub-agents (enterprise clients only)
    if client_config.get("tier") == "enterprise":
        if "custom_ml_agent" in client_config.get("custom_agents", []):
            tools_registry["custom_ml_agent"] = client_config["custom_agents"]["custom_ml_agent"]

    async def tools_node_fn(state: MasterAgentState):
        """Tools node with dynamically configured capabilities"""
        tool_calls = state["pending_actions"]
        results = []

        for tool_call in tool_calls:
            if tool_call.name in tools_registry:
                tool = tools_registry[tool_call.name]

                # Execute simple function or invoke sub-agent
                if callable(tool):
                    result = await tool(**tool_call.args)
                else:
                    # Sub-agent class
                    sub_agent = tool()
                    result = await sub_agent.invoke(tool_call.args)

                results.append(ToolMessage(
                    content=str(result),
                    tool_call_id=tool_call.id
                ))
            else:
                results.append(ToolMessage(
                    content=f"Error: Tool {tool_call.name} not available for this client",
                    tool_call_id=tool_call.id
                ))

        return {
            **state,
            "messages": state["messages"] + results
        }

    return tools_node_fn
```

#### Configuration File Pattern (langgraph.json)

**For LangGraph Cloud deployment**, update `langgraph.json` to point to graph-making function:

```json
{
  "graphs": {
    "master_agent": "./services/customer_success/master_agent.py:make_master_agent_graph"
  },
  "dependencies": ["langchain", "langgraph", "openai"],
  "env": {
    "OPENAI_API_KEY": "$OPENAI_API_KEY",
    "DATABASE_URL": "$DATABASE_URL"
  }
}
```

#### Runtime Invocation with Configuration

```python
# Client A: Simple problem, standard tools
response_a = await master_agent.invoke(
    {"goal": "Calculate health score for client XYZ", "messages": []},
    config={
        "configurable": {
            "client_id": "client_a",
            "complexity": "simple",
            "sub_agents": ["research_agent"]
        },
        "recursion_limit": 11  # 2 * 5 + 1 for simple problems
    }
)

# Client B: Strategic problem, advanced tools, enterprise tier
response_b = await master_agent.invoke(
    {"goal": "Increase Samsung Store attach rate by 20%", "messages": []},
    config={
        "configurable": {
            "client_id": "client_b",
            "complexity": "strategic",
            "sub_agents": [
                "research_agent",
                "strategy_generator",
                "implementation_planner",
                "custom_ml_agent"  # Enterprise-only
            ],
            "tier": "enterprise"
        },
        "recursion_limit": 21  # 2 * 10 + 1 for strategic problems
    }
)
```

#### Use Cases for Runtime Compilation

**1. Multi-Tenant Capability Isolation**
```python
def make_master_agent_graph(config: RunnableConfig):
    client_tier = get_client_tier(config.get("configurable", {}).get("client_id"))

    if client_tier == "free":
        # Limited capabilities
        available_sub_agents = ["research_agent"]
    elif client_tier == "pro":
        # Standard capabilities
        available_sub_agents = ["research_agent", "strategy_generator"]
    elif client_tier == "enterprise":
        # Full capabilities + custom agents
        available_sub_agents = get_all_sub_agents() + get_custom_agents(client_id)

    # Build graph with appropriate capabilities
    # ...
```

**2. A/B Testing Different Workflows**
```python
def make_master_agent_graph(config: RunnableConfig):
    experiment_variant = config.get("configurable", {}).get("ab_test_variant", "control")

    if experiment_variant == "control":
        # Original workflow: agent → tools → agent
        workflow.add_conditional_edges("agent", should_continue, ...)

    elif experiment_variant == "planner_first":
        # Experimental: planner → agent → tools → agent
        workflow.set_entry_point("planner")  # Start with planning step
        workflow.add_edge("planner", "agent")

    elif experiment_variant == "parallel_research":
        # Experimental: Run multiple research agents in parallel
        workflow.add_node("parallel_research", parallel_research_node)
        workflow.add_edge("agent", "parallel_research")
        workflow.add_edge("parallel_research", "agent")

    return workflow
```

**3. Adaptive Complexity Scaling**
```python
def make_master_agent_graph(config: RunnableConfig):
    goal_text = config.get("configurable", {}).get("goal", "")

    # Use LLM to classify problem complexity
    complexity = classify_goal_complexity(goal_text)

    if complexity == "trivial":
        # Direct execution, no sub-agents needed
        return make_simple_workflow()

    elif complexity == "moderate":
        # Standard Master Agent workflow
        return make_standard_workflow()

    elif complexity == "strategic":
        # Full recursive sub-agent orchestration
        return make_strategic_workflow(enable_all_sub_agents=True)
```

**4. Dynamic Planner Agent (Meta-Planning)**
```python
def make_master_agent_graph(config: RunnableConfig):
    """
    Instead of pre-defining the workflow, use a Planner Agent to
    dynamically design the execution graph at runtime.
    """

    goal = config.get("configurable", {}).get("goal")

    # Step 1: Planner Agent designs the workflow DAG
    planner_agent = PlannerAgent()
    plan = await planner_agent.invoke({"goal": goal})

    # plan = {
    #   "steps": [
    #     {"id": "step1", "agent": "research_agent", "depends_on": []},
    #     {"id": "step2", "agent": "data_analysis_agent", "depends_on": ["step1"]},
    #     {"id": "step3", "agent": "strategy_generator", "depends_on": ["step1", "step2"]},
    #   ]
    # }

    # Step 2: Convert plan into LangGraph StateGraph
    workflow = StateGraph(MasterAgentState)

    for step in plan["steps"]:
        # Add node for each planned step
        workflow.add_node(step["id"], get_agent_node(step["agent"]))

        # Add edges based on dependencies
        if not step["depends_on"]:
            workflow.set_entry_point(step["id"])
        else:
            for dependency in step["depends_on"]:
                workflow.add_edge(dependency, step["id"])

    return workflow
```

#### Hot Reload with LangGraph CLI

**Development Mode** (auto-reload on code changes):
```bash
langgraph dev --no-docker
```

**What triggers a rebuild**:
- Python source code changes → **Hot reload** (fast, no full rebuild)
- `langgraph.json` changes → **Full rebuild** (slower, rebuilds Docker image)
- `requirements.txt` / `pyproject.toml` changes → **Full rebuild**

**Production**: Use LangGraph Cloud with versioned deployments
```bash
langgraph deploy --version v2.1.0
```

#### Best Practices

| Practice | Why | Example |
|----------|-----|---------|
| **Use graph-making functions** | Enables runtime customization | `make_master_agent_graph(config)` |
| **Pass RunnableConfig** | Standard LangGraph pattern for runtime config | `config.get("configurable", {})` |
| **Load client config from database** | Dynamic per-tenant capabilities | `load_client_config(client_id)` |
| **Version your graphs** | A/B test safely | `ab_test_variant: "control" vs "experimental"` |
| **Classify problem complexity** | Optimize for simple vs complex goals | `if complexity == "simple": use_fast_workflow()` |
| **Cache compiled graphs** | Performance optimization | Cache graph per `(client_id, complexity)` tuple for 5min |

#### Performance Optimization

```python
from functools import lru_cache
from typing import Tuple

@lru_cache(maxsize=100)
def get_compiled_graph(client_id: str, complexity: str) -> CompiledGraph:
    """
    Cache compiled graphs to avoid rebuilding on every invocation.

    Cache key: (client_id, complexity)
    Cache TTL: 5 minutes (handled externally)
    """

    config = {
        "configurable": {
            "client_id": client_id,
            "complexity": complexity,
            "sub_agents": get_client_sub_agents(client_id),
            "tier": get_client_tier(client_id)
        }
    }

    workflow = make_master_agent_graph(config)
    return workflow.compile(checkpointer=PostgresCheckpointer())

# Usage
async def invoke_master_agent(goal: str, client_id: str):
    complexity = classify_goal_complexity(goal)

    # Get cached compiled graph (or compile new one)
    app = get_compiled_graph(client_id, complexity)

    # Invoke with full config
    return await app.invoke(
        {"goal": goal, "messages": []},
        config={
            "configurable": {"client_id": client_id},
            "recursion_limit": get_recursion_limit(complexity)
        }
    )
```

#### Key Principle

> **"In most cases, customizing behavior based on the config should be handled by a single graph"** - LangGraph Docs

The Master Agent uses **one graph-making function** (`make_master_agent_graph`) with **conditional logic** to adapt the graph structure, rather than maintaining multiple separate graph definitions.

---

### Intelligent Termination Conditions

**CRITICAL**: The Master Agent must NOT run indefinitely. It requires intelligent stopping criteria engineered through context and state management.

#### Termination Strategy

**LangGraph Best Practice (2024-2025)**:
- Default recursion limit: 25 steps
- Configurable at runtime: `recursion_limit` parameter
- Throws `GraphRecursionError` when limit exceeded

**Master Agent Termination Conditions** (evaluated in `should_continue` function):

1. **Goal Completion** (Primary)
   ```python
   # Solution is comprehensive and confidence is high
   if state["solution"] and state["confidence_score"] >= 0.75:
       return "end"
   ```

2. **Max Iterations Reached** (Safety)
   ```python
   # Prevent infinite loops (3-5 iterations typical for most goals)
   if state["iteration_count"] >= state["max_iterations"]:
       return "escalate_to_human"
   ```

3. **Progress Stagnation** (Efficiency)
   ```python
   # No meaningful progress in last 2 iterations
   if not making_progress(state):
       return "escalate_to_human"
   ```

4. **Human Escalation Triggers** (Safety)
   ```python
   # Low confidence or high-risk decision detected
   if state["confidence_score"] < 0.50 or high_risk_detected(state):
       return "escalate_to_human"
   ```

5. **LLM Signals Completion** (Primary)
   ```python
   # LLM explicitly indicates task is done (no tool calls)
   if not state["pending_actions"]:
       return "end"
   ```

#### should_continue Implementation

```python
from typing import Literal

def should_continue(state: MasterAgentState) -> Literal["continue", "end", "escalate_to_human"]:
    """
    Intelligent termination logic using multiple criteria.

    This function is the CORE of termination control - it prevents infinite loops
    while allowing the agent to complete complex multi-step reasoning.
    """

    # 1. Check if LLM signaled completion (no more tool calls)
    messages = state["messages"]
    last_message = messages[-1] if messages else None

    if last_message and not getattr(last_message, "tool_calls", None):
        # LLM provided final response without requesting tools
        # This means it believes the task is complete
        return "end"

    # 2. Check iteration limit (safety mechanism)
    iteration_count = state.get("iteration_count", 0)
    max_iterations = state.get("max_iterations", 10)  # Default: 10 iterations

    if iteration_count >= max_iterations:
        # Exceeded max iterations - escalate to human
        logger.warning(f"Max iterations ({max_iterations}) reached for goal: {state['goal']}")
        return "escalate_to_human"

    # 3. Check progress score (efficiency mechanism)
    progress_score = state.get("progress_score", 0.0)

    if progress_score >= 0.95:
        # Goal is 95%+ complete - can safely end
        logger.info(f"Goal {progress_score*100:.1f}% complete - ending")
        return "end"

    # 4. Check confidence score (quality mechanism)
    confidence_score = state.get("confidence_score", 0.0)

    if confidence_score < 0.50 and iteration_count >= 5:
        # Low confidence after 5 iterations - escalate
        logger.warning(f"Low confidence ({confidence_score:.2f}) after {iteration_count} iterations")
        return "escalate_to_human"

    # 5. Check progress stagnation (efficiency mechanism)
    completed_steps = state.get("completed_steps", [])

    if iteration_count >= 3:
        # After 3 iterations, check if we're making progress
        recent_steps = completed_steps[-3:] if len(completed_steps) >= 3 else completed_steps
        unique_recent_steps = len(set(recent_steps))

        if unique_recent_steps <= 1:
            # Stuck in a loop (same step repeated) - escalate
            logger.warning(f"Progress stagnation detected: {recent_steps}")
            return "escalate_to_human"

    # 6. Continue iteration
    return "continue"
```

#### Context Engineering for Termination

**System Prompt Engineering** (Critical for intelligent termination):

```python
system_prompt = f"""
You are a Master Agent solving: {state['goal']}

TERMINATION INSTRUCTIONS:
- When you have gathered SUFFICIENT information to create a comprehensive solution, STOP calling tools
- Respond with your final solution WITHOUT requesting additional tool calls
- A "sufficient" solution includes:
  1. Root cause identified (confidence >= 75%)
  2. Strategy designed (with success probability)
  3. Implementation plan created (with timeline and resources)
  4. Risks assessed and mitigation planned

ITERATION AWARENESS:
- Current iteration: {state['iteration_count']} / {state['max_iterations']}
- Progress: {state['progress_score']*100:.0f}%
- If approaching max iterations ({state['max_iterations']}), prioritize COMPLETING the solution over PERFECTING it

DECISION CRITERIA:
- If confidence >= 75% AND all required components exist → FINISH
- If confidence < 50% after 5 iterations → ESCALATE to human
- If stuck repeating same analysis → ESCALATE to human

Your approach:
1. Break down the goal into sub-goals
2. Determine what capabilities you need
3. Call available tools/sub-agents
4. **IMPORTANT**: Synthesize results and DECIDE when to stop

Available capabilities:
{get_available_tools_and_subagents()}

Context:
{state['context']}

Think step-by-step and decide: Should I call more tools, or do I have enough to provide a final solution?
"""
```

#### Recursion Limit Configuration

```python
# Recommended recursion limit calculation
max_iterations = 10  # Business logic iterations
recursion_limit = 2 * max_iterations + 1  # LangGraph formula: account for agent+tools nodes

# Runtime configuration
try:
    response = await master_agent.invoke(
        {"goal": "Increase Samsung Store attach rate by 20%", "messages": []},
        config={"recursion_limit": recursion_limit}
    )
except GraphRecursionError:
    logger.error("Agent exceeded recursion limit - likely infinite loop")
    # Escalate to human or retry with different parameters
```

#### Progress Tracking

```python
def calculate_progress_score(state: MasterAgentState) -> float:
    """
    Calculate how close we are to goal completion (0.0 to 1.0).

    This score is used in termination logic to determine if we should continue.
    """
    score = 0.0

    # Component 1: Root cause identified (25%)
    if state.get("findings", {}).get("root_cause"):
        score += 0.25

    # Component 2: Strategy designed (25%)
    if state.get("solution", {}).get("strategy"):
        score += 0.25

    # Component 3: Implementation plan created (25%)
    if state.get("solution", {}).get("implementation_plan"):
        score += 0.25

    # Component 4: Confidence threshold met (25%)
    confidence = state.get("confidence_score", 0.0)
    if confidence >= 0.75:
        score += 0.25
    elif confidence >= 0.50:
        score += 0.15  # Partial credit

    return score

def update_state_progress(state: MasterAgentState) -> MasterAgentState:
    """
    Update progress tracking in state after each iteration.
    """
    return {
        **state,
        "iteration_count": state.get("iteration_count", 0) + 1,
        "progress_score": calculate_progress_score(state)
    }
```

#### Termination Monitoring and Debugging

```python
class TerminationMonitor:
    """
    Tracks termination patterns for debugging and optimization.
    """

    def log_termination(self, state: MasterAgentState, reason: str):
        """Log why agent terminated."""
        logger.info(f"""
Master Agent Termination Report:
- Goal: {state['goal']}
- Reason: {reason}
- Iterations: {state.get('iteration_count', 0)} / {state.get('max_iterations', 0)}
- Progress: {state.get('progress_score', 0.0)*100:.1f}%
- Confidence: {state.get('confidence_score', 0.0)*100:.1f}%
- Completed Steps: {len(state.get('completed_steps', []))}
        """)

    async def analyze_termination_patterns(self):
        """
        Analyze termination patterns across all executions.

        Used to optimize max_iterations and termination thresholds.
        """
        patterns = await self.db.query("""
            SELECT
                reason,
                AVG(iteration_count) as avg_iterations,
                AVG(progress_score) as avg_progress,
                COUNT(*) as count
            FROM master_agent_executions
            GROUP BY reason
        """)

        return patterns
```

#### Best Practices Summary

| Mechanism | Purpose | Threshold | Escalation |
|-----------|---------|-----------|------------|
| **LLM Signal** | Primary termination | No tool calls in response | END |
| **Progress Score** | Goal completion | >= 95% | END |
| **Max Iterations** | Safety limit | 10 iterations | ESCALATE |
| **Confidence Score** | Quality gate | < 50% after 5 iterations | ESCALATE |
| **Stagnation Detection** | Efficiency | Same step 3x in a row | ESCALATE |
| **Recursion Limit** | Hard safety | 21 steps (2*10+1) | GraphRecursionError |

**Key Principle**: The agent should terminate when it has **sufficient** information to solve the problem, not **perfect** information. Over-optimization leads to wasted compute and user frustration.

### Agent Node: Reasoning

```python
async def agent_reasoning_node(state: MasterAgentState) -> MasterAgentState:
    """
    Agent Node: LLM reasons about approach and decides which tools/sub-agents to invoke.
    """
    messages = state["messages"]

    # System prompt with available capabilities
    system_prompt = f"""
    You are a Master Agent solving: {state['goal']}

    Your approach:
    1. Break down the goal into sub-goals
    2. Determine what capabilities you need
    3. Call available tools/sub-agents
    4. Synthesize results into comprehensive solution

    Available capabilities:
    {get_available_tools_and_subagents()}

    Context:
    {state['context']}

    Think step-by-step and decide which actions to take next.
    """

    # LLM decides which tools/sub-agents to invoke
    response = await llm.ainvoke(
        messages=[SystemMessage(content=system_prompt)] + messages,
        tools=get_tool_schemas()  # Includes both functions and sub-agent schemas
    )

    # Update state
    new_state = {
        **state,
        "messages": messages + [response],
        "pending_actions": response.tool_calls  # What to execute next
    }

    return new_state
```

### Tools Node: Execution (Mix of Functions + Sub-Agents)

```python
async def tools_execution_node(state: MasterAgentState) -> MasterAgentState:
    """
    Tools Node: Executes simple functions OR invokes sub-agents (recursive).
    """
    tool_calls = state["pending_actions"]
    results = []

    for tool_call in tool_calls:
        if tool_call.name in SIMPLE_TOOLS:
            # Execute simple function
            result = await SIMPLE_TOOLS[tool_call.name](**tool_call.args)
            results.append(ToolMessage(
                content=str(result),
                tool_call_id=tool_call.id
            ))

        elif tool_call.name in SUB_AGENTS:
            # Invoke sub-agent (RECURSIVE - another full LangGraph!)
            sub_agent_class = SUB_AGENTS[tool_call.name]
            sub_agent = sub_agent_class()

            # Sub-agent has its own agent node + tools node
            sub_result = await sub_agent.invoke(tool_call.args)

            results.append(ToolMessage(
                content=str(sub_result),
                tool_call_id=tool_call.id,
                metadata={"sub_agent": tool_call.name}
            ))

    # Update state with results
    new_state = {
        **state,
        "messages": state["messages"] + results,
        "completed_steps": state["completed_steps"] + [tool_call.name for tool_call in tool_calls]
    }

    return new_state
```

### Sub-Agent Registry

```python
# Simple tools (functions)
SIMPLE_TOOLS = {
    "check_database": lambda query: database.query(query),
    "calculate_metrics": lambda data: analyze(data),
    "schedule_task": lambda task, time: calendar.create(task, time),
}

# Sub-agents (full LangGraph agents)
SUB_AGENTS = {
    "research_agent": ResearchAgent,  # Class reference
    "strategy_generator": StrategyGeneratorAgent,
    "implementation_planner": ImplementationPlannerAgent,
    "playbook_generator": PlaybookGeneratorAgent,
    "data_analysis_agent": DataAnalysisAgent,
}

def get_tool_schemas():
    """
    Returns tool schemas for LLM, including both simple tools and sub-agents.
    """
    schemas = []

    # Simple tool schemas
    for name, func in SIMPLE_TOOLS.items():
        schemas.append({
            "name": name,
            "description": func.__doc__,
            "parameters": get_function_parameters(func)
        })

    # Sub-agent schemas (exposed as tools!)
    for name, agent_class in SUB_AGENTS.items():
        schemas.append({
            "name": name,
            "description": agent_class.description,
            "parameters": agent_class.input_schema
        })

    return schemas
```

---

## Service 13 Integration

### Current Service 13 Architecture

**Service 13 (Customer Success)** already implements domain-specific Master Agent behavior:

```
Service 13 Components:
├─ Health Score Calculator Agent (fully autonomous)
├─ Churn Prediction Agent (fully autonomous)
├─ Expansion Opportunity Scorer (fully autonomous)
├─ QBR Generator Agent (supervised)
├─ Playbook Orchestration Agent (semi-autonomous)
├─ Village Knowledge (multi-client learning)
├─ Strategic Advisory Module (recommendation engine)
└─ Outcome Tracking (performance measurement)
```

**Service 13 = Master Agent for Customer Success Domain**

### Enhancement: Add General Problem-Solving Capability

**Before (Current)**:
```
Service 13 handles pre-defined CS workflows:
- Churn risk intervention (playbook triggered by health score < 50)
- Expansion outreach (playbook triggered by expansion score > 80)
- QBR generation (playbook triggered by QBR due date)
```

**After (Master Agent Integration)**:
```
Service 13 handles ANY business goal:
- "Increase Samsung Store attach rate by 20%" → Research + Strategy + Implementation
- "Reduce churn by 30% in APAC region" → Root cause analysis + Intervention design
- "Identify top 10 expansion opportunities" → Data analysis + Prioritization + Outreach plan
```

### Integration Architecture

```python
class CustomerSuccessService:
    """
    Service 13 enhanced with Master Agent orchestration.
    """

    def __init__(self):
        # EXISTING: Domain-specific agents (pre-Master Agent)
        self.health_scorer = HealthScorerAgent()
        self.churn_predictor = ChurnPredictorAgent()
        self.expansion_scorer = ExpansionOpportunityScorerAgent()
        self.qbr_generator = QBRGeneratorAgent()
        self.playbook_orchestrator = PlaybookOrchestrationAgent()

        # EXISTING: Knowledge and tracking
        self.village_knowledge = VillageKnowledgeRetriever()
        self.outcome_tracker = OutcomeTrackingSystem()

        # NEW: Master Agent orchestrator
        self.master_agent = MasterAgentOrchestrator(
            domain_config=CustomerSuccessDomainConfig()
        )

        # NEW: Sub-agent registry for dynamic capability creation
        self.master_agent.register_sub_agents({
            "research_agent": ResearchAgent,
            "strategy_generator": StrategyGeneratorAgent,
            "implementation_planner": ImplementationPlannerAgent,
            "playbook_generator": PlaybookGeneratorAgent,
            "data_analysis_agent": DataAnalysisAgent,
        })

        # NEW: Connect existing agents as tools for Master Agent
        self.master_agent.register_simple_tools({
            "check_health_score": self.health_scorer.calculate,
            "predict_churn": self.churn_predictor.predict,
            "score_expansion": self.expansion_scorer.score,
            "generate_qbr": self.qbr_generator.generate,
            "execute_playbook": self.playbook_orchestrator.execute,
            "query_village_knowledge": self.village_knowledge.retrieve,
        })

    async def handle_strategic_goal(self, goal: str, client_id: str):
        """
        NEW: Master Agent handles ambiguous strategic goals.

        This is the entry point for ANY business goal, not just pre-defined workflows.
        """
        # Master Agent orchestrates solution
        solution = await self.master_agent.solve(
            goal=goal,
            context={
                "client_id": client_id,
                "client_data": await self.get_client_context(client_id),
                "available_playbooks": await self.playbook_orchestrator.list_playbooks(),
                "historical_outcomes": await self.outcome_tracker.get_learnings(client_id)
            }
        )

        # If solution requires new capability (playbook), create it
        if solution.requires_new_playbook:
            new_playbook = await self.create_playbook(solution.strategy)
            await self.playbook_orchestrator.deploy(new_playbook)

        # Track outcome for self-evolution
        await self.outcome_tracker.monitor(
            solution_id=solution.id,
            expected_outcome=solution.expected_outcome,
            measure_after_days=solution.timeline_days
        )

        return solution

    async def create_playbook(self, strategy: dict):
        """
        NEW: Dynamically create new playbook from Master Agent's strategy.

        This is "self-evolution" - creating new capabilities on-demand.
        """
        playbook_generator = PlaybookGeneratorAgent()

        new_playbook = await playbook_generator.invoke({
            "name": strategy["playbook_name"],
            "trigger": strategy["trigger_conditions"],
            "steps": strategy["implementation_steps"],
            "expected_outcome": strategy["expected_outcome"],
            "success_metrics": strategy["kpis"]
        })

        # Store in database
        await self.playbook_orchestrator.store(new_playbook)

        return new_playbook
```

### Data Flow: Strategic Goal → Solution

```
CLIENT INPUT:
  "Increase Samsung Store 5 attach rate by 20%"

↓ Service 13 API
  POST /api/cs/strategic-goals
  {
    "goal": "Increase Samsung Store 5 attach rate by 20%",
    "client_id": "samsung_retail",
    "timeline": "60 days"
  }

↓ Master Agent (Agent Node - Reasoning)
  LLM thinks:
  "To achieve this goal, I need to:
   1. Understand current attach rate
   2. Identify root causes of low performance
   3. Design intervention strategy
   4. Create implementation plan
   5. Deploy and measure"

↓ Master Agent (Tools Node - Actions)
  Tool 1: check_health_score(store_id=5)
    → Result: {"attach_rate": "3%", "staff_variance": "2-8%"}

  Tool 2: research_agent.invoke({
      "task": "Why is Store 5 attach rate only 3%?",
      "data_sources": ["billing", "staff_performance", "inventory"]
    })
    → Sub-agent executes (recursive LangGraph)
    → Result: {"root_cause": "Veteran staff burnout", "confidence": 0.89}

  Tool 3: strategy_generator.invoke({
      "problem": "Veteran staff burnout",
      "goal": "Increase attach rate to 7%",
      "constraints": {"budget": "$10K", "timeline": "60 days"}
    })
    → Sub-agent executes (recursive LangGraph)
    → Result: {"strategy": "Hybrid coaching + automation", "expected_lift": "4%"}

↓ Master Agent (Agent Node - Synthesis)
  LLM synthesizes:
  "Solution: Implement staff coaching program + automated chatbot upsell prompts.
   Expected outcome: 3% → 7% attach rate (exceeds 20% goal).
   Requires new playbook: 'Staff Performance Monitor'"

↓ Service 13 (Playbook Creation)
  create_playbook({
    "name": "Staff Performance Monitor",
    "trigger": "Weekly batch job",
    "steps": [
      "Query attach rate per staff",
      "Identify underperformers (<5%)",
      "Send coaching email via Service 20",
      "Track improvement for 30 days"
    ]
  })

↓ Service 13 (Deployment)
  playbook_orchestrator.deploy(new_playbook, store_id=5)

↓ Service 13 (Outcome Tracking)
  outcome_tracker.monitor(
    solution_id="samsung_store_5_attach",
    expected="attach_rate_7%",
    actual="measure_after_60_days"
  )

↓ CLIENT OUTPUT:
  {
    "solution_id": "samsung_store_5_attach_20251011",
    "strategy": "Hybrid staff coaching + automated upsell prompts",
    "root_cause": "Veteran staff burnout (confidence: 89%)",
    "expected_outcome": "Attach rate increase from 3% to 7% in 60 days",
    "playbook_deployed": "Staff Performance Monitor (ID: 4521)",
    "tracking_enabled": true
  }
```

---

## Samsung Store Example Walkthrough

### Business Context

**Samsung India Franchise Store** wants to increase re-orders, upsells, and cross-sells by 20%.

**Current State**:
- Store 5 attach rate: **3%** (industry benchmark: 7%)
- Staff variance: 2-8% attach rate across 10 employees
- Newer staff (0-6 months) outperform veterans (2+ years)

**Goal**: Increase attach rate to **7%** within 60 days

### Master Agent Execution Flow

#### Step 1: Goal Intake

```
USER (Samsung Store Manager):
  "I need to increase attach rate by 20% in 60 days"

MASTER AGENT (Agent Node - Initial Reasoning):
  thought = """
  This goal requires:
  1. Data analysis: What's current attach rate? Why is it low?
  2. Root cause identification: Staff performance? Product mix? Training?
  3. Intervention design: What levers can we pull?
  4. Implementation: Deploy solution and measure

  I don't have all these capabilities directly. I'll need to:
  - Check current metrics (simple tool)
  - Research root cause (SUB-AGENT: ResearchAgent)
  - Design strategy (SUB-AGENT: StrategyGeneratorAgent)
  - Create playbook (SUB-AGENT: PlaybookGeneratorAgent)
  """
```

#### Step 2: Data Gathering (Simple Tool)

```
MASTER AGENT (Tools Node):
  action = "check_database"
  params = {
    "query": "SELECT store_id, AVG(attach_rate), staff_variance FROM sales WHERE store_id = 5"
  }

RESULT:
  {
    "store_id": 5,
    "current_attach_rate": "3%",
    "staff_variance": "2-8%",
    "monthly_transactions": 450,
    "staff_count": 10
  }

MASTER AGENT (Agent Node - Update Plan):
  thought = """
  Current attach rate is 3%, which is 57% below target (7%).
  High staff variance (2-8%) suggests individual performance issue, not product/inventory problem.
  Next: Need deep dive into staff performance patterns.
  Action: Invoke ResearchAgent to analyze root cause.
  """
```

#### Step 3: Root Cause Analysis (Sub-Agent: ResearchAgent)

```
MASTER AGENT (Tools Node):
  action = "research_agent"
  params = {
    "task": "Why is Store 5 attach rate only 3% when staff variance is 2-8%?",
    "data_sources": ["billing_db", "staff_performance_db", "inventory_db"],
    "analysis_depth": "deep"
  }

↓ ResearchAgent SPINS UP (Level 2 LangGraph)

RESEARCH AGENT (Agent Node - Sub-Reasoning):
  thought = """
  Need to:
  1. Query staff-level performance data
  2. Correlate with tenure, training, shift times
  3. Identify patterns

  I'll need:
  - SQL query tool (simple tool)
  - Data analysis sub-agent (SUB-SUB-AGENT: DataAnalysisAgent)
  """

RESEARCH AGENT (Tools Node):
  Tool 1: query_database
    SQL = "SELECT staff_id, tenure_months, AVG(attach_rate), training_completed FROM staff_performance WHERE store_id = 5 GROUP BY staff_id"

    Result:
    [
      {"staff_id": 1, "tenure": 36, "attach_rate": "2%", "training": "yes"},
      {"staff_id": 2, "tenure": 30, "attach_rate": "3%", "training": "yes"},
      {"staff_id": 3, "tenure": 4, "attach_rate": "8%", "training": "yes"},
      {"staff_id": 4, "tenure": 2, "attach_rate": "7%", "training": "yes"},
      ...
    ]

  Tool 2: data_analysis_agent.invoke({
    "dataset": staff_performance_data,
    "question": "What patterns explain the variance in attach rates?"
  })

  ↓ DataAnalysisAgent SPINS UP (Level 3 LangGraph - RECURSIVE!)

  DATA ANALYSIS AGENT (Agent Node - Statistical Reasoning):
    thought = """
    I'll run:
    1. Correlation analysis (tenure vs attach_rate)
    2. Segmentation analysis (new vs veteran staff)
    3. Hypothesis testing (is difference statistically significant?)
    """

  DATA ANALYSIS AGENT (Tools Node):
    Tool: statistical_test(method="pearson_correlation")
      → Result: r = -0.72 (strong negative correlation between tenure and attach_rate)

    Tool: segment_analysis(groups=["new_staff", "veteran_staff"])
      → Result: New staff (0-6 months): 8% avg attach rate
                Veteran staff (24+ months): 3% avg attach rate
                Difference: Statistically significant (p < 0.01)

  DATA ANALYSIS AGENT (Result):
    {
      "finding": "Veteran staff significantly underperform newer staff",
      "correlation": "Tenure negatively correlated with attach rate (r=-0.72)",
      "hypothesis": "Veteran staff experience burnout or complacency",
      "confidence": 0.91
    }

RESEARCH AGENT (Agent Node - Synthesis):
  thought = """
  Data analysis reveals veteran staff burnout hypothesis.
  Next: Validate with qualitative data (staff surveys, manager feedback).
  """

RESEARCH AGENT (Tools Node):
  Tool: query_village_knowledge({
    "query": "veteran sales staff underperformance burnout",
    "industry": "retail",
    "top_k": 3
  })

  Result:
  [
    {
      "pattern": "Retail staff burnout after 18-24 months",
      "cause": "Repetitive tasks lead to disengagement",
      "solution": "Gamification + peer coaching",
      "source": "client_xyz_electronics_retail",
      "outcome": "45% performance improvement"
    }
  ]

RESEARCH AGENT (Final Result):
  {
    "root_cause": "Veteran staff burnout after 2+ years",
    "evidence": [
      "Negative correlation between tenure and performance (r=-0.72)",
      "New staff: 8% attach rate vs Veterans: 3% attach rate",
      "Similar pattern in village knowledge (electronics retail)"
    ],
    "confidence": 0.89,
    "recommended_intervention": "Hybrid approach: Peer coaching + automation"
  }

↓ Back to MASTER AGENT (Tools Node - ResearchAgent result received)
```

#### Step 4: Strategy Design (Sub-Agent: StrategyGeneratorAgent)

```
MASTER AGENT (Agent Node - Update Plan):
  thought = """
  Root cause identified: Veteran staff burnout.
  Now need to design intervention strategy within constraints:
  - Budget: $10K
  - Timeline: 60 days
  - Goal: Increase attach rate from 3% to 7%

  Action: Invoke StrategyGeneratorAgent.
  """

MASTER AGENT (Tools Node):
  action = "strategy_generator"
  params = {
    "problem": "Veteran staff burnout leading to low attach rate",
    "goal": "Increase attach rate from 3% to 7%",
    "constraints": {
      "budget": "$10K",
      "timeline": "60 days",
      "staff_count": 10
    },
    "root_cause_analysis": research_agent_result
  }

↓ StrategyGeneratorAgent SPINS UP (Level 2 LangGraph)

STRATEGY AGENT (Agent Node - Strategic Reasoning):
  thought = """
  Given burnout hypothesis, possible interventions:
  1. Staff coaching by high performers (low cost, high touch)
  2. Gamification with leaderboard (medium cost, engagement boost)
  3. Automated chatbot upsell prompts (high cost, scalable)
  4. Hybrid: Coaching + automation (balanced approach)

  I should A/B test these approaches. I'll invoke ABTestDesignerAgent.
  """

STRATEGY AGENT (Tools Node):
  Tool: ab_test_designer_agent.invoke({
    "variants": [
      {
        "name": "Coaching Only",
        "description": "High-performing staff coach underperformers",
        "cost": "$2K",
        "expected_lift": "2-3%",
        "confidence": 0.65
      },
      {
        "name": "Automation Only",
        "description": "Chatbot prompts staff with upsell suggestions",
        "cost": "$8K",
        "expected_lift": "3-4%",
        "confidence": 0.75
      },
      {
        "name": "Hybrid",
        "description": "Coaching + chatbot automation",
        "cost": "$9K",
        "expected_lift": "4-5%",
        "confidence": 0.82
      }
    ],
    "sample_size": 10,  # All staff in Store 5
    "duration_days": 30,
    "success_metric": "attach_rate_increase"
  })

  ↓ ABTestDesignerAgent SPINS UP (Level 3 LangGraph - RECURSIVE!)

  AB TEST DESIGNER (Agent Node):
    thought = """
    With only 10 staff, I can't run parallel A/B test.
    Recommendation: Sequential rollout with measurement:
    - Week 1-2: Coaching only (baseline improvement)
    - Week 3-4: Add automation (incremental lift)
    - Week 5-8: Full hybrid (final measurement)
    """

  AB TEST DESIGNER (Result):
    {
      "recommended_approach": "Sequential rollout (not parallel A/B)",
      "rationale": "Small sample size (10 staff) prevents statistical significance in parallel test",
      "rollout_plan": [
        {"weeks": "1-2", "intervention": "Coaching", "expected": "3% → 5%"},
        {"weeks": "3-4", "intervention": "Add automation", "expected": "5% → 7%"},
        {"weeks": "5-8", "intervention": "Sustain + optimize", "expected": "Maintain 7%+"}
      ],
      "total_cost": "$9K",
      "expected_roi": "4% attach rate lift = $45K additional annual revenue"
    }

STRATEGY AGENT (Agent Node - Finalize Strategy):
  thought = """
  AB test design recommends sequential rollout.
  Village knowledge shows similar hybrid approach succeeded elsewhere.
  Confidence score: 0.82
  Decision: Proceed with hybrid strategy.
  """

STRATEGY AGENT (Final Result):
  {
    "strategy_name": "Hybrid Coaching + Automation",
    "intervention_details": {
      "coaching_component": {
        "design": "Top 2 performers coach bottom 4 performers",
        "frequency": "2x per week, 30-minute sessions",
        "focus_areas": ["Upsell timing", "Accessory bundling", "Objection handling"],
        "cost": "$2K (incentive for coaches)"
      },
      "automation_component": {
        "design": "Chatbot provides real-time upsell suggestions to staff POS",
        "triggers": ["High-margin accessories", "Bundle opportunities", "Complementary products"],
        "integration": "Samsung POS system API",
        "cost": "$7K (development + deployment)"
      }
    },
    "rollout_timeline": {
      "week_1-2": "Launch coaching program",
      "week_3-4": "Deploy chatbot automation",
      "week_5-8": "Monitor and optimize"
    },
    "expected_outcome": "Attach rate increase from 3% to 7.5% (target: 7%)",
    "confidence": 0.82,
    "roi": "$45K additional annual revenue",
    "requires_new_playbook": true,
    "playbook_requirements": {
      "name": "Staff Performance Monitor + Coaching Tracker",
      "triggers": ["Weekly performance review", "Attach rate below target"],
      "automated_actions": ["Send coaching reminders", "Update leaderboard", "Alert underperformers"]
    }
  }

↓ Back to MASTER AGENT (Tools Node - StrategyAgent result received)
```

#### Step 5: Implementation Planning (Sub-Agent: ImplementationPlannerAgent)

```
MASTER AGENT (Agent Node - Next Steps):
  thought = """
  Strategy defined: Hybrid coaching + automation.
  Now need detailed implementation plan.
  Action: Invoke ImplementationPlannerAgent.
  """

MASTER AGENT (Tools Node):
  action = "implementation_planner"
  params = {
    "strategy": strategy_agent_result,
    "timeline_days": 60,
    "stakeholders": ["Store Manager", "Staff", "IT Team"]
  }

↓ ImplementationPlannerAgent SPINS UP (Level 2 LangGraph)

IMPLEMENTATION PLANNER (Agent Node):
  thought = """
  Need to create:
  1. Detailed week-by-week plan
  2. Resource allocation
  3. Risk mitigation
  4. Success metrics tracking

  I'll invoke sub-agents:
  - ResourceEstimatorAgent (staffing, budget allocation)
  - RiskAssessorAgent (what could go wrong?)
  - PlaybookGeneratorAgent (create new automation playbook)
  """

IMPLEMENTATION PLANNER (Tools Node):
  Tool 1: resource_estimator.invoke(...)
    → Result: 2 coaches, 1 IT developer, $9K budget

  Tool 2: risk_assessor.invoke(...)
    → Result: Risks = [Staff resistance, POS integration delays, Budget overrun]
              Mitigations = [Change management, Backup manual process, Phased rollout]

  Tool 3: playbook_generator.invoke({
    "name": "Staff Performance Monitor",
    "trigger_conditions": "Weekly batch job + Real-time attach rate drop",
    "steps": [
      {
        "step": 1,
        "action": "Query attach rate per staff from billing DB",
        "automation_level": "fully_automated"
      },
      {
        "step": 2,
        "action": "Identify staff with attach rate < 5%",
        "automation_level": "fully_automated"
      },
      {
        "step": 3,
        "action": "Send coaching reminder email to coaches",
        "automation_level": "fully_automated",
        "integration": "Service 20 (Communication Engine)"
      },
      {
        "step": 4,
        "action": "Update leaderboard dashboard",
        "automation_level": "fully_automated"
      },
      {
        "step": 5,
        "action": "Alert Store Manager if 3+ staff underperforming",
        "automation_level": "fully_automated",
        "escalation": "Slack notification"
      }
    ],
    "success_metrics": {
      "primary": "Attach rate increase from 3% to 7%",
      "secondary": ["Staff engagement score", "Coaching session attendance", "Chatbot usage rate"]
    }
  })

  ↓ PlaybookGeneratorAgent SPINS UP (Level 3 LangGraph - RECURSIVE!)

  PLAYBOOK GENERATOR (Agent Node):
    thought = """
    Generate executable playbook in Service 13 format.
    Include: triggers, conditional logic, integrations, error handling.
    """

  PLAYBOOK GENERATOR (Result):
    {
      "playbook_id": "staff_perf_monitor_v1",
      "playbook_json": {
        "name": "Staff Performance Monitor",
        "version": "1.0",
        "trigger": {
          "type": "scheduled",
          "cron": "0 9 * * MON",  # Every Monday 9am
          "backup_trigger": {
            "type": "event_based",
            "condition": "attach_rate < 5% for any staff"
          }
        },
        "steps": [...],
        "integrations": ["Service 20 (Email)", "Slack API", "Billing DB"],
        "rollback_plan": "Disable automation, revert to manual monitoring",
        "owner": "Service 13 (Customer Success)"
      }
    }

IMPLEMENTATION PLANNER (Final Result):
  {
    "implementation_plan": {
      "week_1": {
        "milestone": "Launch coaching program",
        "tasks": [
          "Train top 2 performers as coaches",
          "Create coaching playbook",
          "Set up weekly coaching schedule"
        ],
        "deliverables": ["Coaching playbook", "Schedule"],
        "budget": "$500"
      },
      "week_2": {
        "milestone": "Monitor coaching effectiveness",
        "tasks": ["Track coaching session attendance", "Measure early attach rate lift"],
        "deliverables": ["Week 2 performance report"],
        "budget": "$0"
      },
      "week_3-4": {
        "milestone": "Deploy chatbot automation",
        "tasks": [
          "Integrate chatbot with Samsung POS API",
          "Train chatbot on upsell suggestions",
          "UAT with 2 staff members"
        ],
        "deliverables": ["Chatbot deployed to Store 5"],
        "budget": "$7K"
      },
      "week_5-8": {
        "milestone": "Monitor and optimize",
        "tasks": [
          "Deploy 'Staff Performance Monitor' playbook",
          "Track attach rate weekly",
          "Adjust coaching focus based on data"
        ],
        "deliverables": ["Final outcome report", "Playbook operational"],
        "budget": "$1.5K (monitoring tools)"
      }
    },
    "new_playbook_created": playbook_generator_result,
    "risks_and_mitigations": risk_assessor_result,
    "total_budget": "$9K",
    "expected_timeline": "60 days",
    "success_criteria": "Attach rate >= 7% sustained for 2 weeks"
  }

↓ Back to MASTER AGENT (Tools Node - ImplementationPlanner result received)
```

#### Step 6: Master Agent Synthesis & Deployment

```
MASTER AGENT (Agent Node - Final Synthesis):
  thought = """
  All sub-agents have completed their work:
  - ResearchAgent: Root cause = Veteran staff burnout
  - StrategyAgent: Solution = Hybrid coaching + automation
  - ImplementationPlanner: Detailed 8-week plan + new playbook

  Confidence: 0.82 (high)
  Expected outcome: 3% → 7.5% attach rate (exceeds 20% goal)

  Next actions:
  1. Deploy new playbook to Service 13
  2. Notify Samsung Store Manager
  3. Track outcome for 60 days
  4. Store learnings in village knowledge (self-evolution)
  """

MASTER AGENT (Tools Node - Final Actions):
  Tool 1: deploy_playbook(playbook_generator_result)
    → Result: Playbook ID #4521 deployed to Service 13, active on 2025-10-18

  Tool 2: schedule_outcome_tracking({
    "solution_id": "samsung_store_5_attach_20251011",
    "expected_outcome": "attach_rate >= 7%",
    "measure_after_days": 60,
    "intermediate_checkpoints": [14, 30, 45]  # Days 14, 30, 45
  })
    → Result: Tracking job created, will measure on 2025-12-10

  Tool 3: notify_stakeholders({
    "recipients": ["store_manager@samsung.com"],
    "subject": "Attach Rate Improvement Strategy Ready",
    "body": "Master Agent has designed a comprehensive solution...",
    "attachments": ["implementation_plan.pdf", "coaching_playbook.pdf"]
  })
    → Result: Email sent

MASTER AGENT (Final Output to Client):
  {
    "solution_id": "samsung_store_5_attach_20251011",
    "status": "deployed",
    "summary": {
      "goal": "Increase attach rate by 20%",
      "root_cause": "Veteran staff burnout (confidence: 89%)",
      "strategy": "Hybrid coaching + chatbot automation",
      "expected_outcome": "Attach rate 3% → 7.5% in 60 days (exceeds goal)",
      "budget": "$9K",
      "timeline": "60 days (8 weeks)",
      "confidence": 0.82
    },
    "implementation_details": {
      "coaching_program": {
        "coaches": 2,
        "participants": 4,
        "frequency": "2x per week",
        "cost": "$2K"
      },
      "automation": {
        "chatbot_deployment": "Week 3-4",
        "pos_integration": "Samsung POS API",
        "cost": "$7K"
      },
      "new_playbook": {
        "name": "Staff Performance Monitor",
        "id": "4521",
        "status": "deployed",
        "triggers": "Weekly batch + Real-time alerts"
      }
    },
    "tracking": {
      "checkpoints": ["Day 14", "Day 30", "Day 45", "Day 60"],
      "metrics": ["Attach rate", "Coaching attendance", "Chatbot usage", "Staff engagement"],
      "final_measurement": "2025-12-10"
    },
    "documentation": {
      "implementation_plan": "https://s3.../samsung_store_5_plan.pdf",
      "coaching_playbook": "https://s3.../coaching_playbook.pdf",
      "playbook_json": "https://s3.../playbook_4521.json"
    }
  }
```

#### Step 7: Self-Evolution (60 Days Later)

```
DATE: 2025-12-10
OUTCOME TRACKER: Measuring results

ACTUAL RESULTS:
  Store 5 attach rate: 7.2% (target: 7%, actual: 7.2% ✅)
  Staff engagement: +35%
  Coaching attendance: 95%
  Chatbot usage: 87% of transactions
  Budget: $8.5K (under budget ✅)

MASTER AGENT (Self-Evolution Loop):

  # 1. Store outcome in learnings database
  learnings_db.insert({
    "problem_type": "low_retail_attach_rate",
    "root_cause": "staff_burnout",
    "solution_pattern": "hybrid_coaching_and_automation",
    "industry": "retail",
    "vertical": "electronics",
    "expected_outcome": "7% attach rate",
    "actual_outcome": "7.2% attach rate",
    "confidence_score": 0.82,
    "actual_confidence": 0.95,  # Exceeded expectations
    "budget_planned": "$9K",
    "budget_actual": "$8.5K",
    "timeline_planned": "60 days",
    "timeline_actual": "58 days",
    "success": true,
    "evidence": {
      "staff_engagement_lift": "+35%",
      "coaching_attendance": "95%",
      "automation_adoption": "87%"
    },
    "date": "2025-12-10",
    "solution_id": "samsung_store_5_attach_20251011"
  })

  # 2. Update village knowledge (for ALL future clients)
  village_knowledge.insert({
    "pattern_name": "Staff Burnout → Performance Decline",
    "domain": "Retail",
    "description": "Veteran sales staff (24+ months tenure) show performance decline due to burnout from repetitive tasks",
    "intervention": "Hybrid approach: Peer coaching by high performers + AI-powered automation for routine suggestions",
    "evidence": [
      "Samsung Store 5: 3% → 7.2% attach rate in 58 days",
      "Client XYZ Electronics: 45% performance improvement with similar approach"
    ],
    "applicability": {
      "industries": ["Retail", "Consumer Electronics", "B2C Sales"],
      "problem_signals": ["High staff tenure + Low performance", "Staff variance > 3x"],
      "constraints": "Budget $5K-$15K, Timeline 30-90 days"
    },
    "confidence": 0.95,
    "reuse_count": 1,  # Will increment as pattern is reused
    "source": "master_agent_experiment_2025_10"
  })

  # 3. Optimize playbook (A/B test results)
  playbook_optimizer.analyze({
    "playbook_id": "4521",
    "execution_results": {
      "trigger_accuracy": 0.92,  # How often trigger was appropriate
      "step_success_rate": 0.97,  # How often steps executed correctly
      "outcome_accuracy": 1.03,  # Actual vs expected (7.2% / 7% = 1.03)
      "user_satisfaction": 4.8  # Store Manager rating (5.0 scale)
    }
  })

  Result: "Playbook 4521 performing above expectations. Promote to 'Recommended' status for similar use cases."

  # 4. Adjust confidence model
  confidence_model.update({
    "predicted_confidence": 0.82,
    "actual_confidence": 0.95,
    "delta": +0.13,
    "lesson": "Hybrid coaching + automation patterns have higher success rate than initially estimated. Increase prior confidence for similar interventions by +0.10."
  })

  # 5. Notify stakeholders of success
  notify_success({
    "recipient": "store_manager@samsung.com",
    "subject": "🎉 Attach Rate Goal Achieved!",
    "body": """
      Congratulations! Store 5 attach rate increased from 3% to 7.2% in 58 days.

      Results:
      - Goal: 7% (20% increase) ✅
      - Actual: 7.2% (exceeds goal by 3%)
      - Staff engagement: +35%
      - Under budget: $8.5K (planned $9K)

      This solution has been added to our knowledge base and can be replicated for other stores.

      Next steps: Would you like to roll out to Store 6-10?
    """
  })

NEXT TIME (Another client with similar problem):

CLIENT: "Help me increase attach rate at my electronics store"

MASTER AGENT (Agent Node):
  thought = """
  Checking village knowledge for similar patterns...

  Found: 'Staff Burnout → Performance Decline' pattern
  - Industry match: Retail ✅
  - Problem signals match: High staff tenure ✅
  - Intervention: Hybrid coaching + automation
  - Confidence: 0.95 (very high!)
  - Evidence: Samsung Store 5 success + Client XYZ Electronics

  Decision: Recommend proven solution immediately (no need to spin up ResearchAgent!)
  """

MASTER AGENT (Tools Node):
  Tool: strategy_generator.invoke({
    "problem": "Low attach rate",
    "recommended_pattern": village_knowledge_result,
    "customize_for": new_client_context
  })

RESULT: Solution delivered in 5 minutes instead of 2 hours (self-evolution efficiency!)
```

---

## Implementation Roadmap

### Sprint 22-27: Build Master Agent Framework (12 Weeks)

#### Sprint 22-23: Abstract PRD Builder Pattern (4 Weeks)

**Goal**: Extract generalizable intelligence pattern from Service 6

**Deliverables**:

1. **`RequirementsIntelligenceEngine` Base Class**
   ```python
   class RequirementsIntelligenceEngine:
       """
       Abstract base class for domain-agnostic problem solving.
       Implements the Master Agent pattern.
       """
       def __init__(self, domain_config: DomainConfig):
           self.domain = domain_config.domain_name
           self.vocabulary = domain_config.vocabulary
           self.knowledge_corpus = domain_config.knowledge_source
           self.output_schema = domain_config.output_format

       async def solve_problem(self, ambiguous_input: str) -> Solution:
           # LangGraph workflow implementation
           pass
   ```

2. **Domain Configuration System**
   ```python
   @dataclass
   class DomainConfig:
       domain_name: str
       vocabulary: dict
       knowledge_source: KnowledgeCorpus
       output_format: OutputSchema
   ```

3. **Proof-of-Concept: Two Domains**
   - Domain 1: Chatbot PRD (migrate existing Service 6)
   - Domain 2: Medical Diagnosis (simplified version for proof-of-concept)

   **Success Criteria**: Both domains use same `RequirementsIntelligenceEngine` base class

**Tasks**:
- Extract cross-questioning logic from Service 6
- Generalize village knowledge retrieval patterns
- Create domain configuration abstraction
- Build proof-of-concept for medical diagnosis domain
- Write comprehensive unit tests
- Document abstraction patterns

**Team**: 2 developers

**Story Points**: 84 points (42 per sprint)

**Risks**:
- Over-generalization makes system too complex
- Chatbot-specific logic hard to extract
- **Mitigation**: Start with minimal abstraction, iterate

---

#### Sprint 24-25: Build Sub-Agent Library (4 Weeks)

**Goal**: Create reusable specialist sub-agents with recursive capabilities

**Deliverables**:

1. **ResearchAgent** (Data Analysis Specialist)
   ```python
   class ResearchAgent(RequirementsIntelligenceEngine):
       """
       Specialized sub-agent for deep research and root cause analysis.

       Capabilities:
       - Query databases (SQL, NoSQL)
       - Web research and scraping
       - Data analysis (statistical, ML)
       - Pattern identification
       """
       def __init__(self):
           super().__init__(research_domain_config)

           # ResearchAgent has its own sub-agents (recursive!)
           self.sub_agents = {
               "data_query_agent": DataQueryAgent(),
               "data_analysis_agent": DataAnalysisAgent(),
               "web_research_agent": WebResearchAgent()
           }
   ```

2. **StrategyGeneratorAgent** (Intervention Design Specialist)
   ```python
   class StrategyGeneratorAgent(RequirementsIntelligenceEngine):
       """
       Specialized sub-agent for designing intervention strategies.

       Capabilities:
       - Intervention design (A/B test, sequential rollout)
       - ROI calculation
       - Risk assessment
       - Optimization (constraint satisfaction)
       """
       def __init__(self):
           super().__init__(strategy_domain_config)

           self.sub_agents = {
               "ab_test_designer": ABTestDesignerAgent(),
               "simulation_agent": SimulationAgent(),
               "roi_calculator": ROICalculatorAgent()
           }
   ```

3. **ImplementationPlannerAgent** (Execution Specialist)
   ```python
   class ImplementationPlannerAgent(RequirementsIntelligenceEngine):
       """
       Specialized sub-agent for creating detailed implementation plans.

       Capabilities:
       - Milestone planning
       - Resource estimation
       - Risk mitigation
       - Playbook generation
       """
       def __init__(self):
           super().__init__(implementation_domain_config)

           self.sub_agents = {
               "playbook_generator": PlaybookGeneratorAgent(),
               "resource_estimator": ResourceEstimatorAgent(),
               "risk_assessor": RiskAssessorAgent()
           }
   ```

**Tasks**:
- Implement 3 core sub-agents (Research, Strategy, Implementation)
- Build 6 sub-sub-agents (DataQuery, DataAnalysis, ABTest, Simulation, PlaybookGenerator, RiskAssessor)
- Test recursive composition (agent → sub-agent → sub-sub-agent)
- Document sub-agent interfaces
- Write integration tests

**Team**: 2 developers (each owns 1-2 agents)

**Story Points**: 88 points (44 per sprint)

**Risks**:
- Infinite recursion loops
- Sub-agent state management complexity
- **Mitigation**: Max recursion depth = 5, comprehensive state testing

---

#### Sprint 26-27: Integrate with Service 13 (4 Weeks)

**Goal**: Service 13 becomes Master Agent orchestrator

**Deliverables**:

1. **Master Agent Orchestrator in Service 13**
   ```python
   class CustomerSuccessService:
       def __init__(self):
           # Existing Service 13 components
           self.health_scorer = HealthScorerAgent()
           self.churn_predictor = ChurnPredictorAgent()
           self.playbook_orchestrator = PlaybookOrchestrationAgent()

           # NEW: Master Agent
           self.master_agent = MasterAgentOrchestrator(
               domain_config=CustomerSuccessDomainConfig()
           )

           # Register sub-agents
           self.master_agent.register_sub_agents({
               "research": ResearchAgent,
               "strategy": StrategyGeneratorAgent,
               "implementation": ImplementationPlannerAgent
           })

       async def handle_strategic_goal(self, goal: str, client_id: str):
           """NEW: Master Agent handles ANY business goal"""
           return await self.master_agent.solve(goal, context=...)
   ```

2. **API Endpoints**
   ```
   POST /api/cs/strategic-goals
   {
     "goal": "Increase Samsung Store attach rate by 20%",
     "client_id": "samsung_retail",
     "timeline_days": 60
   }

   Response:
   {
     "solution_id": "...",
     "strategy": "...",
     "expected_outcome": "...",
     "playbook_deployed": "...",
     "tracking_enabled": true
   }
   ```

3. **Outcome Tracking System**
   ```python
   class OutcomeTracker:
       async def monitor(self, solution_id, expected, measure_after_days):
           """
           Track solution outcome for self-evolution.
           """
           # Store expected outcome
           # Schedule measurement job
           # Compare actual vs expected
           # Update village knowledge
           # Adjust confidence models
   ```

4. **Self-Evolution Loop**
   - Outcome measurement
   - Learnings database storage
   - Village knowledge updates
   - Confidence model adjustments

**Tasks**:
- Add Master Agent to Service 13
- Build API endpoints
- Implement outcome tracking
- Connect to existing playbook orchestrator
- Build self-evolution loop
- E2E testing (Samsung Store scenario)
- Documentation and runbooks

**Team**: 2 developers

**Story Points**: 84 points (42 per sprint)

**Risks**:
- Integration complexity with existing Service 13
- State management across Master Agent + existing agents
- **Mitigation**: Feature flag for gradual rollout, extensive integration testing

---

### Post-Sprint 27: Production Rollout

**Sprint 28-29: Beta Testing** (4 Weeks)
- Deploy to 5 pilot clients
- Gather feedback on Master Agent solutions
- Measure: solution quality, client satisfaction, outcome accuracy
- Iterate on sub-agent logic based on real-world results

**Sprint 30+: General Availability**
- Full production rollout
- Master Agent available to all Service 13 clients
- Monitor: usage metrics, success rates, self-evolution effectiveness
- Continuous improvement based on village knowledge accumulation

---

## Code Examples

### Example 1: Simple Master Agent Setup

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

class SimpleAgentState(TypedDict):
    goal: str
    messages: list
    solution: dict

# Agent Node: Reasoning
async def agent_node(state: SimpleAgentState):
    """LLM decides what to do next"""
    response = await llm.ainvoke(
        messages=state["messages"],
        tools=[
            {"name": "research_agent", "description": "Analyzes data"},
            {"name": "strategy_agent", "description": "Designs solutions"}
        ]
    )
    return {"messages": state["messages"] + [response]}

# Tools Node: Execute tools or sub-agents
async def tools_node(state: SimpleAgentState):
    """Execute actions"""
    tool_calls = state["messages"][-1].tool_calls
    results = []

    for call in tool_calls:
        if call.name == "research_agent":
            # Invoke sub-agent (recursive LangGraph)
            sub_agent = ResearchAgent()
            result = await sub_agent.invoke(call.args)
        results.append(result)

    return {"messages": state["messages"] + results}

# Build workflow
workflow = StateGraph(SimpleAgentState)
workflow.add_node("agent", agent_node)
workflow.add_node("tools", tools_node)
workflow.add_conditional_edges("agent", should_continue, {"continue": "tools", "end": END})
workflow.add_edge("tools", "agent")
workflow.set_entry_point("agent")

# Run
app = workflow.compile()
result = await app.ainvoke({"goal": "Increase attach rate", "messages": []})
```

---

### Example 2: Sub-Agent with Recursive Capabilities

```python
class ResearchAgent:
    """
    Sub-agent for data analysis.
    This agent is ITSELF a full LangGraph with its own sub-agents.
    """

    def __init__(self):
        # ResearchAgent's own workflow
        self.workflow = self._build_workflow()

    def _build_workflow(self):
        workflow = StateGraph(ResearchState)

        # ResearchAgent's agent node
        workflow.add_node("research_reasoning", self.research_agent_node)

        # ResearchAgent's tools node (can call sub-sub-agents!)
        workflow.add_node("research_tools", self.research_tools_node)

        workflow.add_conditional_edges("research_reasoning", ...)
        workflow.add_edge("research_tools", "research_reasoning")
        workflow.set_entry_point("research_reasoning")

        return workflow.compile()

    async def invoke(self, task: dict):
        """Entry point when Master Agent calls this sub-agent"""
        return await self.workflow.ainvoke(task)

    async def research_agent_node(self, state: ResearchState):
        """ResearchAgent's reasoning"""
        response = await llm.ainvoke(
            messages=state["messages"],
            tools=[
                {"name": "query_database", "description": "SQL queries"},
                {"name": "data_analysis_agent", "description": "Statistical analysis (SUB-SUB-AGENT)"}
            ]
        )
        return {"messages": state["messages"] + [response]}

    async def research_tools_node(self, state: ResearchState):
        """ResearchAgent's tools (can call sub-sub-agents - RECURSIVE!)"""
        tool_calls = state["messages"][-1].tool_calls
        results = []

        for call in tool_calls:
            if call.name == "query_database":
                # Simple tool
                result = await database.query(call.args["sql"])

            elif call.name == "data_analysis_agent":
                # Sub-sub-agent (RECURSIVE - Level 3!)
                sub_sub_agent = DataAnalysisAgent()
                result = await sub_sub_agent.invoke(call.args)

            results.append(result)

        return {"messages": state["messages"] + results}
```

---

### Example 3: Self-Evolution Loop

```python
class OutcomeTracker:
    """
    Tracks Master Agent solution outcomes for self-evolution.
    """

    async def monitor(self, solution_id: str, expected: dict, measure_after_days: int):
        """
        Schedule outcome measurement.
        """
        measurement_date = datetime.now() + timedelta(days=measure_after_days)

        # Store expected outcome
        await self.db.insert("expected_outcomes", {
            "solution_id": solution_id,
            "expected": expected,
            "measurement_date": measurement_date,
            "status": "pending"
        })

        # Schedule measurement job
        await self.scheduler.schedule_job(
            job_id=f"measure_{solution_id}",
            run_at=measurement_date,
            function=self.measure_outcome,
            args=[solution_id]
        )

    async def measure_outcome(self, solution_id: str):
        """
        Measure actual outcome and update learnings.
        """
        # Get expected outcome
        expected = await self.db.get("expected_outcomes", solution_id)

        # Measure actual outcome
        actual = await self.measure_actual(expected["metrics"])

        # Compare
        success = self.evaluate_success(expected, actual)
        confidence_delta = self.calculate_confidence_delta(expected, actual)

        # Store in learnings database
        await self.learnings_db.insert({
            "solution_id": solution_id,
            "expected": expected,
            "actual": actual,
            "success": success,
            "confidence_delta": confidence_delta,
            "timestamp": datetime.now()
        })

        # Update village knowledge (if successful)
        if success:
            pattern = self.extract_pattern(solution_id)
            await self.village_knowledge.insert(pattern)

        # Adjust confidence model
        await self.confidence_model.update(confidence_delta)

        # Notify stakeholders
        await self.notify_outcome(solution_id, actual, success)
```

---

## Self-Evolution Mechanism

### The Learning Loop

```
1. EXECUTE
   Master Agent generates solution → Deploys to production

   ↓

2. MEASURE
   After N days, automatically measure actual outcome
   Expected: "Attach rate 7%"
   Actual: "Attach rate 7.2%"

   ↓

3. COMPARE
   Success evaluation: Actual >= Expected? → YES (7.2% >= 7%)
   Confidence delta: +0.13 (solution exceeded expectations)

   ↓

4. LEARN
   Store in learnings database:
   - Problem type: "low_retail_attach_rate"
   - Root cause: "staff_burnout"
   - Solution: "hybrid_coaching_and_automation"
   - Outcome: SUCCESS (7.2% vs 7% target)
   - Confidence: 0.95 (high)

   ↓

5. GENERALIZE
   Update village knowledge (for ALL clients):
   - Pattern: "Staff burnout → Hybrid intervention"
   - Evidence: Samsung Store 5 success
   - Applicability: Retail, Consumer Electronics
   - Confidence: 0.95

   ↓

6. OPTIMIZE
   Adjust confidence model:
   - Hybrid coaching + automation → Increase prior confidence by +0.10
   - Predicted 0.82 but actual 0.95 → Model was conservative

   ↓

7. REUSE
   Next client with similar problem:
   - Master Agent retrieves pattern from village knowledge
   - Recommends proven solution immediately
   - Confidence: 0.95 (pre-validated)
   - Time to solution: 5 minutes (vs 2 hours first time)
```

### Self-Evolution Data Structures

**Learnings Database Schema**:

```sql
CREATE TABLE solution_learnings (
    solution_id UUID PRIMARY KEY,
    problem_type VARCHAR,
    root_cause VARCHAR,
    solution_pattern VARCHAR,
    industry VARCHAR,
    vertical VARCHAR,

    -- Outcomes
    expected_outcome JSONB,
    actual_outcome JSONB,
    success BOOLEAN,
    confidence_predicted FLOAT,
    confidence_actual FLOAT,
    confidence_delta FLOAT,

    -- Context
    client_id VARCHAR,
    timeline_days INTEGER,
    budget_usd INTEGER,
    constraints JSONB,

    -- Evidence
    evidence JSONB,

    -- Metadata
    created_at TIMESTAMP,
    measured_at TIMESTAMP,

    -- Indexes
    INDEX idx_problem_type (problem_type),
    INDEX idx_success (success),
    INDEX idx_confidence_actual (confidence_actual)
);
```

**Village Knowledge Schema**:

```sql
CREATE TABLE village_knowledge (
    pattern_id UUID PRIMARY KEY,
    pattern_name VARCHAR,
    domain VARCHAR,
    description TEXT,

    -- Solution details
    intervention JSONB,
    expected_outcome TEXT,

    -- Evidence
    evidence JSONB,  -- Array of success stories

    -- Applicability
    applicability JSONB,  -- Industries, constraints, signals

    -- Confidence
    confidence FLOAT,
    reuse_count INTEGER,
    success_rate FLOAT,

    -- Metadata
    source VARCHAR,
    created_at TIMESTAMP,
    last_used_at TIMESTAMP,

    -- Vector embedding for semantic search
    embedding VECTOR(1536),

    -- Indexes
    INDEX idx_domain (domain),
    INDEX idx_confidence (confidence),
    INDEX idx_embedding USING ivfflat (embedding)
);
```

---

## Comparison: Current vs Master Agent

### Current Architecture (Pre-Master Agent)

**Service 13 handles pre-defined workflows**:

| Capability | Current Implementation | Limitation |
|------------|----------------------|------------|
| **Churn Risk** | Health score < 50 → Trigger "Churn Risk Playbook" | Requires pre-defined playbook |
| **Expansion** | Expansion score > 80 → Trigger "Expansion Outreach Playbook" | Requires pre-defined playbook |
| **QBR** | QBR due date approaching → Generate QBR document | Fixed format, no strategic insights |
| **New Problems** | ❌ No capability | Cannot handle arbitrary goals |

**Example**: Samsung Store attach rate problem
- Current: No pre-built playbook exists → Manual intervention required
- Time to solution: Days (requires human analysis and playbook creation)

---

### Master Agent Architecture (Post-Integration)

**Service 13 handles ANY business goal**:

| Capability | Master Agent Implementation | Advantage |
|------------|---------------------------|-----------|
| **Churn Risk** | Same as before (existing playbook) | Backward compatible |
| **Expansion** | Same as before (existing playbook) | Backward compatible |
| **QBR** | Enhanced with strategic insights from StrategyAgent | Better quality |
| **New Problems** | ✅ Master Agent spins up sub-agents dynamically | Solves ANY problem |

**Example**: Samsung Store attach rate problem
- Master Agent: Automatically spins up ResearchAgent + StrategyAgent + ImplementationPlanner
- Time to solution: Hours (fully automated analysis and solution generation)

---

### Side-by-Side Comparison

#### Scenario: "Reduce churn by 30% in APAC region"

**Current Approach**:
```
1. CSM receives goal
2. CSM manually analyzes churn data
3. CSM identifies root causes (takes days)
4. CSM designs intervention (takes days)
5. CSM creates new playbook (takes days)
6. Deploy playbook
7. Track outcome manually

Total time: 1-2 weeks
Automation: 20%
```

**Master Agent Approach**:
```
1. Master Agent receives goal
2. Master Agent (Agent Node): Plans approach
3. Master Agent (Tools Node): Invokes sub-agents
   - ResearchAgent: Analyzes churn data (automated)
   - StrategyAgent: Designs intervention (automated)
   - ImplementationPlanner: Creates playbook (automated)
4. Master Agent: Deploys playbook
5. Master Agent: Tracks outcome automatically
6. Master Agent: Stores learnings in village knowledge

Total time: 2-4 hours
Automation: 95%
```

---

## Risk Assessment

### Technical Risks

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| **Infinite recursion loops** | HIGH | MEDIUM | Max recursion depth = 5, timeout per agent = 5min |
| **Sub-agent state management complexity** | MEDIUM | HIGH | Comprehensive state testing, PostgreSQL checkpointing |
| **LLM hallucinations in strategy design** | HIGH | MEDIUM | Confidence scoring, human review for high-risk decisions |
| **Village knowledge data leaks** | HIGH | LOW | Multi-tenant isolation, RLS on village_knowledge table |
| **Sub-agent coordination failures** | MEDIUM | MEDIUM | Retry logic, graceful degradation, human escalation |
| **Performance degradation (deep recursion)** | MEDIUM | HIGH | Caching, async execution, horizontal scaling |

### Product Risks

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| **Master Agent solutions lower quality than human** | HIGH | MEDIUM | A/B test: 50% Master Agent, 50% human CSM |
| **Clients distrust AI-generated strategies** | MEDIUM | HIGH | Transparent explanations, show reasoning chain |
| **Over-reliance on Master Agent (deskilling CSMs)** | MEDIUM | LOW | Human-in-the-loop for high-stakes decisions |
| **Master Agent creates bad playbooks** | HIGH | LOW | Sandbox testing before production, rollback mechanism |

### Business Risks

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| **Development timeline extends beyond 12 weeks** | MEDIUM | MEDIUM | Phased rollout, MVP in Sprint 27, iterate |
| **Integration breaks existing Service 13** | HIGH | LOW | Feature flags, parallel deployment, extensive testing |
| **ROI not realized within 6 months** | MEDIUM | LOW | Track: time saved, solution quality, client satisfaction |

---

## Success Metrics

### Phase 1 Success Criteria (Sprint 27 - Integration Complete)

**Technical Metrics**:
- ✅ Master Agent handles 3 different problem types (churn, expansion, custom goal)
- ✅ Sub-agents successfully invoke sub-sub-agents (recursion works)
- ✅ Solution generation time < 2 hours (95th percentile)
- ✅ Zero data leaks between tenants (multi-tenancy verified)
- ✅ State persistence works across agent crashes

**Quality Metrics**:
- ✅ Master Agent solutions rated >= 4/5 by CSMs (internal review)
- ✅ Confidence scores correlate with actual success (r > 0.7)
- ✅ Village knowledge retrieval precision >= 80%

---

### Phase 2 Success Criteria (Sprint 28-29 - Beta Testing)

**Usage Metrics**:
- ✅ 5 pilot clients actively use Master Agent
- ✅ 20+ strategic goals processed
- ✅ 80% of goals result in deployed solutions

**Outcome Metrics**:
- ✅ 70% of Master Agent solutions achieve expected outcome
- ✅ Time to solution: 2-4 hours (vs 1-2 weeks manual)
- ✅ Client satisfaction: >= 4.5/5

**Self-Evolution Metrics**:
- ✅ Village knowledge grows by 10+ patterns
- ✅ Confidence model accuracy improves by 10%
- ✅ Solution reuse rate: 30% (second occurrence 5min vs 2hr first occurrence)

---

### Phase 3 Success Criteria (Sprint 30+ - General Availability)

**Adoption Metrics**:
- ✅ 100+ clients use Master Agent
- ✅ 500+ strategic goals processed
- ✅ 85% of goals result in deployed solutions

**Business Impact Metrics**:
- ✅ CSM productivity: 3x increase (handle 3x more strategic goals)
- ✅ Solution quality: 90% of Master Agent solutions achieve expected outcome
- ✅ Client satisfaction: >= 4.7/5
- ✅ Revenue impact: Master Agent clients have 20% higher retention

**Self-Evolution Metrics**:
- ✅ Village knowledge: 100+ validated patterns
- ✅ Confidence model accuracy: >= 85%
- ✅ Solution reuse rate: 60% (most problems have prior patterns)
- ✅ Time to solution (reused): < 5 minutes (instant retrieval from village knowledge)

---

## Appendix: LangGraph Research References

### Official LangGraph Documentation (2024-2025)

1. **Multi-Agent Systems - Overview**
   - URL: https://langchain-ai.github.io/langgraph/concepts/multi_agent/
   - Key Quote: "The supervisor can be thought of as an agent whose tools are other agents."
   - Relevance: Confirms sub-agents as tools pattern

2. **Agent Supervisor Tutorial**
   - URL: https://langchain-ai.github.io/langgraph/tutorials/multi_agent/agent_supervisor/
   - Key Quote: "Handoffs are implemented where one agent hands off control to another, typically via handoff tools given to the supervisor agent."
   - Relevance: Shows how to implement supervisor-worker pattern

3. **Use Subgraphs**
   - URL: https://langchain-ai.github.io/langgraph/how-tos/subgraph/
   - Key Quote: "Sub-agents can be defined as subgraphs with separate state schemas, with input/output transformations enabling parent-child graph communication."
   - Relevance: Explains state management for nested agents

4. **LangGraph: Multi-Agent Workflows (Blog)**
   - URL: https://blog.langchain.com/langgraph-multi-agent-workflows/
   - Key Quote: "Multi-agent designs allow you to divide complicated problems into tractable units of work that can be targeted by specialized agents."
   - Relevance: Validates Master Agent → Specialist sub-agents pattern

5. **Graph Recursion Limit Error Documentation**
   - URL: https://langchain-ai.github.io/langgraph/troubleshooting/errors/GRAPH_RECURSION_LIMIT/
   - Key Quote: "The recursion limit sets the maximum number of super-steps the graph can execute during a single execution. Default is 25 steps."
   - Relevance: Essential for configuring termination safety mechanisms

6. **Run an Agent with Iteration Limits**
   - URL: https://langchain-ai.github.io/langgraph/agents/run_agents/
   - Key Quote: "For AgentExecutor equivalence, set recursion_limit = 2 * max_iterations + 1"
   - Relevance: Shows how to configure intelligent termination bounds

7. **Low-Level Concepts: Conditional Edges**
   - URL: https://langchain-ai.github.io/langgraph/concepts/low_level/
   - Key Quote: "Conditional edges allow dynamic routing between nodes and can optionally terminate graph execution"
   - Relevance: Foundation for implementing should_continue termination logic

8. **Rebuild Graph at Runtime**
   - URL: https://docs.langchain.com/langgraph-platform/graph-rebuild
   - Key Quote: "To make your graph rebuild on each new run with custom configuration, provide a function that takes a config and returns a graph (or compiled graph) instance"
   - Relevance: Core pattern for runtime graph compilation and dynamic workflow adaptation

9. **Building Dynamic Agentic Workflows at Runtime**
   - URL: https://github.com/langchain-ai/langgraph/discussions/2219
   - Key Quote: "Instead of pre-defining workflows, graphs can be dynamically created at runtime via a Planner agent, allowing the system to adapt to any query by generating a tailored execution plan"
   - Relevance: Advanced pattern for meta-planning and dynamic graph generation

10. **LangGraph CLI Documentation**
    - URL: https://docs.langchain.com/langgraph-platform/cli
    - Key Quote: "`langgraph dev` runs the API server in development mode with hot reloading and debugging capabilities"
    - Relevance: Hot reload functionality for rapid development and testing of dynamic graphs

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-11 | AI Assistant + Founder | Initial architecture design based on PRD Builder abstraction, personal assistant mental model, and recursive agent-tools pattern |

---

**END OF DOCUMENT**
