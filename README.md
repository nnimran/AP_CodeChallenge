# AP_CodeChallenge
AP Code Challenge
Solution Description:


Option 1: Using flow that will trigger on update.

Option 2: Using trigger on case object

 

In both cases we require callout to the workforce planning team API.

 

For api, end point we are using a Named Credential.

Note: Though the api currently does not need auth, using Named Cred will provide us flexibility to add it later for upper environments.(SIT, PRE-PROD OR PROD)

 

New fields added on Case

AP_SecretKey

AP_SyncStatus

AP_ErrorLog

AP_CaseSyncCounter

AP_CalloutService

 

Note: Using prefix as AP[Aus Post] to separate them from any other package custom fields.

 

For simplicity I am keeping the log message on  the case object itself.

Note: Ideally we can create another custom object for logging and flush it in finally of a transaction.

 

Retry Mechanism:

 

Rudimentary retry mechanism for minimal effort.

Option 1: Using HTTP retry in the CalloutService class.

The drawback of this approach is, the long running transactions on the platform will keep growing when the api is down for a longer duration and this may happen during business hours.

Options 2: Using batch apex

 that runs in out of business hours to do the sync. We can utilise a batch that can be scheduled every day or hour as per the SLA business has set. Preferable in non-business hours to keep the platform governance limits in check.

For retry in both options we can use the AP_SyncStatus/ AP_CaseSyncCounter field on the case object to decide retry a sync in case the earlier sync fails with and error.
