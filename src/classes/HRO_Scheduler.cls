public with sharing class HRO_Scheduler {
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_HRO_Scheduler.cls
    // By Mark Ramsell 2017.06
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    public Scheduler__c oldSchedule {get;set;}
    public String destination {get;set;}
    public Map<Integer,String> errorCodes;

    public List<SelectOption> getScheduleCompletionDateOpts() {
        List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('true', String.valueOf(HRO_Scheduler_Utility.adjustDate(oldSchedule.Target_Completion__c, oldSchedule.Frequency__c, 1, oldSchedule.Legislation_Country__c).format())));
 	 	options.add(new SelectOption('false', String.valueOf(oldSchedule.Target_Completion__c.format())));
        return options;
    }
    public String adjustFirstReplication {
        get {
            if(adjustFirstReplication == null) {
                adjustFirstReplication = 'true';
            }
            return adjustFirstReplication;
        }
        set;
    }

    public Set<String> feedbackNeg {get;set;}
    public Integer feedbackNegCount {
        get {
            return feedbackNeg.size();
        }
    }
    public Set<String> feedbackPos {get;set;}
    public Integer feedbackPosCount {
        get {
            return feedbackPos.size();
        }
    }
    public Boolean showContinue {
        get {
            if(destination != '' && feedbackNeg.size() == 0 && feedbackPos.size() > 0) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public Boolean hasApexMessages {
        get {
            if(ApexPages.hasMessages()) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    public HRO_Scheduler(ApexPages.StandardController c) {
        if(!Test.isRunningTest()) {
            c.addFields(new List<String>{'Account__c', 'Schedule_Name__c', 'Frequency__c', 'How_many_times__c', 'When__c',
            'Replicate_to_Account__c', 'Target_Completion__c', 'Legislation_Country__c', 'Adjust_First_Replication_Dates__c'});
            this.oldSchedule = (Scheduler__c)c.getRecord();
        } else {
            Id schedId = ApexPages.currentPage().getParameters().get('id');
            this.oldSchedule = [SELECT Id, Account__c, Schedule_Name__c, Frequency__c, How_many_times__c, When__c,
            Replicate_to_Account__c, Target_Completion__c, Legislation_Country__c, Adjust_First_Replication_Dates__c FROM Scheduler__c WHERE Id = :schedId LIMIT 1];
        }
        if(oldSchedule.Replicate_to_Account__c == null) {
            this.oldSchedule.Replicate_to_Account__c = oldSchedule.Account__c;
        }
        this.destination = '';
        this.feedbackNeg = new Set<String>();
        this.feedbackPos = new Set<String>();
        this.errorCodes = OegenHelper.errorCodesInit();
    }
    
    private void resetVars() {
        feedbackNeg.clear();
        feedbackPos.clear();
        destination = '';
    }

    private Boolean doValidate() {
        resetVars();
        if(oldSchedule.Replicate_to_Account__c == null) {
            feedbackNeg.add(errorCodes.get(-4));
            return false;
        }
        if(oldSchedule.How_many_times__c < 1 || oldSchedule.How_many_times__c > 52) {
            feedbackNeg.add(errorCodes.get(-3));
            return false;
        }
        return true;
    }

    public void replicateSchedule() {
        if(doValidate()) {
            try {
                // Exclude old schedule from Flows if When__c is Now
                if(oldSchedule.When__c == 'Now') {
                    oldSchedule.Exclude_from_Flows__c = true;
                }
                // Store user-inputs such as 'How many Times?' into the old Schedule
                oldSchedule.Adjust_First_Replication_Dates__c = Boolean.valueOf(adjustFirstReplication);
                update oldSchedule;

                if(oldSchedule.When__c == 'Now') {

                    // Run the replication asynchronously if how many times is over 12. This is so that we get 6x the CPU time
                    if(oldSchedule.How_many_times__c > 12) {
                        HRO_Scheduler_Utility.replicateSchedulesAsync(new List<Id>{oldSchedule.Id});
                        feedbackPos.add(errorCodes.get(205));
                        destination = 'account';
                    } else {
                        Map<String,List<String>> response = HRO_Scheduler_Utility.replicateSchedules(new List<Id>{oldSchedule.Id}, false);
                        feedbackNeg.addAll(response.get('errors'));
                        if(feedbackNeg.size() == 0) {
                            feedbackPos.add(errorCodes.get(202));
                            destination = 'account';
                        }
                    }

                } else if(oldSchedule.When__c == 'Tonight') {

                    oldSchedule.Replicate_this_Schedule__c = true;
                    oldSchedule.Replication_Status__c = 'Ready to Replicate';
                    update oldSchedule;
                    feedbackPos.add(errorCodes.get(203));
                    destination = 'back';

                } else if(oldSchedule.When__c == 'Hold') {

                    oldSchedule.Replicate_this_Schedule__c = true;
                    oldSchedule.Replication_Status__c = '';
                    update oldSchedule;
                    feedbackPos.add(errorCodes.get(204));
                    destination = 'back';

                } else {

                    feedbackNeg.add(errorCodes.get(-2));
                    destination = '';

                }
            } catch(DMLexception e) {
                resetVars();
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    feedbackNeg.add(e.getDmlMessage(i));
                }
            } catch(Exception e) {
                resetVars();
                feedbackNeg.add(String.valueOf(e));
            }
        }
    }
    
}