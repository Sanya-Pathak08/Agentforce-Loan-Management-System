@IsTest
private class LoanPortalControllerTest {

    @TestSetup
    static void setupTestData() {
        Customer__c cust = new Customer__c(
            Name = 'Anil Verma',
            Credit_Score__c = 730,
            Income__c = 60000,
            Eligibility_Tier__c = 'Silver',
            Preferred_Loan_Type__c = 'Personal Loan'
        );
        insert cust;

        Loan_Account__c acc = new Loan_Account__c(
            Customer__c = cust.Id,
            Loan_Number__c = 'LA-PORTAL-01',
            Loan_Amount__c = 500000,
            EMI_Amount__c = 15000,
            Total_Overdue_Amount__c = 30000,
            Loan_Status__c = 'Overdue',
            Bounced_EMI_Count__c = 2,
            Tenure_Months__c = 36,
            Interest_Rate__c = 11.5
        );
        insert acc;

        List<EMI_Schedule__c> emis = new List<EMI_Schedule__c>{
            new EMI_Schedule__c(
                Loan_Account__c = acc.Id,
                Due_Date__c = Date.today().addMonths(-1),
                EMI_Amount__c = 15000,
                Payment_Status__c = 'Paid',
                Payment_Date__c = '2026-08-05'
            ),
            new EMI_Schedule__c(
                Loan_Account__c = acc.Id,
                Due_Date__c = Date.today(),
                EMI_Amount__c = 15000,
                Payment_Status__c = 'Overdue'
            ),
            new EMI_Schedule__c(
                Loan_Account__c = acc.Id,
                Due_Date__c = Date.today().addMonths(1),
                EMI_Amount__c = 15000,
                Payment_Status__c = 'Pending'
            )
        };
        insert emis;
    }

    @IsTest
    static void testGetBorrowerLoanAccount() {
        Test.startTest();
        LoanPortalController.LoanAccountSummaryWrapper wrapper = LoanPortalController.getBorrowerLoanAccount('LA-PORTAL-01');
        Test.stopTest();

        System.assertNotEquals(null, wrapper);
        System.assertNotEquals(null, wrapper.account);
        System.assertEquals('LA-PORTAL-01', wrapper.account.Loan_Number__c);
        System.assertEquals(true, wrapper.isOverdue);
        System.assert(wrapper.statusBannerMessage.contains('overdue'));
    }

    @IsTest
    static void testGetEMISchedules() {
        Loan_Account__c acc = [SELECT Id FROM Loan_Account__c WHERE Loan_Number__c = 'LA-PORTAL-01' LIMIT 1];

        Test.startTest();
        List<EMI_Schedule__c> listEmis = LoanPortalController.getEMISchedules(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, listEmis);
        System.assertEquals(3, listEmis.size());
    }

    @IsTest
    static void testSubmitLoanApplication() {
        Map<String, Object> appData = new Map<String, Object>{
            'loanType' => 'Personal Loan',
            'loanAmount' => 300000,
            'tenureRequested' => 24,
            'monthlyIncome' => 55000,
            'existingObligations' => 5000,
            'dependants' => 2,
            'creditScore' => 740
        };

        Test.startTest();
        Map<String, Object> result = LoanPortalController.submitLoanApplication(appData);
        Test.stopTest();

        System.assertEquals(true, result.get('isSuccess'));
        System.assertNotEquals(null, result.get('recordId'));
    }
}