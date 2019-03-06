@isTest (SeeAllData=false)
public class case_Helper_Tests_oegen {
     public static testMethod void SetDeptandTeamTest(){
/*         Account a2 = new Account(Name = 'SysPay2', Account_Reference__c = 'SY789SY2', Customer_Code__c = '78PP21', Core_HR__c = 'People', Payroll__c = 'Additional Pay Runs',
            HESA__c = 'Not Sold', QAS__c = 'Not Started', PERCS__c = 'Future Phase', LGPS_2014__c = 'Testing', Fully_Managed_Payroll__c = true,
            P45__c = false, P60__c = true);
        insert a2;
      
        Contact ct2 = new Contact(lastname = 'Mark', AccountId = a2.id, Contact_Reference__c = 'Mark60L');
        insert ct2;
        
        Profile p3 = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u3 = new User(Alias = 'standt3', Email='211362473411@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p3.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='211362473411@testorg.com');

        Group chosenQueue = [SELECT Id, Name FROM Group LIMIT 1];
        List<Id> anotherInsertedCase = new List<Id>();
        
        System.runAs(u3) {
            Case c2 = new case(OwnerId = chosenQueue.Id, AccountId = a2.id, ContactId=ct2.Id, Service_Desk_Owner_LP__c = null, Subject = 'Subject', Status = 'New', Case_Categories__c = 'A - 1 day', 
                          Department__c = null, Team__c = null, Product__c = 'iTrent', Module__c = 'Core HR', Release_Version__c = '1', Age__c = 2, Required_By_Date__c = Date.Today());
            insert c2;
            anotherInsertedCase.add(c2.Id);
        }
        Team_Mapping__c teamMap = new Team_Mapping__c(Name='Service Desk', Department__c='Service Desk', Roles__c='Service Desk - First Line Support Team Leader,Service Desk - First Line Support Team Member');
        insert teamMap;
        
        Test.startTest();
        bg_Case_Helper.SetDepartmentAndTeamForCase(anotherInsertedCase);
        Test.stopTest(); */
     }
    
}