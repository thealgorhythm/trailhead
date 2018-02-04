@isTest
public class WarehouseSyncSchedule_Test {

    @isTest
    static void testWarehouseSyncSchedule() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String cronExp = '12 34 5 6 7 ?';

        Test.startTest();
        WarehouseSyncSchedule sch = new WarehouseSyncSchedule();
		Id jobId = System.schedule('Test Warehouse Sync Schedule', cronExp, sch);
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name, CronJobDetail.Id, State FROM CronTrigger WHERE Id=:jobId LIMIT 1];
        System.assertEquals('Test Warehouse Sync Schedule', ct.CronJobDetail.Name);
        System.assertEquals('WAITING', ct.State);
        System.assertEquals(cronExp, ct.CronExpression);
    }
}
