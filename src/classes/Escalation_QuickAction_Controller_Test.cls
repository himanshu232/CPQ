///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Unit Test: Escalation_QuickAction_Controller_Test
    // - Related Class: Escalation_QuickAction_Controller
    // - Author: AHA 𝝺
    // - Company: Oegen Ltd
    // - Created: 13/09/2017
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
@IsTest
public class Escalation_QuickAction_Controller_Test {
	static testMethod void testMethod1() {
        List<Contact> cList = new List<Contact>();
        List<User> uList = new List<User>();
        Account a = new Account(Name='Test Account');
        insert a;

        Contact c = new Contact(AccountID=a.Id, LastName='Test', Salutation='Mr');
        insert c;
        
        Case cs = new Case(AccountId=a.Id, contactId=c.Id, Department__c = 'Marketing');
        insert cs;
        Case cs2 = [SELECT Id, contactId, Escalation_Related_Department__c, Case_Owner_for_Escalations__c, AccountId FROM Case WHERE Id=:cs.Id LIMIT 1];
        System.debug('AHA - Debug - newcase ' + cs2);
 		Test.startTest();
            PageReference pageRef = Page.Escalation_QuickAction;
            PageRef.getParameters().put('id',cs.id);
            
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(cs2);
            Escalation_QuickAction_Controller controller = new Escalation_QuickAction_Controller(sc);
            controller.esc.Reason_for_Escalation__c = 'Other';
            controller.esc.Escalation_Details__c = 'Details go here';
            controller.saveEscalation();
        	controller.saveEscalation();
        	controller.esc.Reason_for_Escalation__c = 'Reason goes here';
        	controller.saveEscalation();
        	controller.redirectToLink();
        Test.stopTest();
        
        List<Escalation__c> ExList = [SELECT Id FROM Escalation__c];
        System.debug('AHA - Debug - ExList: ' + ExList);
        system.assert(ExList.size()>0);
    }
}