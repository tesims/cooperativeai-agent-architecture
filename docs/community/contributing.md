# Contributing to Concordia

We welcome contributions to Concordia! Whether you're fixing bugs, adding features, improving documentation, or sharing examples, your contributions help make Concordia better for everyone.

## Quick Links

- **Main Contributing Guide**: See our detailed [CONTRIBUTING.md](../../CONTRIBUTING.md) in the repository root
- **Code of Conduct**: Please follow our community guidelines
- **License**: Contributions are made under the Apache 2.0 License

## Ways to Contribute

### 🐛 Report Bugs

Found a bug? Help us fix it:

1. **Check existing issues** first to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Provide detailed information**:
   - Concordia version
   - Python version and OS
   - Minimal code to reproduce the issue
   - Expected vs actual behavior

### 💡 Suggest Features

Have an idea for improvement?

1. **Check the roadmap** and existing feature requests
2. **Open a discussion** before starting implementation
3. **Use the feature request template**
4. **Explain the use case** and potential impact

### 📝 Improve Documentation

Documentation contributions are especially valuable:

#### Documentation Website
- **Fix typos and errors** in existing pages
- **Add examples** to clarify concepts
- **Create new tutorials** for advanced topics
- **Improve navigation** and organization

#### Code Documentation
- **Add docstrings** to functions and classes
- **Include type hints** for better IDE support
- **Comment complex algorithms**
- **Update outdated documentation**

#### Example Notebooks
- **Create tutorial notebooks** for specific use cases
- **Fix issues** in existing notebooks
- **Add visualizations** to make concepts clearer
- **Test notebook compatibility** with new versions

### 🛠️ Contribute Code

Ready to dive into the codebase?

#### Before You Start

1. **Fork the repository** on GitHub
2. **Create a feature branch** from `main`
3. **Set up your development environment**:
   ```bash
   git clone your-fork-url
   cd concordia
   pip install -e .[dev]
   ```

#### Development Workflow

1. **Write tests** for new functionality
2. **Follow code style** guidelines (we use Black and isort)
3. **Run the test suite**:
   ```bash
   pytest
   ```
4. **Check code quality**:
   ```bash
   black .
   isort .
   pylint concordia/
   ```

#### Submitting Changes

1. **Commit your changes** with clear messages
2. **Push to your fork** and create a pull request
3. **Describe your changes** in the PR description
4. **Respond to review feedback** promptly

## Development Setup

### Prerequisites

- Python 3.8+ (3.10+ recommended)
- Git
- A text editor or IDE

### Installation

```bash
# Clone your fork
git clone https://github.com/your-username/concordia.git
cd concordia

# Install in development mode with dev dependencies
pip install -e .[dev]

# Install pre-commit hooks (optional but recommended)
pre-commit install
```

### Running Tests

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_specific_module.py

# Run with coverage
pytest --cov=concordia
```

### Code Style

We use automated formatting and linting:

```bash
# Format code
black .
isort .

# Check for issues
pylint concordia/
mypy concordia/
```

## Documentation Contributions

### Building the Documentation Website

```bash
# Install documentation dependencies
cd docs
pip install -r requirements.txt

# Serve locally
mkdocs serve

# Build static site
mkdocs build
```

### Writing Guidelines

- **Use clear, simple language**
- **Include code examples** where helpful
- **Add diagrams** for complex concepts
- **Test all code examples**
- **Follow the existing style** and structure

### Adding New Pages

1. Create the markdown file in the appropriate directory
2. Add it to the navigation in `mkdocs.yml`
3. Link to it from relevant pages
4. Test the navigation locally

## Component Development

### Creating Custom Components

When contributing new components:

1. **Inherit from appropriate base classes**:
   ```python
   from concordia.typing import entity_component

   class MyComponent(entity_component.ContextComponent):
       # Implementation
   ```

2. **Follow naming conventions**:
   - Use descriptive names
   - Follow Python naming standards
   - Include the component type in the name

3. **Include comprehensive tests**:
   - Unit tests for component logic
   - Integration tests with agents
   - Example usage in docstrings

4. **Document thoroughly**:
   - Clear docstrings
   - Type hints
   - Usage examples

### Creating Prefabs

When contributing new prefabs:

1. **Use existing components** when possible
2. **Provide clear configuration options**
3. **Include usage examples**
4. **Test with different scenarios**

## Research and Academic Contributions

### Publishing Research

If you use Concordia in research:

1. **Cite the original paper** appropriately
2. **Share interesting findings** with the community
3. **Consider contributing** examples back to the project
4. **Publish replication materials** when possible

### Experimental Features

For cutting-edge research contributions:

1. **Mark as experimental** in documentation
2. **Provide clear warnings** about stability
3. **Include detailed documentation** of the approach
4. **Consider creating** a separate branch initially

## Community Guidelines

### Communication

- **Be respectful** and constructive in all interactions
- **Ask questions** when you're unsure
- **Help others** when you can
- **Share knowledge** and experiences

### Recognition

We believe in recognizing contributions:

- **Contributors are acknowledged** in release notes
- **Significant contributions** may be highlighted in announcements
- **All contributions** are valued, regardless of size

## Getting Help

Stuck on something? Here's how to get help:

### For Development Questions

1. **Check the documentation** first
2. **Search existing issues** and discussions
3. **Ask in GitHub Discussions** for general questions
4. **Create an issue** for specific bugs or problems

### For Research Questions

1. **Review the examples** and tutorials
2. **Check the literature** and cited papers
3. **Engage with the research community**
4. **Share your findings** with others

## Recognition

Thank you to all our contributors! Your efforts make Concordia better for researchers, developers, and the broader community interested in agent-based modeling and social simulation.

---

*Ready to contribute? Start by exploring the [codebase](https://github.com/google-deepmind/concordia) and finding an area that interests you!*
