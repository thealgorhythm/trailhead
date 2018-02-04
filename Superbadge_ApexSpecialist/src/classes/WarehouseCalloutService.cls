public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        warehouseEquipmentCallout();
    }

    public static HTTPResponse warehouseEquipmentCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200){
           	String results = response.getBody();
            List<Object> equipment = (List<Object>) JSON.deserializeUntyped(results);

            List<Product2> equipmentToUpdate = new List<Product2>();
            Boolean replacement;
            Integer quantity, maintenanceperiod, lifespan;
            Decimal cost;
            String name, sku;

            for (Object o: equipment) {

                String equipmentJsonString = JSON.serialize(o);
                Map<String,Object> equipmentJsonMap = (Map<String,Object>) JSON.deserializeUntyped(equipmentJsonString);

                //replacement = Boolean.valueOf(JSON.serialize(equipmentJsonMap.get('replacement')));
                quantity = Integer.valueOf(JSON.serialize(equipmentJsonMap.get('quantity')));
                name = String.valueOf(JSON.deserializeUntyped(JSON.serialize(equipmentJsonMap.get('name'))));
                maintenanceperiod = Integer.valueOf(JSON.serialize(equipmentJsonMap.get('maintenanceperiod')));
                lifespan = Integer.valueOf(JSON.serialize(equipmentJsonMap.get('lifespan')));
                cost = Decimal.valueOf(JSON.serialize(equipmentJsonMap.get('cost')));
                sku = String.valueOf(JSON.deserializeUntyped(JSON.serialize(equipmentJsonMap.get('sku'))));

                Product2 p = new Product2(Replacement_Part__c=true,
                    					  Current_Inventory__c=quantity,
                                          Name=name,
                                          Maintenance_Cycle__c=maintenanceperiod,
                                          Lifespan_Months__c=lifespan,
                                          Cost__c=cost,
                                          Warehouse_SKU__c=sku);

                //if(p.Replacement_Part__c) equipmentToUpdate.add(p);
                equipmentToUpdate.add(p);
            }

            Schema.SObjectField extId = Product2.Fields.Warehouse_SKU__c;
            //upsert equipmentToUpdate;
            Database.UpsertResult[] ur = Database.upsert(equipmentToUpdate, extId, false);
        }
        return response;
    }

}
