trigger CXConnectContactsAndLeadsToReply on SurveyMonkeyCXNPSReply__c (after insert) {
  new CXReplyContactTriggerHandler().run();
}