@IsTest
private class GenerateEMIStatementActionTest {

    @TestSetup
    static void setupData() {
        Customer__c cust = new Customer__c(Name = 'Vikram Seth', Credit_Score__c = 750, Income__c = 70000);
        insert cust;

        Loan_Account__c acc = new Loan_Account__c(
            Customer__c = cust.Id,
            Loan_Number__c = 'LA-STMT-01',
            Loan_Amount__c = 400000,
            EMI_Amount__c = 12000,
            Loan_Status__c = 'Active',
            Total_Overdue_Amount__c = 0
        );
        insert acc;

        insert new EMI_Schedule__c(
            Loan_Account__c = acc.Id,
            Due_Date__c = Date.today(),
            EMI_Amount__c = 12000,
            Payment_Status__c = 'Paid',
            Payment_Date__c = '2026-09-01'
        );
    }

    @IsTest
    static void testGenerateStatement() {
        GenerateEMIStatementAction.Request req = new GenerateEMIStatementAction.Request();
        req.loanAccountId = 'LA-STMT-01';

        Test.startTest();
        List<GenerateEMIStatementAction.Response> responses = GenerateEMIStatementAction.generateStatement(new List<GenerateEMIStatementAction.Request>{req});
        Test.stopTest();

        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
        System.assertNotEquals(null, responses[0].downloadUrl);
        System.assert(responses[0].statementSummary.contains('LA-STMT-01'));
    }
}