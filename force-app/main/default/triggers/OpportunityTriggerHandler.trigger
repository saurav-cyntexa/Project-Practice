trigger OpportunityTriggerHandler on Opportunity (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityLineItemTriggerHelper.handleOpportunityUpdate(Trigger.oldMap, Trigger.newMap);
    }
}