# DATA_MODELS.md
# RetailOS — Data Models, ERD, Sequence Diagrams, State Machines
# Pressman Ch 8 (Requirements Modeling — Class-Based + Behavioral)
# Version: 1.0 | Day 3

---

## SECTION 1 — ENTITY CLASSES (Pressman Ch 8.3.1 — Noun Extraction)

### 1.1 All Entity Classes

| Class | Category | Responsibility |
|---|---|---|
| Organization | Entity | Top-level tenant — owns all data |
| Store | Entity | A physical shop location |
| User | Entity | A person who logs in |
| Product | Entity | A sellable item in the catalogue |
| Category | Entity | Product classification |
| TaxGroup | Entity | GST rate configuration |
| Inventory | Entity | Stock level of a product in a store |
| StockMovement | Entity | Audit log of every stock change |
| Sale | Entity | A completed billing transaction |
| SaleItem | Entity | One line item within a Sale |
| Customer | Entity | A registered shop customer |
| LoyaltyAccount | Entity | Customer's points balance |
| Supplier | Entity | A vendor/distributor |
| PurchaseOrder | Entity | A formal order to a supplier |
| PurchaseOrderItem | Entity | One line item in a PO |
| GoodsReceipt | Entity | Record of received stock |
| GoodsReceiptItem | Entity | One line item in a GRN |
| Payment | Entity | Payment record linked to a Sale or PO |
| Invoice | Entity | GST invoice document linked to a Sale |
| Employee | Entity | Staff member (for HR module) |
| Attendance | Entity | Daily attendance record per employee |
| Payroll | Entity | Monthly payroll record per employee |
| JournalEntry | Entity | Double-entry accounting record |
| CashRegister | Entity | Daily cash drawer record per store |

---

### 1.2 Attribute Definitions (Complete)

**Organization**
```
id                UUID        PK
name              TEXT        NOT NULL
gstin             TEXT        UNIQUE NOT NULL
registered_address TEXT       NOT NULL
state_code        TEXT(2)     NOT NULL  -- e.g., '29' for Karnataka
pincode           TEXT(6)
phone             TEXT
email             TEXT
logo_url          TEXT
created_at        TIMESTAMPTZ DEFAULT now()
```

**Store**
```
id                UUID        PK
org_id            UUID        FK → organizations.id ON DELETE CASCADE
name              TEXT        NOT NULL
address           TEXT
gstin             TEXT        -- can differ from org GSTIN for branches
state_code        TEXT(2)
phone             TEXT
invoice_prefix    TEXT        DEFAULT 'INV'
invoice_counter   INTEGER     DEFAULT 1
financial_year    TEXT        DEFAULT '2526'  -- e.g., '2526' for FY 25-26
is_active         BOOLEAN     DEFAULT true
created_at        TIMESTAMPTZ DEFAULT now()
```

**User (profiles table — extends Supabase auth.users)**
```
id                UUID        PK = auth.users.id
org_id            UUID        FK → organizations.id
store_id          UUID        FK → stores.id (assigned store)
full_name         TEXT        NOT NULL
phone             TEXT
role              TEXT        CHECK IN ('owner','manager','cashier')
is_active         BOOLEAN     DEFAULT true
created_at        TIMESTAMPTZ DEFAULT now()
updated_at        TIMESTAMPTZ
```

**Category**
```
id                UUID        PK
org_id            UUID        FK → organizations.id
name              TEXT        NOT NULL
description       TEXT
parent_id         UUID        FK → categories.id (for sub-categories)
created_at        TIMESTAMPTZ DEFAULT now()
```

**TaxGroup**
```
id                UUID        PK
org_id            UUID        FK → organizations.id
name              TEXT        NOT NULL  -- e.g., 'GST 18%'
gst_rate          NUMERIC(5,2) CHECK IN (0,5,12,18,28)
cgst_rate         NUMERIC(5,2)
sgst_rate         NUMERIC(5,2)
igst_rate         NUMERIC(5,2)
is_default        BOOLEAN     DEFAULT false
created_at        TIMESTAMPTZ DEFAULT now()
```

**Product**
```
id                UUID        PK
org_id            UUID        FK → organizations.id
category_id       UUID        FK → categories.id
tax_group_id      UUID        FK → tax_groups.id
name              TEXT        NOT NULL
barcode           TEXT        UNIQUE
hsn_code          TEXT
unit              TEXT        DEFAULT 'pcs'
cost_price        NUMERIC(12,2) NOT NULL DEFAULT 0
selling_price     NUMERIC(12,2) NOT NULL DEFAULT 0
mrp               NUMERIC(12,2)
description       TEXT
image_url         TEXT
is_active         BOOLEAN     DEFAULT true
created_at        TIMESTAMPTZ DEFAULT now()
updated_at        TIMESTAMPTZ
```

**Inventory**
```
id                UUID        PK
store_id          UUID        FK → stores.id
product_id        UUID        FK → products.id
qty_on_hand       NUMERIC(12,3) DEFAULT 0
reorder_level     NUMERIC(12,3) DEFAULT 0
updated_at        TIMESTAMPTZ DEFAULT now()
UNIQUE(store_id, product_id)
```

**StockMovement**
```
id                UUID        PK
store_id          UUID        FK → stores.id
product_id        UUID        FK → products.id
movement_type     TEXT        CHECK IN ('sale','purchase','adjustment','transfer_in','transfer_out','return')
quantity          NUMERIC(12,3) NOT NULL  -- positive = in, negative = out
reference_id      UUID        -- sale_id or grn_id
reference_type    TEXT        -- 'sale' or 'grn' or 'adjustment'
reason            TEXT
user_id           UUID        FK → profiles.id
batch_no          TEXT
expiry_date       DATE
created_at        TIMESTAMPTZ DEFAULT now()
```

**Customer**
```
id                UUID        PK
org_id            UUID        FK → organizations.id
full_name         TEXT        NOT NULL
phone             TEXT        UNIQUE per org
email             TEXT
address           TEXT
gstin             TEXT        -- for B2B customers
date_of_birth     DATE
tier              TEXT        DEFAULT 'bronze' CHECK IN ('bronze','silver','gold')
credit_limit      NUMERIC(12,2) DEFAULT 0
total_purchases   NUMERIC(12,2) DEFAULT 0
created_at        TIMESTAMPTZ DEFAULT now()
```

**LoyaltyAccount**
```
id                UUID        PK
customer_id       UUID        FK → customers.id UNIQUE
points_balance    INTEGER     DEFAULT 0
points_earned_total INTEGER   DEFAULT 0
points_redeemed_total INTEGER DEFAULT 0
updated_at        TIMESTAMPTZ DEFAULT now()
```

**Sale**
```
id                UUID        PK
store_id          UUID        FK → stores.id
customer_id       UUID        FK → customers.id (nullable for guest)
user_id           UUID        FK → profiles.id  -- cashier
invoice_no        TEXT        NOT NULL UNIQUE per org
sale_date         TIMESTAMPTZ DEFAULT now()
subtotal          NUMERIC(12,2) NOT NULL
discount_amount   NUMERIC(12,2) DEFAULT 0
taxable_amount    NUMERIC(12,2) NOT NULL
cgst_amount       NUMERIC(12,2) DEFAULT 0
sgst_amount       NUMERIC(12,2) DEFAULT 0
igst_amount       NUMERIC(12,2) DEFAULT 0
total_tax         NUMERIC(12,2) DEFAULT 0
grand_total       NUMERIC(12,2) NOT NULL
payment_method    TEXT        -- 'cash','upi','card','split'
cash_amount       NUMERIC(12,2) DEFAULT 0
upi_amount        NUMERIC(12,2) DEFAULT 0
card_amount       NUMERIC(12,2) DEFAULT 0
points_redeemed   INTEGER     DEFAULT 0
status            TEXT        DEFAULT 'completed' CHECK IN ('completed','returned','voided')
notes             TEXT
created_at        TIMESTAMPTZ DEFAULT now()
```

**SaleItem**
```
id                UUID        PK
sale_id           UUID        FK → sales.id ON DELETE CASCADE
product_id        UUID        FK → products.id
product_name      TEXT        NOT NULL  -- snapshot at time of sale
hsn_code          TEXT
quantity          NUMERIC(12,3) NOT NULL
unit              TEXT
unit_price        NUMERIC(12,2) NOT NULL
discount_percent  NUMERIC(5,2)  DEFAULT 0
discount_amount   NUMERIC(12,2) DEFAULT 0
taxable_amount    NUMERIC(12,2) NOT NULL
gst_rate          NUMERIC(5,2)
cgst_rate         NUMERIC(5,2)
sgst_rate         NUMERIC(5,2)
igst_rate         NUMERIC(5,2)
cgst_amount       NUMERIC(12,2)
sgst_amount       NUMERIC(12,2)
igst_amount       NUMERIC(12,2)
total_amount      NUMERIC(12,2) NOT NULL
batch_no          TEXT
```

**Supplier**
```
id                UUID        PK
org_id            UUID        FK → organizations.id
name              TEXT        NOT NULL
gstin             TEXT
contact_person    TEXT
phone             TEXT
email             TEXT
address           TEXT
payment_terms     INTEGER     DEFAULT 30  -- days
is_active         BOOLEAN     DEFAULT true
created_at        TIMESTAMPTZ DEFAULT now()
```

**PurchaseOrder**
```
id                UUID        PK
store_id          UUID        FK → stores.id
supplier_id       UUID        FK → suppliers.id
po_number         TEXT        NOT NULL UNIQUE per org
order_date        DATE        DEFAULT CURRENT_DATE
expected_date     DATE
subtotal          NUMERIC(12,2)
tax_amount        NUMERIC(12,2)
total_amount      NUMERIC(12,2)
status            TEXT        DEFAULT 'draft' CHECK IN ('draft','sent','partial','received','cancelled')
notes             TEXT
created_by        UUID        FK → profiles.id
created_at        TIMESTAMPTZ DEFAULT now()
```

**GoodsReceipt**
```
id                UUID        PK
store_id          UUID        FK → stores.id
po_id             UUID        FK → purchase_orders.id (nullable)
supplier_id       UUID        FK → suppliers.id
grn_number        TEXT        NOT NULL
receipt_date      DATE        DEFAULT CURRENT_DATE
supplier_invoice_no TEXT
total_amount      NUMERIC(12,2)
status            TEXT        DEFAULT 'confirmed'
received_by       UUID        FK → profiles.id
created_at        TIMESTAMPTZ DEFAULT now()
```

---

## SECTION 2 — CLASS RELATIONSHIPS (Pressman Ch 8.3.3)

```
ORGANIZATION ──< has many >── STORES                (1:N)
ORGANIZATION ──< has many >── USERS                 (1:N)
ORGANIZATION ──< has many >── PRODUCTS              (1:N)
ORGANIZATION ──< has many >── CUSTOMERS             (1:N)
ORGANIZATION ──< has many >── SUPPLIERS             (1:N)
ORGANIZATION ──< has many >── CATEGORIES            (1:N)
ORGANIZATION ──< has many >── TAX_GROUPS            (1:N)

STORE ──< has many >── SALES                        (1:N)
STORE ──< has many >── PURCHASE_ORDERS              (1:N)
STORE ──< has many >── GOODS_RECEIPTS               (1:N)
STORE ──< has many >── INVENTORY (records)          (1:N)
STORE ──< has many >── EMPLOYEES                    (1:N)
STORE ──< has many >── CASH_REGISTERS               (1:N)
STORE ──< has >── USER (assigned)                   (1:N)

PRODUCT ──< belongs to >── CATEGORY                 (N:1)
PRODUCT ──< belongs to >── TAX_GROUP                (N:1)
PRODUCT ──< has one per store >── INVENTORY         (1:N)
PRODUCT ──< has many >── STOCK_MOVEMENTS            (1:N)

SALE ──< has many >── SALE_ITEMS                    (1:N)
SALE ──< belongs to >── CUSTOMER (optional)         (N:1)
SALE ──< belongs to >── STORE                       (N:1)
SALE ──< created by >── USER (cashier)              (N:1)
SALE ──< generates >── INVOICE                      (1:1)

SALE_ITEM ──< belongs to >── PRODUCT                (N:1)

CUSTOMER ──< has one >── LOYALTY_ACCOUNT            (1:1)
CUSTOMER ──< has many >── SALES                     (1:N)

PURCHASE_ORDER ──< belongs to >── SUPPLIER          (N:1)
PURCHASE_ORDER ──< has many >── PO_ITEMS            (1:N)
PURCHASE_ORDER ──< can have many >── GOODS_RECEIPTS (1:N)

GOODS_RECEIPT ──< linked to >── PURCHASE_ORDER      (N:1 optional)
GOODS_RECEIPT ──< has many >── GRN_ITEMS            (1:N)

EMPLOYEE ──< belongs to >── STORE                   (N:1)
EMPLOYEE ──< has many >── ATTENDANCES               (1:N)
EMPLOYEE ──< has many >── PAYROLLS                  (1:N)
```

---

## SECTION 3 — CRC CARDS (Pressman Ch 8.3.4)

```
┌──────────────────────────────────────────────────────┐
│ CLASS: Organization                                   │
├──────────────────────────┬───────────────────────────┤
│ Responsibilities          │ Collaborators             │
│                           │                           │
│ - Owns all tenant data    │ Store                     │
│ - Validates GSTIN         │ User                      │
│ - Configures tax groups   │ TaxGroup                  │
│ - Manages store setup     │ Product                   │
│ - Holds business profile  │ Category                  │
└──────────────────────────┴───────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ CLASS: Product                                        │
├──────────────────────────┬───────────────────────────┤
│ Responsibilities          │ Collaborators             │
│                           │                           │
│ - Holds product details   │ Category                  │
│ - Knows its GST rate      │ TaxGroup                  │
│ - Carries barcode/HSN     │ Inventory                 │
│ - Tracks pricing history  │ SaleItem                  │
│ - Defines selling unit    │ Organization              │
└──────────────────────────┴───────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ CLASS: Sale                                           │
├──────────────────────────┬───────────────────────────┤
│ Responsibilities          │ Collaborators             │
│                           │                           │
│ - Calculates grand total  │ SaleItem                  │
│ - Applies GST rules       │ Customer                  │
│ - Records payment split   │ TaxGroup                  │
│ - Triggers stock deduction│ Inventory                 │
│ - Generates invoice no    │ Invoice                   │
│ - Awards loyalty points   │ LoyaltyAccount            │
│ - Posts journal entries   │ JournalEntry              │
└──────────────────────────┴───────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ CLASS: Inventory                                      │
├──────────────────────────┬───────────────────────────┤
│ Responsibilities          │ Collaborators             │
│                           │                           │
│ - Tracks qty per store    │ Product                   │
│ - Signals low stock       │ Store                     │
│ - Enforces FEFO           │ StockMovement             │
│ - Logs every movement     │ PurchaseOrder             │
│ - Prevents oversell       │ Sale                      │
└──────────────────────────┴───────────────────────────┘

┌──────────────────────────────────────────────────────┐
│ CLASS: Customer                                       │
├──────────────────────────┬───────────────────────────┤
│ Responsibilities          │ Collaborators             │
│                           │                           │
│ - Holds contact details   │ LoyaltyAccount            │
│ - Tracks purchase history │ Sale                      │
│ - Maintains credit limit  │ Organization              │
│ - Earns/redeems points    │ Payment                   │
│ - Classifies loyalty tier │                           │
└──────────────────────────┴───────────────────────────┘
```

---

## SECTION 4 — SUPABASE SCHEMA SQL

```sql
-- ================================================================
-- RetailOS Complete PostgreSQL Schema
-- File: database/schema.sql
-- Run in: Supabase Dashboard → SQL Editor
-- ================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── ORGANIZATIONS ──────────────────────────────────────────────
CREATE TABLE organizations (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name              TEXT NOT NULL,
  gstin             TEXT NOT NULL,
  registered_address TEXT,
  state_code        TEXT(2) NOT NULL DEFAULT '29',
  pincode           TEXT(6),
  phone             TEXT,
  email             TEXT,
  logo_url          TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX orgs_gstin_idx ON organizations(gstin);

-- ── STORES ─────────────────────────────────────────────────────
CREATE TABLE stores (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  address           TEXT,
  state_code        TEXT(2) DEFAULT '29',
  phone             TEXT,
  invoice_prefix    TEXT NOT NULL DEFAULT 'INV',
  invoice_counter   INTEGER NOT NULL DEFAULT 1,
  financial_year    TEXT NOT NULL DEFAULT '2526',
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX stores_org_idx ON stores(org_id);

-- ── PROFILES (extends auth.users) ──────────────────────────────
CREATE TABLE profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  org_id            UUID REFERENCES organizations(id) ON DELETE SET NULL,
  store_id          UUID REFERENCES stores(id) ON DELETE SET NULL,
  full_name         TEXT NOT NULL DEFAULT '',
  phone             TEXT,
  role              TEXT NOT NULL DEFAULT 'cashier'
                    CHECK (role IN ('owner','manager','cashier')),
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ
);
CREATE INDEX profiles_org_idx ON profiles(org_id);
CREATE INDEX profiles_store_idx ON profiles(store_id);

-- ── CATEGORIES ─────────────────────────────────────────────────
CREATE TABLE categories (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  description       TEXT,
  parent_id         UUID REFERENCES categories(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX categories_org_idx ON categories(org_id);

-- ── TAX GROUPS ─────────────────────────────────────────────────
CREATE TABLE tax_groups (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  gst_rate          NUMERIC(5,2) NOT NULL
                    CHECK (gst_rate IN (0,5,12,18,28)),
  cgst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  sgst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  igst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  is_default        BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX tax_groups_org_idx ON tax_groups(org_id);

-- ── PRODUCTS ───────────────────────────────────────────────────
CREATE TABLE products (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  category_id       UUID REFERENCES categories(id) ON DELETE SET NULL,
  tax_group_id      UUID REFERENCES tax_groups(id) ON DELETE SET NULL,
  name              TEXT NOT NULL,
  barcode           TEXT,
  hsn_code          TEXT,
  unit              TEXT NOT NULL DEFAULT 'pcs',
  cost_price        NUMERIC(12,2) NOT NULL DEFAULT 0
                    CHECK (cost_price >= 0),
  selling_price     NUMERIC(12,2) NOT NULL DEFAULT 0
                    CHECK (selling_price >= 0),
  mrp               NUMERIC(12,2),
  description       TEXT,
  image_url         TEXT,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ
);
CREATE INDEX products_org_idx ON products(org_id);
CREATE INDEX products_name_idx ON products USING gin(to_tsvector('english', name));
CREATE UNIQUE INDEX products_barcode_org_idx ON products(org_id, barcode)
  WHERE barcode IS NOT NULL;

-- ── INVENTORY ──────────────────────────────────────────────────
CREATE TABLE inventory (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  qty_on_hand       NUMERIC(12,3) NOT NULL DEFAULT 0,
  reorder_level     NUMERIC(12,3) NOT NULL DEFAULT 0
                    CHECK (reorder_level >= 0),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(store_id, product_id)
);
CREATE INDEX inventory_store_idx ON inventory(store_id);
CREATE INDEX inventory_low_stock_idx ON inventory(store_id)
  WHERE qty_on_hand <= reorder_level;

-- ── STOCK MOVEMENTS ────────────────────────────────────────────
CREATE TABLE stock_movements (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  product_id        UUID NOT NULL REFERENCES products(id),
  movement_type     TEXT NOT NULL
                    CHECK (movement_type IN ('sale','purchase','adjustment',
                           'transfer_in','transfer_out','return')),
  quantity          NUMERIC(12,3) NOT NULL,
  reference_id      UUID,
  reference_type    TEXT,
  reason            TEXT,
  user_id           UUID REFERENCES profiles(id),
  batch_no          TEXT,
  expiry_date       DATE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX movements_product_idx ON stock_movements(product_id, created_at DESC);
CREATE INDEX movements_store_idx ON stock_movements(store_id, created_at DESC);

-- ── CUSTOMERS ──────────────────────────────────────────────────
CREATE TABLE customers (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  full_name         TEXT NOT NULL,
  phone             TEXT,
  email             TEXT,
  address           TEXT,
  gstin             TEXT,
  date_of_birth     DATE,
  tier              TEXT NOT NULL DEFAULT 'bronze'
                    CHECK (tier IN ('bronze','silver','gold')),
  credit_balance    NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_purchases   NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX customers_org_idx ON customers(org_id);
CREATE UNIQUE INDEX customers_phone_org_idx ON customers(org_id, phone)
  WHERE phone IS NOT NULL;

-- ── LOYALTY ACCOUNTS ───────────────────────────────────────────
CREATE TABLE loyalty_accounts (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id       UUID NOT NULL UNIQUE REFERENCES customers(id) ON DELETE CASCADE,
  points_balance    INTEGER NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
  points_earned_total INTEGER NOT NULL DEFAULT 0,
  points_redeemed_total INTEGER NOT NULL DEFAULT 0,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── SALES ──────────────────────────────────────────────────────
CREATE TABLE sales (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  customer_id       UUID REFERENCES customers(id) ON DELETE SET NULL,
  user_id           UUID REFERENCES profiles(id) ON DELETE SET NULL,
  invoice_no        TEXT NOT NULL,
  sale_date         TIMESTAMPTZ NOT NULL DEFAULT now(),
  subtotal          NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount_amount   NUMERIC(12,2) NOT NULL DEFAULT 0,
  taxable_amount    NUMERIC(12,2) NOT NULL DEFAULT 0,
  cgst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  sgst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  igst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_tax         NUMERIC(12,2) NOT NULL DEFAULT 0,
  grand_total       NUMERIC(12,2) NOT NULL DEFAULT 0,
  payment_method    TEXT NOT NULL DEFAULT 'cash',
  cash_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  upi_amount        NUMERIC(12,2) NOT NULL DEFAULT 0,
  card_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  points_redeemed   INTEGER NOT NULL DEFAULT 0,
  status            TEXT NOT NULL DEFAULT 'completed'
                    CHECK (status IN ('completed','returned','voided')),
  notes             TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX sales_invoice_store_idx ON sales(store_id, invoice_no);
CREATE INDEX sales_store_date_idx ON sales(store_id, sale_date DESC);
CREATE INDEX sales_customer_idx ON sales(customer_id);

-- ── SALE ITEMS ─────────────────────────────────────────────────
CREATE TABLE sale_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sale_id           UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id        UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name      TEXT NOT NULL,
  hsn_code          TEXT,
  quantity          NUMERIC(12,3) NOT NULL CHECK (quantity > 0),
  unit              TEXT NOT NULL DEFAULT 'pcs',
  unit_price        NUMERIC(12,2) NOT NULL,
  discount_percent  NUMERIC(5,2) NOT NULL DEFAULT 0,
  discount_amount   NUMERIC(12,2) NOT NULL DEFAULT 0,
  taxable_amount    NUMERIC(12,2) NOT NULL,
  gst_rate          NUMERIC(5,2) NOT NULL DEFAULT 0,
  cgst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  sgst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  igst_rate         NUMERIC(5,2) NOT NULL DEFAULT 0,
  cgst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  sgst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  igst_amount       NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_amount      NUMERIC(12,2) NOT NULL,
  batch_no          TEXT
);
CREATE INDEX sale_items_sale_idx ON sale_items(sale_id);
CREATE INDEX sale_items_product_idx ON sale_items(product_id);

-- ── SUPPLIERS ──────────────────────────────────────────────────
CREATE TABLE suppliers (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id            UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  gstin             TEXT,
  contact_person    TEXT,
  phone             TEXT,
  email             TEXT,
  address           TEXT,
  payment_terms     INTEGER NOT NULL DEFAULT 30,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX suppliers_org_idx ON suppliers(org_id);

-- ── PURCHASE ORDERS ────────────────────────────────────────────
CREATE TABLE purchase_orders (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  supplier_id       UUID NOT NULL REFERENCES suppliers(id),
  po_number         TEXT NOT NULL,
  order_date        DATE NOT NULL DEFAULT CURRENT_DATE,
  expected_date     DATE,
  subtotal          NUMERIC(12,2) NOT NULL DEFAULT 0,
  tax_amount        NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
  status            TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','sent','partial','received','cancelled')),
  notes             TEXT,
  created_by        UUID REFERENCES profiles(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX po_number_store_idx ON purchase_orders(store_id, po_number);
CREATE INDEX po_store_idx ON purchase_orders(store_id, created_at DESC);

-- ── PO ITEMS ───────────────────────────────────────────────────
CREATE TABLE po_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  po_id             UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES products(id),
  quantity          NUMERIC(12,3) NOT NULL CHECK (quantity > 0),
  unit_price        NUMERIC(12,2) NOT NULL,
  gst_rate          NUMERIC(5,2) NOT NULL DEFAULT 0,
  total_amount      NUMERIC(12,2) NOT NULL
);

-- ── GOODS RECEIPTS ─────────────────────────────────────────────
CREATE TABLE goods_receipts (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  po_id             UUID REFERENCES purchase_orders(id) ON DELETE SET NULL,
  supplier_id       UUID NOT NULL REFERENCES suppliers(id),
  grn_number        TEXT NOT NULL,
  receipt_date      DATE NOT NULL DEFAULT CURRENT_DATE,
  supplier_invoice_no TEXT,
  total_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
  received_by       UUID REFERENCES profiles(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX grn_store_idx ON goods_receipts(store_id, created_at DESC);

-- ── GRN ITEMS ──────────────────────────────────────────────────
CREATE TABLE grn_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  grn_id            UUID NOT NULL REFERENCES goods_receipts(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES products(id),
  ordered_qty       NUMERIC(12,3),
  received_qty      NUMERIC(12,3) NOT NULL CHECK (received_qty >= 0),
  unit_price        NUMERIC(12,2) NOT NULL,
  batch_no          TEXT,
  expiry_date       DATE,
  total_amount      NUMERIC(12,2) NOT NULL
);

-- ── EMPLOYEES ──────────────────────────────────────────────────
CREATE TABLE employees (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  full_name         TEXT NOT NULL,
  phone             TEXT,
  role              TEXT NOT NULL DEFAULT 'staff',
  base_salary       NUMERIC(12,2) NOT NULL DEFAULT 0,
  join_date         DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── CASH REGISTERS ─────────────────────────────────────────────
CREATE TABLE cash_registers (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id          UUID NOT NULL REFERENCES stores(id),
  register_date     DATE NOT NULL DEFAULT CURRENT_DATE,
  opening_balance   NUMERIC(12,2) NOT NULL DEFAULT 0,
  closing_balance   NUMERIC(12,2),
  cash_sales        NUMERIC(12,2) NOT NULL DEFAULT 0,
  cash_expenses     NUMERIC(12,2) NOT NULL DEFAULT 0,
  notes             TEXT,
  UNIQUE(store_id, register_date)
);

-- ================================================================
-- ROW LEVEL SECURITY POLICIES
-- ================================================================

ALTER TABLE organizations     ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores             ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories         ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_groups         ENABLE ROW LEVEL SECURITY;
ALTER TABLE products           ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory          ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements    ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_accounts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales              ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items         ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders    ENABLE ROW LEVEL SECURITY;
ALTER TABLE po_items           ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE grn_items          ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_registers     ENABLE ROW LEVEL SECURITY;

-- Helper function to get current user's org_id
CREATE OR REPLACE FUNCTION get_my_org_id()
RETURNS UUID AS $$
  SELECT org_id FROM profiles WHERE id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- Helper function to get current user's store_id
CREATE OR REPLACE FUNCTION get_my_store_id()
RETURNS UUID AS $$
  SELECT store_id FROM profiles WHERE id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- Helper function to get current user's role
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- RLS: Organizations — user can only see their own org
CREATE POLICY "orgs_self" ON organizations
  FOR ALL USING (id = get_my_org_id());

-- RLS: Stores — user can see stores in their org
CREATE POLICY "stores_own_org" ON stores
  FOR ALL USING (org_id = get_my_org_id());

-- RLS: Products — all users in org can read; manager/owner can write
CREATE POLICY "products_read_own_org" ON products
  FOR SELECT USING (org_id = get_my_org_id());
CREATE POLICY "products_write_manager" ON products
  FOR INSERT WITH CHECK (org_id = get_my_org_id()
    AND get_my_role() IN ('owner','manager'));
CREATE POLICY "products_update_manager" ON products
  FOR UPDATE USING (org_id = get_my_org_id()
    AND get_my_role() IN ('owner','manager'));

-- RLS: Sales — cashier can create; all in org can read own store's sales
CREATE POLICY "sales_read_own_store" ON sales
  FOR SELECT USING (
    store_id IN (SELECT id FROM stores WHERE org_id = get_my_org_id())
    AND (get_my_role() IN ('owner','manager') OR store_id = get_my_store_id())
  );
CREATE POLICY "sales_insert_cashier" ON sales
  FOR INSERT WITH CHECK (store_id = get_my_store_id());

-- RLS: Profiles — users can see their own profile and profiles in their org
CREATE POLICY "profiles_own" ON profiles
  FOR SELECT USING (id = auth.uid() OR org_id = get_my_org_id());
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (id = auth.uid());
```

---

## SECTION 5 — SEQUENCE DIAGRAMS (Pressman Ch 8.4.2)

### SEQ-01: Process a Sale

```
Cashier    POS_Screen    CartManager    TaxCalc    DB         InvoiceGen
  |             |              |           |         |              |
  |--scanBarcode→|             |           |         |              |
  |             |--queryProduct(barcode)-->|         |              |
  |             |<--------------product{}---------   |              |
  |             |--addToCart(product,qty=1)→|        |              |
  |             |              |--calcGST(taxable,rate,isIntraState)→|
  |             |              |<------{cgst,sgst,total}----------  |
  |             |<-cartUpdated(total)------  |        |              |
  |--adjustQty→ |              |            |         |              |
  |             |--updateCart(product,qty)→ |         |              |
  |             |<-cartUpdated(newTotal)---  |        |              |
  |--selectPayment(cash,tendered)→|          |        |              |
  |             |--confirmBill()→|           |         |              |
  |             |              |--createSale(items,payment)→        |
  |             |              |            |---INSERT sale-------->  |
  |             |              |            |---INSERT sale_items-->  |
  |             |              |            |---UPDATE inventory-->   |
  |             |              |            |---INSERT journal_entry→ |
  |             |              |            |<--sale{id,invoice_no}-- |
  |             |              |            |         |--generatePDF(sale)→
  |             |              |            |         |<--pdfUrl-------  |
  |             |<-billConfirmed(invoice,pdfUrl)------  |              |
  |<-showReceipt(invoice,pdfUrl)|           |         |              |
```

---

### SEQ-02: Register New Shop Owner

```
Owner    RegisterForm    AuthService    DB_Supabase    OrgService
  |           |               |               |              |
  |--fillForm(biz,user,store)→|              |              |
  |           |--signUpEmail(email,pass)----->|              |
  |           |               |--CREATE auth.user----------->|
  |           |               |<------userId-----------------|
  |           |--createOrg(name,gstin)------->|              |
  |           |               |    |----------INSERT org---->|
  |           |               |    |<---------org{id}--------|
  |           |--createStore(orgId,storeName)→|              |
  |           |               |    |----------INSERT store-->|
  |           |--createProfile(userId,orgId,storeId,'owner')→|
  |           |               |    |----------INSERT profile>|
  |           |--seedTaxGroups(orgId)-------->|              |
  |           |               |    |----------INSERT 5 slabs>|
  |           |<------onboardingComplete------|              |
  |<-redirect(/dashboard)-----|               |              |
```

---

## SECTION 6 — STATE DIAGRAMS (Pressman Ch 8.5.2)

### STATE-01: Sale Status

```
                   cashier opens POS
                          │
                          ▼
                    ┌──────────┐
                    │  DRAFT   │  (cart being built)
                    └──────────┘
                          │ cashier confirms bill + payment
                          ▼
                   ┌────────────┐
                   │ COMPLETED  │  (stock deducted, invoice generated)
                   └────────────┘
                    │          │
    customer returns│          │manager voids
    within 7 days   │          │(billing error)
                    ▼          ▼
              ┌──────────┐  ┌────────┐
              │ RETURNED │  │ VOIDED │
              └──────────┘  └────────┘
              (credit note    (all entries
               generated,      reversed,
               stock restored) no credit note)
```

### STATE-02: Inventory Stock Level

```
                   product created (qty=0)
                          │
                          ▼
                   ┌─────────────┐
                   │  OUT_OF_STOCK│  qty = 0
                   └─────────────┘
                          │ GRN received (qty > 0)
                          ▼
                   ┌─────────────┐
                   │   IN_STOCK  │  qty > reorder_level
                   └─────────────┘
               ▲          │ qty drops to ≤ reorder_level
               │GRN        ▼
               │   ┌──────────────┐
               └───│  LOW_STOCK   │  0 < qty ≤ reorder_level
                   └──────────────┘  (alert triggered)
                          │ qty drops to 0
                          ▼
                   ┌─────────────┐
                   │ OUT_OF_STOCK│  (POS shows warning on sale attempt)
                   └─────────────┘
```

### STATE-03: Purchase Order Status

```
           manager creates PO
                  │
                  ▼
            ┌──────────┐
            │  DRAFT   │  (not yet sent to supplier)
            └──────────┘
                  │ manager sends to supplier
                  ▼
            ┌──────────┐
            │   SENT   │  (awaiting delivery)
            └──────────┘
              │       │
  partial GRN │       │ cancelled
  received    │       ▼
              │   ┌──────────┐
              │   │CANCELLED │
              │   └──────────┘
              ▼
       ┌─────────────┐
       │   PARTIAL   │  (some items received)
       └─────────────┘
              │ all items received
              ▼
       ┌────────────┐
       │  RECEIVED  │  (full GRN confirmed)
       └────────────┘
              │ invoice matched + payment done
              ▼
        ┌────────┐
        │ CLOSED │
        └────────┘
```

---

### HOW TO RUN schema.sql IN SUPABASE

1. Go to **supabase.com** → Your project → **SQL Editor**
2. Click **New query**
3. Paste the entire SQL from Section 4
4. Click **Run** (▶)
5. You should see "Success. No rows returned" for each statement
6. Go to **Table Editor** — you should see all 19 tables
7. Go to **Authentication → Policies** — you should see RLS policies on all tables

---

*DATA_MODELS.md v1.0*
*Pressman SEPA 9th Edition — Ch 8 (Requirements Modeling)*
*Schema ready to run in Supabase SQL Editor*
