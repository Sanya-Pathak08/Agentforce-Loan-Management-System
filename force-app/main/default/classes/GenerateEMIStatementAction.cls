public with sharing class GenerateEMIStatementAction {

    public class Request {
        @InvocableVariable(label='Loan Account ID or Number' required=false)
        public String loanAccountId;
    }

    public class Response {
        @InvocableVariable(label='Statement Download URL')
        public String downloadUrl;

        @InvocableVariable(label='Statement Summary')
        public String statementSummary;

        @InvocableVariable(label='Content Version ID')
        public Id contentVersionId;
    }

    @InvocableMethod(label='Generate EMI Statement' description='Generates downloadable EMI payment history statement document for a loan account')
    public static List<Response> generateStatement(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            String accId = req != null && req.loanAccountId != null ? req.loanAccountId.trim() : '';
            Response res = createStatementDocument(accId);
            responses.add(res);
        }

        return responses;
    }

    public static Response createStatementDocument(String accId) {
        Response res = new Response();

        List<Loan_Account__c> accounts = new List<Loan_Account__c>();
        if (String.isNotBlank(accId)) {
            accounts = [
                SELECT Id, Name, Loan_Number__c, Loan_Amount__c, EMI_Amount__c, Loan_Status__c,
                       Total_Overdue_Amount__c, Customer__r.Name
                FROM Loan_Account__c
                WHERE Id = :accId OR Loan_Number__c = :accId OR Name = :accId
                LIMIT 1
            ];
        }

        if (accounts.isEmpty()) {
            accounts = [
                SELECT Id, Name, Loan_Number__c, Loan_Amount__c, EMI_Amount__c, Loan_Status__c,
                       Total_Overdue_Amount__c, Customer__r.Name
                FROM Loan_Account__c
                ORDER BY Total_Overdue_Amount__c DESC
                LIMIT 1
            ];
        }

        if (!accounts.isEmpty()) {
            Loan_Account__c acc = accounts[0];
            String loanNum = String.isNotBlank(acc.Loan_Number__c) ? acc.Loan_Number__c : acc.Name;
            String custName = acc.Customer__r != null && String.isNotBlank(acc.Customer__r.Name) ? acc.Customer__r.Name : 'Valued Customer';

            List<EMI_Schedule__c> emis = [
                SELECT Id, Name, Due_Date__c, EMI_Amount__c, Payment_Status__c, Payment_Date__c
                FROM EMI_Schedule__c
                WHERE Loan_Account__c = :acc.Id
                ORDER BY Due_Date__c ASC
            ];

            String docContent = 'LOAN ENGAGEMENT PORTAL — OFFICIAL EMI STATEMENT\n';
            docContent += '=======================================================\n';
            docContent += 'Generated On: ' + DateTime.now().format('dd MMM yyyy, HH:mm') + '\n';
            docContent += 'Borrower Name: ' + custName + '\n';
            docContent += 'Loan Account Number: ' + loanNum + '\n';
            docContent += 'Loan Status: ' + acc.Loan_Status__c + '\n';
            docContent += 'Sanctioned Amount: INR ' + acc.Loan_Amount__c + '\n';
            docContent += 'Monthly EMI: INR ' + acc.EMI_Amount__c + '\n';
            docContent += 'Total Overdue Amount: INR ' + acc.Total_Overdue_Amount__c + '\n';
            docContent += '=======================================================\n';
            docContent += 'PAYMENT SCHEDULE & TRACK RECORD:\n\n';

            Integer paidCount = 0;
            Integer overdueCount = 0;
            Integer upcomingCount = 0;

            for (EMI_Schedule__c emi : emis) {
                String dueDateStr = emi.Due_Date__c != null ? DateTime.newInstance(emi.Due_Date__c, Time.newInstance(0,0,0,0)).format('dd-MMM-yyyy') : 'N/A';
                String paidDateStr = String.isNotBlank(emi.Payment_Date__c) ? ' (Paid: ' + emi.Payment_Date__c + ')' : '';
                docContent += '- Due: ' + dueDateStr + ' | Amount: INR ' + emi.EMI_Amount__c + ' | Status: ' + emi.Payment_Status__c + paidDateStr + '\n';

                if (emi.Payment_Status__c == 'Paid') paidCount++;
                else if (emi.Payment_Status__c == 'Overdue') overdueCount++;
                else upcomingCount++;
            }

            docContent += '\nSUMMARY: Total EMIs: ' + emis.size() + ' (Paid: ' + paidCount + ', Overdue: ' + overdueCount + ', Upcoming: ' + upcomingCount + ')\n';
            docContent += 'Bank Contact: Customer Support Desk | support@loanengagement.com\n';

            ContentVersion cv = new ContentVersion();
            cv.Title = 'EMI_Statement_' + loanNum;
            cv.PathOnClient = 'EMI_Statement_' + loanNum + '.pdf';
            cv.VersionData = Blob.valueOf(docContent);
            cv.IsMajorVersion = true;
            insert cv;

            ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

            res.contentVersionId = insertedCv.Id;
            res.downloadUrl = '/sfc/servlet.shepherd/version/download/' + insertedCv.Id;
            res.statementSummary = 'Statement generated for Loan ' + loanNum + ' with ' + emis.size() + ' schedule entries. Status: ' + acc.Loan_Status__c;
        } else {
            res.statementSummary = 'No active loan account found to generate statement.';
            res.downloadUrl = '#';
        }

        return res;
    }
}