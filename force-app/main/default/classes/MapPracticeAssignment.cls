/**
 * @description     Created this MapPracticeAssignment to solve the assignment during training to get good hands-on of using maps in Apex programming. 
 *
 * @author          Saurav Kumar
 */
public class MapPracticeAssignment {
    
    public static Map<String, Contact> getContactMapByEmail() {
        
        List<Contact> contactList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email != NULL];
        
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        
        for(Contact con : contactList){
            emailToContactMap.put(con.Email, con);
        }
        
        return emailToContactMap;
    }
    
    /**
     * @description                        This function basically retrieves the Account records from the Salesforce database and groups them based on their Industry.
     * 
     * @author                             Saurav Kumar
     * 
     * @return Map<String, List<Account>>  In this map, the key is the Industry and the values will be all the Accounts belonging to that particular Industry.
     */
    public static Map<String, List<Account>> getAccountMapByIndustry() {
        Map<String, List<Account>> industryToAccountsMap = new  Map<String, List<Account>>();
        List<Account> accountList = [SELECT Id, Name, NumberOfEmployees, Industry FROM Account WHERE Industry != NULL];
        for(Account acc : accountList){
            if(!industryToAccountsMap.containsKey(acc.Industry)){
                industryToAccountsMap.put(acc.Industry, new List<Account>{acc});
            }
            industryToAccountsMap.get(acc.Industry).add(acc);        
        }
        return industryToAccountsMap; 
    }
    
    
    /**
     * @description                        This function retrieves the Contact records from the Salesforce database and groups them based on the first letter of their FirstName.
     * 
     * @author                             Saurav Kumar
     * 
     * @return Map<String, List<Contact>>  In this map, the key is the first letter of a Contact's FirstName and the values will be all the Contacts whose FirstName starts with the respective key.
     */
    public static Map<String, List<Contact>> groupContactsByFirstLetter() {
        Map<String, List<Contact>> firstLetterToContactsMap = new Map<String, List<Contact>>();
        
        List<Contact> contactList = [SELECT FirstName, LastName, Email FROM Contact WHERE FirstName != NULL];
        
        for(Contact con : contactList){
            String firstLetter = con.FirstName.substring(0,1);
            if(!firstLetterToContactsMap.containsKey(firstLetter)){
                firstLetterToContactsMap.put(firstLetter, new List<Contact>{con});
            }
            firstLetterToContactsMap.get(firstLetter).add(con);
        }
        return firstLetterToContactsMap;
    }
    
    
    /**
     * @description                     This function retrieves the Opportunity records from the Salesforce database and calculates the total Opportunity Amount for each Stage.
     * 
     * @author                          Saurav Kumar
     * 
     * @return Map<String, Decimal>     In this map, the key is the StageName of the Opportunity and the values will be the total summed Amount of all Opportunities under that Stage.
     */
    public static Map<String, Decimal> calculateStageAmounts() {
        Map<String, Decimal> stageNameToTotalAmountMap = new Map<String, Decimal>();
        
        for(Opportunity opp : [SELECT Id, StageName, Amount FROM Opportunity WHERE StageName != NULL]){
            Decimal totalAmt = opp.Amount != NULL ? opp.Amount : 0;
            if(!stageNameToTotalAmountMap.containsKey(opp.StageName)){
                stageNameToTotalAmountMap.put(opp.StageName, totalAmt);
            }
            totalAmt += stageNameToTotalAmountMap.get(opp.StageName);
            stageNameToTotalAmountMap.put(opp.StageName, totalAmt);
        }
        return stageNameToTotalAmountMap;
    }
    
    
    /**
     * @description                     		This function retrieves the Opportunity records and groups them based on a combination of LeadSource and StageName.
     * 
     * @author                          		Saurav Kumar
     * 
     * @return Map<String, List<Opportunity>>   In this map, the key is a composite value formed by concatenating LeadSource and StageName with a '-' in between, and the values will be all Opportunities matching that key.
     */
    public static Map<String, List<Opportunity>> groupOpportunitiesByLeadSourceAndStage() {
        Map<String, List<Opportunity>> leadSourceAndStageToOpportunitiesMap = new Map<String, List<Opportunity>>();
        for(Opportunity opp : [SELECT Id, Name, LeadSource, StageName FROM Opportunity WHERE LeadSource != NULL AND StageName != NULL]){
            String key = opp.LeadSource + '-' + opp.StageName;
            if(!leadSourceAndStageToOpportunitiesMap.containsKey(key)){
                leadSourceAndStageToOpportunitiesMap.put(key, new List<Opportunity>{opp});
            }
            leadSourceAndStageToOpportunitiesMap.get(key).add(opp);
        }
        return leadSourceAndStageToOpportunitiesMap;
    }
    
    
    /**
     * @description                     This function retrieves the Lead records from the Salesforce database and groups them based on their Status.
     * 
     * @author                          Saurav Kumar
     * 
     * @return Map<String, List<Lead>>  In this map, the key is the Status of a Lead and the values will be all Leads under that Status.
     */
    public static Map<String, List<Lead>> groupLeadsByStatus () {
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>();
        
        for(Lead l : [SELECT Id, FirstName, LastName, Email, Status FROM Lead WHERE Status != NULL]){
            if(!statusToLeadsMap.containsKey(l.Status)){
                statusToLeadsMap.put(l.Status, new List<Lead>{l});
            }
            statusToLeadsMap.get(l.Status).add(l);
        }
        return statusToLeadsMap;
    }
    
    
    /**
     * @description                     This function retrieves the Case records from the Salesforce database and groups them based on their Priority.
     * 
     * @author                          Saurav Kumar
     * 
     * @return Map<String, List<Case>>  In this map, the key is the Priority of a Case and the values will be all Cases under that Priority.
     */
    public static Map<String, List<Case>> getCasesByPriority() {
        Map<String, List<Case>> priorityToCasesMap = new Map<String, List<Case>>();
        
        for(Case c : [SELECT Id, Priority FROM Case WHERE Priority != NULL]){
            if(!priorityToCasesMap.containsKey(c.Priority)){
                priorityToCasesMap.put(c.Priority, new List<Case>{c});
            }
            priorityToCasesMap.get(c.Priority).add(c);
        }
        return priorityToCasesMap;
    }
    
    
    /**
     * @description                     	This function retrieves the Account records from the Salesforce database and groups them based on their BillingCountry.
     * 
     * @author                          	Saurav Kumar
     * 
     * @return Map<String, List<Account>>   In this map, the key is the BillingCountry of an Account and the values will be all Accounts belonging to that country.
     */
    public static Map<String, List<Account>> buildAccountMap() {
        Map<String, List<Account>> billingCountryToAccountsMap = new Map<String, List<Account>>();
        for(Account acc : [SELECT Id, Name, BillingCountry FROM Account WHERE BillingCountry != NULL]){
            if(!billingCountryToAccountsMap.containsKey(acc.BillingCountry)){
                billingCountryToAccountsMap.put(acc.BillingCountry, new List<Account>{acc});
            }
            billingCountryToAccountsMap.get(acc.BillingCountry).add(acc);
        }
        return billingCountryToAccountsMap;
    }
    
    
    /**
     * @description                     	This function retrieves the Contact records from the Salesforce database and groups them based on their MailingState.
     * 
     * @author                          	Saurav Kumar
     * 
     * @return Map<String, List<Contact>>  	In this map, the key is the MailingState of a Contact and the values will be all Contacts belonging to that state.
     */
    public static Map<String, List<Contact>> getContactsByMailingState() {
        Map<String, List<Contact>> mailingStateToContactsMap = new Map<String, List<Contact>>();
        for(Contact con : [SELECT Id, Name, MailingState FROM Contact WHERE MailingState != NULL]){
            if(!mailingStateToContactsMap.containsKey(con.MailingState)){
                mailingStateToContactsMap.put(con.MailingState, new List<Contact>{con});
            }
            mailingStateToContactsMap.get(con.MailingState).add(con);
        }
        return mailingStateToContactsMap;
    }
}