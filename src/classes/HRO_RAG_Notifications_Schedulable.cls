global class HRO_RAG_Notifications_Schedulable implements Schedulable {
	///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    // TestClass: Test_HRO_RAG_Notifications.cls
    // By Mark Ramsell 2017.06
    ///////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
	
	public void execute(SchedulableContext sc) {
		HRO_RAG_Notifications_Batch b = new HRO_RAG_Notifications_Batch();
        database.executebatch(b);
        
	}
	
}