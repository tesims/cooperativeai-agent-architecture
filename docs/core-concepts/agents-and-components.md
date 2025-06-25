# Agents and Components

This page provides a detailed guide to understanding and working with agents and components in Concordia.

## Understanding Agents

Agents in Concordia are the primary actors in your simulation. Think of them as individual characters or entities that can perceive their environment, make decisions, and take actions.

### The EntityAgent Class

The `EntityAgent` is the main agent class in Concordia:

```python
from concordia.agents import entity_agent

agent = entity_agent.EntityAgent(
    agent_name="Alice",
    act_component=acting_component,
    context_components=[
        instructions_component,
        memory_component,
        observation_component,
    ]
)
```

### Key Agent Properties

- **Name**: Unique identifier for the agent
- **Components**: Modular pieces that define behavior
- **State**: Current internal state and memories
- **History**: Record of past actions and observations

## Component Architecture

Components are the building blocks of agent behavior. They follow a modular design that makes agents flexible and extensible.

### Component Types

#### Context Components

Context components provide information to the agent's decision-making process:

**Instructions Component**
```python
from concordia.components.agent import v2 as agent_components

instructions = agent_components.instructions.Instructions(
    agent_name="Alice",
    instruction="You are a helpful researcher studying social dynamics."
)
```

**Memory Component**
```python
memory = agent_components.memory.Memory(
    agent_name="Alice",
    memory_bank=associative_memory_bank
)
```

**Observation Component**
```python
observation = agent_components.observation.Observation(
    agent_name="Alice"
)
```

#### Acting Components

Acting components determine what action the agent takes:

```python
acting = agent_components.concat_act_component.ConcatActComponent()
```

### Component Lifecycle

Components participate in the agent's decision cycle:

1. **Pre-Act**: Gather context information
2. **Act**: Generate the agent's action
3. **Post-Act**: Process the action result
4. **Pre-Observe**: Prepare for new observations
5. **Post-Observe**: Process and store observations

## Creating Custom Components

You can create custom components to implement specific behaviors:

```python
from concordia.typing import entity_component

class CustomComponent(entity_component.ContextComponent):
    def __init__(self, agent_name: str, custom_config: dict):
        self._agent_name = agent_name
        self._config = custom_config

    def pre_act(self, unused_action_spec) -> str:
        # Return context for this component
        return f"Custom context for {self._agent_name}"

    def pre_observe(self, observation: str) -> str:
        # Process incoming observations
        return observation
```

### Component Best Practices

1. **Single Responsibility**: Each component should handle one aspect of cognition
2. **Clear Interfaces**: Use well-defined input/output contracts
3. **State Management**: Keep component state minimal and well-organized
4. **Documentation**: Include clear docstrings and type hints

## Agent Assembly Patterns

### Basic Agent Pattern

```python
def create_basic_agent(name: str, goal: str):
    return entity_agent.EntityAgent(
        agent_name=name,
        act_component=agent_components.concat_act_component.ConcatActComponent(),
        context_components=[
            agent_components.instructions.Instructions(
                agent_name=name,
                instruction=f"You are {name}. Your goal is: {goal}"
            ),
            agent_components.memory.Memory(agent_name=name),
            agent_components.observation.Observation(agent_name=name),
        ]
    )
```

### Advanced Agent Pattern

```python
def create_advanced_agent(name: str, personality: dict):
    components = [
        agent_components.instructions.Instructions(
            agent_name=name,
            instruction=personality.get("base_instruction", "")
        ),
        agent_components.memory.Memory(agent_name=name),
        agent_components.observation.Observation(agent_name=name),
    ]

    # Add specialized components based on personality
    if personality.get("planning_focused"):
        components.append(
            agent_components.plan.Plan(agent_name=name)
        )

    if personality.get("socially_aware"):
        components.append(
            CustomSocialAwarenessComponent(agent_name=name)
        )

    return entity_agent.EntityAgent(
        agent_name=name,
        act_component=agent_components.concat_act_component.ConcatActComponent(),
        context_components=components
    )
```

## Component Communication

Components can share information through the agent's context:

```python
class CommunicatingComponent(entity_component.ContextComponent):
    def pre_act(self, action_spec) -> str:
        # Access other component outputs through the agent
        memory_context = self._agent.get_component_output("memory")
        plan_context = self._agent.get_component_output("plan")

        # Combine information
        return f"Memory: {memory_context}\nPlan: {plan_context}"
```

## Testing Components

Always test your components in isolation:

```python
def test_custom_component():
    component = CustomComponent("TestAgent", {})

    # Test pre_act
    context = component.pre_act(None)
    assert context is not None

    # Test pre_observe
    observation = "Test observation"
    processed = component.pre_observe(observation)
    assert processed == observation
```

## Next Steps

- Learn about [The Game Master Pattern](game-master.md)
- Try [Creating Your First Simulation](../tutorials/basic/creating-simulation.md)
- Explore [Advanced Component Creation](../tutorials/basic/create-prefab.md)

---

*Ready to build your first agent? Check out the [Agent Assembly Tutorial](../tutorials/basic/assembling-agent.md)!*
