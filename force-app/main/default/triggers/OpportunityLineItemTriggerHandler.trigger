trigger OpportunityLineItemTriggerHandler on OpportunityLineItem (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        OpportunityLineItemTriggerHelper.handleOpportunityLineItemInsert(Trigger.New);
    }
}