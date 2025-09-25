public with sharing class dapMay2023Controller {
    public dapMay2023Controller() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchContacts(){
        try {
            return [SELECT Id, FirstName, LastName, Name, AccountId, Phone, Email FROM Contact];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void linkContactsToAccount(List<Map<String, String>> contacts, Id accountId) {
        Set<Id> contactIds = new Set<Id>();
        for(Map<String, String> mp : contacts){
            contactIds.add(mp.get('Id'));
        }

        List<Contact> contactsToUpdate = [SELECT Id FROM Contact WHERE Id IN :contactIds];
        for (Contact c : contactsToUpdate) {
            c.AccountId = accountId;
        }
        update contactsToUpdate;
    }

}