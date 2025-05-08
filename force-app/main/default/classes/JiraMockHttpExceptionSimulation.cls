@IsTest
public class JiraMockHttpExceptionSimulation implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest req){
        throw new JiraAPIException('Exception thrown');
    }
    public class JiraAPIException extends Exception{}
}