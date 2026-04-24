-- ================================================================
-- retail-erp Complete PostgreSQL Schema
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