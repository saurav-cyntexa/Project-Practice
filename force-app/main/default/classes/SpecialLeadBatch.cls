global class SpecialLeadBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Integer specialLeadCount = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // only process recent leads and existing special leads (keeps job selective)
        DateTime since = System.now().addDays(-1);
        return Database.getQueryLocator(
            [SELECT Id, Name, Industry, Company, City__c, Company_Size__c, Special_Lead__c, Referral_Person_Email__c, OwnerId, LastModifiedDate, LastModifiedById 
             FROM Lead
             WHERE (CreatedDate >= :since OR LastModifiedDate >= :since OR Special_Lead__c = TRUE)
            ]
        );
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        System.debug('Batch execution started for ' + scope.size() + ' Leads.');
        
        // collect user ids (owners + editors)
        Set<Id> userIds = new Set<Id>();
        for (Lead l : scope) {
            userIds.add(l.OwnerId);
            userIds.add(l.LastModifiedById);
        }
        
        Map<Id, User> usersById = new Map<Id, User>();
        if (!userIds.isEmpty()) {
            usersById = new Map<Id, User>([SELECT Id, Email, Name, IsActive, CreatedDate, LastLoginDate, ManagerId FROM User WHERE Id IN :userIds]);
            System.debug('Loaded Users: ' + usersById);
        }
        
        Set<String> batchKeys = new Set<String>();
        for(Lead l : scope) {
            if(!l.Special_Lead__c && l.Company != null && l.Email != null && l.City__c != null && l.Industry != null) {
                Integer atIdx = l.Email.indexOf('@');
                String domain = l.Email.substring(atIdx).toLowerCase();
                String key = l.Company.toLowerCase() + '|' + domain + '|' + l.City__c.toLowerCase() + '|' + l.Industry.toLowerCase();
                batchKeys.add(key);
            }
        }

        Map<String, Id> existingSpecialLeads = new Map<String, Id>();
        if(!batchKeys.isEmpty()) {
            for(Lead l : [SELECT Id, Company, Email, City__c, Industry FROM Lead WHERE Special_Lead__c = TRUE AND Company != NULL AND Email != NULL AND City__c != NULL AND Industry != NULL]) {
                Integer atIdx = l.Email.indexOf('@');
                String domain = l.Email.substring(atIdx).toLowerCase();
                String key = l.Company.toLowerCase() + '|' + domain + '|' + l.City__c.toLowerCase() + '|' + l.Industry.toLowerCase();
                existingSpecialLeads.put(key, l.Id);
            }
        }

        
        DateTime ownerActiveCutoff = System.now().addDays(-25);
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
        
        Map<Id, Id> leadToManager = new Map<Id, Id>();
        
        String convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1].MasterLabel;
		
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        
        for (Lead l : scope) {
            Integer vowelCount = VowelCounter.countVowels(l.Company);
            System.debug('Lead Id: ' + l.Id + ', Company: ' + l.Company + ', Vowels: ' + vowelCount);
            
            if (!l.Special_Lead__c) {
                User owner = usersById.get(l.OwnerId);
				Boolean ownerActive = (owner.LastLoginDate != null && owner.LastLoginDate >= System.now().addDays(-25));

                if ((l.Company_Size__c != null && l.Company_Size__c > 500) && (l.City__c != null && l.City__c == 'Tier-I') && (vowelCount >= 2) && ownerActive) {
                    Integer atIdx = l.Email.indexOf('@');
                    String domain = l.Email.substring(atIdx).toLowerCase();
                    String key = l.Company.toLowerCase() + '|' + domain + '|' + l.City__c.toLowerCase() + '|' + l.Industry.toLowerCase();
                    
                    if(!existingSpecialLeads.containsKey(key)) {
                        l.Special_Lead__c = true;
                        leadsToUpdate.add(l);
                        specialLeadCount++;
                        System.debug('Lead Id ' + l.Id + ' marked as Special Lead.');
                    }
                }
            } 
            else {
                Integer daysNotModified = l.LastModifiedDate.date().daysBetween(Date.today());
                System.debug('Lead Id: ' + l.Id + ' is Special Lead, daysNotModified: ' + daysNotModified);
                
                if (daysNotModified >= 5) {
                    System.debug('Lead Id ' + l.Id + ' is stale, preparing conversion.');
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(l.Id);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setConvertedStatus(convertedStatus);
                    lc.setOwnerId(l.OwnerId);
                    converts.add(lc);
                    
                    if (usersById.containsKey(l.OwnerId) && usersById.get(l.OwnerId).ManagerId != null) {
                        leadToManager.put(l.Id, usersById.get(l.OwnerId).ManagerId);
                    }
                } else {
                    User editor = usersById.get(l.LastModifiedById);
                    if (editor != null && editor.ManagerId != null) {
                        System.debug('Submitting approval for Lead Id: ' + l.Id + ' by editor: ' + editor.Name + ', Manager: ' + usersById.get(editor.ManagerId).Name);
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(l.Id);
                        req.setSubmitterId(editor.Id);
                        req.setNextApproverIds(new Id[] { editor.ManagerId });
                        approvalRequests.add(req);
                        l.Lead_Status__c = 'Submitted For Approval';
                        leadsToUpdate.add(l);
                    }else{
                        l.Lead_Status__c = 'Not Submitted For Approval';
                        leadsToUpdate.add(l);                        
                    }
                }
            }
        }
        if (!approvalRequests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(approvalRequests);

            for (Approval.ProcessResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Record ' + result.getInstanceId() + ' submitted for approval successfully. New status: ' + result.getInstanceStatus());
                } else {
                    System.debug('Error submitting record ' + result.getInstanceId() + ' for approval: ' + result.getErrors());
                }
            }
        }
        
        if (!leadsToUpdate.isEmpty()) {
            System.debug('Updating ' + leadsToUpdate.size() + ' Leads.');
            update leadsToUpdate;
        }
        
        if (!converts.isEmpty()) {
            System.debug('Converting ' + converts.size() + ' Leads.');
            List<Database.LeadConvertResult> results = Database.convertLead(converts, false);
            List<Opportunity> oppsToInsert = new List<Opportunity>();
            
            for (Database.LeadConvertResult r : results) {
                if (r.isSuccess()) {
                    Id leadId = r.getLeadId();
                    Id accountId = r.getAccountId();
                    Id mgrId = leadToManager.get(leadId);
                    System.debug('Lead ' + leadId + ' converted. AccountId: ' + accountId + ', ManagerId: ' + mgrId);
                    if (accountId != null && mgrId != null) {
                        Opportunity o = new Opportunity(
                            Name = 'AutoConv - ' + String.valueOf(leadId),
                            AccountId = accountId,
                            CloseDate = Date.today().addDays(30),
                            StageName = 'Prospecting',
                            OwnerId = mgrId
                        );
                        oppsToInsert.add(o);
                        System.debug('Opportunity created for Lead ' + leadId + ' with Manager owner ' + mgrId);
                    }
                } else {
                    System.debug('Convert failed for Lead: ' + r.getLeadId() + ' errors: ' + r.getErrors());
                }
            }
            
            if (!oppsToInsert.isEmpty()) {
                System.debug('Inserting ' + oppsToInsert.size() + ' Opportunities.');
                insert oppsToInsert;
            }
        }
        
        System.debug('Batch execution finished for current scope.');
    }
    
	global void finish(Database.BatchableContext bc) {
        // Use aggregate to compute referral counts (scalable)
        List<AggregateResult> aggs = [
            SELECT Referral_Person_Email__c email, COUNT(Id) cnt
            FROM Lead
            WHERE Special_Lead__c = TRUE AND Referral_Person_Email__c != NULL
            GROUP BY Referral_Person_Email__c
        ];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        // 1) Email to Admins / Managers (example selection: active managers AND sysadmins)
        List<User> notifyUsers = [
            SELECT Id, Name, Email
            FROM User
            WHERE IsActive = true
            AND (Profile.Name = 'System Administrator' OR UserRole.Name = 'Manager')
        ];

        for (User u : notifyUsers) {
            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
            m.setToAddresses(new String[] { u.Email });
            m.setSubject('Special Leads identified');
            m.setPlainTextBody('We identified ' + specialLeadCount + ' special leads today.');
            mails.add(m);
        }

        // 2) Emails to referral persons (one email per referrer)
        for (AggregateResult ar : aggs) {
            String email = (String) ar.get('email');
            Integer cnt = Integer.valueOf(String.valueOf(ar.get('cnt')));
            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
            m.setToAddresses(new String[] { email });
            m.setSubject('Your referrals identified as Special Lead(s)');
            m.setPlainTextBody('Thanks — ' + cnt + ' of your referrals are marked as Special Leads.');
            mails.add(m);
        }

        if (!mails.isEmpty()) {
            // send once (one transaction) — reduces sendEmail invocations and helps stay within limits
            Messaging.sendEmail(mails);
        }
    }

}