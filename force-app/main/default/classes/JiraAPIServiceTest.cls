@IsTest
private class JiraAPIServiceTest {

    @IsTest
    static void createProjectSuccessTest(){
        // Create a valide projectWrapper to pass into the method
        JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper('Test Name', 'KEY', 'Test project description');
        
        Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator(true, true,'KEY'));

        Test.startTest();
        String projectId = JiraAPIService.createProject(projectWrapper);
        Test.stopTest();

        Assert.areEqual('10011', projectId, 'Expected projectId: 10011. Actual projectId: ' + projectId);

    }

    @IsTest
    static void createProjectNullProjectWrapper(){
        String projectId;
        // Create a null project wrapper and pass it into createProject();
        JiraWrapper.ProjectWrapper projectWrapper = null;

        Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator(true, true));

        Test.startTest();
        Try{    
            projectId = JiraAPIService.createProject(projectWrapper);
            System.assert(false, 'Expected an exception.');
        }catch(NullPointerException e){
            System.assert(true, 'NullPointerException was correctly thrown');
        }
        Test.stopTest();

        Assert.areEqual(null, projectId, 'Expected projectId to be null when projectWrapper is null');
        
    }

    @IsTest
    static void createProjectIsFailure(){
        String projectId;
        // Create a null project wrapper and pass it into createProject();
        JiraWrapper.ProjectWrapper projectWrapper = new JiraWrapper.ProjectWrapper('Test Name', 'KEY', 'Test project description');

        Test.setMock(HttpCalloutMock.class, new JiraMockHttpResponseGenerator(false, true));

        Test.startTest();
        try{    
            projectId = JiraAPIService.createProject(projectWrapper);
        }catch(Exception e){
            System.assert(false, 'Exception ' + e.getMessage());
        }
        Test.stopTest();

        //projectId should be null
        Assert.areEqual(null, projectId, 'Expected projectId to be null when projectWrapper is null');
    }

    @IsTest
    static void createIssueSuccessTest(){
        
    }
}