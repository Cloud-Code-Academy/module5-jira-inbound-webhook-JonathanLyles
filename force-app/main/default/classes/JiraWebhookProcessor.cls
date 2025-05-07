/**
 * @description Processor for Jira webhooks
 * Handles issue and project events from Jira
 * 
 * STUDENT TASK:
 * Implement the IWebhookProcessor interface to handle Jira webhook events
 * You'll need to process various events like issue/project creation, updates, and deletions
 * 
 * IMPORTANT NOTE: without sharing is used to avoid sharing issues with the Jira_Issue__c and Jira_Project__c objects but it is not a good practice
 * 
 * @author Jonathan Lyles
 */
public without sharing class JiraWebhookProcessor implements IWebhookProcessor {
    
    // Constants for webhook event types
    private static final String EVENT_ISSUE_CREATED = 'jira:issue_created';
    private static final String EVENT_ISSUE_UPDATED = 'jira:issue_updated';
    private static final String EVENT_ISSUE_DELETED = 'jira:issue_deleted';
    private static final String EVENT_PROJECT_CREATED = 'project_created';
    private static final String EVENT_PROJECT_UPDATED = 'project_updated';
    private static final String EVENT_PROJECT_DELETED = 'project_deleted';
    
    /**
     * @description Validates the incoming Jira webhook request
     * @param request The REST request containing the webhook payload
     * @return Boolean True if the request is valid, false otherwise
     * 
     * STUDENT TASK:
     * Implement validation logic for Jira webhooks
     * - Check for valid JSON by deserializing the request body
     * - Verify the 'webhookEvent' field exists in the payload
     * - You can add further validation like checking for specific headers
     * - Return true if valid, false otherwise
     * 
     * HINT:
     * 1. Use try-catch to handle JSON deserialization errors
     * 2. Cast the deserialized JSON to Map<String, Object>
     * 3. Check if required keys exist using containsKey()
     * 4. Example: if (!payload.containsKey('webhookEvent')) { return false; }
     */
    public Boolean validate(RestRequest request) {

        // Guard clause: Ensure request or requestBody is not null
        if (request == null || request.requestBody == null) {
            Logger.error(
            'Request or requestBody is null' +
            'request contents: ' + request +
            'requestBody contents: ' + request.requestBody
            );
            return false;
        }
        
        try {
            String requestBody = request.requestBody.toString();
            
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            // Guard clause: Ensure webhookEvent is not null
            if (!payload.containsKey('webhookEvent')) {
                Logger.error('webhookEvent is null');
                return false;
            }

            return true;      

        } catch (Exception e) {
            // Log the error and return false
            Logger.error('Error validating webhook: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Processes the Jira webhook request
     * @param request The REST request containing the webhook payload
     * 
     * STUDENT TASK:
     * Implement the main processing logic
     * - Parse the JSON payload from the request body
     * - Extract the 'webhookEvent' field to determine the event type
     * - Call the appropriate handler method based on the event type
     * 
     * HINT:
     * 1. Use JSON.deserializeUntyped() to convert the request body to a Map
     * 2. Extract the event type: String webhookEvent = (String) payload.get('webhookEvent');
     * 3. Use if/else or switch statements to call the appropriate handler
     * 4. Example: if (webhookEvent == EVENT_ISSUE_CREATED) { processIssueCreated(payload); }
     */
    public void process(RestRequest request) {
        // Guard clause to ensure the request or requestBody is not null
        if(request == null || request.requestBody == null){
            Logger.error(
                'Request or requestBody is null' +
                'request contents: ' + request +
                'requestBody contents: ' + request.requestBody
                );
            throw new JiraWebhookProcessorException('Error: request or requestBody is null');
        }
        try {
            String requestBody = request.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Guard clause: check if webhookEvent exists or is null
            String webhookEvent = (String) payload.get('webhookEvent');
            if (String.isEmpty(webhookEvent)) {
                Logger.error('webhookEvent is null');
                throw new JiraWebhookProcessorException('Error: webhookEvent is missing or empty.');
            }

            if (webhookEvent == EVENT_ISSUE_CREATED) {
                processIssueCreated(payload);
            } else if (webhookEvent == EVENT_ISSUE_UPDATED) {
                processIssueUpdated(payload);
            } else if (webhookEvent == EVENT_ISSUE_DELETED) {
                processIssueDeleted(payload);
            } else if (webhookEvent == EVENT_PROJECT_CREATED) {
                processProjectCreated(payload);
            } else if (webhookEvent == EVENT_PROJECT_UPDATED) {
                processProjectUpdated(payload);
            } else if (webhookEvent == EVENT_PROJECT_DELETED) {
                processProjectDeleted(payload);
            } else {
                System.debug(LoggingLevel.ERROR, 'Unknown webhook event: ' + webhookEvent);
            }            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error processing webhook: ' + e.getMessage());
            throw e; // Re-throw to let the caller handle it
            //TODO: Re-throw
        }
    }
    
    /**
     * @description Process an issue_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Use this example as a template for other event handlers
     */
    private void processIssueCreated(Map<String, Object> payload) {

        // Guard clause: ensure payload or issue are not empty
        try{
            if( payload == null || payload.get('issue') == null){
                Logger.error('NullPointerException should be thrown');
                throw new JiraWebhookProcessorException('Error: payload or payload.issue is null');
            }
        }catch(JiraWebhookProcessorException e) {
            Logger.error(e.getMessage());
        }
        try {
            // 1. Extract issue data from the payload
            Map<String, Object> issueData = (Map<String, Object>) payload.get('issue');
            
            // 2. Create a new Jira_Issue__c record using the helper method
            Jira_Issue__c newIssue = createIssueRecord(issueData);
        
            // 3. Insert the new record
            insert newIssue;
            
            // 4. Log success
            Logger.info('Created Jira issue record: ' + newIssue.Id);
            
        } catch (Exception e) {
            Logger.error('Error processing issue_created event: ' + e.getMessage());
            //todo review throwing
            throw e;
        }
    }
    
    /**
     * @description Process an issue_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Issue__c record
     * If the record doesn't exist, create it
     */
    private void processIssueUpdated(Map<String, Object> payload) {
        
        // Guard clause: ensure payload or issue are not empty
        if( payload == null || payload.get('issue') == null){
            Logger.error(
                'Payload or issue is null' +
                'Payload contents: ' + payload +
                'Issue contents: ' + payload.get('issue')
                );
        
        throw new JiraWebhookProcessorException('Error: payload or payload.issue is null');
        }


        //Get the Salesforce Jira_Issue__c record from the issue key in the payload
        Map<String, Object> issueMap = (Map<String, Object>) payload.get('issue');

        // Guard clause: ensure issueMap is not null or empty
        if (issueMap == null) {
            Logger.error('issueMap is null');
            throw new JiraWebhookProcessorException('Error: issue data is missing in the payload.');
        }

        String issueKey = (String) issueMap.get('key');

        //Guard clause: ensure issueKey is not null or empty
        if (String.isEmpty(issueKey)) {
            Logger.error('issueKey is empty');
            throw new JiraWebhookProcessorException('Error: issue key is missing.');
        }

        Jira_Issue__c existingIssue = [SELECT Id, Description__c, Issue_Key__c, Issue_Type__c, Last_Updated__c, Project_Key__c, Status__c, Summary__c FROM Jira_Issue__c WHERE Issue_Key__c = :issueKey LIMIT 1];
        Jira_Issue__c updatedIssue = updateIssueRecord(existingIssue, payload);
        update updatedIssue;       
    }
    
    /**
     * @description Process an issue_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Issue__c record
     */
    private void processIssueDeleted(Map<String, Object> payload) {
        // TODO: Implement issue deletion logic
        Map<String, Object> issueMap = (Map<String, Object>) payload.get('issue');

        // Guard clause to ensure issueMap is not null 
        if (issueMap == null) {
            Logger.error('issueMap is null');
            throw new JiraWebhookProcessorException('Error: issue data is missing in the payload.');
        }

        String doomedIssueKey = (String) issueMap.get('key');
        
        // Guard clause to ensure doomedIssueKey is not missing
        if (String.isEmpty(doomedIssueKey)) {
            Logger.error('doomedIssueKey is missing');
            throw new JiraWebhookProcessorException('Error: issue key is missing.');
        }

        Jira_Issue__c doomedIssue = [SELECT Id FROM Jira_Issue__c WHERE Issue_Key__c = :doomedIssueKey];
        try{
            delete doomedIssue;
        }catch(DmlException e){
            Logger.error('DmlException: ' + e.getMessage());
        }
    }
    
    /**
     * @description Process a project_created event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to create a Jira_Project__c record
     */
    private void processProjectCreated(Map<String, Object> payload) {
        
        // Guard clause: ensure payload or issue are not empty
        if( payload == null || payload.get('project') == null){
            Logger.error('Payload or project is null');
            throw new JiraWebhookProcessorException('Error: payload or payload.project is null');
        }

        if(payload != null){
            Map<String, Object> projectData = (Map<String, Object>) payload.get('project');
            Jira_Project__c newProject = createProjectRecord(projectData);
            Logger.info('new project successfully created: ' + newProject.Id);
        }



            
    }
    
    /**
     * @description Process a project_updated event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to update an existing Jira_Project__c record
     * If the record doesn't exist, create it
     */
    private void processProjectUpdated(Map<String, Object> payload) {
        //TODO: some of the logic belongs in updateProjectRecord()
        if(payload != null){
            Logger.error('Payload is null');
            Map<String, Object> projectMap = (Map<String, Object>) payload.get('project');

            //Guard clause: Ensure projectMap is not null
            if (projectMap == null) {
                Logger.error('projectMap is null');
                throw new JiraWebhookProcessorException('Error: project data is missing in the payload.');
            }

            String projectKey = (String) projectMap.get('key');

            //Guard clause: Ensure projectKey is not missing
            if (String.isEmpty(projectKey)) {
                Logger.error('projectKey is missing');
                throw new JiraWebhookProcessorException('Error: project key is missing.');
            }
            Jira_Project__c existingProject = [SELECT Id, Project_Name__c, Project_Id__c, Project_Key__c, Description__c FROM Jira_Project__c WHERE Project_Key__c = :projectKey LIMIT 1];
            Jira_Project__c updatedProject = new Jira_Project__c();    

            updatedProject.Id = existingProject.Id;
            updatedProject.Project_Name__c = (String) projectMap.get('name');
            updatedProject.Project_Id__c = (String) projectMap.get('id');
            updatedProject.Project_Key__c = (String) projectMap.get('key');
            updatedProject.Description__c = (String) projectMap.get('description');            
            
            update updatedProject;
            Logger.info('Project successfully updated: ' + updatedProject.Id);

        }
    }
    
    /**
     * @description Process a project_deleted event
     * @param payload The webhook payload
     * 
     * STUDENT TASK:
     * Implement logic to delete a Jira_Project__c record
     */
    private void processProjectDeleted(Map<String, Object> payload) {

          // Guard clause: ensure payload or issue are not empty
          if( payload == null || payload.get('project') == null){
            Logger.error('payload or project is empty');
            throw new JiraWebhookProcessorException('Error: payload or payload.project is null');
        }
        Map<String, Object> projectMap = (Map<String, Object>) payload.get('project');
        if (projectMap == null) {
            Logger.error('projectMap is null');
            throw new JiraWebhookProcessorException('Error: project data is missing in the payload.');
        }
        String projectKey = (String) projectMap.get('key');
        if (String.isEmpty(projectKey)) {
            Logger.error('projectKey is empty');
            throw new JiraWebhookProcessorException('Error: project key is missing.');
        }
        Jira_Project__c doomedProject = [SELECT Id FROM Jira_Project__c WHERE Project_Key__c = :projectKey];
        try{
            delete doomedProject;
        }catch(DmlException e){
            Logger.error('DmlException while deleting doomedProject. ' + e.getMessage());
        }
    }
    
    /**
     * @description Create a Jira_Issue__c record from issue data
     * @param issueData The issue data from the webhook
     * @return Jira_Issue__c The newly created issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and create a record
     * 
     * HINT:
     * 1. Extract data from the issueData map (key, summary, status, etc.)
     * 2. Map the fields to a new Jira_Issue__c record
     */
    private Jira_Issue__c createIssueRecord(Map<String, Object> issueData) {

        // Guard clause: ensure payload or issue are not empty
        if( issueData == null || issueData.get('fields') == null){
            Logger.error('issueData or fields is null');
            throw new JiraWebhookProcessorException('Error: issueData or issueData.fields is null');
        }

        Map<String,Object> fieldsMap = (Map<String, Object>) issueData.get('fields');
        if (fieldsMap == null) {
            Logger.error('fieldsMap is null');
            throw new JiraWebhookProcessorException('Error: fields data is missing in the issue data.');
        }
        Map<String,Object> issueTypeMap = (Map<String, Object>) fieldsMap.get('issuetype');
        if (issueTypeMap == null) {
            Logger.error('issueTypeMap is null');
            throw new JiraWebhookProcessorException('Error: issue type data is missing.');
        }
        Map<String,Object> projectMap = (Map<String, Object>) fieldsMap.get('project');
        if (projectMap == null) {
            Logger.error('projectMap is null');
            throw new JiraWebhookProcessorException('Error: project data is missing.');
        }
        Map<String,Object> statusMap = (Map<String, Object>) fieldsMap.get('status');
        if (statusMap == null) {
            Logger.error('statusMap is null');
            throw new JiraWebhookProcessorException('Error: status data is missing.');
        }
        Jira_Issue__c newIssueRecord = new Jira_Issue__c();
        newIssueRecord.description__c = (String) fieldsMap.get('description');
        newIssueRecord.Issue_Key__c = (String) issueData.get('key');
        newIssueRecord.Issue_Type__c = (String) issueTypeMap.get('name');
        newIssueRecord.Last_Updated__c = Datetime.now();
        newIssueRecord.Project_Key__c = (String) projectMap.get('key');
        newIssueRecord.Status__c = (String) statusMap.get('name');
        newIssueRecord.Summary__c = (String) fieldsMap.get('summary');

        return newIssueRecord;
    }
    
    /**
     * @description Update a Jira_Issue__c record from issue data
     * @param existingIssue The existing issue record
     * @param issueData The updated issue data from the webhook
     * @return Jira_Issue__c The updated issue record
     * 
     * STUDENT TASK:
     * Implement logic to extract issue fields and update a record
     */
    private Jira_Issue__c updateIssueRecord(Jira_Issue__c existingIssue, Map<String, Object> issueData) {
        
        // TODO: Implement issue record update logic
        // TODO: Create a new method to create the issue maps? Because this part is repeating
        Map<String,Object> issueMap = (Map<String, Object>) issueData.get('issue');
        Map<String,Object> fieldsMap = (Map<String, Object>) issueMap.get('fields');
        if (fieldsMap == null) {
            Logger.error('fieldsMap is null');
            throw new JiraWebhookProcessorException('Error: fields data is missing in the issue data.');
        }
        Map<String,Object> issueTypeMap = (Map<String, Object>) fieldsMap.get('issuetype');
        if (issueTypeMap == null) {
            Logger.error('issueTypeMap is null');
            throw new JiraWebhookProcessorException('Error: issue type data is missing.');
        }
        Map<String,Object> projectMap = (Map<String, Object>) fieldsMap.get('project');
        if (projectMap == null) {
            Logger.error('projectMap is null');
            throw new JiraWebhookProcessorException('Error: project data is missing.');
        }
        Map<String,Object> statusMap = (Map<String, Object>) fieldsMap.get('status');
        if (statusMap == null) {
            Logger.error('statusMap is null');
            throw new JiraWebhookProcessorException('Error: status data is missing.');
        }
        
        Jira_Issue__c updatedIssueRecord = new Jira_Issue__c();
        updatedIssueRecord.Id = existingIssue.Id;
        System.debug(updatedIssueRecord);
        System.debug('updatedIssueRecord: ' + updatedIssueRecord);
        updatedIssueRecord.description__c = (String) fieldsMap.get('description');
        updatedIssueRecord.Issue_Key__c = (String) issueMap.get('key');
        updatedIssueRecord.Issue_Type__c = (String) issueTypeMap.get('name');
        updatedIssueRecord.Last_Updated__c = Datetime.now();
        updatedIssueRecord.Project_Key__c = (String) projectMap.get('key');
        updatedIssueRecord.Status__c = (String) statusMap.get('name');
        updatedIssueRecord.Summary__c = (String) fieldsMap.get('summary');

        return updatedIssueRecord;
    }
    
    /**
     * @description Create a Jira_Project__c record from project data
     * @param projectData The project data from the webhook
     * @return Jira_Project__c The newly created project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and create a record
     */
    private Jira_Project__c createProjectRecord(Map<String, Object> projectData) {
        
            Jira_Project__c newProject = new Jira_Project__c();    
        
            newProject.Project_Name__c = (String) projectData.get('name');

            newProject.Created_Date__c = Datetime.now();

            newProject.Project_Id__c = (String) projectData.get('id');

            newProject.Project_Key__c = (String) projectData.get('key');

            newProject.Description__c = (String) projectData.get('description');

            insert newProject;
            
        return newProject;
    }
    
    /**
     * @description Update a Jira_Project__c record from project data
     * @param existingProject The existing project record
     * @param projectData The updated project data from the webhook
     * @return Jira_Project__c The updated project record
     * 
     * STUDENT TASK:
     * Implement logic to extract project fields and update a record
     */
    private Jira_Project__c updateProjectRecord(Jira_Project__c existingProject, Map<String, Object> projectData) {
        // TODO: Implement project record update logic
        return existingProject;
    }

    public class JiraWebhookProcessorException extends Exception{}
} 