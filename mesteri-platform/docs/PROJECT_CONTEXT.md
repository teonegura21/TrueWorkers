# Project Context - Mesteri Platform

## Objective & Personas
- **Objective:** Deliver the Mesteri services marketplace MVP that proves the Trust Engine (verified pros, escrow-ready architecture, authentic reviews) while seeding the Inspiration Engine content loop.
- **Primary Personas:** Romanian homeowners seeking trustworthy craftsmen; **Secondary Personas:** Verified professionals managing gigs, reputation, and payouts.

## Tech Stack (Agreed)
- **Client Apps:** Flutter (Dart) targeting iOS & Android; Dio for networking; intl/flutter_localizations for i18n; Firebase Crashlytics & Analytics (planned);
- **Backend:** NestJS (TypeScript) REST APIs, Prisma ORM, PostgreSQL (Cloud SQL), optional Redis cache, WebSocket/poll transports for messaging.
- **Infrastructure:** Docker images deployed via Kubernetes (GKE) on Google Cloud; Terraform-managed infrastructure; Google Cloud Storage for media; Stripe Connect for KYC/KYB & escrow; optional self-hosted LLM services.
- **Security Foundations:** OAuth2-style auth with refresh tokens, role-based access, signed URL media uploads, CMEK-encrypted storage, audit logging.

## Key Architectural Decisions
- Client surfaces remain optimistic but defer to backend truth, with graceful loading/error handling baked in.
- Media uploads bypass backend through signed URLs; backend maintains metadata & retention policies.
- Localization and accessibility (WCAG 2.1 AA) enforced across Flutter surfaces from inception.
- Analytics and logging centralized to support KPI dashboards post-launch.
- Feature flags/environment-driven configs orchestrate staging vs production behaviour.

## High-Level Roadmap (Confirmed)
1. **Phase 1 – Transactional Foundation (MVP)**
   - Wire real service discovery data, deliver baseline projects/messaging/auth flows, stand up storage/retention automation, and document compliance posture.
   - **Progress:** Service discovery data is now live. All client-side API services are configured to use live data.
2. **Phase 2 – Client App Experience**
   - Deepen Flutter customer app with projects UX, messaging polish, localization completeness, analytics instrumentation, and accessibility/performance tuning.
3. **Phase 3 – Craftsmen App & Operational Maturity**
   - Ship craftsmen-facing workflows, prepare payouts/Stripe readiness, expand QA/security/compliance coverage, finalize release engineering, and establish post-launch monitoring.

## Live Data Integration Status
- **Status:** Completed. All client-side API services (`MesteriService`, `ProjectsApiService`, `ConversationsApiService`, `JobsApiService`, `StorageApiService`) are now configured to use live data from the backend APIs. The `AppConfig.useMockData` flag is set to `false` and `MesteriService` correctly respects this setting.