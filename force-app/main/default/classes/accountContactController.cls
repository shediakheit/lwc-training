public with sharing class accountContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getRelatedContacts(Id accountId) {
        return [
            SELECT Id, FirstName, LastName, Email, Phone 
            FROM Contact 
            WHERE AccountId = :accountId 
            ORDER BY CreatedDate DESC
        ];
    }
}
