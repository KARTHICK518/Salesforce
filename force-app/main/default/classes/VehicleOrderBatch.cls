global class VehicleOrderBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Status__c, Vehicle__c
            FROM Vehicle_Order__c
            WHERE Status__c = 'Pending'
        ]);
    }

    global void execute(
        Database.BatchableContext bc,
        List<Vehicle_Order__c> orderList
    ) {

        Set<Id> vehicleIds = new Set<Id>();

        // Collect Vehicle IDs
        for (Vehicle_Order__c order : orderList) {
            if (order.Vehicle__c != null) {
                vehicleIds.add(order.Vehicle__c);
            }
        }

        if (vehicleIds.isEmpty()) {
            return;
        }

        // Get Vehicles
        Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
            [
                SELECT Id, Stock_Quantity__c
                FROM Vehicle__c
                WHERE Id IN :vehicleIds
            ]
        );

        // Maps prevent duplicate IDs
        Map<Id, Vehicle_Order__c> ordersToUpdate =
            new Map<Id, Vehicle_Order__c>();

        Map<Id, Vehicle__c> vehiclesToUpdate =
            new Map<Id, Vehicle__c>();

        // Process orders
        for (Vehicle_Order__c order : orderList) {

            if (order.Vehicle__c == null) {
                continue;
            }

            if (!vehicleMap.containsKey(order.Vehicle__c)) {
                continue;
            }

            Vehicle__c vehicle = vehicleMap.get(order.Vehicle__c);

            if (vehicle.Stock_Quantity__c != null &&
                vehicle.Stock_Quantity__c > 0) {

                order.Status__c = 'Confirmed';

                vehicle.Stock_Quantity__c =
                    vehicle.Stock_Quantity__c - 1;

                ordersToUpdate.put(order.Id, order);
                vehiclesToUpdate.put(vehicle.Id, vehicle);
            }
        }

        // Update Orders
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate.values();
        }

        // Update Vehicles
        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate.values();
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug('Vehicle order batch job completed.');
    }
}