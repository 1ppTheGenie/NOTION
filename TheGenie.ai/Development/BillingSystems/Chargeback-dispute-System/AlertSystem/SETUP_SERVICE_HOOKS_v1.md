# Azure DevOps Service Hooks Setup Guide
## SMS Alert System Configuration

**Version:** 1.0  
**Created:** December 29, 2025  
**Author:** AI Agent / Steve Hundley  

---

## 📋 OVERVIEW

This guide walks through configuring Azure DevOps Service Hooks to trigger SMS alerts via the TheGenie.ai webhook.

---

## 🚀 QUICK SETUP (5 Minutes)

### Step 1: Open Service Hooks Settings

Navigate to:
```
https://oneparkplace.visualstudio.com/SMART/_settings/serviceHooks
```

Or: **Project Settings** → **Service hooks**

---

### Step 2: Create "Production Approval" Webhook

1. Click **+ Create subscription**
2. Select **Web Hooks** from the service list
3. Click **Next**

#### Trigger Configuration:
| Field | Value |
|-------|-------|
| **Trigger** | Release deployment approval pending |
| **Release pipeline** | SMART-Dashboard-Deploy |
| **Stage** | Production |

4. Click **Next**

#### Action Configuration:
| Field | Value |
|-------|-------|
| **URL** | `https://thegenie.ai/api/alerts/devops` |
| **HTTP headers** | (leave empty) |
| **Resource details to send** | All |
| **Messages to send** | All |
| **Detailed messages to send** | All |

5. Click **Test** to verify connection
6. Click **Finish**

---

### Step 3: Create "Build Failed" Webhook

1. Click **+ Create subscription**
2. Select **Web Hooks**
3. Click **Next**

#### Trigger Configuration:
| Field | Value |
|-------|-------|
| **Trigger** | Build completed |
| **Build pipeline** | SMART-Dashboard-Build |
| **Build status** | Failed |

4. Click **Next**

#### Action Configuration:
| Field | Value |
|-------|-------|
| **URL** | `https://thegenie.ai/api/alerts/devops` |
| **Resource details to send** | All |

5. Click **Test** → **Finish**

---

### Step 4: Create "Deployment Failed" Webhook (Optional)

1. Click **+ Create subscription**
2. Select **Web Hooks**
3. Click **Next**

#### Trigger Configuration:
| Field | Value |
|-------|-------|
| **Trigger** | Release deployment completed |
| **Release pipeline** | SMART-Dashboard-Deploy |
| **Stage** | [Any] |
| **Deployment status** | Failed |

4. Click **Next**

#### Action Configuration:
| Field | Value |
|-------|-------|
| **URL** | `https://thegenie.ai/api/alerts/devops` |

5. Click **Finish**

---

## ✅ VERIFICATION

After setup, you should see 2-3 subscriptions in the Service Hooks list:

| Subscription | Status |
|--------------|--------|
| Web Hooks - Release deployment approval pending | ✅ Enabled |
| Web Hooks - Build completed (Failed) | ✅ Enabled |
| Web Hooks - Release deployment completed (Failed) | ✅ Enabled (optional) |

---

## 🧪 TESTING

### Test 1: Production Approval Alert
1. Create a new Release in Azure DevOps
2. Wait for Staging to complete
3. Production should show "Pending Approval"
4. You should receive an SMS within 30 seconds

### Test 2: Build Failed Alert
1. Check in code with a syntax error
2. Build should fail
3. You should receive an SMS within 30 seconds

---

## 📱 CONFIGURE YOUR PHONE NUMBER

**IMPORTANT:** Before alerts will work, add your phone number to the controller:

1. Open `AlertsController.cs`
2. Find the `AlertRecipients` array
3. Add your phone number in format: `"+1XXXXXXXXXX"`

Example:
```csharp
private static readonly string[] AlertRecipients = new string[]
{
    "+15551234567"  // Steve's phone
};
```

4. Check in and deploy the change

---

## 🔒 SECURITY NOTES

1. The webhook endpoint is public but only processes known event types
2. Azure DevOps signs requests (can add signature verification later)
3. Twilio credentials are stored in the controller (TODO: move to config)
4. Phone numbers should be moved to a database for UI configuration

---

## 📝 TROUBLESHOOTING

### SMS Not Received

1. Check Service Hook history in Azure DevOps
2. Verify webhook URL is correct
3. Verify phone number is in correct format (+1XXXXXXXXXX)
4. Check Twilio dashboard for delivery status

### Webhook Timeout

1. Azure DevOps expects response within 20 seconds
2. Twilio API is fast, should not timeout
3. Check server logs for errors

---

## 📝 CHANGE LOG

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 12/29/2025 | AI Agent | Initial guide |


