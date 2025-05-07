@IsTest
public with sharing class JiraWebhookProcessorTest {
    @isTest
    static void validateTrueTest(){
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(('{"webhookEvent":"jira:issue_created"}'));

        JiraWebhookProcessor processor = new JiraWebhookProcessor();

        Test.startTest();
        try{
            Boolean result = processor.validate(request);
            if (result == true) { 
                System.assert(true,'Pass: Expected result: true. Actual result: ' + result);
            } else {
                throw new JiraWebhookProcessorTestException('Expected result: true. Actual result: ' + result);
            }
        } catch (JiraWebhookProcessorTestException e){
            System.assert(false, e.getMessage());
        }
        
    }

    @IsTest
    static void validateFailRequestNull(){
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(('{"webhookEvent":"jira:issue_created"}'));

        JiraWebhookProcessor processor = new JiraWebhookProcessor();

        Test.startTest();
        try{
            request = null;
            Boolean result = processor.validate(request);
            System.assert(false, 'NullPointerException expected if request is null');
        } catch (NullPointerException e){
            System.assert(true, 'NullPointerException expected if request is null'); 
        }    
    } 
    public class JiraWebhookProcessorTestException extends Exception{}

}