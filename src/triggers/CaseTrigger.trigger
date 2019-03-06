trigger CaseTrigger on Case (after insert, after update) {
    CaseFeedFollowUnFollowWorkflow cf = new CaseFeedFollowUnFollowWorkflow(trigger.newMap, trigger.oldMap, trigger.new, Trigger.isInsert, Trigger.isUpdate);
}