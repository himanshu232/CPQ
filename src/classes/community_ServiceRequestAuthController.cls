public with sharing class community_ServiceRequestAuthController {
    public string srID {get;set;}
    public Hosted_Service_Request__c thisSR;
    public string errorString {get;set;}
    
    public string copyTerms {get;set;}
    public string patchTerms {get;set;}
    public string upgradeTerms {get;set;}
    public string terms {get;set;}
    
    public string srName {get;set;}
    public string srType {get;set;}
    public string srDate {get;set;}
    public string srTimeSlot {get;set;}
    public string srTargetEnvironment {get;set;}
    public string srDescription {get;set;}
    public string srOwnerName {get;set;}
    
    public string trentVersion {get;set;}
    
    public string userContactID {get;set;}
    
    public community_ServiceRequestAuthController() {
        try {
            srID = ApexPages.currentPage().getParameters().get('sr');
        } catch (Exception e) {
            errorString = 'The link you have navigated to is invalid. Please check the link you have clicked and try again.';
            return;
        }
        
        if(srID == '') {    
            errorString = 'The link you have navigated to is invalid. Please check the link you have clicked and try again.';
            return;
        }
        
        if(!hasPerm()) {
            //errorString = 'Unfortunately, you do not have the required permissions to authorise service requests. If you believe you should have this permission, please ask an approved authoriser to raise a case on your behalf.';
            errorString = 'Unfortunately you do not have the required permission to approve this service request. If you believe you should have this permission, please ask an approved authoriser to raise a case with our Service Desk to have the permission added to your account.';
            return;
        }    
        
        try {
            thisSR = [SELECT Owner.Name, Name, srRealName__c, srApprover__c, cop_PIT__c, cop_PITDT__c, srCustomer__c, srEnvironment__c, pat_MatchEnvironment__c, srOwner__c, pat_Type__c, srDate__c, cop_SourceEnvironment__c, srStatus__c, srTime__c, upg_TrentVersion__c, srType__c, upg_Copy__c, srTermsAndConditions__c FROM Hosted_Service_Request__c WHERE ID = : srID];
        } catch (Exception e) {
            errorString = 'The link you have navigated to is invalid. Please check the link you have clicked and try again.';
            return;
        }
        
        User currentUser = [SELECT id, contactid, contact.accountid FROM user WHERE id= : UserInfo.getUserID() LIMIT 1];
        userContactID = currentUser.contactid;
        if(thisSR.srCustomer__C != currentUser.Contact.AccountID) {
            //abort! wrong customer.
            errorString = 'The link you have navigated to is invalid. Please check the link you have clicked and try again.';
            return;
        }
        
        if(thisSR.srStatus__c != 'Pending Approval') {
            errorString = 'The link you have followed points to a service request that is not pending approval. Please check the link you followed and try again.';
            return;
        }
        
        srName = thisSR.srRealName__c;
        srType = thisSR.srType__c;
        DateTime tmpDate = (DateTime) thisSR.srDate__c;
        srDate = tmpDate.format('dd/MM/yyyy');
        srTimeSlot = thisSR.srTime__c;
        terms = thisSR.srTermsAndConditions__c;
        Hosted__c tmpTarget = [SELECT ID, Environment_Name__c, Environment_Type__c FROM Hosted__c WHERE ID = : thisSR.srEnvironment__c];
        srTargetEnvironment = tmpTarget.Environment_Name__c;
        
        srOwnerName = thisSR.Owner.Name;
        
        if(srType == 'Patch') {
            srDescription = 'HRO IT will perform a patch install on the ' + srTargetEnvironment + ' environment, and will patch ';
            if(thisSR.pat_Type__c == 'Patch to Match') {
                Hosted__c tmpEnv = [SELECT Environment_Name__c from Hosted__c WHERE ID = : thisSR.pat_MatchEnvironment__c];
                srDescription = srDescription + 'to match the ' + tmpEnv.Environment_Name__c + ' environment';
            } else {
                srDescription = srDescription + 'up to date';
            }  
            
            srDescription = srDescription + ' on the ' + srDate + ' ' + srTimeSlot + '.';
        } else if(srType == 'Database Copy') {
            Hosted__c tmpEnv = [SELECT Environment_Name__c from Hosted__c WHERE ID = : thisSR.cop_SourceEnvironment__c];
            srDescription = 'HRO IT will copy data from the ' + tmpEnv.Environment_Name__c + ' environment to the ' + srTargetEnvironment + ' environment';
            if(thisSR.cop_PIT__c) {
                srDescription = srDescription + ' using data from the ' + tmpEnv.Environment_Name__c + ' at the point in time of ' + thisSR.cop_PITDT__c;
            } else {
                srDescription = srDescription;
            }
            
            srDescription = srDescription + ' on the ' + srDate + ' ' + srTimeSlot + '.';
        } else if(srType == 'Upgrade') {
            srDescription = 'HRO IT will upgrade your ' + srTargetEnvironment + ' to iTrent Version ' + thisSR.upg_TrentVersion__c + ' on the ' + srDate + '.';
            if(thisSR.upg_Copy__c) srDescription = srDescription + ' Data from your Live environment will be copied into this environment at 17:00 on the working day before the upgrade.';
        }
    }
    
    public PageReference srAuthorise() {
        thisSR.srApprover__c = userContactID;
        thisSR.srStatus__c = 'Approved';
        update thisSR;
        
        PageReference responsePage;
        responsePage = New PageReference('/ServiceDesk/community_ServiceRequestList?prompt=Approved&highlight=' + srID);
        
        return responsePage;
    }
    
    public PageReference srReject() {
        thisSR.srApprover__c = userContactID;
        thisSR.srStatus__c = 'Rejected by Customer';
        update thisSR;
        
        PageReference responsePage;
        responsePage = New PageReference('/ServiceDesk/community_ServiceRequestList?prompt=Rejected&highlight=' + srID);
        
        return responsePage;
    }
    
    private void calculateTrentVersionOnDate(DateTime inputDate) {
        DateTime startDate = DateTime.newInstanceGmt(2016, 5, 31); //release of 10.20 - DO NOT CHANGE THIS AS IT WILL SCREW EVERYTHING
        Integer baseVersion = 20;
        DateTime endDate = startDate.addMonths(3); //release of 10.21 / when we stop installing 10.20
        
        DateTime currentVersionStart = startDate;
        Integer currentVersion = baseVersion;
        DateTime currentVersionEnd = endDate;
        
        while(inputDate > currentVersionEnd) {
            currentVersionStart = currentVersionStart.addMonths(3);
            currentVersionEnd = currentVersionEnd.addMonths(3);
            currentVersion = currentVersion + 1;
        }
        
        trentVersion = '10.' + currentVersion;
    } 
    
    private boolean isReleaseMonth(Integer month) {
        Integer[] releaseMonths = new Integer[]{3, 6, 9, 12};
        
        for(Integer m : releaseMonths) {
            if(m == month) return true;
        }
        
        return false;
    }
    
    private boolean hasPerm() {
        Boolean showServiceRequest = false;
        for(List<PermissionSetAssignment> PSA : [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Community_Create_Service_Request']) {
            if (!PSA.isEmpty()) {
                showServiceRequest = true;
            }
        }
        
        return showServiceRequest;
    } 
}