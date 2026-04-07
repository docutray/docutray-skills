## Purpose

Defines requirements for JSON schema design guidelines in the docutray-advanced skill.

## Requirements

### Requirement: JSON schema design guidelines
The SKILL.md SHALL include guidelines for designing JSON schemas optimized for LLM-based document extraction.

#### Scenario: Required and nullable pattern
- **WHEN** the agent designs a schema field
- **THEN** the guidelines SHALL recommend using `"type": ["string", "null"]` with `required` to ensure fields always appear in output

#### Scenario: Descriptive field descriptions
- **WHEN** defining field descriptions
- **THEN** the guidelines SHALL instruct agents to write descriptions that help the LLM locate and interpret values (e.g., position hints, expected format)

#### Scenario: Date and enum types
- **WHEN** defining date or fixed-value fields
- **THEN** the guidelines SHALL recommend `format: "date"` for dates and `enum` for known fixed values

#### Scenario: Tabular and repeating data
- **WHEN** defining line items or repeating data
- **THEN** the guidelines SHALL recommend using `array` with `items` for tabular/repeating structures

### Requirement: Detailed schema reference
A `references/schema-design-reference.md` file SHALL contain detailed JSON schema patterns, field type examples, and complex nesting patterns.

#### Scenario: Reference file exists and is cross-referenced
- **WHEN** the SKILL.md schema design section is read
- **THEN** it SHALL include a cross-reference to `@references/schema-design-reference.md`

#### Scenario: Reference covers field type combinations
- **WHEN** the reference file is read
- **THEN** it SHALL contain examples of string, number, date, enum, array, and object field types with nullable/required combinations
