# Installation Guide

This guide will help you install Concordia and get your development environment ready.

## Prerequisites

Before installing Concordia, ensure you have:

- **Python 3.8 or higher** (Python 3.10+ recommended)
- **pip** (Python package installer)
- **git** (for development installation)

## Installation Methods

### Option 1: Install from PyPI (Recommended)

The easiest way to install Concordia is from PyPI:

```bash
pip install gdm-concordia
```

### Option 2: Development Installation

For development or to access the latest features:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/google-deepmind/concordia.git
   cd concordia
   ```

2. **Install in editable mode:**
   ```bash
   pip install --editable .[dev]
   ```

3. **Verify installation (optional):**
   ```bash
   pytest --pyargs concordia
   ```

## LLM API Requirements

Concordia requires access to a Large Language Model API. You have several options:

### OpenAI API
```bash
pip install openai
export OPENAI_API_KEY="your-api-key-here"
```

### Google AI (Gemini)
```bash
pip install google-generativeai
export GOOGLE_API_KEY="your-api-key-here"
```

### Anthropic Claude
```bash
pip install anthropic
export ANTHROPIC_API_KEY="your-api-key-here"
```

### Local Models
You can also use local models with frameworks like:
- **Ollama**: For running models locally
- **Hugging Face Transformers**: For open-source models
- **vLLM**: For high-performance serving

## Optional Dependencies

### For Enhanced Examples
```bash
pip install jupyter notebook matplotlib pandas
```

### For Development
```bash
pip install pytest black isort mypy
```

## Docker Installation

If you prefer using Docker:

```bash
# Clone the repository
git clone https://github.com/google-deepmind/concordia.git
cd concordia

# Use the provided devcontainer
# This works with VS Code, GitHub Codespaces, or any devcontainer-compatible environment
```

## Verification

Test your installation by running a simple script:

```python
import concordia
from concordia.agents import entity_agent
from concordia.associative_memory import associative_memory

print(f"Concordia version: {concordia.__version__}")
print("✓ Concordia installed successfully!")
```

## Troubleshooting

### Common Issues

**Import Error: No module named 'concordia'**
- Ensure you've activated the correct Python environment
- Try reinstalling with `pip install --upgrade gdm-concordia`

**LLM API Issues**
- Verify your API keys are set correctly
- Check your internet connection for cloud APIs
- Ensure you have sufficient API credits/quota

**Permission Errors**
- Use `pip install --user gdm-concordia` for user-only installation
- Consider using a virtual environment

### Getting Help

If you encounter issues:

1. Check the [GitHub Issues](https://github.com/google-deepmind/concordia/issues)
2. Review the [FAQ section](../community/support.md)
3. Join the community discussions

## Next Steps

Now that you have Concordia installed:

1. 📖 Learn about [Core Concepts](../core-concepts/framework-overview.md)
2. 🚀 Try the [Quick Start Guide](quick-start.md)
3. 🏗️ Build [Your First Simulation](../tutorials/basic/creating-simulation.md)

---

*Installation complete? Let's start building! Head to the [Quick Start Guide](quick-start.md) to create your first Concordia simulation.*
