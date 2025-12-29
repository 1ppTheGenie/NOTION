using Newtonsoft.Json;
using System;

namespace Smart.Model.PayPal
{
    /// <summary>
    /// PayPal Webhook Event Model for TheGenie.ai Billing System
    /// ==========================================================
    /// Version: 1.0
    /// Created: 12/28/2025
    /// Author: Cursor Opus Agent
    /// 
    /// PURPOSE:
    /// Deserializes incoming PayPal webhook JSON payloads.
    /// 
    /// PAYPAL WEBHOOK STRUCTURE:
    /// {
    ///   "id": "WH-xxxxx",
    ///   "event_type": "CUSTOMER.DISPUTE.CREATED",
    ///   "create_time": "2025-12-28T00:00:00Z",
    ///   "resource_type": "dispute",
    ///   "resource": { ... event-specific data ... }
    /// }
    /// 
    /// RELATED FILES:
    /// - Controllers/PayPalWebhooksController.cs
    /// - BLL/PayPal/PayPalWebhookManager.cs
    /// </summary>
    public class PayPalWebhookEvent
    {
        /// <summary>
        /// Unique webhook event ID from PayPal (e.g., "WH-2WR32451HC0233532-67976317FL4543714")
        /// </summary>
        [JsonProperty("id")]
        public string Id { get; set; }

        /// <summary>
        /// The event type (e.g., "CUSTOMER.DISPUTE.CREATED", "PAYMENT.CAPTURE.REFUNDED")
        /// </summary>
        [JsonProperty("event_type")]
        public string EventType { get; set; }

        /// <summary>
        /// Timestamp when the event was created
        /// </summary>
        [JsonProperty("create_time")]
        public DateTime? CreateTime { get; set; }

        /// <summary>
        /// Type of resource (e.g., "dispute", "capture", "subscription")
        /// </summary>
        [JsonProperty("resource_type")]
        public string ResourceType { get; set; }

        /// <summary>
        /// The actual event data - structure varies by event type
        /// </summary>
        [JsonProperty("resource")]
        public PayPalWebhookResource Resource { get; set; }

        /// <summary>
        /// Summary of the event
        /// </summary>
        [JsonProperty("summary")]
        public string Summary { get; set; }

        /// <summary>
        /// Links related to the webhook event
        /// </summary>
        [JsonProperty("links")]
        public PayPalLink[] Links { get; set; }
    }

    /// <summary>
    /// Resource object containing event-specific data
    /// This is a flexible model that handles multiple event types
    /// </summary>
    public class PayPalWebhookResource
    {
        // Common fields across event types
        [JsonProperty("id")]
        public string Id { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        // Dispute-specific fields
        [JsonProperty("dispute_id")]
        public string DisputeId { get; set; }

        [JsonProperty("reason")]
        public string Reason { get; set; }

        [JsonProperty("dispute_state")]
        public string DisputeState { get; set; }

        [JsonProperty("dispute_amount")]
        public PayPalAmount DisputeAmount { get; set; }

        // Payment-specific fields
        [JsonProperty("amount")]
        public PayPalAmount Amount { get; set; }

        [JsonProperty("final_capture")]
        public bool? FinalCapture { get; set; }

        // Subscription-specific fields
        [JsonProperty("plan_id")]
        public string PlanId { get; set; }

        [JsonProperty("subscriber")]
        public PayPalSubscriber Subscriber { get; set; }

        // Invoice-specific fields
        [JsonProperty("invoice_number")]
        public string InvoiceNumber { get; set; }

        // Transaction references
        [JsonProperty("seller_transaction_id")]
        public string SellerTransactionId { get; set; }

        [JsonProperty("disputed_transactions")]
        public PayPalDisputedTransaction[] DisputedTransactions { get; set; }
    }

    /// <summary>
    /// PayPal Amount object
    /// </summary>
    public class PayPalAmount
    {
        [JsonProperty("currency_code")]
        public string CurrencyCode { get; set; }

        [JsonProperty("value")]
        public string Value { get; set; }
    }

    /// <summary>
    /// PayPal Subscriber object for subscription events
    /// </summary>
    public class PayPalSubscriber
    {
        [JsonProperty("email_address")]
        public string EmailAddress { get; set; }

        [JsonProperty("payer_id")]
        public string PayerId { get; set; }

        [JsonProperty("name")]
        public PayPalName Name { get; set; }
    }

    /// <summary>
    /// PayPal Name object
    /// </summary>
    public class PayPalName
    {
        [JsonProperty("given_name")]
        public string GivenName { get; set; }

        [JsonProperty("surname")]
        public string Surname { get; set; }
    }

    /// <summary>
    /// PayPal Disputed Transaction object
    /// </summary>
    public class PayPalDisputedTransaction
    {
        [JsonProperty("seller_transaction_id")]
        public string SellerTransactionId { get; set; }

        [JsonProperty("buyer_transaction_id")]
        public string BuyerTransactionId { get; set; }

        [JsonProperty("create_time")]
        public DateTime? CreateTime { get; set; }

        [JsonProperty("transaction_status")]
        public string TransactionStatus { get; set; }

        [JsonProperty("gross_amount")]
        public PayPalAmount GrossAmount { get; set; }
    }

    /// <summary>
    /// PayPal Link object
    /// </summary>
    public class PayPalLink
    {
        [JsonProperty("href")]
        public string Href { get; set; }

        [JsonProperty("rel")]
        public string Rel { get; set; }

        [JsonProperty("method")]
        public string Method { get; set; }
    }
}

