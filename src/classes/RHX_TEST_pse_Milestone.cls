@isTest(SeeAllData=true)
public class RHX_TEST_pse_Milestone {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM pse__Milestone__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new pse__Milestone__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}