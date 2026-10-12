public with sharing class CaseController {
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(String searchKey) {
        String query = 'SELECT Id, CaseNumber, Subject, Description, Status FROM Case';
        if (String.isNotBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            query += ' WHERE CaseNumber LIKE :key';
        }
        query += ' ORDER BY CreatedDate DESC LIMIT 100';
        return Database.query(query);
    }

    

    @AuraEnabled
    public static Case createCaseRecord(String subject, String description) {
        try {
            Case newCase = new Case(
                Subject = subject,
                Description = description,
                Status = 'New' 
            );
            insert newCase;
            return newCase;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
