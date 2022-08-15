/**
*@Description : Generic class for performing REST Callouts
*@Author : Neha Nimran
**/
public with sharing class AP_CalloutService {
    private static AP_CalloutService instance;
    
    private static final Integer DEFAULT_TIMEOUT= 10000;
    
    private static final Map<String, String> MAP_HTTP_METHODS = new Map<String, String>{'DEL'=>'DELETE'};
        
    public enum HTTP_METHODS {
            GET, POST, PATCH, PUT, DEL
                }
    
    public class CalloutProperties {
        
        public Integer timeout{
            get {
                if(timeout == null) {
                    timeout =  DEFAULT_TIMEOUT;
                }
                return timeout;
            }
            set;
        }
        
        public Boolean setBodyAsBlob = FALSE;
        public Boolean setContentLengthHeader = FALSE;
    }
    
    private  AP_CalloutService() {
        // Private Constructor
    }
    
    public static AP_CalloutService getInstance() {
        if (instance == null) {
            instance = new AP_CalloutService();
        }
        return instance;
    }
    
    public HttpResponse performHttpCallout(
        String namedCredential, String path, HTTP_METHODS methodName, Map<String, String> headers,
        String payload, map<String, String> queryParams
    ) {
        
        return performHttpCallout(
            namedCredential, path, methodName,
            headers, payload, queryParams, new CalloutProperties()
        );
        
    }
    
    
    public HttpResponse performHttpCallout(
        String namedCredential, String path, HTTP_METHODS methodName, Map<String, String> headers,
        String payload, map<String, String> queryParams, CalloutProperties properties
    ) {  
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setMethod(methodName.name());
        if(MAP_HTTP_METHODS.containsKey(methodName.name())){
            request.setMethod(MAP_HTTP_METHODS.get(methodName.name()));
        }
        String endPoint = '';
        if(String.isNotBlank(namedCredential)) {
            endPoint += 'callout:'+namedCredential;
        }
        if(String.isNotBlank(path)) {
            if(String.isNotBlank(endPoint)) {
                endPoint += '/';
            }
            endPoint += path;
        }
        endPoint += setQueryParameters(queryParams);
        
        // check for timeout value
        checkValidTimeout(request, properties.timeout);
        
        request.setEndpoint(endpoint);
        if (String.isNotBlank(payload)) {
            if(properties!= null && properties.setBodyAsBlob){ 
                request.setBodyAsBlob(Blob.valueof(payload));
            } else {
                request.setBody(payload);
            }
        }
        
        setHeaders(request, headers,properties); 
        
        response = new Http().send(request);
        
        return response;
        
    }
    
    
    private void checkValidTimeout(HttpRequest request, Integer timeout) {
        
        
        if (timeout == null || timeout <= 0 || timeout > 120000) {
            
            request.setTimeout(DEFAULT_TIMEOUT);
        } else {
            request.setTimeout(timeout);   
        }
        
    }
    
    private String setQueryParameters(Map<String, String> queryParams) {
        
        String endPoint = '';
        if(queryParams!= null) {
            endpoint += '?';
            Iterator<String> iterator = queryParams.keySet().iterator();
            while(iterator.hasNext()) {
                String key = iterator.next();
                endpoint+= key;
                endpoint+= '=';
                endpoint+=EncodingUtil.urlEncode(queryParams.get(key), 'UTF-8'); // Sanitize request params
                if(iterator.hasNext()) {
                    endpoint+= '&';
                }
            }
            endpoint = String.escapeSingleQuotes(endpoint);
        }
        
        return endPoint;
        
    }
    
    private void setHeaders(HttpRequest request, Map<String, String> headers,CalloutProperties properties) {
        
        if(headers != null) {
            for(String key: headers.keySet()) {
                request.setHeader(key, headers.get(key));
            }
        }
        if(properties!= null && properties.setContentLengthHeader){
            request.setHeader('Content-Length',String.valueOf(request.getBodyAsBlob().size()));	                
        }        
        
    }
}