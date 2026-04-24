# SCRUM_SETUP.md
# RetailOS — Scrum Setup, Product Backlog, Sprint 1 Backlog
# Applying Pressman's Software Engineering (9th Ed.) Chapter 3 — Agility and Scrum
# Version: 1.0 | Day 1 | Updated: Every Sprint

---

## SECTION 1 — SCRUM ARTIFACTS (Pressman Ch 3.4.1)

### 1.1 — Product Backlog (Full — All User Stories)

**Story Format**: "As a [role], I want to [action] so that [benefit]"
**Story Points**: 1=2hrs, 2=4hrs, 3=8hrs, 5=16hrs, 8=32hrs
**Priority**: P1=Month 1 (must), P2=Month 2 (should), P3=Month 3 (could)

---

#### 🔐 AUTHENTICATION (3 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| AUTH-01 | As a shop owner, I want to register my business so that I can access RetailOS | 3 | P1 | 1. Form accepts business name, GSTIN, phone, email, password. 2. Creates org + store + user in Supabase. 3. Redirects to dashboard on success. |
| AUTH-02 | As any team member, I want to log in with email/password so that I can access my store's data | 2 | P1 | 1. Login validates credentials via Supabase Auth. 2. Wrong credentials show clear error. 3. Success redirects to dashboard. 4. Session persists on browser refresh. |
| AUTH-03 | As a shop owner, I want to invite staff members with specific roles so that I can control access | 5 | P2 | 1. Owner can invite by email. 2. Role options: Owner, Manager, Cashier. 3. Invited user receives email and can set password. 4. Cashier cannot access reports or settings. |

---

#### 🧾 POS BILLING (8 stories — most critical)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| POS-01 | As a cashier, I want to search for products by name or barcode so that I can quickly add them to the bill | 3 | P1 | 1. Search returns results within 500ms. 2. Barcode input triggers immediate search. 3. Results show product name, price, stock, GST rate. |
| POS-02 | As a cashier, I want to manage a cart (add/remove/change quantity) so that I can build the customer's bill | 2 | P1 | 1. Add product adds to cart. 2. Quantity +/- buttons work. 3. Remove removes from cart. 4. Cart updates totals instantly. |
| POS-03 | As a cashier, I want the system to auto-calculate GST for each item so that the bill is always tax-correct | 3 | P1 | 1. CGST + SGST calculated for intra-state. 2. IGST calculated for inter-state. 3. Discount applied before tax calculation. 4. All slabs (0/5/12/18/28%) work correctly. |
| POS-04 | As a cashier, I want to apply item-level or bill-level discounts so that I can give offers to customers | 2 | P1 | 1. Discount in % or ₹ accepted. 2. Taxable amount = price after discount. 3. Bill total updates instantly. |
| POS-05 | As a cashier, I want to select the payment method (cash/UPI/card/split) so that I can record how the customer paid | 2 | P1 | 1. All 4 payment modes available. 2. Cash mode shows change due. 3. Split payment allows multiple methods summing to total. 4. Payment recorded in accounts. |
| POS-06 | As a cashier, I want to generate a GST-compliant invoice PDF so that I can give the customer a receipt | 5 | P1 | 1. Invoice shows all required GST fields (GSTIN, HSN, tax breakup). 2. Invoice number auto-generated (INV-00001 format). 3. PDF downloadable and printable. |
| POS-07 | As a cashier, I want to share the bill via WhatsApp so that the customer gets a digital receipt instantly | 2 | P1 | 1. WhatsApp share button opens wa.me with pre-filled bill summary. 2. Link works on mobile. 3. Cashier can share without knowing customer's WhatsApp. |
| POS-08 | As a shop owner, I want inventory to auto-deduct on every sale so that stock levels are always accurate | 3 | P1 | 1. Stock decrements immediately on bill confirmation. 2. If stock < quantity, show warning but allow override. 3. Stock deduction rolls back if bill is cancelled. |

---

#### 📦 INVENTORY MANAGEMENT (6 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| INV-01 | As a manager, I want to add and edit products with full details so that the product master is complete | 3 | P1 | 1. Form accepts name, barcode, category, HSN, GST rate, MRP, cost price, unit. 2. Barcode auto-generated if not provided. 3. Product saved and searchable in POS. |
| INV-02 | As a manager, I want to see real-time stock levels for all products so that I know what's available | 2 | P1 | 1. Stock dashboard shows current qty for all products. 2. Low-stock items highlighted in red. 3. Filterable by category. |
| INV-03 | As a manager, I want to adjust stock manually so that I can correct discrepancies or log wastage | 2 | P1 | 1. Adjustment form accepts reason (received/damaged/expired/correction). 2. Each adjustment logged with timestamp and user. 3. Current stock updates immediately. |
| INV-04 | As a manager, I want to receive low-stock alerts so that I can reorder before running out | 2 | P2 | 1. Reorder level configurable per product. 2. Dashboard highlights products below reorder level. 3. One-click "Request PO" from low-stock alert. |
| INV-05 | As a manager, I want to track batch numbers and expiry dates so that I can manage perishable products | 3 | P2 | 1. Batch/expiry fields in product receive form. 2. Expiry alerts 30 days before date. 3. FEFO (First Expiry First Out) logic in POS stock deduction. |
| INV-06 | As a manager, I want to export inventory reports as Excel/PDF so that I can share with owner or CA | 2 | P2 | 1. Export includes product name, HSN, current stock, value at cost. 2. Date-range filterable. 3. Excel and PDF format options. |

---

#### 🛒 PURCHASE & SUPPLIER (5 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| PUR-01 | As a manager, I want to create and manage supplier records so that I can track who we buy from | 2 | P2 | 1. Supplier form: name, GSTIN, contact, address, payment terms. 2. GSTIN validated on entry. 3. Supplier linked to purchases. |
| PUR-02 | As a manager, I want to create a Purchase Order (PO) so that I can formally request stock from suppliers | 3 | P2 | 1. PO auto-numbered. 2. Products selected from master. 3. PO emailed or shared via WhatsApp to supplier. |
| PUR-03 | As a manager, I want to record Goods Receipt (GRN) when stock arrives so that inventory updates automatically | 3 | P2 | 1. GRN linked to PO. 2. Variance between PO qty and received qty flagged. 3. Stock increments on GRN save. |
| PUR-04 | As an owner, I want to see accounts payable (what we owe suppliers) so that I can plan payments | 3 | P2 | 1. Payable dashboard shows supplier-wise outstanding. 2. Aging: 0-30, 30-60, 60+ days. 3. Record payment against supplier. |
| PUR-05 | As a manager, I want to do 3-way matching (PO vs GRN vs invoice) so that I only pay for what I received | 5 | P2 | 1. System flags if supplier invoice qty/rate differs from GRN. 2. Manager can approve or dispute. 3. Payment blocked until approved. |

---

#### 👥 CUSTOMER & CRM (5 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| CRM-01 | As a cashier, I want to look up a customer by phone at POS so that I can identify loyalty members | 1 | P2 | 1. Phone search at POS returns customer name + points. 2. New customer registered in under 10 seconds. 3. Guest checkout available without customer lookup. |
| CRM-02 | As a cashier, I want to add loyalty points on each purchase so that customers are rewarded | 2 | P2 | 1. Points earned = configurable rate (e.g., 1 point per ₹10). 2. Points shown on invoice. 3. Balance updated in real-time. |
| CRM-03 | As a manager, I want to view full customer purchase history so that I can personalize offers | 2 | P2 | 1. Customer profile shows all bills. 2. Total spending, visit frequency visible. 3. Exportable for WhatsApp campaigns. |
| CRM-04 | As a manager, I want to run WhatsApp campaigns to customer segments so that I can promote offers | 5 | P3 | 1. Filter customers by spending tier or last visit. 2. Message template with variable substitution. 3. wa.me bulk link generation. |
| CRM-05 | As a cashier, I want to redeem loyalty points at POS so that customers can use their rewards | 3 | P2 | 1. Redemption option at payment step. 2. Points-to-₹ rate configurable. 3. Remaining points shown after redemption. |

---

#### 🧮 GST & ACCOUNTING (4 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| GST-01 | As an owner, I want auto-generated GSTR-1 report so that my CA can file monthly returns | 5 | P2 | 1. GSTR-1 format: B2B, B2C, HSN summary. 2. Date range: monthly/quarterly. 3. Excel export in GST portal format. |
| GST-02 | As an owner, I want GSTR-3B summary so that I know my net GST payable | 3 | P2 | 1. Output tax (from sales) vs. Input tax credit (from purchases) shown. 2. Net payable calculated. 3. Exportable for CA review. |
| GST-03 | As an owner, I want a Profit & Loss statement so that I know if my business is profitable | 5 | P2 | 1. Revenue, COGS, gross profit, expenses, net profit shown. 2. Monthly and yearly views. 3. Compare current month vs. last month. |
| GST-04 | As an owner, I want to record cash-in and cash-out transactions so that I track daily cash flow | 2 | P2 | 1. Cash register: opening balance, income entries, expense entries, closing balance. 2. Tied to billing (automatic) and manual entries. 3. Daily cash summary printable. |

---

#### 📊 REPORTS & DASHBOARD (4 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| RPT-01 | As an owner, I want a main dashboard with today's KPIs so that I can see business health at a glance | 3 | P1 | 1. Shows: Today's sales, bills count, top product, low stock count. 2. Loads in <2 seconds. 3. Works on mobile. |
| RPT-02 | As a manager, I want daily/weekly/monthly sales reports so that I can track revenue trends | 3 | P2 | 1. Sales by date range. 2. Breakdown by product, category, cashier, payment method. 3. Chart + table view. Export to Excel/PDF. |
| RPT-03 | As an owner, I want to see top-selling and slow-moving products so that I optimize my stock buying | 2 | P2 | 1. Ranked by sales qty and revenue. 2. Date-range filterable. 3. Slow movers flagged (no sale in 30 days). |
| RPT-04 | As an owner, I want to export any report as PDF or Excel so that I can share with partners or CA | 2 | P2 | 1. Export button on all report pages. 2. PDF: print-ready format. 3. Excel: raw data for further analysis. |

---

#### 🏪 MULTI-STORE (3 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| STR-01 | As a chain owner, I want an HQ dashboard comparing all stores so that I see business at a glance | 5 | P3 | 1. All stores' revenue, stock value, top products visible. 2. Drill-down into any store. 3. Alerts: low-performing stores. |
| STR-02 | As a chain owner, I want to transfer stock between stores so that I can balance inventory | 3 | P3 | 1. Transfer request created at source. 2. Confirmed at destination. 3. Both stores' inventories update simultaneously. |
| STR-03 | As an owner, I want staff to only access their assigned store so that data is isolated | 3 | P2 | 1. Staff login shows only their store's data. 2. RLS policies enforce store-level isolation. 3. Owner can access all stores. |

---

#### 👨‍💼 HR & PAYROLL (3 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| HR-01 | As an owner, I want to manage staff profiles and attendance so that I track my team | 3 | P3 | 1. Staff form: name, role, phone, join date, salary. 2. Daily attendance marking (present/absent/half-day). 3. Monthly attendance summary. |
| HR-02 | As an owner, I want to calculate monthly payroll so that I can pay staff accurately | 5 | P3 | 1. Auto-calculates based on attendance + fixed salary. 2. Deductions field (advance, fine). 3. Payslip PDF generated. |
| HR-03 | As an owner, I want to record salary payments so that I track payroll expenses | 2 | P3 | 1. Payment recorded against staff. 2. Linked to cash flow / accounting. 3. Year-to-date salary visible per staff. |

---

#### ⚙️ SETTINGS & ADMIN (3 stories)

| ID | User Story | Points | Priority | Acceptance Criteria |
|---|---|---|---|---|
| SET-01 | As an owner, I want to configure my business profile so that invoices show correct details | 2 | P1 | 1. Form: business name, address, GSTIN, logo, phone. 2. Logo appears on all invoices. 3. Changes live immediately. |
| SET-02 | As an owner, I want to configure tax groups and HSN codes so that products are taxed correctly | 2 | P1 | 1. All 5 GST slabs pre-configured. 2. Custom HSN codes addable. 3. Linked to product master. |
| SET-03 | As an owner, I want to configure invoice settings (prefix, terms, footer) so that bills look professional | 1 | P2 | 1. Invoice prefix customizable (INV, BILL, etc.). 2. Terms & conditions text field. 3. Footer message field. |

---

### 1.2 — Sprint 1 Backlog (Days 8–14)
**Sprint Goal**: Working React app with authentication, app shell, and dashboard deployed to Vercel.

**Capacity**: 10 hrs/week × 2 people = ~20 hrs | At 1pt = 2hrs → **~30-35 story points**

| ID | Story | Points | Day |
|---|---|---|---|
| SET-01 | Business profile configuration | 2 | Day 8 |
| SET-02 | Tax groups and HSN configuration | 2 | Day 9 |
| AUTH-01 | Register business | 3 | Day 10 |
| AUTH-02 | Login / Logout | 2 | Day 10 |
| — | App layout: Sidebar + Header + Router | 3 | Day 11 |
| — | Supabase: All tables, RLS policies, Auth helpers | 5 | Day 9 |
| RPT-01 | Dashboard with today's KPIs | 3 | Day 12 |
| — | Utility files: gst.js + formatters.js + validators.js | 5 | Day 13 |
| — | Sprint review + retrospective + Sprint 2 planning | 2 | Day 14 |

**Total: 27 points** (conservative — leaves room for setup overhead on Day 8)

**Sprint 1 Acceptance Criteria (overall):**
- [ ] Vercel URL is live and publicly accessible
- [ ] Register → Login → See Dashboard works end-to-end
- [ ] Sanjana can test on her phone without errors
- [ ] GST utility functions pass all unit test cases
- [ ] No console errors on any page

---

### 1.3 — Definition of Done (Pressman Ch 3.4.1)

A user story is **DONE** only when ALL of these are true:

```
CODE:
□ Feature code written and self-reviewed by developer
□ No console.log() statements left in production code
□ No unused imports or dead code
□ Runs without errors: npm run dev + npm run build

TESTING:
□ Developer tested: happy path works as expected
□ Developer tested: at least 1 error/edge case handled gracefully
□ Sanjana tested on desktop Chrome — passes
□ Sanjana tested on mobile Chrome (Android) — passes
□ Sanjana tested: at least 1 edge case (empty field, invalid input) — passes
□ Bug count = 0 (or documented in Google Sheet as "known / won't fix")

QUALITY:
□ Unit tests written for any calculation or validation logic
□ GST calculations verified against manual calculation
□ No accessibility issues (text readable, buttons tappable on mobile)

DEPLOYMENT:
□ Code committed to feature branch with descriptive commit message
□ Pull Request created and merged to dev branch
□ Vercel preview URL shared with Sanjana for testing
□ After Sanjana approval: merged to main → Vercel production deploy

DOCUMENTATION:
□ Google Sheet bug tracker updated (bugs found + resolved)
□ Sprint backlog story marked as "Done"
□ Any known limitations documented in GitHub Issue
```

---

## SECTION 2 — SCRUM CEREMONIES (Pressman Ch 3.4.2–3.4.5)

### Sprint Planning Meeting Template
**When**: Day 1 of each sprint (Monday morning) | **Duration**: 30–45 minutes
**With**: Developer + Sanjana (optional but encouraged)

```
SPRINT PLANNING AGENDA:
━━━━━━━━━━━━━━━━━━━━━━━
1. REVIEW (5 min)
   - What did we complete last sprint? (check Definition of Done for each story)
   - What didn't we finish? Why? (add back to Product Backlog top)
   - Velocity: story points completed / story points planned = ___%

2. GOAL (5 min)
   - What is the ONE sentence sprint goal?
   - Example: "By end of this sprint, a cashier can generate a GST-correct bill"

3. SELECT STORIES (15 min)
   - Pull from top of Product Backlog
   - Verify each story is P1 for this sprint
   - Estimate story points (use Planning Poker if uncertain)
   - Total must be ≤ capacity (10 hrs dev × 1pt/2hrs = max 30-35 pts)
   - Add no more stories than can be completed — better to under-commit

4. BREAKDOWN (10 min)
   - For each story: what are the specific tasks? (code this component, write this query, etc.)
   - Assign day numbers to each story (rough sequencing)
   - Identify dependencies (Story B needs Story A first)

5. RISK CHECK (5 min)
   - Any blockers identified before starting?
   - Any stories that need research before coding?
   - Anything Sanjana needs to research in shops this sprint?

OUTPUT:
   □ Sprint backlog documented in Google Sheet
   □ Sprint goal written at top of backlog
   □ Day-by-day rough schedule set
   □ Sanjana briefed on what to test and when
```

---

### Daily Standup Template (Async — WhatsApp Note)
**When**: Every morning before starting work | **Duration**: 3 minutes to write
**Format**: WhatsApp note to self + shared with Sanjana

```
📅 [DATE] — Day [X] of Sprint [N]

✅ YESTERDAY I BUILT:
   [One line describing what you completed]
   e.g., "Completed login screen — register + login working on Vercel preview"

🔨 TODAY I WILL BUILD:
   [One line with today's specific task]
   e.g., "Building app sidebar + routing structure (INV-02 started)"

🚫 BLOCKED BY:
   [One line — or "Nothing blocking me today"]
   e.g., "Waiting for Sanjana's test result on login page before merging"

📊 SPRINT PROGRESS:
   [X] / [Y] story points done | [Z] days remaining
```

**Rules:**
- Write this BEFORE opening code editor — it sets your intention
- If blocked, message Sanjana or open a GitHub Issue immediately
- Never write "did nothing yesterday" — break the story into smaller tasks so there's always something done

---

### Sprint Review Template
**When**: Last day of sprint (Sunday or Day 14) | **Duration**: 45–60 minutes
**With**: Developer + Sanjana | **Tools**: Vercel URL, Google Sheet

```
SPRINT REVIEW AGENDA:
━━━━━━━━━━━━━━━━━━━━
1. DEMO (20 min)
   Developer demonstrates every completed story on the Vercel URL.
   For each story:
   - Show the happy path (normal use)
   - Show one edge case (empty input, error state)
   - Confirm: does it match the Acceptance Criteria from the backlog?

2. SANJANA'S VERDICT (15 min)
   For each demonstrated story, Sanjana says:
   - ✅ PASS — story is DONE per Definition of Done
   - ❌ FAIL — specific bug/issue found → logged in Google Sheet Bug Tracker
   - ⚠️ FEEDBACK — not a bug but a UX concern → logged in Product Backlog

   Sanjana also tests on her phone during this session.

3. METRICS REVIEW (5 min)
   Review the Google Sheet metrics tab:
   - Story points planned vs. completed
   - Bugs found vs. bugs fixed
   - Any quality metrics (load time, GST calculation accuracy)

4. PRODUCT BACKLOG GROOMING (10 min)
   - Any stories from the field research to add?
   - Re-prioritize top 10 Product Backlog items for next sprint
   - Remove any stories that are no longer relevant

5. SPRINT DECISIONS (5 min)
   - Stories marked FAIL: fix in Sprint N+1 or add to sprint start as carry-over?
   - Velocity calculated → adjust next sprint capacity if needed

OUTPUT:
   □ Sprint review notes in Google Sheet → "Sprint Reviews" tab
   □ All FAIL stories converted to Bug Tracker entries
   □ Product Backlog updated with any new insights
   □ Next sprint's top 10 stories identified (not finalized — that's planning)
```

---

### Sprint Retrospective Template
**When**: After Sprint Review, same day | **Duration**: 20–30 minutes
**With**: Developer + Sanjana

```
RETROSPECTIVE FORMAT (Start-Stop-Continue):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT WENT WELL? (Continue doing these)
   → Things that helped the sprint succeed
   → Process that worked, good practices to keep
   Examples: "Daily standup kept us aligned", "Sanjana catching bugs before main merge saved time"

WHAT SHOULD WE IMPROVE? (Start doing these)
   → Things missing that would have helped
   → New practices to add next sprint
   Examples: "Should have written unit tests before coding GST", "Need to wireframe before building"

WHAT SHOULD WE STOP? (Stop doing these)
   → Things that wasted time or caused problems
   → Habits or practices to eliminate
   Examples: "Stop building features not in sprint backlog", "Stop skipping commit messages"

ACTION ITEMS (Specific and assigned):
   1. [Action] — Owner: [Developer/Sanjana] — Due: [Day]
   2. [Action] — Owner: ...
   (Max 3 action items — fewer is better, must be achievable next sprint)

TEAM MORALE CHECK (private, honest):
   Developer: How do you feel about the project? (1-10)
   Sanjana: How do you feel about your role? (1-10)
   If either < 6: discuss openly before next sprint

OUTPUT:
   □ Retrospective notes saved in Google Sheet → "Retrospectives" tab
   □ Action items added to Sprint N+1 planning agenda
   □ Team morale score logged (track over time)
```

---

## SECTION 3 — GOOGLE SHEET STRUCTURE

Set up one Google Sheet: **RetailOS Project Tracker**

| Tab Name | Purpose | Updated By |
|---|---|---|
| **Sprint Backlog** | Current sprint stories, status, story points | Developer daily |
| **Product Backlog** | All future stories, priority, estimates | Developer weekly |
| **Bug Tracker** | All bugs: description, severity, status, reporter | Sanjana after testing |
| **Shop Research** | Interview notes from shop visits | Sanjana after visits |
| **Sprint Reviews** | Per-sprint outcomes, velocity | Developer per sprint |
| **Retrospectives** | Per-sprint retro notes, action items | Developer per sprint |
| **Metrics** | Bug count, velocity, load times, coverage | Developer weekly |
| **Sprint 2 Research** | Cashier behavior observations for POS module | Sanjana (Week 2) |

---

## SECTION 4 — VELOCITY & ESTIMATION GUIDE

**Story Points Reference:**

| Points | Hours | Complexity | Example |
|---|---|---|---|
| 1 | 2 hrs | Very simple — 1 component, no logic | Add a settings text field |
| 2 | 4 hrs | Simple — small component + data | Login form + Supabase auth call |
| 3 | 8 hrs | Medium — component + logic + testing | GST calculation + unit tests |
| 5 | 16 hrs | Complex — multiple components + API + tests | Full POS cart with GST + payment |
| 8 | 32 hrs | Very complex — full module | Complete inventory management module |

**Sprint 1 Capacity Calculation:**
```
Developer:  7 hrs/week × 2 weeks = 14 hrs → ~7 story points
Setup overhead (Day 8): 2 hrs → reduces to ~12 hrs productive → 6 pts
Sanjana testing: 3 hrs/week × 2 weeks = 6 hrs → ~3 pts (review + bug reporting)
Total capacity: ~27-30 story points (conservative)
```

**After Sprint 1, calculate actual velocity:**
```
Velocity = Story Points Completed / Story Points Planned
If velocity = 0.8 → we complete 80% of what we plan
Use this to calibrate Sprint 2 capacity
```

---

*RetailOS SCRUM_SETUP.md v1.0*
*Pressman SEPA 9th Edition — Ch 3 (Agility and Scrum)*
*Sprint 1 starts: Day 8 | Sprint 1 ends: Day 14*
