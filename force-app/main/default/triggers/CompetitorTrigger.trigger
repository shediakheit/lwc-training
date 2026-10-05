trigger CompetitorTrigger on Competitor__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    // You just call run() and the base framework class handles the before/after routing
    new CompetitorTriggerHandler().run();
}
