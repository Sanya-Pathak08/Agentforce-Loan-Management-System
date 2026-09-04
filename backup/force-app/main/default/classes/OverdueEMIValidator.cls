public with sharing class OverdueEMIValidator {

    public class Request {
        @InvocableVariable(required=true)
        public String loanAccountId;
    }

    public class Response {
        @InvocableVariable
        public Integer overdueCount;

        @InvocableVariable
        public Decimal totalOverdueAmount;

        @InvocableVariable
        public String overdueMessage;
    }

    @InvocableMethod(label='Validate and Flag Overdue EMIs' description='Finds overdue EMIs, updates status, and returns summary')
    public static List<Response> flagOverdueEMIs(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for (Request req : requests) {

            Response res = new Response();
            res.overdueCount = 0;
            res.totalOverdueAmount = 0;
            res.overdueMessage = 'No overdue EMIs found.';

            // 🔹 Validate input
            if (String.isBlank(req.loanAccountId)) {
                responses.add(res);
                continue;
            }

            // 🔹 SAFE QUERY (No QueryException)
            List<Loan_Account__c> loanList = [
                SELECT Id, Loan_Amount__c, Tenure_Months__c
                FROM Loan_Account__c
                WHERE Id = :req.loanAccountId
                LIMIT 1
            ];

            if (loanList.isEmpty()) {
                res.overdueMessage = 'No loan account found.';
                responses.add(res);
                continue;
            }

            Loan_Account__c loan = loanList[0];

            // 🔹 Calculate EMI (derived)
            Decimal emiAmount = 0;
            if (loan.Tenure_Months__c != null && loan.Tenure_Months__c != 0) {
                emiAmount = loan.Loan_Amount__c / loan.Tenure_Months__c;
            }

            // 🔹 Get overdue EMIs
            List<EMI_Schedule__c> overdueList = [
                SELECT Id, Due_Date__c, Payment_Status__c
                FROM EMI_Schedule__c
                WHERE Loan_Account__c = :req.loanAccountId
                AND Payment_Status__c = 'Pending'
                AND Due_Date__c < :Date.today()
            ];

            if (!overdueList.isEmpty()) {

                Decimal total = 0;

                for (EMI_Schedule__c emi : overdueList) {
                    emi.Payment_Status__c = 'Overdue';
                    total += emiAmount;
                }

                update overdueList;

                res.overdueCount = overdueList.size();
                res.totalOverdueAmount = total;
                res.overdueMessage = 'You have ' + res.overdueCount +
                    ' overdue EMI(s) totalling INR ' + total +
                    '. Please clear them to avoid penalties.';
            }

            responses.add(res);
        }

        return responses;
    }
}