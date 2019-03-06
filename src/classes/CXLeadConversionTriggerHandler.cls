public class CXLeadConversionTriggerHandler extends CXTriggerHandler {
  public override void afterUpdate() {

    List<SMCXReplyContact__c> replyContactList = new List<SMCXReplyContact__c>();

    List<String> allLeadIds = new List<String>();

    for(Lead lead : ((List<Lead>) Trigger.new)) {
      if (lead.IsConverted) {
        allLeadIds.add(lead.Id);
      }
    }

    List<SMCXReplyLead__c> leadJunctionObjects = new List<SMCXReplyLead__c>([SELECT Id, Lead__c, SurveyMonkey_CX_NPS_Reply__c FROM SMCXReplyLead__c WHERE Lead__c IN :allLeadIds]);

    for(Lead lead : ((List<Lead>) Trigger.new)) {
      List<SMCXReplyContact__c> junctionObjectsFromLead = new List<SMCXReplyContact__c>();
      for(SMCXReplyLead__c replyLead : leadJunctionObjects) {
        if(replyLead.Lead__c == lead.Id){
          replyContactList.add(new SMCXReplyContact__c(SMCXContact__c= lead.ConvertedContactId, SurveyMonkey_CX_NPS_Reply__c= replyLead.SurveyMonkey_CX_NPS_Reply__c));
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
  }
}