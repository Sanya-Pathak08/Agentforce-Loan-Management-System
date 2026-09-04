@isTest
private class PredictLoanAmountTest {

    @isTest
    static void testSilverTierSpecificPrediction() {
        PredictLoanAmount.Request req = new PredictLoanAmount.Request();
        req.monthlyIncome = 45000;
        req.creditScore = 715;

        Test.startTest();
        List<PredictLoanAmount.Response> responses = PredictLoanAmount.predictLoanAmount(new List<PredictLoanAmount.Request>{ req });
        Test.stopTest();

        System.assertNotEquals(null, responses, 'Responses should not be null');
        System.assertEquals(1, responses.size(), 'Should have 1 response');
        System.assertEquals(2240000, responses[0].predictedLoanAmount, 'Predicted amount for 45000 and 715 should be 2240000');
        System.assert(responses[0].predictionSummary.contains('good credit score'), 'Summary should mention good credit score');
    }

    @isTest
    static void testGoldTierPrediction() {
        PredictLoanAmount.Request req = new PredictLoanAmount.Request();
        req.monthlyIncome = 60000;
        req.creditScore = 780;

        Test.startTest();
        List<PredictLoanAmount.Response> responses = PredictLoanAmount.predictLoanAmount(new List<PredictLoanAmount.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should have 1 response');
        System.assert(responses[0].predictedLoanAmount > 3600000, 'Gold tier AI estimate should exceed rule-based 3.6M');
    }

    @isTest
    static void testStandardTierPrediction() {
        PredictLoanAmount.Request req = new PredictLoanAmount.Request();
        req.monthlyIncome = 25000;
        req.creditScore = 670;

        Test.startTest();
        List<PredictLoanAmount.Response> responses = PredictLoanAmount.predictLoanAmount(new List<PredictLoanAmount.Request>{ req });
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should have 1 response');
        System.assert(responses[0].predictedLoanAmount > 0, 'Standard tier AI estimate should be greater than 0');
    }

    @isTest
    static void testNotEligiblePrediction() {
        PredictLoanAmount.Request req1 = new PredictLoanAmount.Request();
        req1.monthlyIncome = 15000;
        req1.creditScore = 600;

        PredictLoanAmount.Request req2 = new PredictLoanAmount.Request();
        req2.monthlyIncome = 50000;
        req2.creditScore = 640;

        Test.startTest();
        List<PredictLoanAmount.Response> responses = PredictLoanAmount.predictLoanAmount(new List<PredictLoanAmount.Request>{ req1, req2 });
        Test.stopTest();

        System.assertEquals(2, responses.size(), 'Should have 2 responses');
        System.assertEquals(0, responses[0].predictedLoanAmount, 'Low score/income should predict 0');
        System.assertEquals(0, responses[1].predictedLoanAmount, 'Low score should predict 0');
    }
}
