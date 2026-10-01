public class VehicleOrderTriggerHandler {

    public static void handleTrigger(
        List<Vehicle_Order__c> newOrders,
        Map<Id, Vehicle_Order__c> oldOrders,
        Boolean isBefore,
        Boolean isAfter,
        Boolean isInsert,
        Boolean isUpdate
    ) {

        // =====================================================
        // BEFORE INSERT / BEFORE UPDATE
        // Check vehicle stock before allowing the order
        // =====================================================

        if (isBefore) {

            if (isInsert || isUpdate) {

                preventOrderIfOutOfStock(newOrders);
            }
        }


        // =====================================================
        // AFTER INSERT / AFTER UPDATE
        // Reduce vehicle stock when order becomes Confirmed
        // =====================================================

        if (isAfter) {

            if (isInsert || isUpdate) {

                updateStockOnOrderPlacement(
                    newOrders,
                    oldOrders
                );
            }
        }
    }


    // =========================================================
    // Prevent orders when vehicle is out of stock
    // =========================================================

    private static void preventOrderIfOutOfStock(
        List<Vehicle_Order__c> orders
    ) {

        Set<Id> vehicleIds = new Set<Id>();


        // Collect Vehicle IDs
        for (Vehicle_Order__c order : orders) {

            if (order.Vehicle__c != null) {

                vehicleIds.add(order.Vehicle__c);
            }
        }


        if (!vehicleIds.isEmpty()) {

            Map<Id, Vehicle__c> vehicleStockMap =
                new Map<Id, Vehicle__c>();


            // Get vehicle stock
            for (Vehicle__c vehicle : [
                SELECT Id, Stock_Quantity__c
                FROM Vehicle__c
                WHERE Id IN :vehicleIds
            ]) {

                vehicleStockMap.put(
                    vehicle.Id,
                    vehicle
                );
            }


            // Check stock
            for (Vehicle_Order__c order : orders) {

                if (
                    order.Vehicle__c != null &&
                    vehicleStockMap.containsKey(order.Vehicle__c)
                ) {

                    Vehicle__c vehicle =
                        vehicleStockMap.get(order.Vehicle__c);


                    if (
                        vehicle.Stock_Quantity__c == null ||
                        vehicle.Stock_Quantity__c <= 0
                    ) {

                        order.addError(
                            'This vehicle is out of stock. Order cannot be placed.'
                        );
                    }
                }
            }
        }
    }


    // =========================================================
    // Update vehicle stock when order becomes Confirmed
    // =========================================================

    private static void updateStockOnOrderPlacement(
        List<Vehicle_Order__c> orders,
        Map<Id, Vehicle_Order__c> oldOrders
    ) {

        Set<Id> vehicleIds = new Set<Id>();


        // -----------------------------------------------------
        // Find orders that have JUST become Confirmed
        // -----------------------------------------------------

        for (Vehicle_Order__c order : orders) {

            Boolean becameConfirmed = false;


            // INSERT
            if (
                oldOrders == null ||
                !oldOrders.containsKey(order.Id)
            ) {

                if (order.Status__c == 'Confirmed') {

                    becameConfirmed = true;
                }
            }


            // UPDATE
            else {

                Vehicle_Order__c oldOrder =
                    oldOrders.get(order.Id);


                if (
                    order.Status__c == 'Confirmed' &&
                    oldOrder.Status__c != 'Confirmed'
                ) {

                    becameConfirmed = true;
                }
            }


            // Collect Vehicle ID
            if (
                becameConfirmed &&
                order.Vehicle__c != null
            ) {

                vehicleIds.add(order.Vehicle__c);
            }
        }


        // -----------------------------------------------------
        // Get vehicles
        // -----------------------------------------------------

        if (!vehicleIds.isEmpty()) {

            Map<Id, Vehicle__c> vehicleStockMap =
                new Map<Id, Vehicle__c>();


            for (Vehicle__c vehicle : [
                SELECT Id, Stock_Quantity__c
                FROM Vehicle__c
                WHERE Id IN :vehicleIds
            ]) {

                vehicleStockMap.put(
                    vehicle.Id,
                    vehicle
                );
            }


            // -------------------------------------------------
            // IMPORTANT:
            // Use Map instead of List.
            // This prevents Duplicate ID errors.
            // -------------------------------------------------

            Map<Id, Vehicle__c> vehiclesToUpdate =
                new Map<Id, Vehicle__c>();


            // -------------------------------------------------
            // Reduce stock
            // -------------------------------------------------

            for (Vehicle_Order__c order : orders) {

                Boolean becameConfirmed = false;


                // INSERT
                if (
                    oldOrders == null ||
                    !oldOrders.containsKey(order.Id)
                ) {

                    if (order.Status__c == 'Confirmed') {

                        becameConfirmed = true;
                    }
                }


                // UPDATE
                else {

                    Vehicle_Order__c oldOrder =
                        oldOrders.get(order.Id);


                    if (
                        order.Status__c == 'Confirmed' &&
                        oldOrder.Status__c != 'Confirmed'
                    ) {

                        becameConfirmed = true;
                    }
                }


                // Update vehicle stock
                if (
                    becameConfirmed &&
                    order.Vehicle__c != null &&
                    vehicleStockMap.containsKey(order.Vehicle__c)
                ) {

                    Vehicle__c vehicle =
                        vehicleStockMap.get(order.Vehicle__c);


                    if (
                        vehicle.Stock_Quantity__c != null &&
                        vehicle.Stock_Quantity__c > 0
                    ) {

                        vehicle.Stock_Quantity__c -= 1;


                        // Store using Vehicle ID.
                        // Duplicate IDs are prevented.
                        vehiclesToUpdate.put(
                            vehicle.Id,
                            vehicle
                        );
                    }
                }
            }


            // -------------------------------------------------
            // Update vehicles
            // -------------------------------------------------

            if (!vehiclesToUpdate.isEmpty()) {

                update vehiclesToUpdate.values();
            }
        }
    }
}