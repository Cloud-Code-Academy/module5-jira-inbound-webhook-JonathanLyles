/**
 * Service class for making callouts to the Jira API
 * @author Jonathan Lyles
 */
public with sharing class JiraAPIService {

	private static final String NAMED_CREDENTIAL = 'callout:JiraAPI'; // https://jonathanlyles.atlassian.net/rest/api/3
	private static final String CREATE_PROJECT_URL = '/project';
	private static final String CREATE_ISSUE_URL = '/issue';

	/**
	 * Creates a project in Jira
	 * @param projectWrapper The project wrapper object containing all necessary data
	 * @return String The Jira project ID
	 */
	public static String createProject(JiraWrapper.ProjectWrapper projectWrapper) {
		// Guard clause: Validate projectWrapper
		try{
			if (projectWrapper == null){
				throw new NullPointerException('projectWrapper is null');
			}
		}catch(NullPointerException e){
			Logger.error(e.getMessage());
		}
		
		Http http = new Http();
		
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint(NAMED_CREDENTIAL + CREATE_PROJECT_URL);
		req.setHeader('Content-Type','application/json');
		
		// Build request body
		Map<String, Object> body = new Map<String, Object>();
		body.put('key', projectWrapper.key);
		body.put('name', projectWrapper.name);
		body.put('projectTemplateKey', projectWrapper.projectTemplateKey);
		body.put('leadAccountId', '712020:3863faf7-35b9-466a-a958-b67d229b0dff');
		req.setBody(JSON.serialize(body));

		HttpResponse res = http.send(req);

		// Guard clause: Check for null response or unexpected status code
		if (res == null || res.getStatusCode() != 201) {
			Logger.error('Failed to create project. Status code: ' + (res != null ? String.valueOf(res.getStatusCode()) : 'null'));
			return null;
		}

		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		String projectId = String.valueOf( responseMap.get('id') );
		return projectId; 
	}

	/**
	 * Creates an issue in Jira
	 * @param issueWrapper The issue wrapper object containing all necessary data
	 * @return String The Jira issue key
	 * Reminder: Extract and return the issue key from the response
	 */
	public static String createIssue(JiraWrapper.IssueWrapper issueWrapper) {
		if(issueWrapper == null || String.isEmpty(issueWrapper.key) || String.isEmpty(issueWrapper.projectKey) || String.isEmpty(issueWrapper.summary)){
			Logger.error('Invalid issueWrapper: key, summary, and projectKey fields are required. ' +
			'Provided values - key: ' + (issueWrapper != null ? issueWrapper.key : 'null') +
			', projectKey: ' + (issueWrapper != null ? issueWrapper.projectKey : 'null') +
			', summary: ' + (issueWrapper != null ? issueWrapper.summary : 'null'));
			throw new IllegalArgumentException('Invalid issueWrapper: key, summary, and projectKey fields are required.');
		}

		Http http = new http();
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');

		// Guard clause: Ensure that the NAMED_CREDENTIAL constant is correctly configured and not empty
		if(String.isEmpty(NAMED_CREDENTIAL)){
			Logger.error('Error: Named credential is not configured.');
			throw new IllegalStateException('Named credential is not configured.');
		}

		req.setEndpoint(NAMED_CREDENTIAL + CREATE_ISSUE_URL);
		req.setHeader('Content-Type','application/json');

		// Build request body
		Map<String, Object> body = issueWrapper.generateIssuePayloadMap();
		req.setBody(JSON.serialize(body));

		HttpResponse res;
		try {
			res = http.send(req);
		} catch (Exception e){
			Logger.error('HTTP callout failed: ' + e.getMessage());
			return null;
		}

		// Guard clause: check for null response or unexpected response code
		if(res == null || res.getStatusCode() != 201){
			Logger.error('Failed to create proejct. Status code: ' + (res != null ? String.valueOf(res.getStatusCode()) : 'null'));
		}

		// Guard clause: check for empty response body
		if (String.isEmpty(res.getBody())) {
			Logger.error('Response body is empty.');
			return null;
		}

		// Parse response body
		Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		String issueKey = (String) responseBody.get('key');
		return issueKey;
	}

	public class IllegalStateException extends Exception{}
	public class NullPointerException extends Exception{}
}