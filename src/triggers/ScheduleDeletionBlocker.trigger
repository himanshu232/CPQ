trigger ScheduleDeletionBlocker on pse__Schedule__c (before delete) {
    for (pse__Schedule__c s:Trigger.old)
    {
       if(!s.Allow_Deletion__c)
        {
    s.addError('FF Support Diagnostic Message:Schedule Deletion not allowed unless Allow Deletion checkbox ticked');
                }
    }
}