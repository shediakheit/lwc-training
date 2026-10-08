public with sharing class Exercise5 {

    /**
     * Rule 5: Validation to prevent total paid from exceeding the Opportunity's amount.
     * Rewritten to bypass relationship-name dependencies and support multi-record bulk scaling.
     */
    public static void validateAndProcessPayments(Map<Id, Payment__c> oldMap, List<Payment__c> newPayments) {
        Set<Id> oppIds = new Set<Id>();
        
        // Step 1: Gather all involved Opportunity IDs
        for (Payment__c newPay : newPayments) {
            if (newPay.Opportunity__c != null) {
                oppIds.add(newPay.Opportunity__c);
            }
            if (oldMap != null && oldMap.containsKey(newPay.Id)) {
                Id oldOppId = oldMap.get(newPay.Id).Opportunity__c;
                if (oldOppId != null) {
                    oppIds.add(oldOppId);
                }
            }
        }

        if (oppIds.isEmpty()) return;

        // Step 2: Fetch the standard Amount from target Opportunities
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Amount FROM Opportunity WHERE Id IN :oppIds
        ]);

        // Step 3: Direct flat query to get current baseline Paid totals from DB (avoids relationship names)
        Map<Id, Decimal> oppBaseTotalPaid = new Map<Id, Decimal>();
        for (Payment__c existingPay : [SELECT Id, Amount__c, Opportunity__c FROM Payment__c WHERE Opportunity__c IN :oppIds AND Status__c = 'Paid']) {
            Id oppId = existingPay.Opportunity__c;
            if (!oppBaseTotalPaid.containsKey(oppId)) {
                oppBaseTotalPaid.put(oppId, 0.0);
            }
            oppBaseTotalPaid.put(oppId, oppBaseTotalPaid.get(oppId) + (existingPay.Amount__c != null ? existingPay.Amount__c : 0.0));
        }

        // Track sequential calculation changes across bulk-loaded records in the same transaction
        Map<Id, Decimal> runningTotals = new Map<Id, Decimal>();

        // Step 4: Evaluate boundaries
        for (Payment__c newPay : newPayments) {
            if (newPay.Opportunity__c == null) continue;
            
            Id oppId = newPay.Opportunity__c;
            Opportunity opp = oppMap.get(oppId);
            Decimal maxLimit = (opp != null && opp.Amount != null) ? opp.Amount : 0.0;

            // Initialize running context if it's the first time seeing this Opportunity in the loop
            if (!runningTotals.containsKey(oppId)) {
                Decimal base = oppBaseTotalPaid.containsKey(oppId) ? oppBaseTotalPaid.get(oppId) : 0.0;
                
                // If it's an update, subtract the old payment amount from the baseline so we don't double count it
                if (oldMap != null && oldMap.containsKey(newPay.Id)) {
                    Payment__c oldPay = oldMap.get(newPay.Id);
                    if (oldPay.Status__c == 'Paid' && oldPay.Opportunity__c == oppId) {
                        base -= (oldPay.Amount__c != null ? oldPay.Amount__c : 0.0);
                    }
                }
                runningTotals.put(oppId, base);
            }

            // Only track thresholds if the current item is set to 'Paid'
            if (newPay.Status__c == 'Paid') {
                Decimal currentTotal = runningTotals.get(oppId) + (newPay.Amount__c != null ? newPay.Amount__c : 0.0);
                
                if (currentTotal > maxLimit) {
                    newPay.addError('The total paid can never exceed the opportunity’s amount.');
                } else {
                    runningTotals.put(oppId, currentTotal);
                }
            }
        }
    }

    /**
     * Rule 4: Paid records cannot be deleted.
     * (Handled in code because Salesforce validation rules don't support delete triggers)
     */
    public static void validateDelete(List<Payment__c> oldPayments) {
        for (Payment__c oldPay : oldPayments) {
            if (oldPay.Status__c == 'Paid') {
                oldPay.addError('A paid payment cannot be deleted.');
            }
        }
    }

    /**
     * Dynamic roll-up logic that calculates and maps directly to the Total_Paid__c field.
     */
    public static void rollupTotalsToOpportunity(Map<Id, Payment__c> oldMap, List<Payment__c> newPayments) {
        Set<Id> oppIdsToUpdate = new Set<Id>();

        if (newPayments != null) {
            for (Payment__c newPay : newPayments) {
                if (newPay.Opportunity__c != null) oppIdsToUpdate.add(newPay.Opportunity__c);
                if (oldMap != null && oldMap.containsKey(newPay.Id)) {
                    Id oldOppId = oldMap.get(newPay.Id).Opportunity__c;
                    if (oldOppId != null) oppIdsToUpdate.add(oldOppId);
                }
            }
        } else if (oldMap != null) {
            for (Payment__c oldPay : oldMap.values()) {
                if (oldPay.Opportunity__c != null) oppIdsToUpdate.add(oldPay.Opportunity__c);
            }
        }

        if (oppIdsToUpdate.isEmpty()) return;

        // Instantiate targets safely initialized to 0
        Map<Id, Opportunity> oppsToUpdateMap = new Map<Id, Opportunity>();
        for (Id oppId : oppIdsToUpdate) {
            oppsToUpdateMap.put(oppId, new Opportunity(Id = oppId, Total_Paid__c = 0.0));
        }

        // Loop through all remaining active database elements matching criteria
        for (Payment__c pay : [SELECT Amount__c, Opportunity__c FROM Payment__c WHERE Opportunity__c IN :oppIdsToUpdate AND Status__c = 'Paid']) {
            Opportunity opp = oppsToUpdateMap.get(pay.Opportunity__c);
            if (opp != null) {
                opp.Total_Paid__c += (pay.Amount__c != null ? pay.Amount__c : 0.0);
            }
        }

        if (!oppsToUpdateMap.isEmpty()) {
            update oppsToUpdateMap.values();
        }
    }
}
