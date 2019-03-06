///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // Apex Trigger: ogn_ActivityCheck_Trigger
    // - Related Object: Activity_Checklist__c
    // - Author: AHA 𝝺
    // - Company: Oe:gen Ltd
    // - Created: 13/08/2018
    // - Description: Added to accomodate Notification Merge fields on the request of Robin Price as part of Scheduler Phase 2, Sprint 4
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    //  >> -----   Change Log   ------ <<
    //                 
    // 
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ 
trigger ogn_ActivityCheck_Trigger on Activity_Checklist__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

   ogn_ActivityCheck_Handler handler = new ogn_ActivityCheck_Handler();

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.beforeInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

}