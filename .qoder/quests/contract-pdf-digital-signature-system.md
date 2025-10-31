# Contract PDF Generation and Digital Signature System

## Overview

This design defines a comprehensive contract management system that enables digital contract generation, signing, and lifecycle management for the Mesteri platform. The system integrates PDF generation with digital signature capabilities to formalize agreements between clients and craftsmen after offer acceptance.

## Business Context

When a client accepts a craftsman's offer, a formal contract is required before project work begins. This contract serves as:
- Legal agreement documenting project scope, price, and timeline
- Protection mechanism for both parties
- Prerequisite for project activation and payment processing
- Auditable record with retention policy compliance

The contract becomes legally binding once both parties provide digital signatures.

## System Objectives

- Generate professional PDF contracts from structured project data
- Capture and store digital signatures with legal validity
- Track contract lifecycle states and signature status
- Ensure secure storage with retention policy compliance
- Provide seamless user experience for contract review and signing
- Integrate contract workflow into existing offer acceptance flow

## Architectural Strategy

### Backend Architecture

The backend follows NestJS modular architecture with clear separation of concerns:

**Contracts Module** - New module dedicated to contract operations
- ContractsService: Business logic for contract generation, signing, and retrieval
- ContractsController: REST API endpoints for contract operations
- Integration with existing PrismaService, StorageService, NotificationsService

**PDF Generation Strategy**
- Use Puppeteer for server-side HTML-to-PDF conversion
- Template-based approach with parameterized HTML templates
- Professional contract layout with Romanian legal compliance
- Generate contracts on-demand when triggered by offer acceptance

**Storage Strategy**
- Store PDFs in Google Cloud Storage under dedicated contracts directory
- Leverage existing StorageService infrastructure
- Apply STANDARD_GUARANTEE retention policy for long-term archival
- Generate secure signed URLs for client access

### Flutter Architecture

Both app_client and app_mester follow identical contract UI patterns with role-specific views:

**Service Layer**
- ContractsService: API communication with backend endpoints
- Handles HTTP requests, response parsing, and error handling

**UI Layer**
- ContractReviewScreen: Display contract details with PDF preview
- DigitalSignatureScreen: Capture signature using signature pad
- ContractStatusScreen: List all contracts with status indicators

**State Management**
- Local state management for signature capture
- Refresh mechanisms for contract status updates

## Data Model Extensions

### Database Schema Changes

The existing Contract model in Prisma schema requires the following extensions:

**Contract Model Additions**

| Field | Type | Purpose | Constraints |
|-------|------|---------|-------------|
| pdfUrl | String | URL to generated PDF in GCS | Optional, populated after generation |
| clientSignature | String | Base64-encoded signature image | Optional until client signs |
| clientSignatureMetadata | Json | Signature capture metadata | Stores timestamp, device info |
| craftsmanSignature | String | Base64-encoded signature image | Optional until craftsman signs |
| craftsmanSignatureMetadata | Json | Signature capture metadata | Stores timestamp, device info |

**Notes:**
- clientSignedAt and mesterSignedAt already exist in schema
- storageObjectPath will store the GCS path to PDF
- hashSha256 will store PDF file integrity hash
- retentionPolicyId links to STANDARD_GUARANTEE policy

### Contract Status Transitions

| Status | Description | Conditions |
|--------|-------------|------------|
| DRAFT | Contract created, PDF not generated | Initial state after offer acceptance |
| AWAITING_SIGNATURE | PDF generated, pending signatures | PDF exists, neither party signed |
| ACTIVE | Both parties signed | clientSignedAt AND mesterSignedAt not null |
| EXPIRED | Signature deadline passed | Created > 7 days ago, not signed |
| VOID | Contract cancelled | Manual cancellation by admin |

## API Design

### Backend Endpoints

**Generate Contract PDF**

```
POST /contracts/:contractId/generate-pdf
```

Purpose: Generate PDF from contract and project data, upload to storage

Request Parameters:
- contractId (path parameter): UUID of contract record

Response:
```
{
  "contractId": "uuid",
  "pdfUrl": "https://storage.googleapis.com/...",
  "expiresAt": "ISO-8601 timestamp",
  "status": "AWAITING_SIGNATURE"
}
```

Business Logic:
- Retrieve contract with related project, client, craftsman data
- Validate contract exists and is in DRAFT status
- Render HTML template with contract data
- Convert HTML to PDF using Puppeteer
- Upload PDF to GCS bucket under /contracts/{projectId}/ path
- Calculate SHA-256 hash of PDF content
- Update contract record with pdfUrl, storageObjectPath, hashSha256
- Transition status to AWAITING_SIGNATURE
- Send notifications to both client and craftsman

**Sign Contract**

```
POST /contracts/:contractId/sign
```

Purpose: Record digital signature from client or craftsman

Request Body:
```
{
  "signatureData": "base64-encoded PNG image",
  "signatureMetadata": {
    "capturedAt": "ISO-8601 timestamp",
    "deviceType": "mobile|tablet|desktop",
    "platform": "ios|android|web",
    "appVersion": "1.0.0"
  }
}
```

Authentication: Requires valid Firebase JWT with userId

Response:
```
{
  "contractId": "uuid",
  "signedBy": "client|craftsman",
  "signedAt": "ISO-8601 timestamp",
  "status": "AWAITING_SIGNATURE|ACTIVE",
  "allPartiesSigned": false|true
}
```

Business Logic:
- Authenticate user via Firebase JWT
- Retrieve contract and verify user is client or craftsman
- Validate contract status is AWAITING_SIGNATURE
- Determine signing party (client vs craftsman) from userId
- Store signature data in appropriate field (clientSignature or craftsmanSignature)
- Record signature timestamp (clientSignedAt or mesterSignedAt)
- Store metadata in clientSignatureMetadata or craftsmanSignatureMetadata
- Check if both parties have signed
- If both signed: transition status to ACTIVE, send notifications, update project status to ACTIVE
- Record CONTRACT_SIGNED analytics event
- Return updated contract status

**Get Contract Details**

```
GET /contracts/:contractId
```

Purpose: Retrieve contract with all signatures and PDF URL

Authentication: Requires valid Firebase JWT

Response:
```
{
  "id": "uuid",
  "projectId": "uuid",
  "status": "DRAFT|AWAITING_SIGNATURE|ACTIVE|EXPIRED|VOID",
  "pdfUrl": "signed GCS URL",
  "pdfExpiresAt": "ISO-8601 timestamp",
  "version": 1,
  "clientSignature": {
    "imageData": "base64 PNG or null",
    "signedAt": "ISO-8601 timestamp or null",
    "metadata": {...}
  },
  "craftsmanSignature": {
    "imageData": "base64 PNG or null",
    "signedAt": "ISO-8601 timestamp or null",
    "metadata": {...}
  },
  "project": {
    "title": "string",
    "agreedPrice": 0.00,
    "startDate": "ISO-8601 timestamp",
    "deadline": "ISO-8601 timestamp"
  },
  "client": {
    "id": "uuid",
    "fullName": "string"
  },
  "craftsman": {
    "id": "uuid",
    "fullName": "string"
  },
  "createdAt": "ISO-8601 timestamp",
  "guaranteeExpiresAt": "ISO-8601 timestamp"
}
```

Business Logic:
- Authenticate user via Firebase JWT
- Retrieve contract with project, client, craftsman relations
- Verify user has access (is client or craftsman on project)
- Generate fresh signed URL for PDF access (15-minute TTL)
- Return comprehensive contract data
- Mask sensitive data if not authorized

**List User Contracts**

```
GET /contracts?userId=:userId&status=:status
```

Purpose: List all contracts for a user with optional status filter

Query Parameters:
- userId (optional): Filter by user (client or craftsman)
- status (optional): Filter by contract status

Response:
```
{
  "contracts": [
    {
      "id": "uuid",
      "projectTitle": "string",
      "clientName": "string",
      "craftsmanName": "string",
      "agreedPrice": 0.00,
      "status": "ACTIVE",
      "clientSigned": true,
      "craftsmanSigned": true,
      "createdAt": "ISO-8601 timestamp"
    }
  ],
  "total": 0
}
```

### Backend Service Methods

**ContractsService Methods**

| Method | Purpose | Returns |
|--------|---------|---------|
| generateContractPDF(contractId) | Create PDF and upload to storage | Contract with pdfUrl |
| signContract(contractId, userId, signatureData) | Record signature for user | Updated contract |
| getContract(contractId, userId) | Retrieve contract with access check | Contract details |
| listContracts(userId?, status?) | List contracts with filters | Array of contracts |
| createContractForProject(projectId) | Auto-create contract after offer acceptance | New contract record |
| checkSignatureStatus(contractId) | Determine if all parties signed | Boolean status |
| generateSignedPdfUrl(contractId) | Generate temporary GCS signed URL | URL string |

## PDF Template Design

### Contract Template Structure

The HTML template will include the following sections in professional layout:

**Header Section**
- Platform branding (Mesteri logo)
- Contract title: "Contract de Prestari Servicii"
- Contract number and generation date
- QR code linking to digital contract verification

**Parties Section**
- Client information: Full name, contact details, address
- Craftsman information: Full name, contact details, professional details
- Legal representative fields if business entity

**Project Details Section**
- Project title and description
- Service category
- Project location with full address
- Work start date and completion deadline

**Financial Terms Section**
- Agreed price (agreedPrice) displayed prominently
- Payment schedule linked to milestones
- Payment method and terms
- Currency: RON

**Timeline Section**
- Project start date
- Expected completion date
- Milestone schedule if applicable

**Terms and Conditions Section**
- Service scope and deliverables
- Quality standards and acceptance criteria
- Warranty and guarantee period
- Cancellation and dispute resolution procedures
- Data protection and privacy clauses
- Liability limitations
- Force majeure provisions
- Governing law: Romanian jurisdiction

**Signature Section**
- Client signature placeholder with name and date
- Craftsman signature placeholder with name and date
- Digital signature indicators
- Signature timestamp fields

**Footer Section**
- Contract version number
- Document hash for integrity verification
- Retention policy reference
- Legal disclaimer

### Template Rendering Process

The system will follow this rendering workflow:

1. Retrieve contract data with all relations from database
2. Format currency values to Romanian locale (1.234,56 RON)
3. Format dates to Romanian format (DD.MM.YYYY)
4. Translate all field labels to Romanian
5. Inject data into HTML template placeholders
6. Apply professional CSS styling (A4 page format, margins, fonts)
7. Render HTML using Puppeteer in headless Chrome
8. Configure PDF options: A4 size, margins, print background graphics
9. Generate PDF buffer
10. Calculate SHA-256 hash of PDF content
11. Upload to GCS with appropriate content-type and cache headers
12. Return PDF URL and metadata

### Styling Specifications

- Page format: A4 (210mm x 297mm)
- Margins: 20mm all sides
- Font: Professional sans-serif (Roboto or Arial)
- Headings: Bold, size 16-18pt
- Body text: Regular, size 11pt
- Color scheme: Professional blue/gray palette
- Section dividers: Subtle horizontal rules
- Signature boxes: Clear bordered areas

## Digital Signature Implementation

### Signature Capture Mechanics

**Signature Pad Configuration**
- Canvas-based drawing surface
- Touch and mouse input support
- Configurable pen color: Dark blue (#003366)
- Configurable pen width: 2-3 pixels
- Smooth stroke rendering with anti-aliasing
- Real-time preview as user draws

**Signature Validation**
- Minimum stroke count: 3 strokes (prevent accidental taps)
- Minimum bounding box size: 100x50 pixels
- No completely blank signatures accepted
- Visual feedback for invalid signatures

**Signature Export**
- Export format: PNG with transparent background
- Resolution: 400x200 pixels minimum
- Compression: Moderate quality (60-80%)
- Base64 encoding for API transmission
- Include metadata: timestamp, device info, dimensions

### Signature Display

**On Signed Contracts**
- Display signature image at actual size
- Show signer name below signature
- Display signature timestamp
- Visual indicator: Green checkmark icon
- Format: "Signed by [Name] on [DD.MM.YYYY HH:MM]"

**On Unsigned Contracts**
- Show empty signature placeholder
- Call-to-action button: "Sign Contract"
- Visual indicator: Gray placeholder icon
- Descriptive text: "Awaiting signature"

## Flutter Application Implementation

### Screen Specifications

**ContractReviewScreen**

Purpose: Allow users to review contract details before signing

Layout Structure:
- App bar with title "Contract Review"
- Scrollable content area with sections:
  - Contract status badge (Draft, Pending Signature, Active)
  - Project summary card: title, category, location
  - Parties card: client and craftsman details with avatars
  - Financial details card: agreed price, payment terms
  - Timeline card: start date, deadline, duration
  - PDF preview section with "View Full PDF" button
  - Terms and conditions expandable section
  - Signature status indicators for both parties
  - Action buttons based on status

Action Buttons:
- If user hasn't signed: "Sign Contract" (primary button)
- If PDF not available: "Request PDF" (regenerate if needed)
- If both signed: "Download PDF" (read-only)
- Back button to return to previous screen

Interaction Flow:
1. User navigates from offer acceptance or contracts list
2. Load contract data from API
3. Display all contract information
4. Check if current user has signed
5. If not signed: enable "Sign Contract" button → navigate to DigitalSignatureScreen
6. If signed: show signature and timestamp
7. If both parties signed: show success state and download option

**DigitalSignatureScreen**

Purpose: Capture digital signature from user

Layout Structure:
- App bar with title "Digital Signature"
- Instructional text: "Please sign below"
- Signature pad canvas (white background, occupies central area)
- Control buttons row:
  - "Clear" button (icon button, left side)
  - "Save Signature" button (primary, right side)
- Preview section below canvas showing captured signature
- Terms acceptance checkbox: "I agree to the terms of this contract"
- Confirmation dialog before finalizing

Signature Pad Features:
- Full-width canvas with fixed aspect ratio (2:1)
- Landscape orientation recommended prompt
- Visual border around drawing area
- Placeholder text: "Sign here" (disappears on first stroke)
- Real-time stroke rendering

Validation Rules:
- Canvas must not be empty
- Minimum stroke count: 3 strokes
- Terms checkbox must be checked
- Confirmation dialog: "Are you sure you want to submit this signature?"

Interaction Flow:
1. User taps "Sign Contract" from ContractReviewScreen
2. Navigate to DigitalSignatureScreen with contractId
3. User draws signature on canvas
4. User can tap "Clear" to restart
5. User checks terms acceptance checkbox
6. User taps "Save Signature"
7. Show confirmation dialog
8. On confirm: convert canvas to PNG, encode base64
9. Collect signature metadata (timestamp, device info)
10. Call API to submit signature
11. Show loading state during submission
12. On success: show success message, navigate back
13. On error: show error message, allow retry

**ContractStatusScreen**

Purpose: Display list of all user contracts with status tracking

Layout Structure:
- App bar with title "My Contracts"
- Tab bar: "All", "Pending", "Active", "Completed"
- List view with contract cards
- Empty state message if no contracts
- Pull-to-refresh functionality
- Floating action button (craftsmen only): "Create Manual Contract"

Contract Card Design:
- Project title (bold, primary text)
- Client and craftsman names with role labels
- Agreed price (highlighted, large font)
- Status badge with color coding:
  - Draft: Gray
  - Awaiting Signature: Orange
  - Active: Green
  - Expired: Red
  - Void: Dark gray
- Signature indicators: Checkmarks for signed parties
- Creation date (subtle, small font)
- Tap action: Navigate to ContractReviewScreen

Filtering Logic:
- All tab: Show all contracts for user (as client or craftsman)
- Pending tab: Status = AWAITING_SIGNATURE or DRAFT
- Active tab: Status = ACTIVE
- Completed tab: Related project status = COMPLETED

Interaction Flow:
1. User navigates to "Contracts" from main navigation
2. Load contracts from API filtered by userId
3. Display contracts in selected tab
4. User can switch tabs to filter by status
5. User can pull down to refresh list
6. User taps contract card to view details
7. Navigate to ContractReviewScreen with selected contractId

### Flutter Service Layer

**ContractsService API Methods**

```
class ContractsService {
  Future<Contract> getContract(String contractId)
  Future<List<Contract>> listContracts({String? status})
  Future<Contract> signContract(String contractId, SignatureData signature)
  Future<String> generatePdfUrl(String contractId)
  Future<void> downloadPdf(String contractId, String savePath)
}
```

**Data Models**

Contract Model:
- id: String
- projectId: String
- status: ContractStatus enum
- pdfUrl: String?
- version: int
- clientSignature: SignatureData?
- craftsmanSignature: SignatureData?
- project: ProjectSummary
- client: UserSummary
- craftsman: UserSummary
- createdAt: DateTime
- guaranteeExpiresAt: DateTime?

SignatureData Model:
- imageData: String (base64)
- signedAt: DateTime
- metadata: Map<String, dynamic>

### Error Handling

**Backend Error Responses**

| Error Code | HTTP Status | Scenario | User Message |
|------------|-------------|----------|--------------|
| CONTRACT_NOT_FOUND | 404 | Invalid contractId | "Contract not found" |
| UNAUTHORIZED_ACCESS | 403 | User not party to contract | "You don't have access to this contract" |
| ALREADY_SIGNED | 400 | User already signed | "You have already signed this contract" |
| INVALID_STATUS | 400 | Wrong contract status for operation | "Contract cannot be signed in current status" |
| PDF_GENERATION_FAILED | 500 | Puppeteer error | "Failed to generate PDF" |
| STORAGE_UPLOAD_FAILED | 500 | GCS upload error | "Failed to save contract PDF" |
| INVALID_SIGNATURE | 400 | Empty or invalid signature data | "Please provide a valid signature" |

**Flutter Error Handling**

UI Error Display Strategy:
- Network errors: Show snackbar with retry option
- Validation errors: Show inline error messages
- Server errors: Show dialog with error details
- Loading states: Show progress indicators
- Timeout handling: 30-second timeout with retry prompt

Retry Mechanisms:
- Automatic retry for transient network failures (max 3 attempts)
- Manual retry button for server errors
- Exponential backoff for retry delays

Offline Behavior:
- Queue signature submission if offline (local storage)
- Retry when connectivity restored
- Show offline indicator in UI

## Integration with Offer Acceptance Flow

### Automated Contract Creation Workflow

**Trigger Event:** Client accepts an offer

**Workflow Steps:**

1. Client taps "Accept Offer" on offer card
2. Offer acceptance API called
3. Backend creates Project record (existing flow)
4. Backend automatically creates Contract record:
   - Link to projectId
   - Set status to DRAFT
   - Apply STANDARD_GUARANTEE retention policy
   - Set version to 1
5. Backend triggers PDF generation asynchronously
6. PDF generation process executes:
   - Render contract template with project data
   - Upload PDF to GCS
   - Update contract record with pdfUrl and hash
   - Transition status to AWAITING_SIGNATURE
7. Backend sends notifications to both parties:
   - Client notification: "Your contract is ready to sign"
   - Craftsman notification: "New contract requires your signature"
8. Flutter apps receive notifications
9. Users tap notification to navigate to ContractReviewScreen
10. Each party reviews and signs contract
11. After both signatures collected:
    - Contract status → ACTIVE
    - Project status → ACTIVE (can begin work)
    - Both parties receive "Contract fully executed" notification
    - Project conversation unlocked for messaging

### Notification Strategy

**Contract Ready Notification**

Type: Push notification + In-app notification

Title: "Contract Ready for Signature"

Body: "Your contract for [Project Title] is ready. Review and sign to start the project."

Action: Deep link to ContractReviewScreen with contractId

Priority: High

**Signature Request Notification**

Type: Push notification + In-app notification

Title: "Signature Required"

Body: "[Other Party Name] has signed the contract. Your signature is needed."

Action: Deep link to ContractReviewScreen with contractId

Priority: High

**Contract Executed Notification**

Type: Push notification + In-app notification

Title: "Contract Signed"

Body: "The contract for [Project Title] is now active. You can start the project."

Action: Deep link to ProjectDetailsScreen with projectId

Priority: Medium

## Validation and Business Rules

### Contract Creation Validation

- Project must exist and be in valid state
- Project must not already have an active contract
- Client and craftsman must both have verified accounts
- Agreed price must be greater than zero
- All required project fields must be populated

### Signature Submission Validation

- User must be authenticated via Firebase
- User must be either client or craftsman on the contract
- Contract must be in AWAITING_SIGNATURE status
- User must not have already signed
- Signature data must be valid base64 PNG
- Signature metadata must include required fields

### PDF Generation Validation

- Contract must be in DRAFT status
- All related data (project, client, craftsman) must exist
- Retention policy must be available
- Template rendering must not exceed timeout (30 seconds)

### Access Control Rules

- Users can only view contracts where they are client or craftsman
- Users can only sign their own portion of contract
- Admins can view all contracts but not sign
- PDF URLs expire after 15 minutes for security

## Security Considerations

### Data Protection

- Signature images stored as base64 in database (encrypted at rest)
- PDF files stored in GCS with restricted access
- Signed URLs with short expiration (15 minutes)
- No public access to contract bucket
- HTTPS-only communication for all API calls

### Authentication and Authorization

- Firebase JWT authentication required for all contract endpoints
- User identity verified via Firebase UID
- Role-based access: only contract parties can view/sign
- Admin access requires ADMIN role in JWT claims

### Signature Integrity

- PDF hash (SHA-256) stored for tamper detection
- Signature timestamps recorded at server (not client-controlled)
- Signature metadata captured for audit trail
- Once signed, signatures are immutable (cannot be changed)

### Audit Trail

Record in contract history:
- PDF generation timestamp
- Each signature submission timestamp
- User who performed each action
- Device and platform information
- IP address (optional, for fraud detection)

## Non-Functional Requirements

### Performance Targets

- PDF generation: Complete within 10 seconds
- Signature submission: Process within 2 seconds
- Contract retrieval: Return within 1 second
- List contracts: Return within 2 seconds for up to 100 contracts
- Signed URL generation: Complete within 500ms

### Scalability Considerations

- PDF generation offloaded to background job queue if load is high
- GCS handles storage scaling automatically
- Database indexes on contract.projectId and contract.status
- Pagination for contract listing (20 contracts per page)

### Availability

- Contract viewing: 99.5% uptime
- Signature submission: 99% uptime
- Graceful degradation: Allow viewing even if PDF generation temporarily unavailable

### Data Retention

- Contracts follow STANDARD_GUARANTEE retention policy:
  - Active retention: 180 days from contract activation
  - Archive retention: 1080 days (3 years total)
  - Hard delete after archive period
- Signature data retained same duration as contract
- PDF files retained in GCS matching database retention

## Testing Considerations

### Backend Testing Scenarios

**PDF Generation Tests**
- Verify PDF generates successfully with valid data
- Verify proper Romanian text rendering and formatting
- Verify PDF hash calculation accuracy
- Verify GCS upload and URL generation
- Test error handling for Puppeteer failures
- Test timeout handling for long-running generation

**Signature Submission Tests**
- Verify signature storage for client
- Verify signature storage for craftsman
- Verify status transition when both parties sign
- Verify duplicate signature rejection
- Verify unauthorized signature rejection
- Verify notification sending on signature events

**Access Control Tests**
- Verify only contract parties can access contract
- Verify admins can view but not sign
- Verify users cannot sign contracts they're not party to
- Verify signed URL expiration enforcement

### Flutter Testing Scenarios

**Signature Capture Tests**
- Verify signature pad renders correctly
- Verify clear button resets canvas
- Verify save button validation
- Verify base64 encoding of signature
- Verify metadata collection
- Test on different screen sizes and orientations

**Contract Display Tests**
- Verify contract data displays correctly
- Verify status badges show correct colors
- Verify signature indicators update properly
- Verify PDF preview navigation
- Test empty states and loading states

**Error Handling Tests**
- Verify network error recovery
- Verify validation error display
- Verify retry mechanisms
- Test offline queue behavior

### Integration Testing

- End-to-end flow: Offer acceptance → Contract creation → PDF generation → Dual signatures → Project activation
- Test notification delivery at each stage
- Verify data consistency across services
- Test concurrent signature submissions

## Dependencies and Prerequisites

### Backend Dependencies

**New NPM Package:**
- puppeteer: ^21.0.0 (for PDF generation)

**Existing Dependencies:**
- @nestjs/common, @nestjs/core (NestJS framework)
- @prisma/client (database ORM)
- @google-cloud/storage (GCS integration)
- Firebase Admin SDK (authentication)

### Flutter Dependencies

**New Packages:**
- signature: ^5.4.0 (signature pad widget)
- path_provider: ^2.1.1 (local file storage for downloads)

**Existing Dependencies:**
- dio: ^5.6.0 (HTTP client)
- flutter_secure_storage: ^5.0.2 (secure token storage)
- Firebase packages (authentication, messaging)

### Infrastructure Requirements

- Google Cloud Storage bucket configured for contracts
- Firebase Cloud Messaging configured for push notifications
- PostgreSQL database with Prisma migrations applied
- Backend deployed with sufficient memory for Puppeteer (minimum 1GB)

## Deployment Considerations

### Database Migration

Migration steps:
1. Add new columns to Contract table: pdfUrl, clientSignature, clientSignatureMetadata, craftsmanSignature, craftsmanSignatureMetadata
2. Ensure retentionPolicyId references exist
3. Create database indexes for performance
4. Run migration in staging environment first
5. Validate data integrity post-migration

### Backend Deployment

1. Install puppeteer package in backend directory
2. Configure Puppeteer to run in production environment (headless Chrome dependencies)
3. Set environment variables for GCS bucket and retention policies
4. Deploy ContractsModule with new routes
5. Verify PDF generation works in production environment
6. Monitor Puppeteer memory usage and adjust instance size if needed

### Flutter Deployment

1. Update pubspec.yaml with new dependencies in both apps
2. Run flutter pub get
3. Test signature package on all target platforms (iOS, Android, Web)
4. Update API service with new contract endpoints
5. Deploy updated apps to app stores
6. Monitor crash reports for signature-related issues

### Monitoring and Alerts

Monitor the following metrics:
- PDF generation success rate (target: >98%)
- Average PDF generation time (target: <10s)
- Signature submission success rate (target: >99%)
- Contract status distribution
- GCS storage usage for contracts
- Puppeteer memory consumption
- API endpoint response times

Set up alerts for:
- PDF generation failures exceeding 5% of requests
- GCS upload failures
- Puppeteer process crashes
- Signature submission errors exceeding 2% of requests

## Future Enhancements

### Phase 2 Enhancements

- Support for contract amendments and versioning
- Multi-language contract templates (English, Hungarian)
- Advanced e-signature with certificate authorities
- Contract comparison tool (version diff)
- Bulk contract generation for recurring services
- Contract templates for different service categories
- Integration with Romanian e-signature standards (ANAF compliance)

### Analytics and Insights

- Track average time from contract generation to full execution
- Measure signature abandonment rate
- Identify bottlenecks in signing process
- Generate reports on contract volume and trends
- Dashboard for admin contract oversight

### Compliance Enhancements

- GDPR compliance for signature data retention
- Romanian legal code compliance verification
- Audit log export for legal purposes
- Signature verification API for third parties
- Digital notarization integration
