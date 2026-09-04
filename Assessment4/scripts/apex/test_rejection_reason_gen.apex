// Test execution of Generate_Loan_Rejection_Reason flow
System.debug('=== EXECUTING REJECTION REASON FLOW FOR LA-00078 ===');

Map<String, Object> inputs = new Map<String, Object>{
    'loanApplicationId' => 'LA-00078'
};

Flow.Interview.Generate_Loan_Rejection_Reason flow = new Flow.Interview.Generate_Loan_Rejection_Reason(inputs);
flow.start();

String suggestion = (String) flow.getVariableValue('varSuggestionText');
System.debug('FLOW OUTPUT varSuggestionText: ' + suggestion);

Loan_Application__c app = [
    SELECT Id, Name, Application_Status__c, Credit_Score__c, Rejection_Category__c,
           Loan_Type__c, Loan_Amount__c, AI_Rejection_Suggestion__c, Application_Notes__c
    FROM Loan_Application__c
    WHERE Name = 'LA-00078'
    LIMIT 1
];

System.debug('-------------------------------------------');
System.debug('Record: ' + app.Name + ' (' + app.Id + ')');
System.debug('Status: ' + app.Application_Status__c);
System.debug('Credit Score: ' + app.Credit_Score__c);
System.debug('Category: ' + app.Rejection_Category__c);
System.debug('Type: ' + app.Loan_Type__c);
System.debug('Amount: ' + app.Loan_Amount__c);
System.debug('AI_Rejection_Suggestion__c: ' + app.AI_Rejection_Suggestion__c);
System.debug('=== FLOW TEST COMPLETED ===');
