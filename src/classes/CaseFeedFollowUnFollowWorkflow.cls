public without sharing class  CaseFeedFollowUnFollowWorkflow{
    Map<Id, Case> newMap;
    Map<Id, Case> oldMap;
    List<Case> newList;
    Boolean isInsert;
    Boolean isUpdate;
    List<Case> qualifiedCases = new List<Case>();
    
    public CaseFeedFollowUnFollowWorkflow(Map<Id, Case> newMap, Map<Id, Case> oldMap, List<Case> newList, Boolean isInsert, Boolean isUpdate){
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.newList = newList;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        execute();
    }
    
    public void execute(){
        List<EntitySubscription> followList = new List<EntitySubscription>();
        List<EntitySubscription> unFollowList = new List<EntitySubscription>();
        Map<Id, Id> mapOfCaseIdToUnSubscriberId = new Map<Id, Id>();
        for(Case c : isInsert ? newList : newMap.values()){
            if((isInsert || (isUpdate && newMap.get(c.Id).OwnerId != oldMap.get(c.Id).OwnerId)) && String.valueOf(c.OwnerId).startsWith('005')){
                qualifiedCases.add(c);
                if(isUpdate){
                    mapOfCaseIdToUnSubscriberId.put(c.Id, oldMap.get(c.Id).OwnerId);
                }
            }
        }
        
        for(Case c : qualifiedCases){
            if(!followingUserIds.contains(newMap.get(c.Id).OwnerId)){
                EntitySubscription followEnt = new EntitySubscription(ParentId = c.Id, SubscriberId = newMap.get(c.Id).OwnerId);
                followEnt.NetworkId = Network.getNetworkId();

                followList.add(followEnt);
            }
        }
        
        if(!mapOfCaseIdToUnSubscriberId.isEmpty()){
            for(EntitySubscription ent : [Select Id, ParentId, SubscriberId, Subscriber.ContactId FROM EntitySubscription WHERE ParentID IN :mapOfCaseIdToUnSubscriberId.keySet()]){
                if(mapOfCaseIdToUnSubscriberId.containsKey(ent.ParentId) && mapOfCaseIdToUnSubscriberId.get(ent.ParentId) == ent.SubscriberId && 
                    (ent.Subscriber.ContactId == NULL || (ent.Subscriber.ContactId != NULL && newMap.get(ent.ParentId).ContactId != ent.Subscriber.ContactId))){
                    unFollowList.add(ent);
                }
            }
        }
        
        if(!followList.isEmpty()){
            insert followList;
        }
        
        if(!unFollowList.isEmpty()){
            delete unFollowList;
        }
    }
    
    public Set<Id> followingUserIds {
        get {
            if(followingUserIds == null) {
                followingUserIds = new Set<Id>();
                for(EntitySubscription ent: [SELECT Id, SubscriberId FROM EntitySubscription WHERE ParentId IN :qualifiedCases]) {
                    followingUserIds.add(ent.SubscriberId);
                }
            }
            return followingUserIds;
        }
        private set;
    }
}