# Schema Design — Detailed Reference

## JSON Schema Structure

DocuTray extraction schemas follow JSON Schema draft-07 conventions. The schema defines what fields the LLM should extract from a document.

### Top-Level Structure

```json
{
  "type": "object",
  "required": ["field1", "field2"],
  "properties": {
    "field1": { ... },
    "field2": { ... }
  }
}
```

## The Required + Nullable Pattern

**Always prefer `required` + nullable type over optional fields.**

```json
{
  "required": ["invoice_number", "date", "total"],
  "properties": {
    "invoice_number": {
      "type": ["string", "null"],
      "description": "Invoice ID"
    },
    "date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Issue date"
    },
    "total": {
      "type": ["number", "null"],
      "description": "Total amount"
    }
  }
}
```

**Why?** Required fields always appear in the output JSON. Using `["type", "null"]` allows the model to return `null` when a value isn't found, rather than omitting the field entirely. This makes downstream processing predictable — you always know what fields to expect.

**Anti-pattern — optional fields:**

```json
{
  "properties": {
    "vendor": {
      "type": "string",
      "description": "Vendor name"
    }
  }
}
```

This may omit `vendor` entirely from output, making it hard to distinguish "not found" from "not extracted."

## Field Types Reference

### String Fields

Basic text extraction:

```json
{
  "company_name": {
    "type": ["string", "null"],
    "description": "Company name from the letterhead"
  }
}
```

With pattern hint:

```json
{
  "phone": {
    "type": ["string", "null"],
    "description": "Phone number, format: +1 (XXX) XXX-XXXX"
  }
}
```

### Number Fields

For amounts, quantities, and measurements:

```json
{
  "total_amount": {
    "type": ["number", "null"],
    "description": "Grand total including tax, as a decimal number"
  },
  "quantity": {
    "type": ["integer", "null"],
    "description": "Number of units ordered, whole number"
  }
}
```

Use `"type": ["number", "null"]` for decimals, `"type": ["integer", "null"]` for whole numbers.

### Date Fields

Dates are extracted as ISO 8601 strings:

```json
{
  "invoice_date": {
    "type": ["string", "null"],
    "format": "date",
    "description": "Invoice issue date, top-right of page"
  },
  "due_date": {
    "type": ["string", "null"],
    "format": "date",
    "description": "Payment due date, usually 30 days after invoice date"
  }
}
```

The `format: "date"` tells the model to output YYYY-MM-DD regardless of how the date appears on the document. Combine with `promptHints` to specify the source format (e.g., "Dates on this document are DD/MM/YYYY").

### Boolean Fields

For checkbox or yes/no fields:

```json
{
  "is_taxable": {
    "type": ["boolean", "null"],
    "description": "Whether tax applies, indicated by checkbox"
  },
  "signature_present": {
    "type": ["boolean", "null"],
    "description": "Whether the document has a signature"
  }
}
```

### Enum Fields

For fields with known fixed values:

```json
{
  "payment_method": {
    "type": ["string", "null"],
    "enum": ["cash", "credit_card", "bank_transfer", "check", null],
    "description": "Payment method used"
  },
  "status": {
    "type": ["string", "null"],
    "enum": ["draft", "sent", "paid", "overdue", null],
    "description": "Invoice status"
  }
}
```

**Include `null` in the enum array** when using the nullable pattern.

### Array Fields (Tabular Data)

For line items, rows, and repeating sections:

```json
{
  "line_items": {
    "type": ["array", "null"],
    "description": "Table of purchased items, one entry per row",
    "items": {
      "type": "object",
      "required": ["description", "quantity", "unit_price", "total"],
      "properties": {
        "description": {
          "type": ["string", "null"],
          "description": "Item or service description"
        },
        "quantity": {
          "type": ["number", "null"],
          "description": "Quantity ordered"
        },
        "unit_price": {
          "type": ["number", "null"],
          "description": "Price per unit"
        },
        "total": {
          "type": ["number", "null"],
          "description": "Line total (quantity × unit_price)"
        }
      }
    }
  }
}
```

### Nested Object Fields

For structured sub-sections (e.g., address):

```json
{
  "billing_address": {
    "type": ["object", "null"],
    "description": "Billing address block, usually left side of page",
    "required": ["street", "city", "country"],
    "properties": {
      "street": {
        "type": ["string", "null"],
        "description": "Street address"
      },
      "city": {
        "type": ["string", "null"],
        "description": "City name"
      },
      "state": {
        "type": ["string", "null"],
        "description": "State or province"
      },
      "postal_code": {
        "type": ["string", "null"],
        "description": "ZIP or postal code"
      },
      "country": {
        "type": ["string", "null"],
        "description": "Country name or code"
      }
    }
  }
}
```

## Writing Effective Descriptions

Field descriptions are the single most impactful factor in extraction accuracy. They guide the LLM on **where** to find the value and **how** to interpret it.

### Good Descriptions

```json
{
  "invoice_number": {
    "description": "Invoice number, top-right corner of first page, format: INV-YYYY-NNNN"
  },
  "total_amount": {
    "description": "Grand total including tax, bottom-right of page, after the label 'TOTAL DUE:'"
  },
  "vendor_tax_id": {
    "description": "Vendor's tax identification number, in the 'Bill From' section, format: XX-XXXXXXX"
  }
}
```

### Weak Descriptions (Avoid)

```json
{
  "invoice_number": { "description": "The invoice number" },
  "total_amount": { "description": "Total" },
  "vendor_tax_id": { "description": "Tax ID" }
}
```

### Description Checklist

- **Location**: Where on the document is this value? (top-right, in the header, under "Bill To")
- **Format**: What does the value look like? (INV-XXXX, $X,XXX.XX, DD/MM/YYYY)
- **Disambiguation**: If similar values exist, how to tell them apart? ("Total before tax, NOT the grand total")

## Complete Schema Example

A full invoice extraction schema:

```json
{
  "type": "object",
  "required": [
    "invoice_number", "date", "due_date",
    "vendor_name", "vendor_tax_id",
    "customer_name",
    "subtotal", "tax_amount", "total",
    "line_items"
  ],
  "properties": {
    "invoice_number": {
      "type": ["string", "null"],
      "description": "Unique invoice ID, top-right, format: INV-YYYY-NNNN"
    },
    "date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Invoice issue date, near the invoice number"
    },
    "due_date": {
      "type": ["string", "null"],
      "format": "date",
      "description": "Payment due date, near invoice date or in payment terms"
    },
    "vendor_name": {
      "type": ["string", "null"],
      "description": "Vendor/seller company name, top-left or in 'Bill From' section"
    },
    "vendor_tax_id": {
      "type": ["string", "null"],
      "description": "Vendor tax ID, in 'Bill From' section, format: XX-XXXXXXX"
    },
    "customer_name": {
      "type": ["string", "null"],
      "description": "Customer/buyer name, in 'Bill To' or 'Ship To' section"
    },
    "subtotal": {
      "type": ["number", "null"],
      "description": "Sum before tax, labeled 'Subtotal' above the total"
    },
    "tax_amount": {
      "type": ["number", "null"],
      "description": "Tax amount, between subtotal and total"
    },
    "total": {
      "type": ["number", "null"],
      "description": "Grand total including tax, bottom-right, after 'TOTAL DUE'"
    },
    "line_items": {
      "type": ["array", "null"],
      "description": "Table of purchased items/services",
      "items": {
        "type": "object",
        "required": ["description", "quantity", "unit_price", "total"],
        "properties": {
          "description": {
            "type": ["string", "null"],
            "description": "Item or service description"
          },
          "quantity": {
            "type": ["number", "null"],
            "description": "Quantity"
          },
          "unit_price": {
            "type": ["number", "null"],
            "description": "Price per unit"
          },
          "total": {
            "type": ["number", "null"],
            "description": "Line total"
          }
        }
      }
    }
  }
}
```
