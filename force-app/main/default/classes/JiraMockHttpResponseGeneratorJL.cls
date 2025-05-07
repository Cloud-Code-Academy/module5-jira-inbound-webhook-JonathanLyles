public with sharing class JiraMockHttpResponseGeneratorJL implements HttpCalloutMock{
    private static final String MOCK_PROJECT_ID = '10022';
	private static final String MOCK_ISSUE_KEY = 'JL-24';

	private Boolean isSuccess;
	private Boolean isProject;
	private String projectKey;
    private Boolean isBodyNull;

/**
* Constructor
* @param isSuccess Whether to simulate a successful response
* @param isProject Whether to simulate a project or issue API call
*/
	public JiraMockHttpResponseGeneratorJL(Boolean isSuccess, Boolean isProject) {
		this(isSuccess, isProject);
    }

/**
* Constructor with isBodyNull 
* @param isSuccess Whether to simulate a successful response
* @param isProject Whether to simulate a project or issue API call
* @param isBodyNull Whether to simulate an empty response body
*/
	public JiraMockHttpResponseGeneratorJL(Boolean isSuccess, Boolean isProject, Boolean isBodyNull) {
    	this.isSuccess = isSuccess;
		this.isProject = isProject;
		this.isBodyNull = isBodyNull;
	}

    /**
	 * Get the standard mock project ID
	 */
	public static String getMockProjectId() {
		return MOCK_PROJECT_ID;
	}

	/**
	 * Get the standard mock issue key
	 */
	public static String getMockIssueKey() {
		return MOCK_ISSUE_KEY;
	}

    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        
        if(isSuccess){
            res.setStatusCode(201);
            if(isProject){
                if(isBodyNull){
                    res.setBody('{}');
                }
            }
        }
        return null;
        }
        
    }
