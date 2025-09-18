public class OpportunityLineItemTriggerHelper {
    public static void handleOpportunityLineItemInsert(List<OpportunityLineItem> oliList){
        set<Id> oppIds = new set<Id>();
        for(OpportunityLineItem oli : oliList){
            oppIds.add(oli.OpportunityId);
        }
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds]);
        
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : opportunityMap.values()){
            accountIds.add(opp.AccountId);
        }
        
        calculateAverageProductPrice(accountIds);
        
    }
    
    public static void handleOpportunityUpdate(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> newOppMap){
     	set<Id> accountIds = new set<Id>();
        for(Opportunity opp : newOppMap.values()){
            Opportunity newOpp = newOppMap.get(opp.Id);
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            
            if(oldOpp.AccountId != NULL && (oldOpp.AccountId != newOpp.AccountId)){
                accountIds.add(oldOpp.AccountId);
                accountIds.add(newOpp.AccountId);
            }
            
            if(oldOpp.AccountId == NULL && newOpp.AccountId != NULL){
                accountIds.add(newOpp.AccountId);
            }
            
            if(oldOpp.AccountId != NULL && newOpp.AccountId == NULL){
                accountIds.add(oldOpp.AccountId);
            }   
        }
        
        calculateAverageProductPrice(accountIds);
    }
    
    public static void calculateAverageProductPrice(set<Id> accountIds){
        List<AggregateResult> agrList = [SELECT Opportunity.AccountId, SUM(TotalPrice) tPrice, SUM(Quantity) qty FROM OpportunityLineItem WHERE TotalPrice > 1000 AND Opportunity.AccountId IN :accountIds GROUP By Opportunity.AccountId];
        System.debug('AggregateResult List => '+agrList);
        
        Map<String, Decimal> accountToTotalPriceMap = new Map<String, Decimal>();
        Map<String, Decimal> accountToQuantityMap = new Map<String, Decimal>();
        
        for(AggregateResult agr : agrList){
            accountToTotalPriceMap.put((String)agr.get('AccountId'), (Decimal)agr.get('tPrice'));
            accountToQuantityMap.put((String)agr.get('AccountId'), (Decimal)agr.get('qty'));
        }
		System.debug('Account Total Price => '+accountToTotalPriceMap);
        System.debug('Account Total Quantity =>' + accountToQuantityMap);
        
        
		List<Account> accountToUpdate = new List<Account>();        
        for(Id accIds : accountIds){
            if(accountToTotalPriceMap.containsKey(accIds) && accountToQuantityMap.containsKey(accIds)){
                Account acc = new Account();
                acc.Id = accIds;
                acc.Average_Product_Price__c = accountToTotalPriceMap.get(accIds)/accountToQuantityMap.get(accIds);
                accountToUpdate.add(acc);                
            }
        }
        System.debug('Account to update => '+accountToUpdate);
        if(!accountToUpdate.isEmpty()){
            Database.update(accountToUpdate, false);
        }

    }
}