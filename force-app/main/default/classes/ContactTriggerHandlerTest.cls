@isTest
private class ContactTriggerHandlerTest {

    @isTest
    static void testContactInsertRecalculation() {
        // Step 1: Create a test account
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        // Step 2: Prepare contacts testing all your conditional rules
        List<Contact> testContacts = new List<Contact>();
        
        // Match Rule 1: LastName is Smith
        testContacts.add(new Contact(FirstName = 'John', LastName = 'Smith', AccountId = testAcc.Id));
        
        // Match Rule 2: FirstName is empty/blank
        testContacts.add(new Contact(FirstName = '', LastName = 'Adams', AccountId = testAcc.Id));
        testContacts.add(new Contact(FirstName = null, LastName = 'Baker', AccountId = testAcc.Id));
        
        // Non-Match: Does NOT meet any criteria (Should not count)
        testContacts.add(new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = testAcc.Id));

        // Step 3: Run DML inside Test block to reset governor limits
        System.Test.startTest();
        insert testContacts;
        System.Test.stopTest();

        // Step 4: Verify the custom field calculated only the 3 matching records
        Account resultAcc = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        Assert.areEqual(3, resultAcc.Contact_Count__c, 'The account contact count should reflect only matching records.');
    }

    @isTest
    static void testContactCriteriaUpdate() {
        // Step 1: Create a test account and a contact that matches criteria (LastName = Smith)
        Account testAcc = new Account(Name = 'Update Test Account');
        insert testAcc;

        Contact con = new Contact(FirstName = 'Tom', LastName = 'Smith', AccountId = testAcc.Id);
        insert con;

        // Verify initial setup (Count should be 1)
        Account initialAcc = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        Assert.areEqual(1, initialAcc.Contact_Count__c);

        // Step 2: Update the contact so it NO LONGER matches criteria
        System.Test.startTest();
        con.LastName = 'Jones'; // No longer Smith, FirstName is not blank
        update con;
        System.Test.stopTest();

        // Step 3: Verify the count correctly dropped to 0
        Account updatedAcc = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        Assert.areEqual(0, updatedAcc.Contact_Count__c, 'Account count should drop to 0 after removing the Smith criteria.');
    }

    @isTest
    static void testContactAccountSwap() {
        // Step 1: Create two separate accounts
        Account accA = new Account(Name = 'Account A');
        Account accB = new Account(Name = 'Account B');
        insert new List<Account>{accA, accB};

        // Step 2: Insert a matching contact linked to Account A
        Contact con = new Contact(LastName = 'Smith', AccountId = accA.Id);
        insert con;

        // Step 3: Update the contact to switch its parent to Account B
        System.Test.startTest();
        con.AccountId = accB.Id;
        update con;
        System.Test.stopTest();

        // Step 4: Verify the count shifted cleanly from Account A to Account B
        Account resultAccA = [SELECT Contact_Count__c FROM Account WHERE Id = :accA.Id];
        Account resultAccB = [SELECT Contact_Count__c FROM Account WHERE Id = :accB.Id];

        Assert.areEqual(0, resultAccA.Contact_Count__c, 'Account A count should drop to 0.');
        Assert.areEqual(1, resultAccB.Contact_Count__c, 'Account B count should increase to 1.');
    }

    @isTest
    static void testBulkContacts() {
        // Step 1: Create a test account
        Account testAcc = new Account(Name = 'Bulk Test Account');
        insert testAcc;

        // Step 2: Generate 200 matching records to test bulk safe execution
        List<Contact> bulkContacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            bulkContacts.add(new Contact(
                FirstName = 'BulkFirst' + i,
                LastName = 'Smith',
                AccountId = testAcc.Id
            ));
        }

        // Step 3: Insert records and ensure it doesn't hit SOQL/DML Governor Limits
        System.Test.startTest();
        insert bulkContacts;
        System.Test.stopTest();

        // Step 4: Validate count matches bulk volume
        Account resultAcc = [SELECT Contact_Count__c FROM Account WHERE Id = :testAcc.Id];
        Assert.areEqual(200, resultAcc.Contact_Count__c, 'Bulk handling should accurately count all 200 contacts.');
    }
}
