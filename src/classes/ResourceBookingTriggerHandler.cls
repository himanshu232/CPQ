public class ResourceBookingTriggerHandler {
  public void handleAfterInsert(List<pse__Project_Task_Assignment__c> requests) {
      system.debug('OEGEN DEBUG - ENTERED Insert TRIGGER HANDLER ' + requests);
        Map<Id, Id> PTAtoPTMap = new Map<Id, Id>();
        Map<Id, Id> PTAtoRRMap = new Map<Id, Id>();
        Map<Id, pse__Resource_Request__c> RRMap = new Map<Id, pse__Resource_Request__c>();
        Map<Id, pse__Project_Task__c> PTMap = new Map<Id, pse__Project_Task__c>();
        //Map<Id, Id> projectTaskMap = new Map<Id, Id>();
        List<Id> ProjectTaskList = new List<Id>();
        List<Id> ResourceRequestList = new List<Id>();
        List<pse__Resource_Request__c> ResourceRequestToUpdateList = new List<pse__Resource_Request__c>();
        for(pse__Project_Task_Assignment__c rr : requests){
            PTAtoPTMap.put(rr.pse__Project_Task__c, rr.Id);
            PTAtoRRMap.put(rr.pse__Resource_Request__c, rr.Id);
            ProjectTaskList.add(rr.pse__Project_Task__c);
            ResourceRequestList.add(rr.pse__Resource_Request__c);
        }
        
        List<pse__Project_Task__c> PTList = new List<pse__Project_Task__c>();
        PTList = [SELECT Id, Budget__c FROM pse__Project_Task__c WHERE Id IN :ProjectTaskList];
        for(pse__Project_Task__c pt : PTList){
            PTMap.put(PTAtoPTMap.get(pt.Id), pt);
        }
        List<pse__Resource_Request__c> RRList = new List<pse__Resource_Request__c>();
        RRList = [SELECT Id, Budget__c FROM pse__Resource_Request__c WHERE Id IN :ResourceRequestList];
        for(pse__Resource_Request__c rr : RRList){
            RRMap.put(PTAtoRRMap.get(rr.Id), rr);
        }
        for(pse__Project_Task_Assignment__c rr : requests){
            if(PTMap.get(rr.Id).Budget__c != null && RRMap.get(rr.Id) != null && RRMap.get(rr.Id).Budget__c == null){
                system.debug('OEGEN DEBUG - INSIDE CHECK');
                RRMap.get(rr.Id).Budget__c = PTMap.get(rr.Id).Budget__c;
        ResourceRequestToUpdateList.add(RRMap.get(rr.Id));
            }
        }
        system.debug('OEGEN DEBUG - Insert TRIGGER HANDLER Resource Request ' + rrList);
        if(ResourceRequestToUpdateList.size() > 0){
            update ResourceRequestToUpdateList;
        }
    }

    public void handleAfterUpdate(List<pse__Project_Task_Assignment__c> requests, Map<Id,pse__Project_Task_Assignment__c> requestsOld) {
      system.debug('OEGEN DEBUG - ENTERED UPDATE TRIGGER HANDLER ' + requests);
        Map<Id, Id> PTAtoPTMap = new Map<Id, Id>();
        Map<Id, Id> PTAtoRRMap = new Map<Id, Id>();
        Map<Id, pse__Resource_Request__c> RRMap = new Map<Id, pse__Resource_Request__c>();
        Map<Id, pse__Project_Task__c> PTMap = new Map<Id, pse__Project_Task__c>();
        //Map<Id, Id> projectTaskMap = new Map<Id, Id>();
        List<Id> ProjectTaskList = new List<Id>();
        List<Id> ResourceRequestList = new List<Id>();
        List<pse__Resource_Request__c> ResourceRequestToUpdateList = new List<pse__Resource_Request__c>();
        for(pse__Project_Task_Assignment__c rr : requests){
            PTAtoPTMap.put(rr.pse__Project_Task__c, rr.Id);
            PTAtoRRMap.put(rr.pse__Resource_Request__c, rr.Id);
            ProjectTaskList.add(rr.pse__Project_Task__c);
            ResourceRequestList.add(rr.pse__Resource_Request__c);
        }
        
        List<pse__Project_Task__c> PTList = new List<pse__Project_Task__c>();
        PTList = [SELECT Id, Budget__c FROM pse__Project_Task__c WHERE Id IN :ProjectTaskList];
        for(pse__Project_Task__c pt : PTList){
            PTMap.put(PTAtoPTMap.get(pt.Id), pt);
        }
        List<pse__Resource_Request__c> RRList = new List<pse__Resource_Request__c>();
        RRList = [SELECT Id, Budget__c FROM pse__Resource_Request__c WHERE Id IN :ResourceRequestList];
        for(pse__Resource_Request__c rr : RRList){
            RRMap.put(PTAtoRRMap.get(rr.Id), rr);
        }
        for(pse__Project_Task_Assignment__c rr : requests){
            if(PTMap.get(rr.Id).Budget__c != null && RRMap.get(rr.Id) != null && RRMap.get(rr.Id).Budget__c == null){
                system.debug('OEGEN DEBUG - INSIDE CHECK');
                RRMap.get(rr.Id).Budget__c = PTMap.get(rr.Id).Budget__c;
        ResourceRequestToUpdateList.add(RRMap.get(rr.Id));
            }
        }
        system.debug('OEGEN DEBUG - UPDATE TRIGGER HANDLER Resource Request ' + rrList);
        if(ResourceRequestToUpdateList.size() > 0){
            update ResourceRequestToUpdateList;
        }
    }
}