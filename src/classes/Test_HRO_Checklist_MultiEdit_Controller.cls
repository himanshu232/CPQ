@isTest
private class Test_HRO_Checklist_MultiEdit_Controller {
    // ##################################################
    // FOR: HRO_Checklist_MultiEdit_Controller.cls
    // John Hutchinson 🌵 2017.06
    // ##################################################

    static Account ac1 = new Account();
    static Scheduler__c sched = new Scheduler__c();
    static Payroll_Stage__c stage = new Payroll_Stage__c();
    static Payroll_Activities__c activity = new Payroll_Activities__c();
    static Activity_Checklist__c chk1 = new Activity_Checklist__c();
    static Activity_Checklist__c chk2 = new Activity_Checklist__c();
    static Activity_Checklist__c chk3 = new Activity_Checklist__c();
    
    static User player1 = new user();


    public static void setupData() {
        ////////////////////////////////////////
        //  Setup test data
        ////////////////////////////////////////

        ac1 = Test_DataFactory.getAccount();
        sched = Test_DataFactory.getSchedules(1, ac1.Id, 'Monthly')[0];
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
        insert new List<Activity_Checklist__c>{chk1,chk2,chk3};

        player1 = Test_DataFactory.createNoPortalUser();

    }


    @isTest
    static void test_A_1() {
        ////////////////////////////////////////
        //  Load page, save no changes.
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));
            System.assert(cont.activityChecklist.size() == 3);
            System.assert(cont.updatedChecklist.size() == 0);

            cont.onSave();
            System.assert( cont.feedbackPos.containsKey(200) );             // Nothing to save.
        }

    }
    

    @isTest
    static void test_A_2() {
        ////////////////////////////////////////
        //  Load page, save Changes.
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));
            System.assert(cont.activityChecklist.size() == 3);
            System.assert(cont.feedbackBool == FALSE);
            System.assert(cont.hasApexMessages == FALSE);

            cont.activityChecklist[0].Started__c = TRUE;
            cont.activityChecklist[0].Completed__c = TRUE;


            cont.onSave();
            System.assert(cont.updatedChecklist.size() == 1);
            System.assert(cont.feedbackPos.containsKey(201) );              // Updated
            System.assert(cont.feedbackBool == TRUE);
        }

    }

    @isTest
    static void test_A_3() {
        ////////////////////////////////////////
        //  Load page, change one item to 'Completed' but not 'Started', save Changes.
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));
            System.assert(cont.activityChecklist.size() == 3);
            System.assert(cont.feedbackBool == FALSE);
            System.assert(cont.hasApexMessages == FALSE);

            cont.activityChecklist[0].Started__c = FALSE;
            cont.activityChecklist[0].Completed__c = TRUE;


            cont.onSave();
            System.assert(cont.updatedChecklist.size() == 1);
            System.assert(cont.feedbackPos.containsKey(201) );              // Updated
            System.assert(cont.feedbackBool == TRUE);
        }

    }

    @isTest
    static void test_B_1() {
        ////////////////////////////////////////
        //  Load page after clicking through from List View (use StandardSetController)
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;

        List<Activity_Checklist__c> activityChecks = [SELECT Id FROM Activity_Checklist__c];

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(activityChecks);
            stdSetController.setSelected(activityChecks);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(stdSetController);

            System.assert(cont.activityChecklist.size() == 3);
            System.assert(cont.feedbackBool == FALSE);
            System.assert(cont.hasApexMessages == FALSE);

            cont.activityChecklist[0].Started__c = TRUE;
            cont.activityChecklist[0].Completed__c = TRUE;


            cont.onSave();
            System.assert(cont.updatedChecklist.size() == 1);
            System.assert(cont.feedbackPos.containsKey(201) );
            System.assert(cont.feedbackBool == TRUE);
        }

    }
    

    @isTest
    static void test_F_1() {
        ////////////////////////////////////////
        //  Load page without activity param.
        //  Invalid activity
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', '');  
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));

            System.assert( cont.feedbackNeg.containsKey(-404) );            // INVALID
            System.assert( cont.activityName == 'INVALID' );
            System.assert( cont.invalidOrig == TRUE);
        }

    }


    @isTest
    static void test_F_2() {
        ////////////////////////////////////////
        //  Load page, Fail to save Changes.
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));
            System.assert(cont.activityChecklist.size() == 3);
            System.assert(cont.invalidOrig == FALSE);

            cont.activityChecklist[0].Started__c = TRUE;
            cont.activityChecklist[0].Completed__c = TRUE;
            cont.activityChecklist[1].Sequence_Number__c = 1000;

            cont.onSave();
            System.assert(cont.updatedChecklist.size() == 2, cont.updatedChecklist.size() );

            System.assert( cont.feedbackNeg.containsKey(-1), cont.feedbackPos );                
        }

    }


    @isTest
    static void test_F_5() {
        ////////////////////////////////////////
        //  Load page, Cancel
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               // -Hj- The Page now testing

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));

            System.assert(cont.activityChecklist.size() == 3);

            cont.activityChecklist[0].Started__c = TRUE;

            cont.onCancel();
            System.assert(cont.doNavigate == TRUE );

            System.assert( cont.feedbackNeg.isEmpty() );
        }

    }
    
    @isTest
    static void test_AHA_1() {
        ////////////////////////////////////////
        //  Load page, Cancel
        ////////////////////////////////////////
        setupData();
        PageReference pageRef = Page.HRO_Checklist_MultiEdit;               

        Test.startTest();
        System.runAs(player1){
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ActivityId', activity.Id);
            HRO_Checklist_MultiEdit_Controller cont = new HRO_Checklist_MultiEdit_Controller(new ApexPages.StandardController(activity));

            
            
            PageReference pRef1 = cont.changeActivity();
            cont.onSaveAndContinue();
            cont.popupOneDecisionYes();
            cont.StartTimeCardIfNone();
            PageReference pRef3 = cont.onReturnProcessing();
            PageReference pRef2 = cont.onReturn();
            PageReference pRef4 = cont.changeCheck();
            
            cont.closePopup();
        }

    }

}