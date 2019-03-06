trigger CXIntegrationCase on Case (before update) 
{      
    Map<Id, RecordType> caseRT = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType='Case']);
    // adjust for when triggers can run against cases from (based on closed date)
    Date runCodeFrom = date.newInstance(2017,08,18);
    for(Case CaseList : Trigger.new)
    {               

        //Support Service (BAU): Case Resolution survey
        IF(caseRT.get(CaseList.RecordTypeId).DeveloperName != 'Managed_Services_Case' && caseList.CX_Sent__c == False && caseList.Department__c == 'Service Desk' && caseList.Selected_for_CSAT__c == 'Yes' &&  caseList.Status == 'Resolution Provided' && (caseList.ClosedDate >= runCodeFrom || caseList.ClosedDate == null))
    	{
       		caseList.CX_Sent__c = True;
            Account tmpAccount = [SELECT Name FROM Account WHERE ID = : CaseList.AccountId];
            Contact tmpContact = [SELECT FirstName, LastName FROM Contact WHERE ID = : CaseList.ContactId];
            CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/01906c5bc4624aad/replies', '5m1TG59yXGqiF77TzB99FdSs', caseList.ContactEmail, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(caseList.Hosted__c), '', caseList.BDM__c, caseList.CaseNumber, caselist.Case_Owner__c, '', '', '', '');
    	}
        
        //Analytics (BAU): Case Resolution survey
        IF(caseRT.get(CaseList.RecordTypeId).DeveloperName != 'Managed_Services_Case' && caseList.CX_Sent__c == False && caseList.Department__c == 'Business Analytics' && caseList.Status == 'Resolution Provided' && (caseList.ClosedDate >= runCodeFrom || caseList.ClosedDate == null))
    	{
       		caseList.CX_Sent__c = True;
            Account tmpAccount = [SELECT Name FROM Account WHERE ID = : CaseList.AccountId];
            Contact tmpContact = [SELECT FirstName, LastName FROM Contact WHERE ID = : CaseList.ContactId];
            CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/8e8b37692dc10a2a/replies', 'NZfwNNSNYFVsPBp2d8F5qwug', caseList.ContactEmail, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(caseList.Hosted__c), '', caseList.BDM__c, caseList.CaseNumber, caselist.Case_Owner__c, '', '', '', '');
    	}
        
        //Managed Services (BAU): Case Resolution survey
        IF(caseRT.get(CaseList.RecordTypeId).DeveloperName == 'Managed_Services_Case' && caseList.CX_Sent__c == False && caseList.Selected_for_CSAT__c == 'Yes' && caseList.Status == 'Closed' && (caseList.ClosedDate >= runCodeFrom || caseList.ClosedDate == null))
    	{
       		caseList.CX_Sent__c = True;
            Account tmpAccount = [SELECT Name FROM Account WHERE ID = : CaseList.AccountId];
            CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/b0c54c39fc8b1375/replies', 'Wm4AcTDVUJimFvecpSHUF6SH', caseList.SuppliedEmail , caseList.SuppliedName, '', tmpAccount.Name, '', '', '', caseList.CaseNumber, caselist.Case_Owner__c, '', '', '', '');
    	}
        
        //Cloud Service (BAU): Case Resolution survey
        IF(caseRT.get(CaseList.RecordTypeId).DeveloperName != 'Managed_Services_Case' && caseList.CX_Sent__c == False && caseList.Department__c == 'HRO IT Services' && caseList.Selected_for_CSAT__c == 'Yes' && (caseList.Status == 'Closed' || caseList.Status == 'Resolution Provided') && (caseList.ClosedDate >= runCodeFrom || caseList.ClosedDate == null))
    	{
       		caseList.CX_Sent__c = True;
            Account tmpAccount = [SELECT Name FROM Account WHERE ID = : CaseList.AccountId];
            Contact tmpContact = [SELECT FirstName, LastName FROM Contact WHERE ID = : CaseList.ContactId];
            CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/bd8617c9b16cc988/replies', 'zFAL4yBPez4JaErioh9mL5LW', caseList.ContactEmail, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(caseList.Hosted__c), '', caseList.BDM__c, caseList.CaseNumber, caselist.Case_Owner__c, '', '', '', '');
    	}   
    }    
}