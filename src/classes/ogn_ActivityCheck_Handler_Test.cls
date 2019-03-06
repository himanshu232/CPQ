///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Unit Test: ogn_ActivityCheck_Handler_Test
    // - Related Class: ogn_ActivityCheck_Handler
    // - Author: AHA 𝝺
    // - Company: Oe:gen Ltd
    // - Created: 13/08/2018
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
@IsTest
public class ogn_ActivityCheck_Handler_Test {
	static testMethod void testMethod1() {
        Account ac1 = new Account(Name='Test',Industry='COM - Banking, Finance & Insurance', NumberOfEmployees=100, CurrencyIsoCode='GBP');
		insert ac1;
	Scheduler__c sched = new Scheduler__c();
    Payroll_Stage__c stage = new Payroll_Stage__c();
    Payroll_Activities__c activity = new Payroll_Activities__c();
    Activity_Checklist__c chk1 = new Activity_Checklist__c();
    Activity_Checklist__c chk2 = new Activity_Checklist__c();
    Activity_Checklist__c chk3 = new Activity_Checklist__c();
        
        
        
        sched = new Scheduler__c(Exclude_from_flows__c=true, Account__c=ac1.Id, Frequency__c='Monthly', Legislation_Country__c='UK', Schedule_Name__c='Test', Service_Type__c='Fully Managed', Target_Completion__c=DateTime.now().addDays(30), Schedule_Responsibility__c='Avengers');
            insert sched;
        stage = Test_DataFactory.getStages(1, sched.Id)[0];
        insert stage;
        activity = Test_DataFactory.getActivities(1, stage.Id, 60)[0];
        
        insert activity;
        chk1 = Test_DataFactory.getActivityChecks(1, activity.Id)[0];
        chk1.Sequence_Number__c = 1;
        chk2 = Test_DataFactory.getActivityChecks(1, activity.Id)[0];
        chk2.Sequence_Number__c = 2;
        chk3 = Test_DataFactory.getActivityChecks(1, activity.Id)[0];
        chk3.Sequence_Number__c = 3;
  		chk3.Linked_Schedule__c = sched.Id;
        chk3.Completed__c = false;
        chk3.Notification_Message__c = '%%Action test test test';
        insert new List<Activity_Checklist__c>{chk1,chk2,chk3};
        Key_Dates__c kd = new Key_Dates__c();
        kd.Schedule__c = sched.Id;
        kd.Record_Description__c = 'Print';
        kd.Activity_Check__c = chk3.Id;
        kd.Assigned_To__c = 'Raven';
        kd.Automate_Date_Time_1__c = true;
        kd.Automate_Date_Time_2__c = true;
        kd.Automate_Date_Time_3__c = true;
        insert kd;
        chk3.Notification_Message__c = '%%Action test test test3';
        chk3.Completed__c = true;
        update chk3;
        chk3.Completed__c = false;
        update chk3;

    }
}