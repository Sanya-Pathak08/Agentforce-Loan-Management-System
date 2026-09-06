@isTest
public class EMIScheduleSummaryServiceTest {

    @isTest
    static void testGetSummaryWithEMIs() {
        Loan_Account__c loan = new Loan_Account__c(
            Loan_Amount__c = 120000,
            Tenure_Months__c = 12,
            EMI_Amount__c = 10000,
            Loan_Status__c = 'Active'
        );
        insert loan;

        List<EMI_Schedule__c> emis = new List<EMI_Schedule__c>();
        // 2 paid EMIs
        for (Integer i = 1; i <= 2; i++) {
            emis.add(new EMI_Schedule__c(
                Loan_Account__c = loan.Id,
                EMI_Amount__c = 10000,
                Due_Date__c = Date.today().addMonths(-i),
                Payment_Status__c = 'Paid',
                Payment_Date__c = String.valueOf(Date.today().addMonths(-i))
            ));
        }
        // 10 pending EMIs
        for (Integer i = 1; i <= 10; i++) {
            emis.add(new EMI_Schedule__c(
                Loan_Account__c = loan.Id,
                EMI_Amount__c = 10000,
                Due_Date__c = Date.today().addMonths(i),
                Payment_Status__c = 'Pending',
                Payment_Date__c = 'N/A'
            ));
        }
        insert emis;

        EMIScheduleSummaryService.Request req = new EMIScheduleSummaryService.Request();
        req.loanAccountId = loan.Id;

        Test.startTest();
        List<EMIScheduleSummaryService.Response> results = EMIScheduleSummaryService.getSummary(
            new List<EMIScheduleSummaryService.Request>{req}
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(12, results[0].totalEMIs);
        System.assertEquals(2, results[0].paidEMIs);
        System.assertEquals(10, results[0].pendingEMIs);
        System.assertNotEquals(null, results[0].nextDueDate);
    }

    @isTest
    static void testGetSummaryBlankId() {
        EMIScheduleSummaryService.Request req = new EMIScheduleSummaryService.Request();
        req.loanAccountId = '';

        Test.startTest();
        List<EMIScheduleSummaryService.Response> results = EMIScheduleSummaryService.getSummary(
            new List<EMIScheduleSummaryService.Request>{req}
        );
        Test.stopTest();

        System.assertEquals(0, results[0].totalEMIs);
    }
}