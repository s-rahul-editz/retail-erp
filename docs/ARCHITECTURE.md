# ARCHITECTURE.md
# RetailOS — Software Architecture
# Pressman Ch 9 (Design Concepts) + Ch 10 (Architectural Design) + Ch 11 (Component Design)
# Version: 1.0 | Day 4

---

## SECTION 1 — ARCHITECTURAL DECISIONS (Pressman Ch 10.2)

| # | Decision | Chosen | Rejected | Reason |
|---|---|---|---|---|
| AD-01 | Frontend framework | React + Vite | Next.js | No SSR needed; Vite is faster; simpler to deploy on Vercel as SPA |
| AD-02 | Database + Auth | Supabase (PostgreSQL) | Firebase | SQL is right for relational ERP data; Supabase RLS is perfect for multi-tenant isolation |
| AD-03 | Styling | Tailwind CSS | CSS Modules / Styled Components | Utility-first = fastest to build; no CSS file switching; great mobile support |
| AD-04 | State management | React Context + hooks | Redux | Redux is overkill for 2-person team; Context handles auth/store state; local state handles UI |
| AD-05 | API layer | Supabase direct + Vercel Functions | Express.js backend | No separate server needed; Supabase handles CRUD + RLS; Vercel for heavy compute (PDF/reports) |
| AD-06 | PDF generation | jsPDF (client-side) | Puppeteer/server PDF | Free tier Vercel has 10s timeout; client-side PDF avoids timeout; no server needed |
| AD-07 | Authentication | Supabase Auth (JWT) | Custom JWT | Battle-tested; handles refresh tokens, email verification, social auth; zero maintenance |
| AD-08 | Hosting | Vercel | Netlify / Railway | Best GitHub integration; auto-deploys on push; free tier generous; edge network fast in India |

---

## SECTION 2 — 4-LAYER ARCHITECTURE (Pressman Ch 10.3)

```
╔══════════════════════════════════════════════════════════════════╗
║  LAYER 1: PRESENTATION (React Components)                        ║
║  ─────────────────────────────────────────────────────────────── ║
║  pages/        Route-level pages (LoginPage, POSPage, etc.)     ║
║  components/   UI components per module (POS/, Inventory/, etc.) ║
║  context/      Global state (AuthContext, StoreContext)          ║
║  hooks/        Custom React hooks (useCart, useInventory, etc.)  ║
║                                                                   ║
║  Rules: NO direct Supabase calls. NO business logic.             ║
║         Only renders state. Calls services. Shows results.       ║
╠══════════════════════════════════════════════════════════════════╣
║  LAYER 2: BUSINESS LOGIC (Services)                              ║
║  ─────────────────────────────────────────────────────────────── ║
║  services/pos.js        Bill creation, cart, payment processing  ║
║  services/inventory.js  Stock deduction, transfer, alerts        ║
║  services/gst.js        ALL GST calculation logic                ║
║  services/invoice.js    PDF generation (jsPDF)                   ║
║  services/reports.js    Data aggregation for reports             ║
║                                                                   ║
║  Rules: NO React. NO UI. Pure JavaScript functions.              ║
║         Calls database layer. Returns processed data.            ║
╠══════════════════════════════════════════════════════════════════╣
║  LAYER 3: DATA ACCESS (Supabase Client)                          ║
║  ─────────────────────────────────────────────────────────────── ║
║  supabase/client.js     Supabase client initialization           ║
║  supabase/auth.js       Authentication functions                 ║
║  supabase/database.js   All database read/write operations       ║
║                                                                   ║
║  Rules: NO business logic. NO UI. Just DB operations.            ║
║         Returns raw data to services layer.                      ║
╠══════════════════════════════════════════════════════════════════╣
║  LAYER 4: INFRASTRUCTURE                                         ║
║  ─────────────────────────────────────────────────────────────── ║
║  Supabase Cloud     PostgreSQL + Auth + Realtime + Storage       ║
║  Vercel             Frontend hosting + Serverless Functions       ║
║  GitHub             Version control + CI/CD                      ║
╚══════════════════════════════════════════════════════════════════╝

DATA FLOW (Happy Path — Process a Sale):
  Cashier clicks "Confirm Bill"
    → POSPage (Layer 1)
    → calls createBill(cartItems, payment) from services/pos.js (Layer 2)
    → pos.js calls calculateGST() from utils/gst.js
    → pos.js calls database.createSale(saleData) from supabase/database.js (Layer 3)
    → database.js runs Supabase INSERT on sales + sale_items (Layer 4)
    → database.js calls database.deductStock() for each item
    → returns {saleId, invoiceNo}
    → pos.js calls invoice.generatePDF(saleData)
    → returns {pdfBlob, pdfUrl}
    → POSPage receives result and shows ReceiptModal
```

---

## SECTION 3 — DESIGN CONCEPTS (Pressman Ch 9.3)

### Abstraction (Ch 9.3.1)
**Procedural abstraction** — `database.createSale()` hides 4 SQL operations behind one call:
```js
// UI calls this — doesn't know about SQL
const result = await createSale(cartItems, payment, customerId)

// Inside database.js — all complexity hidden
export async function createSale(items, payment, customerId) {
  const saleId = uuid()
  await supabase.from('sales').insert(buildSaleRecord(...))
  await supabase.from('sale_items').insert(buildSaleItems(...))
  await deductStock(items)
  await postJournalEntry(saleId, payment)
  return { saleId, invoiceNo: await getNextInvoiceNo() }
}
```

**Data abstraction** — `Product` type encapsulates all product data:
```js
// Product is always the same shape across the app
const product = {
  id, name, barcode, sellingPrice, gstRate,
  cgstRate, sgstRate, unit, hsnCode, qtyOnHand
}
```

---

### Modularity (Ch 9.3.5)
Each ERP module is a folder with its own components, and calls only the services it owns.

```
Module dependency rules (who can call whom):
  POS           → can call: Inventory (stock check), CRM (loyalty), GST (calc)
  Inventory     → can call: nothing (pure data management)
  Purchase      → can call: Inventory (on GRN confirm)
  CRM           → can call: nothing (pure data management)
  Accounting    → can call: nothing (receives events from other modules)
  Reports       → can call: all modules (read-only aggregation)

  ❌ Inventory must NOT call POS
  ❌ CRM must NOT call Purchase
  ❌ No circular dependencies
```

---

### Information Hiding (Ch 9.3.6)
- **RLS hides other orgs' data** — UI cannot query `SELECT * FROM sales` — RLS filters to own org automatically
- **`.env` hides keys** — `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` never hardcoded
- **Service layer hides GST logic** — UI just receives `{ cgst, sgst, total }` — never knows the formula

---

### Separation of Concerns (Ch 9.3.4)

| Layer | Files | Concern |
|---|---|---|
| UI | `components/`, `pages/` | What to show, user interactions |
| State | `context/`, `hooks/` | What data is currently active |
| Business | `services/` | How to process business rules |
| Data | `supabase/` | How to read/write the database |
| Utilities | `utils/` | Pure functions, no side effects |
| Config | `utils/constants.js` | All magic numbers in one place |

---

## SECTION 4 — COMPONENT SPECIFICATIONS (Pressman Ch 11)

### Component: POS Module
```
Responsibility: All billing — cart management, payment, bill confirmation
Exposes:
  - POSPage (route component)
  - useCart() hook: { items, addItem, removeItem, updateQty, applyDiscount, clear }
  - usePOSSearch() hook: { results, search, loading }
Services it calls: services/pos.js, services/gst.js, services/invoice.js
DB tables it writes: sales, sale_items, stock_movements, loyalty_accounts
Events it emits: 'sale:created' (Supabase Realtime)
State it manages: cart items, payment mode, customer selection, receipt modal
```

### Component: Inventory Module
```
Responsibility: Stock tracking, low-stock alerts, product master
Exposes:
  - ProductsPage, AddProductPage, InventoryPage
  - useInventory(storeId) hook: { inventory, lowStockItems, adjustStock }
Services it calls: services/inventory.js
DB tables it writes: products, inventory, stock_movements
Events it listens to: 'sale:created' (auto-deducts stock)
State it manages: product list, stock levels, filter state
```

### Component: Purchase Module
```
Responsibility: Supplier management, POs, GRNs, payables
Exposes:
  - PurchasePage, NewPOPage, GRNPage
  - usePurchase(storeId) hook: { orders, createPO, receiveGRN }
Services it calls: services/purchase.js
DB tables it writes: purchase_orders, po_items, goods_receipts, grn_items
Triggers: inventory update on GRN confirm
State it manages: PO list, GRN form, supplier list
```

### Component: CRM Module
```
Responsibility: Customer profiles, loyalty, credit (udhar)
Exposes:
  - CustomersPage, CustomerProfilePage
  - useCustomer(phone) hook: { customer, loyaltyBalance, purchaseHistory }
Services it calls: services/crm.js
DB tables it writes: customers, loyalty_accounts
State it manages: customer search results, selected customer
```

### Component: Accounting Module
```
Responsibility: GST reports, P&L, cash register, journal entries
Exposes:
  - ReportsPage, GSTReportPage, CashRegisterPage
  - useReports(storeId, dateRange) hook: { salesData, gstData, loading }
Services it calls: services/reports.js, services/gst.js
DB tables it reads: sales, sale_items, purchase_orders, grn_items, journal_entries
State it manages: date range filter, report data, export state
```

---

*ARCHITECTURE.md v1.0 — Pressman Ch 9, 10, 11*
