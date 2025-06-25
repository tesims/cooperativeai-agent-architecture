# Tutorial: Getting Started with Concordia Development

This tutorial will guide you through setting up your Concordia development environment, running a simulation, and understanding where to add your own custom agents and components for your project.

### The Goal of This Tutorial
By the end of this guide, you will:
1.  Have a working local installation of the Concordia library.
2.  Understand the key directories and their purpose.
3.  Know how to run an existing simulation example.
4.  Clearly understand *where* to add your own code (components, prefabs, and examples) and *why*.

---

### Step 1: Initial Environment Setup

This step ensures the Concordia library and all its dependencies are correctly installed on your system.

**1. Clone the Repository (Already Done)**
You have already cloned the repository, so you're ready for the next step.

**2. Set Up a Python Virtual Environment**
A virtual environment is crucial for keeping your project's dependencies isolated from other Python projects.

In your terminal, at the root of the `concordia` directory, run:
```bash
# Create a virtual environment named 'venv'
python3 -m venv venv

# Activate the virtual environment
# On Mac/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate
```
You'll know it's active because your terminal prompt will change to show `(venv)`.

**3. Install Concordia in Editable Mode**
"Editable" mode is a special installation type for developers. It means that any changes you make to the source code will be immediately reflected when you run the code, without needing to reinstall.

With your virtual environment active, run:
```bash
pip install --editable .[dev]
```
The `.` refers to the current directory, and `[dev]` installs all the extra dependencies needed for development and testing.

**4. Set Up Your Language Model API Key**
Concordia's agents use a Large Language Model (LLM) for their "brains". You need to provide an API key for this to work. The examples are configured to use OpenAI's models.

Set your API key as an environment variable. An environment variable is a secure way to store sensitive keys without hardcoding them into your scripts.

In your terminal, run:
```bash
export OPENAI_API_KEY='your-key-here'
```
*(Note: This variable only lasts for your current terminal session. You may need to add it to your shell's startup file like `.bashrc` or `.zshrc` to make it permanent.)*

---

### Step 2: Understanding the Project Structure

Navigating a new codebase can be daunting. Here's a map of the most important directories:

```
concordia/
├── concordia/                  <-- The core library source code lives here.
│   ├── components/             <-- Individual 'behaviors' for agents.
│   │   └── agent/
│   ├── prefabs/                <-- 'Blueprints' for creating agents.
│   │   └── entity/
│   └── ...
├── examples/                   <-- Ready-to-run examples and tutorials.
│
└── concordia_custom_components/  <-- YOUR WORKSPACE for custom code.
    ├── components/
    │   └── agent/
    ├── prefabs/
    │   └── entity/
    └── examples/
```

*   `concordia/`: You will mostly be **reading** code here to understand how the framework works. Avoid editing these files directly.
*   `examples/`: These are excellent starting points. You can run them to see how Concordia works and copy them as templates for your own simulations.
*   `concordia_custom_components/`: This is where **you will write your code**. Keeping your work here makes it easy to manage and prevents conflicts with the core library code.

---

### Step 3: Running an Existing Example

Let's make sure your setup is working by running a pre-existing example. The `selling_cookies.ipynb` is a good one to start with. Since it is a Jupyter Notebook, the easiest way to run it is within VS Code if you have the Jupyter extension installed.

1.  Open the `examples/selling_cookies.ipynb` file in your editor.
2.  Select the `venv` kernel you created in Step 1.
3.  Run the cells one by one.

You should see the output of a simulation where agents interact to buy and sell cookies. This confirms that your environment is set up correctly and you can communicate with the LLM API.

---

### Step 4: Where to Add Your Code and Why

This is the most important part for your project. Here is the workflow for creating a new, custom agent and a clear explanation of what goes where.

Let's use your goal of creating a **"Promise-Keeping Agent"** as an example.

**1. Where to create the BEHAVIOR? -> `components`**

*   **What you do:** You need to define the *logic* of keeping a promise. This includes things like: What is a promise? How do I know if I've broken one? How does this affect my decisions? This logic is a **Component**.
*   **Where it goes:** `concordia_custom_components/components/agent/promise_keeping.py`
*   **Why:** You are creating a new, self-contained cognitive ability. The `components` directory is for these fundamental building blocks of behavior. By creating a `PromiseKeepingComponent`, you are making a reusable piece of "promise-keeping psychology" that you could potentially add to *any* agent in the future.

**2. Where to create the AGENT TYPE? -> `prefabs`**

*   **What you do:** Now you need to define what a "Promise-Keeping Agent" *is*. It's an agent that has standard abilities like memory and a plan, but *also* has your new `PromiseKeepingComponent`. This recipe for an agent is a **Prefab**.
*   **Where it goes:** `concordia_custom_components/prefabs/entity/promise_keeper.py`
*   **Why:** You are defining a new "character sheet" or "agent architecture". The `prefabs` directory is for these blueprints. The prefab's job is not to define the behavior itself, but to **assemble** the components (like your `PromiseKeepingComponent`) into a complete agent.

**3. Where to TEST your new agent? -> `examples`**

*   **What you do:** You've built the component and the prefab, now you need to see if it works! You'll write a script that sets up a small scenario, creates your Promise-Keeping Agent, gives it a reason to make a promise, and then checks if it tries to fulfill it. This is an **Example**.
*   **Where it goes:** `concordia_custom_components/examples/run_promise_keeper.py`
*   **Why:** The `examples` directory is your laboratory. It's where you run your experiments. This script will import your prefab, build the agent, and run a simulation to test the behavior you just created.

### Summary of the Development Workflow

The process for each of your custom agents (Negotiator, Reputation-Aware, etc.) will be the same:

1.  **Conceptualize:** What is the core logic or *behavior*?
    > "I need a way for an agent to track favors given and received."
2.  **Build the Component:** Create a `ReciprocityComponent` in `concordia_custom_components/components/agent/`.
3.  **Define the Agent:** What is an agent with this behavior?
    > "A 'Reciprocal Agent' is an agent with memory, a plan, and the `ReciprocityComponent`."
4.  **Build the Prefab:** Create a `ReciprocalAgent` prefab in `concordia_custom_components/prefabs/entity/`.
5.  **Test it:** How does this agent behave in a scenario?
    > "Let's create a simulation where one agent gives the Reciprocal Agent a gift and see if it tries to return the favor later."
6.  **Build the Example:** Write a `run_reciprocal_agent.py` script in `concordia_custom_components/examples/`.

By following this structure, you will be using the Concordia framework as it was intended and will keep your project organized and easy to build upon.
