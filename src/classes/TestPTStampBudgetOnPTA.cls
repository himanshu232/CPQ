@isTest
public class TestPTStampBudgetOnPTA {
@isTest static void TestPutBudgetOnProjectTask(){
        
    //Create Account
        Account acct = new Account();
        acct.name='TestTrigger';
        acct.Type = 'Customer';
        insert acct;
    //Create Contact;
        Contact cont = new Contact();
        cont.LastName = 'Test_LastName';
        cont.AccountId = acct.Id;
        insert cont;
    //Create a project
        pse__proj__c Proj = new pse__proj__c(Name = 'IAJTestInsert',pse__is_active__c = True);
        insert Proj;
        //Create a project task
        pse__Project_Task__c PT = new pse__Project_Task__c(Name = 'IAJTest',pse__Project__c = Proj.ID);
        PT.pse__Start_Date_Time__c = date.parse('06/06/2017');
        PT.pse__Actual_Hours__c = 3;
        insert PT;
        //Create Project Task Assignment
        pse__Project_Task_Assignment__c PTA = new pse__Project_Task_Assignment__c(pse__Project_Task__c = PT.ID,pse__resource__c = cont.id);
        insert PTA;
        //Add new budget
        pse__Budget__c B = new pse__Budget__c(pse__project__c = proj.id);
        B.Expiry_Date__c = Date.parse('01/01/2018');
        B.Total_Days__c = 50;
        insert B;
        // add budget to Project Task
        test.startTest();    
        PT.Budget__c= B.ID;
        PT.pse__Actual_Hours__c = 6;
        update PT;
        test.stopTest();
        
        
        
    }
}