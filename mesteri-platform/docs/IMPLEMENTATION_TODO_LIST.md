# Implementation To-Do List

## 1. Home & Discovery
- Update ServiceDiscoveryScreen to surface category insights (top craftsmen, average pricing, gallery). Requires:
  - Backend method JobsApiService.getServicesOverview(categoryId, limit).
  - ServiceInsight model + controller to prefetch insights.
  - Carousel/stacked-card UI with swipe callbacks (record local like/pass for now).
- Hydrate trust strip metrics from backend (rating, completed jobs) instead of hard-coded copy.
- Ensure inspiration feed button loads newest jobs and fetches recommended tags dynamically.

## 2. Category Services Entry Points
- Maintain route parameter ServiceDiscoveryScreen(category: optional) for deep-linking.
- From new CTAs, pass the category so discovery view opens pre-filtered.

## 3. Projects Feature
- Projects list grouped by status (Open / In Progress / Done).
- Detail view: offers, accepted craftsman, milestones.
- Actions wired to API (acceptOffer, declineOffer, updateJob, cancelJob).
- Add skeleton + error states to existing builders to avoid blank flashes.

## 4. Messaging
- Ensure chat list/detail screens load conversations per project.
- Verify push token registration + unread counts; integrate socket/polling client if missing.

## 5. Authentication & Onboarding
- Double-check token refresh & session persistence flow (landing back on updated home).
- Add referral/profile completion steps if required for MVP.

## 6. Settings
- Create dedicated screens for each settings entry (profile edit, notifications, legal, account deletion, etc.).
- Implement forms that call existing endpoints and add client-side validation. Surface backend errors.

## 7. Notifications & Support
- Wire notifications tab to API (list/detail, read/unread updates).
- Load Support/FAQ from CMS or placeholder markdown until content is ready.

## 8. Localization & Diacritics
- Move user-facing strings into localization (intl) to restore Romanian diacritics.
- Add flutter_localizations to pubspec.yaml, wrap MaterialApp delegates, provide 
o_RO ARB.

## 9. Data Layer Hygiene
- Replace mock data with real endpoints; guard fallbacks behind kDebugMode.
- Translate error copy to RO and provide retry actions.

## 10. Device Testing & UI Polish
- Re-test at 320dp width (no overflows). Adjust AppSpacing as needed.
- Fine-tune hero spacing after layout changes.

## 11. Analytics & Logging (MVP scope)
- Instrument events: job posted, service insight viewed, CTA taps, message sent.
- Forward via analytics service to backend/Firebase.

## 12. Stripe (Post-MVP)
- Stripe Connect integration on hold; document dependencies (keys, onboarding status, payouts).

---

## Data Management Blueprint (Archiving Strategy)

### Principle: Archive, Don't Delete
- Project artifacts (photos, chat history, contracts) remain available after guarantee expiry.
- At guarantee expiry data moves to colder tiers rather than being destroyed, preserving arbitration capability and legal defensibility while controlling cost.

### Storage Architecture: PostgreSQL + Google Cloud Storage
- **Structured data** (users, projects, messages metadata, guarantees) stays in Google Cloud SQL (PostgreSQL) via Prisma.
- **Binary assets** (photos, signed PDFs, KYC docs) live in Google Cloud Storage (GCS); Postgres keeps only references (object path, checksum, retention window).

### Lifecycle & Retention
- Define lifecycle policies per object class:
  1. **Active (0–6 months):** Standard storage for fast access.
  2. **Archive Warm (6 months–3 years):** Transition to Nearline/Coldline automatically.
  3. **Long-term Archive (3+ years):** Move to Archive tier. Retain until legal counsel authorises purge.
- Never delete by default; apply deletion only after written legal confirmation (e.g., >7 years) and audit log entry.

### Secure Upload Flow
- Flutter client requests short-lived signed URLs from backend.
- Direct uploads to GCS; backend registers metadata (hash, mime, project_id, guarantee_expiry, 
retention_policy_id) in Postgres.

### Automation on GKE
- Kubernetes CronJobs handle:
  - Lifecycle audits (verify GCS transitions, update metadata status).
  - Signed URL refresh jobs (if long-lived downloads are needed).
  - End-of-retention review: flag items for legal review before deletion.
- Optional workers for antivirus scanning, thumbnail generation, and checksum validation.

### Messaging & Attachments
- messages table stores text plus metadata; attachments map to GCS objects via attachments table.
- Chats remain queryable after archival by serving cold-tier assets on-demand (accepting slower first access).

### Contracts & Guarantees
- contracts table tracks status, signatures, guarantee expiry.
- Attachments linked to contracts inherit the contract's retention schedule.
- Maintain immutable audit log for status changes and access events.

### Compliance & Security
- Validate retention periods with Romanian legal/GDPR counsel; encode rules in configuration.
- Encrypt buckets with CMEK, enforce signed URLs, and apply IAM least privilege.
- Encrypt sensitive Postgres columns (pgcrypto) and consider row-level security for multi-tenant isolation.
- Schedule encrypted Postgres backups and cross-region bucket replication; retain backups as long as legal requires.

### Monitoring & Governance
- Export access logs to BigQuery for forensic analysis.
- Dashboard alerts when lifecycle transitions fail or when data approaches retention deadlines.

This blueprint merges the previous 6-month active-access plan with long-term archiving so the platform retains arbitration data, meets legal obligations, and keeps cloud spend predictable.
---

## MVP Deployment Readiness Plan

### Phase 0 – Governance & Scope Lock
- Freeze MVP scope for both Client and Mester apps; map features to legal and operational requirements.
- Assign owners for each domain (Mobile, Backend, DevOps, Legal, QA, Support).
- Create shared release checklist in project tracker (Notion/Jira) referencing this document.

### Phase 1 – Platform & Data Foundations
- Finalise Prisma schema additions for projects, contracts, conversations, messages, attachments, retention policies.
- Apply database migrations to staging; enable row-level security and seed reference data.
- Configure Google Cloud resources: dedicated GCS buckets per environment, IAM roles, CMEK encryption, lifecycle policies (Standard -> Nearline -> Archive).
- Deploy storage worker CronJobs on GKE (upload validation, lifecycle audit, retention review).
- Implement signed-URL service and integrate antivirus/thumbnails if required.
#### Phase 1 Kickoff Deliverables
- **Schema blueprint & ERD**: Detail new tables (projects, contracts, conversations, messages, attachments, retention_policies) and relationships.
  - Owner: Backend (Andrei)
  - Due: 04 Oct 2025
- **Prisma migration package**: Implement models, enums, and migration scripts; add seed data for retention policies and contract templates.
  - Owner: Backend (Andrei)
  - Due: 08 Oct 2025
- **Staging database rollout**: Apply migration in staging, enable row-level security, backfill existing data, verify Prisma client regeneration.
  - Owner: DevOps (Ioana)
  - Due: 10 Oct 2025
- **GCS infrastructure provisioning**: Terraform buckets per environment, IAM roles, CMEK keys, lifecycle rules (Standard -> Nearline -> Archive).
  - Owner: DevOps (Ioana)
  - Due: 09 Oct 2025
- **Storage automation manifests**: Author GKE CronJobs for lifecycle audit, signed URL refresh, retention review; prepare Helm chart values.
  - Owner: DevOps (Ioana)
  - Due: 11 Oct 2025
- **Signed URL service API**: Define backend service endpoints (issue, revoke), integrate antivirus/thumbnails hooks, deliver REST + Prisma wiring.
  - Owner: Backend (Andrei)
  - Due: 11 Oct 2025
- **Acceptance checklist**: Draft QA

 checklist covering migration tests, storage smoke tests, and rollback steps; share in project tracker.
  - Owner: QA Lead (Mara)
  - Due: 11 Oct 2025


### Phase 2 – Backend Feature Completion
- Service discovery API (getServicesOverview) with caching and telemetry.
- Projects API: list by status, job detail with offers/milestones, actions (accept/decline/mark-complete/cancel).
- Messaging API: real-time transport (socket or polling), unread counts, attachment handling.
- Contract workflow endpoints: creation, signature capture, guarantee tracking, audit log.
- Notification service wired to FCM/APNs and fallback email; ensure preference toggles respected.
- Authentication hardening: refresh tokens, device trust, rate limiting, logging.

### Phase 3 – Client App (Customers)
- Integrate new service discovery data + carousel UX; ensure quick actions deep-link with context.
- Projects module: status sections, detail views, action buttons, optimistic updates + error handling.
- Messaging overhaul: conversation list with badges, threaded view with attachments, typing indicators if available.
- Job posting flow: photo capture/upload via signed URLs, contract preview acknowledgment.
- Settings: profile edit, notification toggles, legal docs, account management, GDPR export request.
- Localization: finalize RO strings (intl), ensure fallback EN ready if needed.
- Instrument analytics events (job posted, insight viewed, message sent, contract signed).
- Accessibility & performance pass (contrast, font scaling, 60fps animations).

### Phase 4 – Mester App (Craftsmen)
- Dashboard: assigned jobs per status, revenue summary, action shortcuts.
- Job detail: customer brief, photos, documents, contract acceptance, milestone checklist.
- Proposal flow: bid creation/edit, availability sharing, messaging quick access.
- Messaging parity with client app + push notifications.
- Work log & photo updates (before/after), guarantee reminder prompts.
- Profile & compliance: KYC upload, certifications, service areas, availability schedule.
- Settings: payout method placeholder (Stripe later), notification preferences, legal docs.
- Localization + analytics parity with client app.

### Phase 5 – Quality, Security, Compliance
- End-to-end test matrix covering both apps on target OS versions and device sizes.
- Load/soak tests for key APIs (service discovery, messaging, file upload) and storage throughput.
- Security review: OWASP mobile checks, backend penetration test, IAM audit, secrets rotation.
- Legal sign-off on contract templates, retention policies, privacy terms.
- Incident response runbook drafted; on-call rota established.

### Phase 6 – Release Engineering
- Configure CI/CD (Flutter build pipelines, backend deploys, Terraform/GitOps for infra).
- Publish beta builds via Firebase App Distribution/TestFlight for internal testing.
- Play Store & App Store listings prepared (assets, descriptions, privacy labels).
- Final data migration rehearsal + production readiness review (PRR) checklist sign-off.
- Schedule launch window, freeze non-critical changes, communicate rollback plan.

### Phase 7 – Post-Launch Monitoring & Support
- Live dashboards for KPIs (job submissions, active chats, crash-free sessions).
- Support playbooks for customer + mester onboarding, dispute escalation.
- Feedback loop: gather analytics + support tickets -> fortnightly triage -> backlog updates.
- Plan Stripe integration & premium features as post-MVP roadmap once stability KPIs met.

