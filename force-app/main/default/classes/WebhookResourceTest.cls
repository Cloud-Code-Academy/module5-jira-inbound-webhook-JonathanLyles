/**
 * @description Test class for WebhookResource
 * @author Jonathan Lyles
 */
@IsTest
private class WebhookResourceTest {
    
    /**
     * @description Test method for Jira issue created webhook
     */
    @IsTest
    static void testJiraIssueCreatedWebhook() {
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira issue created payload
        String requestBody = '{' +
            '"webhookEvent": "jira:issue_created",' +
            '"issue": {' +
                '"key": "TEST-123",' +
                '"fields": {' +
                    '"summary": "Test issue",' +
                    '"description": "This is a test issue",' +
                    '"issuetype": {' +
                        '"name": "Bug"' +
                    '},' +
                    '"status": {' +
                        '"name": "Open"' +
                    '},' +
                    '"project": {' +
                        '"key": "TEST"' +
                    '}' +
                '}' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('success', response.status, 'Response status should be success');
        
        // Verify that the Jira issue record was created
        List<Jira_Issue__c> issues = [
            SELECT Id, Issue_Key__c, Summary__c, Description__c, Issue_Type__c, Status__c, Project_Key__c
            FROM Jira_Issue__c
            WHERE Issue_Key__c = 'TEST-123'
        ];
        
        Assert.areEqual(1, issues.size(), 'One Jira issue record should be created');
        Assert.areEqual('TEST-123', issues[0].Issue_Key__c, 'Issue key should match');
        Assert.areEqual('Test issue', issues[0].Summary__c, 'Summary should match');
        Assert.areEqual('This is a test issue', issues[0].Description__c, 'Description should match');
        Assert.areEqual('Bug', issues[0].Issue_Type__c, 'Issue type should match');
        Assert.areEqual('Open', issues[0].Status__c, 'Status should match');
        Assert.areEqual('TEST', issues[0].Project_Key__c, 'Project key should match');
    }
    
    /**
     * @description Test method for Jira issue updated webhook
     */
    @IsTest
    static void testJiraIssueUpdatedWebhook() {
        // Create a test issue record
        Jira_Issue__c testIssue = new Jira_Issue__c(
            Issue_Key__c = 'TEST-123',
            Summary__c = 'Initial Summary',
            Description__c = 'Initial Description',
            Issue_Type__c = 'Task',
            Status__c = 'To Do',
            Project_Key__c = 'TEST',
            Last_Updated__c = Datetime.now()
        );
        
        insert testIssue;
        
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira issue updated payload
        String requestBody = '{' +
            '"webhookEvent": "jira:issue_updated",' +
            '"issue": {' +
                '"key": "TEST-123",' +
                '"fields": {' +
                    '"summary": "Updated Summary",' +
                    '"description": "Updated Description",' +
                    '"issuetype": {' +
                        '"name": "Bug"' +
                    '},' +
                    '"status": {' +
                        '"name": "In Progress"' +
                    '},' +
                    '"project": {' +
                        '"key": "TEST"' +
                    '}' +
                '}' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('success', response.status, 'Response status should be success');
        
        // Verify that the Jira issue record was updated
        List<Jira_Issue__c> issues = [
            SELECT Id, Issue_Key__c, Summary__c, Description__c, Issue_Type__c, Status__c, Project_Key__c
            FROM Jira_Issue__c
            WHERE Issue_Key__c = 'TEST-123'
        ];
        
        Assert.areEqual(1, issues.size(), 'One Jira issue record should exist');
        Assert.areEqual('TEST-123', issues[0].Issue_Key__c, 'Issue key should match');
        Assert.areEqual('Updated Summary', issues[0].Summary__c, 'Summary should be updated');
        Assert.areEqual('Updated Description', issues[0].Description__c, 'Description should be updated');
        Assert.areEqual('Bug', issues[0].Issue_Type__c, 'Issue type should be updated');
        Assert.areEqual('In Progress', issues[0].Status__c, 'Status should be updated');
    }
    
    /**
     * @description Test method for Jira issue deleted webhook
     */
    @IsTest
    static void testJiraIssueDeletedWebhook() {
        // Create a test issue record
        Jira_Issue__c testIssue = new Jira_Issue__c(
            Issue_Key__c = 'TEST-123',
            Summary__c = 'Test Summary',
            Description__c = 'Test Description',
            Issue_Type__c = 'Task',
            Status__c = 'To Do',
            Project_Key__c = 'TEST',
            Last_Updated__c = Datetime.now()
        );
        
        insert testIssue;
        
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira issue deleted payload
        String requestBody = '{' +
            '"webhookEvent": "jira:issue_deleted",' +
            '"issue": {' +
                '"key": "TEST-123"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('success', response.status, 'Response status should be success');
        
        // Verify that the Jira issue record was deleted
        List<Jira_Issue__c> issues = [
            SELECT Id
            FROM Jira_Issue__c
            WHERE Issue_Key__c = 'TEST-123'
        ];
        
        Assert.areEqual(0, issues.size(), 'The Jira issue record should be deleted');
    }
    
    /**
     * @description Test method for Jira project created webhook
     */
    @IsTest
    static void testJiraProjectCreatedWebhook() {
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('success', response.status, 'Response status should be success');
        
        // Verify that the Jira project record was created
        List<Jira_Project__c> projects = [
            SELECT Id, Project_Key__c, Project_ID__c, Project_Name__c, Description__c
            FROM Jira_Project__c
            WHERE Project_Key__c = 'TEST'
        ];
        
        Assert.areEqual(1, projects.size(), 'One Jira project record should be created');
        Assert.areEqual('TEST', projects[0].Project_Key__c, 'Project key should match');
        Assert.areEqual('10000', projects[0].Project_ID__c, 'Project ID should match');
        Assert.areEqual('Test Project', projects[0].Project_Name__c, 'Project name should match');
        Assert.areEqual('This is a test project', projects[0].Description__c, 'Project description should match');
    }
    
    /**
     * @description Test method for invalid webhook type
     */
    @IsTest
    static void testInvalidWebhookType() {
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/invalid';
        req.httpMethod = 'POST';
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('error', response.status, 'Response status should be error');
        Assert.areEqual('Unsupported webhook type', response.message, 'Error message should indicate unsupported webhook type');
    }
    
    /**
     * @description Test method for invalid JSON payload
     */
    @IsTest
    static void testInvalidJsonPayload() {
        // Create test request with invalid JSON
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"invalid JSON');
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('error', response.status, 'Response status should be error');
    }

    //Extra tests by Jonathan Lyles
    @IsTest
    static void testNullRestRequest(){

        RestRequest request;

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areEqual('error', response.status, 'Response status should be error');
        Assert.areEqual('No request found', response.message, 'Expected message: No request found. Actual message: ' + response.message);
    }   
    @IsTest
    static void testNullRestRequestBody(){

        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areEqual('error', response.status, 'Response status should be error');
        Assert.areEqual('No request body found', response.message, 'Expected message: No request body found. Actual message: ' + response.message);
    }

    @IsTest
    static void testNullRequestURI(){
        RestRequest req = new RestRequest();
        req.requestURI = null;
        req.httpMethod = 'POST';
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areEqual('error', response.status, 'Response status should be error');
        Assert.areEqual('No request URI found', response.message, 'Expected message: No request URI found. Actual message: ' + response.message);
    }

    @IsTest
    static void testWebhookTypeNotFound(){
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook';
        req.httpMethod = 'POST';
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areEqual('error', response.status, 'Response status should be error');
        Assert.areEqual('No webhook type found', response.message, 'Expected message: No webhook type found. Actual message: ' + response.message);
    }

    @IsTest
    static void testPathWithExtraSegments(){
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira/extrastuff';
        req.httpMethod = 'POST';
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areNotEqual('error', response.status, 'Response status should not be error.');
        Assert.areNotEqual('Unsupported webhook type', response.message, 'Response message should not be an error message. Message received: ' + response.message);
    }

    @IsTest
    static void testValidWebhookType() {
        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        // Create a sample Jira project created payload
        String requestBody = '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
        
        req.requestBody = Blob.valueOf(requestBody);
        
        // Set the request and response
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Call the REST resource
        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();
        
        // Assert the response
        Assert.areEqual('success', response.status, 'Response status should be success');
    }   

    //Helper methods for common logic

    private static RestRequest createRestRequest(String requestURI, String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = requestURI;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        return req;
    }

    private static String getProjectCreatedRequestBody() {
        return '{' +
            '"webhookEvent": "project_created",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10000",' +
                '"name": "Test Project",' +
                '"description": "This is a test project"' +
            '}' +
        '}';
    }

    private static String getIssueCreatedRequestBody() {
        return '{' +
            '"webhookEvent": "jira:issue_created",' +
            '"issue": {' +
                '"key": "TEST-123",' +
                '"fields": {' +
                    '"summary": "Test issue",' +
                    '"description": "This is a test issue",' +
                    '"issuetype": {' +
                        '"name": "Bug"' +
                    '},' +
                    '"status": {' +
                        '"name": "Open"' +
                    '},' +
                    '"project": {' +
                        '"key": "TEST"' +
                    '}' +
                '}' +
            '}' +
        '}';
    }
} 