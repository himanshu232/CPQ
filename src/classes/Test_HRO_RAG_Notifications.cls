// ##################################################
// FOR: HRO_RAG_Notifications_Batch.cls, HRO_RAG_Notifications_Schedulable.cls
// ##################################################
@isTest
private class Test_HRO_RAG_Notifications {

	// #########################################
    // Test Data Setup
    // #########################################
    static Account a;
    static Scheduler__c schedule;
	public static String CRON_EXP = '0 0 0 15 3 ? 2050';

	static void createTestData() {
        a = Test_DataFactory.getAccount();
        Scheduler__c s22 = new Scheduler__c(Exclude_from_flows__c=true, Account__c=a.Id, Frequency__c='Monthly', Legislation_Country__c='UK', Schedule_Name__c='Test', Service_Type__c='Managed', Target_Completion__c=DateTime.now().addDays(30), Schedule_Responsibility__c='Operations');
        insert s22;
        schedule = s22;
        schedule.Authorised_By_Customer__c = true;
        //schedule.Amber_RAG_Email_Sent__c = false;
        //schedule.Red_RAG_Email_Sent__c = false;
        
        update schedule;
        

        List<Key_Dates__c> keyDatesToInsert = new List<Key_Dates__c>();
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, schedule.Id, 'BACS'));
        keyDatesToInsert.addAll(Test_DataFactory.getKeyDates(1, schedule.Id, 'Print'));
        insert keyDatesToInsert;

        List<Payroll_Stage__c> stagesToInsert = new List<Payroll_Stage__c>();
        stagesToInsert.addAll(Test_DataFactory.getStages(6, schedule.Id));
        
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

    }

	@isTest static void test_method_1_1() {
		////////////////////////////////////////
        //  RAG Green but Amber_RAG_Email_Sent__c is true
        ////////////////////////////////////////
        createTestData();
        
        //arrange
        //

//act


		DateTime future = DateTime.now().addMinutes(30);

		List<Activity_Checklist__c> checks = [SELECT Id FROM Activity_Checklist__c];
		for(Activity_Checklist__c c : [SELECT Id FROM Activity_Checklist__c]) {
			c.Completed__c = true;
		}
		update checks;
		List<Payroll_Activities__c> pas = [SELECT Id, Activity_Completed__c, RAG_Status_Text__c FROM Payroll_Activities__c];
		for(Payroll_Activities__c pa : pas) {
			pa.Amber_RAG_Email_Sent__c = true;
			pa.Estimated_Minutes_To_Complete__c = 15;
			pa.End_Date_Time__c = future;
		}
		update pas;
        List<Payroll_Stage__c> stages = [SELECT Id FROM Payroll_Stage__c];
        for(Payroll_Stage__c s : stages) {
            s.Amber_RAG_Email_Sent__c = true;
        }
        update stages;
        List<Scheduler__c> scheds = [SELECT Id FROM Scheduler__c];
        for(Scheduler__c s : scheds) {
            s.Amber_RAG_Email_Sent__c = true;
        }
        update scheds;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		//Database.executeBatch(b, 1);
		//HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
       	//b.lim = '200';
        //Database.executebatch(b);
        
        Test.stopTest();
	}
	
	@isTest static void test_method_1_2() {
		////////////////////////////////////////
        //  RAG Amber
        ////////////////////////////////////////
        createTestData();

		DateTime future = DateTime.now().addMinutes(30);

        List<Activity_Checklist__c> checks = [SELECT Id FROM Activity_Checklist__c];
		for(Activity_Checklist__c c : [SELECT Id FROM Activity_Checklist__c]) {
			c.Completed__c = false;
		}
		update checks;
        
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c];
		for(Payroll_Activities__c pa : pas) {
			pa.Estimated_Minutes_To_Complete__c = 60;
			pa.End_Date_Time__c = future;
		}
		update pas;
        
        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Amber', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

    	@isTest static void test_method_1_3() {
		////////////////////////////////////////
        //  RAG Amber but Red_RAG_Email_Sent__c = true
        ////////////////////////////////////////
        createTestData();

		DateTime future = DateTime.now().addMinutes(30);

		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c];
		for(Payroll_Activities__c pa : pas) {
			pa.Estimated_Minutes_To_Complete__c = 60;
			pa.End_Date_Time__c = future;
            pa.Red_RAG_Email_Sent__c = true;
		}
		update pas;
        List<Payroll_Stage__c> stages = [SELECT Id FROM Payroll_Stage__c];
        for(Payroll_Stage__c s : stages) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update stages;
        List<Scheduler__c> scheds = [SELECT Id FROM Scheduler__c];
        for(Scheduler__c s : scheds) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update scheds;
        
        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Amber', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
       	b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

	@isTest static void test_method_1_4() {
		////////////////////////////////////////
        //  RAG Red
        ////////////////////////////////////////
        createTestData();

		DateTime past = DateTime.now().addMinutes(-30);

		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c];
		for(Payroll_Activities__c pa : pas) {
			pa.Estimated_Minutes_To_Complete__c = 15;
			pa.End_Date_Time__c = past;
		}
		update pas;
        
        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Red', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

    @isTest static void test_method_1_5() {
		////////////////////////////////////////
        //  Amber Email sent on Activities/Stages/Schedules, which is then changed to Green by batch apex
        ////////////////////////////////////////
        createTestData();
        
        List<Scheduler__c> schedules = [Select Id FROM Scheduler__c];
        for(Scheduler__c s : schedules) {
            s.Amber_RAG_Email_Sent__c = true;
        }
        update schedules;
        List<Payroll_Stage__c> stages = [Select Id FROM Payroll_Stage__c WHERE Schedule__c = :schedules[0].Id];
		for(Payroll_Stage__c s : stages) {
            s.Amber_RAG_Email_Sent__c = true;
        }
		update stages;
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c WHERE Payroll_Stage__c = :stages[0].Id];
		for(Payroll_Activities__c pa : pas) {
            pa.Estimated_Minutes_To_Complete__c = 20;
			pa.End_Date_Time__c = DateTime.now().addMinutes(60);
            pa.Amber_RAG_Email_Sent__c = true;
        }
        update pas;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

    @isTest static void test_method_1_6() {
		////////////////////////////////////////
        //  Red Email sent on Activities/Stages/Schedules, which is then changed to Green by batch apex
        ////////////////////////////////////////
        createTestData();
        List<Scheduler__c> schedules = [Select Id FROM Scheduler__c];
        for(Scheduler__c s : schedules) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update schedules;
        List<Payroll_Stage__c> stages = [Select Id FROM Payroll_Stage__c WHERE Schedule__c = :schedules[0].Id];
		for(Payroll_Stage__c s : stages) {
            s.Red_RAG_Email_Sent__c = true;
        }
		update stages;
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c WHERE Payroll_Stage__c = :stages[0].Id];
		for(Payroll_Activities__c pa : pas) {
            pa.Estimated_Minutes_To_Complete__c = 20;
			pa.End_Date_Time__c = DateTime.now().addMinutes(60);
            pa.Red_RAG_Email_Sent__c = true;
        }
        update pas;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
    }

    @isTest static void test_method_1_7() {
		////////////////////////////////////////
        //  Amber Activities, Red Stage/Schedule, One Genuinely Red Stage
        ////////////////////////////////////////
        createTestData();
        
        List<Scheduler__c> schedules = [Select Id FROM Scheduler__c];
        for(Scheduler__c s : schedules) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update schedules;
        List<Payroll_Stage__c> stages = [Select Id FROM Payroll_Stage__c WHERE Schedule__c = :schedules[0].Id];
		for(Payroll_Stage__c s : stages) {
            s.Red_RAG_Email_Sent__c = true;
        }
		update stages;
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c WHERE Payroll_Stage__c = :stages[0].Id];
		for(Payroll_Activities__c pa : pas) {
            pa.Estimated_Minutes_To_Complete__c = 20;
			pa.End_Date_Time__c = DateTime.now().addMinutes(10);
            pa.Amber_RAG_Email_Sent__c = true;
        }
        pas[0].Estimated_Minutes_To_Complete__c = 20;
		pas[0].End_Date_Time__c = DateTime.now().addMinutes(-30);
        pas[0].Red_RAG_Email_Sent__c = true;
        update pas;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

    @isTest static void test_method_1_8() {
		////////////////////////////////////////
        //  Red Stages/Schedule, Green Activities, One genuinely Red Stage
        ////////////////////////////////////////
        createTestData();
        
		List<Scheduler__c> schedules = [Select Id FROM Scheduler__c];
        for(Scheduler__c s : schedules) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update schedules;
        List<Payroll_Stage__c> stages = [Select Id FROM Payroll_Stage__c WHERE Schedule__c = :schedules[0].Id];
		for(Payroll_Stage__c s : stages) {
            s.Red_RAG_Email_Sent__c = true;
        }
		update stages;
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c WHERE Payroll_Stage__c = :stages[0].Id];
		for(Payroll_Activities__c pa : pas) {
            pa.Estimated_Minutes_To_Complete__c = 20;
			pa.End_Date_Time__c = DateTime.now().addMinutes(60);
        }
        pas[0].Estimated_Minutes_To_Complete__c = 20;
		pas[0].End_Date_Time__c = DateTime.now().addMinutes(-30);
        pas[0].Red_RAG_Email_Sent__c = true;
        update pas;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}

    @isTest static void test_method_1_9() {
		////////////////////////////////////////
        //  Red Stages/Schedule, Green Activities, One genuinely Amber Stage
        ////////////////////////////////////////
        createTestData();
        
		List<Scheduler__c> schedules = [Select Id FROM Scheduler__c];
        for(Scheduler__c s : schedules) {
            s.Red_RAG_Email_Sent__c = true;
        }
        update schedules;
        List<Payroll_Stage__c> stages = [Select Id FROM Payroll_Stage__c WHERE Schedule__c = :schedules[0].Id];
		for(Payroll_Stage__c s : stages) {
            s.Red_RAG_Email_Sent__c = true;
        }
		update stages;
		List<Payroll_Activities__c> pas = [Select Id FROM Payroll_Activities__c WHERE Payroll_Stage__c = :stages[0].Id];
		for(Payroll_Activities__c pa : pas) {
            pa.Estimated_Minutes_To_Complete__c = 20;
			pa.End_Date_Time__c = DateTime.now().addMinutes(60);
        }
        pas[0].Estimated_Minutes_To_Complete__c = 20;
		pas[0].End_Date_Time__c = DateTime.now().addMinutes(10);
        pas[0].Amber_RAG_Email_Sent__c = true;
        update pas;

        Test.startTest();

        // Schedule the test job
		String jobId = System.schedule('HRO Scheduler RAG Notifications Green', CRON_EXP, new HRO_RAG_Notifications_Schedulable());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        b.lim = '200';
        
        //Database.executebatch(b);
        Test.stopTest();
	}
	
}