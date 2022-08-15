trigger AP_CaseTigger on Case (after update) {
    
    try{
        List<case> casesToUpdate = new List<case>();
        
        If(Trigger.IsUpdate){
            List<case> newlyUpdatedCases = new List<case>();
            newlyUpdatedCases = [Select Id, Secret_Key__c, AP_CaseSyncCounter__c,OwnerId, Status FROM Case WHERE Id IN :Trigger.New ];
            
            for(Case c:newlyUpdatedCases){
                // retry only thrice
                if(c.status =='Closed' )
                {
                    try{
                        AP_WfCalloutService.aSyncCallout(c.Id);
                        
                    }catch(System.CalloutException e){
                        
                        c.AP_CaseSyncErrorLog__c = e.getMessage();
                    }
                    
                }
            }
            
        }
        
    }catch(Exception e){
        //Should be logged to error object
        System.debug('response '+e.getStackTraceString());
    }
    
}