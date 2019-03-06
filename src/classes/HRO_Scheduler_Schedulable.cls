global class HRO_Scheduler_Schedulable implements Schedulable {

	public HRO_Scheduler_Schedulable() {}

	public void execute(SchedulableContext sc) {
		HRO_Scheduler_Batch b = new HRO_Scheduler_Batch();
		database.executebatch(b, 1);
	}
}