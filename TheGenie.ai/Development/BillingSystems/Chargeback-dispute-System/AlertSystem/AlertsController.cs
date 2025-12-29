using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Newtonsoft.Json.Linq;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace Smart.Dashboard.Controllers
{
    /// <summary>
    /// SMS Alert System - Azure DevOps Webhook Handler
    /// Receives notifications from Azure DevOps Service Hooks and sends SMS via Twilio
    /// 
    /// Created: 12/29/2025
    /// Author: AI Agent / Steve Hundley
    /// </summary>
    public class AlertsController : ApiController
    {
        // Twilio Configuration (from Master Credential Tracker)
        private const string TwilioAccountSid = "[TWILIO_ACCOUNT_SID - See Master Credential Tracker]";
        private const string TwilioAuthToken = "[TWILIO_AUTH_TOKEN - See Master Credential Tracker]";
        private const string TwilioFromPhone = "+16193043643";
        
        // Recipients (TODO: Move to database for UI configuration)
        private static readonly string[] AlertRecipients = new string[]
        {
            "+16195074404"  // Steve Hundley
        };

        // Alert Configuration (TODO: Move to database for UI configuration)
        private static readonly bool EnableProductionApprovalAlerts = true;
        private static readonly bool EnableBuildFailedAlerts = true;
        private static readonly bool EnableDeploymentFailedAlerts = true;
        private static readonly bool EnableDeploymentSucceededAlerts = false;
        private static readonly bool EnableCheckInAlerts = false;

        /// <summary>
        /// Health check endpoint
        /// GET /api/alerts/devops
        /// </summary>
        [Route("api/alerts/devops")]
        [HttpGet]
        public HttpResponseMessage Get()
        {
            var response = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent("{\"status\":\"active\",\"service\":\"TheGenie.ai SMS Alert System\",\"version\":\"1.0\"}")
            };
            response.Content.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/json");
            return response;
        }

        /// <summary>
        /// Azure DevOps Service Hook Webhook Handler
        /// POST /api/alerts/devops
        /// </summary>
        [Route("api/alerts/devops")]
        [HttpPost]
        public HttpResponseMessage Post([FromBody] JObject payload)
        {
            try
            {
                if (payload == null)
                {
                    LogAlert("Received null payload");
                    return new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                var eventType = payload["eventType"]?.ToString() ?? "";
                LogAlert($"Received event: {eventType}");

                string message = null;

                // Route based on event type
                switch (eventType)
                {
                    case "ms.vss-release.deployment-approval-pending-event":
                        if (EnableProductionApprovalAlerts)
                        {
                            message = BuildApprovalPendingMessage(payload);
                        }
                        break;

                    case "build.complete":
                        var buildStatus = payload["resource"]?["status"]?.ToString() ?? "";
                        if (buildStatus == "failed" && EnableBuildFailedAlerts)
                        {
                            message = BuildBuildFailedMessage(payload);
                        }
                        break;

                    case "ms.vss-release.deployment-completed-event":
                        var deploymentStatus = payload["resource"]?["environment"]?["status"]?.ToString() ?? "";
                        if (deploymentStatus == "failed" && EnableDeploymentFailedAlerts)
                        {
                            message = BuildDeploymentFailedMessage(payload);
                        }
                        else if (deploymentStatus == "succeeded" && EnableDeploymentSucceededAlerts)
                        {
                            message = BuildDeploymentSucceededMessage(payload);
                        }
                        break;

                    case "tfvc.checkin":
                        if (EnableCheckInAlerts)
                        {
                            message = BuildCheckInMessage(payload);
                        }
                        break;

                    default:
                        LogAlert($"Unhandled event type: {eventType}");
                        break;
                }

                // Send SMS if message was generated
                if (!string.IsNullOrEmpty(message))
                {
                    SendSmsToAllRecipients(message);
                }

                return new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                LogAlert($"Error processing webhook: {ex.Message}");
                return new HttpResponseMessage(HttpStatusCode.OK); // Return OK to prevent retries
            }
        }

        #region Message Builders

        private string BuildApprovalPendingMessage(JObject payload)
        {
            try
            {
                var releaseName = payload["resource"]?["release"]?["name"]?.ToString() ?? "Unknown";
                var stageName = payload["resource"]?["environment"]?["name"]?.ToString() ?? "Unknown";
                var approvalUrl = payload["resource"]?["approval"]?["approvalUrl"]?.ToString() ?? "";

                return $"🚨 PROD APPROVAL NEEDED\n\n" +
                       $"Release: {releaseName}\n" +
                       $"Stage: {stageName}\n\n" +
                       $"Approve: {approvalUrl}";
            }
            catch
            {
                return "🚨 Production deployment needs your approval! Check Azure DevOps.";
            }
        }

        private string BuildBuildFailedMessage(JObject payload)
        {
            try
            {
                var buildNumber = payload["resource"]?["buildNumber"]?.ToString() ?? "Unknown";
                var definition = payload["resource"]?["definition"]?["name"]?.ToString() ?? "Unknown";
                var reason = payload["resource"]?["reason"]?.ToString() ?? "";

                return $"❌ BUILD FAILED\n\n" +
                       $"Build: {buildNumber}\n" +
                       $"Pipeline: {definition}\n" +
                       $"Reason: {reason}";
            }
            catch
            {
                return "❌ Build failed! Check Azure DevOps.";
            }
        }

        private string BuildDeploymentFailedMessage(JObject payload)
        {
            try
            {
                var releaseName = payload["resource"]?["environment"]?["release"]?["name"]?.ToString() ?? "Unknown";
                var stageName = payload["resource"]?["environment"]?["name"]?.ToString() ?? "Unknown";

                return $"❌ DEPLOYMENT FAILED\n\n" +
                       $"Release: {releaseName}\n" +
                       $"Stage: {stageName}";
            }
            catch
            {
                return "❌ Deployment failed! Check Azure DevOps.";
            }
        }

        private string BuildDeploymentSucceededMessage(JObject payload)
        {
            try
            {
                var releaseName = payload["resource"]?["environment"]?["release"]?["name"]?.ToString() ?? "Unknown";
                var stageName = payload["resource"]?["environment"]?["name"]?.ToString() ?? "Unknown";

                return $"✅ DEPLOYED\n\n" +
                       $"Release: {releaseName}\n" +
                       $"Stage: {stageName}";
            }
            catch
            {
                return "✅ Deployment succeeded!";
            }
        }

        private string BuildCheckInMessage(JObject payload)
        {
            try
            {
                var author = payload["resource"]?["author"]?["displayName"]?.ToString() ?? "Unknown";
                var comment = payload["resource"]?["comment"]?.ToString() ?? "";
                if (comment.Length > 50) comment = comment.Substring(0, 47) + "...";

                return $"📝 CODE CHECK-IN\n\n" +
                       $"By: {author}\n" +
                       $"Comment: {comment}";
            }
            catch
            {
                return "📝 New code checked in.";
            }
        }

        #endregion

        #region SMS Sending

        private void SendSmsToAllRecipients(string message)
        {
            if (AlertRecipients == null || AlertRecipients.Length == 0)
            {
                LogAlert("No recipients configured - SMS not sent");
                return;
            }

            try
            {
                TwilioClient.Init(TwilioAccountSid, TwilioAuthToken);

                foreach (var recipient in AlertRecipients)
                {
                    if (string.IsNullOrEmpty(recipient)) continue;

                    try
                    {
                        var smsMessage = MessageResource.Create(
                            body: message,
                            from: new PhoneNumber(TwilioFromPhone),
                            to: new PhoneNumber(recipient)
                        );

                        LogAlert($"SMS sent to {recipient}: SID={smsMessage.Sid}");
                    }
                    catch (Exception ex)
                    {
                        LogAlert($"Failed to send SMS to {recipient}: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                LogAlert($"Twilio init failed: {ex.Message}");
            }
        }

        private void LogAlert(string message)
        {
            // TODO: Replace with proper logging (Logger.Log or database)
            System.Diagnostics.Debug.WriteLine($"[SMS Alert] {DateTime.Now}: {message}");
        }

        #endregion
    }
}


