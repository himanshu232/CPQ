@isTest(SeeAllData=true)
public class RHX_TEST_Activity_Checklist {
    static testMethod void RHX_Testmethod() {
        List<Activity_Checklist__c> sourceList = [SELECT Id FROM Activity_Checklist__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(new Activity_Checklist__c());
        }
        
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}