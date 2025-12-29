# PRODUCTION DEPLOYMENT INSTRUCTIONS
## PayPal Webhook - to Ankit

**Version:** 1.0  
**Created:** 12/29/2025  
**Author:** Steve Hundley
**Priority:** 🔴 HIGH - Deploy TODAY  
**Changeset:** 4678

---

## ✅ PRE-DEPLOYMENT CHECKLIST

| Step | Action | Status |
|:----:|--------|:------:|
| 1 | Code checked into TFVC | ✅ DONE (Changeset 4678) |
| 2 | Files verified in source control | ✅ DONE |
| 3 | Sandbox tested | ✅ DONE |
| 4 | Bypass Staging 
| 5 | Deploy to Production | ⏳ YOUR TASK |
| 6 | Test Production endpoint | ⏳ YOUR TASK |
| 7 | If pass DONE - if not report error


# Deploy Changeset 4678 to Production

**Date:** 12/29/2025  
**Priority:** HIGH - Deploy Today  
**Changeset:** 4678

---

## What To Do

1. **Get Latest** from source control (Changeset 4678)
2. **Build** the solution
3. **Deploy** Smart.Dashboard to **staging** first
4. **Deploy** Smart.Dashboard to **production**
5. **Let Steve know** when it's live

---

## Verify It Worked

After production deployment, open this URL in a browser:

```
https://app.thegenie.ai/api/paypal/webhook
```

You should see:

```json
{"status":"active","service":"TheGenie.ai PayPal Webhook","version":"1.0"}
```

If you see that response, **you're done**. Steve will handle the rest.

---

## Files In Changeset 4678

```
Smart.Dashboard/Controllers/PayPalWebhooksController.cs
Smart.Dashboard/BLL/PayPal/PayPalWebhookManager.cs
Smart.Model/PayPal/PayPalWebhookEvent.cs
```

---

## Questions?

Contact Steve Hundley.
