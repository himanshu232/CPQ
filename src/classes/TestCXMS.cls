@isTest
public class TestCXMS 
{
    @isTest (SeeAllData=true) static void TestingCXMS()
    {         
        //Create Account
        Account acct = new Account();
        acct.name='TestTriggers';
        acct.Type = 'Customer';
        //acct.Project_Manager__c = 'Testing PM';
        //acct.Business_Development_Manager__c = 'Testing BDM';
        insert acct;
        //Create Contact;
        Contact cont = new Contact();
        cont.Salutation = 'Mr.';
        cont.FirstName = 'Test_FirstName';
        cont.LastName = 'Test_LastName';
        cont.email = 'test@test.co.uk';
        cont.Phone = '0';
        cont.AccountId = acct.Id;                            
        insert cont;
        //Create Case;
        integer checker = 0;
        while(checker == 0)
        {
            Case testCase2 = new Case();
            testCase2.subject = 'TestingMSCase';
            testCase2.AccountId = acct.id;
            testCase2.ContactId = cont.id;
            testCase2.RecordTypeId = '012b0000000oRVk';
            testCase2.SuppliedEmail = 'test@test.co.uk';
            testCase2.SuppliedName = 'Test_name';
            testCase2.Description = 'Test';
            testCase2.CX_Sent__c = False;
            testCase2.Status = 'New';
            insert testCase2;
            testCase2 = [select id, Selected_for_CSAT__c, CaseNumber from case where id = : testCase2.id];
            if(testCase2.Selected_for_CSAT__c == 'Yes')
            {
                testCase2.Status = 'Closed';
                testCase2.MServices_Estimated_Hours_Worked__c = 1;
                testCase2.MServices_Estimated_Minutes_Worked__c = 1;
                testCase2.Cause__c = 'Payroll';
                testCase2.Request_Type__c = 'Leavers';
                update testCase2;
                update testCase2;
                checker = 1;   
            }
        }
    }
}