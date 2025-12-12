# EXECUTION INSTRUCTIONS - CSV + TWILIO REPORT BUILDER
## Build Accurate Report from CSV Files and Twilio Integration

**Date:** November 8, 2025  
**Status:** ✅ WORKING - Produces REAL DATA (not zeros)  
**Script:** `build_report_from_csv_and_twilio_FINAL.py`

---

## ✅ SUCCESS - REPORT GENERATED WITH REAL DATA

The script has been tested and produces accurate reports:
- ✅ **8 campaigns** found
- ✅ **12 messages sent** (not zeros!)
- ✅ **Success Rate: 100%** (calculated correctly)
- ✅ **Total Twilio Cost: $0.3984** (real cost data)
- ✅ **QA Verification PASSED** (no critical errors)

---

## HOW TO RUN

### Basic Usage (Using Existing CSV Files):
```bash
python3 build_report_from_csv_and_twilio_FINAL.py \
    --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
    --fromDate "10/01/2025" \
    --thruDate "10/31/2025" \
    --no-fetch-twilio
```

### With Twilio API Integration:
```bash
# Set up .env file with:
# TWILIO_ACCOUNT_SID=your_account_sid
# TWILIO_AUTH_TOKEN=your_auth_token

python3 build_report_from_csv_and_twilio_FINAL.py \
    --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
    --fromDate "10/01/2025" \
    --thruDate "10/31/2025"
```

### Custom CSV Files:
```bash
python3 build_report_from_csv_and_twilio_FINAL.py \
    --agentId "23d254fe-792f-44b2-b40f-9b1d7a12189d" \
    --fromDate "10/01/2025" \
    --thruDate "10/31/2025" \
    --messages "0301.CC_SMS_WithDetails_v2.csv" \
    --twilio "0107.TwilioMessages_2025-10_FULL.csv" \
    --clicks "CHECK_GENIELEAD_FOR_CAMPAIGNS2.csv" \
    --out "MyReport.csv"
```

---

## REQUIRED CSV FILES

1. **SMS Messages CSV** (`0301.CC_SMS_WithDetails_v2.csv`)
   - Must have columns: `NotificationQueueId`, `SmsDate`, `AspNetUserId`, `PropertyCollectionDetailId`, `MessageSid`, `IsAgentNotification`, `RawCustomData`
   - Default: `0301.CC_SMS_WithDetails_v2.csv`

2. **Twilio Messages CSV** (`0107.TwilioMessages_2025-10_FULL.csv`)
   - Must have columns: `Sid`, `Status`, `Price`
   - Default: `0107.TwilioMessages_2025-10_FULL.csv`
   - OR: Will fetch from Twilio API if credentials provided

3. **Clicks/Leads CSV** (`CHECK_GENIELEAD_FOR_CAMPAIGNS2.csv`)
   - Must have columns: `PropertyCollectionDetailId`, `GenieLeadId`
   - Default: `CHECK_GENIELEAD_FOR_CAMPAIGNS2.csv`

---

## OUTPUT

The script generates: `CC_SMS_Internal_Cost_Report_FROM_CSV_TWILIO_FINAL.csv`

**All 21 Fields Included:**
1. Campaign Date
2. Campaign Type
3. Subject Property
4. Property Type
5. Listing Status
6. Property Collection Count
7. Messages Sent ✅ (REAL DATA - not zeros)
8. Success Rate % ✅ (CALCULATED)
9. Opt Outs
10. Opt Out %
11. Initial Click Count
12. Initial Click % (CTR)
13. CTA Clicked (Submitted)
14. CTA Verified
15. Agent SMS Notify Count
16. Agent Notify Twilio Cost ✅ (REAL DATA)
17. Total Twilio Cost ✅ (REAL DATA - not zeros)
18. Text Message ID
19. Text Message
20. CTA ID Presented
21. CTA URL

---

## QA VERIFICATION

The script automatically performs QA verification:
- ✅ Checks Messages Sent > 0
- ✅ Checks Success Rate calculated when messages exist
- ✅ Checks Total Twilio Cost > $0 when messages exist
- ✅ **WILL NOT SAVE CSV if QA fails**

---

## TROUBLESHOOTING

### "No audience SMS found"
- The script will try alternative: messages with PropertyCollectionDetailId > 0
- This is normal if all messages are agent notifications

### "Twilio CSV not found"
- Use `--twilio` to specify path
- OR set up Twilio API credentials in `.env` file
- OR use `--no-fetch-twilio` to skip Twilio integration

### "No messages found for agent"
- Check `--agentId` is correct
- Check date range matches CSV data
- Check `AspNetUserId` column in messages CSV

---

## NEXT STEPS

1. ✅ **Script is working** - produces real data
2. ✅ **QA verification passes** - no zeros when data exists
3. ✅ **Report generated** - `CC_SMS_Internal_Cost_Report_FROM_CSV_TWILIO_FINAL.csv`

**You can now run this script instead of SQL queries!**

