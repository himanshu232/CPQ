///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Unit Test: ogn_CloseTimescards_Batch_Test
    // - Related Class: ogn_CloseTimescards_Batch
    // - Author: AHA 𝝺
    // - Company: Oe:gen Ltd
    // - Created: 23/04/2018
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
@IsTest
public class ogn_CloseTimescards_Batch_Test {
	static Account a;
   	static Scheduler__c schedule;
    static List<Payroll_Activities__c> activitiesToInsert;
    static testMethod void testMethod1() {
        
        createTestData();
        Time_Card__c tc = new Time_Card__c();
        tc.Start__c = system.today();
        tc.Activity__c = activitiesToInsert[0].id;
        insert tc;
        
        ogn_CloseTimescards_Batch b = new ogn_CloseTimescards_Batch();
    	database.executebatch(b, 200);
    }
    
    static void createTestData() {
        a = Test_DataFactory.getAccount();
        schedule = Test_DataFactory.getSchedules(1, a.Id, 'Monthly')[0];

        List<Key_Dates__c> keyDatesToInsert = new List<Key_Dates__c>();
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, schedule.Id, 'BACS'));
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, schedule.Id, 'Print'));
        insert keyDatesToInsert;

        List<Payroll_Stage__c> stagesToInsert = new List<Payroll_Stage__c>();
        stagesToInsert.addAll(Test_DataFactory.getStages(6, schedule.Id));
        insert stagesToInsert;
        
        activitiesToInsert = new List<Payroll_Activities__c>();
        for(Payroll_Stage__c s : stagesToInsert) {
            activitiesToInsert.addAll(Test_DataFactory.getActivities(2, s.Id, 60));
        }
        insert activitiesToInsert;

        List<Activity_Checklist__c> checksToInsert = new List<Activity_Checklist__c>();
        for(Payroll_Activities__c a : activitiesToInsert) {
            checksToInsert.addAll(Test_DataFactory.getActivityChecks(12, a.Id));
        }
        insert checksToInsert;
    }
}