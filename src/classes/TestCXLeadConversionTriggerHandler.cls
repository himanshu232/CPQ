@isTest
private class TestCXLeadConversionTriggerHandler {
  static testMethod void triggerLeadConversion(){
    Lead lead = new Lead(FirstName = 'Lead', LastName = '1', Company='Company', Email = 'email1@example.com');
    insert lead;

    List<SurveyMonkeyCXNPSReply__c> replies = TestCXHelpers.replyList(1);
    insert replies;

    List<SMCXReplyLead__c> replyLeadJunctionObjects = [SELECT Id FROM SMCXReplyLead__c];

    System.debug('convert lead called');
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(lead.id);
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);   
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    System.assert(lcr.isSuccess());
    System.debug('converted');

    List<SMCXReplyContact__c> replyContactJunctionObjects = [SELECT Id FROM SMCXReplyContact__c];
    System.assert(replyLeadJunctionObjects.size() == replyContactJunctionObjects.size());

  }
}