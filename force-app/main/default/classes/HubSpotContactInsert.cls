public class HubSpotContactInsert implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Set<Id> contactIds = new Set<Id>();
    public Boolean isInsertMode;
    
    public HubSpotContactInsert(Set<Id> newContactIds, Boolean isInsert){
        contactIds.addAll(newContactIds);
        isInsertMode = isInsert;
    }
    public List<Contact> start(Database.BatchableContext bc){
        return [SELECT Id, FirstName, LastName, Email, Phone, AccountId, HubSpot_Id__c FROM Contact WHERE Id IN :contactIds];    
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scopes){    
        // System.debug('Scope => '+ scopes);
        List<Contact> contactToUpdate = new List<Contact>();
        
        if(isInsertMode){
            for(Contact con : scopes){
                Http htp = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:HubSpot_API/crm/v3/objects/contacts');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                // System.debug('Request Body =>' + req);
                Map<String, Map<String, String>> finalBody = new Map<String, Map<String, String>>();
                Map<String, String> props  = new Map<String, String>();
                props.put('email', con.Email != NULL ? con.Email : '');
                props.put('firstname', con.FirstName != NULL ? con.FirstName : '');
                props.put('lastname', con.LastName);
                props.put('phone', con.Phone != NULL ? con.Phone : '');
                finalBody.put('properties', props);
                // System.debug('Final Body For Contact Insertion Over HubSpot => '+finalBody);
                req.setBody(JSON.serialize(finalBody));
                HttpResponse res = htp.send(req);
                // System.debug('Response Body =>' + res.getBody());
                // System.debug('Response Status => ' + res.getStatus());
                // System.debug('Response Status Code => ' + res.getStatusCode());
                // 
                if(res.getStatus() == 'Created' || res.getStatusCode() == 201){
                    //Map<String, Map<String, String>> resMap = (Map<String, Map<String, String>>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if(resMap.containsKey('id')){
                        Contact c = new Contact(Id = con.Id, HubSpot_Id__c = (String) resMap.get('id'));
                        contactToUpdate.add(c);
                    }
                }
                
            }
            
            if(!contactToUpdate.isEmpty()){
                update contactToUpdate;
            } 
        }
        else{
            for(Contact con : scopes){
                if(con.HubSpot_Id__c != NULL){
                    Http htp = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint('callout:HubSpot_API/crm/v3/objects/contacts/' + con.HubSpot_Id__c);
                    req.setMethod('PATCH');
                    req.setHeader('Content-Type', 'application/json');
                    // System.debug('Request Body =>' + req);
                    Map<String, Map<String, String>> finalBody = new Map<String, Map<String, String>>();
                    Map<String, String> props  = new Map<String, String>();
                    props.put('email', con.Email != NULL ? con.Email : '');
                    props.put('firstname', con.FirstName != NULL ? con.FirstName : '');
                    props.put('lastname', con.LastName);
                    props.put('phone', con.Phone != NULL ? con.Phone : '');
                    finalBody.put('properties', props);
                    // System.debug('Final Body For Contact Insertion Over HubSpot => '+finalBody);
                    req.setBody(JSON.serialize(finalBody));
                    HttpResponse res = htp.send(req);
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}