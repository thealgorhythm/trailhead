public class WarehouseSyncSchedule implements Schedulable{
  // implement scheduled code here
  // System.schedule('Warehouse Sync Schedule', '0 0 1 * * ?', new WarehouseSyncSchedule());
  public static string DEFAULT_CRON_EXP = '* * 1 * * ?';

  public void execute(SchedulableContext sc){
      WarehouseCalloutService.runWarehouseEquipmentSync();
  }
}
