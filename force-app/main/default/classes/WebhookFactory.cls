/**
 * @description Factory class to process different types of webhooks
 * Uses the Factory pattern to create appropriate processors based on webhook type
 * @author Jonathan Lyles
 */
public with sharing class WebhookFactory {
    
    /**
     * @description Process a webhook based on its type
     * @param webhookType The type of webhook (e.g., "jira")
     * @param request The REST request containing the webhook payload
     */
    public static void processWebhook(String webhookType, RestRequest request) {

        Logger.info('WebhookFactory.processWebhook method invoked.');
        // Get the appropriate webhook processor
        IWebhookProcessor processor = getProcessor(webhookType);
        
        if (processor == null) {
            Logger.error('webhooktype is not supported');
            throw new WebhookException('Unsupported webhook type: ' + webhookType);
        }
        
        // Validate and process the webhook
        if (processor.validate(request)) {
            processor.process(request);
        } else {
            Logger.error('Webhook validation failed for type: ' + webhookType);
            throw new WebhookException('Webhook validation failed for type: ' + webhookType);
        }
    }
    
    /**
     * @description Get the appropriate webhook processor based on the webhook type
     * @param webhookType The type of webhook (e.g., "jira")
     * @return IWebhookProcessor The appropriate webhook processor
     */
    private static IWebhookProcessor getProcessor(String webhookType) {
        // Return the appropriate processor based on webhook type
        switch on webhookType {
            when 'jira' {
                return new JiraWebhookProcessor();
            }
            when else {
                return null;
            }
        }
    }
    
    /**
     * @description Custom exception for webhook processing errors
     */
    public class WebhookException extends Exception {}
} 