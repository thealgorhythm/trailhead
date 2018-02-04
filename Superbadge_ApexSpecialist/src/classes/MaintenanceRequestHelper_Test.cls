@isTest
public class MaintenanceRequestHelper_Test {

    @testSetup
    static void init(){
        Account account = new Account(Name='Test Account', Type='Customer - Direct');
        insert account;
        Contact contact = new Contact(FirstName='Test', LastName='Contact', Account=account);
        insert contact;
        Vehicle__c vehicle = new Vehicle__c(Name='Test Vehicle', Make__c='Test Make', Model__c='Test Model');
        insert vehicle;
        Product2 equipment1 = new Product2(Name='Test Equipment 1', Maintenance_Cycle__c=100, Cost__c=123.00, Replacement_Part__c=true);
        insert equipment1;
        Product2 equipment2 = new Product2(Name='Test Equipment 2', Maintenance_Cycle__c=50, Cost__c=75.00, Replacement_Part__c=true);
        insert equipment2;
        Case repairMR = new Case(Subject='Test Repair', Type='Repair', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert repairMR;
        Case routineMR = new Case(Subject='Test Routine', Type='Routine Maintenance', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert routineMR;
        Case mechanicalMR = new Case(Subject='Test Mechanical', Type='Mechanical', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert mechanicalMR;
        Case electricalMR = new Case(Subject='Test Electrical', Type='Electrical', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert electricalMR;
        Case electronicMR = new Case(Subject='Test Electronic', Type='Electronic', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert electronicMR;
        Case structuralMR = new Case(Subject='Test Structural', Type='Structural', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert structuralMR;
        Case otherMR = new Case(Subject='Test Other', Type='Other', Equipment__c=equipment1.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
        insert otherMR;
        Work_Part__c wp1 = new Work_Part__c(Quantity__c=1, Equipment__c=equipment1.Id, Maintenance_Request__c=repairMR.Id);
        insert wp1;
        Work_Part__c wp2 = new Work_Part__c(Quantity__c=2, Equipment__c=equipment2.Id, Maintenance_Request__c=repairMR.Id);
        insert wp2;
        Work_Part__c wp3 = new Work_Part__c(Quantity__c=3, Equipment__c=equipment1.Id, Maintenance_Request__c=routineMR.Id);
        insert wp3;
        Work_Part__c wp4 = new Work_Part__c(Quantity__c=4, Equipment__c=equipment2.Id, Maintenance_Request__c=routineMR.Id);
        insert wp4;
    }

    //Positive cases
    @isTest
    static void test_shortestMaintenanceCycleAssigned(){
        Test.startTest();
        Case routineMR = [SELECT Id FROM Case WHERE Type='Routine Maintenance' LIMIT 1];
        routineMR.Status = 'Closed';
        Database.update(routineMR);
        Case oldMR = [SELECT Id, (SELECT Id, Equipment__r.Maintenance_Cycle__c FROM Work_Parts__r ORDER BY Equipment__r.Maintenance_Cycle__c ASC)  FROM Case WHERE Type='Routine Maintenance' AND Status='Closed' LIMIT 1];
        Case newMR = [SELECT Id, Date_Due__c FROM Case WHERE Type='Routine Maintenance' AND Status='New' AND Subject LIKE '%Routine Maintenance' LIMIT 1];
        Test.stopTest();
        System.assertNotEquals(null, newMR);
        System.assertEquals(System.today().addDays(oldMR.Work_Parts__r[0].Equipment__r.Maintenance_Cycle__c.intValue()), newMR.Date_Due__c);
    }

	@isTest
    static void test_closeRepairMaintenanceRequest(){
        Test.startTest();
        Case repairMR = [SELECT Id FROM Case WHERE Type='Repair' LIMIT 1];
        repairMR.Status = 'Closed';
        Database.update(repairMR);
        Case oldMR = [SELECT Id, Vehicle__c, Equipment__c FROM Case WHERE Type='Repair' AND Status='Closed' LIMIT 1];
        Case newMR = [SELECT Id, Vehicle__c, Equipment__c FROM Case WHERE Type='Routine Maintenance' AND Status='New' AND Subject LIKE '%Routine Maintenance' LIMIT 1];
        Test.stopTest();
        System.assertNotEquals(null, newMR);
        System.assertNotEquals(oldMR.Id, newMR.Id);
        System.assertEquals(oldMR.Vehicle__c, newMR.Vehicle__c);
        System.assertEquals(oldMR.Equipment__c, newMR.Equipment__c);
    }

    @isTest
    static void test_closeRoutineMaintenanceRequest(){
        Test.startTest();
        Case routineMR = [SELECT Id FROM Case WHERE Type='Routine Maintenance' LIMIT 1];
        routineMR.Status = 'Closed';
        Database.update(routineMR);
        Case oldMR = [SELECT Id, Vehicle__c, Equipment__c FROM Case WHERE Type='Routine Maintenance' AND Status='Closed' LIMIT 1];
        Case newMR = [SELECT Id, Vehicle__c, Equipment__c FROM Case WHERE Type='Routine Maintenance' AND Status='New' AND Subject LIKE '%Routine Maintenance' LIMIT 1];
        Test.stopTest();
        System.assertNotEquals(null, newMR);
        System.assertNotEquals(oldMR.Id, newMR.Id);
        System.assertEquals(oldMR.Vehicle__c, newMR.Vehicle__c);
        System.assertEquals(oldMR.Equipment__c, newMR.Equipment__c);
    }

    @isTest
    static void test_bulkTriggerUpdate(){
        Test.startTest();
        Account account = new Account(Name='Bulk Test Account', Type='Customer - Direct');
        insert account;
        Contact contact = new Contact(FirstName='Bulk Test', LastName='Contact', Account=account);
        insert contact;
        Vehicle__c vehicle = new Vehicle__c(Name='Bulk Test Vehicle', Make__c='Test Make', Model__c='Test Model');
        insert vehicle;
        Product2 equipment = new Product2(Name='Bulk Test Equipment', Maintenance_Cycle__c=100, Cost__c=123.00, Replacement_Part__c=true);
        insert equipment;

        List<Case> requestsToInsert = new List<Case>();
        List<Case> requestsToUpdate = new List<Case>();

        for(Integer i=0;i<300;i++){
            Case mr = new Case(Subject='Bulk Test Repair '+i, Type='Repair', Equipment__c=equipment.Id, Origin='Email', Contact=contact, Account=account, Vehicle__c=vehicle.Id);
            requestsToInsert.add(mr);
        }
        System.assertEquals(300,requestsToInsert.size());
        Insert requestsToInsert;

        List<Case> requestsToClose = [SELECT Id FROM Case WHERE Type='Repair' AND Subject LIKE 'Bulk%'];
        System.assertEquals(300, requestsToClose.size());
        for(Case c: requestsToClose){
            c.Status = 'Closed';
            requestsToUpdate.add(c);
        }
        System.assertEquals(300, requestsToUpdate.size());
        Update requestsToUpdate;

        List<Case> generatedRequests = [SELECT Id FROM Case WHERE Type='Routine Maintenance' AND Status='New' AND Subject LIKE '%Routine Maintenance'];
        Test.stopTest();

        System.assertEquals(300, generatedRequests.size());
    }

    //Negative cases
    @isTest
    static void test_closeMechanicalMaintenanceRequest(){
        Test.startTest();
        Case mechanicalMR = [SELECT Id FROM Case WHERE Type='Mechanical' LIMIT 1];
        mechanicalMR.Status = 'Closed';
        Database.update(mechanicalMR);
        List<Case> routineMRs = [SELECT Id, Subject FROM Case WHERE Type='Routine Maintenance'];
        Test.stopTest();
        System.assertEquals(1, routineMRs.size());
        System.assert(!routineMRs[0].Subject.contains('Routine Maintenance'));
    }

    @isTest
    static void test_closeElectricalMaintenanceRequest(){
        Test.startTest();
        Case electricalMR = [SELECT Id FROM Case WHERE Type='Electrical' LIMIT 1];
        electricalMR.Status = 'Closed';
        Database.update(electricalMR);
        List<Case> routineMRs = [SELECT Id, Subject FROM Case WHERE Type='Routine Maintenance'];
        Test.stopTest();
        System.assertEquals(1, routineMRs.size());
        System.assert(!routineMRs[0].Subject.contains('Routine Maintenance'));
    }

    @isTest
    static void test_closeElectronicMaintenanceRequest(){
        Test.startTest();
        Case electronicMR = [SELECT Id FROM Case WHERE Type='Electronic' LIMIT 1];
        electronicMR.Status = 'Closed';
        Database.update(electronicMR);
        List<Case> routineMRs = [SELECT Id, Subject FROM Case WHERE Type='Routine Maintenance'];
        Test.stopTest();
        System.assertEquals(1, routineMRs.size());
        System.assert(!routineMRs[0].Subject.contains('Routine Maintenance'));
    }

    @isTest
    static void test_closeStructuralMaintenanceRequest(){
        Test.startTest();
        Case structuralMR = [SELECT Id FROM Case WHERE Type='Structural' LIMIT 1];
        structuralMR.Status = 'Closed';
        Database.update(structuralMR);
        List<Case> routineMRs = [SELECT Id, Subject FROM Case WHERE Type='Routine Maintenance'];
        Test.stopTest();
        System.assertEquals(1, routineMRs.size());
        System.assert(!routineMRs[0].Subject.contains('Routine Maintenance'));
    }

    @isTest
    static void test_closeOtherMaintenanceRequest(){
        Test.startTest();
        Case otherMR = [SELECT Id FROM Case WHERE Type='Other' LIMIT 1];
        otherMR.Status = 'Closed';
        Database.update(otherMR);
        List<Case> routineMRs = [SELECT Id, Subject FROM Case WHERE Type='Routine Maintenance'];
        Test.stopTest();
        System.assertEquals(1, routineMRs.size());
        System.assert(!routineMRs[0].Subject.contains('Routine Maintenance'));
    }
}
