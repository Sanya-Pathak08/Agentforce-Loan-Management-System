@IsTest
private class Borrower360ServiceTest {

    @TestSetup
    static void setupData() {
        Customer__c cust = new Customer__c(
            Name = 'Pooja Patel',
            Credit_Score__c = 780,
            Income__c = 85000,
            Eligibility_Tier__c = 'Gold',
            Preferred_Loan_Type__c = 'Home Loan'
        );
        insert cust;

        Loan_Account__c acc = new Loan_Account__c(
            Customer__c = cust.Id,
            Loan_Number__c = 'LA-TEST-360',
            Loan_Amount__c = 2500000,
            EMI_Amount__c = 32000,
            Total_Overdue_Amount__c = 0,
            Loan_Status__c = 'Active',
            Bounced_EMI_Count__c = 0,
            Tenure_Months__c = 120,
            Interest_Rate__c = 8.5
        );
        insert acc;
    }

    @IsTest
    static void testGetBorrower360ProfileByName() {
        Borrower360Service.Request req = new Borrower360Service.Request();
        req.customerIdentifier = 'Pooja Patel';

        Test.startTest();
        List<Borrower360Service.Response> responses = Borrower360Service.getBorrower360Profile(new List<Borrower360Service.Request>{req});
        Test.stopTest();

        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
        System.assertEquals('Pooja Patel', responses[0].borrowerName);
        System.assertEquals('Gold', responses[0].eligibilityTier);
        System.assert(responses[0].profileSummary.contains('Pooja Patel'));
    }

    @IsTest
    static void testGetBorrowerProfileByAccount() {
        Test.startTest();
        Borrower360Service.Response res = Borrower360Service.getBorrowerProfile('LA-TEST-360');
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals('Pooja Patel', res.borrowerName);
    }

    @IsTest
    static void testEmptyIdentifier() {
        Borrower360Service.Request req = new Borrower360Service.Request();
        req.customerIdentifier = '';

        Test.startTest();
        List<Borrower360Service.Response> responses = Borrower360Service.getBorrower360Profile(new List<Borrower360Service.Request>{req});
        Test.stopTest();

        System.assertNotEquals(null, responses);
        System.assertEquals(1, responses.size());
    }
}