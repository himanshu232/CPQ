trigger bg_Case_au on Case bulk (after update) {
    LIST<Id> caseIdList = new LIST<Id>();    
    for (Case updatedCase : trigger.new) {        
        // if the owner has changed to a user       
        if (updatedCase.OwnerId != trigger.oldMap.get(updatedCase.Id).OwnerId) {            
            // add it into a list for later
            caseIdList.add(updatedCase.Id);
        }
    }    
    bg_Case_Helper.SetDepartmentAndTeamForCase(caseIdList);
}