public with sharing class BatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        GroupMemberSyncBatch batch = new GroupMemberSyncBatch();
        
        Database.executeBatch(batch, 200); // Batch size of 200
    }
}