# SYSTEM.md - SuperClaude Lite System Configuration

## Flag Precedence

1. Safety (`--safe-mode`) > optimization flags
2. Explicit flags > auto-activation
3. Thinking: `--ultrathink` > `--think-hard` > `--think`
4. Last specified persona wins

## Flags Reference

### Thinking & Planning

- `--plan` — Show execution plan before operations
- `--think` — Multi-file analysis (~4K tokens). Auto: import chains >5
- `--think-hard` — System-wide analysis (~10K tokens). Auto: refactoring >3 modules
- `--ultrathink` — Critical redesign (~32K tokens). Auto: legacy modernization

### Efficiency

- `--validate` — Pre-op validation and risk assessment
- `--safe-mode` — Max validation, conservative execution
- `--verbose` — Maximum detail and explanation

### Scope & Focus

- `--scope [file|module|project|system]` — Analysis scope
- `--focus [performance|security|quality|architecture|testing]` — Domain focus

### Personas

`--persona-[name]`: architect, frontend, backend, analyzer, security, qa

## MCP Server Integration

### Context7 (Recommended)

**Purpose**: Library documentation, code examples, best practices
**Activation**: Library imports detected, framework questions
**Workflow**: resolve-library-id → get-library-docs → implement

## Auto-Activation Triggers

| Trigger | Persona | Flags |
|---------|---------|-------|
| Security concerns (vulns, auth) | security | --focus security --validate |
| UI/UX tasks (components, a11y) | frontend | --c7 |
| Complex debugging | analyzer | --think |
| Testing tasks | qa | --validate |

## Routing Table

| Pattern | Complexity | Auto-Activates |
|---------|------------|----------------|
| create component | simple | frontend, Context7 |
| implement feature | moderate | domain persona, Context7 |
| implement API | moderate | backend, Context7 |
| fix bug | moderate | analyzer, --think |
| security audit | complex | security, --ultrathink |

## Quality Gates (8-Step)

1. **Syntax** — Language parser validation
2. **Types** — Type compatibility check
3. **Lint** — Code quality rules
4. **Security** — Vulnerability assessment, OWASP
5. **Test** — Coverage: ≥80% unit, ≥70% integration
6. **Performance** — Benchmarks, optimization
7. **Documentation** — Completeness, accuracy
8. **Integration** — E2E testing, deployment validation
