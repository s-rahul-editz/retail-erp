# REQUIREMENTS_SPECIFICATION.md
# RetailOS — Software Requirements Specification (SRS)
# Applying Pressman's Software Engineering (9th Ed.) Chapter 7
# Version: 1.0 | Day 2 | Based on: SHOP_RESEARCH.md + Competitor Analysis

---

## SECTION 1 — STAKEHOLDER ANALYSIS (Pressman Ch 7.2.1)

### 1.1 Primary Stakeholders

---

**STAKEHOLDER 1: Shop Owner**
- **Goals**: Maximize revenue, minimize theft/loss, file GST correctly, see business health at any time
- **Inputs**: Business configuration, product pricing, staff permissions, purchase approvals
- **Gets from system**: Dashboard KPIs, P&L reports, GST reports, inventory valuation
- **Technical skill**: Low to medium (comfortable with smartphones, not with software)
- **Device**: Mobile phone (primary), desktop/tablet (secondary)
- **Language**: Hindi or regional language preferred; English labels acceptable
- **Key concern**: "Is my business profitable today?"

---

**STAKEHOLDER 2: Cashier**
- **Goals**: Process bills quickly with zero errors, handle any payment mode
- **Inputs**: Product scans/searches, quantities, discounts, payment amounts
- **Gets from system**: Completed bill, change amount, receipt for WhatsApp sharing
- **Technical skill**: Low (can use WhatsApp and phone apps, but not enterprise software)
- **Device**: Mobile phone or shared tablet at billing counter
- **Language**: Local language preferred; minimal English UI labels acceptable
- **Key concern**: "Can I bill this customer in under 60 seconds?"

---

**STAKEHOLDER 3: Store Manager**
- **Goals**: Keep stock levels optimal, process purchases efficiently, manage staff
- **Inputs**: Stock adjustments, purchase orders, GRNs, staff attendance
- **Gets from system**: Low-stock alerts, reorder suggestions, purchase history, staff reports
- **Technical skill**: Medium (comfortable with computers and apps)
- **Device**: Desktop/laptop (primary), mobile (secondary)
- **Language**: English acceptable
- **Key concern**: "Is my inventory under control? What do I need to order?"

---

**STAKEHOLDER 4: CA / Accountant**
- **Goals**: File accurate GSTR-1 and GSTR-3B monthly, prepare P&L and balance sheet
- **Inputs**: Validated transaction data from RetailOS (via export)
- **Gets from system**: GSTR-1 report, GSTR-3B summary, HSN summary, Excel exports
- **Technical skill**: High (daily Tally/software user)
- **Device**: Desktop
- **Language**: English
- **Key concern**: "Is this GST data clean and in the right format?"

---

**STAKEHOLDER 5: Customer (End User of the Shop)**
- **Goals**: Get their bill quickly, receive digital receipt, be recognized as loyal customer
- **Inputs**: They do not interact with RetailOS directly
- **Gets from system**: WhatsApp receipt, loyalty points balance (shown at POS)
- **Technical skill**: Varies
- **Device**: Mobile phone (receives WhatsApp receipt)
- **Key concern**: "Is my bill correct? Can I get a digital copy?"

---

**STAKEHOLDER 6: Supplier / Distributor**
- **Goals**: Receive clear POs, get paid on time
- **Inputs**: Responds to Purchase Orders (via WhatsApp or email)
- **Gets from system**: Purchase Orders (PDF/WhatsApp), payment records
- **Technical skill**: Low to medium
- **Device**: Mobile phone
- **Key concern**: "Has the shop sent me a PO? When will they pay?"

---

**STAKEHOLDER 7: Government / GST Authority (Indirect Stakeholder)**
- **Goals**: Accurate GST collection and filing from all registered businesses
- **Inputs**: Filed returns (GSTR-1, GSTR-3B) — filed externally by CA, data from RetailOS
- **Gets from system**: Indirectly — accurate GST data through CA-filed returns
- **Technical skill**: N/A (does not use RetailOS directly)
- **Key concern**: "Are GST amounts correct and filed on time?"

---

### 1.2 Stakeholder Impact Matrix

| Stakeholder | Usage Frequency | Business Impact if System Fails | Priority |
|---|---|---|---|
| Cashier | Every transaction (100x/day) | Cannot bill customers — shop stops | Critical |
| Shop Owner | Daily (reports, settings) | Blind to business health | High |
| Store Manager | Daily (stock, purchase) | Cannot manage inventory | High |
| CA/Accountant | Monthly (GST filing) | Incorrect returns, penalties | High |
| Customer | Every purchase | Poor experience, lost loyalty | Medium |
| Supplier | Weekly | Delayed POs, payment issues | Medium |

---

## SECTION 2 — FUNCTIONAL REQUIREMENTS (Pressman Ch 7.1.5)

**Format**: `FR-[MODULE]-[NUMBER]: The system shall [requirement]`
**Each FR is**: Specific, Measurable, Testable

---

### FR-AUTH — Authentication

| ID | Requirement |
|---|---|
| FR-AUTH-001 | The system shall allow a shop owner to register a new organisation by providing: business name, GSTIN, registered address, phone number, email, and password. |
| FR-AUTH-002 | The system shall validate the GSTIN format (15-character alphanumeric) during registration and reject invalid formats with an explanatory error message. |
| FR-AUTH-003 | The system shall authenticate users via email and password, maintaining session persistence across browser refreshes using Supabase JWT tokens. |
| FR-AUTH-004 | The system shall support role-based access control with three roles: Owner (full access), Manager (no financial settings), Cashier (POS and basic inventory only). |
| FR-AUTH-005 | The system shall allow the Owner to invite team members by email, assign a role, and the invitee shall receive an email to set their password. |

---

### FR-POS — Point of Sale / Billing

| ID | Requirement |
|---|---|
| FR-POS-001 | The system shall allow a cashier to search for products by name (partial match, minimum 2 characters) and return results within 500 milliseconds. |
| FR-POS-002 | The system shall allow a cashier to search for products by barcode number with an exact match, returning the product instantly. |
| FR-POS-003 | The system shall automatically calculate CGST and SGST at equal halves of the applicable GST rate for intra-state transactions. |
| FR-POS-004 | The system shall automatically calculate IGST at the full applicable GST rate for inter-state transactions, determined by comparing seller and buyer state codes. |
| FR-POS-005 | The system shall apply any item-level discount (in % or ₹) to the base price before calculating GST, such that tax is applied only on the post-discount taxable value. |
| FR-POS-006 | The system shall allow a bill-level discount (in % or ₹) that is distributed proportionally across all line items for correct GST calculation. |
| FR-POS-007 | The system shall support a cart where items can be added, quantities changed (including decimal quantities for weight-based items), and items removed. |
| FR-POS-008 | The system shall display a running cart total showing: subtotal, total discount, CGST, SGST (or IGST), and grand total — updating in real time on every cart change. |
| FR-POS-009 | The system shall support four payment modes: Cash, UPI, Card, and Split (combination of any modes). |
| FR-POS-010 | When Cash is selected, the system shall display the change due calculated as: amount tendered minus grand total. |
| FR-POS-011 | The system shall generate a GST-compliant invoice containing: seller GSTIN, buyer GSTIN (if B2B), invoice number, date, HSN/SAC code, item-wise tax breakup, and invoice total. |
| FR-POS-012 | The system shall auto-generate sequential invoice numbers in the format [PREFIX]-[YEAR]-[NUMBER] (e.g., INV-2526-00142), resetting at financial year start. |
| FR-POS-013 | The system shall generate a downloadable PDF invoice using the organisation's logo, address, and configured invoice template. |
| FR-POS-014 | The system shall provide a WhatsApp share button that opens a pre-composed wa.me link with the bill summary and invoice PDF download link. |
| FR-POS-015 | The system shall automatically deduct sold quantities from inventory for each product at the time of bill confirmation. |
| FR-POS-016 | If a product's available stock is less than the quantity being billed, the system shall display a warning but allow the cashier to proceed with an override confirmation. |
| FR-POS-017 | The system shall support a customer lookup at POS by phone number to identify loyalty members and display their name and current loyalty balance. |
| FR-POS-018 | The system shall allow guest checkout (billing without linking a customer) for walk-in customers. |
| FR-POS-019 | The system shall support bill cancellation with a mandatory reason field, reversing all inventory deductions and accounting entries. |
| FR-POS-020 | The system shall record every completed sale as a transaction in the accounts module with correct debit/credit entries. |

---

### FR-INV — Inventory Management

| ID | Requirement |
|---|---|
| FR-INV-001 | The system shall allow a manager to create a product with: name, barcode (auto-generated if not provided), category, HSN code, applicable GST rate, MRP, cost price, selling price, and unit of measurement. |
| FR-INV-002 | The system shall support configurable units of measurement including: pcs, kg, g, litre, ml, metre, box, dozen — with decimal quantity support for weight/length-based units. |
| FR-INV-003 | The system shall maintain real-time stock levels for every product, updated immediately on every sale (deduction) and goods receipt (addition). |
| FR-INV-004 | The system shall display a stock dashboard showing current quantity, reorder level, and a visual indicator (green/yellow/red) for stock health. |
| FR-INV-005 | The system shall allow manual stock adjustments with a mandatory reason selection: Received, Damaged, Expired, Theft, Correction — each adjustment logged with timestamp and user. |
| FR-INV-006 | The system shall allow a manager to configure a reorder level per product; when stock falls below this level the product shall appear in a Low Stock alerts list. |
| FR-INV-007 | The system shall support batch tracking: each stock receipt can be tagged with a batch number and expiry date. |
| FR-INV-008 | The system shall enforce FEFO (First Expiry First Out) at POS by defaulting to the batch with the earliest expiry date when deducting stock. |
| FR-INV-009 | The system shall generate expiry alerts 30 days before a batch's expiry date. |
| FR-INV-010 | The system shall support product variants (e.g., same product in different sizes or colours) linked under a parent product. |
| FR-INV-011 | The system shall allow stock transfer between stores in a multi-store setup, creating a transfer-out entry at the source and a transfer-in entry at the destination. |
| FR-INV-012 | The system shall generate an inventory valuation report showing: product name, current stock, cost price, and total value — exportable as Excel and PDF. |
| FR-INV-013 | The system shall identify slow-moving products (no sale in the last 30 days) and present them in a dedicated report. |
| FR-INV-014 | The system shall support barcode label printing (generating a printable label sheet with barcodes and product names). |
| FR-INV-015 | The system shall maintain a full audit log of all stock movements (sales, adjustments, transfers, receipts) viewable per product. |

---

### FR-PUR — Purchase Management

| ID | Requirement |
|---|---|
| FR-PUR-001 | The system shall allow a manager to create and maintain supplier records with: name, GSTIN, contact person, phone, email, address, and payment terms. |
| FR-PUR-002 | The system shall allow creation of a Purchase Order (PO) with: supplier, line items (product, quantity, rate), expected delivery date, and auto-generated PO number. |
| FR-PUR-003 | The system shall allow sharing of a PO as a PDF download or via a WhatsApp wa.me link. |
| FR-PUR-004 | The system shall allow recording of a Goods Receipt Note (GRN) linked to a PO, with the ability to enter actual received quantities (which may differ from ordered quantities). |
| FR-PUR-005 | The system shall automatically increment inventory stock levels upon GRN confirmation. |
| FR-PUR-006 | The system shall flag quantity or rate variances between the PO and the GRN for manager review. |
| FR-PUR-007 | The system shall maintain an accounts payable ledger showing outstanding amounts per supplier. |
| FR-PUR-008 | The system shall allow recording of supplier payments, reducing the outstanding payable balance. |
| FR-PUR-009 | The system shall support supplier invoice entry (linking to GRN) for 3-way matching (PO → GRN → Supplier Invoice). |
| FR-PUR-010 | The system shall generate a purchase report filterable by supplier, date range, and product — exportable as Excel and PDF. |

---

### FR-CRM — Customer & CRM

| ID | Requirement |
|---|---|
| FR-CRM-001 | The system shall maintain a customer database with: name, phone number, email (optional), address (optional), GSTIN (optional for B2B), and date of joining. |
| FR-CRM-002 | The system shall award loyalty points on every purchase at a configurable rate (e.g., 1 point per ₹10 spent), linked to the customer's phone number. |
| FR-CRM-003 | The system shall allow redemption of loyalty points at POS, converting points to a discount at a configurable rate (e.g., 1 point = ₹0.25). |
| FR-CRM-004 | The system shall display a customer's complete purchase history including date, bill number, items, and amount. |
| FR-CRM-005 | The system shall allow recording customer credit (udhar) — amount owed by a customer — and allow recording of repayments. |
| FR-CRM-006 | The system shall generate a customer-wise outstanding credit (udhar) report. |
| FR-CRM-007 | The system shall segment customers by total spending into tiers: Bronze (0-₹5,000), Silver (₹5,000-₹25,000), Gold (₹25,000+). |
| FR-CRM-008 | The system shall allow a manager to export a customer list (phone numbers + names) for a selected tier — for use in WhatsApp broadcast campaigns. |
| FR-CRM-009 | The system shall display a customer's loyalty points balance on the POS screen when the customer is identified by phone number. |
| FR-CRM-010 | The system shall send an automated WhatsApp message (via wa.me link generated for staff to send) on a customer's birthday if date of birth is recorded. |

---

### FR-GST — GST & Accounting

| ID | Requirement |
|---|---|
| FR-GST-001 | The system shall maintain a tax group master with all 5 GST slabs (0%, 5%, 12%, 18%, 28%) and their CGST/SGST/IGST component rates. |
| FR-GST-002 | The system shall support HSN code assignment per product and auto-suggest the applicable GST rate based on the HSN code from a pre-loaded reference database. |
| FR-GST-003 | The system shall generate a GSTR-1 compatible report for any selected month, including: B2B invoices (with buyer GSTIN), B2C invoices, and HSN summary. |
| FR-GST-004 | The system shall generate a GSTR-3B summary showing: total output tax (from sales), total input tax credit (from purchases), and net GST payable. |
| FR-GST-005 | The system shall maintain a double-entry accounting ledger with automatic posting of journal entries for every sale, purchase, and payment transaction. |
| FR-GST-006 | The system shall generate a Profit & Loss statement for any date range showing: revenue, cost of goods sold, gross profit, operating expenses, and net profit. |
| FR-GST-007 | The system shall maintain a daily cash register: opening balance, cash sales, cash payments made, cash expenses entered, and closing balance. |
| FR-GST-008 | The system shall allow manual journal entries for expenses (rent, electricity, salary) with appropriate account classification. |
| FR-GST-009 | The system shall generate a HSN-wise sales summary report required for GSTR-1 annual filing. |
| FR-GST-010 | All GST reports shall be exportable in Excel format compatible with the GST portal's offline upload tool. |

---

### FR-RPT — Reports & Dashboard

| ID | Requirement |
|---|---|
| FR-RPT-001 | The system shall display a main dashboard showing: today's total sales, number of bills, top-selling product, low stock count, and cash vs UPI split — loading within 2 seconds. |
| FR-RPT-002 | The system shall provide a sales report filterable by: date range, payment mode, cashier, product, and category. |
| FR-RPT-003 | The system shall provide a product performance report showing top-selling and slow-moving products by quantity and revenue for any date range. |
| FR-RPT-004 | The system shall provide a daily summary report showing: opening stock value, closing stock value, total sales, total purchases, and net cash position. |
| FR-RPT-005 | The system shall provide a cashier-wise sales report showing each staff member's billing performance. |
| FR-RPT-006 | The system shall display all reports in both chart (visual) and table (data) format, switchable by the user. |
| FR-RPT-007 | The system shall allow any report to be exported as PDF (print-ready) or Excel (raw data). |
| FR-RPT-008 | The system shall send an automated daily summary WhatsApp message (via wa.me) to the owner's phone with: total sales, bills count, and cash balance. |

---

### FR-MST — Multi-Store

| ID | Requirement |
|---|---|
| FR-MST-001 | The system shall support a single Organisation with multiple Stores, each Store being an independent billing and inventory unit. |
| FR-MST-002 | The system shall enforce data isolation: a cashier or manager can only view and operate their assigned store's data. |
| FR-MST-003 | The system shall provide an Owner-level HQ dashboard aggregating all stores' sales, stock values, and key metrics. |
| FR-MST-004 | The system shall support inter-store stock transfers with source deduction and destination addition logged simultaneously. |
| FR-MST-005 | The system shall allow the Owner to compare store performance (revenue, margin, top products) side by side in the HQ dashboard. |
| FR-MST-006 | The system shall allow the Owner to configure store-specific invoice prefixes, so each store's invoices are distinguishable. |

---

### FR-HR — HR & Payroll (Basic)

| ID | Requirement |
|---|---|
| FR-HR-001 | The system shall maintain an employee master with: name, role, assigned store, phone, joining date, and base salary. |
| FR-HR-002 | The system shall allow daily attendance marking (Present / Absent / Half Day) per employee. |
| FR-HR-003 | The system shall calculate monthly payable salary based on: (base salary / working days in month) × days present, with deductions for advances. |
| FR-HR-004 | The system shall generate a monthly payslip PDF per employee. |
| FR-HR-005 | The system shall allow recording salary payments, linked to the accounts module as an expense. |
| FR-HR-006 | The system shall display a monthly attendance summary per employee (days present, absent, half-days). |
| FR-HR-007 | The system shall track salary advances and deduct them from the next applicable month's payroll. |
| FR-HR-008 | The system shall generate a payroll expense report for any month, showing total staff cost. |

---

### FR-SET — Settings & Administration

| ID | Requirement |
|---|---|
| FR-SET-001 | The system shall allow the Owner to configure the business profile: name, address, GSTIN, logo (image upload), phone, email. |
| FR-SET-002 | The system shall allow configuration of invoice settings: prefix, starting number, terms & conditions text, footer message. |
| FR-SET-003 | The system shall allow configuration of loyalty program settings: points-per-rupee rate, points-to-rupee redemption rate, minimum redemption points. |
| FR-SET-004 | The system shall allow the Owner to manage user accounts: invite, assign role, deactivate — with changes taking effect immediately. |
| FR-SET-005 | The system shall allow configuration of low-stock alert thresholds globally (default reorder level) and allow per-product override. |

---

## SECTION 3 — NONFUNCTIONAL REQUIREMENTS (Pressman Ch 7.2.5)

---

### NFR-PERF — Performance

| ID | Requirement | Measurement |
|---|---|---|
| NFR-PERF-001 | Product search results shall appear within 500ms of the user entering 2+ characters | Measured: network request completion time |
| NFR-PERF-002 | A bill shall be completable (from first product search to receipt generation) within 30 seconds for a 10-item bill by a trained cashier | Measured: end-to-end task time in user testing |
| NFR-PERF-003 | The main dashboard shall load within 2 seconds on a 4G connection (10 Mbps) | Measured: Lighthouse performance score ≥ 70 |
| NFR-PERF-004 | Report generation for up to 10,000 transactions shall complete within 5 seconds | Measured: API response time with seed data |
| NFR-PERF-005 | The application shall function on Android devices with 3GB RAM and Chrome browser version 90+ | Measured: manual testing on target device |

---

### NFR-REL — Reliability

| ID | Requirement |
|---|---|
| NFR-REL-001 | The system shall maintain 99.5% uptime during business hours (8 AM – 10 PM IST, 7 days/week) |
| NFR-REL-002 | The system shall automatically back up all transaction data daily via Supabase point-in-time recovery |
| NFR-REL-003 | The system shall never silently lose data — any failed write operation shall display an error and allow retry |
| NFR-REL-004 | GST calculation results shall be accurate to 2 decimal places in every transaction, verified by unit tests |

---

### NFR-USAB — Usability

| ID | Requirement |
|---|---|
| NFR-USAB-001 | A new cashier with no prior software training shall be able to complete their first bill within 30 minutes of onboarding |
| NFR-USAB-002 | The POS screen shall be fully operable on a 5-inch mobile screen with finger touch (no stylus required) |
| NFR-USAB-003 | All primary actions shall require no more than 3 taps/clicks from the main navigation |
| NFR-USAB-004 | Error messages shall be written in plain language (not technical codes) and include a suggested corrective action |
| NFR-USAB-005 | Currency shall always display in Indian format: ₹X,XX,XXX.XX (Indian numbering system) |
| NFR-USAB-006 | Dates shall always display in DD MMM YYYY format (e.g., 22 Apr 2026) |

---

### NFR-SEC — Security

| ID | Requirement |
|---|---|
| NFR-SEC-001 | All database tables shall have Row Level Security (RLS) policies enforcing organisation-level data isolation — no user shall access another organisation's data |
| NFR-SEC-002 | The Supabase service_role key shall never be exposed in any frontend code or committed to the GitHub repository |
| NFR-SEC-003 | All user inputs shall be validated and sanitised before database operations |
| NFR-SEC-004 | All API communications shall use HTTPS (enforced by Vercel) |
| NFR-SEC-005 | An audit log shall record every data modification (create/update/delete) with user ID and timestamp |
| NFR-SEC-006 | Passwords shall be hashed using Supabase Auth's bcrypt implementation — plain-text passwords shall never be stored |

---

### NFR-SCAL — Scalability

| ID | Requirement |
|---|---|
| NFR-SCAL-001 | The system shall support 1 to 10 stores per organisation within the MVP |
| NFR-SCAL-002 | The system shall support up to 10,000 products per store |
| NFR-SCAL-003 | The system shall support up to 500 transactions per day per store without performance degradation |
| NFR-SCAL-004 | The database schema shall use organisation_id and store_id foreign keys on all transactional tables to support future horizontal scaling |

---

### NFR-COMP — Compliance (India-specific)

| ID | Requirement |
|---|---|
| NFR-COMP-001 | All invoices shall comply with GST Rule 46 (Tax Invoice format) including mandatory fields: GSTIN, Invoice No, Date, HSN/SAC, taxable value, tax amount |
| NFR-COMP-002 | GSTR-1 export shall be in the format specified by the GST portal for offline JSON/Excel upload |
| NFR-COMP-003 | The system shall support all 5 GST tax slabs: 0%, 5%, 12%, 18%, 28% |
| NFR-COMP-004 | The system shall distinguish between intra-state (CGST+SGST) and inter-state (IGST) transactions |
| NFR-COMP-005 | The financial year shall run April to March (Indian FY), with invoice number sequences resetting at FY start |

---

### NFR-AVAIL — Availability / Offline

| ID | Requirement |
|---|---|
| NFR-AVAIL-001 | The POS module shall support offline billing when internet is unavailable, storing bills locally and syncing when connectivity is restored |
| NFR-AVAIL-002 | Product catalogue shall be cached locally so product search works without internet |
| NFR-AVAIL-003 | The system shall display a clear offline indicator when operating without internet connectivity |

---

### NFR-MAINT — Maintainability

| ID | Requirement |
|---|---|
| NFR-MAINT-001 | New features shall be deployable to production without downtime (zero-downtime deployment via Vercel) |
| NFR-MAINT-002 | All GST rates and rules shall be configurable in the database (tax_groups table) without requiring code changes |
| NFR-MAINT-003 | The codebase shall follow a modular component structure where each ERP module (POS, Inventory, etc.) is independently maintainable |

---

## SECTION 4 — USAGE SCENARIOS (Pressman Ch 7.3.2)

### Scenario 1 — Morning Routine of a Kirana Store Owner

Ramesh arrives at his shop at 8:30 AM. Before opening the shutter, he takes out his
phone, opens RetailOS, and checks the dashboard. Yesterday's total sales: ₹14,280.
Cash collected: ₹5,200. UPI: ₹9,080. He notices 3 items are in the low-stock list —
Tata Salt 1kg, Surf Excel 500g, and Fortune Soya Oil 1L. He makes a quick WhatsApp
message to his distributor: "Please send: Tata Salt x20, Surf Excel 500g x12, Fortune
Oil 1L x6." He does this before the distributor's morning delivery cutoff at 9 AM.

By 9 AM his son has arrived and opened the shop. The son logs in to RetailOS on
the shop's tablet. Billing begins. Ramesh leaves for other work, knowing he can
check live sales from his phone at any time during the day.

At noon, Ramesh receives the automated WhatsApp morning summary on his phone:
"Today so far: 42 bills, ₹4,820 sales, Cash ₹1,200, UPI ₹3,620." He's satisfied
and continues his other work.

---

### Scenario 2 — Cashier Billing During Rush Hour

It's 7 PM on a Saturday. Ramesh's son is billing customers on the shop tablet.
There are 6 customers waiting. A customer places 12 items on the counter.

The son starts billing: types "par" → Parle-G appears first in search → taps to add →
quantity already 1, customer says "2 packets" → taps + once → next item → types "tata
sa" → Tata Salt appears → adds → continues. 12 items in 90 seconds.

Bill total: ₹486. GST breakdown appears: ₹12.40 CGST, ₹12.40 SGST. Grand total: ₹511.

Customer says "Google Pay karein." Son taps UPI → grand total shown → customer scans
the shop's QR code separately and pays → son confirms payment received → taps Confirm Bill.

Invoice generated. Son taps WhatsApp share → pre-composed message opens on phone
with bill summary and PDF link → sends to customer.

Total time: 2 minutes 15 seconds. Next customer steps up.

---

### Scenario 3 — Owner Checking Sales at Night on Mobile

It's 10:30 PM. Ramesh is at home. The shop has just closed. He opens RetailOS on
his phone. Today's dashboard: 127 bills, ₹18,640 total sales. He taps Reports →
Today's Sales → sorted by product.

He notices: Britannia Biscuits sold 34 packets today (unusually high — probably
because of a cricket match). He makes a mental note to order more tomorrow.
He also sees: 3 bills were settled in credit (udhar) — total ₹920 outstanding
across 2 customers. He'll collect tomorrow.

He checks the cash drawer: opening balance ₹2,000 + cash sales ₹6,840 −
cash purchases ₹1,200 = closing balance ₹7,640. He'll count the physical cash
tomorrow morning and verify. He closes the app and goes to sleep, confident he
knows his business for the day.

---

### Scenario 4 — Manager Placing a Purchase Order

Priya (medical shop owner/manager) opens RetailOS on a Tuesday morning.
The low-stock alert shows 8 items below reorder level. She taps "Create PO" →
selects supplier "Medplus Distributors" → the system pre-populates the 8 low-stock
items with their last purchase rate → she adjusts quantities based on expected demand.

She reviews the PO: 8 products, total value ₹12,400. She taps "Send to Supplier" →
a PDF PO is generated → WhatsApp opens with the PO attached → she sends it to the
distributor's number.

Distributor arrives Thursday with the stock. Priya opens RetailOS → Purchase → GRN →
links to the PO → enters actual received quantities (6 of 8 items match PO; 2 items
partially delivered) → confirms GRN. Inventory automatically updates for all 8 items.
The PO shows as "Partially Fulfilled." An accounts payable entry is created for ₹9,800
(the value of received goods) against Medplus Distributors.

---

### Scenario 5 — GST Return Filing on Last Day of Month

It's May 10th — last day to file April's GSTR-1. Priya's CA, Mr. Venkat, calls her:
"Please send me April's GST data."

Priya opens RetailOS → GST → GSTR-1 Report → selects April 2026 → clicks Download Excel.

The Excel file downloads with three sheets:
- B2B invoices (12 invoices to registered businesses with their GSTINs)
- B2C summary (1,240 invoices to unregistered customers, grouped by rate)
- HSN summary (tax collected under each HSN code)

She sends the file to Mr. Venkat on WhatsApp. He opens it in Tally/GST portal,
reviews the data (it's clean and formatted correctly), and files the return in 20 minutes.

No back-and-forth, no missing invoices, no wrong HSN codes. Filing complete before deadline.

---

*REQUIREMENTS_SPECIFICATION.md v1.0*
*Pressman SEPA 9th Edition — Ch 7 (Understanding Requirements)*
*Based on: SHOP_RESEARCH.md (3 simulated shop interviews)*
*Next: USE_CASES.md (Pressman Ch 7.4 + 8.2)*
