public class CXReplyContactTriggerHandler extends CXTriggerHandler {
  public override void afterInsert() {

    // Junction objects to insert
    List<SMCXReplyContact__c> replyContactList = new List<SMCXReplyContact__c>();
    List<SMCXReplyLead__c> replyLeadList = new List<SMCXReplyLead__c>();

    // For loop to harvest all email addresses
    List<String> allEmails = new List<String>();

    for(SurveyMonkeyCXNPSReply__c reply : ((List<SurveyMonkeyCXNPSReply__c>) Trigger.new)) {
      if(reply.SMCX_Email__c ==  null){

      } else {
        allEmails.add(reply.SMCX_Email__c);
      }
    }

    if (allEmails.size() > 0) {
      // Map all contact records for those email addresses
      List<Contact> contactsForAllEmails = new List<Contact>([SELECT Id, Email FROM Contact WHERE Email IN :allEmails]);

      Map<String, List<Contact>> mapContactsForReplies = new Map<String, List<Contact>>();

      // Map contacts to each reply
      for(SurveyMonkeyCXNPSReply__c reply : ((List<SurveyMonkeyCXNPSReply__c>) Trigger.new)){
        List<Contact> contactsPerEmail = new List<Contact>();
        for(Contact contact : contactsForAllEmails){
          if(contact.Email == reply.SMCX_Email__c){
            contactsPerEmail.add(contact);
          }
        }
        mapContactsForReplies.put(reply.Id, contactsPerEmail);
      }

      // Map all lead records for those email addresses
      List<Lead> leadsForAllEmails = new List<Lead>([SELECT Id, Email FROM Lead WHERE Email IN :allEmails]);

      Map<String, List<Lead>> mapLeadsForReplies = new Map<String, List<Lead>>();

      // Map leads to each reply
      for(SurveyMonkeyCXNPSReply__c reply : ((List<SurveyMonkeyCXNPSReply__c>) Trigger.new)){
        List<Lead> leadsPerEmail = new List<Lead>();
        for(Lead lead : leadsForAllEmails) {
          if(lead.Email == reply.SMCX_Email__c){
            leadsPerEmail.add(lead);
          }
        }
        mapLeadsForReplies.put(reply.Id, leadsPerEmail);
      }

      // Initialize main list of junction objects
      // Find and connect contacts to replies
      if (mapContactsForReplies.size() > 0) {
        for (String replyId : mapContactsForReplies.keySet()) {
          for (Contact contact : mapContactsForReplies.get(replyId)) {
            replyContactList.add(new SMCXReplyContact__c(SMCXContact__c= contact.Id, SurveyMonkey_CX_NPS_Reply__c= replyId));
          }
        }
      }

      // Find and connect leads to replies
      if (mapLeadsForReplies.size() > 0) {
        for (String replyId : mapLeadsForReplies.keySet()) {
          for (Lead lead : mapLeadsForReplies.get(replyId)) {
            replyLeadList.add(new SMCXReplyLead__c(Lead__c= lead.Id, SurveyMonkey_CX_NPS_Reply__c= replyId));
          }
        }
      }
      if (replyContactList.size() > 0) {
        try {
          insert(replyContactList);
        } catch(dmlexception e) {
          System.debug('CX ERROR');
          System.debug(e);
        }
      }
      if (replyLeadList.size() > 0) {
        try {
          insert(replyLeadList);
        } catch(dmlexception e) {
          System.debug('CX ERROR');
          System.debug(e);
        }
      }
    }
  }
}