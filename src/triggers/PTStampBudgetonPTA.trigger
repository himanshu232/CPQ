trigger PTStampBudgetonPTA on pse__Project_Task__c (after update) {
    List<pse__Project_Task__c> PTList = new List<pse__Project_Task__c>();
    
        for(pse__Project_Task__c PT : Trigger.new){
            if (Trigger.isUpdate) {
                pse__Project_Task__c BeforeUpdate = Trigger.oldMap.get(PT.ID);
            /**    if (PT.pse__Actual_Hours__c != BeforeUpdate.pse__Actual_Hours__c || PT.Budget__c != BeforeUpdate.Budget__c) { **/
                if (PT.Budget__c != null){
                    PTList.add(PT);
                }
                /**}**/
            } else {
            
                if (PT.Budget__c != null){
                    PTList.add(PT);
                }
            }
        }
        
        
        
        List<pse__Project_Task_Assignment__c> PTAsToUpdate = new List<pse__Project_Task_Assignment__c>();
        try { 
            
            List<String> PTIDs = New List<String>();
            for(pse__Project_Task__c PT : PTList) {
                PTIDs.add(PT.ID);
            }
            
            List<pse__Project_Task_Assignment__c> PTAList = [SELECT Budget__c, pse__Project_Task__r.Budget__c FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c in : PTIDs];
            
            for(pse__Project_Task_Assignment__c PTA:PTAList) {
                if(PTA.Budget__c == PTA.pse__Project_Task__r.Budget__c) continue;
            
                PTA.Budget__c = PTA.pse__Project_Task__r.Budget__c;
                //We utilise the Master-Detail relationship here instead of looping through PT's.
                PTAsToUpdate.add(PTA);
            }
             
            //for(pse__Project_Task__c PT : PTList){
                //List<pse__Project_Task_Assignment__c> PTAList = [SELECT Budget__c FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c = : PT.ID];
                //We are moving this select out of the above for loop, so it will only run once - see me for details.
                
                //for(pse__Project_Task_Assignment__c PTA:PTAList) {
                //    PTA.Budget__c = PT.Budget__c;
                //    PTAsToUpdate.add(PTA);
                //}
                //Therefore we can move this for-loop under our new list of PTA's.
            //}
                
            if (PTAsToUpdate.size() > 0 ){
                update PTAsToUpdate;    
            }
            
        } catch(DmlException e) {
        
        System.debug('An unexpected error has occurred: ' + e.getMessage());
    }
    
    String ptIDs = '';
    for(pse__Project_Task__c pt : Trigger.new) {
        ptIDs = pt.ID + ', ';
    }
    system.debug(' --- Leaving PTStampBudgetonPTA - we ran for ' + ptIDs + ' and currently are at the SOQL count of ' + Limits.getQueries());
}

/*

    Dear Ivor, below is your code. I am sorry it came to this. Cinder made me do it.
    
    On a serious note, blame Cait. Come over and see me if you're interested in what we did.
    
    Kind regards,
    Ashley
    
    trigger PTStampBudgetonPTA on pse__Project_Task__c (after update) {
        List<pse__Project_Task__c> PTList = new List<pse__Project_Task__c>();
        
            for(pse__Project_Task__c PT : Trigger.new){
                if (Trigger.isUpdate) {
                    pse__Project_Task__c BeforeUpdate = Trigger.oldMap.get(PT.ID);
                <!-- COMMENT ME OUT    if (PT.pse__Actual_Hours__c != BeforeUpdate.pse__Actual_Hours__c || PT.Budget__c != BeforeUpdate.Budget__c) { COMMENT ME OUT -->
                    if (PT.Budget__c != null){
                        PTList.add(PT);
                    }
                    <!-- COMMENT ME OUT    }COMMENT ME OUT -->
                } else {
                
                    if (PT.Budget__c != null){
                        PTList.add(PT);
                    }
                }
            }
            
            
            
            List<pse__Project_Task_Assignment__c> PTAsToUpdate = new List<pse__Project_Task_Assignment__c>();
            try { 
                for(pse__Project_Task__c PT : PTList){
                    List<pse__Project_Task_Assignment__c> PTAList = [SELECT Budget__c FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c = : PT.ID];
                    
                    for(pse__Project_Task_Assignment__c PTA:PTAList) {
                        PTA.Budget__c = PT.Budget__c;
                        PTAsToUpdate.add(PTA);
                    }
                }
                    
                if (PTAsToUpdate.size() > 0 ){
                    update PTAsToUpdate;    
                }
            } catch(DmlException e) {
            
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }



*/