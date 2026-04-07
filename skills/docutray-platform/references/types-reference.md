# Types — Detailed Reference

## Schema Structure

Each document type defines a schema with extraction fields:

```json
{
  "name": "invoice",
  "description": "Standard invoice document",
  "schema": {
    "fields": [
      {
        "name": "invoice_number",
        "type": "string",
        "required": true,
        "description": "Unique invoice identifier"
      },
      {
        "name": "date",
        "type": "date",
        "required": true,
        "description": "Invoice issue date"
      },
      {
        "name": "total",
        "type": "number",
        "required": true,
        "description": "Total amount"
      },
      {
        "name": "line_items",
        "type": "array",
        "required": false,
        "description": "Individual line items",
        "items": {
          "fields": [
            { "name": "description", "type": "string" },
            { "name": "quantity", "type": "number" },
            { "name": "unit_price", "type": "number" }
          ]
        }
      }
    ]
  }
}
```

## Field Types

| Type | Description | Example Values |
|------|-------------|----------------|
| `string` | Text content | `"INV-2024-001"` |
| `number` | Numeric value (int or float) | `1500.00` |
| `date` | Date in ISO 8601 format | `"2024-03-15"` |
| `boolean` | True/false value | `true` |
| `array` | List of structured items | Line items, addresses |
| `object` | Nested structured data | Address with street, city, zip |

## List All Types

### CLI

```bash
docutray types list
```

### Python SDK

```python
types = client.types.list()
for t in types:
    print(f"{t.name}: {t.description}")
```

### Node SDK

```typescript
const types = await client.types.list();
for (const t of types) {
  console.log(`${t.name}: ${t.description}`);
}
```

### REST API

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types
```

**Response:**

```json
{
  "success": true,
  "data": [
    { "name": "invoice", "description": "Standard invoice document" },
    { "name": "receipt", "description": "Purchase receipt" },
    { "name": "contract", "description": "Legal contract" }
  ]
}
```

The list includes user-created, organizational, and public document types.

## Get Type Details

### CLI

```bash
docutray types get invoice
```

### Python SDK

```python
doc_type = client.types.get("invoice")
print(doc_type.name)
print(doc_type.description)
print(doc_type.schema)
```

### Node SDK

```typescript
const docType = await client.types.get("invoice");
console.log(docType.name);
console.log(docType.description);
console.log(docType.schema);
```

### REST API

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/invoice
```

## Export Type Schema

Export a document type's schema as a standalone JSON file, useful for version control or sharing.

### CLI

```bash
# To stdout
docutray types export invoice

# To file
docutray types export invoice --output invoice-schema.json
```

### Python SDK

```python
schema = client.types.export("invoice")
# schema is a dict with the full schema definition

import json
with open("invoice-schema.json", "w") as f:
    json.dump(schema, f, indent=2)
```

### Node SDK

```typescript
const schema = await client.types.export("invoice");

import { writeFileSync } from "fs";
writeFileSync("invoice-schema.json", JSON.stringify(schema, null, 2));
```

### REST API

```bash
curl -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  https://app.docutray.com/api/types/invoice/export \
  -o invoice-schema.json
```

## Schema Validation

Validate a JSON document against a type's schema before submitting for conversion.

### REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $DOCUTRAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"type": "invoice", "data": {"invoice_number": "INV-001"}}' \
  https://app.docutray.com/api/types/validate
```

**Response (valid):**

```json
{
  "success": true,
  "data": {
    "valid": true,
    "warnings": []
  }
}
```

**Response (invalid):**

```json
{
  "success": true,
  "data": {
    "valid": false,
    "errors": [
      { "field": "date", "message": "Required field 'date' is missing" }
    ],
    "warnings": [
      { "field": "vendor", "message": "Optional field 'vendor' not provided" }
    ]
  }
}
```

## Common Patterns

### Check If a Type Exists Before Converting

```python
types = client.types.list()
type_names = [t.name for t in types]

if "invoice" in type_names:
    result = client.convert(file_path="doc.pdf", document_type="invoice")
else:
    print("Document type 'invoice' not available")
```

### Export All Schemas for Version Control

```bash
for TYPE in $(docutray types list | jq -r '.data[].name'); do
  docutray types export "$TYPE" --output "schemas/${TYPE}.json"
done
```
