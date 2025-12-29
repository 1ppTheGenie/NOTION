using Smart.Core.BLL.Logging;
using Smart.Model.PayPal;
using System;
using System.Net;

namespace Smart.Dashboard.BLL.PayPal
{
    /// <summary>
    /// PayPal Webhook Manager for TheGenie.ai Billing System
    /// Version: 2.0
    /// Created: 12/28/2025
    /// </summary>
    public class PayPalWebhookManager
    {
        /// <summary>
        /// Main entry point for processing PayPal webhook events
        /// </summary>
        public static HttpStatusCode ProcessEvent(PayPalWebhookEvent webhookEvent)
        {
            try
            {
                if (webhookEvent == null)
                {
                    Logger.Log("PayPal webhook received null event", title: "PayPal Webhook");
                    return HttpStatusCode.BadRequest;
                }

                // Log the event
                Logger.Log($"PayPal Webhook: {webhookEvent.EventType} | ID: {webhookEvent.Id}", title: "PayPal Webhook Received");

                // Route to appropriate handler based on event type
                var eventType = webhookEvent.EventType ?? string.Empty;

                if (eventType.StartsWith("CUSTOMER.DISPUTE"))
                {
                    ProcessDisputeEvent(webhookEvent);
                }
                else if (eventType.StartsWith("PAYMENT"))
                {
                    ProcessPaymentEvent(webhookEvent);
                }
                else if (eventType.StartsWith("BILLING.SUBSCRIPTION"))
                {
                    ProcessSubscriptionEvent(webhookEvent);
                }
                else if (eventType.StartsWith("INVOICING"))
                {
                    ProcessInvoiceEvent(webhookEvent);
                }
                else
                {
                    Logger.Log($"Unknown PayPal event type: {eventType}", title: "PayPal Webhook Unknown");
                }

                return HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                Logger.Log(ex, title: "PayPal Webhook Error");
                return HttpStatusCode.OK;
            }
        }

        private static void ProcessDisputeEvent(PayPalWebhookEvent webhookEvent)
        {
            try
            {
                var resource = webhookEvent.Resource;
                var disputeId = resource?.DisputeId ?? "UNKNOWN";
                var reason = resource?.Reason ?? "UNKNOWN";

                Logger.Log($"DISPUTE: {webhookEvent.EventType} | ID: {disputeId} | Reason: {reason}", title: "PayPal Dispute");
            }
            catch (Exception ex)
            {
                Logger.Log(ex, title: "PayPal Dispute Error");
            }
        }

        private static void ProcessPaymentEvent(PayPalWebhookEvent webhookEvent)
        {
            try
            {
                var resource = webhookEvent.Resource;
                var txnId = resource?.Id ?? "UNKNOWN";
                var amount = resource?.Amount?.Value ?? "0.00";

                Logger.Log($"PAYMENT: {webhookEvent.EventType} | TxnID: {txnId} | Amount: {amount}", title: "PayPal Payment");
            }
            catch (Exception ex)
            {
                Logger.Log(ex, title: "PayPal Payment Error");
            }
        }

        private static void ProcessSubscriptionEvent(PayPalWebhookEvent webhookEvent)
        {
            try
            {
                var resource = webhookEvent.Resource;
                var subId = resource?.Id ?? "UNKNOWN";
                var status = resource?.Status ?? "UNKNOWN";

                Logger.Log($"SUBSCRIPTION: {webhookEvent.EventType} | SubID: {subId} | Status: {status}", title: "PayPal Subscription");
            }
            catch (Exception ex)
            {
                Logger.Log(ex, title: "PayPal Subscription Error");
            }
        }

        private static void ProcessInvoiceEvent(PayPalWebhookEvent webhookEvent)
        {
            try
            {
                var resource = webhookEvent.Resource;
                var invoiceId = resource?.Id ?? "UNKNOWN";

                Logger.Log($"INVOICE: {webhookEvent.EventType} | InvoiceID: {invoiceId}", title: "PayPal Invoice");
            }
            catch (Exception ex)
            {
                Logger.Log(ex, title: "PayPal Invoice Error");
            }
        }
    }
}

