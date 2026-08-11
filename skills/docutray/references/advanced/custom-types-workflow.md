# Custom document type workflow — detailed reference

This file is the playbook agents follow when guiding a user through creating or modifying a document type. CLI commands are documented against `@docutray/cli/0.4.0` — run `docutray types create --help` / `docutray types update --help` to confirm.

## Decision tree

```
User wants to extract data from a document
│
├─ Run: docutray types list --search "<keywords>"
├─ Run: docutray identify <file>
│
├─ Match found (confidence >= 0.9)?
│  ├─ YES → Use existing: docutray convert <file> -t <code>
│  └─ NO ↓
│
├─ Similar type exists (0.7–0.9 or keyword match)?
│  ├─ YES → Ask user: modify existing or create new?
│  │  ├─ MODIFY → "Modifying types" workflow below
│  │  └─ CREATE → "Creating types" workflow below
│  └─ NO  → "Creating types" workflow below
│
└─ Done: convert document using the (new or existing) type
```

## Progressive disclosure flow

The principle: **gather information in stages, not all at once.** It prevents overwhelming users and lets the agent make informed suggestions.

### Stage 1: Get and read an example document

**Always ask for an example document before designing a schema.** The agent reads the actual file to discover the real fields, their positions, and their formats — that produces far better extraction descriptions than a verbal description ever could.

**Agent asks:**
> "Can you share an example of this document? I'll read it to understand its structure before we design the schema."

**Agent actions:**
1. **Read the document with your own file/vision tool.** Most coding agents (Claude Code, Cursor, Codex) can open PDFs and images directly — use that native capability to inspect the sample's layout, fields, and any tables. Do **not** rely on `docutray convert`/`identify` to "see" the document for schema design; read it yourself.
2. Check for an existing matching type while you're at it:
   ```bash
   docutray types list --search "<document keywords>"
   docutray identify sample-document.pdf --types <candidate-codes>
   ```

**Gather (from reading + a short confirmation):**
- Document type (invoice, receipt, form, report, …)
- General purpose (what data needs extracting)
- The actual fields, locations, formats, and tables visible in the sample

**No sample available?** Warn the user that the schema will be **tentative** and must be validated against a real document later, then fall back to gathering fields by description (Stages 3–4 as a verbal Q&A). Do not block — just flag the schema as unverified until a real document is run through it.

### Stage 2: Name and identity

**Agent asks:**
> "Let's set up the document type. What would you like to call it? I'll also need a short code (like `purchase_order`)."

**Gather:**
- Name: human-readable (e.g. "Acme Purchase Order")
- Code: kebab-case or snake_case identifier (lowercase, numbers, underscores; e.g. `acme-purchase-order`)
- Description: one sentence

The code must be unique and lowercase; the agent suggests one based on the name when the user doesn't provide one.

### Stage 3: Core fields

Lead with what you read, don't interrogate. Having read the document in Stage 1, the agent **proposes** the fields it detected and asks the user to confirm or adjust — rather than asking the user to enumerate fields from scratch.

**Agent says:**
> "From the document I read these core fields: `invoice_number` (top-right), `issue_date` (under the number), `total` (bottom-right). Did I miss anything, and are these the ones you need?"

**For each detected field, infer and record:**
- Name (normalized to `snake_case`)
- Type (`string`, `number`, `date`, `boolean`)
- Where it appears on the page (for the JSON Schema `description`)
- Expected format if visible

The user confirms, removes, or adds fields. The agent builds the initial JSON Schema from the agreed list using the **required + nullable** pattern (see `schema-design.md`).

(If no sample was available, fall back to asking: "What are the 3–5 most important pieces of data you need, and what kind of value is each?" — and mark the schema tentative per Stage 1.)

### Stage 4: Additional fields and tabular data

**Agent asks:**
> "Are there additional fields beyond those core ones? Does this document have any tables or repeating sections (line items, rows of data)?"

For tables:
- Ask for column names and types
- Build an `array` field with `items` describing each column
- Ask if row order matters (`--keep-ordering` on `types create`)

### Stage 5: Special formatting (prompt hints)

**Agent asks:**
> "Does this document use any special formatting I should know about? Date format, decimal separator, language, multi-page layout, …?"

These map to **`promptHints`** (used during conversion):

| Hint | Example |
|---|---|
| Date format | `"Dates are DD/MM/YYYY"` |
| Decimal separator | `"Comma is decimal separator (1.234,56)"` |
| Thousand separator | `"Period is thousand separator"` |
| Language/locale | `"Document is in Portuguese (Brazil)"` |
| Multi-page | `"Summary table is on the last page"` |
| Layout | `"Two-column layout, read left column first"` |

### Stage 6: Identify hints

**Agent asks:**
> "If you'll auto-detect this type with `docutray identify`, what visual or structural clues would help? Logos, headers, numbering patterns?"

These map to **`identifyPromptHints`** (used by `identify` to disambiguate similar types):

```
"Acme Corp purchase order. Distinguished by Acme logo top-left, PO numbers
starting with 'PO-', and 'Purchase Order' title in the header."
```

Effective `identifyPromptHints` reference:
- Visual markers (logos, watermarks, headers)
- Unique identifiers (numbering patterns, specific labels)
- Distinguishing features from similar types

### Stage 7: Review and confirm

The agent presents:
- Complete JSON Schema
- Proposed `promptHints` and `identifyPromptHints`
- The `docutray types create` command that will run
- Whether to publish immediately or keep as draft (default is draft)

**Agent asks:**
> "Here's the complete configuration. Want me to create it as a draft, publish it immediately, or adjust anything?"

### Stage 8: Create and test

```bash
docutray types create \
  --name "Purchase Order" \
  --code acme-purchase-order \
  --description "Standard Acme purchase order" \
  --schema po_schema.json \
  --prompt-hints "Dates DD/MM/YYYY; comma is decimal separator (1.234,56)." \
  --identify-hints "Acme PO; logo top-left; PO numbers start with 'PO-'." \
  --publish
```

```bash
docutray convert sample-po.pdf -t acme-purchase-order
```

> **The code you pass is not always the code you get.** For org-owned types the API namespaces `--code` with an organization prefix — passing `--code acme-purchase-order` in an org named *Acme* yields a stored `codeType` like `acme_acme-purchase-order`, and the un-prefixed code does **not** resolve (`Document type "acme-purchase-order" not found`). Public catalog types (`factura`, `bl`, …) carry no prefix.
>
> **Always take the real code from the create response** instead of reusing what you passed:
>
> ```bash
> CODE=$(docutray types create --name "…" --code acme-purchase-order \
>   --description "…" --schema schema.json --json | jq -r '.codeType' | head -1)
> docutray convert sample-po.pdf -t "$CODE"
> ```
>
> The `| head -1` is deliberate: `types create` output is **not reliably a single JSON object** — it has been observed emitting two, the second with `isDraft` and `status` nulled. Take the first and don't assume a lone document.

> **A code that already exists fails with a bare `500`.** Re-running a create with a taken code returns `{"error":"Error processing request","status":500}` — no conflict status, and nothing naming the code as the cause. Before concluding the API is down, check whether the type already exists: `docutray types list --search <name>`.

The agent reviews the output with the user and iterates the schema if needed.

## `types create` — full flag reference

From `docutray types create --help` (`@docutray/cli/0.4.0`).

| Flag | Required | Description |
|---|---|---|
| `--code=<value>` | yes | Requested code (lowercase, numbers, underscores or hyphens). **Org-owned types get an organization prefix** — read the real `codeType` from the response |
| `--description=<value>` | yes | One-sentence description |
| `--name=<value>` | yes | Human-readable name |
| `--schema=<value>` | yes | JSON Schema as a file path **or** inline JSON string. Given a full `types export` payload, its embedded `conversionSpec` is carried over too |
| `--prompt-hints=<value>` | no | General extraction prompt hints |
| `--identify-hints=<value>` | no | Hints for automatic identification |
| `--conversion-mode=<json\|toon\|multi_prompt>` | no | Conversion mode |
| `--conversion-spec=<value>` | no | Export spec (JSON → CSV/Excel column mapping): file path or inline JSON. Accepts a bare spec (`{"columns":[…]}` / `{"sheets":[…]}`) or a full `types export` payload. Takes precedence over a spec embedded in `--schema` |
| `--keep-ordering` | no | Preserve property ordering in output |
| `--publish` | no | Publish immediately (equivalent to `--no-draft`) |
| `--draft` | no | Create as draft (the default) |
| `--json` | no | Force JSON output |

Examples:

```bash
# Schema from file
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" --schema schema.json

# Inline schema
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" \
  --schema '{"type":"object","properties":{"total":{"type":"number"}}}'

# Create and publish in one shot
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" --schema schema.json --publish

# Specific conversion mode
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" --schema schema.json \
  --conversion-mode toon

# With an export spec (JSON → CSV/Excel column mapping)
docutray types create --name "Invoice" --code invoice \
  --description "Standard invoice" --schema schema.json \
  --conversion-spec spec.json

# Round-trip: recreate an exported type — schema AND export spec are carried over
docutray types export factura -o factura.json
docutray types create --name "Copia" --code factura_copy \
  --description "Copy of factura" --schema factura.json
```

See `conversion-spec.md` for the spec format and `jsonPath` authoring.

## Modifying types — `types update`

From `docutray types update --help` (`@docutray/cli/0.4.0`). The `code` is positional and cannot be changed; everything else is optional, but at least one updatable field is required.

| Flag | Description |
|---|---|
| (positional) `CODE` | Document type code to update |
| `--name=<value>` | New name |
| `--description=<value>` | New description |
| `--schema=<value>` | New JSON Schema (file path or inline JSON). Unlike `types create`, a `conversionSpec` embedded in a `types export` payload is **ignored** — use `--conversion-spec` to change it |
| `--prompt-hints=<value>` | New prompt hints |
| `--identify-hints=<value>` | New identify hints |
| `--conversion-mode=<json\|toon\|multi_prompt>` | New conversion mode |
| `--conversion-spec=<value>` | Replace the export spec: file path or inline JSON, same parsing as `create` |
| `--no-conversion-spec` | Remove the export spec from the type. Mutually exclusive with `--conversion-spec` |
| `--[no-]keep-ordering` | Toggle ordering preservation |
| `--[no-]draft` | Set draft status |
| `--publish` | Publish (sets draft=false) |
| `--json` | Force JSON output |

Either conversion-spec flag on its own satisfies the "at least one field to update" check.

**Why `update --schema` doesn't carry the spec:** an update is partial by contract, so pulling a `conversionSpec` out of a schema file would modify a field the user never named. `create` is the opposite case — it builds a type from scratch, so reproducing the whole exported definition is what you want.

### Workflow

```bash
# 1. Inspect current state
docutray types get acme-purchase-order

# 2. Export the schema for editing
docutray types export acme-purchase-order -o current_schema.json

# 3. Edit current_schema.json, then update
docutray types update acme-purchase-order --schema current_schema.json

# 4. (Optional) tweak hints separately
docutray types update acme-purchase-order \
  --prompt-hints "Updated: dates are now in YYYY-MM-DD format."

docutray types update acme-purchase-order \
  --identify-hints "Acme PO v2 — new logo format."

# 5. (Optional) change the export spec — pick ONE of these, they undo each other
docutray types update acme-purchase-order --conversion-spec spec.json   # replace it
# docutray types update acme-purchase-order --no-conversion-spec        # or clear it

# 6. Publish a draft
docutray types update acme-purchase-order --publish

# 7. Test
docutray convert sample-po.pdf -t acme-purchase-order
```

Compare the new output against the previous version to verify improvements before re-publishing.

If you changed the export spec, confirm it stored — an API deployment predating `conversionSpec` support accepts and discards the field without error:

```bash
docutray types get acme-purchase-order    # → anything other than "(none)"
```

## Multi-document files

### Signs

- User mentions "invoice and packing slip in one PDF"
- Different pages have clearly different layouts
- `docutray identify` returns low confidence (the file confuses two types)

### Strategy 1 — separate types per document

```bash
# Invoice portion
docutray types create \
  --name "Shipping Bundle - Invoice" \
  --code shipping-invoice \
  --description "Invoice page of multi-doc shipping bundle" \
  --schema invoice_schema.json \
  --prompt-hints "This is pages 1–2 of a multi-document shipping bundle."

# Packing slip portion
docutray types create \
  --name "Shipping Bundle - Packing Slip" \
  --code shipping-packing-slip \
  --description "Packing slip page of multi-doc shipping bundle" \
  --schema packing_slip_schema.json \
  --prompt-hints "This is the last page of a multi-document shipping bundle."
```

### Strategy 2 — same type repeated

When one PDF contains multiple instances of the same document type (e.g. 10 invoices in one file), use a **single** type — DocuTray handles repeated extraction automatically. Add a `promptHints` like `"Each page is a separate invoice"` to make the pattern explicit.

## Example agent–user dialog

A condensed walkthrough showing the progressive flow.

---

**User:** I need to extract data from our purchase orders.

**Agent:** Can you share an example PO? I'll read it before we design the schema.

**User:** Here's `sample-po.pdf`.

**Agent:** *(reads the PDF with its file/vision tool, and checks for an existing type)*
```bash
docutray types list --search "purchase order"
```
No matching types. From the document I see: PO number (top-right, `PO-XXXXX`), vendor name (header), order date and delivery date (under the header), and a line-items table with columns Item code, Description, Quantity, Unit price, Total. I suggest a type **"Purchase Order"** with code `purchase-order` covering those fields. Did I miss anything?

**User:** That's all of them.

**Agent:** Any special formatting — date format, decimal separators, language, layout?

**User:** Dates are DD/MM/YYYY, amounts use comma as decimal separator.

**Agent:** Here's the complete schema and the command. Create it now, or adjust first?

```json
{
  "type": "object",
  "required": ["po_number", "vendor_name", "order_date", "delivery_date", "line_items"],
  "properties": {
    "po_number":     { "type": ["string", "null"], "description": "PO number, top-of-page, format PO-XXXXX" },
    "vendor_name":   { "type": ["string", "null"], "description": "Vendor name, in header" },
    "order_date":    { "type": ["string", "null"], "format": "date", "description": "Order creation date" },
    "delivery_date": { "type": ["string", "null"], "format": "date", "description": "Expected delivery date" },
    "line_items": {
      "type": ["array", "null"],
      "description": "Table of ordered items",
      "items": {
        "type": "object",
        "required": ["item_code", "description", "quantity", "unit_price", "total"],
        "properties": {
          "item_code":   { "type": ["string", "null"] },
          "description": { "type": ["string", "null"] },
          "quantity":    { "type": ["number", "null"] },
          "unit_price":  { "type": ["number", "null"] },
          "total":       { "type": ["number", "null"] }
        }
      }
    }
  }
}
```

```bash
docutray types create --name "Purchase Order" --code purchase-order \
  --description "Standard purchase order" \
  --schema po_schema.json \
  --prompt-hints "Dates DD/MM/YYYY; comma is decimal separator (1.234,56)." \
  --identify-hints "Purchase order; 'Purchase Order' header; PO-XXXXX number." \
  --publish
```

**User:** Looks good — create it.

**Agent:** Created. Testing on your sample:
```bash
docutray convert sample-po.pdf -t purchase-order
```

Then iterate on the schema if any field is missing or wrong.
