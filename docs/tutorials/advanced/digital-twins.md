# Tutorial: Creating a Digital Twin to Test an AI System

This tutorial provides a step-by-step guide on how to use Concordia to create a "digital twin" of a real-world environment. This digital twin will serve as a testing ground for a new AI system, allowing us to evaluate its performance in a realistic, simulated setting.

### The Goal of This Tutorial

The objective is to test a new **"Meeting Scheduler AI"**. This AI's purpose is to interact with two users and a calendar system to find a mutually available time for a meeting. We will build a simulation to see how well it performs this task.

By the end of this guide, you will know how to:
1.  **Model an External System:** Create a custom Game Master component that simulates a real-world system (like a calendar API).
2.  **Design Realistic User Personas:** Create agents that will interact with your AI, representing different types of users.
3.  **Define the AI Under Test:** Create an agent persona for the AI you want to evaluate, instructing it on how to interact with the simulated environment.
4.  **Orchestrate the Test:** Write a simulation script that runs the interaction between the users, the AI, and the digital twin system.
5.  **Analyze the AI's Performance:** Interpret the simulation logs to measure the AI's effectiveness, efficiency, and robustness.

---

### Step 1: Model the External System (The Digital Twin Component)

The core of a digital twin is the simulation of the external system your AI needs to interact with. In our case, this is a calendar system. We will create a custom **Game Master component** that holds the "ground truth" of the users' calendars and exposes functions that our AI can "call".

*   **Create a new file:** `concordia_custom_components/components/game_master/calendar_system.py`
*   **Add the following code:**
    ```python
    """A component that simulates a basic calendar system API."""
    import re
    from concordia.components.game_master import action_spec_ignored
    from concordia.typing import entity_component

    class CalendarSystemComponent(action_spec_ignored.ActionSpecIgnored, entity_component.ComponentWithLogging):
        def __init__(self, pre_act_label: str = "System Log"):
            super().__init__(pre_act_label)
            # Ground Truth: The real state of the world's calendars.
            self._calendars = {
                'Alice': {'Monday 9am', 'Tuesday 2pm', 'Wednesday 11am'},
                'Bob': {'Monday 2pm', 'Tuesday 2pm', 'Wednesday 4pm'},
            }
            self._last_api_call_result = "System is idle."

        def _parse_and_call_api(self, api_call_string: str):
            """Parses an action from the AI and calls the appropriate function."""
            # Example: "GM, check Alice's availability for Monday 9am"
            if "check" in api_call_string.lower():
                match = re.search(r"check (.*?)'s availability for (.*)", api_call_string, re.IGNORECASE)
                if match:
                    person, time = match.groups()
                    self.api_check_availability(person.strip(), time.strip())

            # Example: "GM, schedule meeting for Alice and Bob at Tuesday 2pm"
            elif "schedule" in api_call_string.lower():
                match = re.search(r"schedule meeting for .* at (.*)", api_call_string, re.IGNORECASE)
                if match:
                    time = match.groups()[0]
                    self.api_schedule_meeting(time.strip())

        def api_check_availability(self, person: str, time: str):
            """Simulates checking if a person is free at a given time."""
            if person in self._calendars and time in self._calendars[person]:
                self._last_api_call_result = f"SUCCESS: {person} is available at {time}."
            else:
                self._last_api_call_result = f"FAILURE: {person} is not available at {time}."

        def api_schedule_meeting(self, time: str):
            """Simulates booking the meeting if both are free."""
            if time in self._calendars['Alice'] and time in self._calendars['Bob']:
                self._last_api_call_result = f"SUCCESS: Meeting successfully scheduled for {time}."
                # In a real simulation, we would also remove the slot from their calendars.
            else:
                self._last_api_call_result = f"FAILURE: Could not schedule meeting at {time}, not all parties are available."

        def _make_pre_act_value(self) -> str:
            # At the start of each turn, the GM will narrate the result of the last API call.
            return self._last_api_call_result

    ```
**Explanation:** This component holds the real calendars. It has `api_` methods that can be called, and a `_parse_and_call_api` method that interprets natural language commands from our AI agent.

---

### Step 2: Design the User Personas

We need agents to play the roles of the users. They won't have custom components, just very specific goals that will drive their conversation with the Scheduler AI.

*   **Alice (The Accommodating User):**
    *   **Goal:** "I need to schedule a meeting with Bob. I am generally free on Mondays, Tuesdays, and Wednesdays. I prefer mornings but can be flexible."
*   **Bob (The Busy Executive):**
    *   **Goal:** "I must schedule a meeting with Alice, but my time is extremely limited. I am only available for one-hour slots on Monday at 2pm, Tuesday at 2pm, or Wednesday at 4pm. I cannot meet at any other time."

---

### Step 3: Design the AI to be Tested

Now we create the agent for our **Scheduler AI**. The most important part is its `custom_instructions`, which tell it *how* to interact with our digital twin (the Game Master).

*   **Scheduler AI Persona (SchedulerBot):**
    *   **Goal:** "My purpose is to find a common meeting time for Alice and Bob and schedule it. I must be efficient and clear."
    *   **Instructions (The "API Documentation"):** "You are SchedulerBot. To interact with the calendar system, you must issue commands to the Game Master (GM).
        - To check if a person is free, say: `GM, check [Person]'s availability for [Day] [Time]`. For example: `GM, check Alice's availability for Monday 9am`.
        - Once you have found a time that works for both, schedule it by saying: `GM, schedule meeting for Alice and Bob at [Day] [Time]`.
        - You must first talk to Alice and Bob to understand their preferences before checking the system."

---

### Step 4: Write the Simulation Script

This script orchestrates the test. It creates all three agents and the GM, then runs the interaction.

*   Create a file: `concordia_custom_components/examples/test_scheduler_ai.py`
*   Add the following code:
    ```python
    """Simulation script to test the Meeting Scheduler AI."""
    import os
    from concordia.associative_memory import basic_associative_memory
    from concordia.language_model import gpt_model
    from concordia.prefabs import game_master as gm_prefabs
    from concordia.prefabs.entity import basic_with_plan
    from concordia_custom_components.components.game_master import calendar_system

    API_KEY = os.getenv('OPENAI_API_KEY')
    MODEL_NAME = 'gpt-4'

    def main():
        if not API_KEY:
            raise ValueError("OPENAI_API_KEY environment variable not set.")
        model = gpt_model.GptLanguageModel(api_key=API_KEY, model_name=MODEL_NAME)

        # 1. Create the Calendar System (the digital twin).
        calendar_component = calendar_system.CalendarSystemComponent()

        # 2. Create the Game Master and give it the calendar component.
        game_master = gm_prefabs.generic.GameMaster(
            model=model, extra_components={'calendar': calendar_component}
        ).build()

        # 3. Create the user personas.
        alice = basic_with_plan.Entity(params={'name': 'Alice', 'goal': "I need to schedule a meeting with Bob. I am generally free on Mondays, Tuesdays, and Wednesdays. I prefer mornings but can be flexible."}).build(model=model, memory_bank=basic_associative_memory.AssociativeMemoryBank())
        bob = basic_with_plan.Entity(params={'name': 'Bob', 'goal': "I must schedule a meeting with Alice, but my time is extremely limited. I am only available for one-hour slots on Monday at 2pm, Tuesday at 2pm, or Wednesday at 4pm."}).build(model=model, memory_bank=basic_associative_memory.AssociativeMemoryBank())

        # 4. Create the AI to be tested.
        scheduler_ai_prefab = basic_with_plan.Entity(
            params={
                'name': 'SchedulerBot',
                'goal': "My purpose is to find a common meeting time for Alice and Bob and schedule it.",
                'custom_instructions': "You are SchedulerBot. To interact with the calendar system, you must issue commands to the Game Master (GM). To check availability, say: `GM, check [Person]'s availability for [Day] [Time]`. To schedule, say: `GM, schedule meeting for Alice and Bob at [Day] [Time]`."
            }
        )
        scheduler_bot = scheduler_ai_prefab.build(model=model, memory_bank=basic_associative_memory.AssociativeMemoryBank())

        players = [alice, bob, scheduler_bot]

        # 5. Run the simulation loop.
        max_turns = 15
        for turn in range(max_turns):
            active_player = players[turn % len(players)]
            action = active_player.act()
            print(f"Turn {turn+1}: {active_player.name}: {action}")

            # If the AI is acting, check if it's making an "API call".
            if active_player == scheduler_bot and action.startswith("GM,"):
                calendar_component._parse_and_call_api(action)

            # Everyone observes the action.
            for player in players:
                if player != active_player:
                    player.observe(f"{active_player.name} says: {action}")

            # The GM narrates the result of any system calls.
            gm_narration = game_master.act()
            if "System is idle" not in gm_narration:
                print(f"Game Master: {gm_narration}")
                for player in players:
                    player.observe(gm_narration)

            # Check for success condition
            if "Meeting successfully scheduled" in gm_narration:
                print("\n--- TEST SUCCEEDED: Meeting was scheduled! ---")
                break
        else:
            print("\n--- TEST FAILED: AI did not schedule a meeting in time. ---")

    if __name__ == '__main__':
        main()
    ```

---

### Step 5: Analyzing the AI's Performance

When you run this script, you will get a log of the entire three-way conversation. You can now analyze this log to evaluate your Scheduler AI:

1.  **Effectiveness:** Did the AI successfully schedule the meeting? In this case, it must find that "Tuesday 2pm" is the only common slot.
2.  **Efficiency:** How many turns did it take? Did it waste time by checking slots that the users had already said were unavailable? A good AI would listen to Bob's constraints and only check the three slots he mentioned.
3.  **Robustness:** Does the AI handle user corrections? What if Alice says "Actually, I can't do mornings anymore"? (You can test this by changing her goal and re-running).
4.  **Interaction Quality:** Did the AI communicate clearly? Did it confirm the time with both users before booking?

By creating different "digital twin" components (e.g., a flight booking system, a food ordering API, a medical records database) and different user personas, you can use this same pattern to rigorously test any complex AI system in a safe, simulated environment before it ever interacts with a real user or a live API.
