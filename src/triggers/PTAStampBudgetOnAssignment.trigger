trigger PTAStampBudgetOnAssignment on pse__Project_Task_Assignment__c (after insert, after update) {
    List<pse__Project_Task_Assignment__c> PTAList = new List<pse__Project_Task_Assignment__c>();
    
    for(pse__Project_Task_Assignment__c PTA : Trigger.new){
        PTAList.add(PTA);
    }
    
    system.debug(logginglevel.INFO,  'number in list: ' + PTALIST.SIZE());
    map<Id,Id> AssignmentMap = new map<Id,Id>();
    List<pse__Assignment__c> AssignmentsToUpdate = new List<pse__Assignment__c>();
    
    try { 
        for(pse__Project_Task_Assignment__c PTA1:PTAList){
        //pse__Project_Task_Assignment__c PTA1 = PTAList.get(0) ;
        
            if(AssignmentMap.containsKey(PTA1.pse__Assignment__c)){
            
            } else {
                AssignmentMap.put(PTA1.pse__Assignment__c, PTA1.pse__Assignment__c);
                List<pse__Assignment__c> AssignmentList = [SELECT Budget__c FROM pse__Assignment__c WHERE ID = : PTA1.pse__Assignment__c];
                for(pse__Assignment__c a: AssignmentList){
                    if(a.budget__c != null) continue;
                    a.budget__c = PTA1.Budget__c;
                    AssignmentsToUpdate.add(a);    
                }
            }
        }
        
        if (AssignmentsToUpdate.size() > 0 ){
            update AssignmentsToUpdate;    
        }
        
    } catch(DmlException e) {
        System.debug('An unexpected error has occurred: ' + e.getMessage());
    }
    
}

/*

    Dear Ivor,
    
    Cait made me do it. Not Cinder.
    
    Stuff and things,
    Ashley
    
    trigger PTAStampBudgetOnAssignment on pse__Project_Task_Assignment__c (after insert, after update) {
        List<pse__Project_Task_Assignment__c> PTAList = new List<pse__Project_Task_Assignment__c>();
        for(pse__Project_Task_Assignment__c PTA : Trigger.new){
            PTAList.add(PTA);
        }
        system.debug(logginglevel.INFO,  'number in list: ' + PTALIST.SIZE());
        map<Id,Id> AssignmentMap = new map<Id,Id>();
        List<pse__Assignment__c> AssignmentsToUpdate = new List<pse__Assignment__c>();
        try { 
            for(pse__Project_Task_Assignment__c PTA1:PTAList){
            //pse__Project_Task_Assignment__c PTA1 = PTAList.get(0) ;
            
                if(AssignmentMap.containsKey(PTA1.pse__Assignment__c)){
                } else {
                    AssignmentMap.put(PTA1.pse__Assignment__c, PTA1.pse__Assignment__c);
            List<pse__Assignment__c> AssignmentList = [SELECT Budget__c FROM pse__Assignment__c WHERE ID = : PTA1.pse__Assignment__c];
            for(pse__Assignment__c a: AssignmentList){
                a.budget__c = PTA1.Budget__c;
                AssignmentsToUpdate.add(a);    
            }
                }
            }
            if (AssignmentsToUpdate.size() > 0 ){
                
                update AssignmentsToUpdate;    
            }
        } catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
    }


*/