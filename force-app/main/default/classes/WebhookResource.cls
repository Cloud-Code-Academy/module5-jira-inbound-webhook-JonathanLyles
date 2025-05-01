/**
 * @description REST resource to handle incoming webhooks from various systems
 * Current implementation supports Jira webhooks at /webhook/jira
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Jonathan
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

        Logger.info('doPost method invoked');
        
        String webhookType;

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        if (req == null) {
            Logger.error('Request object is null.');
            return new ResponseWrapper('error', 'No request found');
        }
        
        if (req.requestBody == null) {
            Logger.error('Request body is null.');
            return new ResponseWrapper('error', 'No request body found');
        }
        
        if (req.requestURI == null) {
            Logger.error('Request URI is null.');
            return new ResponseWrapper('error', 'No request URI found');
        }   

        try {
        // Extract the webhook type from the URL path using getWebhookTypeFromPath
            webhookType = getWebhookTypeFromPath(req.requestURI);
            Logger.info('Extracted webhook type: ' + webhookType);
        // Check if the webhook type is empty   
            if (String.isEmpty(webhookType)) {
                Logger.error('No webhook type found');
                return new ResponseWrapper('error', 'No webhook type found');
            }
        // Check if the webhook type is suported
            if (!isSupportedWebhook(webhookType)) {
                Logger.error('Unsupported webhook type');
                return new ResponseWrapper('error', 'Unsupported webhook type');
            }
        } 
        catch (Exception e) {
            Logger.error('Error processing webhook type: ' + e.getMessage());
            return new ResponseWrapper('error', 'Error processing webhook: ' + e.getMessage());
        }
        
        // Check if the payload is valid

        try{
            JiraWebhookProcessor jwp = new JiraWebhookProcessor();
            if( jwp.validate(req) == false){
                Logger.error('Invalid JSON payload in the request');
                return new ResponseWrapper('error', 'Invalid JSON payload');
            }
        }catch(Exception e){
            Logger.error(e.getMessage());
            return new ResponseWrapper('error', 'Invalid JSON payload');
        }


        WebhookFactory.processWebhook(webhookType, req);
        Logger.info(webhookType + 'Webhook received successfully');
        return new ResponseWrapper('success', webhookType + 'Webhook received successfully');
    }
    
    /**
     * @description Extracts the webhook type from the URL path
     * @param path The request URI
     * @return The webhook type (e.g., "jira")
     */
    private static String getWebhookTypeFromPath(String path) {
        Logger.info('getWebhookTypeFromPath method invoked. Parameter: ' + path);
        
        Integer webhookIndex = path.indexOf('/webhook/');
        
        if (webhookIndex >= 0) {
            // Extract the part after /webhook/
            String remaining = path.substring(webhookIndex + 9);
            Logger.info('The path after webhook/ and before the next /');
            
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
        Logger.info('isSupportedWebhook method invoked. Parameter received: ' + webhookType);
        List<Webhook_Type__mdt> webhookTypes = [SELECT Type_Name__c FROM Webhook_Type__mdt];
        List<String> webhookTypeList = new List<String>();
        for(Webhook_Type__mdt wt : webhookTypes) {
            webhookTypeList.add(wt.Type_Name__c);
        }
        Logger.info(webhookType + ' is a supported webhook: ' + webhookTypeList.contains(webhookType));
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