@isTest
public class CaseFeedWorkflowTest{  
    
    static testMethod void testCaseAutoFollowUnfollow(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@midland.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser2@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@midland.com');
        insert u2;
        
        Account a = new Account(Name = 'Test Account');
        a.Account_Reference__c = '12345';
        a.Customer_Code__c = '67890';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        insert c;
        
        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.ContactId = c.Id;
        ca.OwnerId = u1.Id;
        insert ca;
        
        EntitySubscription ent = [Select Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentID = :ca.Id];
        system.assertEquals(ent.SubscriberId, u1.Id);
        
        ca.OwnerId = u2.Id;
        update ca;
        
        /*ent = [Select Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentID = :ca.Id];
        system.assertEquals(ent.SubscriberId, u2.Id);*/
    }
    
    @isTest(SeeAllData = false)
    public static void testFeedEmailWorkflow(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p1.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@midland.com');
        insert u1;
        
        Account a = new Account(Name = 'Test Account');
        a.Account_Reference__c = '12345';
        a.Customer_Code__c = '67890';
        insert a;
        
        Contact c1 = new Contact();
        c1.AccountId = a.Id;
        c1.FirstName = 'Test 1';
        c1.LastName = 'Contact';
        c1.Email = 'test1@kj.com';
        insert c1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser2@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p1.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@midland.com');
        insert u2;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Customer Community User']; 
        User u3 = new User(Alias = 'standt', Email='standarduser3@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p2.Id, ContactId = c1.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3@midland.com');
        insert u3;
        
        User u4 = new User(Alias = 'standt', Email='standarduser1=4@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p1.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser4@midland.com');
        insert u4;
        
        Case ca = new Case();
        ca.AccountId = a.Id;
        ca.ContactId = c1.Id;
        ca.OwnerId = u4.Id;
        insert ca;
        
        EntitySubscription ent1 = new EntitySubscription(ParentId = ca.Id, SubscriberId = u2.Id,NetworkId = Network.getNetworkId());
        insert ent1;
        
        EntitySubscription ent2 = new EntitySubscription(ParentId = ca.Id, SubscriberId = u1.Id,NetworkId = Network.getNetworkId());
        insert ent2;
        
        System.runAs(u1){
            FeedItem feed1 = new FeedItem();
            feed1.Body = 'Private Post';
            feed1.ParentId = ca.Id;
            feed1.Visibility = 'InternalUsers';
            insert feed1;
        }
        
        System.runAs(u1){
            FeedItem feed2 = new FeedItem();
            feed2.Body = 'Public Post';
            feed2.ParentId = ca.Id;
            feed2.Visibility = 'AllUsers';
            insert feed2;
        }
        
        System.runAs(u1){
            FeedItem feed2 = new FeedItem();
            feed2.Body = 'Extrenal Post';
            feed2.ParentId = ca.Id;
            insert feed2;
        }
    }
    
}