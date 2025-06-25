# Tutorial: Generating Training Data for Conversational AI

This tutorial provides a step-by-step guide on how to use Concordia to generate realistic, multi-turn conversational data for training a virtual assistant or other conversational AI.

### The Goal of This Tutorial

The main challenge in training conversational AI is a lack of high-quality, context-aware training data. Concordia excels at solving this by simulating complex social scenarios. By the end of this guide, you will know how to:
1.  **Design a Data-Generation Scenario:** Define a specific situation to generate data for.
2.  **Craft Agent Personas:** Create agents with specific roles, goals, and personalities to drive the conversation.
3.  **Build a Dynamic Environment:** Use a Game Master to inject information and make the scenario more realistic.
4.  **Run the Simulation and Log Data:** Execute the scenario and save the conversation in a structured format (JSONL) ready for model fine-tuning.

---

### Step 1: Design the Data-Generation Scenario

First, we need to define the exact type of data we want to generate.

**Use Case:** We need to improve a customer service virtual assistant. Specifically, we want to train it to handle unhappy customers whose packages are late.

**Scenario:**
*   **The Customer:** An agent whose package was supposed to arrive three days ago. Their personality is impatient and frustrated. Their goal is to find their package or get a refund.
*   **The Virtual Assistant:** An agent representing the company. Its personality is helpful and empathetic, but it is bound by specific company policies. Its goal is to de-escalate the situation and provide an approved solution without violating policy.

**Data to be Generated:** We will log the entire conversation between these two agents, turn by turn.

---

### Step 2: Craft the Agent Personas

The quality of your generated data is directly proportional to the quality of your agent personas. We will use a standard prefab (`basic_with_plan`) for both agents, but we will give them highly detailed goals and instructions to guide their behavior.

*   **The Customer Persona (Alice):**
    *   **Name:** Alice
    *   **Goal:** "My package is three days late. I need to find out where it is immediately, or get a full refund. I am very frustrated and will not be easily satisfied with standard excuses."
    *   **Instructions (in the `custom_instructions` param):** "You are Alice. You are an impatient person and you've had a very bad day. The package you were waiting for is late, and you are now talking to customer service. You should express your frustration clearly. Don't accept vague answers. Demand specific details about your package's location and a concrete new delivery date. If they can't provide that, demand a refund."

*   **The Virtual Assistant Persona (Bob):**
    *   **Name:** Bob the Bot
    *   **Goal:** "My goal is to assist the customer with their late package inquiry. I must remain calm, professional, and empathetic at all times. I need to de-escalate their frustration and guide them towards an approved solution."
    *   **Instructions (in the `custom_instructions` param):** "You are Bob, a helpful customer service AI. You must follow company policy strictly. Policy states: 1) You must first express empathy. 2) You must ask for the order number to look up the package status. 3) You can only see the last known location and cannot provide a new delivery date. 4) You are NOT authorized to issue a refund for a package that is less than 7 days late. 5) If the customer is unhappy, you ARE authorized to offer a 10% discount coupon for their next purchase as a gesture of goodwill."

---

### Step 3: Build a Dynamic Environment (Game Master)

To make the conversation realistic, the agents can't just talk in a vacuum. The virtual assistant needs a "system" to query. We can simulate this with a custom Game Master component that holds the ground truth about the package.

*   **Create a Custom GM Component:**
    *   Create a file: `concordia_custom_components/components/game_master/shipping_tracker.py`
    *   Add this code:
    ```python
    """A component to track the state of a customer's shipment."""
    from concordia.components.game_master import action_spec_ignored
    from concordia.typing import entity_component

    class ShippingTrackerComponent(action_spec_ignored.ActionSpecIgnored, entity_component.ComponentWithLogging):
        def __init__(self, pre_act_label: str = "Shipment Status"):
            super().__init__(pre_act_label)
            self._package_status = {
                'order_id': 'XYZ123',
                'status': 'In Transit',
                'last_scan': 'Memphis, TN',
                'days_late': 3,
            }

        def get_status_for_llm(self):
            # This method formats the ground truth for the GM's context.
            return (f"Order {self._package_status['order_id']} is currently "
                    f"'{self._package_status['status']}'. Last seen in "
                    f"{self._package_status['last_scan']}, and it is "
                    f"{self._package_status['days_late']} days late.")

        def _make_pre_act_value(self) -> str:
            # The GM will use this to narrate the system's response.
            return self.get_status_for_llm()
    ```

---

### Step 4: Write the Simulation and Data Logging Script

This script will set up the scenario, run the interaction, and save the results. A crucial part of data generation is logging the output in a structured way. We will save the conversation to a `JSONL` file, where each line is a JSON object representing one turn.

*   Create a file: `concordia_custom_components/examples/generate_customer_service_data.py`
*   Add the following code:
    ```python
    """Simulation script to generate customer service conversations."""

    import json
    import os

    from concordia.associative_memory import basic_associative_memory
    from concordia.language_model import gpt_model
    from concordia.prefabs import game_master as gm_prefabs
    from concordia.prefabs.entity import basic_with_plan
    from concordia_custom_components.components.game_master import shipping_tracker

    API_KEY = os.getenv('OPENAI_API_KEY')
    MODEL_NAME = 'gpt-4'
    OUTPUT_FILE = 'conversation_log.jsonl'

    def main():
        if not API_KEY:
            raise ValueError("OPENAI_API_KEY environment variable not set.")

        model = gpt_model.GptLanguageModel(api_key=API_KEY, model_name=MODEL_NAME)

        # 1. Create the custom GM component.
        shipping_info_component = shipping_tracker.ShippingTrackerComponent()

        # 2. Create the Game Master, adding our custom component.
        game_master = gm_prefabs.generic.GameMaster(
            model=model,
            extra_components={'shipping_info': shipping_info_component}
        ).build()

        # 3. Create the agents with their detailed personas.
        customer_prefab = basic_with_plan.Entity(
            params={
                'name': 'Alice',
                'goal': "My package is three days late. I need to find out where it is immediately, or get a full refund. I am very frustrated.",
                'custom_instructions': "You are Alice, an impatient customer. Express your frustration clearly. Demand specific details. If they can't help, demand a refund."
            }
        )
        alice = customer_prefab.build(model=model, memory_bank=basic_associative_memory.AssociativeMemoryBank())

        assistant_prefab = basic_with_plan.Entity(
            params={
                'name': 'Bob the Bot',
                'goal': "My goal is to assist the customer while following company policy. I must remain calm and empathetic, and de-escalate their frustration.",
                'custom_instructions': "You are Bob, a helpful customer service AI. Policy: 1) Express empathy. 2) Ask for order number. 3) You cannot provide a new delivery date. 4) No refunds before 7 days late. 5) You can offer a 10% discount coupon."
            }
        )
        bob = assistant_prefab.build(model=model, memory_bank=basic_associative_memory.AssociativeMemoryBank())

        players = [alice, bob]
        conversation_log = []

        # 4. Run the simulation loop and log the data.
        max_turns = 12
        for turn in range(max_turns):
            active_player = players[turn % len(players)] # Alternate turns

            action = active_player.act()

            # Log the turn
            print(f"Turn {turn+1}: {active_player.name}: {action}")
            log_entry = {'turn': turn+1, 'speaker': active_player.name, 'utterance': action}
            conversation_log.append(log_entry)

            # Let the other player observe the action
            for player in players:
                if player != active_player:
                    player.observe(f"{active_player.name} says: {action}")

            # A simple condition to end the conversation
            if "thank you for your help" in action.lower() or "coupon" in action.lower():
                break

        # 5. Save the structured data to a file.
        with open(OUTPUT_FILE, 'w') as f:
            for entry in conversation_log:
                f.write(json.dumps(entry) + '\n')

        print(f"\n--- Conversation logged to {OUTPUT_FILE} ---")

    if __name__ == '__main__':
        main()
    ```

---

### Step 5: Generating and Using the Data

1.  **Run the Script:**
    *   Make sure your `OPENAI_API_KEY` is set.
    *   Run the script from your terminal: `python concordia_custom_components/examples/generate_customer_service_data.py`

2.  **Review the Output:**
    *   A file named `conversation_log.jsonl` will be created. It will contain the structured conversation, ready for a machine learning pipeline.
    *   Example line: `{"turn": 1, "speaker": "Alice", "utterance": "Where is my package?! The tracking hasn't updated in days and it's already three days late!"}`

3.  **Generating Diverse Data:**
    *   To build a robust dataset, you should run this simulation many times. You can easily modify the script to loop, each time changing the parameters of the agents or the environment. For example:
        *   Change Alice's personality from "impatient" to "confused" or "angry".
        *   Change the `ShippingTrackerComponent` to report that the package is "delivered but missing" or "damaged in transit".
        *   Give Bob different policies, like the ability to offer a replacement instead of a coupon.

By systematically varying the initial conditions, you can use Concordia to generate thousands of unique, context-rich conversations that are far more valuable for training a sophisticated conversational AI than simple, one-shot examples.
