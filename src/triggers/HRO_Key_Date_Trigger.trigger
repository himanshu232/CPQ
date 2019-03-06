trigger HRO_Key_Date_Trigger on Key_Dates__c (after insert, after update, before delete) {

    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            HRO_Key_Date_Trigger_Handler.handleBeforeDelete(Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if(Trigger.isInsert) {
            HRO_Key_Date_Trigger_Handler.handleAfterInsert(Trigger.newMap);
        } else if(Trigger.isUpdate) {
            HRO_Key_Date_Trigger_Handler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

}