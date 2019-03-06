@isTest
public class Test_DataFactory {
	
	public static Account getAccount() {
		Account a = new Account(Name='Test', RecordTypeId='012b00000009c7n',Industry='COM - Banking, Finance & Insurance', NumberOfEmployees=100, CurrencyIsoCode='GBP');
		insert a;
		return a;
	}

	public static Case getCase(Id accId, Id recTypeId) {
		Case c = new Case(AccountID=accId, Subject='Test', RecordTypeId=recTypeId);
		insert c;
		return c;
	}

	public static EmailMessage getEmailMessage(Id parentId, Boolean inbound) {
		EmailMessage e = new EmailMessage(ParentId=parentId, FromAddress='salesforce1@oegen.co.uk', FromName='oegen', HtmlBody='Test', Incoming=inbound, Subject='Test', ToAddress='salesforce2@oegen.co.uk');
		insert e;
		return e;
	}

	public static Attachment getAttachment(Id parentId) {
		Attachment a = new Attachment(Body=Blob.valueOf('Test'), ContentType='text/rtf', Name='Test', ParentId=parentId);
		insert a;
		return a;
	}

	public static Id getRecordTypeID(String sObjectType, String developerName, Boolean devNameDoesNotEqual) {
		String s = 'Select Id FROM RecordType WHERE IsActive = True AND SObjectType = \'' + sObjectType + '\' AND DeveloperName ';
		if(devNameDoesNotEqual == true) {
			s += '!= \'' + developerName + '\'';
		} else {
			s += '= \'' + developerName + '\'';
		}
		return Database.query(s)[0].Id;
	}

	public static List<Scheduler__c> getSchedules(Integer quantity, Id accId, String frequency) {
		List<Scheduler__c> schedulesToInsert = new List<Scheduler__c>();
		for(Integer i = 0; i < quantity; i++) {
			Scheduler__c s = new Scheduler__c(Exclude_from_flows__c=true, Account__c=accId, Frequency__c=frequency, Legislation_Country__c='UK', Schedule_Name__c='Test'+i, Service_Type__c='Managed', Target_Completion__c=DateTime.now().addDays(30), Schedule_Responsibility__c='Avengers');
            schedulesToInsert.add(s);
		}
		try {
			insert schedulesToInsert;
			return schedulesToInsert;
		} catch(Exception e) {
			System.debug(System.LoggingLevel.ERROR, 'Error while inserting Schedules in Test_DataFactory: ' + e.getMessage());
			return null;
		}
	}

	public static List<Key_Dates__c> getKeyDates(Integer quantity, Id schedId, String description) {
		List<Key_Dates__c> keyDates = new List<Key_Dates__c>();
		for(Integer i = 0; i < quantity; i++) {
			Key_Dates__c kd = new Key_Dates__c(Schedule__c=schedId, Record_Description__c=description);
			if(description == 'BACS') {
				kd.Assigned_To__c = 'Avengers';
				kd.Description_1__c = 'Net Pay transmission';
				kd.Description_2__c = 'Net Pay processing';
				kd.Description_3__c = 'Net Pay pay date';
			} else {
				kd.Assigned_To__c = 'Raven';
				kd.Description_1__c = 'Payslip print & dispatch';
				kd.Description_2__c = 'Payslip print & dispatch';
				kd.Description_3__c = 'Payslip print & dispatch';
			}
			kd.Date_Time_1__c = DateTime.now().addDays(30 + i);
			kd.Date_Time_2__c = DateTime.now().addDays(60 + i);
			kd.Date_Time_3__c = DateTime.now().addDays(90 + i);
			keyDates.add(kd);
		}
		return keyDates;
	}

	public static List<Payroll_Stage__c> getStages(Integer quantity, Id schedId) {
		List<Payroll_Stage__c> stagesToInsert = new List<Payroll_Stage__c>();

		Map<Integer,String> stageMap = new Map<Integer,String>{0 => '1. Data Submission', 1 => '2. Data Processing', 2 => '3. Trial Run',
																3 => '4. Output Approval', 4 => '5. Payment Processing', 5 => '6. Post Processing'};
		for(Integer i = 0; i < quantity; i++) {
			Payroll_Stage__c s = new Payroll_Stage__c(Schedule__c=schedId, Stage__c=stageMap.get(i), Target_Completion_Date_Time__c=DateTime.now().addDays(30));
			stagesToInsert.add(s);
		}
		return stagesToInsert; 
	}

	public static List<Payroll_Activities__c> getActivities(Integer quantity, Id stageId, Integer estimatedMinutes) {
		List<Payroll_Activities__c> activitiesToInsert = new List<Payroll_Activities__c>();
		for(Integer i = 0; i < quantity; i++) {
			Payroll_Activities__c a = new Payroll_Activities__c(Payroll_Stage__c=stageId, Activity__c='Calculations', Payroll_Identifier__c='test'+i, Start_Date_Time__c=DateTime.now().addDays(10), Estimated_Minutes_To_Complete__c=estimatedMinutes, End_Date_Time__c=DateTime.now().addDays(20));
			activitiesToInsert.add(a);
		}
		return activitiesToInsert;
	}

	public static List<Activity_Checklist__c> getActivityChecks(Integer quantity, Id activityId) {
		List<Activity_Checklist__c> checksToInsert = new List<Activity_Checklist__c>();
		for(Integer i = 0; i < quantity; i++) {
			Activity_Checklist__c c = new Activity_Checklist__c(Payroll_Activity__c=activityId, Action__c='Calculations', Role__c='Service Manager', Sequence_Number__c=1 + i);
			checksToInsert.add(c);
		}
		return checksToInsert;
	}

	public static List<Time_Card__c> getTimecards(Integer quantity, Id activityId) {
		List<Time_Card__c> timecardsToInsert = new List<Time_Card__c>();
		for(Integer i = 0; i < quantity; i++) {
			Time_Card__c tc = new Time_Card__c(Activity__c=activityId, Start__c=DateTime.now());
			timecardsToInsert.add(tc);
		}
		return timecardsToInsert;
	}

	public static List<Bank_Holidays__c> getBankHolidays() {
		List<Bank_Holidays__c> bankHolsToInsert = new List<Bank_Holidays__c>();
		bankHolsToInsert.add(new Bank_Holidays__c(Legislation_Country__c='UK', Bank_Holiday_Name__c='oegen Day', Bank_Holiday_Date__c=Date.today().addDays(30)));
		bankHolsToInsert.add(new Bank_Holidays__c(Legislation_Country__c='UK', Bank_Holiday_Name__c='oegen Day', Bank_Holiday_Date__c=Date.today().addDays(45)));
		bankHolsToInsert.add(new Bank_Holidays__c(Legislation_Country__c='UK', Bank_Holiday_Name__c='oegen Day', Bank_Holiday_Date__c=Date.today().addDays(60)));
		insert bankHolsToInsert;
		return bankHolsToInsert;
	}

	public static User createNoPortalUser(){
   		Id p = [select id from profile where name='Standard User'].id;
        
        User user = new User(alias = 'inacuse', email='testNOportal@hotmail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                profileid = p, country='United Kingdom', IsActive =true, username='testNOportal@hotmail.com', 
                timezonesidkey='America/Los_Angeles', firstName='Test', FederationIdentifier = 'admin@universalcontainers.com');
       
        insert user;
        return user;
    }
	
}