global class HRO_Scheduler_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	public String query;
	public Set<String> errors;
	
	global HRO_Scheduler_Batch() {
		this.errors = new Set<String>();
		this.query = 'SELECT Id FROM Scheduler__c WHERE When__c = \'Tonight\' AND Replication_Status__c = \'Ready to Replicate\' AND Replicate_this_Schedule__c = true';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Scheduler__c> scope) {
		List<Id> schedulesToReplicate = new List<Id>();
		for(Scheduler__c s : scope) {
			schedulesToReplicate.add(s.Id);
		}

		// Replicate the Schedules
		Map<String,List<String>> response = new Map<String,List<String>>(HRO_Scheduler_Utility.replicateSchedules(schedulesToReplicate, false));
		errors.addAll(response.get('errors'));
	}

	global void finish(Database.BatchableContext BC) {
		// Send email summary

		if(OegenHelper.emailIsEnabled || Test.isRunningTest()) {

			try {
				AsyncApexJob a = [Select Id, Status FROM AsyncApexJob WHERE Id = :BC.getJobId()];
				
				List<String> toAddresses = new List<String>();
				toAddresses.addAll(Label.HRO_Scheduler_Overnight_Email_Recipients.deleteWhitespace().split(','));

				if(toAddresses.size() > 0) {
					String plainTextBody = 'There were ' + errors.size() + ' errors while replicating Schedules.';
					plainTextBody += '\n';
					for(String s : errors) {
						plainTextBody += '\n';
						plainTextBody += '\n' + s;
					}
					
					Messaging.SingleEmailMessage mail = OegenHelper.initEmail('MHR - Schedule Replication - ' + a.Status, plainTextBody, toAddresses);

					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
			} catch(Exception e) {}
			
		}
	}
	
}