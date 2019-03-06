public with sharing class community_ServiceRequestInternalComplete {

    public string status {get;set;}
    public string referrerID {get;set;}
    public Hosted_Service_Request__c referrerSR {get;set;}
    public string customerID {get;set;}
    
    public string pageTitle {get;set;}
    public string pageSubtitle {get;set;}
    public string pageContent {get;set;}
    
    public community_ServiceRequestInternalComplete() {
    
        try {
            status = ApexPages.currentPage().getParameters().get('type');
            if(status != 'ERR') {
                referrerID = ApexPages.currentPage().getParameters().get('sr');
            
                referrerSR = [SELECT Name, srRealName__c, srDate__c, srTime__c, srType__c, srCustomer__c FROM Hosted_Service_Request__c WHERE ID = : referrerID];
            }
        } catch (Exception e) {
            pageTitle = 'There was an error';
            pageSubtitle = 'There was an error displaying this page.';
            pageContent = 'This page could not be displayed as no parameters have been given to it. Please check the link you have been provided and try again.';
            
            return;
        }
        
        if(status == 'SUC') {
            String customerName = [SELECT name FROM account WHERE id= : referrerSR.srCustomer__c LIMIT 1].Name;
            DateTime tmpDate = (DateTime) referrerSR.srDate__c;
            String srDate = tmpDate.format('dd/MM/yyyy');
        
            pageTitle = 'Raise a Hosted Service Request';
            pageSubtitle = 'The service request has been raised successfully.';
            
            pageContent = 'The service request for ' + customerName + ' has been successfully raised as ' + referrerSR.srRealName__c + '. This is a request for a ' + referrerSR.srType__c + ' on ' + srDate;
            if(referrerSR.srTime__c != '') {
                pageContent = pageContent + ' (' + referrerSR.srTime__c + ')';
            }
            pageContent = pageContent + '. The customer will be notified to approve this request to allow it to go ahead.';
        } else if(status == 'ERR') {
            pageTitle = 'Raise a Hosted Service Request';
            pageSubtitle = 'There was an error when attempting to raise the service request';
            pageContent = 'Unfortunately, there was an error when attempting to raise the Service Request. Please try again later.';
        }
        
    }    
}