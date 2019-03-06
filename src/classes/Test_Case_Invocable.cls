// ##################################################
// FOR: Case_Invocable.cls
// ##################################################
@isTest
private class Test_Case_Invocable {
	
	static Account a;
	static Case c;
	static Id managedServicesRecordTypeId;

	static void createTestData() {
		a = Test_DataFactory.getAccount();
		managedServicesRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND isActive = True AND DeveloperName = 'Managed_Services_Case' LIMIT 1].Id;
		c = Test_DataFactory.getCase(a.Id, managedServicesRecordTypeId);
	}
  	
	@isTest static void test_method_1_1() {
		////////////////////////////////////////
		//  Change the estimated hours on Case
		//  Total on Account is updated
		////////////////////////////////////////
		createTestData();

		Test.startTest();

		c.MServices_Estimated_Hours_Worked__c = 2.5;
		c.MServices_Estimated_Minutes_Worked__c = 30;
		update c;

		// Call the method directly - in reality this will be called by Process Builder
		Case_Invocable.sumEstimatedTimeWorked(new List<String>{a.Id});

		a = [SELECT MServices_Estimated_Case_Hours_Worked__c FROM Account WHERE Id = :a.Id LIMIT 1];
		System.assertEquals(c.MServices_Estimated_Hours_Worked__c + (c.MServices_Estimated_Minutes_Worked__c / 60), a.MServices_Estimated_Case_Hours_Worked__c);

		Test.stopTest();
	}
	/*
	@isTest static void test_method_1_2() {
		////////////////////////////////////////
		//  Do not change the estimated hours on Case
		//  Total on Account is not updated
		////////////////////////////////////////
		createTestData();

		Test.startTest();

		c.Subject = 'Testing';
		update c;

		// Call the method directly - in reality this will be called by Process Builder
		Case_Invocable.sumEstimatedTimeWorked(new List<String>{a.Id});

		a = [SELECT MServices_Estimated_Case_Hours_Worked__c FROM Account WHERE Id = :a.Id LIMIT 1];
		System.assertEquals(null, a.MServices_Estimated_Case_Hours_Worked__c);

		Test.stopTest();
	}

	@isTest static void test_method_1_3() {
		////////////////////////////////////////
		//  Change estimated hours on multiple Cases
		//  Total on Account is updated
		////////////////////////////////////////
		createTestData();

		Test.startTest();

		c.MServices_Estimated_Hours_Worked__c = 1;
		List<Case> casesToUpsert = new List<Case>();
		casesToUpsert.add(c);
		for(Integer i = 0; i < 100; i++) {
			casesToUpsert.add(new Case(AccountId=a.Id, Subject='Test'+i, Status='New', RecordTypeId=managedServicesRecordTypeId, MServices_Estimated_Hours_Worked__c=1));
		}
		upsert casesToUpsert;

		// Call the method directly - in reality this will be called by Process Builder
		Case_Invocable.sumEstimatedTimeWorked(new List<String>{a.Id});

		a = [SELECT MServices_Estimated_Case_Hours_Worked__c FROM Account WHERE Id = :a.Id LIMIT 1];
		System.assertEquals(101.00, a.MServices_Estimated_Case_Hours_Worked__c);

		Test.stopTest();
	}
	*/

}