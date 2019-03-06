@RestResource(urlMapping='/v1/cx/replies/*')
global with sharing class CXReplyApi {
  @HttpPost
  global static Map<String, String> doPost(List<CxReplyPayload> replies ) {
    Map<String, String> result = new Map<String, String>();

    List<SurveyMonkeyCXNPSReply__c> newReplies = new List<SurveyMonkeyCXNPSReply__c>();

    for(CXReplyPayload payload : replies){
      SurveyMonkeyCXNPSReply__c newReply = new SurveyMonkeyCXNPSReply__c();
      newReply.Name = payload.getName();
      newReply.SMCX_Email__c = payload.getEmail();
      newReply.SMCX_Answered_At__c = payload.getAnsweredAt();
      newReply.SMCX_NPS__c = payload.getNps();
      newReply.SMCX_NPS_Reason__c = payload.getNpsReason();
      newReply.SMCX_Token__c = payload.getToken();
      newReply.SMCX_Reply_URL__c = payload.getReplyUrl();
      newReply.SMCX_Questions_Answered__c = payload.getQuestionsAnswered();
      newReply.SMCX_Survey_Name__c = payload.getSurveyName();
      newReply.SMCX_Region__c = payload.getRegion();
      newReply.SMCX_Country_Code__c = payload.getCountryCode();
      newReply.SMCX_Sentiment__c = payload.getSentiment();

      newReplies.add(newReply);
    }

    if(newReplies.size() > 0){
      try {
        upsert newReplies SMCX_Token__c;
        for(SurveyMonkeyCXNPSReply__c savedReply : newReplies){
         result.put(savedReply.SMCX_Token__c, savedReply.Id);
        }
      } catch(dmlexception e) {
        System.debug('CX ERROR');
        System.debug(e);
      }
    }
    return result;
  }
  // Delete reply
  // @HttpDelete
  // global static void doDelete() {
  //   RestRequest req = RestContext.request;
  //   RestResponse res = RestContext.response;
  //   String replyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
  //   SurveyMonkeyCXNPSReply__c reply = [SELECT Id FROM SurveyMonkeyCXNPSReply__c WHERE Id = :replyId];
  //   delete reply;
  // }

  // Update reply
  // @HttpPatch
  // global static SurveyMonkeyCXNPSReply__c doPut(CxReplyPayload reply) {
  //   RestRequest req = RestContext.request;
  //   RestResponse res = RestContext.response;
  //   String replyId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
  //   SurveyMonkeyCXNPSReply__c cXNpsReply = [SELECT Id FROM SurveyMonkeyCXNPSReply__c WHERE Id = :replyId];
  //   cXNpsReply.SMCX_NPS_Reason__c = reply.getNpsReason();
  //   update cXNpsReply;
  //   return cXNpsReply;
  // }
}