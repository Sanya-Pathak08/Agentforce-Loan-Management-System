Customer__c cust = new Customer__c(
    Name = 'Komal Test Customer', 
    Credit_Score__c = 760, 
    Income__c = 75000, 
    Phone__c = '9876543210', 
    Email__c = 'test@example.com'
);
insert cust;

Loan_Application__c app = new Loan_Application__c(
    Customer__c = cust.Id, 
    Loan_Amount__c = 240000, 
    Loan_Type__c = 'Personal Loan', 
    Credit_Score__c = 760, 
    Application_Status__c = 'Submitted'
);
insert app;

Loan_Application__c updatedApp = [
    SELECT Id, Name, Application_Status__c, Rejection_Reason__c 
    FROM Loan_Application__c 
    WHERE Id = :app.Id
];
System.debug('TEST LOG -> Application Name: ' + updatedApp.Name + ' | Status: ' + updatedApp.Application_Status__c);

List<Loan_Account__c> accounts = [
    SELECT Id, Name, Loan_Amount__c, Tenure_Months__c, EMI_Amount__c, Loan_Status__c 
    FROM Loan_Account__c 
    WHERE Loan_Application__c = :app.Id
];
System.debug('TEST LOG -> Loan Accounts Created: ' + accounts.size());

if (!accounts.isEmpty()) {
    System.debug('TEST LOG -> Loan Account Name: ' + accounts[0].Name + ' | Monthly EMI: ' + accounts[0].EMI_Amount__c);
    List<EMI_Schedule__c> emis = [
        SELECT Id, Name, Due_Date__c, Payment_Status__c 
        FROM EMI_Schedule__c 
        WHERE Loan_Account__c = :accounts[0].Id
    ];
    System.debug('TEST LOG -> Total EMIs Generated: ' + emis.size());
}
