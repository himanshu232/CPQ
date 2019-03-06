global class HRO_RAG_Notifications_Batch implements Database.Batchable<sObject>, Database.Stateful {
	///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_HRO_RAG_Notifications.cls
    // By Mark Ramsell 2017.06
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	public String query;
	public String whereClauses;
    public String lim;
	List<String> activityRagEmailRecipients;
	List<String> stageRagEmailRecipients;
	List<String> scheduleRagEmailRecipients;

	Map<Id,Scheduler__c> schedulesWithAmberStages;
	Map<Id,Scheduler__c> schedulesWithRedStages;
	Map<Id,Payroll_Stage__c> stagesWithAmberActivities;
	Map<Id,Payroll_Stage__c> stagesWithRedActivities;
	
	global HRO_RAG_Notifications_Batch() {

		this.schedulesWithAmberStages = new Map<Id,Scheduler__c>([SELECT Id, (SELECT Id FROM Payroll_Steps__r) FROM Scheduler__c WHERE Id IN (SELECT Schedule__c FROM Payroll_Stage__c WHERE Rag_Status_Text__c = 'Amber') ORDER BY CreatedDate DESC LIMIT 5000]);
		this.schedulesWithRedStages = new Map<Id,Scheduler__c>([SELECT Id, (SELECT Id FROM Payroll_Steps__r) FROM Scheduler__c WHERE Id IN (SELECT Schedule__c FROM Payroll_Stage__c WHERE Rag_Status_Text__c = 'Red') ORDER BY CreatedDate DESC LIMIT 5000]);
		this.stagesWithAmberActivities = new Map<Id,Payroll_Stage__c>([SELECT Id, (SELECT Id FROM Payroll_Steps_Checklists__r) FROM Payroll_Stage__c WHERE Id IN (SELECT Payroll_Stage__c FROM Payroll_Activities__c WHERE Rag_Status_Text__c = 'Amber') ORDER BY CreatedDate DESC LIMIT 10000]);
		this.stagesWithRedActivities = new Map<Id,Payroll_Stage__c>([SELECT Id, (SELECT Id FROM Payroll_Steps_Checklists__r) FROM Payroll_Stage__c WHERE Id IN (SELECT Payroll_Stage__c FROM Payroll_Activities__c WHERE Rag_Status_Text__c = 'Red') ORDER BY CreatedDate DESC LIMIT 10000]);

						// Activities
		this.whereClauses = 'WHERE Payroll_Stage__r.Schedule__r.Authorised_By_Customer__c = true AND (' 
            			+ '(Rag_Status_Text__c = \'Amber\' AND (Amber_RAG_Email_Sent__c = false OR Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Amber_RAG_Email_Sent__c = true OR Red_RAG_Email_Sent__c = true)) '
						
						// Stages 
						+ 'OR (Rag_Status_Text__c = \'Amber\' AND (Payroll_Stage__r.Amber_RAG_Email_Sent__c = false OR Payroll_Stage__r.Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Payroll_Stage__r.Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Payroll_Stage__r.Amber_RAG_Email_Sent__c = true OR Payroll_Stage__r.Red_RAG_Email_Sent__c = true)) '

						// Schedules
						+ 'OR (Rag_Status_Text__c = \'Amber\' AND (Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c = false OR Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c = true OR Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = true))'
            			+ ')';
						
		if(Test.isRunningTest()){
            this.whereClauses = 'WHERE Payroll_Stage__r.Schedule__r.Authorised_By_Customer__c = true AND (' 
            			+ '(Rag_Status_Text__c = \'Amber\' AND (Amber_RAG_Email_Sent__c = false OR Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Amber_RAG_Email_Sent__c = true OR Red_RAG_Email_Sent__c = true)) '
						
						// Stages 
						+ 'OR (Rag_Status_Text__c = \'Amber\' AND (Payroll_Stage__r.Amber_RAG_Email_Sent__c = false OR Payroll_Stage__r.Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Payroll_Stage__r.Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Payroll_Stage__r.Amber_RAG_Email_Sent__c = true OR Payroll_Stage__r.Red_RAG_Email_Sent__c = true)) '

						// Schedules
						+ 'OR (Rag_Status_Text__c = \'Amber\' AND (Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c = false OR Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = true)) '
						+ 'OR (Rag_Status_Text__c = \'Red\' AND Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = false) '
						+ 'OR (Rag_Status_Text__c = \'Green\' AND (Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c = true OR Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c = true))'
            			+ ') LIMIT 200';
        }
        
		this.query = 'SELECT Id, Name, Rag_Status_Text__c, Amber_RAG_Email_Sent__c, Red_RAG_Email_Sent__c, '
		+ 'Payroll_Stage__c, Payroll_Stage__r.Name, Payroll_Stage__r.Rag_Status_Text__c, Payroll_Stage__r.Amber_RAG_Email_Sent__c, Payroll_Stage__r.Red_RAG_Email_Sent__c, '
		+ 'Payroll_Stage__r.Schedule__c, Payroll_Stage__r.Schedule__r.Schedule_Name__c, Payroll_Stage__r.Schedule__r.Rag_Status_Text__c, Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c, Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c '
		+ 'FROM Payroll_Activities__c '
		+ whereClauses;
        
        

		try {
			this.activityRagEmailRecipients = Label.HRO_Activity_RAG_Email_Recipients.deleteWhitespace().split(',');
			this.stageRagEmailRecipients = Label.HRO_Stage_RAG_Email_Recipients.deleteWhitespace().split(',');
			this.scheduleRagEmailRecipients = Label.HRO_Schedule_RAG_Email_Recipients.deleteWhitespace().split(',');
		} catch(Exception e) {
			System.debug(System.LoggingLevel.ERROR, 'Error while querying email recipient custom labels: ' + e.getMessage());
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Integer hours = Integer.valueof(String.valueof(Datetime.NOW().time()).MID(0,2));
        Integer mins = Integer.valueof(String.valueof(Datetime.NOW()).MID(14,2));
        if((hours >= 9 && hours <= 17) || (hours == 17 && mins <= 30)){
        	System.debug('AHA - Debug - ' + Database.getQueryLocator(query));
            return Database.getQueryLocator(query);   
            
        }
        else{
            System.abortJob(bc.getJobId());
            return null;
        }
	}

   	global void execute(Database.BatchableContext BC, List<Payroll_Activities__c> scope) {
		
		Map<Id,Payroll_Activities__c> activitiesToUpdate = new Map<Id,Payroll_Activities__c>();
		Map<Id,Payroll_Stage__c> stagesToUpdate = new Map<Id,Payroll_Stage__c>();
		Map<Id,Scheduler__c> schedulesToUpdate = new Map<Id,Scheduler__c>();

		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

		for(Payroll_Activities__c a : scope) {
            System.debug('AHA - Debug - ' + a);
			// WHERE RAG STATUS IS RED AND RED_RAG_EMAIL_SENT__c == FALSE
			// SEND RED EMAILS, SET RED_RAG_EMAIL_SENT__c to TRUE
			if(a.Rag_Status_Text__c == 'Red' && a.Red_RAG_Email_Sent__c == false) {
				if(activitiesToUpdate.get(a.Id) == null) {
					activitiesToUpdate.put(a.Id, new Payroll_Activities__c(Id=a.Id, Amber_RAG_Email_Sent__c=true, Red_RAG_Email_Sent__c=true));
					emailsToSend.add(OegenHelper.initEmail('A Scheduler Activity is overdue', 'Scheduler Activity <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '\'>' + a.Name + '</a>' + ' on Schedule ' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + ' is now Red status.', activityRagEmailRecipients));
				}
			}
			if(a.Rag_Status_Text__c == 'Red' && a.Payroll_Stage__r.Red_RAG_Email_Sent__c == false) {
				if(stagesToUpdate.get(a.Payroll_Stage__c) == null) {
					stagesToUpdate.put(a.Payroll_Stage__c, new Payroll_Stage__c(Id=a.Payroll_Stage__c, Amber_RAG_Email_Sent__c=true, Red_RAG_Email_Sent__c=true));
					emailsToSend.add(OegenHelper.initEmail('A Scheduler Stage is overdue', 'Scheduler Stage <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Payroll_Stage__c + '\'>' + a.Payroll_Stage__r.Name + '</a>' + ' on Schedule ' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + ' is now Red status.', stageRagEmailRecipients));
				}
			}

			if(a.Rag_Status_Text__c == 'Red' && a.Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c == false) {
				if(schedulesToUpdate.get(a.Payroll_Stage__r.Schedule__c) == null) {
					schedulesToUpdate.put(a.Payroll_Stage__r.Schedule__c, new Scheduler__c(Id=a.Payroll_Stage__r.Schedule__c, Amber_RAG_Email_Sent__c=true, Red_RAG_Email_Sent__c=true));
					emailsToSend.add(OegenHelper.initEmail('A Schedule is overdue', 'Schedule <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Payroll_Stage__r.Schedule__c + '\'>' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + '</a>' + ' is now Red status.', scheduleRagEmailRecipients));
				}
			}

		}

		for(Payroll_Activities__c a : scope) {
			// WHERE RAG STATUS IS AMBER AND AMBER_RAG_EMAIL_SENT__c == FALSE AND RED_RAG_EMAIL_SENT__c == FALSE
			// SEND AMBER EMAILS AND SET AMBER_RAG_EMAIL_SENT__c TO TRUE
			if(a.Rag_Status_Text__c == 'Amber' && (a.Amber_RAG_Email_Sent__c == false || a.Red_RAG_Email_Sent__c == true)) {
				if(activitiesToUpdate.get(a.Id) == null) {
					Payroll_Activities__c newAct = new Payroll_Activities__c();
					if(a.Red_RAG_Email_Sent__c == true) {
						newAct.Id = a.Id;
						newAct.Red_RAG_Email_Sent__c = false;
					}
					if(a.Amber_RAG_Email_Sent__c == false) {
						newAct.Id = a.Id;
						newAct.Amber_RAG_Email_Sent__c = true;
					}
					if(a.Amber_RAG_Email_Sent__c == false && a.Red_RAG_Email_Sent__c == false) {
						emailsToSend.add(OegenHelper.initEmail('A Scheduler Activity is at risk', 'Scheduler Activity <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '\'>' + a.Name + '</a>' + ' on Schedule ' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + ' is now Amber status.', activityRagEmailRecipients));
					}
					if(newAct.Id != null) {
						activitiesToUpdate.put(newAct.Id, newAct);
					}
				}
			}
			if(a.Rag_Status_Text__c == 'Amber' && (a.Payroll_Stage__r.Amber_RAG_Email_Sent__c == false || a.Payroll_Stage__r.Red_RAG_Email_Sent__c == true)) {
				if(stagesToUpdate.get(a.Payroll_Stage__c) == null) {
					Payroll_Stage__c newStage = new Payroll_Stage__c();
					if(a.Payroll_Stage__r.Red_RAG_Email_Sent__c == true) {
						//CHECK IF STAGE HAS ANY RED ACTIVIES AND IF NOT, SET RED_RAG_EMAIL_SENT__c TO FALSE
						if(!stagesWithRedActivities.containsKey(a.Payroll_Stage__c)) {
							newStage.Id = a.Payroll_Stage__c;
							newStage.RED_RAG_Email_Sent__c = false;
						} else {
							Boolean zeroRedActivities = true;
							for(Payroll_Activities__c p : stagesWithRedActivities.get(a.Payroll_Stage__c).Payroll_Steps_Checklists__r) {
								if(activitiesToUpdate.containsKey(p.Id)) {
									if(activitiesToUpdate.get(p.Id).Red_RAG_Email_Sent__c != false) {
										zeroRedActivities = false;
									}
								} else {
									zeroRedActivities = false;
								}
							}
							if(zeroRedActivities) {
								newStage.Id = a.Payroll_Stage__c;
								newStage.Red_RAG_Email_Sent__c = false;
							}
						}
					}
					if(a.Payroll_Stage__r.Amber_RAG_Email_Sent__c == false) {
						newStage.Id = a.Payroll_Stage__c;
						newStage.Amber_RAG_Email_Sent__c = true;
					}
					if(a.Payroll_Stage__r.Amber_RAG_Email_Sent__c == false && a.Payroll_Stage__r.Red_RAG_Email_Sent__c == false) {
						emailsToSend.add(OegenHelper.initEmail('A Scheduler Stage is at risk', 'Scheduler Stage <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Payroll_Stage__c + '\'>' + a.Payroll_Stage__r.Name + '</a>' + ' on Schedule ' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + ' is now Amber status.', stageRagEmailRecipients));
					}
					if(newStage.Id != null) {
						stagesToUpdate.put(newStage.Id, newStage);
					}
				}
			}
			if(a.Rag_Status_Text__c == 'Amber' && (a.Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c == false || a.Payroll_Stage__r.Red_RAG_Email_Sent__c == true)) {
				if(schedulesToUpdate.get(a.Payroll_Stage__r.Schedule__c) == null) {
					Scheduler__c newSched = new Scheduler__c();
					if(a.Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c == true) {
						//CHECK IF SCHEDULE HAS ANY RED STAGES AND IF NOT, SENT RED_RAG_EMAIL_SENT__c TO FALSE
						if(!schedulesWithRedStages.containsKey(a.Payroll_Stage__r.Schedule__c)) {
							newSched.Id = a.Payroll_Stage__r.Schedule__c;
							newSched.Red_RAG_Email_Sent__c = false;
						} else {
							Boolean zeroRedStages = true;
							for(Payroll_Stage__c s : schedulesWithRedStages.get(a.Payroll_Stage__r.Schedule__c).Payroll_Steps__r) {
								if(stagesToUpdate.containsKey(s.Id)) {
									if(stagesToUpdate.get(s.Id).Red_RAG_Email_Sent__c != false) {
										zeroRedStages = false;
									}
								} else {
									zeroRedStages = false;
								}
							}
							if(zeroRedStages) {
								newSched.Id = a.Payroll_Stage__r.Schedule__c;
								newSched.Red_RAG_Email_Sent__c = false;
							}
						}
						if(newSched.Id != null) {
							schedulesToUpdate.put(newSched.Id, newSched);
						}
					}
					if(a.Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c == false) {
						newSched.Id = a.Payroll_Stage__r.Schedule__c;
						newSched.Amber_RAG_Email_Sent__c = true;
					}
					if(a.Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c == false && a.Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c == false) {
						emailsToSend.add(OegenHelper.initEmail('A Schedule is at risk', 'Schedule <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Payroll_Stage__r.Schedule__c + '\'>' + a.Payroll_Stage__r.Schedule__r.Schedule_Name__c + '</a>' + ' is now Amber status.', scheduleRagEmailRecipients));
					}
					if(newSched.Id != null) {
						schedulesToUpdate.put(newSched.Id, newSched);
					}
				}
			}
		}

		for(Payroll_Activities__c a : scope) {
			// WHERE RAG STATUS IS GREEN AND AMBER_RAG_EMAIL_SENT__c OR RED_RAG_EMAIL_SENT__c == TRUE
			// DO NOT SEND ANY EMAILS, SET AMBER_RAG_EMAIL_SENT__c AND RED_RAG_EMAIL_SENT__c to FALSE WHERE APPROPRIATE
			if(a.Rag_Status_Text__c == 'Green' && (a.Amber_RAG_Email_Sent__c == true || a.Red_RAG_Email_Sent__c == true)) {
				if(activitiesToUpdate.get(a.Id) == null) {
					activitiesToUpdate.put(a.Id, new Payroll_Activities__c(Id=a.Id, Amber_RAG_Email_Sent__c=false, Red_RAG_Email_Sent__c=false));
				}
			}
			if(a.Rag_Status_Text__c == 'Green' && (a.Payroll_Stage__r.Amber_RAG_Email_Sent__c == true || a.Payroll_Stage__r.Red_RAG_Email_Sent__c == true)) {
				if(stagesToUpdate.get(a.Payroll_Stage__c) == null) {
					Payroll_Stage__c newStage = new Payroll_Stage__c();
					//CHECK IF STAGE HAS ANY AMBER ACTIVIES AND IF NOT, SET AMBER_RAG_EMAIL_SENT__c TO FALSE
					if(!stagesWithAmberActivities.containsKey(a.Payroll_Stage__c)) {
						newStage.Id = a.Payroll_Stage__c;
						newStage.Amber_RAG_Email_Sent__c = false;
					} else {
						Boolean zeroAmberActivities = true;
						for(Payroll_Activities__c p : stagesWithAmberActivities.get(a.Payroll_Stage__c).Payroll_Steps_Checklists__r) {
							if(activitiesToUpdate.containsKey(p.Id)) {
								if(activitiesToUpdate.get(p.Id).Amber_RAG_Email_Sent__c != false) {
									zeroAmberActivities = false;
								}
							} else {
								zeroAmberActivities = false;
							}
						}
						if(zeroAmberActivities) {
							newStage.Id = a.Payroll_Stage__c;
							newStage.Amber_RAG_Email_Sent__c = false;
						}
					}
					//CHECK IF STAGE HAS ANY RED ACTIVITIES AND IF NOT, SET RED_RAG_EMAIL_SENT__c TO FALSE
					if(!stagesWithRedActivities.containsKey(a.Payroll_Stage__c)) {
						newStage.Id = a.Payroll_Stage__c;
						newStage.Red_RAG_Email_Sent__c = false;
					} else {
						Boolean zeroRedActivities = true;
						for(Payroll_Activities__c p : stagesWithRedActivities.get(a.Payroll_Stage__c).Payroll_Steps_Checklists__r) {
							if(activitiesToUpdate.containsKey(p.Id)) {
								if(activitiesToUpdate.get(p.Id).Red_RAG_Email_Sent__c != false) {
									zeroRedActivities = false;
								}
							} else {
								zeroRedActivities = false;
							}
						}
						if(zeroRedActivities) {
							newStage.Id = a.Payroll_Stage__c;
							newStage.Red_RAG_Email_Sent__c = false;
						}
					}
					if(newStage.Id != null) {
						stagesToUpdate.put(newStage.Id, newStage);
					}
				}
			}
		}
		
		for(Payroll_Activities__c a : scope) {
			if(a.Rag_Status_Text__c == 'Green' && (a.Payroll_Stage__r.Schedule__r.Amber_RAG_Email_Sent__c == true || a.Payroll_Stage__r.Schedule__r.Red_RAG_Email_Sent__c == true)) {
				if(schedulesToUpdate.get(a.Payroll_Stage__r.Schedule__c) == null) {
					Scheduler__c newSched = new Scheduler__c();
					//CHECK IF SCHEDULE HAS ANY AMBER STAGES AND IF NOT, SET AMBER_RAG_EMAIL_SENT__c TO FALSE
					if(!schedulesWithAmberStages.containsKey(a.Payroll_Stage__r.Schedule__c)) {
						newSched.Id = a.Payroll_Stage__r.Schedule__c;
						newSched.Amber_RAG_Email_Sent__c = false;
					} else {
						Boolean zeroAmberStages = true;
						for(Payroll_Stage__c s : schedulesWithAmberStages.get(a.Payroll_Stage__r.Schedule__c).Payroll_Steps__r) {
							if(stagesToUpdate.containsKey(s.Id)) {
								if(stagesToUpdate.get(s.Id).Amber_RAG_Email_Sent__c != false) {
									zeroAmberStages = false;
								}
							} else {
								zeroAmberStages = false;
							}
						}
						if(zeroAmberStages) {
							newSched.Id = a.Payroll_Stage__r.Schedule__c;
							newSched.Amber_RAG_Email_Sent__c = false;
						}
					}
					//CHECK IF SCHEDULE HAS ANY RED STAGES AND IF NOT, SENT RED_RAG_EMAIL_SENT__c TO FALSE
					if(!schedulesWithRedStages.containsKey(a.Payroll_Stage__r.Schedule__c)) {
						newSched.Id = a.Payroll_Stage__r.Schedule__c;
						newSched.Red_RAG_Email_Sent__c = false;
					} else {
						Boolean zeroRedStages = true;
						for(Payroll_Stage__c s : schedulesWithRedStages.get(a.Payroll_Stage__r.Schedule__c).Payroll_Steps__r) {
							if(stagesToUpdate.containsKey(s.Id)) {
								if(stagesToUpdate.get(s.Id).Red_RAG_Email_Sent__c != false) {
									zeroRedStages = false;
								}
							} else {
								zeroRedStages = false;
							}
						}
						if(zeroRedStages) {
							newSched.Id = a.Payroll_Stage__r.Schedule__c;
							newSched.Red_RAG_Email_Sent__c = false;
						}
					}
					if(newSched.Id != null) {
						schedulesToUpdate.put(newSched.Id, newSched);
					}
				}
			}
		}

		// SEND THE EMAILS
		if(OegenHelper.emailIsEnabled) {

			if(emailsToSend.size() > 0) {
                try {
                    Messaging.reserveSingleEmailCapacity(emailsToSend.size());
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend, false);
                    for(Messaging.SendEmailResult r : results) {
                        if(!r.isSuccess()) {
                            for(Messaging.SendEmailError e : r.getErrors()) {
                                System.debug(System.LoggingLevel.ERROR, 'Error while sending a RAG status email: ' + e.getMessage());
                            }
                        }
                        
                    }
                } catch(Exception e) {
                    System.debug(System.LoggingLevel.ERROR, 'Error while sending RAG status emails: ' + e.getMessage());
                }
            }

		}

		// UPDATE THE SOBJECTS TO REFLECT EMAILS HAVING BEEN SENT
		if(!activitiesToUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.Update(activitiesToUpdate.values(), false);
			for(Database.SaveResult sr : results) {
				if(!sr.isSuccess()) {
					for(Database.Error e : sr.getErrors()) {
						System.debug(System.LoggingLevel.ERROR, 'Error while updating Activity: ' + e.getMessage() + '. Fields affecting this error: ' + e.getFields());
					}
				}
			}
		}

		if(!stagesToUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.Update(stagesToUpdate.values(), false);
			for(Database.SaveResult sr : results) {
				if(!sr.isSuccess()) {
					for(Database.Error e : sr.getErrors()) {
						System.debug(System.LoggingLevel.ERROR, 'Error while updating Stage: ' + e.getMessage() + '. Fields affecting this error: ' + e.getFields());
					}
				}
			}
		}
	
		if(!schedulesToUpdate.isEmpty()) {
			List<Database.SaveResult> results = Database.Update(schedulesToUpdate.values(), false);
			for(Database.SaveResult sr : results) {
				if(!sr.isSuccess()) {
					for(Database.Error e : sr.getErrors()) {
						System.debug(System.LoggingLevel.ERROR, 'Error while updating Schedule: ' + e.getMessage() + '. Fields affecting this error: ' + e.getFields());
					}
				}
			}
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		// Nothing for now
	}
	
}