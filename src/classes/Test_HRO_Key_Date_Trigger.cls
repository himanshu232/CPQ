// ##################################################
// FOR: HRO_Key_Date_Trigger.trigger, HRO_Key_Date_Trigger_Handler.cls
// ##################################################
@isTest
private class Test_HRO_Key_Date_Trigger {

    // #########################################
    // Test Data Setup
    // #########################################
    static Account a;
    static Scheduler__c schedule;
    static Key_Dates__c bacsKeyDate;
    static Key_Dates__c printKeyDate;

    static void createTestData() {
        a = Test_DataFactory.getAccount();
        schedule = Test_DataFactory.getSchedules(1, a.Id, 'Monthly')[0];
        bacsKeyDate = Test_DataFactory.getKeyDates(1, schedule.Id, 'BACS')[0];
        printKeyDate = Test_DataFactory.getKeyDates(1, schedule.Id, 'Print')[0];
    }
    
    @isTest static void test_1_1() {
        ////////////////////////////////////////
        //  Test After Insert, dates not today (see Data Factory for date)
        ////////////////////////////////////////
        createTestData();

        Test.startTest();

        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();

    }

    @isTest static void test_1_2() {
        ////////////////////////////////////////
        //  Test After Insert, date 1 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();

        Test.startTest();

        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();

    }

    @isTest static void test_1_3() {
        ////////////////////////////////////////
        //  Test After Insert, date 2 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_2__c = DateTime.now();
        printKeyDate.Date_Time_2__c = DateTime.now();

        Test.startTest();

        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();

    }

    @isTest static void test_1_4() {
        ////////////////////////////////////////
        //  Test After Insert, date 3 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_3__c = DateTime.now();
        printKeyDate.Date_Time_3__c = DateTime.now();

        Test.startTest();

        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();

    }
    
    @isTest static void test_2_1() {
        ////////////////////////////////////////
        //  Test After Update, dates not today
        ////////////////////////////////////////
        createTestData();
        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        bacsKeyDate.Note_1__c = 'Test';
        printKeyDate.Note_1__c = 'Test';
        
        Test.startTest();

        update new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
    }

    @isTest static void test_2_2() {
        ////////////////////////////////////////
        //  Test After Update, date 1 = today
        ////////////////////////////////////////
        createTestData();
        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();
        
        Test.startTest();

        update new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
    }

    @isTest static void test_2_3() {
        ////////////////////////////////////////
        //  Test After Update, date 2 = today
        ////////////////////////////////////////
        createTestData();
        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        bacsKeyDate.Date_Time_2__c = DateTime.now();
        printKeyDate.Date_Time_2__c = DateTime.now();
        
        Test.startTest();

        update new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
    }

    @isTest static void test_2_4() {
        ////////////////////////////////////////
        //  Test After Update, date 3 = today
        ////////////////////////////////////////
        createTestData();
        insert new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        bacsKeyDate.Date_Time_3__c = DateTime.now();
        printKeyDate.Date_Time_3__c = DateTime.now();
        
        Test.startTest();

        update new List<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
    }

    @isTest static void test_3_1() {
        ////////////////////////////////////////
        //  Test After Delete, dates not today
        ////////////////////////////////////////
        createTestData();
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();

        delete new list<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
        
    }

    @isTest static void test_3_2() {
        ////////////////////////////////////////
        //  Test After Delete, date 1 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();

        delete new list<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
        
    }

    @isTest static void test_3_3() {
        ////////////////////////////////////////
        //  Test After Delete, date 2 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_2__c = DateTime.now();
        printKeyDate.Date_Time_2__c = DateTime.now();
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();

        delete new list<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
        
    }

    @isTest static void test_3_4() {
        ////////////////////////////////////////
        //  Test After Delete, date 3 = today
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_3__c = DateTime.now();
        printKeyDate.Date_Time_3__c = DateTime.now();
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();

        delete new list<Key_Dates__c>{bacsKeyDate,printKeyDate};
        
        Test.stopTest();
        
    }
    
    @isTest static void test_3_5() {
        ////////////////////////////////////////
        //  Test Key Dates
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();
        schedule.Authorised_By_Customer__c = true;
        update schedule;
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();
		bacsKeyDate.Date_Time_1__c = DateTime.now().addDays(1);
        printKeyDate.Date_Time_1__c = DateTime.now().addDays(1);
    
        update bacsKeyDate;
        update printKeyDate;
        
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();
        
        update bacsKeyDate;
        update printKeyDate;
        
        Test.stopTest();
        
    }
    @isTest static void test_3_6() {
        ////////////////////////////////////////
        //  Test Key Dates
        ////////////////////////////////////////
        createTestData();
        bacsKeyDate.Date_Time_1__c = DateTime.now();
        printKeyDate.Date_Time_1__c = DateTime.now();
        schedule.Authorised_By_Customer__c = true;
        update schedule;
        insert new list<Key_Dates__c>{bacsKeyDate,printKeyDate};

        Test.startTest();
		bacsKeyDate.Date_Time_1__c = DateTime.now().addDays(1);
        printKeyDate.Date_Time_1__c = DateTime.now().addDays(1);
    
        bacsKeyDate.Cancelled__c = true;
        printKeyDate.Cancelled__c = true;
        
        update bacsKeyDate;
        update printKeyDate;
        
        
        
        Test.stopTest();
        
    }
    
}