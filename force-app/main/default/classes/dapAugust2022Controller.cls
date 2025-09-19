public with sharing class dapAugust2022Controller {
    public dapAugust2022Controller() {

    }

    @AuraEnabled
    public static List<Contact> getContactList(String mail, String ph){
        try {
            List<Contact> contactList = [SELECT Id, FirstName, LastName, Name, Phone, Email, Gender__c,Is_Current_Permanent_Adress_Same__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Email = :mail OR Phone = :ph];
            return contactList;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendOTPEmail(String emailAddress, String otp) {
        try {

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            
            String[] toAddresses = new String[] { emailAddress };
            email.setToAddresses(toAddresses);        
            
            String subject = 'Your One-Time Password (OTP)';
            String body = 'Hello,\n\n'
                        + 'Your One-Time Password (OTP) is: ' + otp + '\n\n'
                        + 'Please use this code to complete your verification process. '
                        + 'This OTP will expire in 10 minutes.\n\n'
                        + 'If you did not request this, please ignore this email.\n\n'
                        + 'Thank you,\n'
                        + 'Your Company Team';
            
            email.setSubject(subject);
            email.setPlainTextBody(body);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}