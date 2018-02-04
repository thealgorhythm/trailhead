trigger MaintenanceRequest on Case (before update, after update) {

    MaintenanceRequestHelper.newCases = trigger.new;
    MaintenanceRequestHelper.oldCases = trigger.old;
    MaintenanceRequestHelper.newCasesMap = trigger.newMap;
    MaintenanceRequestHelper.oldCasesMap = trigger.oldMap;

    // call MaintenanceRequestHelper.updateWorkOrders
    MaintenanceRequestHelper.updateWorkOrders();
}
