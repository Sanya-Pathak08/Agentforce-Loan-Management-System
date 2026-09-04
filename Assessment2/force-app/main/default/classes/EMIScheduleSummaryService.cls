public with sharing class EMIScheduleSummaryService {

    public class Request {
        @InvocableVariable(required=true description='Unique Loan Account ID')
        public String loanAccountId;
    }

    public class Response {
        @InvocableVariable(description='Total number of EMIs for the loan account')
        public Integer totalEMIs;

        @InvocableVariable(description='Number of paid EMIs')
        public Integer paidEMIs;

        @InvocableVariable(description='Number of pending EMIs')
        public Integer pendingEMIs;

        @InvocableVariable(description='Next EMI due date')
        public Date nextDueDate;

        @InvocableVariable(description='Formatted next EMI due date')
        public String nextdueDate2;
    }

    @InvocableMethod(label='Get EMI Schedule Summary' description='Calculates total, paid, pending EMIs and next due date')
    public static List<Response> getSummary(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            res.totalEMIs = 0;
            res.paidEMIs = 0;
            res.pendingEMIs = 0;
            res.nextDueDate = null;
            res.nextdueDate2 = 'None';

            if (String.isBlank(req.loanAccountId)) {
                responses.add(res);
                continue;
            }

            // Support either Salesforce Id or Loan Account Name (e.g. LACC-00001)
            List<Loan_Account__c> accounts = [
                SELECT Id 
                FROM Loan_Account__c 
                WHERE Id = :req.loanAccountId OR Name = :req.loanAccountId 
                LIMIT 1
            ];

            Id targetAccountId = !accounts.isEmpty() ? accounts[0].Id : null;

            if (targetAccountId == null && req.loanAccountId.length() >= 15) {
                try {
                    targetAccountId = (Id)req.loanAccountId;
                } catch (Exception e) {
                    targetAccountId = null;
                }
            }

            if (targetAccountId != null) {
                List<EMI_Schedule__c> emis = [
                    SELECT Id, Due_Date__c, Payment_Status__c 
                    FROM EMI_Schedule__c 
                    WHERE Loan_Account__c = :targetAccountId 
                    ORDER BY Due_Date__c ASC
                ];

                res.totalEMIs = emis.size();
                for (EMI_Schedule__c emi : emis) {
                    if (emi.Payment_Status__c == 'Paid') {
                        res.paidEMIs++;
                    } else {
                        res.pendingEMIs++;
                        if (res.nextDueDate == null && emi.Due_Date__c != null) {
                            res.nextDueDate = emi.Due_Date__c;
                            res.nextdueDate2 = String.valueOf(emi.Due_Date__c);
                        }
                    }
                }
            }

            responses.add(res);
        }

        return responses;
    }
}