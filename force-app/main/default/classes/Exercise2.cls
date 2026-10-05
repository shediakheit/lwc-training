public with sharing class Exercise2 {
    
    public static void countContactsInsert(Map<Id, Contact> oldMap, List<Contact> triggerNew) {
        Set<Id> accountIdsToUpdate = new Set<Id>();
        List<Contact> recordsToProcess = (triggerNew != null) ? triggerNew : oldMap.values();

        for (Contact newContact : recordsToProcess) {
            Contact oldContact = (oldMap != null && newContact.Id != null) ? oldMap.get(newContact.Id) : null;
            
            Boolean currentMatches = (String.isBlank(newContact.FirstName) || newContact.LastName == 'smith');
            Boolean priorMatches = (oldContact != null) && (String.isBlank(oldContact.FirstName) || oldContact.LastName == 'smith');

            if (oldContact == null) {
                if (newContact.AccountId != null && currentMatches) {
                    accountIdsToUpdate.add(newContact.AccountId);
                }
            } 
            else {
                Boolean accountChanged = (newContact.AccountId != oldContact.AccountId);
                Boolean criteriaChanged = (currentMatches != priorMatches);

                if (accountChanged) {
                    if (currentMatches && newContact.AccountId != null) accountIdsToUpdate.add(newContact.AccountId);
                    if (priorMatches && oldContact.AccountId != null) accountIdsToUpdate.add(oldContact.AccountId);
                } 
                else if (criteriaChanged && newContact.AccountId != null) {
                    accountIdsToUpdate.add(newContact.AccountId);
                }
            }
        }

        if (!accountIdsToUpdate.isEmpty()) {
            Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();
            
            // 1. Initialize all targeted accounts with 0 to clear out values if everything was removed
            for (Id accId : accountIdsToUpdate) {
                accountsToUpdateMap.put(accId, new Account(Id = accId, Contact_Count__c = 0));
            }

            // 2. Loop through accounts using the SOQL loop
            for (Account acc : [
                SELECT Id, (SELECT Id FROM Contacts WHERE FirstName = NULL OR LastName = 'smith') 
                FROM Account 
                WHERE Id IN :accountIdsToUpdate
            ]) {
                // 3. To prevent the subquery "direct assignment" limit error, we manually count 
                // the elements by iterating over the subquery inline list.
                Integer matchingContactCount = 0;
                for (Contact con : acc.Contacts) {
                    matchingContactCount++;
                }
                
                accountsToUpdateMap.get(acc.Id).Contact_Count__c = matchingContactCount;
            }

            // 4. Update records
            if (!accountsToUpdateMap.isEmpty()) {
                update accountsToUpdateMap.values();
            }
        }
    }
}
