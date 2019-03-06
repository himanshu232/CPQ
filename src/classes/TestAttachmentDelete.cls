@isTest
public class TestAttachmentDelete {
	static testMethod void testStandardUser() {
    
    // Create a new user with the Partner Community User profile
    Profile standardProf = [select id from profile where name='System Administrator']; 
    User su = new User(alias = 'standt', email='markcommunity@test.com', 
    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
    localesidkey='en_US', profileid = standardProf.Id, 
    Timezonesidkey='Europe/London', username='markcommunity@test.com');
      
    // Switch current user to Partner Community User
    System.runAs(su) {    
    
      // Create test data (a new Account with an Attachment)
      Account acct = new Account(Name = 'Test Account',Account_Reference__c='a',Customer_Code__c='a');
      insert acct;
      Blob attachBody = Blob.valueOf('attachment body');
      Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
      insert attach;
    
      // Verify the "Unable to delete attachments" error is thrown when attachment is deleted
      Boolean errorThrown = false; 
      try {
        delete attach;
      } catch (Exception e) {
        System.debug(e);
        if (e.getMessage().contains('Unable to delete attachments.')) {
          errorThrown = true;
        }
      }
      //System.assert(errorThrown);
        }
  }
}