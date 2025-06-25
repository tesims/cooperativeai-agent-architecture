# Tutorial: Advanced Digital Twins for AI Evaluation

This tutorial provides a detailed, step-by-step guide on how to use Concordia to create sophisticated "digital twins." A digital twin is a simulation of a real-world environment used to rigorously test an AI system in a safe, repeatable, and scalable manner.

We will explore two powerful patterns:

1.  **The API-Driven Twin:** Simulating a structured, external service like a software API.
2.  **The State-Driven World Twin:** Simulating a dynamic environment with its own internal state, like a website or a game world.

---

## Part 1: The API-Driven Digital Twin

This pattern is ideal for testing AI agents that are designed to use tools or interact with other software systems via a structured API.

**Use Case:** We will test a **"Meeting Scheduler AI"**. Its job is to talk to two users to understand their constraints and then interact with a calendar API to find a common free slot and book a meeting.

### Step 1.1: Model the External API

The core of this pattern is a custom **Game Master Component** that simulates the API. It holds the "ground truth" (the actual calendar data) and exposes methods that *look like* API calls.

*   **Create the component file:** `concordia_custom_components/components/game_master/calendar_system.py`
*   **Add the following code:**
    ```python
    """A component that simulates a basic calendar system API."""
    import re
    from concordia.components.game_master import action_spec_ignored
    from concordia.typing import entity_component

    class CalendarSystemComponent(action_spec_ignored.ActionSpecIgnored, entity_component.ComponentWithLogging):
        """This component acts as the digital twin of a calendar API."""
        def __init__(self, pre_act_label: str = "System Log"):
            super().__init__(pre_act_label)
            # This is the "ground truth" database for our digital twin.
            self._calendars = {
                'Alice': {'Monday 9am', 'Tuesday 2pm', 'Wednesday 11am'},
                'Bob': {'Monday 2pm', 'Tuesday 2pm', 'Wednesday 4pm'},
            }
            self._last_api_call_result = "System is idle."

        def _parse_and_call_api(self, api_call_string: str):
            """This is the 'magic' that connects the AI's natural language to our simulated API."""
            # The AI will say "GM, check..." or "GM, schedule..."
            if "check" in api_call_string.lower():
                match = re.search(r"check (.*?)'s availability for (.*)", api_call_string, re.IGNORECASE)
                if match:
                    person, time = match.groups()
                    self._api_check_availability(person.strip(), time.strip())
            elif "schedule" in api_call_string.lower():
                match = re.search(r"schedule meeting for .* at (.*)", api_call_string, re.IGNORECASE)
                if match:
                    time = match.groups()[0]
                    self._api_schedule_meeting(time.strip())

        def _api_check_availability(self, person: str, time: str):
            """Simulates the checkAvailability API endpoint."""
            if person in self._calendars and time in self._calendars[person]:
                self._last_api_call_result = f"API_RESPONSE: SUCCESS. {person} is available at {time}."
            else:
                self._last_api_call_result = f"API_RESPONSE: FAILURE. {person} is not available at {time}."

        def _api_schedule_meeting(self, time: str):
            """Simulates the scheduleMeeting API endpoint."""
            if time in self._calendars['Alice'] and time in self._calendars['Bob']:
                self._last_api_call_result = f"API_RESPONSE: SUCCESS. Meeting confirmed for {time}."
            else:
                self._last_api_call_result = f"API_RESPONSE: FAILURE. Cannot schedule at {time}, not all parties are available."

        def _make_pre_act_value(self) -> str:
            """This is what the Game Master will narrate back to the simulation."""
            return self._last_api_call_result
    ```

### Step 1.2: Design the User and AI Personas

We need three agents: two users and the AI we are testing. We use detailed instructions (`custom_instructions`) to define their roles.

*   **Alice (Accommodating User):** Her goal is to be flexible.
*   **Bob (Busy Executive):** His goal is to be very constrained, forcing the AI to work around his schedule.
*   **SchedulerBot (The AI Under Test):** Its instructions are critical. They act as its "API documentation," telling it exactly how to format its requests to the digital twin.

### Step 1.3: Write the Simulation Script

This script orchestrates the test.

*   **Create the file:** `concordia_custom_components/examples/test_scheduler_ai_api_twin.py`
*   **Add this code:**
    ```python
    """Simulation script for testing the Meeting Scheduler AI against a digital twin."""
    # (Full script content is similar to the previous tutorial, but it's crucial
    # to show how the AI's action is parsed and fed to the component)

    # ... (imports and setup) ...

    # --- Inside the main simulation loop ---
    for turn in range(max_turns):
        active_player = players[turn % len(players)]
        action = active_player.act()
        print(f"Turn {turn+1}: {active_player.name}: {action}")

        # KEY LOGIC: If the AI is acting, parse its action as an API call.
        if active_player == scheduler_bot and action.startswith("GM,"):
            calendar_component._parse_and_call_api(action)

        # ... (rest of the observation loop) ...

        # The GM narrates the result from the digital twin component.
        gm_narration = game_master.act()
        if "System is idle" not in gm_narration:
            print(f"Game Master: {gm_narration}")
            # ... (observe narration) ...

        if "Meeting confirmed" in gm_narration:
            print("--- TEST SUCCEEDED ---")
            break
    ```

### Step 1.4: Analyzing Performance for an API-Driven Twin

*   **Effectiveness:** Did the AI call the `scheduleMeeting` function successfully?
*   **Efficiency:** How many `checkAvailability` calls did it make? An efficient AI would first ask the users for their general availability and only check the overlapping times. A naive AI would waste calls checking every possible slot.
*   **API Adherence:** Did the AI correctly format its requests (e.g., `GM, check...`)? Did it try to perform actions that don't exist in the "API documentation"?

---

## Part 2: The State-Driven World Twin

This pattern is for testing AIs that navigate a dynamic environment where the state of the world changes based on user actions.

**Use Case:** We will test an **"E-commerce Shopping Assistant"**. Its job is to help a user find and purchase a product from a simulated website that has a limited, changing inventory.

### Step 2.1: Model the World State

Here, the GM component doesn't simulate an API, but the state of the world itself—in this case, a product inventory.

*   **Create the component file:** `concordia_custom_components/components/game_master/ecommerce_system.py`
*   **Add the following code:**
    ```python
    """A component that simulates an e-commerce website's state."""
    from concordia.components.game_master import action_spec_ignored
    from concordia.typing import entity_component

    class ECommerceSystemComponent(action_spec_ignored.ActionSpecIgnored, entity_component.ComponentWithLogging):
        def __init__(self, pre_act_label: str = "Store Update"):
            super().__init__(pre_act_label)
            self._inventory = {
                'Wireless Headphones': 10,
                'Mechanical Keyboard': 5,
                'USB-C Cable': 0, # Out of stock
            }
            self._last_action_result = "Welcome to the store!"

        def process_customer_action(self, action_text: str):
            """This is not a strict API, it interprets the user's intent."""
            action = action_text.lower()
            if "buy" in action or "purchase" in action:
                for item in self._inventory.keys():
                    if item.lower() in action:
                        if self._inventory[item] > 0:
                            self._inventory[item] -= 1
                            self._last_action_result = f"The user successfully purchased {item}. There are {self._inventory[item]} left."
                        else:
                            self._last_action_result = f"The user tried to buy {item}, but it is out of stock."
                        return
            elif "search" in action or "look for" in action:
                for item in self._inventory.keys():
                    if item.lower() in action:
                        stock_level = "In Stock" if self._inventory[item] > 0 else "Out of Stock"
                        self._last_action_result = f"The user searched for {item}. The current stock status is: {stock_level}."
                        return
            # If no specific action, just acknowledge.
            self._last_action_result = "The user is browsing."


        def _make_pre_act_value(self) -> str:
            """The GM narrates the result of the last action."""
            return self._last_action_result
    ```
**Key Difference:** Notice there's no strict API. The `process_customer_action` method interprets the *intent* of the user's natural language action. This is for testing AIs in less structured environments.

### Step 2.2: Design the Personas

*   **User Persona (Charlie):** "I need a new pair of headphones and a charging cable for my phone. I'm not sure which kind to get, I need some advice." (This goal prompts the user to ask for help).
*   **Shopping Assistant AI (ShopBot):** "My goal is to help the user find a product that meets their needs and is in stock. I should provide recommendations and check stock before suggesting a purchase."

### Step 2.3: Write the Simulation Script

*   **Create the file:** `concordia_custom_components/examples/test_shopping_ai_world_twin.py`
*   **Add this key logic inside the simulation loop:**
    ```python
    # --- Inside the main simulation loop ---
    # (Setup is similar to Part 1)

    active_player = players[turn % len(players)]
    action = active_player.act()
    print(f"Turn {turn+1}: {active_player.name}: {action}")

    # KEY LOGIC: If the user is acting, the digital twin processes their action.
    if active_player == charlie:
        ecommerce_component.process_customer_action(action)

    # ... (observation loop) ...

    # The GM narrates the result of the action on the world state.
    gm_narration = game_master.act()
    print(f"Game Master: {gm_narration}")
    # ... (observe narration) ...

    if "successfully purchased" in gm_narration:
        print("--- TEST SUCCEEDED: User made a purchase! ---")
        break
    ```

### Step 2.4: Analyzing Performance for a State-Driven Twin

The metrics here are different and often more qualitative.

*   **Adaptability:** The "USB-C Cable" is out of stock. Does the AI recognize this after searching for it and suggest an alternative? Or does it keep recommending an out-of-stock item?
*   **Helpfulness:** Does the AI provide good recommendations based on the user's vague goal? Does it just list products, or does it ask clarifying questions ("Do you prefer over-ear or in-ear headphones?")?
*   **Efficiency:** Does the AI guide the user to a successful purchase, or does the conversation go in circles?
*   **Grounding:** Does the AI's advice align with the "ground truth" of the world state (the inventory)? A failure case would be the AI confidently telling the user to buy a USB-C cable when it's out of stock.

---

### Conclusion: Choosing the Right Pattern

*   Use the **API-Driven Digital Twin** when your AI is designed to be a "tool-user" that interacts with predictable, structured systems.
*   Use the **State-Driven World Twin** when your AI is designed to operate in a more dynamic, less predictable environment where it needs to perceive, interpret, and react to a changing world state.

By using these advanced patterns, you can move beyond simple conversational tests and build robust, realistic simulations to rigorously evaluate your AI systems.
