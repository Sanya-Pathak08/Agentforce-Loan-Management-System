// Check if LA-00078 already exists
List<Loan_Application__c> existing = [SELECT Id, Name FROM Loan_Application__c WHERE Name = 'LA-00078'];
if (!existing.isEmpty()) {
    System.debug('LA-00078 already exists: ' + existing[0].Id);
    Loan_Application__c app = existing[0];
    app.Application_Status__c = 'Rejected';
    app.Credit_Score__c = 610;
    app.Rejection_Category__c = 'Low Credit Score';
    app.Loan_Type__c = 'Personal Loan';
    app.Loan_Amount__c = 500000;
    app.Application_Notes__c = 'Applicant credit score is below required minimum of 650 with multiple recent inquiries.';
    update app;
    System.debug('LA-00078 updated successfully');
} else {
    // Determine how many dummy records are needed to reach LA-00078
    // Currently highest is LA-00001 (1)
    List<Loan_Application__c> latest = [SELECT Name FROM Loan_Application__c ORDER BY CreatedDate DESC LIMIT 1];
    Integer currentNum = 1;
    if (!latest.isEmpty()) {
        String numStr = latest[0].Name.replace('LA-', '');
        currentNum = Integer.valueOf(numStr);
    }
    System.debug('Current highest number: ' + currentNum);
    Integer needed = 78 - currentNum - 1; // records to insert before 78
    System.debug('Needed dummy records: ' + needed);
    
    if (needed > 0) {
        List<Loan_Application__c> dummyList = new List<Loan_Application__c>();
        for (Integer i = 0; i < needed; i++) {
            dummyList.add(new Loan_Application__c(
                Application_Status__c = 'Draft',
                Loan_Type__c = 'Personal Loan',
                Loan_Amount__c = 10000
            ));
        }
        insert dummyList;
        System.debug('Inserted ' + dummyList.size() + ' dummy records');
        delete dummyList;
        System.debug('Deleted dummy records');
    }
    
    // Now insert the actual LA-00078 record
    Loan_Application__c targetApp = new Loan_Application__c(
        Application_Status__c = 'Rejected',
        Credit_Score__c = 610,
        Rejection_Category__c = 'Low Credit Score',
        Loan_Type__c = 'Personal Loan',
        Loan_Amount__c = 500000,
        Application_Notes__c = 'Applicant credit score is below required minimum of 650 with multiple recent inquiries.'
    );
    insert targetApp;
    targetApp = [SELECT Id, Name, Application_Status__c, Credit_Score__c, Rejection_Category__c, Loan_Type__c, Loan_Amount__c FROM Loan_Application__c WHERE Id = :targetApp.Id];
    System.debug('Target record created: ' + targetApp.Name + ' (Id: ' + targetApp.Id + ')');
}
