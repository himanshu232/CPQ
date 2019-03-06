@isTest(SeeAllData=true)
public class RHX_TEST_pse_Assignment {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM pse__Assignment__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new pse__Assignment__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}