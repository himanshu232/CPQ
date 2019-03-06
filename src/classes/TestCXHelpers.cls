@isTest
public class TestCXHelpers {

    public static List<Contact> contactList(Integer size){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0 ; i < size ; i++){
            contacts.add(new Contact(FirstName = 'Contact', LastName = String.valueOf(i), Email = 'email' + String.valueOf(i) + '@example.com'));
        }
        return contacts;
    }

    public static List<Lead> leadList(Integer size){
    List<Lead> leads = new List<Lead>();
    for(Integer i = 0 ; i < size ; i++){
      leads.add(new Lead(FirstName = 'Lead', LastName = String.valueOf(i), Company='Company'));
    }
    return leads;
  }
    public static List<SurveyMonkeyCXNPSReply__c> replyList(Integer size){
    List<SurveyMonkeyCXNPSReply__c> replies = new List<SurveyMonkeyCXNPSReply__c>();
    for(Integer i = 0 ; i < size ; i++){
      replies.add(new SurveyMonkeyCXNPSReply__c(Name= 'Reply ' + String.valueOf(i), SMCX_Email__c= 'email' + String.valueOf(i) + '@example.com', SMCX_Answered_At__c= DateTime.now(), SMCX_NPS__c= 9, SMCX_NPS_Reason__c= 'Some NPS reason', SMCX_Token__c= '60006f70d1706da' + String.valueOf(i), SMCX_Reply_URL__c= 'http://cx.dev/app/replies/60006f70d1706da' + String.valueOf(i), SMCX_Questions_Answered__c= 3, SMCX_Survey_Name__c= 'Test Survey', SMCX_Region__c= 'CA', SMCX_Country_Code__c= 'US', SMCX_Sentiment__c= 'promoter'));
        }
    return replies;
  }
}