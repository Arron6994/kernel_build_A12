# Contributing to Zeus Kernel Build

Thank you for your interest in contributing to the Zeus Kernel Build project! 

## Quick Start

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/kernel_build_A12.git
cd kernel_build_A12

# Validate environment
./scripts/validate.sh

# Setup development environment
./scripts/setup.sh
```

## Guidelines

### Code Style
- Follow existing shell script conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

### Testing
- Test on actual hardware when possible
- Validate scripts with shellcheck
- Run environment validation before committing
- Test both successful and error scenarios

### Documentation
- Update README.md for user-facing changes
- Document new configuration options
- Add inline comments for complex code
- Update help text for new options

### Commit Messages
```
type: brief description

Longer explanation if needed

- List specific changes
- Reference issues: Fixes #123
```

Types: feat, fix, docs, style, refactor, test, chore

## Pull Request Process

1. **Before submitting:**
   - Run `./scripts/validate.sh`
   - Test build process
   - Update documentation
   - Add appropriate tests

2. **PR description should include:**
   - What changes were made
   - Why the changes were needed
   - How to test the changes
   - Any breaking changes

3. **Review process:**
   - Maintainers will review your PR
   - Address feedback promptly
   - Keep PR focused and atomic

## Questions?

Feel free to:
- Open an issue for bugs or feature requests
- Start a discussion for questions
- Contact maintainers for urgent matters

Thank you for contributing! 🚀