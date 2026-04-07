---
name: docutray-advanced
description: >-
  Advanced DocuTray features: create custom document types, design extraction
  schemas, and build processing pipelines. Use this skill when creating a new
  document type, defining schema fields, configuring extraction rules, or
  setting up multi-step processing pipelines.
---

# DocuTray Advanced

Guide users through creating and managing custom document types for DocuTray. Assumes DocuTray is already set up (see `docutray-setup` skill) and the user is familiar with core commands (see `docutray-platform` skill).

## 1. Document Type Workflow

When a user wants to extract data from a document not covered by existing types, follow this decision tree:

### Step 1: Check Existing Types

Before creating anything, check what already exists:

```bash
# Search for types matching the document
docutray types list --search "invoice"

# Auto-detect the document type
docutray identify document.pdf
```

### Step 2: Decide — Create or Modify

Based on results:

- **High-confidence match** (identify confidence >= 0.9): Use the existing type directly with `docutray convert`
- **Partial match** (0.7–0.9 or similar type exists): Ask the user — modify the existing type or create a new one?
- **No match** (< 0.7 or no relevant types): Proceed to create a new document type

Ask the user explicitly:
> "I found a type called `purchase_order` that's similar. Would you like to modify it for your needs, or create a new document type?"

### Step 3: Route to Create or Modify

- **Create new** → Follow Section 2 (Creating Document Types)
- **Modify existing** → Follow Section 4 (Modifying Document Types)

## 2. Creating Document Types

Guide the user through progressive steps. **Do not ask all questions at once** — gather information incrementally.

### Stage 1: Name and Code

Ask the user for:
- **Name**: Human-readable (e.g., "Purchase Order")
- **Code**: Machine identifier, snake_case (e.g., `purchase_order`)
- **Description**: One sentence explaining the document type

### Stage 2: Main Fields

Ask: "What are the main fields you need to extract from this document?"

For each field, determine:
- Field name (snake_case)
- Type (`string`, `number`, `date`, `enum`, `boolean`)
- Whether it's required
- A description that helps the LLM find and interpret the value

Example prompt to user:
> "What are the 3-5 most important fields in this document? For each, tell me the name and what kind of value it holds (text, number, date, etc.)"

### Stage 3: Additional Fields and Tabular Data

After main fields are confirmed, ask:
> "Are there any additional fields? Does this document have line items, rows, or other repeating data?"

For tabular/repeating data, use `array` type with `items` defining the row structure.

### Stage 4: Prompt Hints

Ask about document-specific conventions:
> "Are there any special formatting conventions? For example: date format (DD/MM/YYYY vs MM/DD/YYYY), number format (comma vs period for decimals), or language?"

See Section 5 for prompt hints details.

### Stage 5: Review and Execute

Present the complete schema to the user for review before executing:

```bash
# Save schema to a file first
cat > my_type_schema.json << 'EOF'
{
  "type": "object",
  "required": ["invoice_number", "date", "total"],
  "properties": {
    "invoice_number": {
      "type": ["string", "null"],
      "description": "Unique invoice identifier, typically at top of page"
    },
    "date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Invoice issue date"
    },
    "total": {
      "type": ["number", "null"],
      "description": "Total amount due, bottom-right of page"
    }
  }
}
EOF

# Create the document type
docutray types create \
  --name "My Invoice" \
  --code my_invoice \
  --description "Custom invoice format for Acme Corp" \
  --schema my_type_schema.json \
  --prompt-hints "Dates are in DD/MM/YYYY format. Amounts use comma as decimal separator." \
  --identify-hints "This is an Acme Corp invoice, identified by the logo in the top-left corner."
```

### Stage 6: Test

After creation, test with a real document:

```bash
docutray convert sample-document.pdf --type my_invoice
```

Review the output with the user and iterate on the schema if needed.

> **Details:** @references/document-type-workflow-reference.md — detailed decision tree, progressive disclosure steps, multi-document handling, example interactions

## 3. Schema Design

Design JSON schemas that help the LLM extract data accurately.

### Key Principles

**Use required + nullable for all fields:**

```json
{
  "required": ["field_name"],
  "properties": {
    "field_name": {
      "type": ["string", "null"]
    }
  }
}
```

This ensures the field always appears in output (`required`) but accepts missing values gracefully (`null`). Prefer this over optional fields.

**Write LLM-friendly descriptions:**

Descriptions guide the extraction model. Include:
- Where to find the value on the document
- Expected format or pattern
- Disambiguation when similar values exist

```json
{
  "invoice_number": {
    "type": ["string", "null"],
    "description": "Invoice number, top-right corner, format: INV-XXXX-XXX"
  },
  "total_amount": {
    "type": ["number", "null"],
    "description": "Grand total including tax, bottom of page, after 'TOTAL DUE'"
  }
}
```

**Use appropriate types:**

| Data | JSON Schema Type | Notes |
|------|-----------------|-------|
| Text | `"type": ["string", "null"]` | Default for most fields |
| Numbers | `"type": ["number", "null"]` | Amounts, quantities, percentages |
| Dates | `"type": ["string", "null"], "format": "date"` | Outputs ISO 8601 (YYYY-MM-DD) |
| Fixed values | `"type": ["string", "null"], "enum": [...]` | Status, category, payment method |
| Yes/No | `"type": ["boolean", "null"]` | Checkbox fields |

**Use arrays for tabular data:**

```json
{
  "line_items": {
    "type": ["array", "null"],
    "description": "Table of purchased items",
    "items": {
      "type": "object",
      "properties": {
        "description": { "type": ["string", "null"] },
        "quantity": { "type": ["number", "null"] },
        "unit_price": { "type": ["number", "null"] },
        "total": { "type": ["number", "null"] }
      }
    }
  }
}
```

> **Details:** @references/schema-design-reference.md — complete field type examples, nullable/required combinations, nested objects, enum patterns, complex schema examples

## 4. Modifying Document Types

To modify an existing document type:

### Step 1: Retrieve Current Schema

```bash
# View current type definition
docutray types get my_invoice

# Export schema to file for editing
docutray types export my_invoice --output current_schema.json
```

### Step 2: Edit and Update

Modify the exported schema file, then update:

```bash
# Update schema
docutray types update my_invoice --schema updated_schema.json

# Update prompt hints
docutray types update my_invoice --prompt-hints "Updated: dates are now in YYYY-MM-DD format."

# Update identify hints
docutray types update my_invoice --identify-hints "Acme Corp invoice v2, new logo format."
```

### Step 3: Test Changes

```bash
docutray convert sample-document.pdf --type my_invoice
```

Compare output against the previous version to verify improvements.

## 5. Prompt Hints

Prompt hints provide document-wide context to the extraction model. They complement field-level descriptions with global instructions.

### promptHints

Used during extraction (`convert`). Tell the model about document conventions:

```bash
docutray types create ... \
  --prompt-hints "Dates are in DD/MM/YYYY format. Amounts use period as thousand separator and comma as decimal separator (e.g., 1.234,56). All text is in Spanish."
```

**Common prompt hints:**

| Hint | Example |
|------|---------|
| Date format | `"Dates are DD/MM/YYYY"` |
| Decimal separator | `"Comma is decimal separator (1.234,56)"` |
| Thousand separator | `"Period is thousand separator"` |
| Language/locale | `"Document is in Portuguese (Brazil)"` |
| Multi-page | `"Summary table is on the last page"` |
| Layout | `"Two-column layout, read left column first"` |

### identifyPromptHints

Used during identification (`identify`). Help distinguish this type from similar documents:

```bash
docutray types create ... \
  --identify-hints "This is an Acme Corp purchase order. Distinguished by: Acme logo top-left, PO number starting with 'PO-', and 'Purchase Order' title in header."
```

**Effective identify hints include:**
- Visual markers (logos, headers, watermarks)
- Unique identifiers (numbering patterns, specific labels)
- Distinguishing features from similar document types

## 6. Multi-Document Files

Some files contain multiple document types (e.g., a PDF with an invoice and a packing slip).

### Handling Strategy

1. **Ask the user** if pages contain different document types
2. **Create separate types** for each document type in the file
3. **Document the relationship** in descriptions and prompt hints

```bash
# Create the primary type
docutray types create \
  --name "Shipping Bundle - Invoice" \
  --code shipping_bundle_invoice \
  --schema invoice_schema.json \
  --prompt-hints "This is the invoice portion of a shipping bundle. Usually pages 1-2."

# Create the secondary type
docutray types create \
  --name "Shipping Bundle - Packing Slip" \
  --code shipping_bundle_packing_slip \
  --schema packing_slip_schema.json \
  --prompt-hints "This is the packing slip portion. Usually the last page."
```

For files where the same type repeats (e.g., multiple invoices in one PDF), use a single type — DocuTray handles repeated extraction automatically.

> **Details:** @references/document-type-workflow-reference.md — detailed multi-document strategies and examples

## 7. CLI Command Reference

| Command | Description |
|---------|-------------|
| `docutray types list [--search <term>]` | List available document types |
| `docutray types get <code>` | Get type details and schema |
| `docutray types export <code> [--output <file>]` | Export schema as JSON |
| `docutray types create --name --code --schema [--description] [--prompt-hints] [--identify-hints]` | Create new type |
| `docutray types update <code> [--schema] [--prompt-hints] [--identify-hints]` | Update existing type |
| `docutray identify <file>` | Auto-detect document type |
| `docutray convert <file> --type <code>` | Convert using a type |

## Scope Note

This skill covers document type creation and schema design. The following are **not covered** in this version:
- Validation rules (`dslRules`, `validationRules`)
- Conversion spec (`conversionSpec`) and advanced `conversionMode`
- Processing pipeline creation (see `docutray-platform` skill for running existing pipelines)
