trigger RHX_pse_Project_Task_Assignment on pse__Project_Task_Assignment__c
    (after delete, after insert, after undelete, after update, before delete) {
     System.debug('OEGEN DEBUG - TRIGGER ENTERED');
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
   if(rollClass != null) {
    rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
    if (trigger.isAfter) {
      pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'pse__Project_Task_Assignment__c'}, null);
      }
     }
    
    ResourceBookingTriggerHandler rh = new ResourceBookingTriggerHandler();
    if(Trigger.isAfter){
        System.debug('OEGEN DEBUG - AFTER TRIGGER ENTERED');
        if(Trigger.IsUpdate){
            System.debug('OEGEN DEBUG - ISUPDATE TRIGGER ENTERED');
            rh.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } 
        if(Trigger.IsInsert){
            System.debug('OEGEN DEBUG - ISINSERT TRIGGER ENTERED');
            rh.handleAfterInsert(Trigger.new);
        }
    }


}