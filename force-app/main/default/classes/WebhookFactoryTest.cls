@IsTest
private class WebhookFactoryTest {
    
    @IsTest
    static void processWebhookValidWebhookTypeTest(){
        String webhookType = 'jira';
        RestRequest request = new RestRequest();
        request.requestURI = '/webhook/jira';
        request.httpMethod = 'POST';
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
        request.requestBody = Blob.valueOf(requestBody);
        Test.startTest();
        try{
            WebhookFactory.processWebhook(webhookType, request);
            // If no exception is thrown, pass the test
            System.assert(true, 'Test passed');
        }catch(WebhookFactory.WebhookException e){
            // If an exception is thrown, fail the test
            System.assert(false,'Test failed. Message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void processWebhookInvalidWebhookTypeTest(){
        String webhookType = 'invalid';
        RestRequest request = new RestRequest();
        request.requestURI = '/webhook/invalid';
        request.httpMethod = 'POST';
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
        request.requestBody = Blob.valueOf(requestBody);
        Test.startTest();
        try{
            WebhookFactory.processWebhook(webhookType, request);
            // If no exception is thrown, fail the test
            System.assert(false, 'Expected WebhookException was not thrown');
        }catch(WebhookFactory.WebhookException e){
             // Assert the exception message
        System.assertEquals('Unsupported webhook type: invalid', e.getMessage(), 'Exception message should indicate unsupported webhook type');
        }
        Test.stopTest();
        
    }

    @IsTest
    static void processWebhookValidationFailedTest(){
        String webhookType = 'jira';
        RestRequest request = new RestRequest();
        request.requestURI = '/webhook/jira';
        request.httpMethod = 'POST';
        // Create a sample Jira issue created payload
        String requestBody = '{invalid Json';
        request.requestBody = Blob.valueOf(requestBody);
        Test.startTest();
        try{
            WebhookFactory.processWebhook(webhookType, request);
            // If no exception is thrown, pass the test
            System.assert(false, 'Expected WebhookException was not thrown');
        }catch(WebhookFactory.WebhookException e){
            // If an exception is thrown, fail the test
            System.assert(true, 'Validation for webhookType: ' + webhookType + ' correct failed with an invalid body'); 
        }
        Test.stopTest();

    }
}