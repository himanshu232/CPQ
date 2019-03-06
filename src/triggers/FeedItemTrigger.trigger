trigger FeedItemTrigger on FeedItem (after insert) {
    FeedItemEmailWorkflow f = new FeedItemEmailWorkflow(trigger.new);
}