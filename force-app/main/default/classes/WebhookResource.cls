/**
 * @description REST resource to handle incoming webhooks from various systems
 * Current implementation supports Jira webhooks at /webhook/jira
 * 
 * STUDENT TASK:
 * Complete the doPost method implementation to process incoming webhooks
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Student Name
 */
@RestResource(urlMapping='/webhook/*')
global without sharing class WebhookResource {
    
    /**
     * @description Handles POST requests from webhooks
     * @return Returns a simple success response
     * 
     * STUDENT TASK:
     * Implement this method to:
     * 1. Get the REST request and response objects
     * 2. Extract the webhook type from the URL path using getWebhookTypeFromPath
     * 3. Process the webhook using WebhookFactory.processWebhook
     * 4. Return an appropriate ResponseWrapper
     * 5. Add error handling using try-catch
     */
    @HttpPost
    global static ResponseWrapper doPost() {
        
        String webhookType;

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        if (req == null) {
            return new ResponseWrapper('error', 'No request found');
        }
        
        if (req.requestBody == null) {
            return new ResponseWrapper('error', 'No request body found');
        }
        
        if (req.requestURI == null) {
            return new ResponseWrapper('error', 'No request URI found');
        }   

        try {
        // Extract the webhook type from the URL path using getWebhookTypeFromPath
            webhookType = getWebhookTypeFromPath(req.requestURI);
        // Check if the webhook type is empty   
            if (String.isEmpty(webhookType)) {
                return new ResponseWrapper('error', 'No webhook type found');
            }
        // Check if the webhook type is suported
            if (!isSupportedWebhook(webhookType)) {
                return new ResponseWrapper('error', 'Unsupported webhook type');
            }
        } 
        catch (Exception e) {
            //TODO: Add logging
            return new ResponseWrapper('error', 'Error processing webhook: ' + e.getMessage());
        }
        
        // Check if the payload is valid

        try{
            JiraWebhookProcessor jwp = new JiraWebhookProcessor();
            if( jwp.validate(req) == false){
                return new ResponseWrapper('error', 'Invalid JSON payload');
            }
        }catch(Exception e){
            //TODO: something bad happened, so log it. 
            return new ResponseWrapper('error', 'Invalid JSON payload');
        }

        
        WebhookFactory.processWebhook(webhookType, req);

        return new ResponseWrapper('success', webhookType + 'Webhook received successfully');
    }
    
    /**
     * @description Extracts the webhook type from the URL path
     * @param path The request URI
     * @return The webhook type (e.g., "jira")
     */
    private static String getWebhookTypeFromPath(String path) {
        System.debug('getWebhookTypeFromPath: ' + path);
        
        Integer webhookIndex = path.indexOf('/webhook/');
        
        if (webhookIndex >= 0) {
            // Extract the part after /webhook/
            String remaining = path.substring(webhookIndex + 9);
            System.debug('remaining: ' + remaining);
            
            // If there are additional slashes, only take the first segment
            Integer nextSlash = remaining.indexOf('/');
            if (nextSlash > 0) {
                System.debug('nextSlash: ' + nextSlash);
                return remaining.substring(0, nextSlash).toLowerCase();
            }
            
            return remaining.toLowerCase();
        }
        
        return '';
    }

    /**
     * @description Checks if the webhook type is supported
     * @param webhookType The webhook type
     * @return True if the webhook type is supported, false otherwise
     */
    private static Boolean isSupportedWebhook(String webhookType) {
        List<Webhook_Type__mdt> webhookTypes = [SELECT Type_Name__c FROM Webhook_Type__mdt];
        List<String> webhookTypeList = new List<String>();
        for(Webhook_Type__mdt wt : webhookTypes) {
            webhookTypeList.add(wt.Type_Name__c);
        }
        return webhookTypeList.contains(webhookType);
    }
    
    /**
     * @description Response wrapper class for consistent response format
     */
    global class ResponseWrapper {
        public String status;
        public String message;
        
        public ResponseWrapper(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
} 