# Contract System Testing Guide

## Backend Testing

### Prerequisites
1. Ensure backend is running: `cd backend && npm run start:dev`
2. Database is accessible and migrations applied: `npx prisma migrate dev`
3. Prisma client generated: `npx prisma generate`
4. Puppeteer Chrome dependencies installed on system

### Environment Variables Required
```env
DATABASE_URL=postgresql://user:password@localhost:5432/mesteri
CONTRACT_BUCKET_NAME=mesteri-contracts-dev
APPLICATION_ENV=dev
FIREBASE_PROJECT_ID=your-project-id
GCS_SIGNED_URLS=enabled
```

### Test Endpoints with cURL

#### 1. Generate Contract PDF
```bash
# Get Firebase token first (from Flutter app or Firebase console)
TOKEN="your-firebase-jwt-token"

# Generate PDF for a contract
curl -X POST http://localhost:3000/contracts/{contractId}/generate-pdf \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Expected Response:
# {
#   "contractId": "uuid",
#   "pdfUrl": "gs://bucket/contracts/...",
#   "expiresAt": "2025-10-31T...",
#   "status": "AWAITING_SIGNATURE"
# }
```

#### 2. Sign Contract
```bash
# Sign as client or craftsman
curl -X POST http://localhost:3000/contracts/{contractId}/sign \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "signatureData": "data:image/png;base64,iVBORw0KGgoAAAANS...",
    "signatureMetadata": {
      "capturedAt": "2025-10-31T19:00:00Z",
      "deviceType": "mobile",
      "platform": "android",
      "appVersion": "1.0.0"
    }
  }'

# Expected Response:
# {
#   "contractId": "uuid",
#   "signedBy": "client",
#   "signedAt": "2025-10-31T...",
#   "status": "AWAITING_SIGNATURE",
#   "allPartiesSigned": false
# }
```

#### 3. Get Contract Details
```bash
curl -X GET http://localhost:3000/contracts/{contractId} \
  -H "Authorization: Bearer $TOKEN"

# Expected Response: Full contract object with signatures and PDF URL
```

#### 4. List Contracts
```bash
# List all contracts for user
curl -X GET "http://localhost:3000/contracts?userId={userId}" \
  -H "Authorization: Bearer $TOKEN"

# List contracts by status
curl -X GET "http://localhost:3000/contracts?userId={userId}&status=ACTIVE" \
  -H "Authorization: Bearer $TOKEN"

# Expected Response:
# {
#   "contracts": [...],
#   "total": 5
# }
```

### Test PDF Generation

1. **Verify Puppeteer Installation:**
   ```bash
   cd backend
   node -e "const puppeteer = require('puppeteer'); console.log('Puppeteer installed:', puppeteer.version);"
   ```

2. **Check Generated PDF:**
   - Trigger contract creation via offer acceptance
   - Check GCS bucket for generated PDF
   - Download PDF and verify Romanian content, formatting, and signatures

3. **Validate PDF Hash:**
   - Retrieve contract from database
   - Verify hashSha256 field is populated
   - Re-calculate hash of downloaded PDF and compare

### Test Workflow Integration

1. **Create Job** (as client)
2. **Submit Offer** (as craftsman)
3. **Accept Offer** (as client) → Should auto-create contract
4. **Verify Contract Created:**
   ```sql
   SELECT * FROM contracts WHERE "projectId" = 'project-id';
   ```
5. **Check PDF Generation** (should happen automatically)
6. **Verify Notifications Sent** to both parties
7. **Sign Contract** (as client)
8. **Sign Contract** (as craftsman)
9. **Verify Project Status** changes to ACTIVE

## Flutter Testing

### Prerequisites
1. Install dependencies:
   ```bash
   cd app_client
   flutter pub get
   
   cd ../app_mester
   flutter pub get
   ```

2. Configure API base URL in app configuration

### Test Digital Signature Screen

1. Navigate to contract review screen
2. Tap "Sign Contract" button
3. **Test Cases:**
   - Try to submit empty signature → Should show error
   - Draw simple signature (< 3 strokes) → Should show error
   - Submit without agreeing to terms → Should show error
   - Draw valid signature, agree to terms → Should show confirmation dialog
   - Confirm signature → Should submit successfully

4. **Verify:**
   - Loading state shows during submission
   - Success message appears
   - Navigate back to review screen
   - Signature status updated

### Test Contract Review Screen

1. Open contract from list
2. **Verify Display:**
   - Status badge shows correct status
   - Project details displayed correctly
   - Parties information shown
   - Signature status for both parties
   - PDF preview button (if PDF exists)
   - Correct action button based on status

3. **Test Actions:**
   - If unsigned → "Sign Contract" button appears
   - If signed → Green confirmation message
   - If both signed → "Download PDF" option

### Test Contract Status Screen

1. Navigate to "My Contracts"
2. **Test Tabs:**
   - All: Shows all contracts
   - Pending: Shows DRAFT and AWAITING_SIGNATURE
   - Active: Shows ACTIVE contracts
   - Completed: Shows completed project contracts

3. **Test List:**
   - Contract cards display correctly
   - Status badges show correct colors
   - Signature indicators (C/M checkmarks)
   - Tap card → Navigate to review screen
   - Pull to refresh → Reload contracts

4. **Verify Filtering:**
   - Switch tabs
   - Correct contracts shown in each tab
   - Empty state when no contracts

## Integration Testing

### End-to-End Flow

1. **Setup:**
   - Client user logged in app_client
   - Craftsman user logged in app_mester
   - Backend running with database

2. **Flow Steps:**
   
   a. **Client posts job**
   b. **Craftsman submits offer**
   c. **Client accepts offer**
      - ✅ Project created
      - ✅ Contract created (status: DRAFT)
      - ✅ PDF generation triggered
      
   d. **Verify notifications**
      - Client receives "Contract ready"
      - Craftsman receives "Contract ready"
      
   e. **Client signs contract**
      - Opens contract from notification
      - Reviews contract details
      - Taps "Sign Contract"
      - Draws signature
      - Agrees to terms
      - Submits signature
      - ✅ Client signature recorded
      - ✅ Craftsman receives "Signature required" notification
      
   f. **Craftsman signs contract**
      - Opens contract from notification
      - Reviews contract
      - Signs contract
      - ✅ Craftsman signature recorded
      - ✅ Contract status → ACTIVE
      - ✅ Project status → ACTIVE
      - ✅ Both parties receive "Contract executed" notification
      
   g. **Verify final state**
      - Contract has both signatures
      - PDF contains placeholder for signatures
      - Project can proceed (milestones, payments, etc.)

### Test Concurrent Signatures

1. Have both users attempt to sign simultaneously
2. Verify both signatures recorded correctly
3. Verify no race conditions or duplicate updates

### Test Error Scenarios

1. **Network Failures:**
   - Sign with no internet → Should queue and retry
   - Intermittent connection → Should handle gracefully

2. **Invalid Data:**
   - Tampered signature data → Should reject
   - Wrong user signing → Should reject (403)
   - Already signed → Should reject (400)

3. **PDF Generation Failures:**
   - Missing project data → Should handle error
   - Puppeteer crash → Should log error, allow retry
   - GCS upload failure → Should handle error

## Performance Testing

### Backend Performance

1. **PDF Generation Time:**
   - Target: < 10 seconds
   - Measure: Time from endpoint call to PDF upload complete
   - Test with complex contracts

2. **Signature Submission:**
   - Target: < 2 seconds
   - Measure: POST /sign endpoint response time

3. **Contract Retrieval:**
   - Target: < 1 second
   - Measure: GET /contracts/:id response time

### Mobile Performance

1. **Signature Capture:**
   - Smooth drawing on low-end devices
   - No lag or stuttering
   - Works on various screen sizes

2. **List Loading:**
   - Load 20 contracts in < 2 seconds
   - Smooth scrolling
   - Images load progressively

## Security Testing

1. **Authentication:**
   - Access without token → 401
   - Invalid token → 401
   - Expired token → 401

2. **Authorization:**
   - Access other user's contract → 403
   - Sign contract not party to → 403
   - View PDF of other's contract → 403

3. **Data Validation:**
   - Empty signature → 400
   - Missing required fields → 400
   - Invalid status transition → 400

4. **PDF Security:**
   - Signed URLs expire after 15 minutes
   - Direct GCS access blocked
   - PDF hash verifiable

## Monitoring

### Metrics to Track

1. PDF generation success rate (target: >98%)
2. Average PDF generation time (target: <10s)
3. Signature submission success rate (target: >99%)
4. Contract status distribution
5. Time from contract creation to full execution
6. Signature abandonment rate

### Alerts to Configure

1. PDF generation failures >5%
2. GCS upload failures
3. Puppeteer process crashes
4. Signature submission errors >2%
5. Database query timeouts

## Known Issues / Limitations

1. PDF generation requires Puppeteer Chrome dependencies on server
2. Large PDFs may take longer to generate (>10s for complex contracts)
3. Signed URLs expire after 15 minutes (regenerate on demand)
4. Offline signature submission requires connectivity for retry
5. No digital certificate authority integration (Phase 2 feature)

## Next Steps

After testing confirms all features work:

1. Deploy to staging environment
2. Conduct user acceptance testing
3. Monitor metrics for 1 week
4. Address any issues found
5. Deploy to production
6. Monitor closely for first week
7. Collect user feedback
8. Plan Phase 2 enhancements
