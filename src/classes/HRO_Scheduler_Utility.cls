public with sharing class HRO_Scheduler_Utility {
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_HRO_Scheduler.cls
    // By Mark Ramsell 2017.06
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	private static Map<String,List<String>> objTypeToDateFieldsMap;
    private static Map<String,Set<Date>> countryToBankHolidaysMap;

    // A bunch of maps that we'll use to make sure that replicated child records are related to the replicated parent record
    private static Map<String, Scheduler__c> oldScheduleToNewScheduleMap;
	private static Map<String, Key_Dates__c> oldKeyDateToNewKeyDateMap;
    private static Map<String, Payroll_Stage__c> oldStageToNewStageMap;
    private static Map<String,String> oldStageIdToOldDependentStageIdMap;
    private static Map<String, Payroll_Activities__c> oldActivityToNewActivityMap;
    private static Map<String, Activity_Checklist__c> oldCheckToNewCheckMap;

    private static Boolean emailIsEnabled;

    static {
        objTypeToDateFieldsMap = new Map<String,List<String>>();
        // Query Bank Holidays object for all bank holidays that are after today
        List<Bank_Holidays__c> bankHolidays = [SELECT Id, Legislation_Country__c, Bank_Holiday_Date__c, Bank_Holiday_Name__c FROM Bank_Holidays__c WHERE Bank_Holiday_Date__c > :Date.today()];
        countryToBankHolidaysMap = new Map<String,Set<Date>>();
        for(Bank_Holidays__c bh : bankHolidays) {
            if(countryToBankHolidaysMap.containsKey(bh.Legislation_Country__c)) {
                countryToBankHolidaysMap.get(bh.Legislation_Country__c).add(bh.Bank_Holiday_Date__c);
            } else {
                countryToBankHolidaysMap.put(bh.Legislation_Country__c, new Set<Date>{bh.Bank_Holiday_Date__c});
            }
        }
        oldScheduleToNewScheduleMap = new Map<String, Scheduler__c>();
	    oldKeyDateToNewKeyDateMap = new Map<String, Key_Dates__c>();
        oldStageToNewStageMap = new Map<String, Payroll_Stage__c>();
        oldStageIdToOldDependentStageIdMap = new Map<String,String>();
        oldActivityToNewActivityMap = new Map<String, Payroll_Activities__c>();
        oldCheckToNewCheckMap = new Map<String, Activity_Checklist__c>();

        emailIsEnabled = OegenHelper.emailIsEnabled;
    }

    // Provide an Asyncrounous means of running replicateSchedules from the Visualforce page (Overnight Apex will run Async by default)
    // This allows us to support higher Frequency__c values (e.g. 52)
    @future
    public static void replicateSchedulesAsync(List<Id> oldScheduleIds) {
        replicateSchedules(oldScheduleIds, true);
    }

	public static Map<String,List<String>> replicateSchedules(List<Id> oldScheduleIds, Boolean vfAsync) {

        // Initialise the response map that we'll return at the end of this method
		Map<String,List<String>> response = new Map<String,List<String>>{'errors' => new List<String>()};

        // A map from old Schedule Id to old Schedule, so that we can get at fields like How_many_times__c and Replicate_to_Account__c
		Map<Id,Scheduler__c> scheduleIdToScheduleMap = new Map<Id,Scheduler__c>([SELECT Id, How_many_times__c, Frequency__c, Account__c, Replicate_to_Account__c, Legislation_Country__c, Adjust_First_Replication_Dates__c FROM Scheduler__c WHERE Id IN :oldScheduleIds]);
        
        // Create a save point for roll back in case of errors
		Savepoint sp = Database.setSavepoint();
        
        List<Database.SaveResult> results;

        try {
		    /*** SCHEDULES ***/
			// Query for Schedules whose Ids were passed in to the method. Call generateSOQL which builds SOQL to query all fields specified in the 'Fields_to_Replicate' field set
            for(Scheduler__c s : Database.query(generateSOQL('Scheduler__c', 'Id', ''))) {

                List<String> dateFields = objTypeToDateFieldsMap.get('Scheduler__c');

                Scheduler__c oldSchedule = scheduleIdToScheduleMap.get(s.Id);

                // Determine whether the first replication should be a like-for-like copy of the old Schedule in the replication,
                // or whether to push the first replication back by 1 * Frequency__c (week/month/year etc.)
                Integer howManyTimes;
                Integer startOffset;
                if(oldSchedule.Adjust_First_Replication_Dates__c == null || oldSchedule.Adjust_First_Replication_Dates__c == false) {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c) - 1;
                    startOffset = 0;
                } else {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c);
                    startOffset = 1;
                }

                // If Schedule is being cloned to a different Account, blank the Primary Customer Email and Name fields
                Boolean blankCustFields = false;
                if(oldSchedule.Account__c != oldSchedule.Replicate_to_Account__c) {
                    blankCustFields = true;
                }
                // Make sure we replicate the Schedule the correct number of times
				for(Integer i = startOffset; i <= howManyTimes; i++) {
                    // Clone old Schedule and add to map
                    Scheduler__c newSchedule = s.clone(false, true, false, false);
                    newSchedule.Account__c = oldSchedule.Replicate_to_Account__c;
                    // Make sure no processes/flows execute on insert of the new Schedules
                    newSchedule.Exclude_from_Flows__c = true;
                    // Update all date/date time fields to be the correct dates, avoiding bank holidays and weekends
                    for(String field : dateFields) {
                        if(s.get(field) != null) {
                            DateTime newDate = adjustDate((DateTime)s.get(field), oldSchedule.Frequency__c, i, oldSchedule.Legislation_Country__c);
                            newSchedule.put(field, newDate);
                        }
                    }
                    // If Schedule is being cloned to a different Account, blank the Primary Customer Email and Name fields
                    if(blankCustFields) {
                        newSchedule.Primary_Customer_Email__c = null;
                        newSchedule.Primary_Customer_Name__c = null;
                    }
                    // Make sure we set 'Authorised By Customer' to false
                    newSchedule.Authorised_By_Customer__c = false;
                    // The key thing here is to make sure we combine the old Schedule Id with the iteration number, so that we have a unique key for this replicated schedule
                    oldScheduleToNewScheduleMap.put(String.valueOf(s.Id) + i, newSchedule);
                }
			}

            results = Database.Insert(oldScheduleToNewScheduleMap.values(), true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while inserting new Schedule: ' + e);
                    }
                }
            }
		
		    /*** KEY DATES ***/
			// Query for Key Dates whose Schedule__c is in oldScheduleIds. Call generateSOQL which builds SOQL to query all fields specified in the 'Fields_to_Replicate' field set
            for(Key_Dates__c kd : Database.query(generateSOQL('Key_Dates__c', 'Schedule__c', 'Schedule__c'))) {

                List<String> dateFields = objTypeToDateFieldsMap.get('Key_Dates__c');

                Scheduler__c oldSchedule = scheduleIdToScheduleMap.get(kd.Schedule__c);

                // Determine whether the first replication should be a like-for-like copy of the old Schedule in the replication,
                // or whether to push the first replication back by 1 * Frequency__c (week/month/year etc.)
                Integer howManyTimes;
                Integer startOffset;
                if(oldSchedule.Adjust_First_Replication_Dates__c == null || oldSchedule.Adjust_First_Replication_Dates__c == false) {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c) - 1;
                    startOffset = 0;
                } else {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c);
                    startOffset = 1;
                }
                // Make sure we replicate the Key Dates the correct number of times
				for(Integer i = startOffset; i <= howManyTimes; i++) {
                    Key_Dates__c newKd = kd.clone(false, true, false, false);
                    newKd.Schedule__c = oldScheduleToNewScheduleMap.get(String.valueOf(kd.Schedule__c) + i).Id;
                    // Update all date/date time fields to be the correct dates, avoiding bank holidays and weekends
                    if(dateFields != null) {
                        for(String field : dateFields) {
                            if(kd.get(field) != null) {
                                DateTime newDate = adjustDate((DateTime)kd.get(field), oldSchedule.Frequency__c, i, oldSchedule.Legislation_Country__c);
                                newKd.put(field, newDate);
                            }
                        }
                    }
                    oldKeyDateToNewKeyDateMap.put(String.valueOf(kd.Id) + i, newKd);

                }
            }

            results = Database.Insert(oldKeyDateToNewKeyDateMap.values(), true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while inserting new Key Date: ' + e);
                    }
                }
            }

		    /*** STAGES ***/
			// Query for Stages whose Schedule__c is in oldScheduleIds. Call generateSOQL which builds SOQL to query all fields specified in the 'Fields_to_Replicate' field set
            // Order By Stage__c so that the Stages related list is in the correct order on the replicated Schedules
            String stagesQuery = generateSOQL('Payroll_Stage__c', 'Schedule__c', 'Schedule__c') + ' ORDER BY Stage__c ASC';
            // We use a list for inserting new Stages instead of Map.values(), to preserve the sort on Stage__c
            List<Payroll_Stage__c> newStagesList = new List<Payroll_Stage__c>();
            for(Payroll_Stage__c ps : Database.query(stagesQuery)) {

                List<String> dateFields = objTypeToDateFieldsMap.get('Payroll_Stage__c');

                Scheduler__c oldSchedule = scheduleIdToScheduleMap.get(ps.Schedule__c);

                // Determine whether the first replication should be a like-for-like copy of the old Schedule in the replication,
                // or whether to push the first replication back by 1 * Frequency__c (week/month/year etc.)
                Integer howManyTimes;
                Integer startOffset;
                if(oldSchedule.Adjust_First_Replication_Dates__c == null || oldSchedule.Adjust_First_Replication_Dates__c == false) {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c) - 1;
                    startOffset = 0;
                } else {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c);
                    startOffset = 1;
                }
                // Make sure we replicate the Stages the correct number of times
                for(Integer i = startOffset; i <= howManyTimes; i++) {
                    Payroll_Stage__c newPs = ps.clone(false, true, false, false);
                    // Add the old Stage id and dependent stage id's to a map for use when...
                    // hooking new Stages up to the correct new Dependent Stage
                    // We nullify the 'Dependent_Stage__c' field so that we don't trigger a lookup filter
                    if(newPs.Dependent_Stage__c != null) {
                        oldStageIdToOldDependentStageIdMap.put(ps.Id + String.valueOf(i), newPs.Dependent_Stage__c + String.valueOf(i));
                        newPs.Dependent_Stage__c = null;
                    }
                    newPs.Schedule__c = oldScheduleToNewScheduleMap.get(String.valueOf(ps.Schedule__c) + i).Id;
                    // Update all date/date time fields to be the correct dates, avoiding bank holidays and weekends
                    if(dateFields != null) {
                        for(String field : dateFields) {
                            if(ps.get(field) != null) {
                                DateTime newDate = adjustDate((DateTime)ps.get(field), oldSchedule.Frequency__c, i, oldSchedule.Legislation_Country__c);
                                newPs.put(field, newDate);
                            }
                        }
                    }
                    String oldStageId = ps.Id + String.valueOf(i);
                    oldStageToNewStageMap.put(oldStageId, newPs);
                }
            }

            results = Database.Insert(oldStageToNewStageMap.values(), true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while inserting new Stage: ' + e);
                    }
                }
            }
            // Loop through the old Stage Ids that had a Dependent Stage, and link them up to the correct NEW Dependent Stage
            List<Payroll_Stage__c> stagesToUpdate = new List<Payroll_Stage__c>();
            for(String s : oldStageIdToOldDependentStageIdMap.keyset()) {
                Payroll_Stage__c newStage = oldStageToNewStageMap.get(s);
                if(newStage.Id != null) {
                    Payroll_Stage__c newDependentStage = oldStageToNewStageMap.get(oldStageIdToOldDependentStageIdMap.get(s));
                    if(newDependentStage.Id != null) {
                        newStage.Dependent_Stage__c = newDependentStage.Id;
                        stagesToUpdate.add(newStage);
                    }
                }
            }
            // Update the Stages which now have the correct NEW Dependent Stage assigned
            results = Database.Update(stagesToUpdate, true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while attempting to link a new Stage to a new dependent Stage: ' + e);
                    }
                }
            }

		    /*** Activities ***/
			// Query for Activities whose Payroll_Stage__r.Schedule__c is in oldScheduleIds. Call generateSOQL which builds SOQL to query all fields specified in the 'Fields_to_Replicate' field set
            for(Payroll_Activities__c pa : Database.query(generateSOQL('Payroll_Activities__c', 'Payroll_Stage__r.Schedule__c', 'Payroll_Stage__r.Schedule__c'))) {

                List<String> dateFields = objTypeToDateFieldsMap.get('Payroll_Activities__c');

                Scheduler__c oldSchedule = scheduleIdToScheduleMap.get(pa.Payroll_Stage__r.Schedule__c);

                // Determine whether the first replication should be a like-for-like copy of the old Schedule in the replication,
                // or whether to push the first replication back by 1 * Frequency__c (week/month/year etc.)
                Integer howManyTimes;
                Integer startOffset;
                if(oldSchedule.Adjust_First_Replication_Dates__c == null || oldSchedule.Adjust_First_Replication_Dates__c == false) {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c) - 1;
                    startOffset = 0;
                } else {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c);
                    startOffset = 1;
                }
                // Make sure we replicate the Activities the correct number of times
                for(Integer i = startOffset; i <= howManyTimes; i++) {
                    Payroll_Stage__c newStage = oldStageToNewStageMap.get(String.valueOf(pa.Payroll_Stage__c) + i);
                    Payroll_Activities__c newPa = pa.clone(false, true, false, false);
                    newPa.Payroll_Stage__c = newStage.Id;
                    // Update all date/date time fields to be the correct dates, avoiding bank holidays and weekends
                    if(dateFields != null) {
                        for(String field : dateFields) {
                            if(pa.get(field) != null) {
                                if(field != 'Start_Date_Time__c') {
                                    DateTime newDate = adjustDate((DateTime)pa.get(field), oldSchedule.Frequency__c, i, oldSchedule.Legislation_Country__c);
                                    newPa.put(field, newDate);
                                }
                            }
                        }
                    }
                    if(pa.End_Date_Time__c != null && pa.Start_Date_Time__c != null) {
                        // Adjust Start_Date_Time__c to make sure MHR have at least the same amount of time to perform the Activity as before replication
                        Integer startEndDateDifference = Date.valueOf(pa.Start_Date_Time__c).daysBetween(Date.valueOf(pa.End_Date_Time__c));
                        DateTime recalculatedStartDate = Datetime.newInstance(Date.valueOf(newPa.End_Date_Time__c.addDays(startEndDateDifference * -1)), pa.Start_Date_Time__c.time());
                        // Important to set multiplier to zero as we just want to avoid weekends and bank holidays (we've calculated start date based on end date)
                        newPa.Start_Date_Time__c = adjustDate(recalculatedStartDate, oldSchedule.Frequency__c, 0, oldSchedule.Legislation_Country__c);
                    } else if(pa.Start_Date_Time__c != null) {
                        newPa.Start_Date_Time__c = adjustDate(pa.Start_Date_Time__c, oldSchedule.Frequency__c, i, oldSchedule.Legislation_Country__c);
                    }
                    // If the Activity's end date is after it's parent's Target End Date (Stage target end date), make them match or we'll trigger a validation rule
                    if(newPa.End_Date_Time__c != null && newStage.Target_Completion_Date_Time__c != null && newPa.End_Date_Time__c > newStage.Target_Completion_Date_Time__c) {
                        newPa.End_Date_Time__c = newStage.Target_Completion_Date_Time__c;
                    }
                        
                    oldActivityToNewActivityMap.put(String.valueOf(pa.Id) + i, newPa);
                }
            }

            results = Database.Insert(oldActivityToNewActivityMap.values(), true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while inserting new Activity: ' + e);
                    }
                }
            }

		    /*** Activity Checklists ***/
			// Query for Activity Checklists whose Payroll_Activity__r.Payroll_Stage__r.Schedule__c is in oldScheduleIds. Call generateSOQL which builds SOQL to query all fields specified in the 'Fields_to_Replicate' field set
            for(Activity_Checklist__c ac : Database.query(generateSOQL('Activity_Checklist__c', 'Payroll_Activity__r.Payroll_Stage__r.Schedule__c', 'Payroll_Activity__r.Payroll_Stage__r.Schedule__c'))) {
                
                Scheduler__c oldSchedule = scheduleIdToScheduleMap.get(ac.Payroll_Activity__r.Payroll_Stage__r.Schedule__c);
                
                // Determine whether the first replication should be a like-for-like copy of the old Schedule in the replication,
                // or whether to push the first replication back by 1 * Frequency__c (week/month/year etc.)
                Integer howManyTimes;
                Integer startOffset;
                if(oldSchedule.Adjust_First_Replication_Dates__c == null || oldSchedule.Adjust_First_Replication_Dates__c == false) {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c) - 1;
                    startOffset = 0;
                } else {
                    howManyTimes = Integer.valueOf(oldSchedule.How_many_times__c);
                    startOffset = 1;
                }

                // If Schedule is being cloned to a different Account, blank the Primary Customer Email and Name fields
                Boolean blankCustFields = false;
                if(oldSchedule.Account__c != oldSchedule.Replicate_to_Account__c) {
                    blankCustFields = true;
                }
                // Make sure we replicate the Activity Checklists the correct number of times
                for(Integer i = startOffset; i <= howManyTimes; i++) {
                    Activity_Checklist__c newAc = ac.clone(false, true, false, false);
                    newAc.Payroll_Activity__c = oldActivityToNewActivityMap.get(String.valueOf(ac.Payroll_Activity__c) + i).Id;
                    newAc.Started__c = false;
                    newAc.Completed__c = false;
                    // If Schedule is being cloned to a different Account, blank the Primary Customer Email and Name fields
                    if(blankCustFields) {
                        newAc.Primary_Customer_Email__c = null;
                        newAc.Primary_Customer_Name__c = null;
                    }
                    oldCheckToNewCheckMap.put(String.valueOf(ac.Id) + i, newAc);
                }
            }

            results = Database.Insert(oldCheckToNewCheckMap.values(), true);           
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        response.get('errors').add('Error while inserting new Activity Check: ' + e);
                    }
                }
            }
		} catch(Exception e) {
            Database.rollback(sp);
            response.get('errors').add(String.valueOf(e));
            if(vfAsync) {
                sendStatusEmail('Failure');
            }
            return response;
        }

        // If we haven't returned a response by now, there have been no errors. Reset the new Schedules so that they aren't excluded from Processes/Flows
        response.get('errors').addAll(resetNewSchedules(oldScheduleToNewScheduleMap.values()));

        // If we haven't returned a response by now, there have been no errors. Reset the old schedules and then return a response.
        response.get('errors').addAll(resetReplicatedSchedules(scheduleIdToScheduleMap.keyset()));
        
        // Catch-all database roll back if there were any errors at any point in the process
        if(response.get('errors').size() > 0) {
            Database.rollback(sp);
            if(vfAsync) {
                sendStatusEmail('Failure');
            }
        } else {
            if(vfAsync) {
                sendStatusEmail('Success');
            }
        }
        return response;
	}

    private static void sendStatusEmail(String status) {

        if(emailIsEnabled || Test.isRunningTest()) {

            try {
                String plainTextBody;
                Map<Integer,String> errorCodes = OegenHelper.errorCodesInit();
                if(status == 'Success') {
                    plainTextBody = errorCodes.get(206);
                } else {
                    plainTextBody = errorCodes.get(-5);
                }
                Messaging.SingleEmailMessage mail = OegenHelper.initEmail('Long-running Schedule Replication: ' + status, plainTextBody, new List<String>{userInfo.getUserEmail()});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch(Exception e) {}

        }
    }

    // relationshipField parameter allows us to force the SOQL query string to query a single relationship field (not possible to add these to a field set)
	private static String generateSOQL(String objType, String idFieldName, String relationshipField) {

        // Get a full list of fields on the objType passed in
        Map<String, Schema.SObjectField> objFields = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();

        // Add this objType to the objTypeToDateFieldMap Map
        objTypeToDateFieldsMap.put(objType, new List<String>());

        String q = 'SELECT Id';
        if(relationshipField != '') {
            q = q + ', ' + relationshipField;
        }

        for(Schema.FieldSetMember m : Schema.getGlobalDescribe().get(objType).getDescribe().FieldSets.getMap().get('Fields_to_Replicate').getFields()) {
            
            String fieldName = m.getFieldPath();

            String fieldType = String.valueOf(m.getType());
            
            if(objFields.get(fieldName).getDescribe().isUpdateable()) {
                q = q + ', ' + fieldName;

                if(fieldType == 'Date' || fieldType == 'DateTime') {
                    objTypeToDateFieldsMap.get(objType).add(fieldName);
                }
            }
        }

        q = q + ' FROM ' + objType + ' WHERE ' + idFieldName + ' IN :oldScheduleIds';
        return q;
    }

    private static Set<String> resetReplicatedSchedules(Set<Id> replicatedSchedules) {
        
        Set<String> updateResponse = new Set<String>();
        List<Scheduler__c> schedulesToReset = new List<Scheduler__c>();

        for(Id oneId : replicatedSchedules) {
            Scheduler__c s = new Scheduler__c(Id = oneId, Replicate_this_Schedule__c = false, How_many_times__c = null,
                                            Replication_Status__c = 'Replication Completed', When__c = null, Replicate_to_Account__c = null,
                                            Adjust_First_Replication_Dates__c = true, Exclude_from_Flows__c = false);
            schedulesToReset.add(s);
        }
        try {
            List<Database.SaveResult> results = Database.Update(schedulesToReset, true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        updateResponse.add('Error while resetting old Schedule: ' + e);
                    }
                }
            }
        } catch(Exception e) {
            updateResponse.add(String.valueOf(e));
            return updateResponse;
        }
        return updateResponse;
    }

    private static Set<String> resetNewSchedules(List<Scheduler__c> newSchedules) {
        Set<String> updateResponse = new Set<String>();
        List<Scheduler__c> schedulesToReset = new List<Scheduler__c>();
        for(Scheduler__c s : newSchedules) {
            s.Exclude_from_Flows__c = false;
            schedulesToReset.add(s);
        }
        try {
            List<Database.SaveResult> results = Database.Update(schedulesToReset, true);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        updateResponse.add('Error while resetting new Schedule: ' + e);
                    }
                }
            }
        } catch(Exception e) {
            updateResponse.add(String.valueOf(e));
            return updateResponse;
        }
        return updateResponse;
    }

    // Method is also used in HRO_Scheduler VF controller, so must be public
    public static DateTime adjustDate(DateTime oldDate, String frequency, Integer multiplier, String legislationCountry) {
        DateTime newDate;
        if(multiplier > 0) {
            if(frequency == 'Weekly') {
            newDate = oldDate.addDays(7 * multiplier);
            } else if(frequency == 'Fortnightly') {
            newDate = oldDate.addDays(14 * multiplier);
            } else if(frequency == 'Monthly') {
            newDate = oldDate.addMonths(1 * multiplier);
            } else if(frequency == 'Lunar') {
            newDate = oldDate.addDays(28 * multiplier);
            } else if(frequency == 'Quarterly') {
            newDate = oldDate.addMonths(3 * multiplier);
            } else if(frequency == 'Annually') {
            newDate = oldDate.addYears(1 * multiplier);
            }
        } else {
            newDate = oldDate;
        }
        
        if(legislationCountry != '' && legislationCountry != null) {
            // Loop, removing a day until we find a day that isn't a weekend and isn't a bank holiday
            while(countryToBankHolidaysMap.get(legislationCountry).contains(newDate.date()) || isWeekend(newDate)) {
                newDate = newDate.addDays(-1);
            }
        }
        return newDate;
    }

    private static Boolean isWeekend(DateTime theDate) {
        String dayOfWeek = theDate.format('E');
        if(dayOfWeek == 'Sat' || dayOfWeek == 'Sun') {
            return true;
        } else {
            return false;
        }
    }
}