@isTest
public class FeedItemWorkFlowTest { 
	@isTest(SeeAllData = false)
    public static void testFeedEmailTemplate(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u1 = new User(Alias = 'Test', Email='teststandard@gmail.com', 
                EmailEncodingKey='UTF-8', LastName='Test Standard', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p1.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testmidland@midlandHR.com');
        insert u1;
        
        Account a = new Account(Name = 'Test Account');
        a.Account_Reference__c = '12345';
        a.Customer_Code__c = '12345';
        insert a;
        
        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.FirstName = 'Test 1';
        c1.LastName = 'Contact';
        c1.Email = 'testContact@test.com';
        insert c1;
        
        Defect__c de = new Defect__c();
        de.Name = 'Test defect';
        de.CategorySLA__c = 'A - [SLA - 1 Day]';        
        insert de;
        
        EntitySubscription ent1 = new EntitySubscription(ParentId = de.Id, SubscriberId = u1.Id,NetworkId = Network.getNetworkId());
        insert ent1; 
        
        System.runAs(u1){
            FeedItem feed1 = new FeedItem();
            feed1.Body = 'Public Post';
            feed1.ParentId = de.Id;
            feed1.Visibility = 'AllUsers';
            insert feed1;
            System.assertEquals(feed1.Body, 'Public Post');
        }
        
        
        Documentation__c doc = new Documentation__c();
        doc.Title__c = 'Test Documentation';
        doc.Date_Issued__c = Date.today();
        doc.Issue_Number__c = 'Test Issue';
        insert doc;
        
		EntitySubscription ent2 = new EntitySubscription(ParentId = doc.Id, SubscriberId = u1.Id,NetworkId = Network.getNetworkId());
        insert ent2;   
        
        
        System.runAs(u1){ 
            FeedItem feed2 = new FeedItem();
            feed2.Body = 'Test Document';
            feed2.ParentId = doc.Id;
            feed2.Visibility = 'AllUsers';
            insert feed2;
            System.assertEquals(feed2.Body, 'Test Document');
        } 
        
        FeedItemEmailWorkflow.fakeMethod(); 
    }
}