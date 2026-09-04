@isTest
private class LoanDefaultRiskServiceTest {

    @testSetup
    static void setupTestData() {
        Customer__c cust = new Customer__c(Name = 'Risk Test Customer', Income__c = 50000, Credit_Score__c = 750);
        insert cust;

        Loan_Account__c accHigh = new Loan_Account__c(
            Customer__c = cust.Id,
            Loan_Number__c = 'LA-009',
            Default_Risk__c = 'High',
            Risk_Flag__c = 'High',
            Total_Overdue_Amount__c = 25000,
            Bounced_EMI_Count__c = 3,
            Loan_Amount__c = 500000,
            Tenure_Months__c = 36,
            EMI_Amount__c = 15000,
            Loan_Status__c = 'Active'
        );
        insert accHigh;

        Loan_Account__c accLow = new Loan_Account__c(
            Customer__c = cust.Id,
            Loan_Number__c = 'LA-010',
            Default_Risk__c = 'Low',
            Risk_Flag__c = 'Low',
            Total_Overdue_Amount__c = 0,
            Bounced_EMI_Count__c = 0,
            Loan_Amount__c = 300000,
            Tenure_Months__c = 24,
            EMI_Amount__c = 12000,
            Loan_Status__c = 'Active'
        );
        insert accLow;
    }

    @isTest
    static void testHighRiskAccount() {
        LoanDefaultRiskService.Request req = new LoanDefaultRiskService.Request();
        req.loanAccountId = 'LA-009';

        Test.startTest();
        List<LoanDefaultRiskService.Response> responses = LoanDefaultRiskService.checkLoanDefaultRisk(new List<LoanDefaultRiskService.Request>{req});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return 1 response');
        System.assertEquals('High', responses[0].riskLevel, 'Risk level should be High');
        System.assertEquals(78, responses[0].probabilityScore, 'Probability should be 78%');
        System.assert(responses[0].defaultRiskMessage.contains('78%'), 'Message should mention 78%');
    }

    @isTest
    static void testLowRiskAccount() {
        LoanDefaultRiskService.Request req = new LoanDefaultRiskService.Request();
        req.loanAccountId = 'LA-010';

        Test.startTest();
        List<LoanDefaultRiskService.Response> responses = LoanDefaultRiskService.checkLoanDefaultRisk(new List<LoanDefaultRiskService.Request>{req});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return 1 response');
        System.assertEquals('Low', responses[0].riskLevel, 'Risk level should be Low');
    }

    @isTest
    static void testNotFoundAccount() {
        LoanDefaultRiskService.Request req = new LoanDefaultRiskService.Request();
        req.loanAccountId = 'NON-EXISTENT';

        Test.startTest();
        List<LoanDefaultRiskService.Response> responses = LoanDefaultRiskService.checkLoanDefaultRisk(new List<LoanDefaultRiskService.Request>{req});
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return 1 response');
        System.assertEquals('Unknown', responses[0].riskLevel, 'Risk level should be Unknown');
    }
}