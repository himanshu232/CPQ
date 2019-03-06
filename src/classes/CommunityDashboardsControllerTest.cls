/** oe:gen 23-12-2015 **/
@isTest

private class CommunityDashboardsControllerTest {

    public static void InitialiseBasicData() {
        
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        insert account;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Last Name';
        contact.Salutation = 'Mr.';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        List<Defect__c> defects = new List<Defect__c>();
        Defect__c d1 = new Defect__c(Status__c='In Progress', Product__c='iTrent');
        defects.add(d1);
        Defect__c d2 = new Defect__c(Status__c='Complete', Product__c='iTrent');
        defects.add(d2);
        insert defects;
        
        //Create 6 Cases
        List<Case> cases = new List<Case>();
        for(Integer i=0; i<6; i++){
            Case c = new Case(Age__c = 1, Required_By_Date__c = Date.Today(), AccountId = account.Id, ContactId = contact.Id);
            cases.add(c);
        }
        //Attach defects to the first two Cases
        Case c1 = cases[0];
        c1.Defect__c = d1.Id;
        Case c2 = cases[1];
        c2.Defect__c = d2.Id;
        
        insert cases;
        
        //Old_Escalation__c e = new Old_Escalation__c(Case__c=c1.Id);
        //insert e;
        
        List<Customer_Experience__c> custExperiences = new List<Customer_Experience__c>();
        Customer_Experience__c ce1 = new Customer_Experience__c(Support_Case__c=c2.Id,Score__c='Very Satisfied');
        Customer_Experience__c ce2 = new Customer_Experience__c(Support_Case__c=c2.Id,Score__c='Satisfied');
        Customer_Experience__c ce3 = new Customer_Experience__c(Support_Case__c=c2.Id,Score__c='Neither Satisfied or Dissatisfied');
        Customer_Experience__c ce4 = new Customer_Experience__c(Support_Case__c=c2.Id,Score__c='Dissatisfied');
        Customer_Experience__c ce5 = new Customer_Experience__c(Support_Case__c=c2.Id,Score__c='Very Dissatisfied');
        custExperiences.add(ce1);
        custExperiences.add(ce2);
        custExperiences.add(ce3);
        custExperiences.add(ce4);
        custExperiences.add(ce5);
        insert custExperiences;
    }
    
    @isTest static void test_CommunityDashboardsController() {
        InitialiseBasicData();
        Contact contact = [Select Id,LastName,Title From Contact Limit 1];
        Account account = [Select Id From Account Limit 1];
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        List<Case> cases = [SELECT Id FROM Case];
        
        Test.startTest();
        

        /* Use this code block to shift case created dates back for greater code coverage - Test.setCreatedDate method should become available in Spring 16 release
        List<Datetime> dates = new List<Datetime>();
        Datetime today = Datetime.now().addDays(0);
        dates.add(today);
        Datetime fourDaysAgo = Datetime.now().addDays(-4);
        dates.add(fourDaysAgo);
        Datetime tenDaysAgo = Datetime.now().addDays(-10);
        dates.add(tenDaysAgo);
        Datetime twentyDaysAgo = Datetime.now().addDays(-20);
        dates.add(twentyDaysAgo);
        Datetime fiftyDaysAgo = Datetime.now().addDays(-50);
        dates.add(fiftyDaysAgo);
        Datetime twoHundredDaysAgo = Datetime.now().addDays(-200);
        dates.add(twoHundredDaysAgo);
        // There should only be 6 cases created by our test, and 6 dates created above, so we set the created date for each case using these
        for(Integer i=0; i < cases.size(); i++){
            Test.setCreatedDate(cases[i].Id, dates[i]);
        }
        */
        
        // run the tests as our new community user

        system.runAs(u){
            PageReference testPR = Page.Community_Dashboards;
            Test.setCurrentPage(testPR);
            community_DashboardsController controller = new community_DashboardsController();
            community_DashboardsController.getLoggedCaseStatusData();
            community_DashboardsController.getOpenCaseAgeData();
            community_DashboardsController.getAllDefectsLogged();
            community_DashboardsController.getClosedCaseAgeData();
            //community_DashboardsController.getOld_Escalations();
            community_DashboardsController.getFeedback();
        }
        Test.stopTest();

    }


}