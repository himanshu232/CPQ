public with sharing class community_RequestListingController {

    /*public List<Service_Request__c> serviceRequest {get;set;}
    
    public community_RequestListingController() {
        
        User currentUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        string customer = [SELECT Id From Account WHERE Id = : currentUser.Contact.AccountId LIMIT 1].Id;
       
        serviceRequest = New List<Service_Request__c>();
        serviceRequest = [SELECT Id, Name, created__c,recordtype.name, status__c,Service_Request_Availablity__r.date__c FROM service_request__c  WHERE customer__c = : customer AND Cancelled_By_Customer__c = false ORDER BY created__c];
    }*/

    public community_RequestListingController () {
        redirect();
    }
    
    public PageReference redirect() {
        PageReference pageRef = new PageReference('/apex/community_ServiceRequestList');
         return pageRef.setRedirect(true);
    }
}