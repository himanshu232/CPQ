trigger CXIntegrationHostedServiceRequests on Hosted_Service_Request__c (before update)
{ 
    for(Hosted_Service_Request__c HostedSRList : Trigger.new)
    {
        // adjust for when triggers can run against Service Requests from (based on service date)
        Date runCodeFrom = date.newInstance(2017,07,17);
        
        //Cloud Services (BAU): Hosted Service Request Complete      
        IF(HostedSRList.CX_Sent__c == False && HostedSRList.srStatus__c == 'Complete' && HostedSRList.srDate__c >= runCodeFrom)
    	{
            HostedSRList.CX_Sent__c = True;
            Account tmpAccount = [SELECT Name, Hosted_Midland__c, OwnerId FROM Account WHERE ID = : HostedSRList.srCustomer__c];
            Contact tmpContact = [SELECT FirstName, LastName, Email FROM Contact WHERE ID = : HostedSRList.srApprover__c];
            User tmpBDM = [SELECT Full_Name__c FROM User WHERE ID = : tmpAccount.OwnerId];
            string userHolder = '';
            IF(HostedSRList.srOwner__c != null)
            {
                User tmpUser = [SELECT Name FROM User WHERE ID = : HostedSRList.srOwner__c];
                userHolder = tmpUser.Name;
            }
            CXRequest.requestToCX('https://cx.surveymonkey.com/api/v1/surveys/5d32a90f32d4f00d/replies', 'j6hPUG1BYqZ4symWr7Wybr1L', tmpContact.Email, tmpContact.FirstName, tmpContact.LastName, tmpAccount.Name, String.valueOf(tmpAccount.Hosted_Midland__c), '', tmpBDM.Full_Name__c, '',userHolder, HostedSRList.Name, '', '', '');
        }
    }
}