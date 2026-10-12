public with sharing class AccountOpportunityController {
    
    public class AccountOpportunityWrapper {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Integer oppCount { get; set; }
        @AuraEnabled public Decimal totalAmount { get; set; }
        @AuraEnabled public List<Opportunity> opportunities { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountOpportunityWrapper> getAccountOpportunities() {
        List<AccountOpportunityWrapper> wrapperList = new List<AccountOpportunityWrapper>();
        
        // Fetch accounts along with their related opportunities
        List<Account> accounts = [
            SELECT Id, Name, 
                   (SELECT Id, Name, StageName, Amount, IsClosed FROM Opportunities) 
            FROM Account 
            WITH USER_MODE
            LIMIT 50
        ];

        for (Account acc : accounts) {
            AccountOpportunityWrapper wrap = new AccountOpportunityWrapper();
            wrap.accountId = acc.Id;
            wrap.accountName = acc.Name;
            wrap.opportunities = acc.Opportunities;
            wrap.oppCount = acc.Opportunities.size();
            
            Decimal total = 0;
            for (Opportunity opp : acc.Opportunities) {
                if (opp.Amount != null) {
                    total += opp.Amount;
                }
            }
            wrap.totalAmount = total;
            wrapperList.add(wrap);
        }
        
        return wrapperList;
    }

    @AuraEnabled
    public static void updateOpportunityStage(Id opportunityId, String stageName) {
        try {
            Opportunity opp = new Opportunity(Id = opportunityId, StageName = stageName);
            update as user opp;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating opportunity: ' + e.getMessage());
        }
    }
}
