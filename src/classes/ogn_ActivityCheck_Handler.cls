///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Trigger Handler: ogn_ActivityCheck_Handler
    // - Related Trigger: ogn_ActivityCheck_Trigger
    // - Author: AHA 𝝺
    // - Company: Oe:gen Ltd
    // - Created: 13/08/2018
    // - Description:
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 

public class ogn_ActivityCheck_Handler{

    public ogn_ActivityCheck_Handler() {

    }

    public void beforeInsert(List<Activity_Checklist__c> newRecord){
        notificationMerge(newRecord);
    }
    
    public void beforeUpdate(List<Activity_Checklist__c > newRecord , Map<Id, Activity_Checklist__c > oldRecordMap ){
        List<Activity_Checklist__c> cleared = new List<Activity_Checklist__c>();
        for(Activity_Checklist__c ac : newRecord){
            if(ac.Notification_Message__c != oldRecordMap.get(ac.Id).Notification_Message__c){
                cleared.add(ac);
            }
        } 
        if(cleared.size() > 0){
            notificationMerge(cleared);
        }
    }

    public void afterUpdate(List<Activity_Checklist__c > newRecord , Map<Id, Activity_Checklist__c > oldRecordMap ){
        Map<String,Activity_Checklist__c> toComplete = new Map<String,Activity_Checklist__c>();
        Map<String,Activity_Checklist__c> toUncomplete = new Map<String,Activity_Checklist__c>();
        List<Key_Dates__c> keyDates = new List<Key_Dates__c>();
        List<Key_Dates__c> keyDatesToUpdate = new List<Key_Dates__c>();

        for(Activity_Checklist__c ac : newRecord){
            if(ac.Completed__c == true && oldRecordMap.get(ac.Id).Completed__c != true){
                toComplete.put(ac.Id,ac);
            }
            if(ac.Completed__c == false && oldRecordMap.get(ac.Id).Completed__c != false){
                toUncomplete.put(ac.Id,ac);
            }
        }

        keyDates = [SELECT Id, Completed_1__c, Completed_2__c, Completed_3__c, Activity_Check__c, Automate_Date_Time_1__c, Automate_Date_Time_2__c, Automate_Date_Time_3__c FROM Key_Dates__c WHERE (Activity_Check__c IN :toComplete.keyset() OR Activity_Check__c IN :toUncomplete.keyset()) AND Cancelled__c = FALSE];

        for(Key_Dates__c kd : keyDates){
            if(toComplete.keyset().contains(kd.Activity_Check__c)){
                if(kd.Automate_Date_Time_1__c == true){
                	kd.Completed_1__c = true;
                }
                if(kd.Automate_Date_Time_2__c == true){
                	kd.Completed_2__c = true;
                }
                if(kd.Automate_Date_Time_3__c == true){
                    kd.Completed_3__c = true;
                }
                keyDatesToUpdate.add(kd);
            }
            if(toUncomplete.keyset().contains(kd.Activity_Check__c)){
                if(kd.Automate_Date_Time_1__c == true){
                	kd.Completed_1__c = false;
                }
                if(kd.Automate_Date_Time_2__c == true){
                    kd.Completed_2__c = false;
                }
                if(kd.Automate_Date_Time_3__c == true){
                    kd.Completed_3__c = false;
                }
                keyDatesToUpdate.add(kd);
            }
        }
        if(keyDatesToUpdate.size() > 0){
            update keyDatesToUpdate;
        }
    }

    public void notificationMerge (List<Activity_Checklist__c> newRecord){
        List<Notification_Merge_Fields__mdt> mergeFields = new List<Notification_Merge_Fields__mdt>();
        Map<String,String> mergeMap = new Map<String,String>();

        // Retrieve all custom metadata related to merge fields
        mergeFields = [SELECT Id, API_Field_Name__c, Keyword__c FROM Notification_Merge_Fields__mdt];

        
        if(mergeFields.size() > 0){

            //For each Activity check replace keywords in the notification message field with their linked record field.
            for(Activity_Checklist__c ac : newRecord){
                if(ac.Notification_Message__c != null){
                	ac.Notification_Merge__c = ac.Notification_Message__c;
                	for(Notification_Merge_Fields__mdt mf : mergeFields){ 
                        if(ac.Notification_Merge__c.contains(mf.Keyword__c)){
                            ac.Notification_Merge__c = ac.Notification_Merge__c.replaceAll(mf.Keyword__c, String.valueof(ac.get(mf.API_Field_Name__c))); 
                        }
                    }
                }
            }
        }
    } 
}