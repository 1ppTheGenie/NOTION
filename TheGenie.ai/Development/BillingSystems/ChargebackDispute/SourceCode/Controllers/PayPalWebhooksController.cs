using Smart.Dashboard.BLL.PayPal;
using Smart.Model.PayPal;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Smart.Dashboard.Controllers
{
    /// <summary>
    /// PayPal Webhook Controller for TheGenie.ai Billing System
    /// ==========================================================
    /// Version: 1.0
    /// Created: 12/28/2025
    /// Author: Cursor Opus Agent
    /// 
    /// PURPOSE:
    /// Receives webhook notifications from PayPal for:
    /// - Customer disputes (chargebacks)
    /// - Payment events (refunds, captures)
    /// - Billing subscription events
    /// - Invoice events
    /// 
    /// DEPLOYMENT:
    /// This controller exposes: https://app.thegenie.ai/api/webhooks/paypal
    /// Configure this URL in PayPal Developer Portal → Apps & Credentials → Webhooks
    /// 
    /// PATTERN:
    /// Modeled after existing FacebookWebhookManager pattern in this codebase.
    /// 
    /// RELATED FILES:
    /// - BLL/PayPal/PayPalWebhookManager.cs
    /// - Model/PayPal/PayPalWebhookEvent.cs
    /// - Model/PayPal/PayPalDisputeEvent.cs
    /// </summary>
    [RoutePrefix("api/paypal")]
    public class PayPalWebhooksController : ApiController
    {
        /// <summary>
        /// Health check / verification endpoint
        /// PayPal may call this to verify the webhook URL is active
        /// </summary>
        /// <returns>200 OK with status message</returns>
        [Route("webhook")]
        [HttpGet]
        public HttpResponseMessage Get()
        {
            var response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("{\"status\":\"active\",\"service\":\"TheGenie.ai PayPal Webhook\",\"version\":\"1.0\"}")
            };
            response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            return response;
        }

        /// <summary>
        /// Receives PayPal webhook events
        /// 
        /// Expected event types:
        /// - CUSTOMER.DISPUTE.CREATED
        /// - CUSTOMER.DISPUTE.RESOLVED
        /// - CUSTOMER.DISPUTE.UPDATED
        /// - PAYMENT.CAPTURE.REFUNDED
        /// - PAYMENT.CAPTURE.DENIED
        /// - PAYMENT.CAPTURE.COMPLETED
        /// - BILLING.SUBSCRIPTION.CANCELLED
        /// - BILLING.SUBSCRIPTION.PAYMENT.FAILED
        /// - INVOICING.INVOICE.PAID
        /// - INVOICING.INVOICE.CANCELLED
        /// </summary>
        /// <param name="webhookEvent">The webhook payload from PayPal</param>
        /// <returns>200 OK to acknowledge receipt (required by PayPal)</returns>
        [Route("webhook")]
        [HttpPost]
        public HttpResponseMessage Post([FromBody] PayPalWebhookEvent webhookEvent)
        {
            var httpStatus = PayPalWebhookManager.ProcessEvent(webhookEvent);
            return new HttpResponseMessage(httpStatus);
        }
    }
}

