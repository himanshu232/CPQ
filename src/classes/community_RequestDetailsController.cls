public class community_RequestDetailsController {
    
    /*public Service_Request__c serviceRequest {get;set;}
    private string ServiceRequestId {get;set;}
    public boolean showDatabase {get;set;}
    public boolean showPatches {get;set;}
    public boolean showUpgrade {get;set;}
    
    public community_RequestDetailsController() {
        ServiceRequestId = ApexPages.currentPage().getParameters().get('SRId');
        serviceRequest = [SELECT Name, CreatedBy.name, Service_Request_Availablity__r.date__c, created__c, source_environment_del__r.Environment_Type__c , Target_Environment_del__r.Environment_Type__c,status__c, 
                          Point_In_Time__c, Upgrade_Environment__c, Scheduled_Date__c, Match_Environment__c, RecordType.Name,Record_Type_Name__c, Patch_Environment__c
                          FROM service_request__c WHERE Id = : ServiceRequestId LIMIT 1];
        if(serviceRequest.Recordtype.Name == 'Database Copy Requested' ||serviceRequest.Recordtype.Name == 'Database Copy') {
            showDatabase = true;
            showPatches = false;
            showUpgrade = false;
        } else if (serviceRequest.Record_Type_Name__c == 'Upgrade' || serviceRequest.Record_Type_Name__c == 'Upgrade Requested') {
            showDatabase = false;
            showPatches = false;
            showUpgrade = true;
        } else {
            showDatabase = false;
            showPatches = true;
            showUpgrade = false;
        }
    }

    public pageReference CancelRequest() {
        serviceRequest.Cancelled_By_Customer__c = true;
        update serviceRequest;
        PageReference pageRef = page.community_ServiceRequestListing;
        return pageRef;

    }*/
    
    public community_RequestDetailsController () {
        redirect();
    }
    
    public PageReference redirect() {
        PageReference pageRef = new PageReference('/apex/community_ServiceRequestList');
         return pageRef.setRedirect(true);
    }
        
}