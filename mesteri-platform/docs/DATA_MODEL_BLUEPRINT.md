# Platform Data Model Blueprint (Phase 1)

_Last updated: 2025-09-18_

This blueprint describes the new persistence layer components required for MVP Phase 1. It complements the existing user/job tables and is written to map directly onto Prisma models targeting PostgreSQL.

## High-Level Context
- **Primary goal**: persist project communication, contractual artefacts, and rich media while enabling lifecycle retention controls.
- **Tech stack**: Prisma + PostgreSQL (Cloud SQL), Google Cloud Storage (binary assets), GKE worker automation.
- **Key concerns**: referential integrity, tenant isolation, auditing, retention metadata, and performant read patterns for mobile clients.

## Entity Overview

| Entity | Purpose | Notes |
| --- | --- | --- |
| projects | Existing core job record (extended with guarantee + media counters). | Extend model via migration. |
| contracts | Digital agreements tied to a project and counterparties. | Tracks signatures, versions, guarantee window. |
| etention_policies | Configurable retention schedules. | Drives lifecycle automation + legal overrides. |
| conversations | Logical chat thread per project (client ↔ mester). | Supports group or future multi-role chat. |
| conversation_participants | Junction table for conversation membership. | Allows extra participants (support, managers). |
| messages | Individual chat messages (text/system). | Supports threading metadata, delivery states. |
| ttachments | Metadata for GCS objects (photos, docs). | Shared by messages, contracts, work logs. |
| ttachment_links | Junction table linking attachments to domain entities. | Enables reuse across contexts. |
| project_events | Append-only audit log for status/contract changes. | Supports compliance + dispute resolution. |

## Table Definitions

### etention_policies
- **Columns**
  - id (PK, UUID)
  - code (string, unique) – e.g., STANDARD_GUARANTEE
  - description (text)
  - ctive_days (int) – number of days in hot storage
  - rchive_days (int) – number of days before archive transition
  - hard_delete_after_days (int, nullable) – null = keep indefinitely
  - equires_legal_review (bool, default true)
  - created_at / updated_at
- **Indexes**: code unique
- **Notes**: Seed a baseline policy and allow future overrides per contract/project.

### contracts
- **Columns**
  - id (PK, UUID)
  - project_id (FK → projects.id)
  - ersion (int, default 1)
  - status (enum: DRAFT, AWAITING_SIGNATURE, ACTIVE, EXPIRED, VOID)
  - client_signed_at, mester_signed_at (timestamps)
  - guarantee_expires_at (timestamp)
  - etention_policy_id (FK → retention_policies.id)
  - storage_object_path (string) – location of signed PDF in GCS
  - hash_sha256 (string)
  - created_at / updated_at
- **Indexes**: (project_id, status), (project_id, version)
- **Notes**: Only one ACTIVE contract per project. Guarantee expiry feeds retention jobs.

### conversations
- **Columns**
  - id (PK, UUID)
  - project_id (FK → projects.id, nullable for general support threads)
  - 	ype (enum: PROJECT, SUPPORT, SYSTEM)
  - 	itle (optional)
  - created_by (FK → users.id)
  - etention_policy_id (FK → retention_policies.id)
  - created_at / updated_at
- **Indexes**: project_id, 	ype

### conversation_participants
- **Columns**
  - conversation_id (FK)
  - user_id (FK → users.id)
  - ole (enum: CLIENT, MESTER, SUPPORT, SYSTEM)
  - joined_at
  - last_read_message_id (nullable FK → messages.id)
- **PK**: (conversation_id, user_id)
- **Notes**: Supports unread counts via last_read_message_id.

### messages
- **Columns**
  - id (PK, UUID)
  - conversation_id (FK → conversations.id)
  - sender_id (FK → users.id, nullable for system messages)
  - kind (enum: TEXT, SYSTEM, NOTICE)
  - ody (text, nullable if attachment-only)
  - metadata (JSONB) – e.g., delivery receipts, reactions
  - eply_to_message_id (nullable self FK)
  - sent_at (timestamp, default now)
  - edited_at, deleted_at (nullable)
  - etention_policy_id (FK → retention_policies.id)
- **Indexes**: (conversation_id, sent_at), GIN on metadata

### ttachments
- **Columns**
  - id (PK, UUID)
  - ucket (string)
  - object_path (string)
  - content_type (string)
  - ile_size (int)
  - checksum_sha256 (string)
  - uploaded_by (FK → users.id)
  - etention_policy_id (FK → retention_policies.id)
  - status (enum: PENDING, ACTIVE, QUARANTINED, DELETED)
  - uploaded_at (timestamp)
- **Indexes**: (bucket, object_path) unique, status
- **Notes**: antivirus job updates status.

### ttachment_links
- **Columns**
  - ttachment_id (FK → attachments.id)
  - entity_type (enum: MESSAGE, CONTRACT, PROJECT, MILESTONE, WORK_LOG)
  - entity_id (UUID)
  - ole (string, e.g., BEFORE_PHOTO, AFTER_PHOTO, SIGNED_CONTRACT)
  - created_at
- **PK**: (attachment_id, entity_type, entity_id)
- **Notes**: entity_id is stored as UUID referencing appropriate table; enforced via application logic.

### project_events
- **Columns**
  - id (PK, UUID)
  - project_id (FK → projects.id)
  - ctor_id (FK → users.id, nullable for system)
  - event_type (enum: STATUS_CHANGE, CONTRACT_SIGNED, MESSAGE_FLAGGED, etc.)
  - payload (JSONB)
  - created_at
- **Indexes**: (project_id, created_at)
- **Notes**: Append-only; used for disputes and analytics.

### Project Table Extensions
- Add columns on existing projects table:
  - primary_contract_id (FK → contracts.id, nullable until signed)
  - guarantee_expires_at (timestamp)
  - media_before_count, media_after_count (int, default 0)
  - conversation_id (FK → conversations.id) – for primary chat thread

## Prisma Model Snippets
`prisma
model RetentionPolicy {
  id                     String   @id @default(uuid())
  code                   String   @unique
  description            String?
  activeDays             Int
  archiveDays            Int
  hardDeleteAfterDays    Int?
  requiresLegalReview    Boolean  @default(true)
  createdAt              DateTime @default(now())
  updatedAt              DateTime @updatedAt
  contracts              Contract[]
  conversations          Conversation[]
  messages               Message[]
  attachments            Attachment[]
}

model Contract {
  id                 String            @id @default(uuid())
  project            Project           @relation(fields: [projectId], references: [id])
  projectId          String
  version            Int               @default(1)
  status             ContractStatus    @default(DRAFT)
  clientSignedAt     DateTime?
  mesterSignedAt     DateTime?
  guaranteeExpiresAt DateTime?
  retentionPolicy    RetentionPolicy   @relation(fields: [retentionPolicyId], references: [id])
  retentionPolicyId  String
  storageObjectPath  String
  hashSha256         String
  createdAt          DateTime          @default(now())
  updatedAt          DateTime          @updatedAt
  attachments        AttachmentLink[]
}

model Conversation {
  id                 String              @id @default(uuid())
  project            Project?            @relation(fields: [projectId], references: [id])
  projectId          String?
  type               ConversationType
  title              String?
  createdBy          String
  retentionPolicy    RetentionPolicy     @relation(fields: [retentionPolicyId], references: [id])
  retentionPolicyId  String
  createdAt          DateTime            @default(now())
  updatedAt          DateTime            @updatedAt
  participants       ConversationParticipant[]
  messages           Message[]
}

model Message {
  id                 String            @id @default(uuid())
  conversation       Conversation      @relation(fields: [conversationId], references: [id])
  conversationId     String
  sender             User?             @relation(fields: [senderId], references: [id])
  senderId           String?
  kind               MessageKind        @default(TEXT)
  body               String?
  metadata           Json?
  replyTo            Message?           @relation("Thread", fields: [replyToMessageId], references: [id])
  replyToMessageId   String?
  sentAt             DateTime           @default(now())
  editedAt           DateTime?
  deletedAt          DateTime?
  retentionPolicy    RetentionPolicy    @relation(fields: [retentionPolicyId], references: [id])
  retentionPolicyId  String
  attachments        AttachmentLink[]
}

model Attachment {
  id                 String            @id @default(uuid())
  bucket             String
  objectPath         String
  contentType        String
  fileSize           Int
  checksumSha256     String
  uploadedBy         User              @relation(fields: [uploadedById], references: [id])
  uploadedById       String
  retentionPolicy    RetentionPolicy   @relation(fields: [retentionPolicyId], references: [id])
  retentionPolicyId  String
  status             AttachmentStatus  @default(PENDING)
  uploadedAt         DateTime          @default(now())
  links              AttachmentLink[]
  @@unique([bucket, objectPath])
}

model AttachmentLink {
  attachment       Attachment @relation(fields: [attachmentId], references: [id])
  attachmentId     String
  entityType       AttachmentEntity
  entityId         String
  role             String?
  createdAt        DateTime   @default(now())
  @@id([attachmentId, entityType, entityId])
}
`

### Enum References
`prisma
enum ContractStatus { DRAFT AWAITING_SIGNATURE ACTIVE EXPIRED VOID }
enum ConversationType { PROJECT SUPPORT SYSTEM }
enum MessageKind { TEXT SYSTEM NOTICE }
enum AttachmentStatus { PENDING ACTIVE QUARANTINED DELETED }
enum AttachmentEntity { MESSAGE CONTRACT PROJECT MILESTONE WORK_LOG }
enum ConversationParticipantRole { CLIENT MESTER SUPPORT SYSTEM }
`

## Relationship Highlights
- Project has 1↔N contracts, 1↔1 primary conversation once created.
- Conversation has N participants; participants track read state via last_read_message_id.
- Message may link to multiple attachments via ttachment_links, enabling reuse (e.g., same photo attached to contract + progress log).
- Retention policy foreign keys allow per-entity overrides and make lifecycle jobs deterministic.
- Project_events provide append-only auditing; pair with retention policy or keep indefinitely under legal hold.

## Migration & Seeding Checklist
1. Create enums in Prisma schema.
2. Add new models (RetentionPolicy, Contract, Conversation, etc.).
3. Extend Project model with new fields (primaryContractId, mediaBeforeCount, etc.).
4. Generate migration; review SQL for indices and constraints.
5. Seed etention_policies table with:
   - STANDARD_GUARANTEE (active 180 days, archive 1080 days, no delete)
   - SUPPORT_THREAD (active 90 days, archive 365 days)
6. Seed default conversation creation logic for existing projects (background job or migration script).
7. Update Prisma client usage in services.

## Open Questions / Follow-ups
- Confirm existing users / projects table naming and casing in current Prisma schema.
- Identify whether multi-craftsman conversations are needed for MVP.
- Align project_events retention with legal counsel (possibly indefinite).
- Decide on ttachment_links.entity_id constraints (Postgres composite foreign keys vs. app-layer validation).

---

This document satisfies Phase 1 Deliverable 1 (Schema blueprint & ERD) and should remain the source of truth for subsequent migration work.
