/**
* Test Class for AP_WfCalloutService
* @author Neha Nimran
**/
@isTest
public class AP_CalloutSerivceTest {
    
    Static User apiUser;
    // this is an example only, in a real org the profile will never be SYS Admin for running test
    private static final String Api_Profile = 'System Administrator',CC_EMAIL = 'testUserAddP@testEmail.com';
    private static final String NAMED_CREDENTIAL = 'testCredential';
    private static final String PATH = 'testPath';
    private static final Map<String, String> QUERY_PARAMS = new Map<String, String> {
        'testParam' => 'testValue',
            'testParam2' => 'testValue2'
            };
                private static final String PAYLOAD = '{"requestId: 123"}';
    
    private static final Map<String, String> HEADERS = new Map<String, String> {
        'Content-Type' => 'application/json',
            'Content-Length' => '1000'
            };
                
    @testSetup
    static void testData(){
         apiUser = createUser();
         apiUser.Email =CC_Email;
         apiUser.Username = CC_EMAIL;
         Database.insert(apiUser);
    }
    
    /**
     * Please note all these reuaable methods can be added to a Factory class for reuse
    */
    public static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        return u;
    }
    
   
    
    
    @isTest
    private static void testSuccessfulCalloutDefaultTimeout() {
        Exception calloutException;
        apiUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: Api_Profile LIMIT 1];
        System.runAs(apiUser){
            Map<String,Object> responseMap = new Map<String,Object>();
            Test.setMock(HttpCalloutMock.class, new CalloutSuccessMock());
            Test.startTest();
            try {
                HttpResponse response =AP_CalloutService.getInstance().performHttpCallout(
                    NAMED_CREDENTIAL, PATH, AP_CalloutService.HTTP_METHODS.GET,
                    HEADERS, PAYLOAD, QUERY_PARAMS);
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                
            } catch (Exception e) {
                calloutException = e;
            }
            Test.stopTest();
            Map<String,Object> data  = (Map<String,Object>)responseMap.get('data');
            System.assertEquals(null, calloutException, 'No exception should be thrown given valid inputs are provided to the service');
            System.assertEquals('4fa9bc2e-9aeb-491b-8d7a-577561d9070a', (String)responseMap.get('requestId'), 'Check requestId from response');
            System.assertEquals('test', (String)data.get('test'), 'Check requestId from response');
        }
    }
    
    @isTest
    private static void testSuccessfulCalloutWithInvalidTimeout() {
        AP_CalloutService.CalloutProperties props = new AP_CalloutService.CalloutProperties();
        props.timeout = -1;
        
        Exception calloutException;
        apiUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: Api_Profile LIMIT 1];
        System.runAs(apiUser){
        	Map<String,Object> responseMap = new Map<String,Object>();
            Test.setMock(HttpCalloutMock.class, new CalloutSuccessMock());
            Test.startTest();
            try {
                HttpResponse response= AP_CalloutService.getInstance().performHttpCallout(
                    NAMED_CREDENTIAL, PATH, AP_CalloutService.HTTP_METHODS.GET,
                    null, null, QUERY_PARAMS, props); 
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                system.debug('response'+response.getBody());
                
            } catch (Exception e) {
                calloutException = e;
            }
            Test.stopTest();
            Map<String,Object> data  = (Map<String,Object>)responseMap.get('data');
            System.assertEquals(null, calloutException, 'No exception should be thrown given valid inputs are provided to the service');
            System.assertEquals('4fa9bc2e-9aeb-491b-8d7a-577561d9070a', (String)responseMap.get('requestId'), 'Check requestId from response');
            System.assertEquals('test', (String)data.get('test'), 'Check requestId from response');
        }
    }
    
    @isTest
    private static void testSuccessfulCalloutForException() {
        
        Exception calloutException;
        apiUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: Api_Profile LIMIT 1];
        System.runAs(apiUser){
            Test.setMock(HttpCalloutMock.class, new CalloutExceptionMock());
            Test.startTest();
            try {
                HttpResponse response= AP_CalloutService.getInstance().performHttpCallout(
                    NAMED_CREDENTIAL, PATH, AP_CalloutService.HTTP_METHODS.GET,
                    null, null, QUERY_PARAMS); 
                
            } catch (Exception e) {
                calloutException = e;
            }
            Test.stopTest();
            System.assertEquals('Null Value', calloutException.getMessage(), 'Check Exception thrown');
        }
    }    
    
    @isTest
    private static void testSetBodyAsBlobAndsetContentLengthHeader() {
        Exception calloutException;
        apiUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: Api_Profile LIMIT 1];
        System.runAs(apiUser){
            Map<String,Object> responseMap = new Map<String,Object>();
            Test.setMock(HttpCalloutMock.class, new CalloutSuccessMock());
            Test.startTest();
            try {
                AP_CalloutService.CalloutProperties calloutProperties = new AP_CalloutService.CalloutProperties();
                calloutProperties.setBodyAsBlob = TRUE;
                calloutProperties.setContentLengthHeader = TRUE;
                HttpResponse response =AP_CalloutService.getInstance().performHttpCallout(
                    NAMED_CREDENTIAL, PATH, AP_CalloutService.HTTP_METHODS.GET,
                    HEADERS, PAYLOAD, QUERY_PARAMS, calloutProperties);
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                
            } catch (Exception e) {
                calloutException = e;
            }
            Test.stopTest();
            Map<String,Object> data  = (Map<String,Object>)responseMap.get('data');
            System.assertEquals(null, calloutException, 'No exception should be thrown given valid inputs are provided to the service');
            System.assertEquals('4fa9bc2e-9aeb-491b-8d7a-577561d9070a', (String)responseMap.get('requestId'), 'Check requestId from response');
            System.assertEquals('test', (String)data.get('test'), 'Check requestId from response');
        }
    } 

    public class CalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":200,"code":200, "time":"2020-04-29T09:44:29.932+0000", "requestId":"4fa9bc2e-9aeb-491b-8d7a-577561d9070a","method":"GET","data":{"test":"test"}}');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class CalloutExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            Exception e = new NullPointerException();
            e.setMessage('Null Value');
            throw e;
        }
    }
    
    @isTest
    private static void testSuccessfulCalloutWithInvalidTimeoutForDeleteMethod() {
        AP_CalloutService.CalloutProperties props = new AP_CalloutService.CalloutProperties();
        props.timeout = -1;
        
        Exception calloutException;
        apiUser = [SELECT Id,ContactId,UserRoleId FROM User WHERE Username =: CC_EMAIL AND Profile.Name =: Api_Profile LIMIT 1];
        System.runAs(apiUser){
        	Map<String,Object> responseMap = new Map<String,Object>();
            Test.setMock(HttpCalloutMock.class, new CalloutSuccessMock());
            Test.startTest();
            try {
                HttpResponse response= AP_CalloutService.getInstance().performHttpCallout(
                    NAMED_CREDENTIAL, PATH, AP_CalloutService.HTTP_METHODS.DEL,
                    null, null, QUERY_PARAMS, props); 
                responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                
            } catch (Exception e) {
                calloutException = e;
            }
            Test.stopTest();
            Map<String,Object> data  = (Map<String,Object>)responseMap.get('data');
            System.assertEquals(null, calloutException, 'No exception should be thrown given valid inputs are provided to the service');
            System.assertEquals('4fa9bc2e-9aeb-491b-8d7a-577561d9070a', (String)responseMap.get('requestId'), 'Check requestId from response');
            System.assertEquals('test', (String)data.get('test'), 'Check requestId from response');
        }
    }
}