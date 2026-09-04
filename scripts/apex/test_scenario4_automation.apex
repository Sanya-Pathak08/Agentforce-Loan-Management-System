Customer__c cust = [SELECT Id, Eligibility_Tier__c FROM Customer__c WHERE Id = 'a0ANS00000DQUqz2AH'];
cust.Eligibility_Tier__c = 'Silver';
update cust;

Loan_Account__c acc = [SELECT Id, Name, Risk_Flag__c, AI_Account_Summary__c, Last_Summary_Generated__c, Total_Overdue_Amount__c FROM Loan_Account__c WHERE Id = 'a0CNS00002oTvkg2AC'];
System.debug('BEFORE UPDATE: Risk_Flag__c=' + acc.Risk_Flag__c + ', AI_Account_Summary__c=' + acc.AI_Account_Summary__c + ', Last_Summary=' + acc.Last_Summary_Generated__c);

acc.Total_Overdue_Amount__c = 0;
acc.Risk_Flag__c = 'Medium';
update acc;

// Query again to verify Auto_Refresh flow executed
Loan_Account__c accAfter = [SELECT Id, Name, Risk_Flag__c, AI_Account_Summary__c, Last_Summary_Generated__c FROM Loan_Account__c WHERE Id = 'a0CNS00002oTvkg2AC'];
System.debug('AFTER UPDATE: Risk_Flag__c=' + accAfter.Risk_Flag__c + ', AI_Account_Summary__c=' + accAfter.AI_Account_Summary__c + ', Last_Summary=' + accAfter.Last_Summary_Generated__c);
