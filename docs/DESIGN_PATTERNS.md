# DESIGN_PATTERNS.md
# RetailOS — Design Patterns + Folder Structure + Anti-Patterns
# Pressman Ch 14 (Pattern-Based Design)
# Version: 1.0 | Day 4

---

## SECTION 1 — DESIGN PATTERNS (Pressman Ch 14.4)

---

### PATTERN 1: Repository Pattern
**Where used**: `supabase/database.js` is our Repository
**Why**: Decouples business logic from database; if we switch from Supabase to another DB, only database.js changes — services and UI are untouched.

```js
// supabase/database.js — Repository interface
export const ProductRepository = {
  findById: (id) => supabase.from('products').select('*').eq('id', id).single(),
  findByBarcode: (orgId, barcode) =>
    supabase.from('products').select('*').eq('org_id', orgId).eq('barcode', barcode).single(),
  findAll: (orgId, search) =>
    supabase.from('products').select('*, tax_groups(*), inventory(*)')
      .eq('org_id', orgId)
      .ilike('name', `%${search}%`)
      .eq('is_active', true),
  save: (product) => supabase.from('products').insert(product),
  update: (id, changes) => supabase.from('products').update(changes).eq('id', id),
}

// services/inventory.js — calls repository, never Supabase directly
import { ProductRepository } from '../supabase/database'
export async function searchProducts(orgId, query) {
  const { data, error } = await ProductRepository.findAll(orgId, query)
  if (error) throw new Error('Product search failed')
  return data
}
```

---

### PATTERN 2: Observer Pattern (Supabase Realtime)
**Where used**: Dashboard listens to live sales; Inventory listens to stock changes
**Why**: Cashier bills on one device → owner's dashboard phone updates automatically without page refresh.

```js
// supabase/database.js — Observable (emits changes)
export function subscribeToStoreSales(storeId, onNewSale) {
  return supabase
    .channel(`sales:store_id=eq.${storeId}`)
    .on('postgres_changes', {
      event: 'INSERT', schema: 'public', table: 'sales',
      filter: `store_id=eq.${storeId}`
    }, (payload) => onNewSale(payload.new))
    .subscribe()
}

// components/Dashboard/SalesWidget.jsx — Observer (listens)
useEffect(() => {
  const channel = subscribeToStoreSales(storeId, (newSale) => {
    setTodaySales(prev => prev + newSale.grand_total)
    setBillCount(prev => prev + 1)
  })
  return () => supabase.removeChannel(channel) // cleanup
}, [storeId])
```

---

### PATTERN 3: Context/Provider Pattern
**Where used**: `AuthContext` (who is logged in), `StoreContext` (which store is active)
**Why**: Avoids prop-drilling auth data through 6+ component levels.

```jsx
// context/AuthContext.jsx — Provider
export function AuthProvider({ children }) {
  const [currentUser, setCurrentUser] = useState(null)
  const [orgId, setOrgId] = useState(null)
  const [storeId, setStoreId] = useState(null)
  const [userRole, setUserRole] = useState(null)

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (session) {
          const profile = await getUserProfile(session.user.id)
          setCurrentUser(session.user)
          setOrgId(profile.org_id)
          setStoreId(profile.store_id)
          setUserRole(profile.role)
        } else {
          setCurrentUser(null)
        }
      }
    )
    return () => subscription.unsubscribe()
  }, [])

  return (
    <AuthContext.Provider value={{ currentUser, orgId, storeId, userRole }}>
      {children}
    </AuthContext.Provider>
  )
}

// Any component — Consumer
function SalesReport() {
  const { orgId, storeId, userRole } = useAuth()
  // No props needed — got it from context
}
```

---

### PATTERN 4: Strategy Pattern
**Where used**: GST calculation (intra-state vs inter-state)
**Why**: Two different tax calculation strategies — same interface, different logic.

```js
// utils/gst.js — Strategy interface
const GSTStrategies = {
  intraState: {
    calculate: (taxableAmount, gstRate) => ({
      cgst: round2(taxableAmount * (gstRate / 2) / 100),
      sgst: round2(taxableAmount * (gstRate / 2) / 100),
      igst: 0,
      totalTax: round2(taxableAmount * gstRate / 100)
    })
  },
  interState: {
    calculate: (taxableAmount, gstRate) => ({
      cgst: 0,
      sgst: 0,
      igst: round2(taxableAmount * gstRate / 100),
      totalTax: round2(taxableAmount * gstRate / 100)
    })
  }
}

// Context selects strategy
export function calculateItemGST(taxableAmount, gstRate, isInterState) {
  const strategy = isInterState
    ? GSTStrategies.interState
    : GSTStrategies.intraState
  return strategy.calculate(taxableAmount, gstRate)
}
```

---

### PATTERN 5: Factory Pattern
**Where used**: Invoice generation — different formats for B2B vs B2C
**Why**: Invoice structure differs (B2B needs buyer GSTIN, B2C doesn't). Factory creates right format.

```js
// services/invoice.js — Factory
function InvoiceFactory(sale, org, customer) {
  if (customer?.gstin) {
    return new B2BInvoice(sale, org, customer)  // Full GSTIN invoice
  } else {
    return new B2CInvoice(sale, org, customer)  // Simplified invoice
  }
}

class B2BInvoice {
  generate() { /* includes buyer GSTIN, full address, place of supply */ }
}
class B2CInvoice {
  generate() { /* simplified — just customer name if available */ }
}
```

---

### PATTERN 6: Composite Pattern
**Where used**: Cart (CartItems → Cart total), Multi-store (Store views → HQ view)
**Why**: HQ dashboard is a composition of all store dashboards.

```js
// Cart is a composite of CartItems
class Cart {
  constructor() { this.items = [] }
  add(item) { this.items.push(item) }
  getSubtotal() { return this.items.reduce((sum, i) => sum + i.getTotal(), 0) }
  getTotalGST() { return this.items.reduce((sum, i) => sum + i.getTax(), 0) }
  getGrandTotal() { return this.getSubtotal() + this.getTotalGST() }
}
// HQ view is a composite of Store views
class HQDashboard {
  constructor(stores) { this.stores = stores }
  getTotalRevenue() { return this.stores.reduce((sum, s) => sum + s.getRevenue(), 0) }
}
```

---

## SECTION 2 — COMPLETE FOLDER STRUCTURE

```
retail-erp/
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                  # Build check on every push to dev
│   │   └── pr-check.yml            # PR checklist on main PR
│   └── PULL_REQUEST_TEMPLATE.md    # Standardized PR format
│
├── database/
│   ├── schema.sql                  # Complete PostgreSQL schema (Day 3)
│   ├── seed_data.sql               # Sample data for testing
│   └── migrations/                 # Future schema changes (versioned)
│       └── .gitkeep
│
├── docs/                           # All Pressman documentation
│   ├── ENGINEERING_PLAN.md         # Day 1 — Project charter
│   ├── RISK_REGISTER.md            # Day 1 — Risk management
│   ├── SCRUM_SETUP.md              # Day 1 — Scrum ceremonies + backlog
│   ├── SHOP_RESEARCH.md            # Day 2 — Field research
│   ├── REQUIREMENTS_SPECIFICATION.md # Day 2 — FRs + NFRs
│   ├── USE_CASES.md                # Day 2 — 10 use cases
│   ├── DATA_MODELS.md              # Day 3 — ERD + schema + sequences
│   ├── WIREFRAME_SPECS.md          # Day 3 — Screen specifications
│   ├── ARCHITECTURE.md             # Day 4 — System architecture
│   ├── DESIGN_PATTERNS.md          # Day 4 — Patterns + folder structure
│   └── QUALITY_PLAN.md             # Day 7 — Quality plan + metrics
│
└── frontend/                       # React application
    │
    ├── .env                        # NOT committed — local secrets only
    ├── .env.example                # Committed — shows required env vars
    ├── .eslintrc.cjs               # ESLint rules
    ├── .gitignore                  # node_modules, .env, dist
    ├── index.html                  # Entry HTML with meta tags + fonts
    ├── package.json                # Dependencies + scripts
    ├── tailwind.config.js          # Design system tokens
    ├── vite.config.js              # Vite config (@alias, host)
    │
    ├── api/                        # Vercel Serverless Functions
    │   ├── gst/
    │   │   └── validate-gstin.js   # GSTIN validation API
    │   ├── reports/
    │   │   └── generate-excel.js   # Excel export (heavy compute)
    │   └── invoices/
    │       └── generate-pdf.js     # Server-side PDF (if needed)
    │
    └── src/
        │
        ├── main.jsx                # React root + providers + toaster
        ├── App.jsx                 # Router + routes + lazy loading
        ├── globals.css             # Tailwind directives + component classes
        │
        ├── supabase/               # Layer 3: Data Access
        │   ├── client.js           # Supabase client singleton
        │   ├── auth.js             # 10 auth functions
        │   └── database.js         # All CRUD operations
        │
        ├── services/               # Layer 2: Business Logic
        │   ├── pos.js              # Bill creation, payment processing
        │   ├── inventory.js        # Stock deduction, transfers
        │   ├── purchase.js         # PO creation, GRN processing
        │   ├── crm.js              # Customer management, loyalty
        │   ├── gst.js              # GST calculation (pure functions)
        │   ├── invoice.js          # PDF generation (jsPDF)
        │   └── reports.js          # Data aggregation for reports
        │
        ├── context/                # Global State
        │   ├── AuthContext.jsx     # currentUser, orgId, storeId, role
        │   └── StoreContext.jsx    # active store, store list
        │
        ├── hooks/                  # Custom React Hooks
        │   ├── useCart.js          # Cart state management
        │   ├── useInventory.js     # Stock data + low-stock
        │   ├── useCustomer.js      # Customer lookup + loyalty
        │   ├── useSales.js         # Sales data + realtime
        │   ├── useReports.js       # Report data with filters
        │   └── useDebounce.js      # Debounce for search inputs
        │
        ├── utils/                  # Pure Utility Functions
        │   ├── constants.js        # All constants (GST rates, states, etc.)
        │   ├── formatters.js       # Currency, date, number formatting
        │   ├── validators.js       # Input validation functions
        │   └── helpers.js          # UUID gen, debounce, misc
        │
        ├── components/             # Reusable UI Components
        │   ├── ui/                 # Generic UI (used everywhere)
        │   │   ├── Button.jsx
        │   │   ├── Input.jsx
        │   │   ├── Modal.jsx
        │   │   ├── DataTable.jsx
        │   │   ├── Badge.jsx
        │   │   ├── KPICard.jsx
        │   │   ├── PageHeader.jsx
        │   │   └── Spinner.jsx
        │   ├── layout/             # App-wide layout components
        │   │   ├── AppLayout.jsx   # Sidebar + header + content wrapper
        │   │   ├── Sidebar.jsx
        │   │   ├── Header.jsx
        │   │   └── ProtectedRoute.jsx
        │   ├── pos/                # POS-specific components
        │   │   ├── ProductSearch.jsx
        │   │   ├── CartItem.jsx
        │   │   ├── CartSummary.jsx
        │   │   ├── PaymentModal.jsx
        │   │   ├── ReceiptModal.jsx
        │   │   └── CustomerSearchBar.jsx
        │   ├── inventory/          # Inventory-specific components
        │   │   ├── ProductForm.jsx
        │   │   ├── StockAdjustForm.jsx
        │   │   └── LowStockBadge.jsx
        │   ├── purchase/           # Purchase-specific components
        │   │   ├── POForm.jsx
        │   │   └── GRNForm.jsx
        │   ├── crm/
        │   │   └── CustomerCard.jsx
        │   └── reports/
        │       ├── SalesChart.jsx
        │       └── GSTTable.jsx
        │
        └── pages/                  # Route-Level Pages
            ├── auth/
            │   ├── LoginPage.jsx
            │   ├── RegisterPage.jsx
            │   └── ForgotPasswordPage.jsx
            ├── DashboardPage.jsx
            ├── pos/
            │   └── POSPage.jsx
            ├── inventory/
            │   ├── ProductsPage.jsx
            │   ├── AddProductPage.jsx
            │   └── InventoryPage.jsx
            ├── purchase/
            │   ├── PurchasePage.jsx
            │   └── NewPOPage.jsx
            ├── customers/
            │   ├── CustomersPage.jsx
            │   └── CustomerProfilePage.jsx
            ├── reports/
            │   ├── ReportsPage.jsx
            │   ├── SalesReportPage.jsx
            │   └── GSTReportPage.jsx
            ├── settings/
            │   └── SettingsPage.jsx
            └── NotFoundPage.jsx
```

---

## SECTION 3 — ANTI-PATTERNS TO AVOID (Pressman Ch 14.5)

### Anti-Pattern 1: God Component
**Problem**: One React component handles 500+ lines — POS cart, product search, payment, receipt all in `POSPage.jsx`
**Why bad**: Impossible to test, impossible to reuse, impossible for Sanjana to understand
**Solution**: Split by responsibility — `ProductSearch`, `CartItem`, `PaymentModal`, `ReceiptModal` are separate components
**Rule**: If a component exceeds 150 lines, split it

### Anti-Pattern 2: Direct Supabase in UI Components
**Problem**: `await supabase.from('sales').insert({...}).select()` called directly inside a React component
**Why bad**: Business logic (GST calculation, stock deduction, accounting) gets scattered in UI files; impossible to test; no single place to change behavior
**Solution**: All Supabase calls go through `supabase/database.js`; UI only calls `services/pos.js`

### Anti-Pattern 3: Hardcoded GST Rates
**Problem**: `const cgst = amount * 0.09` scattered across 12 files
**Why bad**: When GST law changes (it does), you need to find and change 12 places
**Solution**: All rates in `utils/constants.js` GST_RATES array; all calculation in `services/gst.js`

### Anti-Pattern 4: No Error Boundaries
**Problem**: jsPDF crashes while generating invoice → entire React app shows blank white screen
**Why bad**: One error takes down the whole app — shop cannot bill at all
**Solution**: Wrap each module in a React ErrorBoundary component; errors show a fallback UI with "Retry" button

### Anti-Pattern 5: N+1 Query Problem
**Problem**: Fetching 50 sale items then calling `SELECT * FROM products WHERE id = ?` in a loop (50 queries)
**Why bad**: 50 extra DB calls on every POS page load; Supabase free tier rate-limited; very slow
**Solution**: Use Supabase `select('*, products(*)')` to JOIN in one query; batch all fetches

### Anti-Pattern 6: Keys in Code
**Problem**: `const supabase = createClient('https://xyz.supabase.co', 'eyJhbGc...')` committed to GitHub
**Why bad**: GitHub scans public repos; even private repos should not have secrets; rotated keys break old commits
**Solution**: Always `import.meta.env.VITE_SUPABASE_URL`; `.env` in `.gitignore`; `.env.example` with placeholder values

### Anti-Pattern 7: No Loading States
**Problem**: User taps "Confirm Bill" → nothing happens for 2 seconds → taps again → creates 2 bills
**Why bad**: Double billing, duplicate invoices, incorrect stock deduction — very hard to reverse
**Solution**: Button shows spinner immediately on tap; disabled while pending; `isSubmitting` state prevents double-submit

### Anti-Pattern 8: Feature Envy
**Problem**: `POSPage.jsx` directly reads supplier data from `suppliers` table to suggest reorder
**Why bad**: POS module now depends on Purchase module's data model; any supplier table change breaks POS
**Solution**: POS module only reads `products` and `inventory`; low-stock notification is Inventory module's responsibility

---

*DESIGN_PATTERNS.md v1.0*
*Pressman SEPA 9th Edition — Ch 14 (Pattern-Based Design)*
