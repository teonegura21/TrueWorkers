# Live Data Adoption Plan

## Client App
- Notifications: need /notifications list/detail, mark-read endpoints; seed sample notifications.
- Verification / trust: require /trust/verification/:id summary API, docs metadata storage; seed craftsman verification data.
- ComprehensiveService (jobs/projects/messaging/payments/offers/profile): ensure REST coverage for jobs feed, project list/detail, milestones, messages, reviews, payments, offers, notifications, verification docs, profile CRUD.
- Chat screen: relies on job mocks; needs /projects/:id/conversations + message send/list endpoints.
- Milestone service: require /projects/:id/milestones with update/approve actions.

## Mester App
- Jobs discovery/detail: provide /craftsmen/jobs search, /jobs/:id detail.
- Offers: endpoints to list/filter craftsman offers, summary stats.
- Earnings: payouts/transactions history endpoints.
- Profile: fetch/update craftsman profile, portfolio, certificates.

## Shared Data Requirements
- Seed database with representative jobs, projects, milestones, offers, payouts, notifications, verification docs.
- Ensure signed media references exist in GCS or use placeholder URLs from staging bucket.

## Next Steps
1. Design schema additions & seed scripts for missing data.
2. Implement/verify NestJS controllers/services for each feature.
3. Coordinate with frontend to remove mock fallbacks once APIs are live.

# Live Data Schema & Seed Outline

## Projects & Milestones
- Tables already exist (jobs, projects, projectMilestones, offers, messages). Verify fields needed by the apps (e.g., project.status, milestone progress, attachment references).
- Seed staging with representative projects:
  - Job with offers (pending, accepted, declined).
  - Active project with milestones (pending/in-progress/completed), messages, attachments.
  - Completed project with payouts recorded.

## Messaging
- Ensure conversations, conversationParticipants, messages, ttachments schemas cover all extra fields (sender role, read receipts, attachments metadata).
- Seed conversation per sample project with 10+ messages including attachments.

## Payments / Earnings
- Confirm payouts table (payouts or equivalent) exists with amount, currency, status, timestamps.
- Seed transaction history for both client and mester (completed payouts, pending payouts, failed payouts).

## Notifications
- Define 
otifications table (id, userId, title, body, category, readAt, createdAt).
- Seed sample notifications (project updates, verification reminders, payout alerts).

## Trust Verification
- Create/verify tables for verification requests (erifications, erificationDocuments, statuses).
- Seed at least one completed verification plus one pending.

## Profile & Portfolio
- Ensure craftsmen profile table contains badges, specialties, insurance, portfolio items with media URLs.
- Seed sample portfolio entries (images stored in staging GCS bucket).

## Seed Strategy
- Use Prisma migrate/seed scripts:
  1. Add migration if schema gaps exist.
  2. Seed script creating users, jobs, projects, offers, chats, payouts, notifications, verification docs.
  3. Link assets to staging bucket paths (or stub URLs).

## Next Actions
1. Diff current Prisma schema vs. feature needs; draft migration plan.
2. Prepare seed script outline covering the entities above.
3. Coordinate with backend to schedule migration + seed run in staging.

# Backend Endpoint/Service Outline

## Client App Features
- **Notifications**
  - GET /notifications (query params: status/filter), GET /notifications/:id, POST /notifications/:id/read.
  - Nest modules: NotificationsModule with service + repository, DTOs for list and detail.
  - Auth: JWT (user scope).

- **Trust Verification**
  - GET /trust/verification list, GET /trust/verification/:id, POST /trust/verification/:id/documents, POST /trust/verification/:id/action (approve/reject).
  - Requires file upload handling (signed URLs) + audit logs.

- **Projects & Milestones**
  - GET /projects (filters by status), GET /projects/:id, PATCH /projects/:id/status.
  - GET /projects/:id/milestones, PATCH /projects/:id/milestones/:milestoneId (update progress/approve).
  - GET /projects/:id/messages, POST /projects/:id/messages.
  - Ensure websockets or polling for new message notifications.

- **Jobs Feed**
  - GET /jobs/discovery (filters, pagination), GET /jobs/:id detail, POST /jobs (creation), PATCH /jobs/:id, DELETE /jobs/:id (optional).

- **Offers**
  - For clients: GET /projects/:id/offers, POST /projects/:id/offers/:offerId/accept, POST /projects/:id/offers/:offerId/reject.

- **Payments**
  - GET /payments/history, GET /payments/payouts, POST /payments/intent (placeholder for Stripe integration), GET /wallet/summary.

- **Profile**
  - GET /profile, PATCH /profile, GET /profile/portfolio, POST /profile/portfolio, DELETE /profile/portfolio/:id.

## Mester App Features
- **Jobs Discovery**
  - GET /craftsmen/jobs with filters (location, budget, specialties).
  - GET /craftsmen/jobs/:id for detail.
  - POST /craftsmen/jobs/:id/offer to submit/modify offers.

- **Offers Management**
  - GET /craftsmen/offers (filter by status), PATCH /craftsmen/offers/:id (update terms), DELETE /craftsmen/offers/:id.

- **Earnings & Payouts**
  - GET /craftsmen/payouts, GET /craftsmen/payouts/:id, POST /craftsmen/payouts/:id/acknowledge.

- **Messaging Parity**
  - Shared conversations endpoints with role-based filters.

- **Profile & Verification**
  - GET /craftsmen/profile, PATCH /craftsmen/profile, PATCH /craftsmen/availability, GET /craftsmen/portfolio, POST /craftsmen/portfolio.

## Shared Services
- Authentication (JWT refresh, role scopes).
- Media uploads via signed URLs (POST /storage/upload-url).
- Analytics/telemetry events ingestion if required.

## Next Steps
1. Break down controllers/services into implementation tickets with owner & due dates.
2. Align DTO contracts with frontend models (ServiceInsight, ProjectDetail, etc.).
3. Establish staging endpoints + docs in API reference for QA.

# Frontend Mock Removal Plan

## Coordination Points
- Schedule joint backend/frontend review once each API endpoint is ready; provide Postman collection or Swagger docs.
- Flip AppConfig.useMockData to alse in both apps as soon as staging data/APIs are stable.
- Remove _mock* helper functions and mock imports feature-by-feature, testing against staging after each removal.
- Guard any temporary fallbacks behind ssert(kDebugMode) blocks only.

## Action Items
1. Backend team to expose endpoints per LIVE_DATA_PLAN and confirm staging data seeded.
2. Frontend team to create cleanup tasks per module (jobs, projects, messaging, etc.) removing mocks and wiring live services.
3. QA to run regression against staging with real data before each milestone sign-off.

