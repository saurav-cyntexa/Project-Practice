trigger OpportunityTriggerHandler on Opportunity (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityLineItemTriggerHelper.opportunityUpdation(Trigger.oldMap, Trigger.newMap);
    }
}