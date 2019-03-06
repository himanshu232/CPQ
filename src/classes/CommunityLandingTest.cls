@isTest
private class CommunityLandingTest {
   
   public static void InitialiseBasicData() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';    
        account.type = 'Customer';
        insert account;
        
        Hosted__c environment = new Hosted__c();
        environment.Customer__c = account.ID;
        environment.Name = 'Test';
        environment.Environment_Type__c = 'Test';
        environment.Environment_Version__c = '10.23';
        insert environment;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.ID;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        insert hostEnvLive;
        
        Service_Request_Availability_Schedule__c ava = new Service_Request_Availability_Schedule__c();
        ava.sra_EffectiveDate__c = Date.parse('01/12/2020');
        ava.sra_Upgrades__c = 100;
        insert ava;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        contact.Salutation = 'Mr.';
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/03/2020');
        settings.settingIdentifier__c = 'HSR';
        insert settings;

    }
    
    static testMethod void hsrUpgSubmit() {
        InitialiseBasicData();
        /** oe:gen 23-12-2015 **/
        Contact contact = [Select Id,LastName,Title From Contact Limit 1];
        Account account = [Select Id From Account Limit 1];
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        Case caseRecord = new Case(Age__c = 1, 
                                   Required_By_Date__c = Date.Today(), 
                                   AccountId = account.Id, 
                                   ContactId = contact.Id);
        insert caseRecord;
        
        /** oe:gen 23-12-2015 **/
        // run the tests as our new community user
        system.runAs(u){

            CommunityLandingController controller = new CommunityLandingController();
            
            controller.prepUpgradeBox();
            
            controller.serviceDate = Date.parse('12/12/2018');
            controller.bookMandatoryUpgrades();
            
            //Boolean a = controller.isReleaseMonth(12);
            //Boolean b = controller.isReleaseMonth(11);
            
            Boolean c = controller.isTrentVersionMandatory('10.26');
            Boolean d = controller.isTrentVersionMandatory('10.25');
            
            String e = controller.getLastMandatory();
            
            //String f = controller.func_calculateTrentVersionOnDate('10/12/2017');
            
        }
    }
    
    static testMethod void testCommunityLanding() {
        InitialiseBasicData();
        /** oe:gen 23-12-2015 **/
        Contact contact = [Select Id,LastName,Title From Contact Limit 1];
        Account account = [Select Id From Account Limit 1];
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        Case caseRecord = new Case(Age__c = 1, 
                                   Required_By_Date__c = Date.Today(), 
                                   AccountId = account.Id, 
                                   ContactId = contact.Id);
        insert caseRecord;
        
        /** oe:gen 23-12-2015 **/
        // run the tests as our new community user
        system.runAs(u){

            CommunityLandingController controller = new CommunityLandingController();
            controller.getCustomer();
            /*------------  Retired 23-12-2015 ------------ */
            /*
            controller.getC1Data();
            controller.getC2Data();
            */
            controller.getReferencePoint();
            
            List<Case> caseList = CommunityLandingController.getCases();
            system.assertNotEquals(0, caseList.size());
        }
        
        /** oe:gen 23-12-2015 **/
        // run the tests again but this time as System Admin for additional code coverage
        CommunityLandingController controller = new CommunityLandingController();
        controller.getCustomer();
        /*------------  Retired 23-12-2015 ------------ */
        /*
        controller.getC1Data();
        controller.getC2Data();
        */
        controller.getReferencePoint();
        
        List<Case> caseList = CommunityLandingController.getCases();
        system.assertEquals(0, caseList.size());
    }
}