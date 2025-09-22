/**
 * @description : Created this DMLAssignment to solve the assignment and to get good hands-on of  utilizing DML/Database. 
 * @author      : Saurav Kumar
 */
public class DMLAssignment {

    /**
     * @description : Insert and link the one opportunity with all those accounts records(which are present in your salesforce org) who do not have any opportunities linked to them. Note: Inserted opportunity’s name should first have an account name in it then append ‘First Opportunity’ in it.
     * @author      : Saurav Kumar
     */
    public static void createOpportunitiesWithoutLinks(){
        List<Opportunity> opportunityToInsert = new List<Opportunity>();
        for(Account acc : [SELECT Id, Name, (SELECT Id, Name FROM Opportunities) FROM Account]){
            if(acc.Opportunities == NULL){
                Opportunity opp = new Opportunity();
                opp.Name = acc.Name + ' First Opportunity';
                opp.CloseDate = Date.Today() + 30;
                opp.StageName = 'Prospecting';
                opp.AccountId = acc.Id;
                opportunityToInsert.add(opp);
            }
        }
        
        if(!opportunityToInsert.isEmpty()){
            Database.insert(opportunityToInsert, false);
        }
    }
    
    
    /**
     * @description : First insert account and contact related to it then delete it,then Undelete those records of Account object.
     * @author      : Saurav Kumar
     */
    public static void manipulateAccountAndContact() {
        Account acc = new Account();
        acc.Name = 'Unive Container';
        Insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Carter last';
        con.AccountId = acc.Id;
        
        Delete acc;
        
        undelete acc;
    }
   
    
    /**
     * @description : Insert Account and Contact record in one insert call. Note: Make a company email field ( with API Name: Company_Email__c) of Email type on Account object. It should be an external id, and unique. Use this field to provide the solution to this question.
     * @author      : Saurav Kumar
     */
    public static void insertAccountContactRecords() {
        Account acc = new Account(Company_Email__c = 'testcompany@gmail.com');
        Contact con = new Contact(LastName = 'Doe', Account=acc);
        Account acc1 = new Account(Name = 'Test', Company_Email__c = 'testcompany@gmail.com');
        
        List<sObject> sobj = new List<sObject>{acc1, con};
        
        Database.insert(sobj, false);
    }
    
	/**
     * @description : Insert 5 records in Account object and then create related one or more contact and one or more opportunity to all 5 accounts and add one or more opportunity product to those opportunities.
     * @author      : Saurav Kumar
     */
    public static void insertAndCreateRelatedRecords() {
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<5; i++){
            Account acc = new Account(Name='Test Account '+i);
            accounts.add(acc);
        }
        
        Database.SaveResult[] srList = Database.insert(accounts, false);
        
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        
        for(Database.SaveResult sr : srList){
            if(sr.isSuccess()){
                Contact con = new Contact(LastName = 'Test Contact', AccountId = sr.getId());
                contacts.add(con);
                Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.Today()+30, StageName = 'Prospecting', AccountId = sr.getId());
                opportunities.add(opp);
            }
        }
        
        if(!contacts.isEmpty()){
            Database.insert(contacts, false);
        }
        
        List<Pricebook2> pricebookList = [SELECT Id, Name, IsActive, IsStandard FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
        List<Product2> productList = [SELECT Id, Name FROM Product2 WHERE Name = 'GenWatt Diesel 10kW' LIMIT 1];
        List<PricebookEntry> PricebookEntryList = [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Pricebook2Id =:pricebookList[0].Id AND Product2Id =:productList[0].Id];
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        if(!opportunities.isEmpty()){
            Database.SaveResult[] srList1 = Database.insert(opportunities, false);
            for(Database.SaveResult sr : srList1){
                if(sr.isSuccess()){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = sr.getId();
                oli.PricebookEntryId = PricebookEntryList[0].Id;
                oli.Quantity = 1;
                oli.UnitPrice = PricebookEntryList[0].UnitPrice;
                oliList.add(oli);
                }
            }
        }        
        
        if(!oliList.isEmpty()){
            Database.insert(oliList, false);
        }
        
    }
    
	/**
     * @description : Delete those Accounts who have more than 2 open opportunities and no closed opportunities.
     * @author      : Saurav Kumar
     */
    public static void deleteOpp(){
        
        List<AggregateResult> agrList = [SELECT AccountId, IsClosed, COUNT(Id) cnt FROM Opportunity WHERE AccountId != NULL GROUP BY AccountId, IsClosed];
        
        Map<Id, Integer> accountToOpenOppMap =  new Map<Id, Integer>();
        Map<Id, Integer> accountToCloseOppMap = new Map<Id, Integer>();
        
        for(AggregateResult agr : agrList){
            if(!accountToOpenOppMap.containsKey((Id)agr.get('AccountId'))){
                accountToOpenOppMap.put((Id)agr.get('AccountId'), (Integer)agr.get('cnt'));
            }
            if(!accountToCloseOppMap.containsKey((Id)agr.get('AccountId'))){
                accountToCloseOppMap.put((Id)agr.get('AccountId'), (Integer)agr.get('cnt'));
            }            
        }
        
        List<Account> accountList = [SELECT Id, Name FROM Account WHERE Id IN :accountToOpenOppMap.keySet()];
        
        List<Account> accountToDelete = new List<Account>();
        for(Account acc : accountList){
            if(accountToOpenOppMap.containsKey(acc.Id) && accountToOpenOppMap.get(acc.Id) > 2){
                if(!accountToCloseOppMap.containsKey(acc.Id)){
                    accountToDelete.add(acc);
                }
            }
        }
        
        Database.Delete(accountToDelete, false);
    }

	/**
     * @description : Write a program to get the total number of records present in an object(Object should be passed as an argument) 
     * @author      : Saurav Kumar
     */    
    public static Integer totalRecordsInObject(String objectName) {
        String query = 'SELECT COUNT() total FROM ' + objectName;
        AggregateResult[] results = Database.query(query);
        return (Integer) results[0].get('total');
    }

}