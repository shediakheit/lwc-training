public with sharing class PaymentTriggerHandler extends TriggerHandler implements ITriggerHandler {
    public static Integer count = 0;
    private Map<Id, Payment__c> newMap;
    private Map<Id, Payment__c> oldMap;
    private List<Payment__c> TriggerNew;
    private List<Payment__c> TriggerOld;
    
    public PaymentTriggerHandler(){
        this.newMap = (Map<Id, Payment__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Payment__c>) Trigger.oldMap;
        this.TriggerNew = (List<Payment__c>) Trigger.New;
        this.TriggerOld = (List<Payment__c>) Trigger.Old;
    }
    
    // Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
       
                // Exercise4.insertIdentifiers(oldMap, TriggerOld);
                        
Exercise4.insertIdentifiers(oldMap, TriggerNew);

    }

    public override void afterInsert() {
        
    }

    public override void beforeUpdate() {
     
                        // Exercise4.insertIdentifiers(oldMap, TriggerOld);
Exercise4.insertIdentifiers(oldMap, TriggerNew);
    }

    public override void afterUpdate() {
        // Intentionally blank
                        // Exercise4.insertIdentifiers(oldMap, TriggerOld);

    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}
