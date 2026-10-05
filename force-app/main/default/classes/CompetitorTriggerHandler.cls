public with sharing class CompetitorTriggerHandler extends TriggerHandler implements ITriggerHandler {

    private Map<Id, Competitor__c> newMap;
    private Map<Id, Competitor__c> oldMap;
    private List<Competitor__c> TriggerNew;
    private List<Competitor__c> TriggerOld;
    
    public CompetitorTriggerHandler(){
        this.newMap = (Map<Id, Competitor__c>) Trigger.newMap;
        this.oldMap = (Map<Id, Competitor__c>) Trigger.oldMap;
        this.TriggerNew = (List<Competitor__c>) Trigger.New;
        this.TriggerOld = (List<Competitor__c>) Trigger.Old;
    }
    
    // Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    // check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    public override void beforeInsert() {
        // Rule 1: Code-only uniqueness validation
        Exercise3.handleCompetitorLinks(TriggerNew, newMap, oldMap);
    }

    public override void afterInsert() {
        // Rule 2: Sync Quote Competitors to parent Opportunity
        Exercise3.handleCompetitorLinks(TriggerNew, newMap, oldMap);
    }

    public override void beforeUpdate() {
        // Rule 1: Recheck uniqueness if parent/account fields change
        Exercise3.handleCompetitorLinks(TriggerNew, newMap, oldMap);
    }

    public override void afterUpdate() {
        // Intentionally blank
    }
    
    public override void beforeDelete() {
        
    }
    
    public override void afterDelete() {
        
    }
    
    public override void afterUnDelete() {
        
    }
}
