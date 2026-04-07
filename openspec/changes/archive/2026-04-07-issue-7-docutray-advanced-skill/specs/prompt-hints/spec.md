## ADDED Requirements

### Requirement: promptHints usage documented
The SKILL.md SHALL document how to use `promptHints` for document-wide extraction instructions.

#### Scenario: promptHints examples
- **WHEN** the agent reads the prompt hints section
- **THEN** it SHALL find examples covering date formats, decimal separators, and thousand separators

#### Scenario: promptHints flag in CLI
- **WHEN** the agent needs to set prompt hints via CLI
- **THEN** the skill SHALL document the `--prompt-hints` flag on `types create` and `types update`

### Requirement: identifyPromptHints usage documented
The SKILL.md SHALL document how to use `identifyPromptHints` to improve document type identification.

#### Scenario: identifyPromptHints examples
- **WHEN** the agent reads the identify hints section
- **THEN** it SHALL find examples of hints that help distinguish similar document types

#### Scenario: identifyPromptHints flag in CLI
- **WHEN** the agent needs to set identify hints via CLI
- **THEN** the skill SHALL document the `--identify-hints` flag on `types create` and `types update`
