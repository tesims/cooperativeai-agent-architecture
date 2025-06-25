# Concordia: Step-by-Step User Manual

## Table of Contents
1. [What is Concordia?](#what-is-concordia)
2. [How It Works: The Core Concepts](#how-it-works-the-core-concepts)
3. [The Simulation Process](#the-simulation-process)
4. [What Can You Use It For?](#what-can-you-use-it-for)
5. [Who Is This For?](#who-is-this-for)

## What is Concordia?

Concordia is a Python library created by Google DeepMind for building generative agent-based models. Think of it as a sophisticated framework for creating simulations where multiple AI "agents" interact with each other and a simulated environment.

The core idea is inspired by tabletop role-playing games like Dungeons & Dragons. A special agent, the **Game Master (GM)**, narrates the state of the world and interprets the actions of the player agents. The player agents, powered by Large Language Models (LLMs), decide what to do and state their actions in natural language (e.g., "I will try to convince the shopkeeper to give me a discount."). The GM then processes this, determines the outcome, and describes what happens next.

## How It Works: The Core Concepts

### 1. Agents (EntityAgent)

These are the actors in the simulation. Each agent is a self-contained entity with its own goals, memories, and decision-making processes. In Concordia, the primary agent class is `EntityAgent`, which is essentially a container for various components that define its behavior.

**Code Reference:** `concordia/agents/entity_agent.py`

### 2. Components (ContextComponent, ActingComponent)

This is the most important concept. Instead of writing one monolithic agent class, you build agents by assembling smaller, reusable components. Each component is responsible for a specific piece of the agent's "thinking" process.

For example, an agent might be composed of:
- An **InstructionsComponent** to hold its core identity (e.g., "You are a friendly shopkeeper.")
- A **MemoryComponent** to remember past events
- A **PlanComponent** to formulate and follow multi-step plans
- An **ObservationComponent** to process what it sees and hears

The components you are building, like a `NegotiationComponent` or a `PromiseKeepingComponent`, would fit right into this architecture.

**Code Reference:** `concordia/components/` and `concordia/typing/entity_component.py`

### 3. Prefabs

Since assembling all these components manually for every agent can be repetitive, Concordia uses a "prefab" system. A prefab is a pre-configured template for an agent. It's a class that knows how to build a specific type of agent (e.g., a "basic agent with a plan") by putting together the right set of components. Your goal is to create prefabs for the different agent architectures you've designed.

**Code Reference:** `concordia/prefabs/`

## The Simulation Process

The simulation proceeds in turns, orchestrated by the Game Master, following an **Act-Observe Cycle**:

### Act Phase
When it's an agent's turn to act, the GM asks it for an action. The agent's `ActingComponent`:
1. Gathers context from all its other components (what are my goals? what do I remember? what's my plan?)
2. Constructs a large prompt
3. Sends it to an LLM to generate an action

### Observe Phase
The GM:
1. Takes the actions from all agents
2. Determines the outcome of those actions (often using an LLM itself)
3. Generates an observation for each agent (e.g., "The shopkeeper looks unconvinced by your argument and the other customers in the pub are now staring at you.")

Each agent's `ObservationComponent`:
1. Receives this observation
2. Processes it
3. Stores important details in its memory

This updates the agent's internal state, influencing its next action.

## What Can You Use It For?

Based on the codebase and its documentation, Concordia is designed for a wide range of applications:

### 🔬 Social Science Research
Simulate social dynamics, cultural evolution, or economic interactions. You can create societies of agents with different personalities and see how they behave over time.

### ⚖️ AI Ethics and Safety
Test AI agents in complex social dilemmas. For example, you could test for fairness, bias, or the propensity for agents to cooperate or deceive one another.

### 📊 Data Generation
Generate rich, context-aware datasets of social interactions. This data could be used to fine-tune smaller, more specialized language models for specific social tasks.

### 📈 Performance Evaluation
You can build simulated environments to test how real-world applications or services would be used by different types of users, represented by the agents.

## Who Is This For?

### 1. The Primary Audience: Researchers

This is the main target group. Concordia is a powerful tool for conducting research in a variety of fields:

#### 👥 Social Scientists (Sociologists, Psychologists, Economists)
Researchers can create simulated societies to test theories about human behavior. For example, they could study:
- How social norms emerge
- How reputations are formed
- How economic inequality develops
- How different communication styles affect group decisions

It's like a virtual laboratory for social experiments.

#### 🛡️ AI Ethicists and Safety Researchers
This platform is ideal for creating "moral mazes" for AI agents. Researchers can design complex ethical dilemmas and see how different agent architectures navigate them. They can study:
- Fairness
- Bias
- Deception
- Potential for unintended harmful consequences in multi-agent systems

#### 🧠 Cognitive Scientists and Neuroscientists
Researchers can model theories of human cognition. The README.md explicitly mentions the "three key questions" model of human action:
1. What situation is this?
2. Who am I?
3. What do people like me do here?

Concordia allows scientists to implement these cognitive models as agent architectures and test their behavioral predictions.

### 2. The Secondary Audience: AI/ML Engineers and Developers

While its roots are in research, Concordia is also a practical tool for engineers:

#### 🤖 Developers Building Socially-Aware AI
If you're building a chatbot, a virtual assistant, or any AI that needs to interact with humans in a sophisticated way, you can use Concordia to generate realistic training data for a wide range of social scenarios.

#### 🔧 Engineers Evaluating AI Systems
You can use Concordia to create a "digital twin" of a real-world environment to test your own AI. For example, you could simulate thousands of "users" (as Concordia agents) interacting with a new app or service to:
- Find bugs
- Evaluate user experience
- Assess performance under different conditions before launching to the public

---

*This manual provides the foundation for understanding Concordia. For specific implementation details and tutorials, refer to the additional documentation and examples in the repository.*
