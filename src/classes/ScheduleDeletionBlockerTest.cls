@isTest
private class ScheduleDeletionBlockerTest {
    @isTest
  static void testdeleteSchedule(){
    pse__Schedule__c s  = new pse__Schedule__c();
    s.pse__Start_Date__c = System.today();
    s.pse__End_Date__c = System.today();
    s.Allow_Deletion__c = true ;  
    insert s;
    delete s;
     }
    
}