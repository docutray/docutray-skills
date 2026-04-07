# Document Type Workflow — Detailed Reference

## Decision Tree

```
User wants to extract data from a document
│
├─ Run: docutray types list --search "<keywords>"
├─ Run: docutray identify <file>
│
├─ Match found (confidence >= 0.9)?
│  ├─ YES → Use existing type: docutray convert <file> --type <code>
│  └─ NO ↓
│
├─ Similar type exists (0.7–0.9 or keyword match)?
│  ├─ YES → Ask user: modify existing or create new?
│  │  ├─ MODIFY → Go to "Modifying Types" workflow
│  │  └─ CREATE → Go to "Creating Types" workflow
│  └─ NO → Go to "Creating Types" workflow
│
└─ Done: convert document using the (new or existing) type
```

## Progressive Disclosure Flow

The key principle: **gather information in stages, not all at once.** This prevents overwhelming users and allows the agent to make informed suggestions.

### Stage 1: Understand the Document

**Agent asks:**
> "Can you share or describe the document you want to process? What kind of document is it?"

**What to gather:**
- Document type (invoice, receipt, form, report, etc.)
- General purpose (what data needs to be extracted)
- Sample file if available

**Agent actions:**
```bash
# Check existing types
docutray types list --search "<document keywords>"

# If user provided a file, auto-detect
docutray identify sample-document.pdf
```

### Stage 2: Name and Identity

**Agent asks:**
> "Let's set up the document type. What would you like to call it? I'll also need a short code (like `purchase_order`)."

**What to gather:**
- Name: Human-readable (e.g., "Acme Purchase Order")
- Code: snake_case identifier (e.g., `acme_purchase_order`)
- Description: One sentence

**Agent suggests** a code based on the name if the user doesn't provide one.

### Stage 3: Core Fields

**Agent asks:**
> "What are the 3-5 most important pieces of data you need from this document? For each, tell me what it is and what kind of value (text, number, date, etc.)."

**What to gather for each field:**
- Name (agent converts to snake_case)
- Type (string, number, date, boolean)
- Where it appears on the document (for the description)
- Expected format if relevant

**Agent builds** the initial schema from this information.

### Stage 4: Additional Fields and Tables

**Agent asks:**
> "Are there additional fields beyond those core ones? Also, does this document have any tables or repeating sections (like line items, rows of data)?"

**If tables exist:**
- Ask for column names and types
- Build an `array` field with `items` defining each column
- Ask if row order matters

### Stage 5: Special Formatting

**Agent asks:**
> "Does this document use any special formatting I should know about? For example: date format, number format (comma vs period for decimals), language, or multi-page layout?"

**This maps to `promptHints`:**
- Date format → `"Dates are DD/MM/YYYY"`
- Number format → `"Comma is decimal separator"`
- Language → `"Document is in French"`
- Layout → `"Two-column layout"`

### Stage 6: Review and Confirm

**Agent presents:**
- Complete schema as JSON
- Proposed promptHints
- Proposed identifyPromptHints
- The CLI command that will be executed

**Agent asks:**
> "Here's the complete configuration. Want me to create it, or would you like to adjust anything?"

### Stage 7: Create and Test

**Agent executes:**
```bash
docutray types create --name "..." --code ... --schema schema.json \
  --prompt-hints "..." --identify-hints "..."
```

**Then tests:**
```bash
docutray convert sample-document.pdf --type <code>
```

**Agent reviews** output with the user and iterates if needed.

## Multi-Document Handling

### Identifying Multi-Document Files

Signs that a file contains multiple document types:
- User mentions "invoice and packing slip in one PDF"
- Different pages have clearly different layouts
- `docutray identify` returns low confidence (confusion between types)

### Strategy: Separate Types

Create individual document types for each document within the file:

1. **Ask the user** which pages correspond to which document type
2. **Create separate types** with descriptive names indicating the bundle
3. **Use promptHints** to specify page ranges or positions

Example:
```bash
# Type for the invoice portion
docutray types create \
  --name "Shipping Bundle - Invoice" \
  --code shipping_invoice \
  --schema invoice_schema.json \
  --prompt-hints "This is pages 1-2 of a multi-document shipping bundle."

# Type for the packing slip
docutray types create \
  --name "Shipping Bundle - Packing Slip" \
  --code shipping_packing_slip \
  --schema packing_slip_schema.json \
  --prompt-hints "This is the last page of a multi-document shipping bundle."
```

### Strategy: Repeated Same-Type Documents

When one PDF contains multiple instances of the same document type (e.g., 10 invoices in one file):
- Create a single type — DocuTray handles repeated extraction automatically
- Use `promptHints` to indicate the repeating pattern: `"Each page is a separate invoice"`

## Example Agent-User Interaction

Below is an example conversation showing the progressive disclosure pattern:

---

**User:** I need to extract data from our purchase orders.

**Agent:** Let me check if there's already a matching type.
```bash
docutray types list --search "purchase order"
```
No matching types found. Let's create one! What would you like to call this document type? I suggest "Purchase Order" with code `purchase_order`.

**User:** That works. Our POs have a PO number, vendor name, order date, delivery date, and line items.

**Agent:** Got it. Here's the initial schema based on those fields:
- `po_number` (string) — the PO identifier
- `vendor_name` (string) — vendor/supplier name
- `order_date` (date) — when the PO was created
- `delivery_date` (date) — expected delivery date
- `line_items` (array) — table of ordered items

For the line items, what columns does the table have?

**User:** Item code, description, quantity, unit price, and total.

**Agent:** Are there any additional fields I should include? And do your POs have any special formatting — like European date format or specific number formatting?

**User:** Dates are DD/MM/YYYY and amounts use comma as decimal separator.

**Agent:** Here's the complete schema:

```json
{
  "type": "object",
  "required": ["po_number", "vendor_name", "order_date", "delivery_date", "line_items"],
  "properties": {
    "po_number": {
      "type": ["string", "null"],
      "description": "Purchase order number, top of page, format: PO-XXXXX"
    },
    "vendor_name": {
      "type": ["string", "null"],
      "description": "Vendor/supplier name, in header or 'Supplier' section"
    },
    "order_date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Order creation date"
    },
    "delivery_date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Expected delivery date"
    },
    "line_items": {
      "type": ["array", "null"],
      "description": "Table of ordered items",
      "items": {
        "type": "object",
        "required": ["item_code", "description", "quantity", "unit_price", "total"],
        "properties": {
          "item_code": { "type": ["string", "null"], "description": "Product/item code" },
          "description": { "type": ["string", "null"], "description": "Item description" },
          "quantity": { "type": ["number", "null"], "description": "Quantity ordered" },
          "unit_price": { "type": ["number", "null"], "description": "Price per unit" },
          "total": { "type": ["number", "null"], "description": "Line total" }
        }
      }
    }
  }
}
```

Prompt hints: "Dates are in DD/MM/YYYY format. Amounts use comma as decimal separator (e.g., 1.234,56)."

Want me to create this type, or adjust anything?

**User:** Looks good, create it.

**Agent:**
```bash
docutray types create --name "Purchase Order" --code purchase_order \
  --description "Standard purchase order document" \
  --schema po_schema.json \
  --prompt-hints "Dates are in DD/MM/YYYY format. Amounts use comma as decimal separator (e.g., 1.234,56)." \
  --identify-hints "Purchase order document, identified by 'Purchase Order' header and PO-XXXXX number."
```

Type created. Let me test it with your sample:
```bash
docutray convert sample-po.pdf --type purchase_order
```
