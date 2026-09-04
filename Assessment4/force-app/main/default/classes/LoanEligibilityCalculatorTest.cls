@isTest
public class LoanEligibilityCalculatorTest {

    @isTest
    static void testGoldTierEligibility() {
        LoanEligibilityCalculator.Request req = new LoanEligibilityCalculator.Request();
        req.monthlyIncome = 60000;
        req.creditScore = 780;

        List<LoanEligibilityCalculator.Response> result =
            LoanEligibilityCalculator.calculateEligibility(
                new List<LoanEligibilityCalculator.Request>{req}
            );

        System.assertEquals('Gold', result[0].eligibilityTier);
        System.assertEquals(3600000, result[0].maxLoanAmount);
    }

    @isTest
    static void testNotEligible() {
        LoanEligibilityCalculator.Request req = new LoanEligibilityCalculator.Request();
        req.monthlyIncome = 15000;
        req.creditScore = 600;

        List<LoanEligibilityCalculator.Response> result =
            LoanEligibilityCalculator.calculateEligibility(
                new List<LoanEligibilityCalculator.Request>{req}
            );

        System.assertEquals('Not Eligible', result[0].eligibilityTier);
        System.assertEquals(0, result[0].maxLoanAmount);
    }

    @isTest
    static void testSilverTier() {
        LoanEligibilityCalculator.Request req = new LoanEligibilityCalculator.Request();
        req.monthlyIncome = 35000;
        req.creditScore = 720;

        List<LoanEligibilityCalculator.Response> result =
            LoanEligibilityCalculator.calculateEligibility(
                new List<LoanEligibilityCalculator.Request>{req}
            );

        System.assertEquals('Silver', result[0].eligibilityTier);
        System.assertEquals(1400000, result[0].maxLoanAmount);
    }
}