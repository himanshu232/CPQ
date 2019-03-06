// ##################################################
// FOR: HRO_Scheduler.cls, HRO_Scheduler_Utility.cls, HRO_Scheduler_Batch.cls, HRO_Scheduler_Schedulable.cls
// ##################################################
@isTest
private class Test_HRO_Scheduler {

    // #########################################
    // Test Data Setup
    // #########################################
    static Account a;
    static Account a2;
    static Scheduler__c mainSchedule;
    static HRO_Scheduler c;
    //otherSchedule's purpose is to make sure other Schedules aren't affected when mainSchedule is replicated/worked on
    static Scheduler__c otherSchedule;
    static DateTime oneBankHoliday;
    public static String CRON_EXP = '0 0 0 15 3 ? 2050';

    static void createBasicTestData(String frequency) {
        a = Test_DataFactory.getAccount();
        mainSchedule = Test_DataFactory.getSchedules(1, a.Id, frequency)[0];
        otherSchedule = Test_DataFactory.getSchedules(1, a.Id, 'Weekly')[0];
        oneBankHoliday = Test_DataFactory.getBankHolidays()[0].Bank_Holiday_Date__c;
    }

    static void createReplicationTestData() {
        a2 = Test_DataFactory.getAccount();

        List<Key_Dates__c> keyDatesToInsert = new List<Key_Dates__c>();
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, mainSchedule.Id, 'BACS'));
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, mainSchedule.Id, 'Print'));
        insert keyDatesToInsert;

        List<Payroll_Stage__c> stagesToInsert = new List<Payroll_Stage__c>();
        stagesToInsert.addAll(Test_DataFactory.getStages(6, mainSchedule.Id));
        insert stagesToInsert;
        
        List<Payroll_Activities__c> activitiesToInsert = new List<Payroll_Activities__c>();
        for(Payroll_Stage__c s : stagesToInsert) {
            activitiesToInsert.addAll(Test_DataFactory.getActivities(2, s.Id, 60));
        }
        insert activitiesToInsert;

        List<Activity_Checklist__c> checksToInsert = new List<Activity_Checklist__c>();
        for(Payroll_Activities__c a : activitiesToInsert) {
            checksToInsert.addAll(Test_DataFactory.getActivityChecks(12, a.Id));
        }
        insert checksToInsert;

        mainSchedule.Exclude_from_flows__c = false;
        otherSchedule.Exclude_from_flows__c = false;
        update new List<Scheduler__c>{mainSchedule,otherSchedule};
    }

    // #########################################
    // Visualforce Page Setup
    // #########################################
    static PageReference pr;
    static void createVfTestData() {
        createBasicTestData('Monthly');
        pr = Page.HRO_Replicate_Schedule;
        pr.getParameters().put('id', mainSchedule.Id);
    }
    
    ////////////////////////////////////////
    //  HRO_Scheduler.cls Tests
    ////////////////////////////////////////
    @isTest
    static void test_1_1() {
        ////////////////////////////////////////
        //  General VF Tests
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        
        System.assertNotEquals(null, c.getScheduleCompletionDateOpts());
        System.assertEquals('true', c.adjustFirstReplication);
        System.assertEquals(0, c.feedbackNegCount);
        System.assertEquals(0, c.feedbackPosCount);
        System.assertEquals(false, c.showContinue);
        System.assertEquals(false, c.hasApexMessages);

        c.feedbackNeg.add('Error');
        System.assertEquals(1, c.feedbackNegCount);
        c.feedbackPos.add('Success');
        System.assertEquals(1, c.feedbackPosCount);
        c.adjustFirstReplication = 'false';
        System.assertEquals('false', c.adjustFirstReplication);

        Test.stopTest();
        
    }
    
    @isTest
    static void test_1_2() {
        ////////////////////////////////////////
        //  Form input validation
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        c.oldSchedule.When__c = 'Now';

        c.oldSchedule.Replicate_to_Account__c = null;
        c.oldSchedule.How_many_times__c = 999;
        c.replicateSchedule();
        System.assertEquals(1, c.feedbackNeg.size());
        System.assertEquals('', c.destination);
        System.assertEquals(false, c.showContinue);

        c.oldSchedule.Replicate_to_Account__c = a.Id;
        c.replicateSchedule();
        System.assertEquals(1, c.feedbackNeg.size());
        System.assertEquals('', c.destination);
        System.assertEquals(false, c.showContinue);

        c.oldSchedule.When__c = '';
        c.replicateSchedule();
        System.assertEquals(1, c.feedbackNeg.size());
        System.assertEquals('', c.destination);
        System.assertEquals(false, c.showContinue);

        c.oldSchedule.When__c = 'Now';
        c.oldSchedule.How_many_times__c = 12;
        c.replicateSchedule();
        System.assertEquals(0, c.feedbackNeg.size());
        System.assertEquals(true, c.oldSchedule.Exclude_from_Flows__c);
        System.assertEquals(true, c.oldSchedule.Adjust_First_Replication_Dates__c);
        System.assertEquals(1, c.feedbackPos.size());
        System.assertEquals('account', c.destination);
        System.assertEquals(true, c.showContinue);

        Test.stopTest();

    }

    @isTest
    static void test_1_3() {
        ////////////////////////////////////////
        //  Replicate Tonight
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        c.oldSchedule.When__c = 'Tonight';
        c.oldSchedule.How_many_times__c = 12;

        c.replicateSchedule();

        System.assertEquals(0, c.feedbackNeg.size());
        System.assertEquals(false, c.oldSchedule.Exclude_from_Flows__c);
        System.assertEquals(true, c.oldSchedule.Adjust_First_Replication_Dates__c);
        System.assertEquals(true, c.oldSchedule.Replicate_this_Schedule__c);
        System.assertEquals('Ready to Replicate', c.oldSchedule.Replication_Status__c);
        System.assertEquals(1, c.feedbackPos.size());
        System.assertEquals('back', c.destination);
        System.assertEquals(true, c.showContinue);

        Test.stopTest();

    }

    @isTest
    static void test_1_4() {
        ////////////////////////////////////////
        //  Replication on hold
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        c.oldSchedule.When__c = 'Hold';
        c.oldSchedule.How_many_times__c = 12;

        c.replicateSchedule();

        System.assertEquals(0, c.feedbackNeg.size());
        System.assertEquals(false, c.oldSchedule.Exclude_from_Flows__c);
        System.assertEquals(true, c.oldSchedule.Adjust_First_Replication_Dates__c);
        System.assertEquals(true, c.oldSchedule.Replicate_this_Schedule__c);
        System.assertEquals('', c.oldSchedule.Replication_Status__c);
        System.assertEquals(1, c.feedbackPos.size());
        System.assertEquals('back', c.destination);
        System.assertEquals(true, c.showContinue);

        Test.stopTest();

    }

    @isTest
    static void test_1_5() {
        ////////////////////////////////////////
        //  Long-running replication now (over 12 times)
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        c.oldSchedule.When__c = 'Now';
        c.oldSchedule.How_many_times__c = 52;

        c.replicateSchedule();

        System.assertEquals(0, c.feedbackNeg.size());
        System.assertEquals(true, c.oldSchedule.Exclude_from_Flows__c);
        System.assertEquals(true, c.oldSchedule.Adjust_First_Replication_Dates__c);
        System.assertEquals(1, c.feedbackPos.size());
        System.assertEquals('account', c.destination);
        System.assertEquals(true, c.showContinue);

        Test.stopTest();

    }

    @isTest
    static void test_1_6() {
        ////////////////////////////////////////
        //  Wreak havoc
        ////////////////////////////////////////
        createVfTestData();
        
        Test.startTest();
        Test.setCurrentPage(pr);
        c = new HRO_Scheduler(new ApexPages.StandardController(mainSchedule));
        c.oldSchedule.When__c = 'Now';
        c.oldSchedule.How_many_times__c = 12;

        // Havoc ensues
        c.oldSchedule.Id = null;
        c.replicateSchedule();

        System.assertEquals(1, c.feedbackNeg.size());
        System.assertEquals(true, c.oldSchedule.Exclude_from_Flows__c);
        System.assertEquals(true, c.oldSchedule.Adjust_First_Replication_Dates__c);
        System.assertEquals(0, c.feedbackPos.size());
        System.assertEquals('', c.destination);
        System.assertEquals(false, c.showContinue);

        Test.stopTest();

    }

    ////////////////////////////////////////
    //  HRO_Scheduler_Utility.cls Tests
    ////////////////////////////////////////
    @isTest
    static void test_2_1() {
        ////////////////////////////////////////
        //  Monthly Schedule, replicated to same Account, adjusting first Schedule date by 1 month
        ////////////////////////////////////////
        createBasicTestData('Monthly');
        createReplicationTestData();
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 12;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = true;
        mainSchedule.Replicate_to_Account__c = a.Id;
        update mainSchedule;
        
        Test.startTest();

        Map<String,List<String>> response = HRO_Scheduler_Utility.replicateSchedules(new List<Id>{mainSchedule.Id}, false);
        
        Test.stopTest();
        
    }

    @isTest
    static void test_2_2() {
        ////////////////////////////////////////
        //  Weekly Schedule, replicated to different Account, keeping the first Schedule date as-is (not adjusted)
        ////////////////////////////////////////
        createBasicTestData('Weekly');
        createReplicationTestData();
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 52;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = false;
        mainSchedule.Replicate_to_Account__c = a2.Id;
        update mainSchedule;
        
        Test.startTest();

        HRO_Scheduler_Utility.replicateSchedulesAsync(new List<Id>{mainSchedule.Id});
        
        Test.stopTest();
        
    }

    @isTest
    static void test_2_3() {
        ////////////////////////////////////////
        //  Fortnightly Schedule, replicated to different Account, keeping the first Schedule date as-is (not adjusted)
        ////////////////////////////////////////
        createBasicTestData('Fortnightly');
        createReplicationTestData();
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 26;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = false;
        mainSchedule.Replicate_to_Account__c = a2.Id;
        update mainSchedule;
        
        Test.startTest();

        HRO_Scheduler_Utility.replicateSchedulesAsync(new List<Id>{mainSchedule.Id});
        
        Test.stopTest();
        
    }

    @isTest
    static void test_2_4() {
        ////////////////////////////////////////
        //  Lunar Schedule, replicated to different Account, keeping the first Schedule date as-is (not adjusted)
        ////////////////////////////////////////
        createBasicTestData('Lunar');
        createReplicationTestData();
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 12;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = false;
        mainSchedule.Replicate_to_Account__c = a2.Id;
        update mainSchedule;
        
        Test.startTest();

        Map<String,List<String>> response = HRO_Scheduler_Utility.replicateSchedules(new List<Id>{mainSchedule.Id}, false);
        
        Test.stopTest();
        
    }

    @isTest
    static void test_2_5() {
        ////////////////////////////////////////
        //  Quarterly Schedule, replicated to different Account, keeping the first Schedule date as-is (not adjusted)
        ////////////////////////////////////////
        createBasicTestData('Quarterly');
        createReplicationTestData();
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 4;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = false;
        mainSchedule.Replicate_to_Account__c = a2.Id;
        update mainSchedule;
        
        Test.startTest();

        Map<String,List<String>> response = HRO_Scheduler_Utility.replicateSchedules(new List<Id>{mainSchedule.Id}, false);
        
        Test.stopTest();
        
    }

    @isTest
    static void test_2_6() {
        ////////////////////////////////////////
        //  Annual Schedule, replicated to the same Account, adjusting the first Schedule date, Activities have end dates
        ////////////////////////////////////////
        createBasicTestData('Annually');
        createReplicationTestData();
        List<Payroll_Activities__c> activities = [SELECT Id FROM Payroll_Activities__c WHERE Payroll_Stage__r.Schedule__c = :mainSchedule.Id];
        for(Payroll_Activities__c pa : activities) {
            pa.End_Date_Time__c = DateTime.now().addDays(20);
        }
        update activities;
        mainSchedule.When__c = 'Now';
        mainSchedule.How_many_times__c = 1;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = true;
        update mainSchedule;
        
        Test.startTest();

        Map<String,List<String>> response = HRO_Scheduler_Utility.replicateSchedules(new List<Id>{mainSchedule.Id}, false);
        
        Test.stopTest();
        
    }

    ////////////////////////////////////////
    //  HRO_Scheduler_Batch.cls, HRO_Scheduler_Schedulable.cls Tests
    ////////////////////////////////////////
    @isTest
    static void test_3_1() {
        ////////////////////////////////////////
        //  Monthly Schedule, replicated to same Account, adjusting first Schedule date by 1 month, replicate tonight (scheduled)
        ////////////////////////////////////////
        createBasicTestData('Monthly');
        createReplicationTestData();
        mainSchedule.When__c = 'Tonight';
        mainSchedule.How_many_times__c = 12;
        mainSchedule.Replicate_this_Schedule__c = true;
        mainSchedule.Adjust_First_Replication_Dates__c = true;
        mainSchedule.Replicate_to_Account__c = a.Id;
        mainSchedule.Replication_Status__c = 'Ready to Replicate';
        update mainSchedule;
        
        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler Schedulable Test', CRON_EXP, new HRO_Scheduler_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        
        Test.stopTest();
        
    }

}