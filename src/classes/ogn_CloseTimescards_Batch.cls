///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Class: ogn_CloseTimescards_Batch
    // Unit Test: ogn_CloseTimescards_Batch_Test
    // - Author: AHA 𝝺
    // - Company: Oegen Ltd
    // - Created: 23/07/2018
    // - Description: Batch class to close off all Timecards at midnight each night
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
global class ogn_CloseTimescards_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Integer recordsProcessed = 0;
    
    global String errMessage;
    global String timecardsList;
    global List<Time_Card__c> timecardsListfull = new List<Time_Card__c>();
    
    global RecordType issueRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Time_Card__c' LIMIT 1];
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String timecards = 'SELECT Id,End__c, Name, Activity__c, Start__c, Activity__r.Payroll_Stage__c, Activity__r.Activity__c, CreatedBy.Name, CreatedBy.Email, Activity__r.Stage_Name__c FROM Time_Card__c WHERE End__c = null';
        return Database.getQueryLocator(timecards);
    }
    
    global void execute(Database.BatchableContext bc, List<Time_Card__c> records){
        // process each batch of records
        
        for(Time_Card__c tc : records){
            if(timecardsList != null){
            	timecardsList = timecardsList+ '\n , '+tc.Id + ' - ' + tc.Name + ' - for Activity:' + tc.Activity__c;   
            }
            else{
                timecardsList = tc.Id + ' - ' + tc.Name + ' - for Activity:' + tc.Activity__c;
            }
            timecardsListfull.add(tc);
            
            Datetime dt = Datetime.now();
            if(Datetime.now().time() != Datetime.now().timeGMT()){
            	tc.End__c = DateTime.newInstancegmt(dt.yeargmt(), dt.monthgmt(), dt.daygmt(), 16, 30, 00);
                System.debug('AHA - Debug - GMT Time - ' + tc.End__c);
            }
            else{
        		tc.End__c = DateTime.newInstance(dt.year(), dt.month(), dt.day(), 17, 30, 00);
                System.debug('AHA - Debug - Time - ' + tc.End__c);
            }
        }
        if(!records.isEmpty()){
            try{
            	update records;
                System.debug('AHA - Debug - timecardsList - ' + timecardsList);
            }
            catch(Exception e){
                errMessage = e.getMessage();
                System.debug('AHA - Debug - error - ' + e.getMessage());
                System.debug('AHA - Debug - error2 - ' + e);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('AHA - Debug - size of emails to send ' + timecardsListfull.size());
        for(time_card__c tc : timecardsListfull){
        List<String> toAddresses= new List<String>();
        
            toAddresses.add(tc.CreatedBy.Email);
            
            System.debug('AHA - Debug - To address ' + tc.CreatedBy.Email);
            
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Batch Apex');
            mail.setSubject('Overnight Timecard Batch apex has completed for - ' + system.today());
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody('Hello ' + tc.CreatedBy.Name + '<br></br>' + 'An open timecard for you has been automatically closed overnight with an end date and time of ' + tc.End__c.format('dd/mm/yyyy kk:mm') 
                						+'.<br></br>' + 'If this value is incorrect, either click the Timecard reference link to correct it. <br></br><br></br>'
                						+ 'Further Details:<br></br>'
                						+ 'Stage: ' + tc.Activity__r.Stage_Name__c + '<br></br>'
                						+ 'Activity: ' + tc.Activity__r.Activity__c + '<br></br>'
                						+ 'Timecard reference: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + tc.Id + '">' + tc.Name + '</a><br></br>'
                						+ 'Start date and time: ' + tc.Start__c.format('dd/mm/yyyy kk:mm') + '<br></br>'
                						+ '<br></br>'
                						+ 'Link to Timecard Console: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Ogn_Time_Card_Console?Id=' + tc.Activity__c + '">Click Here</a>');
        
            if(!Test.isRunningTest()){
                if(errMessage != null){
                    system.debug('ERROR EMAIL - ' + errMessage);
                    mail.setPlainTextBody('Batch Failed due to the following error: - ' + errMessage);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                else{
                    //mail.setPlainTextBody('Batch Completed with no Errors');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
        	}
            System.debug('AHA - Debug - Email - ' + mail);
        }
    }
}