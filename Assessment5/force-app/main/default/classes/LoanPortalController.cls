public with sharing class LoanPortalController {

    public class LoanAccountSummaryWrapper {
        @AuraEnabled public Loan_Account__c account { get; set; }
        @AuraEnabled public String nextEMIDueDate { get; set; }
        @AuraEnabled public Integer remainingTenureMonths { get; set; }
        @AuraEnabled public Decimal totalOverdueAmount { get; set; }
        @AuraEnabled public Boolean isOverdue { get; set; }
        @AuraEnabled public String statusBannerMessage { get; set; }
        @AuraEnabled public String statusBannerType { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentUserInfo() {
        Map<String, Object> info = new Map<String, Object>();
        info.put('isGuest', Auth.CommunitiesUtil.isGuestUser());
        info.put('userId', UserInfo.getUserId());
        info.put('userName', UserInfo.getName());
        info.put('userType', UserInfo.getUserType());
        return info;
    }

    @AuraEnabled(cacheable=true)
    public static LoanAccountSummaryWrapper getBorrowerLoanAccount(String accountKey) {
        LoanAccountSummaryWrapper wrapper = new LoanAccountSummaryWrapper();
        List<Loan_Account__c> accounts = new List<Loan_Account__c>();

        if (String.isNotBlank(accountKey)) {
            String key = accountKey.trim();
            accounts = [
                SELECT Id, Name, Loan_Number__c, Loan_Amount__c, Interest_Rate__c, Loan_Status__c,
                       Tenure__c, Tenure_Months__c, EMI_Amount__c, Default_Risk__c, Total_Overdue_Amount__c,
                       Customer__c, Customer__r.Name
                FROM Loan_Account__c
                WHERE Id = :key OR Loan_Number__c = :key OR Name = :key OR Customer__r.Name LIKE :('%' + key + '%')
                ORDER BY Total_Overdue_Amount__c DESC
                LIMIT 1
            ];
        }

        if (accounts.isEmpty()) {
            accounts = [
                SELECT Id, Name, Loan_Number__c, Loan_Amount__c, Interest_Rate__c, Loan_Status__c,
                       Tenure__c, Tenure_Months__c, EMI_Amount__c, Default_Risk__c, Total_Overdue_Amount__c,
                       Customer__c, Customer__r.Name
                FROM Loan_Account__c
                ORDER BY Total_Overdue_Amount__c DESC
                LIMIT 1
            ];
        }

        if (!accounts.isEmpty()) {
            Loan_Account__c acc = accounts[0];
            wrapper.account = acc;
            wrapper.totalOverdueAmount = acc.Total_Overdue_Amount__c != null ? acc.Total_Overdue_Amount__c : 0;
            wrapper.isOverdue = (acc.Loan_Status__c == 'Overdue' || wrapper.totalOverdueAmount > 0);

            if (wrapper.isOverdue) {
                wrapper.statusBannerMessage = 'Your loan is overdue. Please contact support immediately.';
                wrapper.statusBannerType = 'warning';
            } else {
                wrapper.statusBannerMessage = 'Your loan is in good standing.';
                wrapper.statusBannerType = 'success';
            }

            List<EMI_Schedule__c> pendingEMIs = [
                SELECT Id, Due_Date__c, EMI_Amount__c, Payment_Status__c
                FROM EMI_Schedule__c
                WHERE Loan_Account__c = :acc.Id AND Payment_Status__c = 'Pending'
                ORDER BY Due_Date__c ASC
            ];

            if (!pendingEMIs.isEmpty() && pendingEMIs[0].Due_Date__c != null) {
                DateTime dt = DateTime.newInstance(pendingEMIs[0].Due_Date__c, Time.newInstance(0, 0, 0, 0));
                wrapper.nextEMIDueDate = dt.format('dd MMM yyyy');
                wrapper.remainingTenureMonths = pendingEMIs.size();
            } else {
                Date nextDue = Date.today().addDays(15);
                DateTime dt = DateTime.newInstance(nextDue, Time.newInstance(0, 0, 0, 0));
                wrapper.nextEMIDueDate = dt.format('dd MMM yyyy');
                wrapper.remainingTenureMonths = acc.Tenure_Months__c != null ? Integer.valueOf(acc.Tenure_Months__c) : 12;
            }
        }

        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<EMI_Schedule__c> getEMISchedules(String loanAccountId) {
        if (String.isBlank(loanAccountId)) {
            LoanAccountSummaryWrapper def = getBorrowerLoanAccount('');
            if (def != null && def.account != null) {
                loanAccountId = def.account.Id;
            }
        }

        if (String.isNotBlank(loanAccountId)) {
            return [
                SELECT Id, Name, Due_Date__c, EMI_Amount__c, Payment_Status__c, Payment_Date__c, Loan_Account__c
                FROM EMI_Schedule__c
                WHERE Loan_Account__c = :loanAccountId OR Loan_Account__r.Loan_Number__c = :loanAccountId
                ORDER BY Due_Date__c ASC
            ];
        }

        return new List<EMI_Schedule__c>();
    }

    @AuraEnabled
    public static Map<String, Object> submitLoanApplication(Map<String, Object> applicationData) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            Loan_Application__c app = new Loan_Application__c();
            if (applicationData.containsKey('loanType')) {
                app.Loan_Type__c = String.valueOf(applicationData.get('loanType'));
            }
            if (applicationData.containsKey('loanAmount') && applicationData.get('loanAmount') != null) {
                app.Loan_Amount__c = Decimal.valueOf(String.valueOf(applicationData.get('loanAmount')));
            }
            if (applicationData.containsKey('tenureRequested') && applicationData.get('tenureRequested') != null) {
                app.Tenure_Requested__c = Decimal.valueOf(String.valueOf(applicationData.get('tenureRequested')));
            }
            if (applicationData.containsKey('monthlyIncome') && applicationData.get('monthlyIncome') != null) {
                app.Applicant_Monthly_Income__c = Decimal.valueOf(String.valueOf(applicationData.get('monthlyIncome')));
            }
            if (applicationData.containsKey('existingObligations') && applicationData.get('existingObligations') != null) {
                app.Existing_Monthly_Obligations__c = Decimal.valueOf(String.valueOf(applicationData.get('existingObligations')));
            }
            if (applicationData.containsKey('dependants') && applicationData.get('dependants') != null) {
                app.Number_Of_Dependants__c = Decimal.valueOf(String.valueOf(applicationData.get('dependants')));
            }
            if (applicationData.containsKey('creditScore') && applicationData.get('creditScore') != null) {
                app.Credit_Score__c = Decimal.valueOf(String.valueOf(applicationData.get('creditScore')));
            }

            app.Application_Status__c = 'Submitted';
            insert app;

            Loan_Application__c createdApp = [SELECT Id, Name FROM Loan_Application__c WHERE Id = :app.Id LIMIT 1];

            response.put('isSuccess', true);
            response.put('recordId', createdApp.Id);
            response.put('applicationNumber', createdApp.Name);
            response.put('message', 'Your application has been submitted. A loan specialist will contact you within 24 hours.');
        } catch (Exception e) {
            response.put('isSuccess', false);
            response.put('message', 'Error submitting application: ' + e.getMessage());
        }

        return response;
    }
}