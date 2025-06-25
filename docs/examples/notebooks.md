# Jupyter Notebook Examples

Explore Concordia through interactive Jupyter notebooks that demonstrate key concepts and provide hands-on learning experiences.

## Available Notebooks

### 🚀 Getting Started

#### [Tutorial Notebook](../../examples/tutorial.ipynb)
**Perfect for beginners** - A comprehensive introduction to Concordia that walks through:

- Setting up your first simulation environment
- Creating basic agents with different personalities
- Running a social scenario (friends stuck in a snowed-in pub)
- Understanding the act-observe cycle
- Analyzing simulation outcomes

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.sandbox.google.com/github/google-deepmind/concordia/blob/main/examples/tutorial.ipynb)

### 🧠 Agent Development

#### [Actor Development](../../examples/actor_development.ipynb)
**Intermediate level** - Deep dive into creating sophisticated agents:

- Advanced component composition
- Custom behavior implementation
- Agent personality design
- Memory and planning systems
- Testing agent behaviors

#### [Alice Example](../../examples/alice.ipynb)
**Character study** - Detailed example of building a specific character:

- Character-driven agent design
- Personality trait implementation
- Contextual behavior adaptation
- Social interaction patterns

### 🏪 Real-World Scenarios

#### [Selling Cookies](../../examples/selling_cookies.ipynb)
**Business simulation** - Economic interaction modeling:

- Multi-agent market dynamics
- Negotiation behaviors
- Economic decision-making
- Supply and demand simulation
- Transaction processing

### 📋 Research Applications

#### [Questionnaire v2 Example](../../examples/questionnaire_v2_example.ipynb)
**Advanced research tool** - Psychology and social science applications:

- Survey and questionnaire administration to agents
- Response pattern analysis
- Behavioral consistency measurement
- Large-scale data collection
- Statistical analysis of agent responses

## Running the Notebooks

### Option 1: Google Colab (Recommended for Beginners)

Click the "Open in Colab" button on any notebook to run it in your browser with no setup required.

### Option 2: Local Jupyter

1. **Install Jupyter and dependencies:**
   ```bash
   pip install jupyter notebook matplotlib pandas
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/google-deepmind/concordia.git
   cd concordia
   ```

3. **Start Jupyter:**
   ```bash
   jupyter notebook examples/
   ```

### Option 3: VS Code

1. Install the Jupyter extension for VS Code
2. Open the notebook files directly in VS Code
3. Run cells interactively

## Learning Path

We recommend following this sequence for optimal learning:

1. **Start Here**: [Tutorial Notebook](../../examples/tutorial.ipynb)
   - Get familiar with basic concepts
   - Understand the simulation flow
   - See a complete example

2. **Character Building**: [Alice Example](../../examples/alice.ipynb)
   - Learn detailed character creation
   - Understand personality modeling
   - Practice component customization

3. **Advanced Behaviors**: [Actor Development](../../examples/actor_development.ipynb)
   - Explore complex agent architectures
   - Implement custom components
   - Test sophisticated behaviors

4. **Real Applications**: Choose based on your interest:
   - **Economics**: [Selling Cookies](../../examples/selling_cookies.ipynb)
   - **Research**: [Questionnaire v2](../../examples/questionnaire_v2_example.ipynb)

## Notebook Features

### Interactive Exploration

Each notebook includes:

- **Live code execution** - Modify and run examples instantly
- **Visualization** - See simulation results graphically
- **Parameter tuning** - Experiment with different settings
- **Output analysis** - Examine agent behaviors and outcomes

### Educational Content

- **Step-by-step explanations** of key concepts
- **Code comments** explaining implementation details
- **Best practices** and common pitfalls
- **Extension suggestions** for further exploration

## Creating Your Own Notebooks

Want to create your own Concordia notebook? Here's a template structure:

```python
# 1. Import required libraries
import concordia
from concordia.agents import entity_agent
from concordia.components.agent import v2 as agent_components

# 2. Set up your simulation environment
# [Your environment setup code]

# 3. Create agents with specific behaviors
# [Your agent creation code]

# 4. Run the simulation
# [Your simulation loop]

# 5. Analyze and visualize results
# [Your analysis code]
```

### Tips for Notebook Development

1. **Start simple** - Begin with basic scenarios before adding complexity
2. **Document thoroughly** - Explain your design decisions
3. **Include visualizations** - Help readers understand the results
4. **Test incrementally** - Verify each component works before combining
5. **Share with the community** - Consider contributing your notebook back to the project

## Community Contributions

We welcome notebook contributions! If you've created an interesting example:

1. Fork the repository
2. Add your notebook to the `examples/` directory
3. Include clear documentation and comments
4. Submit a pull request

### Contribution Guidelines

- **Clear learning objective** - What will users learn?
- **Well-documented code** - Explain complex concepts
- **Reproducible results** - Include seed values for consistency
- **Appropriate scope** - Not too simple, not too complex
- **Test thoroughly** - Ensure the notebook runs from start to finish

## Troubleshooting

### Common Issues

**Notebook won't run**
- Check that all dependencies are installed
- Verify your API keys are set correctly
- Ensure you have sufficient API quota

**Slow execution**
- Reduce the number of simulation steps
- Use smaller agent populations
- Consider using local models for development

**Memory errors**
- Clear intermediate variables
- Restart the kernel periodically
- Reduce the simulation complexity

### Getting Help

- Check the [GitHub Issues](https://github.com/google-deepmind/concordia/issues) for known problems
- Review the [Support page](../community/support.md) for additional resources
- Join community discussions to share experiences

---

*Ready to start exploring? Begin with the [Tutorial Notebook](../../examples/tutorial.ipynb) and work your way through the examples!*
