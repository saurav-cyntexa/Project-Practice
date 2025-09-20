/**
* @description     Createdd QueryAssignment class to do hands-on of soql assignment.
* @author          Saurav Kumar
*/
public class QueryAssignment {
    
    /**
    * @description Get the Sum of Amount of all closed opportunities owned by the current logged in user. The Sum should be fetched for every fiscal year by a single query.
    * @author  Saurav Kumar
    * @return List<AggregateResult> Return type is aggregateResult because here i have used sum aggregatation to do total of amount.  
    */
    public static List<AggregateResult> getClosedOpportunitySumByFiscalYear(){
        return [SELECT FiscalYear, SUM(Amount) totalAmt FROM Opportunity WHERE isClosed = true AND OwnerId = :UserInfo.getUserId() GROUP BY FiscalYear];
    }
    
    /**
    * @description Fetch all the opportunity records whose close date lies between 2 dates passed as an argument to the function (firstDate, SecondDate) and opportunity owner’s name is ‘Saurman Dsouza’.
    * @author  Saurav Kumar
    * @return List<Opportunity> Will return all the opportunity records which closed date lies in between the given date range. 
    * @param firstDate From Date range  
    * @param secondDate To Date range
    */
    public static List<Opportunity> fetchOpportunitiesBetweenDates(Date firstDate, Date secondDate){
        if(firstDate >secondDate){
            Date temp = firstDate;
            firstDate = secondDate;
            secondDate = temp;
        }
        
        return [SELECT Id, Name, CloseDate, OwnerId, Owner.Name FROM Opportunity WHERE CloseDate >= :firstDate AND CloseDate <= :secondDate AND Owner.Name = 'Saurman Dsouza'];
    }
    
    /**
    * @description Get all the opportunities,contacts,notes related to an Account where Account Name starts with ‘B’.
    * @author  Saurav Kumar
    * @return List<Account>  Will return all the account and there relatedd opportunity, contact, notes 
    */
    public static List<Account> fetchAccountsWithRelatedData() {
        return [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts), (SELECT Id, Title FROM Notes) FROM Account WHERE Name LIKE 'B%'];
    }
    
    /**
    * @description Get the account name,notes,contacts related to an opportunity where opportunity name ends with ‘A’.
    * @author  Saurav Kumar
    * @return List<Opportunity>  return all the opportunity record having account name, notes and contacts. 
    */
    public static List<Opportunity> fetchRelatedDataForOpportunity(){
        return [SELECT Id, Name, Account.Name, (SELECT Id, Title FROM Notes), (SELECT Id, ContactId, Contact.Name FROM OpportunityContactRoles) FROM Opportunity WHERE Name LIKE '%A'];
    }
    
    /**
    * @description Get all the account and opportunity records where field consist ‘Test’ and close date of opportunity records should be of this fiscal year, accounts should be owned by current logged in user. 
    * @author  Saurav Kumar
    * @return List<List<sObject>> list of list of sObject where sobjects are account and opportunity object, will contains the record which consist 'Test' and if it is account record which is owned by the current user and if it is opportunity record and close date is in this fiscal year.
    */    
    public static List<List<sObject>> fetchTestOpportunityRecords(){
        return [FIND 'Test' RETURNING Account(Name, OwnerId, Owner.Name WHERE Owner.Name = :UserInfo.getUserId()), Opportunity(Name,CloseDate Where CloseDate = This_Fiscal_Year)];
    }
    
    /**
    * @description Create a map, use the query of Q3 a) Where the key will be the Account id and list of records as value.
    * @author  Saurav Kumar
    */ 
    public static Map<Id, List<Opportunity>> opportunitiesRelatedToAccountMap  = new Map<Id, List<Opportunity>>(); 
    public static Map<Id, List<Contact>> contactsRelatedToAccountMap = new Map<Id, List<Contact>>();
    public static Map<Id, List<Note>> notesRelatedToAccountMap = new Map<Id, List<Note>>();
    public static void setOppContactNotesRelatedToAccount(){
        List<Account> accountList = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities), (SELECT Id, Name FROM Contacts), (SELECT Id, Title FROM Notes) FROM Account WHERE Name LIKE 'B%'];
        for(Account acc : accountList){
            opportunitiesRelatedToAccountMap.put(acc.Id, acc.Opportunities);
            contactsRelatedToAccountMap.put(acc.Id, acc.Contacts);
            notesRelatedToAccountMap.put(acc.Id, acc.Notes);
        }
    }
}