public with sharing class QuoteController {
    
    @AuraEnabled(cacheable=true)
    public static String getOpportunityLeaseType(Id recordId) {
        try {
            Opportunity opp = [SELECT Lease_Type__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            return opp.Lease_Type__c;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Opportunity: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveQuote(Quote quoteRec, Id oppId) {
        try {
            quoteRec.OpportunityId = oppId;
            insert quoteRec;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving Quote: ' + e.getMessage());
        }
    }
}
