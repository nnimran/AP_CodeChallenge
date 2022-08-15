/**
*@Description : Class for AP_APCallout Flow's Apex Action
*@Author: Neha Nimran
**/

public class AP_InvocableCalloutController {
    
    //WorkforceApiService
    @InvocableMethod(label='Call to API' callout ='true')
    public static void getSecretKeyFromCallout(List<InputResource> inputs)
    {
        for(InputResource iR: inputs){
            AP_WfCalloutService.aSyncCallout(iR.case_Id);            
        }       
    }
    
    public class InputResource{
        @InvocableVariable(label='Fetch Case Id')
        public Id case_Id;
    }
    
}