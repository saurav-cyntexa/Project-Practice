public with sharing class dapOctober2021Controller {
    public dapOctober2021Controller() {

    }
    @AuraEnabled(cacheable=true)
    public static List<Real_Estate_Property__c> fetchProperties(){
        try {
            return [SELECT Id, Name, Property_Image__c, Price__c, (SELECT Id, LastName, FirstName, Name, Phone, Email, Contact_Image__c, Real_Estate_Property__c FROM Contacts__r) FROM Real_Estate_Property__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}