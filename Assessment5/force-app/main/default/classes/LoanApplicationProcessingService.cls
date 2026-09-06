public with sharing class LoanApplicationProcessingService {

    public static void processSubmittedApplications(List<Loan_Application__c> apps) {
        List<Loan_Application__c> toApprove = new List<Loan_Application__c>();
        List<Loan_Application__c> toReject = new List<Loan_Application__c>();

        for (Loan_Application__c app : apps) {
            if (app.Credit_Score__c != null && app.Credit_Score__c >= 700) {
                toApprove.add(app);
            } else {
                toReject.add(app);
            }
        }

        // Handle Rejections
        for (Loan_Application__c app : toReject) {
            app.Application_Status__c = 'Rejected';
            if (String.isBlank(app.Rejection_Reason__c)) {
                app.Rejection_Reason__c = 'Credit score is below the minimum required threshold of 700.';
            }
        }

        // Handle Approvals
        List<Loan_Account__c> accountsToInsert = new List<Loan_Account__c>();
        Map<Id, Loan_Application__c> appMap = new Map<Id, Loan_Application__c>();

        for (Loan_Application__c app : toApprove) {
            app.Application_Status__c = 'Approved';
            app.Rejection_Reason__c = null;
        }
    }

    public static void createLoanAccountsAndEMIs(List<Loan_Application__c> approvedApps) {
        List<Loan_Account__c> accountsToInsert = new List<Loan_Account__c>();

        for (Loan_Application__c app : approvedApps) {
            Integer tenure = 12;
            Decimal principal = app.Loan_Amount__c != null ? app.Loan_Amount__c : 100000;
            Decimal emi = (principal / tenure).setScale(2, RoundingMode.HALF_UP);

            Loan_Account__c acc = new Loan_Account__c(
                Customer__c = app.Customer__c,
                Loan_Application__c = app.Id,
                Loan_Amount__c = principal,
                Interest_Rate__c = 10.5,
                Tenure_Months__c = tenure,
                EMI_Amount__c = emi,
                Loan_Status__c = 'Active'
            );
            accountsToInsert.add(acc);
        }

        if (!accountsToInsert.isEmpty()) {
            insert accountsToInsert;

            List<EMI_Schedule__c> emisToInsert = new List<EMI_Schedule__c>();
            for (Loan_Account__c acc : accountsToInsert) {
                for (Integer i = 1; i <= acc.Tenure_Months__c; i++) {
                    emisToInsert.add(new EMI_Schedule__c(
                        Loan_Account__c = acc.Id,
                        EMI_Amount__c = acc.EMI_Amount__c,
                        Due_Date__c = Date.today().addMonths(i),
                        Payment_Status__c = 'Pending',
                        Payment_Date__c = 'N/A'
                    ));
                }
            }

            if (!emisToInsert.isEmpty()) {
                insert emisToInsert;
            }
        }
    }
}