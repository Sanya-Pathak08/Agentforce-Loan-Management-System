public with sharing class LoanEligibilityCalculator {

    public class Request {
        @InvocableVariable(required=true)
        public Decimal monthlyIncome;

        @InvocableVariable(required=true)
        public Integer creditScore;
    }

    public class Response {
        @InvocableVariable
        public Decimal maxLoanAmount;

        @InvocableVariable
        public String eligibilityTier;
    }

    @InvocableMethod(label='Calculate Loan Eligibility' description='Calculates loan eligibility based on income and credit score')
    public static List<Response> calculateEligibility(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();

            Decimal income = req.monthlyIncome;
            Integer score = req.creditScore;

            // Default values
            res.maxLoanAmount = 0;
            res.eligibilityTier = 'Not Eligible';

            if (score >= 750 && income >= 50000) {
                res.eligibilityTier = 'Gold';
                res.maxLoanAmount = income * 60;
            }
            else if (score >= 700 && score <= 749 && income >= 30000) {
                res.eligibilityTier = 'Silver';
                res.maxLoanAmount = income * 40;
            }
            else if (score >= 650 && score <= 699 && income >= 20000) {
                res.eligibilityTier = 'Standard';
                res.maxLoanAmount = income * 20;
            }
            else {
                res.eligibilityTier = 'Not Eligible';
                res.maxLoanAmount = 0;
            }

            responses.add(res);
        }

        return responses;
    }
}