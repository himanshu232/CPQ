public with sharing class HRO_Key_Date_Trigger_Handler {

    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_HRO_Key_Date_Trigger.cls
    // By Mark Ramsell 2017.06
    // Updated by Robin Price 08/05/2018 to enhance and
    // correct text in the email notifications:
    //    1) When rescheduled, deleted or cancelled then
    //         report the last modified user not the creator
    //    2) Replace the word “transmission” in emails 
    //         related to print 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    Static Date today;
    Static List<String> toAddresses;
    static {
        today = Date.today();
        // to Address set to Robin Price during testing
        // toAddresses = new List<String>{'r.price@mhr.co.uk'}; 
         toAddresses = new List<String>{'BAUManagementTeam@mhr.co.uk'};
    }
    
    public static void handleAfterInsert(Map<Id,Key_Dates__c> newMap) {
        processEmailAlerts(newMap, new Map<Id,Key_Dates__c>(), false, true);
    }

    public static void handleAfterUpdate(Map<Id,Key_Dates__c> newMap, Map<Id,Key_Dates__c> oldMap) {
        processEmailAlerts(newMap, oldMap, false, false);
    }

    public static void handleBeforeDelete(Map<Id,Key_Dates__c> oldMap) {
        processEmailAlerts(new Map<Id,Key_Dates__c>(), oldMap, true, false);
    }

    public static void processEmailAlerts(Map<Id,Key_Dates__c> newMap, Map<Id,Key_Dates__c> oldMap, Boolean isDelete, Boolean isInsert) {

        // Create a list of Key Dates that we can add to as we go
        // And then set their 'Email_Alert_Sent__c' fields to true
        List<Key_Dates__c> keyDatesToUpdate = new List<Key_Dates__c>();

        if(OegenHelper.emailIsEnabled || Test.isRunningTest()) {

            Map<Id,Key_Dates__c> keyDateIdToKeyDateInfoMap = new Map<Id,Key_Dates__c>([SELECT Id, Email_Alert_Sent__c, Schedule__r.Account__r.Name, Schedule__c, Schedule__r.Schedule_Name__c, Schedule__r.Schedule_Responsibility__c,
                                                                                        CreatedBy.LastName, CreatedBy.FirstName, CreatedBy.UserName, CreatedDate,
                                                                                        LastModifiedBy.Username, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedDate,
                                                                                        Cancelled__c, Assigned_To__c, Date_Time_1__c, Date_Time_2__c, Date_Time_3__c
                                                                                        FROM Key_Dates__c WHERE (Cancelled__c = true OR Rescheduled__c != true) AND Authorised_by_related_customer__c = true AND (Id IN :newMap.keyset() OR Id IN :oldMap.keyset())]);

            Map<Id,Key_Dates__c> keyDateIdToKeyDateInfoMapChange = new Map<Id,Key_Dates__c>([SELECT Id, Email_Alert_Sent__c, Schedule__r.Account__r.Name, Schedule__c, Schedule__r.Schedule_Name__c, Schedule__r.Schedule_Responsibility__c,
                                                                                        CreatedBy.LastName, CreatedBy.FirstName, CreatedBy.UserName, CreatedDate,
                                                                                        LastModifiedBy.Username, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedDate,
                                                                                        Cancelled__c, Assigned_To__c, Date_Time_1__c, Date_Time_2__c, Date_Time_3__c
                                                                                        FROM Key_Dates__c WHERE Authorised_by_related_customer__c = true AND (Id IN :newMap.keyset() OR Id IN :oldMap.keyset())]);

            Map<Id,Map<String,Object>> keyDateIdToBACSInfoMap = new Map<Id,Map<String,Object>>();
            Map<Id,Map<String,Object>> keyDateIdToPRINTInfoMap = new Map<Id,Map<String,Object>>();
            
            //Initialize variables for change emails
            Map<Id,Map<String,Object>> keyDateIdToBACSInfoMapChange = new Map<Id,Map<String,Object>>();
            Map<Id,Map<String,Object>> keyDateIdToPRINTInfoMapChange = new Map<Id,Map<String,Object>>();

            for( Key_Dates__c k : isDelete ? oldMap.values() : newMap.values() ) {

                Key_Dates__c newKD;
                Key_dates__c oldKD;
                if(!isDelete) {
                    newKD = newMap.get(k.Id);
                }
                oldKD = oldMap.get(k.Id);

                // Check whether the Key Date may qualify for an email alert
                //if(isInsert || (isDelete && oldKD.Cancelled__c == false) || (oldKD.Cancelled__c == false && newKD.Cancelled__c == true) || oldKD.Date_Time_1__c != newKD.Date_Time_1__c || oldKD.Date_Time_2__c != newKD.Date_Time_2__c || oldKD.Date_Time_3__c != newKD.Date_Time_3__c) {
				if(isInsert || isDelete || (oldKD.Cancelled__c == false && newKD.Cancelled__c == true) || oldKD.Date_Time_1__c != newKD.Date_Time_1__c) {
                    if(k.Record_Description__c == 'BACS') {
                        if(k.Description_1__c != null && k.Description_1__c.toLowerCase().contains('transmission') && k.Date_Time_1__c != null && k.Date_Time_1__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_1__c != null && oldMap.get(k.Id).Date_Time_1__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ) {
                            System.debug('AHA - Debug - Inside BACS to today');
                            keyDateIdToBACSInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_1__c, 'dateTime' => k.Date_Time_1__c});
                            if(!isInsert) {
                                keyDateIdToBACSInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_1__c);
                            }

                        } else if(k.Description_2__c != null && k.Description_2__c.toLowerCase().contains('transmission') && k.Date_Time_2__c != null && k.Date_Time_2__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_2__c != null && oldMap.get(k.Id).Date_Time_2__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ) {
                            
                            keyDateIdToBACSInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_2__c, 'dateTime' => k.Date_Time_2__c});
                            if(!isInsert) {
                                keyDateIdToBACSInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_2__c);
                            }

                        } else if(k.Description_3__c != null && k.Description_3__c.toLowerCase().contains('transmission') && k.Date_Time_3__c != null && k.Date_Time_3__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_3__c != null && oldMap.get(k.Id).Date_Time_3__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ) {

                            keyDateIdToBACSInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_3__c, 'dateTime' => k.Date_Time_3__c});
                            if(!isInsert) {
                                keyDateIdToBACSInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_3__c);
                            }

                        }
                        
                        //If date changed from today
                        if(oldMap.get(k.Id) != null && k.Authorised_by_related_customer__c == true){
                            System.debug('AHA - Debug - Inside BACS Changed 1');
                            if(oldMap.get(k.Id).Date_Time_1__c != null){
                                System.debug('AHA - Debug - Inside BACS Changed 2');
                                if(k.Description_1__c != null && k.Description_1__c.toLowerCase().contains('transmission') && k.Date_Time_1__c != null  && (!isInsert && (k.Date_Time_1__c.Date() != today && oldMap.get(k.Id).Date_Time_1__c != null && oldMap.get(k.Id).Date_Time_1__c.Date() == today)) ) {
                                    System.debug('AHA - Debug - Inside BACS Changed 3');
                                    keyDateIdToBACSInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_1__c, 'dateTime' => k.Date_Time_1__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_1__c});
                                }
                            }
                            /*else If(oldMap.get(k.Id).Date_Time_2__c != null){
                                if(k.Description_2__c != null && k.Description_2__c.toLowerCase().contains('transmission') && k.Date_Time_2__c != null  && (!isInsert && (k.Date_Time_2__c.Date() != today && oldMap.get(k.Id).Date_Time_2__c != null && oldMap.get(k.Id).Date_Time_2__c.Date() == today)) ) {                                       
                                   keyDateIdToBACSInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_2__c, 'dateTime' => k.Date_Time_2__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_2__c});
                                }
                            }
                            else If(oldMap.get(k.Id).Date_Time_3__c != null){
                                if(k.Description_3__c != null && k.Description_3__c.toLowerCase().contains('transmission') && k.Date_Time_3__c != null && (!isInsert && (k.Date_Time_3__c.Date() != today && oldMap.get(k.Id).Date_Time_3__c != null && oldMap.get(k.Id).Date_Time_3__c.Date() == today)) ) {   
                                    keyDateIdToBACSInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_3__c, 'dateTime' => k.Date_Time_3__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_3__c});
                                }
                            }*/
                        }

                    } else if (k.Record_Description__c == 'Print') {
                        if(k.Description_1__c != null && k.Description_1__c.toLowerCase().contains('print & dispatch') && k.Date_Time_1__c != null && k.Date_Time_1__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_1__c != null && oldMap.get(k.Id).Date_Time_1__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ){

                            keyDateIdToPRINTInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_1__c, 'dateTime' => k.Date_Time_1__c});
                            if(!isInsert) {
                                keyDateIdToPRINTInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_1__c);
                            }

                        } else if(k.Description_2__c != null && k.Description_2__c.toLowerCase().contains('print & dispatch') && k.Date_Time_2__c != null && k.Date_Time_2__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_2__c != null && oldMap.get(k.Id).Date_Time_2__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ){
                            
                            keyDateIdToPRINTInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_2__c, 'dateTime' => k.Date_Time_2__c});
                            if(!isInsert) {
                                keyDateIdToPRINTInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_2__c);
                            }

                        } else if(k.Description_3__c != null && k.Description_3__c.toLowerCase().contains('print & dispatch') && k.Date_Time_3__c != null && k.Date_Time_3__c.Date() == today &&  ( (!isInsert && oldMap.get(k.Id).Date_Time_3__c != null && oldMap.get(k.Id).Date_Time_3__c.Date() != today) || isInsert) || (k.Cancelled__c) || (isDelete) ){

                            keyDateIdToPRINTInfoMap.put(k.Id, new Map<String,Object>{'text' => k.Description_3__c, 'dateTime' => k.Date_Time_3__c});
                            if(!isInsert) {
                                keyDateIdToPRINTInfoMap.get(k.Id).put('oldDateTime', oldMap.get(k.Id).Date_Time_3__c);
                            }

                        }

                        //If date changed from today
                        if(oldMap.get(k.Id) != null){
                       
                                if(oldMap.get(k.Id).Date_Time_1__c != null){
                                    if(k.Description_1__c != null && k.Description_1__c.toLowerCase().contains('print & dispatch') && k.Date_Time_1__c != null  && (!isInsert && (k.Date_Time_1__c.Date() != today && oldMap.get(k.Id).Date_Time_1__c != null && oldMap.get(k.Id).Date_Time_1__c.Date() == today)) ) {
                                        keyDateIdToPRINTInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_1__c, 'dateTime' => k.Date_Time_1__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_1__c});
                                    }
                                }
                               /* else If(oldMap.get(k.Id).Date_Time_2__c != null){
                                    if(k.Description_2__c != null && k.Description_2__c.toLowerCase().contains('print & dispatch') && k.Date_Time_2__c != null   && (!isInsert && (k.Date_Time_2__c.Date() != today && oldMap.get(k.Id).Date_Time_2__c != null && oldMap.get(k.Id).Date_Time_2__c.Date() == today)) ) {                                       
                                       keyDateIdToPRINTInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_2__c, 'dateTime' => k.Date_Time_2__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_2__c});
                                    }
                                }
                                else If(oldMap.get(k.Id).Date_Time_3__c != null){
                                    if(k.Description_3__c != null && k.Description_3__c.toLowerCase().contains('print & dispatch') && k.Date_Time_3__c != null   && (!isInsert && (k.Date_Time_3__c.Date() != today && oldMap.get(k.Id).Date_Time_3__c != null && oldMap.get(k.Id).Date_Time_3__c.Date() == today)) ) {   
                                        keyDateIdToPRINTInfoMapChange.put(k.Id, new Map<String,Object>{'text' => k.Description_3__c, 'dateTime' => k.Date_Time_3__c, 'oldDateTime' => oldMap.get(k.Id).Date_Time_3__c});
                                    }
                                }*/
                            
                        }
                    }
                }
            }

            // SEND THE EMAILS
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            // BACS
            for(Id i : keyDateIdToBACSInfoMap.keyset()) {

                DateTime dt = (DateTime)keyDateIdToBACSInfoMap.get(i).get('dateTime');
                DateTime oldDt;
                if(!isInsert) {
                    oldDt = (DateTime)keyDateIdToBACSInfoMap.get(i).get('oldDateTime');
                }

                // Not Deleted or Cancelled
                if(!keyDateIdToKeyDateInfoMap.isEmpty()){
                    if(!isDelete && !keyDateIdToKeyDateInfoMap.get(i).Cancelled__c) {
    
                        String emailSubject = 'Additional BACS ' + keyDateIdToBACSInfoMap.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>Additional BACS transmission for today</b></p>'
                        + 'Type: ' + keyDateIdToBACSInfoMap.get(i).get('text')
                        + '<br/>Time of planned transmission: ' + dt.format();
                        emailBody += '<br/>Original transmission date: ';
                        emailBody += isInsert ? 'NEW' : oldDt.format();
                        emailBody += '<br/>Customer: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        emailBody += isInsert ? 'NEW' : 'Rescheduled';
                        emailBody += '<br/>Assigned to: ' + keyDateIdToKeyDateInfoMap.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMap.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c + '</a>'
                        + '<br/>Team: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Responsibility__c;
                        if(isInsert) {
                            emailBody += '<br/>Added by: '+ keyDateIdToKeyDateInfoMap.get(i).CreatedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.Username + ')'
                            + '<br/>Added on: ' + keyDateIdToKeyDateInfoMap.get(i).CreatedDate.format();
                        }
                        if(!isInsert) {
                            emailBody += '<br/>Rescheduled by: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.Username + ')'
                            + '<br/>Rescheduled on: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedDate.format();
                        }
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
    
                    }
                    // Deleted or Cancelled
                    //removed at request of robin and added line below
                    //else if(keyDateIdToKeyDateInfoMap.get(i).Date_Time_1__c.Date() == today || keyDateIdToKeyDateInfoMap.get(i).Date_Time_2__c.Date() == today || keyDateIdToKeyDateInfoMap.get(i).Date_Time_3__c.Date() == today){
						else if(keyDateIdToKeyDateInfoMap.get(i).Date_Time_1__c.Date() == today){
     					String emailSubject = 'Cancelled BACS ' + keyDateIdToBACSInfoMap.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>Cancelled BACS transmission for today</b></p>'
                        + 'Type: ' + keyDateIdToBACSInfoMap.get(i).get('text')
                        + '<br/>Time of planned transmission: ' + dt.format()
                        + '<br/>Customer: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        emailBody += !isDelete ? 'Cancelled' : 'Deleted';
                        emailBody += '<br/>Unassigned from: ' + keyDateIdToKeyDateInfoMap.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMap.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c + '</a>'                    + '<br/>Team: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Responsibility__c
                        //+ '<br/>Deleted/Cancelled by: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.Username + ')'
                        //+ '<br/>Deleted/Cancelled on: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedDate.format();
                        + '<br/>Deleted/Cancelled by: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' (' + UserInfo.getUserName() + ')'
                        + '<br/>Deleted/Cancelled on: ' + Datetime.now().format('dd/MM/yyyy HH:mm');
    
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
    
                    }
                }
            }

            // PRINT
            for(Id i : keyDateIdToPRINTInfoMap.keyset()) {
                
                DateTime dt = (DateTime)keyDateIdToPRINTInfoMap.get(i).get('dateTime');

                DateTime oldDt;
                if(!isInsert) {
                    oldDt = (DateTime)keyDateIdToPRINTInfoMap.get(i).get('oldDateTime');
                }

                // Not Deleted or Cancelled
                if(!keyDateIdToKeyDateInfoMap.isEmpty()){
                    if(!isDelete && !keyDateIdToKeyDateInfoMap.get(i).Cancelled__c) {
    
                        String emailSubject = 'Additional PRINT ' + keyDateIdToPRINTInfoMap.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>Additional PRINT job for today</b></p>'
                        + 'Type: ' + keyDateIdToPRINTInfoMap.get(i).get('text')
                        + '<br/>Time of planned print: ' + dt.format();
                        emailBody += '<br/>Original print date: ';
                        emailBody += isInsert ? 'NEW' : oldDt.format();
                        emailBody += '<br/>Customer: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        emailBody += isInsert ? 'NEW' : 'Rescheduled';
                        emailBody += '<br/>Assigned to: ' + keyDateIdToKeyDateInfoMap.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMap.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c + '</a>'
                        + '<br/>Team: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Responsibility__c;
                         if(isInsert) {
                            emailBody += '<br/>Added by: '+ keyDateIdToKeyDateInfoMap.get(i).CreatedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.Username + ')'
                            + '<br/>Added on: ' + keyDateIdToKeyDateInfoMap.get(i).CreatedDate.format();
                        }
                        if(!isInsert) {
                            emailBody += '<br/>Rescheduled by: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.Username + ')'
                            + '<br/>Rescheduled on: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedDate.format();
                        }
                        //+ '<br/>Added by: ' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).CreatedBy.Username + ')'
                        //+ '<br/>Added on: ' + keyDateIdToKeyDateInfoMap.get(i).CreatedDate.format();
                        //+ '<br/>Original print date: ';
                        //emailBody += isInsert ? 'NEW' : oldDt.format();
    
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
    
                    }
                    // Deleted or Cancelled
                    // below line removed at request of robin price and new line added below.
                    // else if(keyDateIdToKeyDateInfoMap.get(i).Date_Time_1__c.Date() == today || keyDateIdToKeyDateInfoMap.get(i).Date_Time_2__c.Date() == today || keyDateIdToKeyDateInfoMap.get(i).Date_Time_3__c.Date() == today){
    					else if(keyDateIdToKeyDateInfoMap.get(i).Date_Time_1__c.Date() == today){
    
                        String emailSubject = 'Cancelled PRINT ' + keyDateIdToPRINTInfoMap.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>Cancelled PRINT job for today</b></p>'
                        + 'Type: ' + keyDateIdToPRINTInfoMap.get(i).get('text')
                        + '<br/>Time of planned print: ' + dt.format() 
                        + '<br/>Customer: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        //emailBody += keyDateIdToKeyDateInfoMap.get(i).Cancelled__c ? 'Cancelled' : 'Deleted';
                        emailBody += !isDelete ? 'Cancelled' : 'Deleted';
                        emailBody += '<br/>Unassigned from: ' + keyDateIdToKeyDateInfoMap.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMap.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Name__c + '</a>'
                        + '<br/>Team: ' + keyDateIdToKeyDateInfoMap.get(i).Schedule__r.Schedule_Responsibility__c
                        //+ '<br/>Deleted/Cancelled by: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedBy.Username + ')'
                        //+ '<br/>Deleted/Cancelled on: ' + keyDateIdToKeyDateInfoMap.get(i).LastModifiedDate.format();
                        + '<br/>Deleted/Cancelled by: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' (' + UserInfo.getUserName() + ')'
                        + '<br/>Deleted/Cancelled on: ' + Datetime.now().format('dd/MM/yyyy HH:mm');
    
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
    
                    }
                }
            }

            for(Id i : keyDateIdToBACSInfoMapChange.keyset()) {
                DateTime dt = (DateTime)keyDateIdToBACSInfoMapChange.get(i).get('dateTime');
                System.debug('AHA - Debug - Change email 1');
                DateTime oldDt;
                if(!isInsert) {
                    oldDt = (DateTime)keyDateIdToBACSInfoMapChange.get(i).get('oldDateTime');
                }
                if(!isDelete && keyDateIdToKeyDateInfoMapChange.get(i)!= null) {
                    System.debug('AHA - Debug - Change email 2');
                    if(!(keyDateIdToKeyDateInfoMapChange.get(i).Cancelled__c)){
                        System.debug('AHA - Debug - Inside Change email');
                        String emailSubject = 'A BACS transmission has been changed from today ' + keyDateIdToBACSInfoMapChange.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>A BACS transmission has been moved from today</b></p>'
                        + 'Type: ' + keyDateIdToBACSInfoMapChange.get(i).get('text')
                        + '<br/>Time of planned transmission: ' + dt.format()
                        + '<br/>Time of original transmission: ' + oldDt.format()   
                        + '<br/>Customer: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        emailBody += 'Rescheduled';
                        emailBody += '<br/>Assigned to: ' + keyDateIdToKeyDateInfoMapChange.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Name__c + '</a>'
                        + '<br/>Team: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Responsibility__c
                        + '<br/>Rescheduled by: ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.Username + ')'
                        + '<br/>Rescheduled on: ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedDate.format();
                        //emailBody += isInsert ? 'NEW' : oldDt.format();
    
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
                    }
                }
            }

            for(Id i : keyDateIdToPRINTInfoMapChange.keyset()) {
                DateTime dt = (DateTime)keyDateIdToPRINTInfoMapChange.get(i).get('dateTime');

                DateTime oldDt;
                if(!isInsert) {
                    oldDt = (DateTime)keyDateIdToPRINTInfoMapChange.get(i).get('oldDateTime');
                }
                if(!isDelete && keyDateIdToKeyDateInfoMapChange.get(i)!= null) {
                    if(!isDelete && !keyDateIdToKeyDateInfoMapChange.get(i).Cancelled__c) {
                        String emailSubject = 'A PRINT job has been changed from today ' + keyDateIdToPRINTInfoMapChange.get(i).get('text') + ' for ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Account__r.Name +
                        ', schedule: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Name__c;
                        String emailBody = '<p><b>A PRINT job has been moved from today</b></p>'
                        + 'Type: ' + keyDateIdToPRINTInfoMapChange.get(i).get('text')
                        + '<br/>Time of planned print: ' + dt.format()
                        + '<br/>Time of original print: ' + oldDt.format()    
                        + '<br/>Customer: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Account__r.Name
                        + '<br/>Status: ';
                        emailBody += 'Rescheduled';
                        emailBody += '<br/>Assigned to: ' + keyDateIdToKeyDateInfoMapChange.get(i).Assigned_To__c;
    
                        emailBody += '<p><b>Schedule Information</b></p>'
                        + 'Schedule: <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__c + '\'>' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Name__c + '</a>'
                        + '<br/>Team: ' + keyDateIdToKeyDateInfoMapChange.get(i).Schedule__r.Schedule_Responsibility__c
                        + '<br/>Rescheduled by: ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.FirstName + ' ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.LastName + ' (' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedBy.Username + ')'
                        + '<br/>Rescheduled on: ' + keyDateIdToKeyDateInfoMapChange.get(i).LastModifiedDate.format();
                        //emailBody += isInsert ? 'NEW' : oldDt.format();
    
                        Messaging.SingleEmailMessage mail = OegenHelper.initEmail(emailSubject, emailBody, toAddresses);
                        emailsToSend.add(mail);
                    }
                }
            }

            if(emailsToSend.size() > 0) { 
                try {
                    Messaging.reserveSingleEmailCapacity(emailsToSend.size());
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend, false);
                    for(Messaging.SendEmailResult r : results) {
                        if(!r.isSuccess()) {
                            for(Messaging.SendEmailError e : r.getErrors()) {
                                System.debug('Error while sending a Key Date email: ' + e.getMessage());
                            }
                        }
                    }
                } catch(Exception e) {
                    System.debug('Error while sending Key Date emails: ' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'An error occurred while trying to send Key Date email alerts: ' + e.getMessage()));
                }
            }
        }
    }
}