public with sharing class Exercise3 {
       public static Integer count = 0; 
   public static void handleCompetitorLinks(List<Competitor__c> newList, Map<Id, Competitor__c> oldMap, Map<Id, Competitor__c> newMap) {
    
    // -------------------------------------------------------------
    // RULE 1: Enforce Uniqueness per Quote/Opp (Before Context)
    // -------------------------------------------------------------
    Set<Id> quoteIds = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();

    for (Competitor__c comp : newList) {
        if (comp.Account__c != null) {
            accountIds.add(comp.Account__c);
            if (comp.Quote__c != null) quoteIds.add(comp.Quote__c);
            if (comp.Opportunity__c != null) oppIds.add(comp.Opportunity__c);
        }
    }

    // Query existing competitors matching the same parent and account scopes
    Map<String, Competitor__c> existingRecordsMap = new Map<String, Competitor__c>();
    for (Competitor__c existing : [SELECT Id, Account__c, Quote__c, Opportunity__c 
                                    FROM Competitor__c 
                                    WHERE Account__c IN :accountIds 
                                    AND (Quote__c IN :quoteIds OR Opportunity__c IN :oppIds)]) {
        if (existing.Quote__c != null) {
            existingRecordsMap.put(existing.Quote__c + '_' + existing.Account__c, existing);
        }
        if (existing.Opportunity__c != null) {
            existingRecordsMap.put(existing.Opportunity__c + '_' + existing.Account__c, existing);
        }
    }

    List<Competitor__c> competitorsToCopyToOpp = new List<Competitor__c>();

    for (Competitor__c comp : newList) {
        if (comp.Account__c == null) continue;

        // Check unique Quote relationship
        if (comp.Quote__c != null) {
            String key = comp.Quote__c + '_' + comp.Account__c;
            if (existingRecordsMap.containsKey(key) && (newMap == null || !newMap.containsKey(existingRecordsMap.get(key).Id))) {
                comp.addError('This account is already a competitor on this Quote.');
            } else {
                // Stage for Rule 2 automation if it passes validation
                if (oldMap == null || oldMap.get(comp.Id).Quote__c != comp.Quote__c) {
                    competitorsToCopyToOpp.add(comp);
                }
            }
        }

        // Check unique Opportunity relationship
        if (comp.Opportunity__c != null) {
            String key = comp.Opportunity__c + '_' + comp.Account__c;
            if (existingRecordsMap.containsKey(key) && (newMap == null || !newMap.containsKey(existingRecordsMap.get(key).Id))) {
                comp.addError('This account is already a competitor on this Opportunity.');
            }
        }
    }

    // -------------------------------------------------------------
    // RULE 2: Auto-Add to Opportunity if added to Quote (After Context execution simulation)
    // -------------------------------------------------------------
    if (!competitorsToCopyToOpp.isEmpty() && Trigger.isAfter) {
        List<Competitor__c> newOppCompetitors = new List<Competitor__c>();
        
        // We need the Opportunity ID from the Quote since Quote has an MD relationship to Opportunity
        Set<Id> targetQuoteIds = new Set<Id>();
        for(Competitor__c c : competitorsToCopyToOpp) targetQuoteIds.add(c.Quote__c);
        
        Map<Id, Quote> quoteToOppMap = new Map<Id, Quote>([SELECT Id, OpportunityId FROM Quote WHERE Id IN :targetQuoteIds]);

        for (Competitor__c quoteComp : competitorsToCopyToOpp) {
            Id oppId = quoteToOppMap.get(quoteComp.Quote__c)?.OpportunityId;
            if (oppId != null) {
                String key = oppId + '_' + quoteComp.Account__c;
                // Only add if it doesn't already exist on the Opportunity
                if (!existingRecordsMap.containsKey(key)) {
                    newOppCompetitors.add(new Competitor__c(
                        Account__c = quoteComp.Account__c,
                        Opportunity__c = oppId
                    ));
                }
            }
        }

        if (!newOppCompetitors.isEmpty()) {
            insert newOppCompetitors;
        }
    }
}

}
