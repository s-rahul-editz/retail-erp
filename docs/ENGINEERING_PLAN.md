# ENGINEERING_PLAN.md
# RetailOS — Retail ERP SaaS for Indian Shops
# Applying Pressman's Software Engineering: A Practitioner's Approach (9th Ed.)
# Version: 1.0 | Date: Day 1 | Team: Developer + Sanjana + Claude

---

## SECTION 1 — SOFTWARE DEFINITION (Pressman Ch 1.1)

### 1.1 Software Type Classification (Ch 1.1.2)
RetailOS falls into **multiple software categories**:

| Category | Applies? | Reason |
|---|---|---|
| **Web/Cloud Application** | ✅ Primary | Browser-based SaaS, hosted on Vercel, data in Supabase |
| **Mobile Application** | ✅ Secondary | Must work on mobile browsers; cashiers use phones at POS |
| **Business Application** | ✅ Primary | Replaces manual billing, inventory ledgers, and cash registers |
| **AI/ML Application** | ⏳ Month 3 | Demand forecasting and smart reporting planned in Sprint 11 |
| **Embedded Software** | ❌ No | No device firmware required |
| **Systems Software** | ❌ No | Not OS-level or infrastructure software |

**Primary Classification: Web-based Business SaaS Application with planned AI features.**

### 1.2 Software Application Domain
RetailOS belongs to the **Enterprise Resource Planning (ERP)** domain, specifically:
- **Vertical ERP** — built for a specific industry (Indian retail: kirana stores, supermarkets, pharmacies, textile shops)
- **SaaS delivery model** — multi-tenant, subscription-based
- **Compliance-critical domain** — GST law mandates specific invoice formats and reporting; errors can result in legal penalties for shop owners

### 1.3 Key Software Characteristics (Ch 1.1.1 — Pressman's 7 Characteristics)

| Characteristic | How It Applies to RetailOS |
|---|---|
| **1. Software is developed, not manufactured** | Each feature is engineered by us; no physical production. Quality must be built in from design, not inspected in at the end. |
| **2. Software doesn't "wear out"** | Our code won't degrade with use, but it will require constant maintenance as GST laws change, browsers update, and Supabase APIs evolve. |
| **3. Software is complex** | POS + Inventory + GST + CRM + Accounting + Multi-store = deeply interconnected modules. One bug in GST calculation affects billing, accounting, and legal reports. |
| **4. Software is a logical element** | RetailOS has no physical component — it exists as logic, data, and user experience. |
| **5. Most software is built on existing software** | We stand on React, Supabase, Tailwind, Vercel, date-fns, jsPDF — all third-party. We manage integration risk. |
| **6. Software deteriorates without maintenance** | Feature requests from shop owners, browser updates, Supabase API changes, new GST rules — all require ongoing updates. |
| **7. New software is often built from components** | We will create reusable components: `<DataTable>`, `<GSTBreakdown>`, `<InvoicePDF>`, `<CustomerSearch>` — usable across all modules. |

### 1.4 Legacy Software Considerations
Shop owners currently use:
- **Paper registers / manual khata** — no digital integration possible; we must replicate the mental model
- **Tally ERP** — desktop-only, complex, expensive; shop owners dislike it but know its concepts (ledgers, vouchers)
- **Simple billing apps** (StoreHippo, Vyapar, Marg) — we must understand their workflows and be simpler
- **WhatsApp** — deeply embedded in daily business; we integrate (receipts, alerts) rather than replace

**Strategy**: Adopt familiar language (bill, stock, purchase entry, party), not enterprise jargon (invoice, SKU, GRN).

---

## SECTION 2 — PROJECT SCOPE (Pressman Ch 24.3)

### 2.1 Context — The Problem We Solve

Indian retail (₹66 lakh crore market, 10+ crore small shops) is:
- Largely undigitized — 70%+ of kirana stores still use manual billing
- GST-mandated — every shop must file monthly GSTR-1 and GSTR-3B returns
- Underserved by software — existing ERPs are either too expensive (Tally ₹18,000/yr) or too simple (basic billing apps with no accounting)

**RetailOS solves:** Digital transformation for Indian small retailers — one app replacing billing machine + inventory notebook + customer register + GST accountant.

### 2.2 Information Objectives

| Information Type | Input | Processing | Output |
|---|---|---|---|
| **Sales data** | Cashier scans items, selects payment | GST calculation, stock deduction, account posting | Invoice PDF, WhatsApp receipt, daily sales report |
| **Inventory data** | Received stock, adjustments | Stock tracking, low-stock detection | Stock dashboard, reorder alerts, inventory report |
| **Customer data** | Phone number, name at POS | Loyalty point calculation, purchase history | Customer card, loyalty balance, WhatsApp campaign |
| **Purchase data** | Supplier invoice entry | 3-way matching (PO → GRN → Bill), account payable | Purchase report, payable statement, supplier ledger |
| **GST data** | Every sale and purchase transaction | Tax classification (CGST/SGST/IGST), HSN matching | GSTR-1, GSTR-3B reports for CA filing |
| **Financial data** | All transactions | Double-entry bookkeeping | P&L statement, balance sheet, cash flow |

### 2.3 Top 10 Functions (High Level)

1. **Point of Sale (POS) Billing** — Generate GST-compliant bills in under 30 seconds
2. **Inventory Management** — Real-time stock tracking with low-stock alerts
3. **Purchase Management** — Manage suppliers, purchase orders, goods receipt
4. **Customer & CRM** — Customer profiles, loyalty programs, WhatsApp campaigns
5. **GST Accounting** — Auto-generate GSTR-1, GSTR-3B, HSN summary reports
6. **Financial Reports** — P&L, balance sheet, cash management
7. **Multi-store Management** — HQ dashboard comparing all store performance
8. **User Access Control** — Role-based access (owner, manager, cashier)
9. **Data Export** — Excel/PDF export of all reports
10. **WhatsApp Integration** — Automated receipts, payment reminders, low-stock alerts

### 2.4 Performance Goals

| Metric | Target | Rationale |
|---|---|---|
| **Bill generation speed** | < 30 seconds from first scan to printed/WhatsApp receipt | Customers queue; slow billing loses business |
| **System uptime** | 99.5% during business hours (8 AM – 10 PM) | A shop cannot operate if billing is down |
| **GST calculation accuracy** | 100% — zero tolerance | Legal liability for incorrect GST |
| **Page load time** | < 2 seconds on 4G mobile | Most shop owners use mid-range Android phones on 4G |
| **Data sync** | < 5 seconds lag for inventory updates | Prevents overselling when 2 cashiers bill simultaneously |
| **Mobile compatibility** | Works on Chrome/Android 8+ | Target: ₹8,000–₹15,000 Android phones |

### 2.5 Constraints

| Constraint | Details |
|---|---|
| **Budget** | ₹0/month — free tier only (Supabase Free, Vercel Hobby, GitHub Free) |
| **Timeline** | 90 days to working MVP |
| **Team size** | 2 people — 7 hrs/week (developer) + 3 hrs/week (QA/analyst) |
| **Technical** | No backend server (Supabase edge functions only), no paid APIs |
| **Regulatory** | Must comply with GST Act 2017 invoice format requirements |
| **Scale limit** | Free Supabase: 500MB DB, 2GB file storage — sufficient for MVP with <50 active stores |

### 2.6 Out of Scope (90 Days)

The following will NOT be built in this sprint plan:
- Manufacturing/production module
- Payroll with PF/ESI compliance (basic payroll only)
- Full e-invoicing IRN generation via GST portal API (format only)
- Native mobile app (iOS/Android — web app only)
- Multi-currency support
- ERP for chains with >10 stores
- Custom report builder
- Integrated payment gateway (UPI QR shown, not automated settlement)

---

## SECTION 3 — THE W5HH PRINCIPLE (Pressman Ch 24.6)

### WHY — Why is RetailOS being developed?
Because 10 crore Indian shop owners deserve affordable, GST-compliant, mobile-first business software. Tally costs ₹18,000/year and requires a trained accountant. Basic billing apps don't do inventory or GST reports. RetailOS bridges this gap — a complete, free-to-try SaaS that shop owners can operate themselves.

Personal why: Build a real, production-grade software product following professional engineering principles, gain startup experience, and create a potential revenue-generating SaaS.

### WHAT — What will be done each sprint?

| Sprint | Duration | What Gets Built |
|---|---|---|
| Sprint 0 (Week 1) | Days 1–7 | Planning, requirements, architecture, design, dev setup |
| Sprint 1 (Week 2) | Days 8–14 | Auth, app shell, dashboard skeleton |
| Sprint 2 (Week 3) | Days 15–21 | POS billing module (core feature) |
| Sprint 3 (Week 4) | Days 22–28 | Inventory module |
| Sprint 4 (Week 5) | Days 29–35 | Purchase & supplier module |
| Sprint 5 (Week 6) | Days 36–42 | CRM & customer module |
| Sprint 6 (Week 7) | Days 43–49 | Accounting & GST reports |
| Sprint 7 (Week 8) | Days 50–56 | Reports, dashboards, multi-store |
| Sprint 8–11 | Weeks 9–12 | HR, warehouse, e-commerce, AI features |
| Sprint 12 (Week 13) | Days 85–90 | Bug fixing, performance, production launch |

### WHEN — Milestone Schedule

| Milestone | Target Date | Success Criteria |
|---|---|---|
| Architecture complete | Day 4 | All diagrams done, tech stack confirmed |
| Dev environment live | Day 6 | GitHub + Supabase + Vercel connected |
| Auth working | Day 10 | Login/Register/Logout on Vercel |
| First bill generated | Day 17 | GST-correct bill created in POS module |
| Month 1 MVP | Day 28 | POS + Inventory working, Sanjana tested |
| Month 2 MVP | Day 56 | All core modules working, 1 pilot shop |
| Production launch | Day 90 | First paying customer onboarded |

### WHO — Responsibility Matrix

| Function | Owner | Support |
|---|---|---|
| Product decisions (what to build) | Developer | Sanjana's shop research |
| Architecture & coding | Developer | Claude |
| Requirements gathering | Sanjana (field) | Developer (user stories) |
| Testing (QA) | Sanjana | Developer (unit tests) |
| Design (wireframes, UX) | Developer | Claude |
| GST compliance research | Developer | Claude |
| Sprint facilitation | Developer (Scrum Master) | — |
| Stakeholder communication | Developer (Product Owner) | Sanjana |

### WHERE — Team Location
- Developer: Remote, async-first
- Sanjana: Field researcher (shop visits in local area) + remote testing
- Claude: Available 24/7 as coding assistant and technical advisor
- All code: GitHub repository (remote)
- All deployments: Vercel (cloud)
- All data: Supabase (cloud, Singapore region)

### HOW — Technical and Managerial Approach

**Technical:**
- React + Vite + TypeScript-ready (plain JS for speed)
- Tailwind CSS for rapid UI development
- Supabase for database, auth, realtime, storage
- Vercel for hosting and edge functions
- GitHub for version control (main/dev/feature branches)

**Managerial:**
- 2-week Scrum sprints
- Daily async standup in WhatsApp note format
- Sprint review with Sanjana every 2 weeks
- Pressman's RMMM (Risk Monitoring, Mitigation, Management) applied continuously
- Friday weekly reviews (30 mins): progress vs plan, risk update, next week plan

### HOW MUCH — Resource Estimates

| Resource | Amount | Notes |
|---|---|---|
| **Developer time** | 7 hrs/week × 13 weeks = ~91 hours | Primary constraint |
| **Sanjana time** | 3 hrs/week × 13 weeks = ~39 hours | Testing + field research |
| **Claude sessions** | Unlimited | AI pair programmer |
| **Budget** | ₹0/month | All free tiers |
| **Storage** | 500MB Supabase | Sufficient for MVP |
| **Bandwidth** | 100GB Vercel | Sufficient for <500 users |

---

## SECTION 4 — PROCESS MODEL SELECTION (Pressman Ch 2, 3, 4)

### Why NOT Waterfall (Ch 2.5.1)?
Waterfall requires:
- Complete requirements before design, design before coding
- In RetailOS, **shop owners don't know what they want until they see it** — requirements will evolve as Sanjana does field research
- A bug discovered at testing phase requires reworking everything upstream
- **Verdict: Waterfall would kill this project.** Too rigid for a startup product with evolving requirements.

### Why Agile Scrum (Ch 3) — and its limits?
Scrum is right because:
- Delivers working software every 2 weeks (not at end of project)
- Adapts to changing requirements between sprints
- Sanjana's shop research continuously informs the backlog

But pure Scrum assumes team already understands the product. We don't yet know how Indian shop billing works in detail. **We need a prototype to validate assumptions before committing to final architecture.**

### Why Recommended Process Model (Ch 4) — Our Hybrid Approach
Pressman's recommended model says: **communicate → plan → model → construct → deploy** in iterative cycles, with prototyping to reduce uncertainty early.

**Our hybrid = Agile Scrum sprints + Prototype-first validation:**

```
WEEK 1 (Sprint 0):     Requirements + Design + Architecture
                        → No code, pure modeling (Ch 7, 8, 9, 10)

WEEK 2 (Sprint 1):     Prototype — Auth + Shell + Dashboard
                        → Working but thin (Ch 4 Prototype Model)

END OF WEEK 2:          Prototype Evaluation (Sanjana + Developer)
                        → Is the architecture right? Is UX correct?
                        → Go: proceed | No-Go: refactor before adding features

WEEKS 3-13:            Full Scrum sprints building on validated prototype
                        → 2-week cycles with testing, review, retrospective
```

This gives us the **safety of up-front modeling** combined with the **flexibility of Agile delivery**.

---

## SECTION 5 — TEAM STRUCTURE (Pressman Ch 5, 24.2)

### 5.1 Team Structure Type (Ch 5.4)
With 2 people, we use a **Closed Paradigm team structure** (also called "Chief Programmer Team"):
- One lead (Developer) makes final technical decisions
- All roles are explicitly defined and non-overlapping
- Communication is direct and synchronous when needed, async by default

### 5.2 Role Definitions

| Person | Role | Responsibilities |
|---|---|---|
| **Developer** | Product Owner + Scrum Master + Lead Developer | Architecture, all coding, sprint planning, backlog management, deployment |
| **Sanjana** | QA Engineer + Business Analyst | Shop interviews, requirements validation, manual testing (desktop + mobile), bug reporting |
| **Claude** | AI Pair Programmer + Technical Advisor | Code generation, architecture review, debugging, documentation generation |

### 5.3 Communication Plan

| Channel | Purpose | Frequency |
|---|---|---|
| **WhatsApp** | Daily standup, quick questions, test results | Daily (3 lines: done/today/blocked) |
| **GitHub Issues** | Bug tracking, feature discussions | Per bug/feature |
| **Google Sheet** | Bug tracker, shop research, metrics | Updated after every test session |
| **Video call** | Sprint review, retrospective, complex discussions | Every 2 weeks (sprint end) |
| **GitHub commits** | Code changes with meaningful messages | Per feature, not per day |

### 5.4 Decision Making
- **Technical decisions** (architecture, libraries, implementation): Developer decides
- **Product decisions** (features, priority, UX): Developer decides, with Sanjana's field research as primary input
- **Scope changes**: Developer + Sanjana discuss; new items go to Product Backlog, not current sprint
- **When stuck on technical problem**: Ask Claude, then StackOverflow/docs, then post as GitHub Issue

### 5.5 Contingency Plan
**If Developer unavailable for 1 week:**
- Sprint paused, not cancelled
- Sanjana continues shop research and documents findings
- Milestone dates shift by 1 week; no permanent plan change

**If Sanjana unavailable for 1 week:**
- Developer performs basic testing (happy path only)
- Sprint continues; Sanjana catches up with full testing next sprint
- Any untested features tagged as "needs Sanjana review" in backlog

---

## APPENDIX — DOCUMENT INDEX

This charter references and should be read alongside:
- `RISK_REGISTER.md` — All project risks with RMMM plans (Pressman Ch 26)
- `SCRUM_SETUP.md` — Scrum ceremonies, Product Backlog, Sprint 1 Backlog (Pressman Ch 3)
- `REQUIREMENTS_SPECIFICATION.md` — User stories, use cases (Pressman Ch 7, 8) — Due Day 2
- `ARCHITECTURE.md` — System architecture, tech stack decision (Pressman Ch 10) — Due Day 4
- `QUALITY_PLAN.md` — Quality factors, Definition of Done (Pressman Ch 15, 17) — Due Day 7

---

*RetailOS ENGINEERING_PLAN.md v1.0*
*Pressman SEPA 9th Edition — Ch 1, 3, 4, 5, 24, 25*
*Team: Developer + Sanjana + Claude*
