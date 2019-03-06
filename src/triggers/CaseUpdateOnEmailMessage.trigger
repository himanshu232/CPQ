trigger CaseUpdateOnEmailMessage on EmailMessage (after insert, after update)
{
    Set<Id> setParentId = new Set<Id>();
     for(EmailMessage em: Trigger.new)
     {
         if(em.HasAttachment)
         {
           setParentId.add(em.ParentId);
         }
     }

     List<Case> lstCases = [select Id , HasAttachment__c from Case where Id IN :setParentId];
    
     For(Case c : lstCases)
     {
        c.HasAttachment__c = True;
     }

     update lstCases;
}