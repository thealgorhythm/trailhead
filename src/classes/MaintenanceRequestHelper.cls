public class MaintenanceRequestHelper {

    public static List<Case> newCases;
    public static List<Case> oldCases;
    public static Map<Id,Case> newCasesMap;
    public static Map<Id,Case> oldCasesMap;

    public static List<Case> closedCases;

    public static void updateWorkOrders(){
        // update workorders
        closedCases = [SELECT Id, Subject, ContactId, AccountId, Vehicle__c, Equipment__c, (SELECT Id, Equipment__r.Maintenance_Cycle__c FROM Work_Parts__r ORDER BY Equipment__r.Maintenance_Cycle__c ASC) FROM Case WHERE Id in :newCases AND Status='Closed' AND (Type='Repair' OR Type='Routine Maintenance')];
        List<Case> casesToInsert = new List<Case>();

        for(Case c: closedCases){
            Date dueDate = c.Work_Parts__r.isEmpty() ? System.today().addDays(365) : System.today().addDays(c.Work_Parts__r[0].Equipment__r.Maintenance_Cycle__c.intValue());

            Case newCase = new Case(Type='Routine Maintenance',
                                    Vehicle__c=c.Vehicle__c,
                                    Equipment__c=c.Equipment__c,
                                    ContactId=c.ContactId,
                                    AccountId=c.AccountId,
                                    Subject=c.Subject+' Routine Maintenance',
                                    Date_Reported__c=System.today(),
                                    Date_Due__c=dueDate);
        	casesToInsert.add(newcase);
        }
        insert casesToInsert;
    }

}
