// ##################################################
// UNIT TEST: Test_Case_Invocable.cls
// ##################################################
public without sharing class Case_Invocable {

	@InvocableMethod(label='Sum Estimated Time Worked' description='Sum Estimated Time Worked')
	public static void sumEstimatedTimeWorked(List<String> accountIds) {

		Map<Id, Double> accIdToTotalHoursWorked = new Map<Id, Double>();
		
		List<AggregateResult> aggResults = [SELECT AccountId, SUM(MServices_Estimated_Hours_Worked__c)totalHours, SUM(MServices_Estimated_Minutes_Worked__c)totalMins
											FROM Case
											WHERE AccountId IN :accountIds AND RecordType.DeveloperName = 'Managed_Services_Case'
											GROUP BY AccountId];

		for(AggregateResult ar : aggResults) {
			accIdToTotalHoursWorked.put(String.valueOf(ar.get('AccountId')), ( Double.valueOf(ar.get('totalHours')) + Double.valueOf(ar.get('totalMins')) / 60) );
		}

		List<Account> accsToUpdate = new List<Account>();

		for(Id i : accIdToTotalHoursWorked.keyset()) {
			accsToUpdate.add(new Account(Id=i, MServices_Estimated_Case_Hours_Worked__c = accIdToTotalHoursWorked.get(i)));
		}

		try {
			List<Database.SaveResult> results = Database.Update(accsToUpdate, false);
		} catch(Exception e) {
			System.debug('Error while updating Accounts\' Estimated Case Hours Worked: ' + e.getMessage());
		}
		
	}
}