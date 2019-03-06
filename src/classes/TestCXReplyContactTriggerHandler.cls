@isTest
private class TestCXReplyContactTriggerHandler {
  static testMethod void triggerContactsInsert(){
    // Create contacts
    List<Contact> contacts = TestCXHelpers.contactList(1);
    insert contacts;

    // Create replies with contacts' emails
    List<SurveyMonkeyCXNPSReply__c> replies = TestCXHelpers.replyList(1);
    insert replies;

    // Retrieve contact junction objects
    List<SMCXReplyContact__c> replyContactJunctionObjects = [SELECT Id FROM SMCXReplyContact__c];
    System.assert(replyContactJunctionObjects.size() == 1);
  }

}