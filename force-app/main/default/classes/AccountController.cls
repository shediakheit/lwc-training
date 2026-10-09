public class AccountController {


    @AuraEnabled
    public static void createNewAccount(String accountName) {
        if (String.isBlank(accountName)) {
            throw new AuraHandledException('Account name cannot be empty.');
        }
        Account acc = new Account(Name = accountName);
            
    
            insert as user acc; 
            
    }


    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer maxRecords) {
        List<Account> accounts = [SELECT Id, Name FROM Account ORDER BY CreatedDate
        DESC LIMIT: maxRecords];
        return accounts;
    }
}