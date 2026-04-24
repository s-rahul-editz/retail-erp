# RISK_REGISTER.md
# RetailOS — Software Risk Register
# Applying Pressman's Software Engineering (9th Ed.) Chapter 26 — Risk Management
# Version: 1.0 | Day 1 | Review: Every Friday

---

## SECTION 1 — RISK CATEGORIES (Pressman Ch 26.2)

### 1.1 Project Risks (affect plan, schedule, resources)
Risks that threaten the project plan, timeline, or team capacity.
Examples: student time constraints, scope creep, loss of team member.

### 1.2 Technical Risks (affect quality or timeliness)
Risks that threaten the quality or correctness of the software being built.
Examples: GST calculation errors, offline sync conflicts, performance degradation.

### 1.3 Business Risks (affect product viability)
Risks that threaten whether the product will succeed in the market.
Examples: shop owners not adopting, competitor moves, GST law changes.

### 1.4 Known Risks (predictable)
Risks we can identify and plan for in advance.
All 15 risks in Section 2 are known risks based on project context.

### 1.5 Unknown Risks (unpredictable) — Categories of Unknowns
We cannot predict specific unknowns, but they likely fall in:
- **Technology unknowns**: Supabase or Vercel announcing pricing/API changes
- **Regulatory unknowns**: GST law amendments requiring retroactive code changes
- **Market unknowns**: A well-funded competitor launching a free ERP for kirana shops
- **Personal unknowns**: Health, family, or academic emergencies affecting team
- **Security unknowns**: A zero-day vulnerability in a library we depend on

**Strategy for unknowns**: Monthly risk review. Add new risks as discovered. Maintain 1-week buffer in schedule.

---

## SECTION 2 — RISK TABLE (Pressman Ch 26.4.1)

| Risk ID | Category | Description | Probability | Impact | Priority |
|---|---|---|---|---|---|
| R01 | Project | Student time constraints — 10 hrs/week commitment not maintained | High | High | 🔴 Critical |
| R02 | Technical | GST calculation errors leading to incorrect billing | Medium | Critical | 🔴 Critical |
| R03 | Project | Scope creep — shop owners request new features mid-sprint | High | High | 🔴 Critical |
| R04 | Technical | Data loss — sales, inventory, customer data lost | Low | Critical | 🔴 Critical |
| R05 | Technical | Security breach — customer financial data exposed | Low | Critical | 🔴 Critical |
| R06 | Project | Sanjana unavailable during key testing phase | Medium | Medium | 🟡 High |
| R07 | Technical | Supabase free tier paused or limits exceeded | Low | High | 🟡 High |
| R08 | Technical | Vercel function timeout on complex reports (10s limit) | Medium | High | 🟡 High |
| R09 | Business | Shop owners don't adopt RetailOS after launch | Medium | High | 🟡 High |
| R10 | Technical | Offline sync conflicts in POS (2 cashiers billing simultaneously) | Medium | High | 🟡 High |
| R11 | Technical | Dashboard slow with 10,000+ sales records (full table scans) | Medium | Medium | 🟠 Medium |
| R12 | Project | Requirements changing after feature coding has started | Medium | Medium | 🟠 Medium |
| R13 | Technical | WhatsApp API (wa.me links) rate limits for receipts | Low | Medium | 🟠 Medium |
| R14 | Business | Competitor (Vyapar, Khatabook) adds identical features | Medium | Medium | 🟠 Medium |
| R15 | Business | GST law change requiring retroactive code changes | Low | High | 🟠 Medium |

---

## SECTION 3 — RMMM PLANS (Pressman Ch 26.7)
### Top 5 Highest-Priority Risks — Detailed RMMM

---

### R01 — Student Time Constraints
**Risk**: 7 hrs/week developer commitment drops below minimum, causing sprint failures and plan slippage.
**Probability**: High | **Impact**: High

**MITIGATION (prevent it):**
- Commit to a fixed weekly schedule: e.g., Mon 2hrs + Wed 2hrs + Sat/Sun 3hrs
- Treat RetailOS sprints like scheduled classes — non-negotiable time blocks
- Each sprint has a minimum viable deliverable — even 5 hrs/week produces something
- Prompt plan provides ready-to-use prompts so no time is wasted figuring out what to do
- Break every day's work into 1-hour units — one Pomodoro = one task

**MONITORING (detect early):**
- If daily standup is skipped for 3 consecutive days — trigger
- If < 4 story points completed by Day 5 of a sprint — trigger
- Weekly Friday review: actual hours vs. planned 7 hours

**MANAGEMENT (if it happens):**
- Immediately reduce sprint scope to 50% — do fewer things completely, not more things half-done
- Push non-P1 stories to backlog — never sacrifice quality for quantity
- Communicate openly to Sanjana — adjust testing timeline
- Never skip the sprint review — even a half-done sprint needs to be reviewed

---

### R02 — GST Calculation Errors
**Risk**: Incorrect CGST/SGST/IGST calculation causes shop owners to under/overcharge customers and file incorrect GST returns, exposing them to legal penalties.
**Probability**: Medium | **Impact**: Critical (legal, financial, reputational)

**MITIGATION (prevent it):**
- Write `utils/gst.js` as the single source of truth for ALL tax calculations — no inline calculations anywhere
- Write unit tests for every GST function before using it in POS (Pressman Ch 19)
- Test all 5 GST slabs: 0%, 5%, 12%, 18%, 28%
- Test both intra-state (CGST + SGST) and inter-state (IGST) scenarios
- Test discount scenarios — taxable value must be calculated on post-discount amount
- Cross-verify against GST Council's official calculation examples
- Have Sanjana manually verify 10 sample bills against a Tally calculation

**MONITORING (detect early):**
- Unit test suite must pass 100% before any POS code goes to main branch
- Every sprint review includes a GST calculation spot-check (5 random bills)
- Code review required for any change to `gst.js`

**MANAGEMENT (if it happens):**
- Immediately roll back the affected deployment to last known-good version
- Add the failed test case to the unit test suite
- Audit all bills generated during the error period
- Communicate proactively to any pilot shops — do not hide errors

---

### R03 — Scope Creep
**Risk**: Shop owners (via Sanjana's research) or personal ideas cause new features to be added mid-sprint, breaking the plan and producing half-finished modules.
**Probability**: High | **Impact**: High

**MITIGATION (prevent it):**
- Strict sprint backlog — once Sprint starts, its backlog is frozen
- All new ideas go to the Product Backlog (Google Sheet) immediately — they do not enter the current sprint
- Sanjana's research findings are collected weekly and reviewed at sprint planning, not acted on immediately
- Apply Pressman's Ch 3.4.1 — only Product Owner can change sprint backlog (that's you)
- For each new idea, ask: "Will this make or break the MVP?" If no → backlog.

**MONITORING (detect early):**
- Daily standup note includes current sprint tasks only
- If a day's work isn't in the sprint backlog, it's scope creep
- Sprint backlog stored in Google Sheet — track additions vs. original list

**MANAGEMENT (if it happens):**
- Stop the unplanned work immediately
- Add the item to the Product Backlog
- Complete the current sprint items first
- Discuss at next sprint planning whether the new item should enter next sprint

---

### R04 — Data Loss
**Risk**: Sales records, inventory data, or customer data is permanently lost due to accidental deletion, Supabase issue, or developer error.
**Probability**: Low | **Impact**: Critical (shop owners' business data)

**MITIGATION (prevent it):**
- Enable Supabase daily automated backups (free tier — 7-day point-in-time recovery)
- Never run `DELETE` or `TRUNCATE` SQL statements on production without a backup first
- Use soft deletes (`is_deleted = true`) for all user-facing data — never hard delete
- Row Level Security (RLS) on all tables — prevent accidental cross-tenant data access
- Separate dev database from production database — never use production for testing

**MONITORING (detect early):**
- Weekly check: Supabase dashboard → Backups section → confirm last backup timestamp
- Monitor Supabase usage dashboard — storage and connection limits
- If any data anomaly reported by Sanjana, investigate immediately before next sprint

**MANAGEMENT (if it happens):**
- Restore from Supabase point-in-time recovery immediately
- Document exactly what was lost and the root cause
- Add preventive SQL guard (foreign key constraint, trigger, or RLS policy) to prevent recurrence
- If pilot shops are affected, communicate immediately and transparently

---

### R05 — Security Breach (Customer Financial Data)
**Risk**: Customer purchase history, phone numbers, or financial data is accessed by an unauthorized party due to missing Row Level Security (RLS), exposed API keys, or injection vulnerabilities.
**Probability**: Low | **Impact**: Critical (legal, reputational, trust)

**MITIGATION (prevent it):**
- **RLS on every single Supabase table** — no exceptions. Every table has a policy before it's used in production
- **Never expose `service_role` key in frontend** — only `anon` key with RLS protection
- **Environment variables only** — no hardcoded keys in any file ever committed to GitHub
- Input validation on all user inputs — `validators.js` used everywhere
- HTTPS everywhere — enforced by Vercel by default
- Parameterized queries only — Supabase JS client handles this automatically (no raw SQL from frontend)
- Authentication required for all routes — protected routes check auth state before rendering

**MONITORING (detect early):**
- GitHub secret scanning — enabled in repository settings (auto-detects committed keys)
- Supabase Auth logs — review weekly for unusual login attempts
- Test RLS policies before every sprint review: log in as different users, verify data isolation

**MANAGEMENT (if it happens):**
- Immediately rotate all API keys (Supabase, Vercel)
- Identify what data was accessed and by whom (Supabase logs)
- Notify affected users (even if pilot/test users)
- Patch the vulnerability before re-opening the application
- Document incident fully in GitHub Issues

---

## SECTION 4 — RMMM PLANS (Pressman Ch 26.7)
### Remaining Risks — Summary RMMM

### R06 — Sanjana Unavailable
- **Mitigation**: Minimum weekly WhatsApp standup; developer tests basic flows
- **Monitoring**: No test report after sprint = trigger; contact to check in
- **Management**: Developer does basic happy-path testing; Sanjana catches up next sprint; complex testing waits

### R07 — Supabase Free Tier Paused
- **Mitigation**: Open Supabase dashboard weekly to keep project active; set calendar reminder
- **Monitoring**: Check dashboard every Monday; set alert for 80% storage usage
- **Management**: Upgrade to $25/month Pro plan (break-glass budget) or migrate data

### R08 — Vercel Function Timeout (10s limit)
- **Mitigation**: Design reports to use Supabase views and materialized data, not heavy JOIN queries in API functions
- **Monitoring**: Test report generation with 1,000+ records before launch
- **Management**: Move heavy computation to Supabase scheduled functions or background jobs

### R09 — Shop Owner Adoption Failure
- **Mitigation**: Sanjana validates every feature with real shops before building; follow-up interviews after demos
- **Monitoring**: Track pilot user engagement (logins per week, bills generated)
- **Management**: Rapid feature iteration based on feedback; consider white-glove onboarding support

### R10 — Offline Sync Conflicts
- **Mitigation**: Design for "last write wins" conflict resolution for MVP; add optimistic UI with server-side validation
- **Monitoring**: Test 2-device simultaneous billing in Sprint 2 review
- **Management**: Add conflict detection and alert UI before production launch

### R11 — Dashboard Performance
- **Mitigation**: Add Supabase database indexes on `created_at`, `store_id`, `org_id` for all major tables
- **Monitoring**: Performance test with 10,000 seed records before Sprint 7 deploy
- **Management**: Implement pagination, date-range filters, and database views for dashboard aggregations

### R12 — Requirements Change Mid-Sprint
- **Mitigation**: Requirements locked at sprint start; changes queued for next sprint
- **Monitoring**: Any change request during sprint is logged and deferred automatically
- **Management**: Acknowledge the change, log it in Product Backlog, communicate expected sprint

### R13 — WhatsApp API Limits
- **Mitigation**: Use `wa.me` deep links (no API key needed) for MVP receipts — no rate limits
- **Monitoring**: Track receipt send volume; evaluate official WhatsApp Business API at 50+ daily receipts
- **Management**: WhatsApp Business API at ₹0.85/conversation or Twilio fallback for high-volume shops

### R14 — Competitor Feature Parity
- **Mitigation**: Ship unique differentiators: GST accuracy, WhatsApp-first UX, offline capability, Indian product catalog
- **Monitoring**: Monthly competitor review (Vyapar, Khatabook, BillBook changelogs)
- **Management**: Accelerate highest-value features; focus on niche underserved by competitors

### R15 — GST Law Change
- **Mitigation**: Centralize all GST logic in `utils/gst.js` and Supabase `tax_groups` table — one change updates everything
- **Monitoring**: Subscribe to GST Council notifications; review quarterly
- **Management**: Patch `gst.js` and push Supabase tax_groups update within 30 days of any law change

---

## RISK MONITORING SCHEDULE

| Activity | Frequency | Owner |
|---|---|---|
| Review risk register | Every Friday | Developer |
| Update probability/impact scores | Every 2 weeks (sprint end) | Developer |
| Supabase dashboard check | Every Monday | Developer |
| GST calculation spot-check | Every sprint review | Sanjana |
| RLS policy verification | Every sprint review | Developer |
| Competitor monitoring | Monthly | Developer |

---

*RetailOS RISK_REGISTER.md v1.0*
*Pressman SEPA 9th Edition — Ch 26 (Risk Management)*
*Next review: End of Sprint 1 (Day 14)*
