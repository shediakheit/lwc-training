@isTest
private class CompetitorTriggerHandlerTest {

    @TestSetup
    static void makeData() {
        // Create common test Accounts
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Competitor Account Alpha'),
            new Account(Name = 'Competitor Account Beta')
        };
        insert testAccounts;

        // Create a standard Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Deal Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Create a standard Quote linked to the Opportunity
        Quote q = new Quote(
            Name = 'Standard Test Quote',
            OpportunityId = opp.Id
        );
        insert q;
    }

    /**
     * Test Rule 1: Verifies that adding the same Account to an Opportunity 
     * a second time fails due to the code-level addError validation.
     */
    @isTest
    static void testOpportunityUniquenessConstraint() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Competitor Account Alpha' LIMIT 1];

        // First insert should pass cleanly
        Competitor__c comp1 = new Competitor__c(
            Opportunity__c = opp.Id,
            Account__c = acc.Id
        );
        insert comp1;

        // Second insert of the exact same account on the same Opportunity should throw a DmlException
        Competitor__c comp2 = new Competitor__c(
            Opportunity__c = opp.Id,
            Account__c = acc.Id
        );

        System.Test.startTest();
        try {
            insert comp2;
            System.assert(false, 'A DmlException should have been thrown because this account is already assigned.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('already listed as a competitor'), 'Expected the custom validation error message.');
        }
        System.Test.stopTest();
    }

    /**
     * Test Rule 1: Verifies that adding the same Account to a Quote 
     * a second time fails due to the code-level addError validation.
     */
    @isTest
    static void testQuoteUniquenessConstraint() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Competitor Account Alpha' LIMIT 1];

        // First insert should pass cleanly
        Competitor__c comp1 = new Competitor__c(
            Quote__c = q.Id,
            Account__c = acc.Id
        );
        insert comp1;

        // Second insert of the exact same account on the same Quote should throw a DmlException
        Competitor__c comp2 = new Competitor__c(
            Quote__c = q.Id,
            Account__c = acc.Id
        );

        System.Test.startTest();
        try {
            insert comp2;
            System.assert(false, 'A DmlException should have been thrown because this account is already assigned.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('already listed as a competitor'), 'Expected the custom validation error message.');
        }
        System.Test.stopTest();
    }

    /**
     * Test Rule 2: Verifies that when a competitor account is added to a Quote, 
     * it automatically creates a corresponding record on the parent Opportunity.
     */
    @isTest
    static void testSyncQuoteCompetitorToOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Competitor Account Alpha' LIMIT 1];

        // Assert that the Opportunity has no competitors at the start
        System.assertEquals(0, [SELECT COUNT() FROM Competitor__c WHERE Opportunity__c = :opp.Id]);

        System.Test.startTest();
        Competitor__c quoteComp = new Competitor__c(
            Quote__c = q.Id,
            Account__c = acc.Id
        );
        insert quoteComp;
        System.Test.stopTest();

        // Verify that the trigger logic automatically sync'd a record over to the Opportunity
        List<Competitor__c> oppCompetitors = [
            SELECT Id, Account__c 
            FROM Competitor__c 
            WHERE Opportunity__c = :opp.Id
        ];
        
        System.assertEquals(1, oppCompetitors.size(), 'A competitor record should have been automatically added to the parent Opportunity.');
        System.assertEquals(acc.Id, oppCompetitors[0].Account__c, 'The sync logic should have targeted the same Account.');
    }

    /**
     * Test Rule 2 No-Op: Verifies that if a competitor account already exists on the Opportunity,
     * adding it to the Quote does not break the transaction or trigger a self-duplication failure.
     */
    @isTest
    static void testSyncQuoteCompetitorWhenAlreadyExistsOnOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Competitor Account Alpha' LIMIT 1];

        // Add the Account directly to the Opportunity first
        Competitor__c oppComp = new Competitor__c(
            Opportunity__c = opp.Id,
            Account__c = acc.Id
        );
        insert oppComp;

        System.Test.startTest();
        // Insert the same Account on the Quote
        Competitor__c quoteComp = new Competitor__c(
            Quote__c = q.Id,
            Account__c = acc.Id
        );
        
        // This transaction shouldn't fail. The service must skip cloning because it already exists.
        Database.SaveResult result = Database.insert(quoteComp, false);
        System.Test.stopTest();

        System.assert(result.isSuccess(), 'The Quote competitor insertion should succeed smoothly even if the Opportunity already has it.');
        
        // Final count tracking check: 1 on Opportunity + 1 on Quote = 2 total records
        System.assertEquals(2, [SELECT COUNT() FROM Competitor__c], 'The service should gracefully bypass existing duplicates without creating extra records.');
    }
}
