/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WebhookResourceMissingTests {

    @isTest
    static void testJiraProjectUpdatedWebhook() {
         // Create a test project record to be updated
         Jira_Project__c testProject = new Jira_Project__c(
            Project_Key__c = 'TEST',
            Project_Name__c = 'Test Project',
            Created_Date__c = Datetime.now(),
            Project_Id__c = '10008',
            Description__c = 'Test description'
        );
        
        insert testProject;

        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira project deleted payload
        String requestBody = '{' +
            '"webhookEvent": "project_updated",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10008",' +
                '"name": "new name",' +
                '"description":"new description"' +
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

        // Verify the Jira Project record was updated
        List<Jira_Project__c> projects = [SELECT Id, Project_Name__c, Project_Id__c, Description__c, Project_Key__c FROM Jira_Project__c WHERE Project_Key__c = 'TEST'];
        Assert.areEqual('new name', projects[0].Project_Name__c, 'The project name has not been updated');
        Assert.areEqual('new description', projects[0].Description__c, 'The project description has not been updated');
        Assert.areEqual('10008', projects[0].Project_Id__c, 'The project Id should be 10008. Actual: ' + projects[0].Project_Id__c);
        Assert.areEqual('TEST', projects[0].Project_Key__c, 'The project key should be test. Actual: ' + projects[0].Project_Key__c);
    }

    @isTest
    static void testJiraProjectDeletedWebhook() {
        // Create a test project record to be deleted
        Jira_Project__c testProject = new Jira_Project__c(
            Project_Key__c = 'TEST',
            Project_Name__c = 'Test Project',
            Created_Date__c = Datetime.now(),
            Project_Id__c = '10008',
            Description__c = 'Test description'
        );
        
        insert testProject;

        // Create test request
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        
        // Create a sample Jira project deleted payload
        String requestBody = '{' +
            '"webhookEvent": "project_deleted",' +
            '"project": {' +
                '"key": "TEST",' +
                '"id": "10008",' +
                '"name": "Test Project"' +
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

        // Verify the Jira Project record was deleted
        List<Jira_Project__c> projects = [SELECT Id FROM Jira_Project__c WHERE Project_Key__c = 'TEST'];
        Assert.areEqual(0, projects.size(), 'The test project should be deleted');
    }
}