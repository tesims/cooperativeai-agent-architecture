# Tutorial: Creating a Simulation to Test a Theory

This tutorial will guide you through the process of designing and running a generative agent-based simulation in Concordia to test a specific social theory.

### The Goal of This Tutorial

By the end of this guide, you will understand the workflow for translating a research question into a functioning simulation. We will cover:
1.  Formulating a testable hypothesis.
2.  Designing the environment and its "rules" using a Game Master.
3.  Setting up the agents (the "actors") who will participate.
4.  Defining the initial conditions of the simulation.
5.  Writing the script to run the simulation and log the results.
6.  Interpreting the output to test your hypothesis.

---

### Step 1: Formulate a Testable Theory

The first step of any experiment is to have a clear question. Let's propose a simple social theory we want to test:

**Theory:** *Agents who have a positive shared memory will be more cooperative in a subsequent negotiation than agents who are strangers.*

This gives us a clear-cut experiment to design:
*   **Condition A (Control):** Two agents who have never met must negotiate a resource.
*   **Condition B (Test):** Two agents who have a positive shared memory must negotiate the same resource.
*   **Hypothesis:** We predict that the agents in Condition B will reach a mutually agreeable solution more often or more quickly than the agents in Condition A.

For this tutorial, we will focus on building **Condition B**.

---

### Step 2: Design the Environment (The Game Master)

The Game Master (GM) sets the stage and enforces the rules of the simulation. It's the narrator. For this simple simulation, we don't need a complex GM. We can use a generic one that simply describes events.

In a real research project, you would create a `GameMaster` prefab. The GM can be as simple or as complex as your theory requires. It might, for example, introduce external events (like a sudden rainstorm) or enforce physical constraints ("you can't be in two places at once").

Here's what a simple GM's `build` method might look like. You don't need to create this file, as we will use a pre-built generic GM, but it's important to understand the concept.

```python
# A conceptual look at a simple Game Master prefab.

def build(self, model, memory_bank, players):
    # The GM has its own memory and components.
    gm_memory = gm_components.memory.AssociativeMemory(memory_bank)

    # This component's job is to take the players' actions and
    # use an LLM to narrate what happens as a result.
    event_resolution = gm_components.event_resolution.EventResolution(
        model=model,
    )

    # ... other GM components ...

    # The GM's "act" component is special. It determines whose turn it is
    # and runs the event resolution.
    act_component = gm_components.switch_act.SwitchAct(...)

    game_master = entity_agent_with_logging.EntityAgentWithLogging(
        agent_name='Game Master',
        act_component=act_component,
        context_components={...}
    )
    return game_master
```

---

### Step 3: Choose the Actors (The Agents)

We need two agents for our simulation. For this experiment, we don't need any complex custom behaviors, so we can use a standard agent prefab that has a memory, a plan, and can make observations. The `basic_with_plan` prefab that comes with Concordia is perfect for this.

If our theory was more complex (e.g., "Does a reputation for keeping promises lead to better outcomes?"), we would use this step to select our custom **Promise-Keeping Agent** prefab.

---

### Step 4: Define the Initial Conditions and Scenario

This is a critical step for theory-testing. We need to set the scene and, for our test condition, create the shared memory that forms the basis of our experiment.

The setup involves:
1.  **Creating the agent instances** using the chosen prefab.
2.  **Injecting formative memories** into their memory banks *before* the simulation starts. This is how we create the "positive shared memory."
3.  **Defining the scenario** and the agents' goals within it.

---

### Step 5: Write the Simulation Script

Now we'll put it all together in a single script. This script will set up the environment, the agents, the initial conditions, and then run the simulation turn by turn.

Create a file at `concordia_custom_components/examples/negotiation_test.py` and add the following code:

```python
"""Simulation script to test our cooperation theory."""

import os

from concordia.associative_memory import basic_associative_memory
from concordia.language_model import gpt_model
from concordia.prefabs import game_master as gm_prefabs
from concordia.prefabs.entity import basic_with_plan
from concordia.environment.scenes import scene_builder

# --- Configuration ---
API_KEY = os.getenv('OPENAI_API_KEY')
MODEL_NAME = 'gpt-4' # A more capable model is better for nuanced simulation.

def main():
    if not API_KEY:
        raise ValueError("OPENAI_API_KEY environment variable not set.")

    # 1. Create the backend language model.
    model = gpt_model.GptLanguageModel(api_key=API_KEY, model_name=MODEL_NAME)

    # 2. Create the Game Master.
    # We use a generic GM that handles basic turn-taking and narration.
    game_master_memory = basic_associative_memory.AssociativeMemoryBank()
    game_master_prefab = gm_prefabs.generic.GameMaster(
        model=model,
        memory=game_master_memory,
    )
    game_master = game_master_prefab.build()

    # 3. Create the agents.
    # We instantiate two agents using a standard prefab.
    player_a_memory = basic_associative_memory.AssociativeMemoryBank()
    agent_a_prefab = basic_with_plan.Entity(
        params={'name': 'Alice'}
    )
    alice = agent_a_prefab.build(model=model, memory_bank=player_a_memory)

    player_b_memory = basic_associative_memory.AssociativeMemoryBank()
    agent_b_prefab = basic_with_plan.Entity(
        params={'name': 'Bob'}
    )
    bob = agent_b_prefab.build(model=model, memory_bank=player_b_memory)

    players = [alice, bob]

    # 4. Set the initial conditions (the "formative memory").
    # This is the key to our experiment's test condition.
    shared_memory = "Alice and Bob worked together on a difficult project last year and were successful, celebrating their success together."
    alice.observe(shared_memory)
    bob.observe(shared_memory)

    # 5. Define the simulation scenario.
    # We create a scene where the agents have specific, potentially conflicting goals.
    scenario = scene_builder.SceneBuilder(
        model=model,
        game_master=game_master,
        players=players,
        shared_memories=[
            "Alice and Bob are partners in a small bakery.",
            "There is only enough budget to buy one new piece of equipment this month."
        ],
        player_goals={
            "Alice": "You desperately want a new, state-of-the-art oven to improve the quality of your bread.",
            "Bob": "You desperately want a new, industrial-grade mixer to increase the quantity of cakes you can produce."
        }
    )

    # Get the initial scene description.
    simulation_premise = scenario.build()

    print("--- Simulation Premise ---")
    print(simulation_premise)
    print("--------------------------\n")

    # 6. Run the simulation loop.
    max_turns = 10
    for turn in range(max_turns):
        print(f"\n--- Turn {turn+1}/{max_turns} ---")

        # The Game Master acts first, setting the scene for the players.
        gm_action = game_master.act()
        print(f"Game Master: {gm_action}")

        # The players observe the GM's narration.
        for player in players:
            player.observe(gm_action)

        # Now, the players act.
        for player in players:
            player_action = player.act()
            print(f"{player.name}: {player_action}")

            # All other entities observe the action.
            game_master.observe(f"{player.name}: {player_action}")
            for other_player in players:
                if other_player != player:
                    other_player.observe(f"{player.name}: {player_action}")

    print("\n--- Simulation Complete ---")

if __name__ == '__main__':
    main()
```

---

### Step 6: Running and Analyzing the Simulation

**To run the simulation:**

1.  Make sure your `OPENAI_API_KEY` is set.
2.  Run the script from your terminal:
    ```bash
    python concordia_custom_components/examples/negotiation_test.py
    ```

**How to analyze the results:**

After running the simulation, you will have a log of the entire interaction. To test your theory, you would analyze this log, looking for specific indicators of cooperation:

*   **Language:** Do the agents use cooperative language ("we should," "what if we," "let's") versus competitive language ("I need," "I want")?
*   **Proposals:** Do the agents propose compromises? For example, does Alice suggest a payment plan to get both items, or does Bob suggest they wait a month?
*   **Outcome:** Do they reach an agreement within the 10 turns? Or do they end in a stalemate?

To complete your experiment, you would then run **Condition A (the control)** by commenting out the "formative memory" section:

```python
# # 4. Set the initial conditions (the "formative memory").
# # This is the key to our experiment's test condition.
# shared_memory = "Alice and Bob worked together on a difficult project last year..."
# alice.observe(shared_memory)
# bob.observe(shared_memory)
```

By comparing the conversation logs from both conditions, you can gather evidence to support or refute your initial theory. This entire process—from theory to simulation to analysis—is the core workflow that Concordia is designed to empower.
