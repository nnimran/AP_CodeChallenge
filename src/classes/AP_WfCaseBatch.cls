/**
*@Description : Generic class for performing REST Callouts
*@Author : Neha Nimran
**/
global class AP_WfCaseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // add 100 for limiting callouts for each batch process
        String query = 'SELECT ID, Secret_Key__c, AP_CaseSyncCounter__c, AP_CaseSyncErrorLog__c, AP_CaseSyncStatus__c, OwnerId FROM CASE WHERE Secret_Key__c = NULL AND (AP_CaseSyncCounter__c < 3 OR AP_CaseSyncCounter__c = NULL) AND Status != \'Closed\' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Case>scope){
        
        AP_WfCalloutService apiService = new AP_WfCalloutService();
        AP_WfCalloutService.EndPoint endpoint = new AP_WfCalloutService.EndPoint();
        AP_WfCalloutService.Request request = new AP_WfCalloutService.Request();
        AP_WfCalloutService.Response response = new AP_WfCalloutService.Response();
        List<Case> casesToUpdate = new List<Case>();
        try{
            for(Case caseObj :scope){
               AP_WfCalloutService.aSyncCallout(caseObj.Id);
            }
        }catch(Exception e){
            System.debug('e '+e.getStackTraceString());
            
        }finally{
            // Log flush to commit all logs
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}