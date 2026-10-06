public with sharing class Exercise4 {
    
  public static void insertIdentifiers(Map<Id, Offer__c> oldMap, List<Offer__c> offers) {
    Set<Id> oppIds = new Set<Id>();
    List<Offer__c> offersToProcess = new List<Offer__c>();

    for (Offer__c offer : offers) {
        Boolean isInsert = (oldMap == null);
        Boolean isOppChanged = (!isInsert && offer.Opportunity__c != oldMap.get(offer.Id).Opportunity__c);

        if (offer.Opportunity__c != null && (isInsert || isOppChanged)) {
            oppIds.add(offer.Opportunity__c);
            offersToProcess.add(offer);
        }
    }

    if (oppIds.isEmpty()) {
        return;
    }

    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
        SELECT Id, Identifier__c 
        FROM Opportunity 
        WHERE Id IN :oppIds
    ]);

    Map<Id, Integer> oppToMaxNumMap = new Map<Id, Integer>();
    
    for (Offer__c existingOffer : [
        SELECT Opportunity__c, Identifier__c 
        FROM Offer__c 
        WHERE Opportunity__c IN :oppIds AND Identifier__c LIKE '%-%'
        ORDER BY CreatedDate ASC, Id ASC
    ]) {
        String ident = existingOffer.Identifier__c;
       
            Integer currentNum = Integer.valueOf(ident.substringAfterLast('-'));
            if (!oppToMaxNumMap.containsKey(existingOffer.Opportunity__c) || currentNum > oppToMaxNumMap.get(existingOffer.Opportunity__c)) {
                oppToMaxNumMap.put(existingOffer.Opportunity__c, currentNum);
            }
    }

    for (Offer__c offer : offersToProcess) {
        Opportunity opp = oppMap.get(offer.Opportunity__c);
        if (opp == null || String.isBlank(opp.Identifier__c)) {
            continue;
        }

        Integer currentMax = oppToMaxNumMap.containsKey(offer.Opportunity__c) ? oppToMaxNumMap.get(offer.Opportunity__c) : -1;
        Integer nextNum = currentMax + 1;
        
        String suffix = String.valueOf(nextNum).leftPad(3, '0');
        offer.Identifier__c = opp.Identifier__c + '-' + suffix;
        
        oppToMaxNumMap.put(offer.Opportunity__c, nextNum);
    }
}


}