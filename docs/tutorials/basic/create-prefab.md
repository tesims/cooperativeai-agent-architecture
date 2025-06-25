# Tutorial: Creating a Concordia Prefab

This tutorial provides a complete, step-by-step guide to creating a custom agent prefab in Concordia. We will build a **"Historian Agent"**. This agent's special ability, defined by a custom component, will be to summarize historical events from its memory to inform its actions.

### What is a Prefab?

A **Prefab** (pre-fabricated object) is a blueprint for creating an agent. It defines which components an agent should have and how they should be configured. Using prefabs allows you to easily create and reuse different types of agents without rewriting the assembly code every time. The core idea is to separate an agent's *behavior* (its components) from its *construction* (the prefab).

---

### Step 1: Create the Directory Structure

Before writing any code, it's best practice to set up a clean directory structure. This keeps your custom code organized and separate from the core Concordia library.

Open your terminal and run the following commands to create the necessary directories:

```bash
mkdir -p concordia_custom_components/prefabs/entity
mkdir -p concordia_custom_components/components/agent
mkdir -p concordia_custom_components/examples
```

This will give you:
*   `concordia_custom_components/components/agent/`: A place for your new, custom agent components.
*   `concordia_custom_components/prefabs/entity/`: A place for your new agent prefabs.
*   `concordia_custom_components/examples/`: A place for a script to test your new agent.

---

### Step 2: Create the Custom Component

Every special agent needs a special component to define its unique behavior. We'll create a `HistoricalSummaryComponent`. This component will be responsible for accessing the agent's memory, retrieving recent events, and using an LLM to create a historical summary.

Create a new file at `concordia_custom_components/components/agent/historical_summary.py` and add the following code:

```python
"""A component that provides a historical summary of events."""

from concordia.components.agent import action_spec_ignored
from concordia.language_model import language_model
from concordia.typing import entity_component
from concordia.components.agent.memory import AssociativeMemory

DEFAULT_PRE_ACT_LABEL = 'Historical Summary'


class HistoricalSummaryComponent(
    action_spec_ignored.ActionSpecIgnored,
    entity_component.ComponentWithLogging,
):
    """A component that summarizes the agent's memory of past events."""

    def __init__(
        self,
        model: language_model.LanguageModel,
        memory_component_name: str = 'memory',
        num_memories_to_summarize: int = 10,
        pre_act_label: str = DEFAULT_PRE_ACT_LABEL,
    ):
        """Initializes the component.

        Args:
            model: The language model to use for summarization.
            memory_component_name: The name of the memory component to use.
            num_memories_to_summarize: The number of recent memories to summarize.
            pre_act_label: The label to use before the component's output.
        """
        super().__init__(pre_act_label)
        self._model = model
        self._memory_component_name = memory_component_name
        self._num_memories_to_summarize = num_memories_to_summarize

    def _get_memory_component(self) -> AssociativeMemory:
        """Gets the memory component from the agent."""
        # The get_entity() method gives access to the parent agent,
        # which allows this component to find other components.
        return self.get_entity().get_component(
            self._memory_component_name,
            type_=AssociativeMemory
        )

    def _make_pre_act_value(self) -> str:
        """This is the main logic of the component. It's called by the agent
        during the 'pre_act' phase of its decision-making cycle.
        """
        memory = self._get_memory_component()
        # Retrieve the most recent memories from the agent's memory component.
        recent_memories = memory.retrieve(limit=self._num_memories_to_summarize)

        if not recent_memories:
            return "No significant historical events to summarize."

        # Construct a prompt for the LLM to generate a summary.
        prompt = (
            "Summarize the following sequence of events from a historical "
            "perspective, focusing on cause and effect.\n\n"
            "Events:\n"
        )
        for mem in recent_memories:
            prompt += f"- {mem.text}\n"

        summary = self._model.sample(prompt=prompt)

        # This is good practice for debugging and seeing the component's output.
        self._logging_channel({
            'Key': self.get_pre_act_label(),
            'Value': summary,
        })
        return summary
```

**Key Concepts Explained:**
*   **`_make_pre_act_value`**: This is the core method. During an agent's turn, before it decides what to do (`pre_act`), it calls this method on all its components. The string returned by this method becomes part of the final context prompt sent to the LLM to decide on an action.
*   **`get_entity().get_component(...)`**: This is how components can interact with each other. A component can ask its parent agent to give it a reference to another component (in this case, the `memory` component).

---

### Step 3: Create the Prefab

Now we will define the prefab itself. This class is responsible for assembling a "Historian Agent" using our new component alongside standard ones.

Create a new file at `concordia_custom_components/prefabs/entity/historian.py` and add the following code:

```python
"""A prefab for a historian agent."""

import dataclasses
from collections.abc import Mapping

from concordia.agents import entity_agent_with_logging
from concordia.associative_memory import basic_associative_memory
from concordia.components import agent as agent_components
from concordia.language_model import language_model
from concordia.typing import prefab as prefab_lib

# Import our custom component so the prefab can use it.
from concordia_custom_components.components.agent import historical_summary

@dataclasses.dataclass
class HistorianAgent(prefab_lib.Prefab):
    """A prefab for an agent that summarizes historical events."""

    description: str = "An agent that reflects on history to inform its actions."
    params: Mapping[str, str] = dataclasses.field(
        default_factory=lambda: {
            'name': 'Historian',
            'goal': 'To observe the flow of events and provide historical context.',
            'summarize_last_n_memories': '10',
        }
    )

    def build(
        self,
        model: language_model.LanguageModel,
        memory_bank: basic_associative_memory.AssociativeMemoryBank,
    ) -> entity_agent_with_logging.EntityAgentWithLogging:
        """This method is the factory that builds the agent."""
        agent_name = self.params['name']
        num_memories = int(self.params['summarize_last_n_memories'])

        # 1. Define all the components the agent will use.
        # These are standard components required by most agents.
        memory = agent_components.memory.AssociativeMemory(memory_bank=memory_bank)
        observation = agent_components.observation.ObservationComponent(model=model, memory=memory)
        plan = agent_components.plan.PlanComponent(model=model, memory=memory)

        # Here is where we instantiate our custom component.
        history = historical_summary.HistoricalSummaryComponent(
            model=model,
            memory_component_name='memory', # Tells it which component to get memories from
            num_memories_to_summarize=num_memories,
        )

        # 2. Assemble the components into a dictionary.
        # The keys are the names the components will have within the agent.
        # This is how the 'history' component can find the 'memory' component.
        components = {
            'memory': memory,
            'observation': observation,
            'plan': plan,
            'history': history, # Our custom component
        }

        # 3. Define the acting sequence.
        # This is a critical step. It controls the order of information in the final
        # prompt that the LLM sees when deciding on an action.
        component_order = [
            'observation',
            'plan',
            'history', # We want the historical summary to inform the action.
        ]

        # 4. Create the 'act' component, which orchestrates the acting sequence.
        act_component = agent_components.concat_act_component.ConcatActComponent(
            model=model,
            component_order=component_order,
        )

        # 5. Build and return the final agent object.
        agent = entity_agent_with_logging.EntityAgentWithLogging(
            agent_name=agent_name,
            act_component=act_component,
            context_components=components,
        )
        return agent
```

**Key Concepts Explained:**
*   **`build` method**: This is the factory for your agent. It's where you declare all the "parts" (components) your agent needs and how they fit together.
*   **`components` dictionary**: This dictionary maps a name to each component instance. This is how components can reference each other (e.g., our history component looks for the 'memory' component).
*   **`component_order` list**: This determines the structure of the prompt sent to the LLM. The order `['observation', 'plan', 'history']` means the LLM will see something like: "Here's what you just saw... Here's your current plan... Here's a historical summary... Now, what do you do?". The order matters greatly for the agent's reasoning process.

---

### Step 4: Test the Prefab in an Example

Now that you have defined the component and the prefab, let's write a simple script to see it in action.

Create a new file at `concordia_custom_components/examples/run_historian.py` and add the following code:

```python
"""Example of running a custom historian agent."""

import os

from concordia.associative_memory import basic_associative_memory
from concordia.language_model import gpt_model
from concordia_custom_components.prefabs.entity import historian

# --- Configuration ---
# Make sure you have your OpenAI API key set as an environment variable.
# You can replace this with any model that supports the `sample` method.
API_KEY = os.getenv('OPENAI_API_KEY')
MODEL_NAME = 'gpt-3.5-turbo'

def main():
    if not API_KEY:
        raise ValueError("OPENAI_API_KEY environment variable not set.")

    # 1. Create the backend: the language model and the agent's memory bank.
    model = gpt_model.GptLanguageModel(api_key=API_KEY, model_name=MODEL_NAME)
    memory_bank = basic_associative_memory.AssociativeMemoryBank()

    # 2. Instantiate your custom prefab.
    agent_prefab = historian.HistorianAgent()

    # 3. Use the prefab's build() method to create the agent instance.
    # This is where all the components are created and assembled.
    agent = agent_prefab.build(model=model, memory_bank=memory_bank)

    print(f"Created agent: {agent.name}")

    # 4. Simulate some observations to populate the agent's memory.
    # The agent doesn't "react" yet, it just stores these memories.
    agent.observe("The sky turned a worrying shade of green.")
    agent.observe("A strange humming sound began to fill the air.")
    agent.observe("Citizens started gathering in the town square, looking nervous.")
    agent.observe("The town elder, clutching an ancient scroll, stepped onto the podium.")

    # 5. Ask the agent to act.
    # This is the moment everything comes together. When you call .act():
    # - The HistoricalSummaryComponent will run its _make_pre_act_value method.
    # - It will summarize the observations we just made.
    # - That summary will be fed into the agent's final decision-making prompt.
    action_result = agent.act()

    print("\n--- Agent's Action ---")
    print(action_result)
    print("----------------------\n")

if __name__ == '__main__':
    main()

```

**To run this example:**

1.  Set your OpenAI API key as an environment variable in your terminal:
    ```bash
    export OPENAI_API_KEY='your-key-here'
    ```
2.  Run the script from the root of the `concordia` directory:
    ```bash
    python concordia_custom_components/examples/run_historian.py
    ```

You should see the agent's action printed to the console. The action it takes will be informed by the historical summary automatically generated by your custom component, demonstrating that your prefab works as intended.

This completes the tutorial. You have successfully created a custom component, defined a prefab to use it, and instantiated a working agent from that prefab. You can use this pattern to create all the agent architectures outlined in your proposal.
