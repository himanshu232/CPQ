@isTest
private class Test_EmailPublisherLoader {

    static Account a;
    static Contact ct;
    static Case ca;
    static Id mservicesRecTypeId;
    static Id nonMServicesRecTypeId;

    static {
        a = new Account(Name='Test');
        insert a;
        ct = new Contact(FirstName='Test', LastName='Test', Email='Test@Test.com', AccountId=a.Id);
        insert ct;
        mservicesRecTypeId = [SELECT Id FROM RecordType WHERE (SObjectType = 'Case' AND IsActive = TRUE AND DeveloperName = 'Managed_Services_Case')].Id;
        nonMServicesRecTypeId = [SELECT Id FROM RecordType WHERE (SObjectType = 'Case' AND IsActive = TRUE AND DeveloperName != 'Managed_Services_Case') LIMIT 1].Id;
    }
    
    //Managed Services Case
    //No matching org-wide address
    //Expected outcome: no errors
    @isTest static void test_method_1_1() {

        Exception failureDuringExecution = null;

        ca = new Case(RecordTypeId=mservicesRecTypeId, Subject='Test', AccountId=a.Id, ContactId=ct.Id, SuppliedEmail='Test@Test.com');
        insert ca;

        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>> {
            new Map<String, Object> {
                'targetSObject' => new EmailMessage(),
                'contextId' => ca.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
            }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
        (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

        Test.startTest();

        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e;
        }

        Test.stopTest();

        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');

    }

    //Non Managed Services Case
    //No matching org-wide address
    //Expected outcome: EmailPublisherLoader does nothing
    @isTest static void test_method_2_1() {

        Exception failureDuringExecution = null;

        ca = new Case(RecordTypeId=nonMServicesRecTypeId, Subject='Test', AccountId=a.Id, ContactId=ct.Id, SuppliedEmail='Test@Test.com');
        insert ca;

        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>> {
            new Map<String, Object> {
                'targetSObject' => new EmailMessage(),
                'contextId' => ca.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
            }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
        (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

        Test.startTest();

        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e;
        }

        Test.stopTest();

        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');

    }

    //Managed Services Case
    //Matching org-wide address
    //Expected outcome: no errors
    //OrgWideEmailAddress obj cannot be inserted in unit tests - we have to use seeAllData=true
    @isTest(seeAllData=True) static void test_method_3_1() {

        Exception failureDuringExecution = null;

        ca = new Case(RecordTypeId=mServicesRecTypeId, Subject='Test', AccountId=a.Id, ContactId=ct.Id, SuppliedEmail='support@midlandhr.com');
        insert ca;

        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>> {
            new Map<String, Object> {
                'targetSObject' => new EmailMessage(),
                'contextId' => ca.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'support@midlandhr.com' }
            }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
        (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);

        Test.startTest();

        try {
            (new EmailPublisherLoader()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e;
        }

        Test.stopTest();

        System.assertEquals(null, failureDuringExecution, 'There was an exception thrown during the test!');

    }

}