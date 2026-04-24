# USE_CASES.md
# RetailOS — Use Cases
# Applying Pressman's Software Engineering (9th Ed.) Ch 7.4 + Ch 8.2
# Version: 1.0 | Day 2

---

## USE CASE INDEX

| ID | Name | Actor | Priority | Frequency |
|---|---|---|---|---|
| UC-01 | Process a Sale (POS) | Cashier | P1 | 80-150x/day |
| UC-02 | Add New Product to Catalogue | Manager | P1 | 5-20x/week |
| UC-03 | Receive Goods from Supplier (GRN) | Manager | P1 | 3-5x/week |
| UC-04 | Process Customer Return / Exchange | Cashier | P2 | 2-5x/day |
| UC-05 | Apply Loyalty Points at Billing | Cashier | P2 | 10-30x/day |
| UC-06 | Generate GST-Compliant Invoice | System (auto) | P1 | Every sale |
| UC-07 | Check Today's Sales on Mobile | Owner | P1 | 3-5x/day |
| UC-08 | Low Stock Alert and Reorder | Manager | P1 | 2-5x/week |
| UC-09 | Register New Shop / Store | Owner | P1 | Once at setup |
| UC-10 | Generate Monthly GST Report | Owner / CA | P1 | 1x/month |

---

## UC-01 — Process a Sale (POS)
*Most critical use case — most detailed*

**USE CASE ID**: UC-01
**USE CASE NAME**: Process a Sale
**ACTOR(S)**: Primary: Cashier | Secondary: Customer (indirect), System (automatic actions)
**PRECONDITIONS**:
- Cashier is logged in with Cashier or higher role
- At least one product exists in the product catalogue
- Store is configured with a valid GSTIN

**TRIGGER**: Customer presents items for purchase at billing counter

---

**MAIN SUCCESS SCENARIO (Basic Flow)**:

1. Cashier opens the POS screen from the sidebar navigation
2. System displays an empty cart with product search field focused
3. Cashier scans barcode using device camera or types product name (min 2 chars)
4. System displays matching products with: name, price, GST rate, available stock
5. Cashier selects the product
6. System adds product to cart with quantity = 1, showing item total and GST breakup
7. Cashier adjusts quantity if needed using +/- buttons or direct input
8. System recalculates item total and cart summary in real time
9. Steps 3-8 repeat for each item in the purchase
10. Cashier applies item-level discount if applicable (% or ₹ amount)
11. System recalculates taxable value and GST on post-discount amount
12. Cashier reviews cart: subtotal, discount, CGST, SGST, grand total
13. Cashier taps "Proceed to Payment"
14. System displays payment screen with grand total
15. Cashier selects payment mode: Cash
16. Cashier enters amount tendered by customer
17. System displays change due = tendered amount − grand total
18. Cashier taps "Confirm Bill"
19. System simultaneously:
    a. Creates a sale record with all line items
    b. Deducts stock for each product
    c. Posts accounting entry (debit cash/UPI, credit sales + GST payable)
    d. Auto-generates invoice number (e.g., INV-2526-00143)
    e. Generates invoice PDF
20. System displays "Bill Confirmed" screen with invoice PDF preview
21. Cashier taps "Share on WhatsApp" — system opens wa.me with bill summary
22. Cashier returns to POS screen for next customer

**POSTCONDITIONS**:
- Sale recorded in database with all line items, payment, and GST details
- Inventory stock levels reduced for all sold products
- Invoice PDF generated and available for download/sharing
- Accounting entries posted correctly
- Invoice number incremented for next bill

---

**ALTERNATIVE FLOWS**:

**Alt A — UPI Payment**:
At step 15, Cashier selects UPI instead of Cash.
System shows grand total amount to collect via UPI.
Cashier shows shop's UPI QR code to customer (physical or on-screen).
Customer pays. Cashier confirms payment received (manual confirmation).
Continue from step 18.

**Alt B — Card Payment**:
At step 15, Cashier selects Card.
System shows grand total. Cashier swipes/taps card on external POS terminal.
On approval, Cashier taps "Card Approved" in RetailOS.
Continue from step 18.

**Alt C — Split Payment**:
At step 15, Cashier selects Split.
System shows grand total with fields for each payment mode.
Cashier enters partial amount for Cash (e.g., ₹200) and partial for UPI (e.g., ₹311).
System validates: Cash + UPI must equal Grand Total.
Continue from step 18.

**Alt D — Customer Identified (Loyalty)**:
Before step 3, Cashier searches customer by phone number.
System displays customer name and loyalty point balance.
Customer is linked to the bill.
After step 13, system shows loyalty points available for redemption.
If customer chooses to redeem: see UC-05 (Apply Loyalty Points).
Post-bill: loyalty points earned from this purchase added to customer balance.

**Alt E — Barcode Not Found**:
At step 3, cashier scans barcode but no product matches.
System shows "Product not found — add to catalogue?" message.
Cashier can: manually search by name, or exit and ask manager to add product.
If found by name: continue from step 5.

**Alt F — Guest Checkout**:
Customer does not want to provide phone number.
Cashier proceeds without customer identification.
Bill is created without loyalty points (no customer linked).
Continue from step 13.

---

**EXCEPTION FLOWS**:

**Exc 1 — Internet Is Down (Offline Mode)**:
At any point, if internet connectivity is lost:
System displays orange "OFFLINE" indicator in header.
Cashier can continue billing — data saved to local browser storage.
Invoice PDF generated locally without internet.
WhatsApp sharing deferred until connectivity returns.
On reconnection: system automatically syncs all offline bills to Supabase.
System confirms sync with "X bills synced" notification.

**Exc 2 — Product Out of Stock**:
At step 6, system detects available stock = 0 or less than requested quantity.
System displays warning: "Low stock: only X units available."
Cashier can: reduce quantity to available stock, OR override with confirmation.
If override chosen: system logs a negative stock entry flagged for manager review.
Continue from step 7.

**Exc 3 — Bill Confirmation Fails (Network Error)**:
At step 18, network request to Supabase fails.
System displays error: "Bill not saved — please retry."
Cart data is preserved. Cashier taps Confirm again.
System retries. If repeated failure: system saves bill to offline queue.
On reconnection: bill synced automatically. Cashier notified.

**Exc 4 — Duplicate Barcode Scan**:
Cashier accidentally scans the same product twice.
System detects product already in cart and increments quantity instead of adding duplicate.
System shows brief toast: "Quantity updated to X."

---

**BUSINESS RULES**:
- BR1: GST is calculated on post-discount taxable value only (not on MRP before discount)
- BR2: For intra-state sales: CGST = SGST = GST rate / 2
- BR3: For inter-state sales: IGST = full GST rate (no CGST/SGST)
- BR4: Invoice number format: [PREFIX]-[FY]-[SEQUENCE] e.g. INV-2526-00143
- BR5: Financial year runs April to March; invoice sequence resets 1 April each year
- BR6: Maximum discount per item cannot exceed selling price (bill total must be ≥ ₹0)
- BR7: Cash tendered must be ≥ grand total (change cannot be negative)
- BR8: Split payment total must exactly equal grand total — no partial payment allowed

**FREQUENCY**: 80–150 times per day per store
**PRIORITY**: P1 — Must work perfectly before any other feature is built

---

## UC-02 — Add New Product to Catalogue

**USE CASE ID**: UC-02
**USE CASE NAME**: Add New Product to Catalogue
**ACTOR(S)**: Manager or Owner
**PRECONDITIONS**: User logged in with Manager or Owner role; at least one category and one tax group exist
**TRIGGER**: Manager needs to add a new product to enable billing for it

**MAIN SUCCESS SCENARIO**:
1. Manager navigates to Inventory → Products → Add New Product
2. System displays the new product form
3. Manager enters: Product Name, Category (select from list), HSN Code
4. System auto-suggests GST rate based on HSN code
5. Manager confirms or adjusts GST rate, selects applicable tax group
6. Manager enters: Cost Price, Selling Price, MRP, Unit of Measurement
7. Manager enters or scans barcode (or leaves blank for auto-generation)
8. Manager sets initial stock quantity and reorder level
9. Manager clicks Save
10. System validates all mandatory fields; saves product; auto-generates barcode if blank
11. System shows success message and returns to product list
12. New product is immediately searchable at POS

**POSTCONDITIONS**: Product exists in catalogue with correct GST rate; searchable in POS; inventory record created

**ALTERNATIVE FLOWS**:
- Alt A — Duplicate Barcode: System detects barcode already exists → shows error with existing product name → manager enters a different barcode
- Alt B — Product Variant: Manager taps "Add Variant" → links new product as variant of existing parent product (e.g., Tata Salt 500g as variant of Tata Salt 1kg)

**EXCEPTION FLOWS**:
- Exc 1 — Invalid HSN Code: System cannot find GST rate → manager manually selects tax group

**BUSINESS RULES**:
- Selling Price must be ≥ Cost Price (system warns but allows override)
- HSN code must be 4, 6, or 8 digits

**FREQUENCY**: 5–20 times/week | **PRIORITY**: P1

---

## UC-03 — Receive Goods from Supplier (GRN)

**USE CASE ID**: UC-03
**USE CASE NAME**: Receive Goods from Supplier (GRN)
**ACTOR(S)**: Manager | Secondary: System (inventory update)
**PRECONDITIONS**: Supplier exists in system; PO exists (optional — can do GRN without PO); user has Manager role
**TRIGGER**: Supplier delivers goods to the store

**MAIN SUCCESS SCENARIO**:
1. Manager navigates to Purchase → Goods Receipt → New GRN
2. System asks: "Link to existing PO?" Manager selects Yes and chooses the PO
3. System pre-fills GRN with PO line items (products and ordered quantities)
4. Manager enters actually received quantities for each item (may differ from PO)
5. Manager enters batch number and expiry date for each item (especially for medical shops)
6. Manager enters supplier invoice number and date
7. Manager reviews total received value
8. Manager clicks Confirm GRN
9. System updates inventory stock for each product (adds received quantities)
10. System creates accounts payable entry for the received value
11. System flags any line items where received quantity ≠ PO quantity as variance

**POSTCONDITIONS**: Inventory updated; payable recorded; GRN linked to PO; variances flagged for review

**ALTERNATIVE FLOWS**:
- Alt A — GRN Without PO: Manager creates GRN manually without linking to PO → adds products and quantities directly

**EXCEPTION FLOWS**:
- Exc 1 — Product Not in Catalogue: Item in delivery not found in product master → manager must add product first (UC-02) then return to GRN

**BUSINESS RULES**:
- GRN cannot be deleted after confirmation — only a credit note can reverse it
- Cost price from GRN updates the product's last purchase price

**FREQUENCY**: 3–5 times/week | **PRIORITY**: P1

---

## UC-04 — Process Customer Return / Exchange

**USE CASE ID**: UC-04
**USE CASE NAME**: Process Customer Return / Exchange
**ACTOR(S)**: Cashier or Manager
**PRECONDITIONS**: Original sale exists in system with original invoice number
**TRIGGER**: Customer returns to shop with product for return or exchange

**MAIN SUCCESS SCENARIO**:
1. Cashier navigates to POS → Returns
2. Cashier enters original invoice number (or customer phone to find recent bills)
3. System displays original bill with all line items
4. Cashier selects item(s) being returned and enters return quantity
5. System calculates refund amount including GST reversal
6. Cashier selects return reason: Defective / Wrong Item / Customer Changed Mind / Expired
7. Cashier selects refund method: Cash Refund / Store Credit / Exchange
8. If Exchange: system opens a new POS session pre-loaded with the return credit applied
9. Cashier confirms the return
10. System creates a Credit Note (reverse invoice) with negative amounts
11. System returns stock to inventory for returned items
12. System reverses the original accounting entry
13. Refund given to customer (cash or store credit applied)

**POSTCONDITIONS**: Stock restored; accounting reversed; credit note generated; customer record updated if loyalty points were earned on original bill

**EXCEPTION FLOWS**:
- Exc 1 — Original Bill Not Found: Cashier cannot find original bill → manager can process return without original invoice with a manual reason log

**BUSINESS RULES**:
- Returns without receipt subject to manager approval
- Credit note must reference original invoice number (GST compliance)

**FREQUENCY**: 2–5 times/day | **PRIORITY**: P2

---

## UC-05 — Apply Loyalty Points at Billing

**USE CASE ID**: UC-05
**USE CASE NAME**: Apply Loyalty Points at Billing
**ACTOR(S)**: Cashier | Secondary: Customer
**PRECONDITIONS**: Customer identified at POS by phone number; customer has redeemable points balance; loyalty program is configured
**TRIGGER**: Customer requests to redeem loyalty points during checkout

**MAIN SUCCESS SCENARIO**:
1. Customer is already identified at POS (from Alt D in UC-01)
2. At payment step, system shows: "Customer has 240 points (₹60 redeemable)"
3. Customer confirms they want to redeem points
4. Cashier taps "Redeem Points" and enters points to redeem (up to max available)
5. System calculates discount: points × redemption rate (e.g., 240 × ₹0.25 = ₹60)
6. System applies ₹60 discount to grand total: new total = grand total − ₹60
7. Remaining amount collected via Cash/UPI/Card
8. On bill confirmation: redeemed points deducted from customer balance
9. New points earned from this purchase (on post-redemption amount) added to balance

**POSTCONDITIONS**: Points balance updated; bill includes loyalty redemption line; receipt shows points used and new balance

**BUSINESS RULES**:
- Minimum redemption threshold: configurable (e.g., 100 points minimum)
- Points cannot be redeemed on discounted items below cost price
- Points earned = post-discount, post-redemption amount × earning rate

**FREQUENCY**: 10–30 times/day | **PRIORITY**: P2

---

## UC-06 — Generate GST-Compliant Invoice

**USE CASE ID**: UC-06
**USE CASE NAME**: Generate GST-Compliant Invoice
**ACTOR(S)**: System (triggered automatically by UC-01)
**PRECONDITIONS**: Sale has been confirmed (UC-01 step 18 complete)
**TRIGGER**: Bill confirmation event

**MAIN SUCCESS SCENARIO**:
1. System receives confirmed sale data
2. System retrieves organisation profile: business name, address, GSTIN, logo
3. System retrieves buyer details: name, address, GSTIN (if B2B)
4. System generates invoice with all GST Rule 46 mandatory fields:
   - Seller: name, address, GSTIN, state code
   - Buyer: name, address, GSTIN (if B2B), state code
   - Invoice number and date
   - For each line item: description, HSN code, quantity, unit, rate, discount, taxable value, CGST/SGST or IGST rate and amount
   - Total taxable value, total CGST, total SGST (or IGST), total invoice value
   - Amount in words (Indian format)
5. System generates PDF using configured invoice template
6. PDF stored in Supabase Storage
7. PDF download link made available in bill confirmed screen

**POSTCONDITIONS**: GST-compliant PDF invoice available for download and WhatsApp sharing

**BUSINESS RULES**:
- Invoice must comply with GST Rule 46 format
- For exempt items (0% GST): invoice shows ₹0 tax (not blank)
- Invoice number must be unique within the organisation's financial year

**FREQUENCY**: Every sale (80–150x/day) | **PRIORITY**: P1

---

## UC-07 — Check Today's Sales on Mobile

**USE CASE ID**: UC-07
**USE CASE NAME**: Check Today's Sales on Mobile
**ACTOR(S)**: Owner
**PRECONDITIONS**: Owner has Owner role; at least some sales exist for today
**TRIGGER**: Owner wants to check business performance at any time during the day

**MAIN SUCCESS SCENARIO**:
1. Owner opens RetailOS on mobile browser
2. System authenticates via existing session (no login required if session active)
3. System displays main dashboard with today's KPIs:
   - Total sales amount
   - Number of bills
   - Cash collected vs UPI collected
   - Top-selling product today
   - Low stock count (items needing reorder)
4. Owner taps "View Sales Report"
5. System displays today's bills in reverse chronological order
6. Owner can filter by payment mode, cashier, or product category
7. Owner taps on a specific bill to see full bill details
8. Owner checks cash drawer balance
9. Owner satisfied — closes app

**POSTCONDITIONS**: Owner has real-time visibility into store performance

**ALTERNATIVE FLOWS**:
- Alt A — Multi-store Owner: Dashboard shows store selector; owner picks store or views HQ aggregate

**EXCEPTION FLOWS**:
- Exc 1 — Session Expired: System shows login page → owner logs in → redirected to dashboard

**FREQUENCY**: 3–5 times/day | **PRIORITY**: P1

---

## UC-08 — Low Stock Alert and Reorder

**USE CASE ID**: UC-08
**USE CASE NAME**: Low Stock Alert and Reorder
**ACTOR(S)**: Manager | Secondary: Supplier (receives PO via WhatsApp)
**PRECONDITIONS**: Products have reorder levels configured; at least one product is below reorder level
**TRIGGER**: Manager opens RetailOS and sees low-stock notification, OR system sends automated alert

**MAIN SUCCESS SCENARIO**:
1. Manager opens RetailOS; sidebar shows red badge: "5 low stock items"
2. Manager taps notification → navigates to Inventory → Low Stock
3. System displays list of products below reorder level: product name, current stock, reorder level, preferred supplier
4. Manager reviews list, deselects items not needed now, adjusts reorder quantities
5. Manager groups items by supplier
6. Manager taps "Create PO for Supplier A" → system pre-fills PO with selected items
7. Manager reviews PO, adjusts quantities based on budget/storage capacity
8. Manager taps "Send to Supplier" → WhatsApp opens with PO PDF attached
9. Manager sends PO to supplier
10. System marks PO as "Sent" and records expected delivery date

**POSTCONDITIONS**: PO created and sent; purchase tracking initiated; inventory not yet updated (awaits GRN)

**EXCEPTION FLOWS**:
- Exc 1 — No Preferred Supplier Set: Manager manually selects supplier from dropdown for each item

**BUSINESS RULES**:
- Suggested reorder quantity = (reorder level × 2) − current stock (to bring to 2× reorder level)

**FREQUENCY**: 2–5 times/week | **PRIORITY**: P1

---

## UC-09 — Register New Shop / Store

**USE CASE ID**: UC-09
**USE CASE NAME**: Register New Shop / Store (Onboarding)
**ACTOR(S)**: Shop Owner (new user)
**PRECONDITIONS**: User has internet access; user has their GSTIN available
**TRIGGER**: Owner decides to start using RetailOS

**MAIN SUCCESS SCENARIO**:
1. Owner opens RetailOS URL on browser
2. System shows login page with "Register your business" link
3. Owner taps Register
4. System displays onboarding form — Step 1 of 3: Business Details
   - Business name, GSTIN, registered address, state, pincode
5. System validates GSTIN format in real time
6. Owner proceeds to Step 2: Owner Account
   - Name, email, phone, password (min 8 chars)
7. Owner proceeds to Step 3: First Store Setup
   - Store name, store address (can be same as business), invoice prefix
8. Owner taps "Complete Setup"
9. System creates: Organisation, Owner User, First Store, default tax groups (all 5 slabs)
10. System sends verification email to owner's email address
11. System redirects owner to dashboard with onboarding checklist:
    - [ ] Add your first product
    - [ ] Add a staff member (optional)
    - [ ] Make your first test bill
12. Owner is live

**POSTCONDITIONS**: Organisation, store, and owner user created; default configuration applied; ready for use

**ALTERNATIVE FLOWS**:
- Alt A — Adding a Second Store: Existing owner navigates to Settings → Stores → Add Store → enters store details → new store created and accessible from store selector

**EXCEPTION FLOWS**:
- Exc 1 — GSTIN Already Registered: System detects GSTIN already linked to an account → shows "This GSTIN is already registered — Login instead?"

**BUSINESS RULES**:
- One GSTIN can be linked to only one organisation
- First store is created automatically during registration

**FREQUENCY**: Once per new shop | **PRIORITY**: P1

---

## UC-10 — Generate Monthly GST Report

**USE CASE ID**: UC-10
**USE CASE NAME**: Generate Monthly GST Report (GSTR-1)
**ACTOR(S)**: Owner or CA (using Owner's account or shared access)
**PRECONDITIONS**: At least one month of sales data exists; organisation GSTIN is configured
**TRIGGER**: End of month — GST return filing due (10th of following month for GSTR-1)

**MAIN SUCCESS SCENARIO**:
1. Owner navigates to GST → GSTR-1 Report
2. System displays month selector (default: previous completed month)
3. Owner selects month: April 2026
4. System compiles all April sales transactions and categorises:
   - B2B invoices: bills to customers with GSTIN (with buyer GSTIN, invoice-wise)
   - B2C Large: invoices > ₹2.5L to unregistered buyers (invoice-wise)
   - B2C Small: all other invoices (aggregate by rate)
   - HSN Summary: HSN-wise total taxable value and tax
5. System displays summary: Total taxable value, Total CGST, Total SGST, Total IGST
6. Owner reviews for any obvious errors (unusually high/low amounts)
7. Owner taps "Download Excel (GSTR-1 Format)"
8. System generates Excel file in GST portal offline upload format
9. Owner downloads file and sends to CA via WhatsApp
10. CA uploads to GST portal, reviews, and files

**POSTCONDITIONS**: GSTR-1 Excel file downloaded; CA can file return without requesting any additional data

**ALTERNATIVE FLOWS**:
- Alt A — GSTR-3B Summary: Owner selects GSTR-3B tab → system shows output tax − input credit = net payable → downloadable as PDF for CA reference

**EXCEPTION FLOWS**:
- Exc 1 — Missing GSTIN on B2B Invoice: System highlights bills where buyer GSTIN was not captured → owner can update customer GSTIN retroactively on those bills

**BUSINESS RULES**:
- GSTR-1 due date: 10th of following month for monthly filers
- B2B invoice details must include buyer GSTIN, invoice number, date, taxable value, tax
- HSN codes must be 4-digit minimum in GSTR-1

**FREQUENCY**: Once per month | **PRIORITY**: P1

---

*USE_CASES.md v1.0*
*Pressman SEPA 9th Edition — Ch 7.4 (Use Cases) + Ch 8.2 (Scenario-Based Modeling)*
*UC-01 is the foundation — build and test it first before any other use case*
