public with sharing class PaymentTriggerHandler extends TriggerHandler implements ITriggerHandler {
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
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {     
        Exercise5.validateAndProcessPayments(null, TriggerNew);
    }

    public override void afterInsert() {
        Exercise5.rollupTotalsToOpportunity(null, TriggerNew);
    }

    public override void beforeUpdate() {
        Exercise5.validateAndProcessPayments(oldMap, TriggerNew);
    }

    public override void afterUpdate() {
        Exercise5.rollupTotalsToOpportunity(oldMap, TriggerNew);
    }
    
    public override void beforeDelete() {
        Exercise5.validateDelete(TriggerOld);
    }
    
    public override void afterDelete() {
        // FIXED: Passing oldMap as the first argument
        Exercise5.rollupTotalsToOpportunity(oldMap, null);
    }
    
    public override void afterUnDelete() {
        Exercise5.rollupTotalsToOpportunity(null, TriggerNew);
    }
}
