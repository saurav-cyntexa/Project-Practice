public class HubSpotContactDelete implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Set<Id> contactIds = new Set<Id>();
    public HubSpotContactDelete(Set<Id> newContactIds){
        contactIds.addAll(newContactIds);
    }
    public List<Contact> start(Database.BatchableContext bc){
        return [SELECT Id, FirstName, LastName, Email, Phone, AccountId, HubSpot_Id__c FROM Contact WHERE Id IN :contactIds AND AccountId != NULL];    
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scopes){    
        for(Contact con : scopes){
            if(con.HubSpot_Id__c != NULL){
                Http htp = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:HubSpot_API/crm/v3/objects/contacts/' + con.HubSpot_Id__c);
                req.setMethod('DELETE');
                HttpResponse res = htp.send(req);
            }
            
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}