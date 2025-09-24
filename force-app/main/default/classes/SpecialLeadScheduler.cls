global class SpecialLeadScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // choose small batch size like 100 or 200 to control heap
        Database.executeBatch(new SpecialLeadBatch(), 200);
    }
}

/*
String cronExp = '0 0 2 * * ?'; 
System.schedule('Daily SpecialLeadJob', cronExp, new SpecialLeadScheduler());
*/