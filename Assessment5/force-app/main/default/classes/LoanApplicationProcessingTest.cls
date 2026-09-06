@isTest
public class LoanApplicationProcessingTest {

    @isTest
    static void testApprovedApplication() {
        Customer__c cust = new Customer__c(
            Name = 'John Doe',
            Credit_Score__c = 750,
            Income__c = 60000
        );
        insert cust;

        Loan_Application__c app = new Loan_Application__c(
            Customer__c = cust.Id,
            Loan_Amount__c = 120000,
            Credit_Score__c = 750,
            Application_Status__c = 'Draft'
        );
        insert app;

        Test.startTest();
        app.Application_Status__c = 'Submitted';
        update app;
        Test.stopTest();

        Loan_Application__c updatedApp = [
            SELECT Application_Status__c, Rejection_Reason__c 
            FROM Loan_Application__c 
            WHERE Id = :app.Id
        ];
        System.assertEquals('Approved', updatedApp.Application_Status__c);
        System.assertEquals(null, updatedApp.Rejection_Reason__c);

        List<Loan_Account__c> accounts = [
            SELECT Id, Loan_Amount__c, Tenure_Months__c, EMI_Amount__c, Loan_Status__c 
            FROM Loan_Account__c 
            WHERE Loan_Application__c = :app.Id
        ];
        System.assertEquals(1, accounts.size());
        System.assertEquals('Active', accounts[0].Loan_Status__c);

        List<EMI_Schedule__c> emis = [
            SELECT Id, Due_Date__c, Payment_Status__c 
            FROM EMI_Schedule__c 
            WHERE Loan_Account__c = :accounts[0].Id
        ];
        System.assertEquals(12, emis.size());
    }

    @isTest
    static void testRejectedApplication() {
        Customer__c cust = new Customer__c(
            Name = 'Jane Smith',
            Credit_Score__c = 620,
            Income__c = 30000
        );
        insert cust;

        Loan_Application__c app = new Loan_Application__c(
            Customer__c = cust.Id,
            Loan_Amount__c = 50000,
            Credit_Score__c = 620,
            Application_Status__c = 'Submitted'
        );

        Test.startTest();
        insert app;
        Test.stopTest();

        Loan_Application__c updatedApp = [
            SELECT Application_Status__c, Rejection_Reason__c 
            FROM Loan_Application__c 
            WHERE Id = :app.Id
        ];
        System.assertEquals('Rejected', updatedApp.Application_Status__c);
        System.assertNotEquals(null, updatedApp.Rejection_Reason__c);
    }
}