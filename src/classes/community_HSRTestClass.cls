@isTest ()
public class community_HSRTestClass {
    
    @isTest static void test_method_customer_on_hold() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        account.Credit_Hold__c = true;
        insert account;
        
        Contact contact = new Contact(); 
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/03/2018');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Name ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        Service_Request_Availability_Schedule__c tmpSra = New Service_Request_Availability_Schedule__c();
        tmpSra.sra_CopyAM__c = 10;
        tmpSra.sra_CopyPM__c = 10;
        tmpSra.sra_PatchAM__c = 10;
        tmpSra.sra_PatchPM__c = 10;
        tmpSra.sra_Upgrades__c = 20;
        tmpSra.sra_EffectiveDate__c = Date.parse('01/01/2016');
        insert tmpSra;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        system.runAs(u) {
        
            PageReference srPage = Page.community_ServiceRequestCreate;
            community_ServiceRequestCreateController srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
            srClass.checkSaveReady();
            srClass.pageContinue();
            srClass.input_Customer = account.Name;
            srClass.srCustomerCheck();
            srClass.srApproverCheck();
            //public string getTrentVersionAtDate(String env, Date serviceDate)
            String envID = hostEnvDev.Id;
            String tVersion = srClass.getTrentVersionAtDate(envID, Date.parse('10/10/2016'));
            for(Integer m = 0; m < 12; m++) {
                Boolean isReleaseMonth = srClass.isReleaseMonth(m);
            }
        
            srPage.getParameters().put('srType', 'Upgrade');
            srClass.srTypeCheck();
            srPage.getParameters().put('inputServiceDate', '10/10/2016');
            srClass.serviceUpgDate();
            srPage.getParameters().put('inputTargetEnvironment', hostEnv.ID);
            srClass.serviceUpgCheckEnv();
            srClass.checkSaveReady();
            srClass.pageContinue();
            
            srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
        }
    }
    
    @isTest static void test_method_one() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact(); 
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/03/2018');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Name ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        Service_Request_Availability_Schedule__c tmpSra = New Service_Request_Availability_Schedule__c();
        tmpSra.sra_CopyAM__c = 10;
        tmpSra.sra_CopyPM__c = 10;
        tmpSra.sra_PatchAM__c = 10;
        tmpSra.sra_PatchPM__c = 10;
        tmpSra.sra_Upgrades__c = 20;
        tmpSra.sra_EffectiveDate__c = Date.parse('01/01/2016');
        insert tmpSra;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        system.runAs(u) {
        
            PageReference srPage = Page.community_ServiceRequestCreate;
            community_ServiceRequestCreateController srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
            srClass.checkSaveReady();
            srClass.pageContinue();
            srClass.input_Customer = account.Name;
            srClass.srCustomerCheck();
            srClass.srApproverCheck();
            //public string getTrentVersionAtDate(String env, Date serviceDate)
            String envID = hostEnvDev.Id;
            String tVersion = srClass.getTrentVersionAtDate(envID, Date.parse('10/10/2016'));
            for(Integer m = 0; m < 12; m++) {
                Boolean isReleaseMonth = srClass.isReleaseMonth(m);
            }
        
            srPage.getParameters().put('srType', 'Upgrade');
            srClass.srTypeCheck();
            srPage.getParameters().put('inputServiceDate', '10/10/2016');
            srClass.serviceUpgDate();
            srPage.getParameters().put('inputTargetEnvironment', hostEnv.ID);
            srClass.serviceUpgCheckEnv();
            srClass.checkSaveReady();
            srClass.pageContinue();
            
            srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
            
            srPage.getParameters().put('srType', 'Patch');
            srClass.srTypeCheck();
            srClass.input_TypeRequested = 'Patch';
            srClass.input_TargetEnvironment = hostEnv.id;
            srClass.servicePatType();
            srPage.getParameters().put('inputPatchType', 'Patch to Match');
            srClass.servicePatType();
            srPage.getParameters().put('inputPatchType', 'Patch to Match');
            srClass.servicePatType();
            srPage.getParameters().put('inputSourceEnvironment', hostEnvLive.ID);
            srClass.servicePatEnvCheck();
            srPage.getParameters().put('inputPatchDate', '10/10/2016');
            srClass.servicePatDate();
            srClass.checkSaveReady();
            srClass.pageContinue();
            
            srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
            
            srPage.getParameters().put('srType', 'Database Copy');
            srClass.srTypeCheck();
            srClass.input_TypeRequested = 'Database Copy';
            srClass.serviceCopPIT();
            srPage.getParameters().put('inputCopyPIT', 'PIT');
            srClass.serviceCopPIT();
            srPage.getParameters().put('inputCopyDate', '10/10/2016');
            srClass.input_ServiceDate = Date.parse('10/10/2016');
            srClass.serviceCopDate();
            srPage.getParameters().put('inputCopySource', hostEnvLive.ID);
            srClass.serviceCopEnvCheck();
            srPage.getParameters().put('inputTargetEnvironment', hostEnvDev.ID);
            srClass.serviceCopEnvCheck();
            srClass.input_TypeRequested = 'Database Copy';
            srClass.pageContinue();
            
            srClass = New community_ServiceRequestCreateController();
            Test.setCurrentPage(srPage);
            
        }
    }
    
    @isTest static void test_method_two() {
        //let's test the listing!
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        system.runAs(u) {
        
            PageReference srPage = Page.community_ServiceRequestList;
            community_ServiceRequestListController srClass = New community_ServiceRequestListController();
            Test.setCurrentPage(srPage);
            
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'PENDING_APPROVAL');
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'PENDING_SCHEDULE');
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'SCHEDULED');
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'COMPLETE');
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'CANCELLED');
            srClass.updateList();
            srPage.getParameters().put('inputSort', 'REJECTED');
            srClass.updateList();

        }
    }
 
    @isTest static void test_method_three() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        Hosted_Service_Request__c sr = new Hosted_Service_Request__c();
        sr.srStatus__c = 'Scheduled';
        sr.srType__c = 'Patch';
        insert sr;
        
        system.runAs(u) {
        
            PageReference srPage = New PageReference('/ServiceDesk/community_ServiceRequestView?sr=' + sr.ID);
            community_ServiceRequestViewController srClass = New community_ServiceRequestViewController();
            srPage.getParameters().put('sr', sr.id);
            srClass.srID = sr.id;
            Test.setCurrentPage(srPage);
            srPage.getParameters().put('sr', sr.id);
        }
    }
    
    @isTest static void test_method_four() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        Hosted_Service_Request__c sr = new Hosted_Service_Request__c();
        sr.srStatus__c = 'Pending Approval';
        sr.srType__c = 'Patch';
        insert sr;
        
        system.runAs(u) {
            PageReference srPage = New PageReference('/ServiceDesk/community_ServiceRequestAuth?sr=' + sr.ID);
            community_ServiceRequestAuthController srClass = New community_ServiceRequestAuthController();
            srPage.getParameters().put('sr', sr.id);
            srClass.srID = sr.id;
            Test.setCurrentPage(srPage);
            srPage.getParameters().put('sr', sr.id);
        }
    }
    
    @isTest static void test_method_five() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        Hosted_Service_Request__c sr = new Hosted_Service_Request__c();
        sr.srStatus__c = 'Pending Approval';
        sr.srType__c = 'Patch';
        sr.srCustomer__c = account.ID;
        Date tmpDate = Date.today();
        sr.srDate__c = tmpDate;
        insert sr;
        
        system.runAs(u) {
            ApexPages.currentPage().getParameters().put('type', 'SUC');
            ApexPages.currentPage().getParameters().put('sr', sr.id);
            community_ServiceRequestInternalComplete srClass = New community_ServiceRequestInternalComplete();
        }
    }
    
    @isTest static void test_method_six() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        Hosted_Service_Request__c sr = new Hosted_Service_Request__c();
        sr.srStatus__c = 'Pending Approval';
        sr.srType__c = 'Patch';
        sr.srCustomer__c = account.ID;
        Date tmpDate = Date.today();
        sr.srDate__c = tmpDate;
        insert sr;
        
        system.runAs(u) {
            ApexPages.currentPage().getParameters().put('type', 'ERR');
            ApexPages.currentPage().getParameters().put('sr', sr.id);
            community_ServiceRequestInternalComplete srClass = New community_ServiceRequestInternalComplete();
        }
    }
    
    @isTest static void test_method_seven() {
        Account account = new Account();
        account.Name = 'Test Name';
        account.Account_Reference__c = 'Test Reference';
        account.Customer_Code__c = 'TCC';       
        account.type = 'Customer';
        insert account;
        
        Contact contact = new Contact();
        contact.Salutation = 'Mr.';
        contact.LastName = 'Test_LastName';
        contact.Contact_Reference__c = 'TCR';
        contact.AccountId = account.Id;
        insert contact;
        
        Custom_Settings__c settings = new Custom_Settings__c();
        settings.settingPatchTC__c = 'terms';
        settings.settingcopyTC__c = 'terms';
        settings.settingUpgradeTC__c = 'terms';
        settings.settingUpgradeMargin__c = 3;
        settings.settingNonLiveMargin__c = 4;
        settings.settingEndDate__c = Date.parse('01/01/2017');
        settings.settingIdentifier__c = 'HSR';
        insert settings;
        
        Hosted__c hostEnv = New Hosted__c();
        hostEnv.Customer__c = account.Id;
        hostEnv.Environment_Version__c ='testEnv';
        hostEnv.Environment_Type__c = 'Test';
        hostEnv.Environment_Version__c = '10.22';
        insert hostEnv;
        
        Hosted__c hostEnvLive = New Hosted__c();
        hostEnvLive.Customer__c = account.Id;
        hostEnvLive.Environment_Version__c ='LiveEnv';
        hostEnvLive.Environment_Type__c = 'Live';
        hostEnvLive.Environment_Version__c = '10.22';
        insert hostEnvLive;
        
        Hosted__c hostEnvDev = New Hosted__c();
        hostEnvDev.Customer__c = account.Id;
        hostEnvDev.Environment_Version__c ='DevEnv';
        hostEnvDev.Environment_Type__c = 'Dev';
        hostEnvDev.Environment_Version__c = '10.22';
        insert hostEnvDev;
        
        User u = TestUtils.getCommunityUser(contact, Label.Service_Desk_Customer_Profile_Id);
        
        Hosted_Service_Request__c sr = new Hosted_Service_Request__c();
        sr.srStatus__c = 'Pending Approval';
        sr.srType__c = 'Patch';
        sr.srCustomer__c = account.ID;
        Date tmpDate = Date.today();
        sr.srDate__c = tmpDate;
        insert sr;
        
        system.runAs(u) {
            community_ServiceRequestInternalComplete srClass = New community_ServiceRequestInternalComplete();
        }
    }
}