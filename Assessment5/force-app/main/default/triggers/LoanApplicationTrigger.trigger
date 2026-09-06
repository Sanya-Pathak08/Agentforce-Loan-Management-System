trigger LoanApplicationTrigger on Loan_Application__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        List<Loan_Application__c> toProcess = new List<Loan_Application__c>();
        for (Loan_Application__c app : Trigger.new) {
            Loan_Application__c oldApp = Trigger.isUpdate ? Trigger.oldMap.get(app.Id) : null;
            if (app.Application_Status__c == 'Submitted' && (oldApp == null || oldApp.Application_Status__c != 'Submitted')) {
                toProcess.add(app);
            }
        }
        if (!toProcess.isEmpty()) {
            LoanApplicationProcessingService.processSubmittedApplications(toProcess);
        }
    }
    else if (Trigger.isAfter) {
        List<Loan_Application__c> approved = new List<Loan_Application__c>();
        for (Loan_Application__c app : Trigger.new) {
            Loan_Application__c oldApp = Trigger.isUpdate ? Trigger.oldMap.get(app.Id) : null;
            if (app.Application_Status__c == 'Approved' && (oldApp == null || oldApp.Application_Status__c != 'Approved')) {
                approved.add(app);
            }
        }
        if (!approved.isEmpty()) {
            LoanApplicationProcessingService.createLoanAccountsAndEMIs(approved);
        }
    }
}