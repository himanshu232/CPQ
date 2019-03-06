@isTest
public class TestCX 
{
    @isTest static void TestingCX()
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
        //Create a Case
        integer checker = 0; 
        while(checker == 0)
        {
            Case testCase = new Case();
            testCase.subject = 'TestingCloudCase';
            testCase.AccountId = acct.id;
            testCase.ContactId = cont.id;
            testCase.RecordTypeId = '012b0000000M0S5';
            testCase.Product__c = 'iTrent';
            testCase.Description = 'Test';
            testCase.CX_Sent__c = False;
            testCase.Required_By_Date__c = date.newInstance(2017,08,18);
            testCase.Status = 'New';                        
            insert testCase;
            testCase = [select id, Selected_for_CSAT__c, CaseNumber from case where id = : testCase.id];
            testCase.Department__c = 'HRO IT Services';
            testCase.Status = 'Resolution Provided';
            testCase.Cause__c = 'Change';
            if(testCase.Selected_for_CSAT__c == 'Yes')
            {
                update testCase;
                checker = 1;
                testCase.Status = 'In Progress';
                testCase.CX_Sent__c = False;
                testCase.Cause__c = null;
                update testCase;
                testCase.Department__c = 'Service Desk';
        		update testCase;
                testCase.Status = 'Resolution Provided';
                testCase.Cause__c = 'Change';
                update testCase;
                
                //analytics
                testCase.Status = 'In Progress';
                testCase.CX_Sent__c = False;
                testCase.Cause__c = null;
                update testCase;
                testCase.Department__c = 'Business Analytics';
        		update testCase;
                testCase.Status = 'Resolution Provided';
                testCase.Cause__c = 'Change';
                update testCase;
            }
            
		}
    }
}