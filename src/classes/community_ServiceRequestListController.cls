public with sharing class community_ServiceRequestListController {
    public string additionalPrompt {get;set;}
    public string referrerID {get;set;}
    public Hosted_Service_Request__c referrerSR {get;set;}
    public boolean paramsSet {get;set;}
    public string customerID {get;set;}
    
    public List<Hosted_Service_Request__c> existingSR {get;set;}
    public SelectOption [] sortOptions {get;set;}
    
    public string sortOpt {get;set;}
    
    public community_ServiceRequestListController() {
        try {
            additionalPrompt = ApexPages.currentPage().getParameters().get('prompt');
            referrerID = ApexPages.currentPage().getParameters().get('highlight');
            
            referrerSR = [SELECT Name, srRealName__c, srDate__c, srTime__c, srType__c FROM Hosted_Service_Request__c WHERE ID = : referrerID];
        } catch (Exception e) {
            paramsSet = false;
        }
        
        User currentUser = [SELECT id, contactid, contact.accountid FROM user WHERE id= : UserInfo.getUserID() LIMIT 1];
        customerID = currentUser.contact.accountid;
        
        sortOptions = new List<SelectOption>();
        sortOptions.add(new SelectOption('ALL', 'All Service Requests'));
        sortOptions.add(new SelectOption('PENDING_APPROVAL', 'Pending Approval'));
        sortOptions.add(new SelectOption('NOT_APPROVED', 'Not Approved'));
        sortOptions.add(new SelectOption('PENDING_SCHEDULE', 'Awaiting Scheduling'));
        sortOptions.add(new SelectOption('SCHEDULED', 'Scheduled'));
        sortOptions.add(new SelectOption('COMPLETE', 'Completed'));
        sortOptions.add(new SelectOption('CANCELLED', 'Cancelled'));
        sortOptions.add(new SelectOption('REJECTED', 'Rejected'));        
        existingSR = new List<Hosted_Service_Request__c>();
        existingSR = [SELECT Name, srRealName__c, srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID ORDER BY Name ASC];
        
    }
    
    public void updateList() {
        sortOpt = ApexPages.currentPage().getParameters().get('inputSort');
        
        existingSR.clear();
        if(sortOpt == 'ALL' || sortOpt == '') {
            existingSR = [SELECT Name, srRealName__c, srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID ORDER BY Name ASC];
        } else if(sortOpt == 'PENDING_APPROVAL') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Pending Approval' ORDER BY Name ASC];
        } else if(sortOpt == 'NOT_APPROVED') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Rejected by Customer' ORDER BY Name ASC];
        } else if(sortOpt == 'PENDING_SCHEDULE') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Approved' ORDER BY Name ASC];
        } else if(sortOpt == 'SCHEDULED') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Scheduled' ORDER BY Name ASC];
        } else if(sortOpt == 'COMPLETE') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Scheduled' ORDER BY Name ASC];
        } else if(sortOpt == 'CANCELLED') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Cancelled' ORDER BY Name ASC]; 
        } else if(sortOpt == 'REJECTED') {
            existingSR = [SELECT Name, srRealName__c,srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c FROM Hosted_Service_Request__c WHERE srCustomer__c = : customerID AND srStatus__c = 'Rejected' ORDER BY Name ASC];
        }
        
    }
}