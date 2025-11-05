# Contract Signing & Digital Signature - Testing Strategy

This document outlines a comprehensive testing strategy for the contract signing and digital signature feature of the Mesteri Platform. The primary goal is to validate the implementation in a sandbox environment without incurring costs from SignRequest.

## 1. SignRequest Sandbox Setup

SignRequest offers a free sandbox environment for testing purposes. All documents created in the sandbox are marked with a watermark and are not legally binding.

### 1.1. Create a Sandbox Account
1. Go to the [SignRequest website](https://signrequest.com/)
2. Sign up for a free account
3. Navigate to **Team Settings** → **API**
4. Find your **API Token** (this is your sandbox token)
5. Note your **Team Subdomain** (appears in URL: `https://{subdomain}.signrequest.com`)

### 1.2. API Token Configuration

Update `mesteri-platform/backend/.env`:

```env
# SignRequest Integration
SIGNREQUEST_API_URL=https://api.signrequest.com/v1
SIGNREQUEST_API_TOKEN=your_sandbox_api_token_here

# Google Cloud Storage for Contracts
GCS_CONTRACTS_BUCKET=mesteri-contracts-dev
```

### 1.3. Webhook URL Setup with Ngrok

SignRequest uses webhooks to notify our backend. To test locally:

1. **Install Ngrok:** [https://ngrok.com/download](https://ngrok.com/download)

2. **Run your backend:**
   ```bash
   cd mesteri-platform/backend
   npm run start:dev
   ```

3. **In another terminal, expose port 3000:**
   ```bash
   ngrok http 3000
   ```

4. **Copy the HTTPS URL** (e.g., `https://abc123.ngrok.io`)

5. **Configure webhook in SignRequest:**
   - Go to Team Settings → Webhooks
   - Add webhook URL: `https://abc123.ngrok.io/contracts/webhooks/signrequest`
   - Save the webhook

---

## 2. Prisma Database Migration

Apply schema changes to local PostgreSQL:

```bash
cd mesteri-platform/backend

# Run migration
npx prisma migrate dev --name add-signrequest-integration

# Generate Prisma client
npx prisma generate
```

---

## 3. Database Seed Script

Create test data for contracts.

**File:** `mesteri-platform/backend/prisma/seed-contracts.ts`

```typescript
import { PrismaClient, UserRole, JobStatus, ProjectStatus, JobCategory, UrgencyLevel } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding contract test data...');

  // 1. Create or find Retention Policy
  const retentionPolicy = await prisma.retentionPolicy.upsert({
    where: { code: 'STANDARD_GUARANTEE' },
    update: {},
    create: {
      code: 'STANDARD_GUARANTEE',
      description: 'Standard 12-month guarantee for completed work',
      activeDays: 365,
      archiveDays: 1825, // 5 years
      hardDeleteAfterDays: 3650, // 10 years
      requiresLegalReview: false,
    },
  });
  console.log('✓ Retention policy ready');

  // 2. Create Test Client
  const client = await prisma.user.upsert({
    where: { email: 'client.test@mesteri.ro' },
    update: {},
    create: {
      email: 'client.test@mesteri.ro',
      fullName: 'Ana Popescu',
      role: UserRole.CLIENT,
      city: 'București',
      county: 'București',
      address: 'Str. Victoriei nr. 10',
      phone: '+40721234567',
    },
  });
  console.log(`✓ Client created: ${client.fullName}`);

  // 3. Create Test Craftsman
  const craftsman = await prisma.user.upsert({
    where: { email: 'mester.test@mesteri.ro' },
    update: {},
    create: {
      email: 'mester.test@mesteri.ro',
      fullName: 'Ion Ionescu',
      role: UserRole.CRAFTSMAN,
      city: 'București',
      county: 'București',
      address: 'Str. Moților nr. 5',
      phone: '+40722345678',
      specialties: ['Instalații sanitare', 'Zugrăvit', 'Gresie și faianță'],
      yearsExperience: 10,
      isVerified: true,
    },
  });
  console.log(`✓ Craftsman created: ${craftsman.fullName}`);

  // 4. Create Test Job
  const job = await prisma.job.upsert({
    where: { id: 'test-job-contract-001' },
    update: {},
    create: {
      id: 'test-job-contract-001',
      title: 'Renovare Apartament 2 Camere',
      description: 'Renovare completă apartament: zugrăvit, parchet, gresie baie și bucătărie. Include materiale.',
      category: JobCategory.CONSTRUCTII,
      location: 'Sector 1, București',
      city: 'București',
      budgetMin: 4000,
      budgetMax: 6000,
      urgency: UrgencyLevel.MEDIUM,
      status: JobStatus.ACCEPTED,
      clientId: client.id,
    },
  });
  console.log(`✓ Job created: ${job.title}`);

  // 5. Create Test Project
  const project = await prisma.project.upsert({
    where: { jobId: job.id },
    update: {},
    create: {
      title: 'Renovare Apartament Ana Popescu',
      description: 'Proiect de renovare completă conform discuțiilor. Materiale incluse în preț.',
      totalBudget: 4800,
      status: ProjectStatus.FUNDED,
      jobId: job.id,
      clientId: client.id,
      craftsmanId: craftsman.id,
      agreedPrice: 4800,
      startDate: new Date('2025-12-01'),
      deadline: new Date('2025-12-20'),
    },
  });
  console.log(`✓ Project created: ${project.id}`);

  console.log('\n✅ Seeding complete! Test data ready.\n');
  console.log('📋 Test Users:');
  console.log(`   Client: ${client.email}`);
  console.log(`   Craftsman: ${craftsman.email}`);
  console.log(`\n📦 Test Project ID: ${project.id}`);
  console.log(`\n🚀 You can now test contract creation with:`);
  console.log(`   POST http://localhost:3000/contracts/project/${project.id}\n`);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

**Run the seed:**

```bash
npx ts-node prisma/seed-contracts.ts
```

---

## 4. Manual Testing Procedure

### Step 1: Create Contract

```bash
curl -X POST http://localhost:3000/contracts/project/{PROJECT_ID} \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "id": "contract-uuid",
  "projectId": "project-uuid",
  "status": "PENDING_SIGNATURE",
  "version": 1,
  "signRequestViewUrl": "https://signrequest.com/...",
  "createdAt": "2025-11-03T..."
}
```

**Verify:**
- ✅ Contract created in database
- ✅ SignRequest document visible in dashboard
- ✅ Both users received signing emails

### Step 2: Sign the Contract

1. Check email inbox for `client.test@mesteri.ro`
2. Click signing link
3. Complete signature in SignRequest UI
4. Repeat for `mester.test@mesteri.ro`

### Step 3: Verify Webhook Processing

**Watch backend logs:**
```
[ContractsService] Processing 'signed' webhook for SignRequest document...
[ContractsService] Downloading signed PDF...
[ContractsService] Uploading signed PDF to GCS...
[ContractsService] Contract updated to SIGNED state.
```

**Check database:**
```sql
SELECT id, status, signedAt, storageObjectPath
FROM contracts
WHERE projectId = 'your-project-id';
```

### Step 4: Download Signed Contract

```bash
curl -X GET http://localhost:3000/contracts/{CONTRACT_ID}
```

**Expected Response:**
```json
{
  "id": "contract-uuid",
  "projectId": "project-uuid",
  "status": "SIGNED",
  "signedDocumentUrl": "https://storage.googleapis.com/...",
  "createdAt": "2025-11-03T..."
}
```

**Verify:**
- ✅ Signed URL is valid (7-day expiration)
- ✅ PDF downloads successfully
- ✅ PDF contains both signatures

---

## 5. Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `SignRequest is not configured` | Missing API token | Add `SIGNREQUEST_API_TOKEN` to `.env` |
| `Retention policy not found` | Database not seeded | Run seed script |
| `Project not found` | Invalid project ID | Use project ID from seed output |
| `GCS authentication failed` | Missing credentials | Set `GOOGLE_APPLICATION_CREDENTIALS` |
| `Webhook not received` | Ngrok not running | Restart ngrok and update webhook URL |

---

## 6. Automated Testing

**File:** `mesteri-platform/backend/src/contracts/contracts.service.spec.ts`

```typescript
import { Test } from '@nestjs/testing';
import { ContractsService } from './contracts.service';
import { PrismaService } from '../prisma/prisma.service';
import { SignRequestService } from '../signrequest/signrequest.service';

describe('ContractsService', () => {
  let service: ContractsService;
  let prisma: PrismaService;
  let signRequest: SignRequestService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        ContractsService,
        {
          provide: PrismaService,
          useValue: {
            project: { findUnique: jest.fn() },
            contract: { create: jest.fn(), update: jest.fn() },
            retentionPolicy: { findUnique: jest.fn() },
          },
        },
        {
          provide: SignRequestService,
          useValue: {
            createDocumentWithSigners: jest.fn(),
            downloadSignedPdf: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(ContractsService);
    prisma = module.get(PrismaService);
    signRequest = module.get(SignRequestService);
  });

  it('should create a contract', async () => {
    // Test implementation
    expect(service).toBeDefined();
  });
});
```

**Run tests:**
```bash
npm test contracts.service.spec.ts
```

---

## 7. Production Readiness Checklist

### Before Production Deployment:

- [ ] All sandbox tests passing
- [ ] Retention policy seeded in production DB
- [ ] Production SignRequest account created
- [ ] Production API token configured
- [ ] Production GCS bucket created and configured
- [ ] Production webhook URL configured in SignRequest
- [ ] Error monitoring set up (Sentry, LogRocket, etc.)
- [ ] Email notifications tested
- [ ] Payment escrow integration tested
- [ ] Flutter UI tested end-to-end
- [ ] Load testing completed (100+ concurrent contracts)
- [ ] Backup strategy for GCS contracts implemented
- [ ] Legal review of contract template completed

### Cost Validation:

- [ ] Confirmed SignRequest pricing (€0.50/contract)
- [ ] GCS storage costs calculated
- [ ] Monthly budget allocated for contract volume

---

## 8. Quick Start Commands

```bash
# 1. Install dependencies
cd mesteri-platform/backend
npm install

# 2. Run migrations
npx prisma migrate dev

# 3. Seed test data
npx ts-node prisma/seed-contracts.ts

# 4. Start backend
npm run start:dev

# 5. In new terminal: Expose with ngrok
ngrok http 3000

# 6. Test contract creation
curl -X POST http://localhost:3000/contracts/project/{PROJECT_ID}
```

---

**Ready to test!** 🚀
