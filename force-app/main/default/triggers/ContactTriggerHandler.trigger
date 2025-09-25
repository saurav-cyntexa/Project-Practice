trigger ContactTriggerHandler on Contact (after insert, after update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : Trigger.New){
            if(con.AccountId == NULL){
                contactIds.add(con.Id);
            }
        }
        Database.executeBatch(new HubSpotContactInsert(contactIds, true), 100);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> contactIdToInsert = new Set<Id>();
        Set<Id> contactIdToDelete = new Set<Id>();
        Set<Id> contactIdToUpdate = new Set<Id>();
        
        Map<Id, Contact> oldContactMap = Trigger.oldMap;
        
        for(Contact con : Trigger.New){
            Contact oldCon = oldContactMap.get(con.Id);
            
            // Case 1: Account newly linked → delete from HubSpot
            if(con.AccountId != NULL && oldCon.AccountId == NULL){
                contactIdToDelete.add(con.Id);
            }
            // Case 2: Account removed → insert into HubSpot
            else if(con.AccountId == NULL && oldCon.AccountId != NULL){
                contactIdToInsert.add(con.Id);
            }
            // Case 3: Still no Account, but other fields updated → update HubSpot
            else if(con.AccountId == NULL && oldCon.AccountId == NULL){
                if(con.FirstName != oldCon.FirstName || 
                   con.LastName != oldCon.LastName ||
                   con.Email != oldCon.Email || 
                   con.Phone != oldCon.Phone){
                       contactIdToUpdate.add(con.Id);
                   }
            }
        }
        
        if(!contactIdToInsert.isEmpty()){
            Database.executeBatch(new HubSpotContactInsert(contactIdToInsert, true), 100);
        }
        if(!contactIdToUpdate.isEmpty()){
            Database.executeBatch(new HubSpotContactInsert(contactIdToUpdate, false), 100); 
        }
        if(!contactIdToDelete.isEmpty()){
            Database.executeBatch(new HubSpotContactDelete(contactIdToDelete), 100);
        }
    }
    
}