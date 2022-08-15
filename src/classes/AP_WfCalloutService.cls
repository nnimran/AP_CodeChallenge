/**
*@Description : Generic class for performing REST Callouts
*@Author : Neha Nimran
**/
public with sharing class AP_WfCalloutService {
    
    // callout method for async call
    @Future(callout=true)
    public static void aSyncCallout(String caseId){
        List<Case> caseToUpdateList = new List<Case>();
        Case caseToUpdate = new Case();
        try{
            
            caseToUpdateList = [SELECT Id, Secret_Key__c, AP_CaseSyncCounter__c, OwnerId FROM Case WHERE Id =:caseId LIMIT 1];
            if(caseToUpdateList.size() == 0){
                return;
            }
            
            caseToUpdate =caseToUpdateList[0];
            AP_WfCalloutService apiService = new AP_WfCalloutService();
            AP_WfCalloutService.EndPoint endpoint = new AP_WfCalloutService.EndPoint();
            AP_WfCalloutService.Request request = new AP_WfCalloutService.Request();
            AP_WfCalloutService.Response response = new AP_WfCalloutService.Response();
            request.setId(caseToUpdate.Id);
            request.setAgentid(caseToUpdate.OwnerId);
            response = apiService.callout(request, endpoint);
            
            HttpResponse response_x = AP_CalloutService.getInstance()
                .performHttpCallout(
                    endpoint.namedCredential,
                    null,
                    endpoint.method,
                    endpoint.headers,
                    JSON.serialize(request),
                    endpoint.urlParameters,
                    endpoint.prop
                ); 
            
            if (response_x.getStatusCode() != 200) {
                caseToUpdate.AP_CaseSyncErrorLog__c = response_x.getStatusCode() + ' '+response_x.getBody();
            }
            Response responseWithNulls = (Response) JSON.deserialize(
                response_x.getBody(),
                Response.class
            );
            response = (Response) JSON.deserialize(
                JSON.serialize(responseWithNulls, true),
                Response.class
            );
            
            if(response != null && String.isBlank(response.secretKey)){
                caseToUpdate.AP_CaseSyncErrorLog__c = 'Sync failed. Please retry';
            }
            
            // Update secretKey on case
            caseToUpdate.Secret_Key__c = response.secretKey;
            // can be avoided with config to have initial value as 0 on case creation
            if(caseToUpdate.AP_CaseSyncCounter__c == Null){
                caseToUpdate.AP_CaseSyncCounter__c = 1;
            }else{
                caseToUpdate.AP_CaseSyncCounter__c = Integer.valueOf(caseToUpdate.AP_CaseSyncCounter__c + 1);
            }
        }catch(Exception e){
            // Ideally each type of exception can be treated differently like DML/Callout 
            caseToUpdate.AP_CaseSyncErrorLog__c = e.getMessage();
        }
        System.debug('caseToUpdate '+caseToUpdate);
        upsert caseToUpdate;
        
    }
    
    
    //callout method for sync call 
    public Response callout(Request request, Endpoint endPoint){
        HttpResponse response_x = AP_CalloutService.getInstance()
            .performHttpCallout(
                endpoint.namedCredential,
                null,
                endpoint.method,
                endpoint.headers,
                JSON.serialize(request),
                endpoint.urlParameters,
                endpoint.prop
            ); 
        
        if (response_x.getStatusCode() != 200) {
            // Log the error
        }
        Response responseWithNulls = (Response) JSON.deserialize(
            response_x.getBody(),
            Response.class
        );
        Response response = (Response) JSON.deserialize(
            JSON.serialize(responseWithNulls, true),
            Response.class
        );
        
        if(response != null && String.isBlank(response.secretKey)){
            // Log the error
        }
        if(hasError(response)){
            // Log the error
        }
        return response;
    }
    
    private Boolean hasError(Response response) {
        return response.error != null;
    }
    
    public class EndPoint {
        public AP_CalloutService.CalloutProperties prop { get; private set; }
        public AP_CalloutService.HTTP_METHODS method { get; private set; }
        public String namedCredential { get; private set; }
        public Map<String, String> urlParameters { get; private set; }
        public Map<String, String> headers { get; private set; }
        
        public EndPoint() {
            this.prop = new AP_CalloutService.CalloutProperties();
            this.prop.timeout = 100000;
            this.method = AP_CalloutService.HTTP_METHODS.POST;
            this.namedCredential = 'AP_Workforce_URL';
            this.headers = new Map<String, String>{
                'Content-Type' => 'application/json'
                    };
                        }
        public void addUrlParam(String key, String value) {
            if (this.urlParameters == null) {
                this.urlParameters = new Map<String, String>();
            }
            this.urlParameters.put(key, value);
        }
        public void addHeader(String key, String value) {
            this.headers.put(key, value);
        }
        public void setMethod(AP_CalloutService.HTTP_METHODS method) {
            this.method = method;
        }
        public void setTimeOut(Integer timeout) {
            this.prop.timeout = timeout;
        }
    }
    
    public class Response {
        public String error { get; set; }
        public Boolean success { get; set; }
        public String secretKey { get; private set; }
    }
    
    public class Data {
        @TestVisible public String secretKey { get; private set; }
    }
    
    public class Request  {
        public String id { get;  private set; }
        public String agentid { get;  private set; }
        public Request(){
            this.id = '';
            this.agentid = '';
        }
        
        public void setId(String id){
            this.id = id;
        }
        
        public void setAgentid(String agentId){
            this.agentid = agentId;
        }
    }
}