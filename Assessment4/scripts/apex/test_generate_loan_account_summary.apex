Map<String, Object> inputs = new Map<String, Object>{
    'loanAccountId' => 'LA-009'
};
Flow.Interview.Generate_Loan_Account_Summary interview = new Flow.Interview.Generate_Loan_Account_Summary(inputs);
interview.start();

String summary = (String) interview.getVariableValue('accountSummary');
System.debug('=== GENERATED LOAN ACCOUNT SUMMARY FOR LA-009 ===');
System.debug(summary);

// Verify record fields
Loan_Account__c acc = [SELECT Id, Name, Loan_Number__c, AI_Account_Summary__c, Last_Summary_Generated__c FROM Loan_Account__c WHERE Loan_Number__c = 'LA-009'];
System.debug('=== RECORD VERIFICATION ===');
System.debug('Id: ' + acc.Id);
System.debug('Name: ' + acc.Name);
System.debug('Last Summary Generated: ' + acc.Last_Summary_Generated__c);
System.debug('AI Summary Length: ' + (acc.AI_Account_Summary__c != null ? acc.AI_Account_Summary__c.length() : 0));
