# SignRequest Sandbox Setup Guide for Mesteri Platform

This guide provides a complete walkthrough for setting up a SignRequest sandbox account to test the contract signing feature of the Mesteri Platform.

## 1. Create Your SignRequest Sandbox Account

### Step 1: Sign Up
1. **Navigate to SignRequest:** Go to [https://signrequest.com/](https://signrequest.com/)
2. **Click "Try for Free"** or **"Sign Up"** button
3. **Register** using email/password or Google/LinkedIn account

### Step 2: Create Your Team
1. After signup, you'll be prompted to **create a team**
2. Give your team a name (e.g., "Mesteri Platform Dev")
3. **This team is required for API access**

### Step 3: Activate Sandbox Mode
1. Click your **profile icon** (top-right corner)
2. Select **"Settings"**
3. Go to **"Teams"** tab
4. Look for **"Create Sandbox Team"** or sandbox mode toggle
5. Click it to create a separate sandbox environment

**✅ What You Should See:**
- Prominent **"Sandbox"** or **"Test Mode"** banner at top of dashboard
- All documents will have a **"TEST"** watermark
- Signatures are NOT legally binding in sandbox

---

## 2. Obtain Your API Token

### Navigation Path: `Settings → Team → API → Create Token`

**Step-by-Step:**
1. Go to **Settings** (profile icon → Settings)
2. Click **"Teams"** tab
3. **Select your Sandbox Team** (make sure it says "Sandbox")
4. Scroll to **"API Settings"** section
5. Click **"Create Token"** button
6. **COPY the token IMMEDIATELY** - you won't see it again!

**Where to Save:**
```env
# mesteri-platform/backend/.env
SIGNREQUEST_API_TOKEN=your_sandbox_token_here
```

⚠️ **Common Mistake:** Using production token instead of sandbox token!

---

## 3. Find and Set Your Team Subdomain

### What is a Subdomain?
Your subdomain is part of your SignRequest URL: `https://<subdomain>.signrequest.com`

**Where to Find:**
1. Go to **Settings → Team**
2. Your subdomain is displayed at the top (usually based on team name)
3. Example: If team is "Mesteri Dev", subdomain might be `mesteri-dev`

**Where to Save:**
```env
# mesteri-platform/backend/.env
SIGNREQUEST_SUBDOMAIN=your-subdomain-here
```

---

## 4. Configure Webhooks

### Navigation Path: `Settings → Team → API → Add Webhook`

Webhooks notify your backend when documents are signed.

### Step 1: Set Up Ngrok (for local testing)

**Install Ngrok:**
```bash
# Download from https://ngrok.com/download
# Then run:
ngrok http 3000
```

**Copy the HTTPS URL** (e.g., `https://abc123.ngrok.io`)

### Step 2: Add Webhook in SignRequest

1. Go to **Settings → Team → API**
2. Click **"Add Webhook"**
3. **Configure:**
   - **URL:** `https://abc123.ngrok.io/contracts/webhooks/signrequest`
   - **Events to Subscribe:**
     - ✅ `signed` (when document is signed)
     - ✅ `declined` (when signer declines)
     - ✅ `sent` (when document is sent)
4. **Copy the Webhook Secret** (used for signature verification)

**Where to Save:**
```env
# mesteri-platform/backend/.env
SIGNREQUEST_WEBHOOK_SECRET=your_webhook_secret_here
```

⚠️ **IMPORTANT:**
- URL MUST be HTTPS (not HTTP)
- URL must be publicly accessible
- Ngrok URL changes each time you restart it

---

## 5. Verify Sandbox Mode

### Visual Checklist:
- [ ] Dashboard shows **"Sandbox"** or **"Test Mode"** banner
- [ ] Team name includes "Sandbox" indicator
- [ ] All documents show **"TEST"** watermark when signed
- [ ] Settings show you're in sandbox team (not production)

**Screenshot Description:**
- Top of page: Orange/yellow banner saying "SANDBOX MODE"
- Team selector: "Mesteri Platform Dev (Sandbox)"

---

## 6. Manually Test Document Signing

### Create Your First Test Document:

1. **Click "+ New SignRequest"** in dashboard
2. **Upload a sample PDF** (any PDF will work)
3. **Add yourself as signer** with your email
4. **Place signature field:**
   - Drag signature box onto PDF
   - Position where signature should appear
5. **Click "Send"**
6. **Check your email** for signing link
7. **Click link and sign** the document

**✅ What You Should See:**
- Email from SignRequest with signing link
- Document with "TEST" watermark
- Simple signing interface
- Confirmation after signing

**Why This Matters:**
This helps you understand the user experience before API integration.

---

## 7. Common Mistakes to Avoid

| Mistake | Problem | Solution |
|---------|---------|----------|
| **Production token in .env** | Charges money! | Use sandbox token |
| **HTTP webhook URL** | SignRequest rejects it | Must be HTTPS |
| **Forgot to subscribe to events** | No webhooks received | Enable `signed`, `declined`, `sent` |
| **Ngrok URL changed** | Webhooks fail | Update webhook URL in SignRequest |
| **No webhook secret** | Can't verify requests | Copy secret from webhook settings |
| **Wrong subdomain** | API calls fail | Check team settings for correct subdomain |

---

## 8. Monitor Webhook Deliveries

### How to Debug Webhook Issues:

1. Go to **Settings → Team → API**
2. Find your webhook in the list
3. Click **"View Deliveries"** or similar
4. **You'll see:**
   - Timestamp of each webhook attempt
   - HTTP status code (200 = success)
   - Request payload sent
   - Response from your server

**Common Issues:**
- **404 Not Found:** Wrong URL path
- **500 Error:** Your backend crashed
- **Timeout:** Your endpoint took too long

---

## 9. Usage Limits & Pricing

### Sandbox (FREE):
- ✅ Unlimited test documents
- ✅ Does NOT count toward production limits
- ✅ All documents watermarked
- ✅ NOT legally binding

### Production (PAID):
- 💰 €0.50 per contract
- ✅ Legally binding signatures
- ✅ No watermarks
- ✅ Audit trail and compliance

**When to Switch:**
Only switch to production when:
- All tests pass in sandbox
- You're ready to pay €0.50 per contract
- You need legally binding signatures

---

## 10. Quick Setup Checklist

- [ ] Create SignRequest account
- [ ] Create sandbox team
- [ ] Copy API token → save to `.env`
- [ ] Copy subdomain → save to `.env`
- [ ] Install and run ngrok: `ngrok http 3000`
- [ ] Add webhook with ngrok URL
- [ ] Copy webhook secret → save to `.env`
- [ ] Subscribe to events: `signed`, `declined`, `sent`
- [ ] Send test document manually
- [ ] Sign test document
- [ ] Verify webhook received (check logs)

---

## 11. Your .env File Should Look Like:

```env
# SignRequest Integration
SIGNREQUEST_API_URL=https://api.signrequest.com/v1
SIGNREQUEST_API_TOKEN=sr_sandbox_abc123xyz...
SIGNREQUEST_WEBHOOK_SECRET=whsec_def456uvw...

# Google Cloud Storage for Contracts
GCS_CONTRACTS_BUCKET=mesteri-contracts-dev
```

---

## 12. Next Steps After Setup

1. **Run backend:** `npm run start:dev`
2. **Run ngrok:** `ngrok http 3000`
3. **Seed database:** `npx ts-node prisma/seed-contracts.ts`
4. **Test API:** `curl -X POST http://localhost:3000/contracts/project/{PROJECT_ID}`
5. **Check SignRequest dashboard** for new document
6. **Sign document** in SignRequest UI
7. **Watch backend logs** for webhook reception

---

## 📚 Additional Resources

- **SignRequest API Docs:** [https://signrequest.com/api/v1/docs/](https://signrequest.com/api/v1/docs/)
- **Ngrok Documentation:** [https://ngrok.com/docs](https://ngrok.com/docs)
- **SignRequest Support:** support@signrequest.com

---

## 🆘 Troubleshooting

### Problem: "API token is invalid"
**Solution:** Make sure you're using the SANDBOX token, not production

### Problem: "Webhooks not received"
**Solution:**
1. Check ngrok is still running
2. Verify webhook URL in SignRequest matches ngrok URL
3. Check backend logs for errors
4. Verify webhook secret matches

### Problem: "Document not created"
**Solution:**
1. Check API token is correct
2. Verify HTML content is valid
3. Check signer emails are valid
4. Review backend logs for errors

---

**Ready to test!** 🚀

Follow the **CONTRACT_SIGNING_TESTING_STRATEGY.md** guide for complete testing procedures.
