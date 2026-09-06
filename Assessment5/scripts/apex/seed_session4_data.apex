// Create 100 Loan_Account__c records for Default Risk training
List<Customer__c> customers = [SELECT Id FROM Customer__c LIMIT 10];
Id defaultCustId = customers[0].Id;

List<Loan_Account__c> accountsToInsert = new List<Loan_Account__c>();

for (Integer i = 1; i <= 120; i++) {
    Loan_Account__c acc = new Loan_Account__c();
    acc.Customer__c = defaultCustId;
    acc.Loan_Number__c = 'LA-TRAIN-' + String.valueOf(1000 + i);
    
    // Create realistic pattern:
    // Low risk: High credit score (>=720), low bounced EMIs (0), zero/low overdue
    // High risk: Lower credit score (<680), multiple bounced EMIs (>=2), high overdue
    Boolean isHighRisk = (Math.mod(i, 3) == 0); // ~33% high risk, 67% low risk
    
    if (isHighRisk) {
        acc.Default_Risk__c = 'High';
        acc.Risk_Flag__c = 'High';
        acc.Credit_Score_At_Application__c = 580 + Math.mod(i * 7, 90); // 580 - 669
        acc.Bounced_EMI_Count__c = 2 + Math.mod(i, 4); // 2 - 5
        acc.Monthly_Income__c = 25000 + (Math.mod(i, 5) * 5000);
        acc.Total_Overdue_Amount__c = 15000 + (Math.mod(i, 8) * 4000);
        acc.Loan_Status__c = 'Active';
    } else {
        acc.Default_Risk__c = 'Low';
        acc.Risk_Flag__c = 'Low';
        acc.Credit_Score_At_Application__c = 720 + Math.mod(i * 11, 110); // 720 - 829
        acc.Bounced_EMI_Count__c = (Math.mod(i, 7) == 0) ? 1 : 0;
        acc.Monthly_Income__c = 45000 + (Math.mod(i, 10) * 8000);
        acc.Total_Overdue_Amount__c = 0;
        acc.Loan_Status__c = (Math.mod(i, 5) == 0) ? 'Closed' : 'Active';
    }
    
    acc.Loan_Amount__c = 200000 + (Math.mod(i, 15) * 50000);
    acc.Interest_Rate__c = 10.5 + (Math.mod(i, 5) * 1.0);
    acc.Tenure_Months__c = 24 + (Math.mod(i, 4) * 12);
    acc.EMI_Amount__c = (acc.Loan_Amount__c / acc.Tenure_Months__c).setScale(2);
    
    Integer typeIdx = Math.mod(i, 3);
    acc.Loan_Type__c = (typeIdx == 0) ? 'Personal Loan' : (typeIdx == 1 ? 'Home Loan' : 'Vehicle Loan');
    acc.Employment_Type__c = (Math.mod(i, 2) == 0) ? 'Salaried' : 'Self-Employed';
    
    accountsToInsert.add(acc);
}

insert accountsToInsert;
System.debug('Successfully inserted ' + accountsToInsert.size() + ' training Loan_Account__c records!');

// Create 80 approved Loan_Application__c records for Loan Amount Regression training
List<Loan_Application__c> appsToInsert = new List<Loan_Application__c>();

for (Integer j = 1; j <= 80; j++) {
    Loan_Application__c app = new Loan_Application__c();
    app.Customer__c = defaultCustId;
    app.Application_Status__c = 'Approved';
    app.Application_Date__c = Date.today().addDays(-j);
    
    Decimal income = 30000 + (Math.mod(j, 15) * 8000); // 30,000 - 1,42,000
    app.Applicant_Monthly_Income__c = income;
    app.Existing_Monthly_Obligations__c = Math.mod(j, 4) * 5000;
    app.Number_Of_Dependants__c = Math.mod(j, 4);
    app.Tenure_Requested__c = 24 + (Math.mod(j, 5) * 12);
    app.Credit_Score__c = 680 + Math.mod(j * 9, 140); // 680 - 819
    
    Integer appTypeIdx = Math.mod(j, 4);
    app.Loan_Type__c = (appTypeIdx == 0) ? 'Personal Loan' : (appTypeIdx == 1 ? 'Home Loan' : (appTypeIdx == 2 ? 'Auto Loan' : 'Education Loan'));
    
    // Calibrated formula for training: Income * 25-45 multiplier based on credit score
    Decimal multiplier = (app.Credit_Score__c >= 750) ? 40 : 25;
    Decimal amount = (income * multiplier).setScale(2);
    app.Loan_Amount__c = amount;
    app.Predicted_Loan_Amount__c = amount;
    
    appsToInsert.add(app);
}

insert appsToInsert;
System.debug('Successfully inserted ' + appsToInsert.size() + ' training Loan_Application__c records!');