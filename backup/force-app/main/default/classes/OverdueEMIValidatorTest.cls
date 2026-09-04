@isTest
public class OverdueEMIValidatorTest {

    @isTest
    static void testOverdueEMIsFound() {

        // Create Loan Account
        Loan_Account__c loan = new Loan_Account__c(
            Loan_Amount__c = 360000,
            Tenure_Months__c = 12
        );
        insert loan;

        // Create 3 overdue EMIs
        List<EMI_Schedule__c> emis = new List<EMI_Schedule__c>();

        for (Integer i = 0; i < 3; i++) {
            emis.add(new EMI_Schedule__c(
                Loan_Account__c = loan.Id,
                Due_Date__c = Date.today().addDays(-5),
                Payment_Status__c = 'Pending',
                Payment_Date__c = 'N/A' // Required field
            ));
        }

        insert emis;

        // Call method
        OverdueEMIValidator.Request req = new OverdueEMIValidator.Request();
        req.loanAccountId = loan.Id;

        List<OverdueEMIValidator.Response> result =
            OverdueEMIValidator.flagOverdueEMIs(
                new List<OverdueEMIValidator.Request>{req}
            );

        // Assertions
        System.assertEquals(3, result[0].overdueCount);
        System.assertEquals(90000, result[0].totalOverdueAmount);

        // Verify status updated
        List<EMI_Schedule__c> updated = [
            SELECT Payment_Status__c
            FROM EMI_Schedule__c
            WHERE Loan_Account__c = :loan.Id
        ];

        for (EMI_Schedule__c e : updated) {
            System.assertEquals('Overdue', e.Payment_Status__c);
        }
    }

    @isTest
    static void testNoOverdueEMIs() {

        Loan_Account__c loan = new Loan_Account__c(
            Loan_Amount__c = 240000,
            Tenure_Months__c = 12
        );
        insert loan;

        EMI_Schedule__c emi = new EMI_Schedule__c(
            Loan_Account__c = loan.Id,
            Due_Date__c = Date.today().addDays(10),
            Payment_Status__c = 'Pending',
            Payment_Date__c = 'N/A'
        );
        insert emi;

        OverdueEMIValidator.Request req = new OverdueEMIValidator.Request();
        req.loanAccountId = loan.Id;

        List<OverdueEMIValidator.Response> result =
            OverdueEMIValidator.flagOverdueEMIs(
                new List<OverdueEMIValidator.Request>{req}
            );

        System.assertEquals(0, result[0].overdueCount);
        System.assertEquals(0, result[0].totalOverdueAmount);
        System.assertEquals('No overdue EMIs found.', result[0].overdueMessage);
    }

    @isTest
    static void testEmptyLoanAccount() {

        OverdueEMIValidator.Request req = new OverdueEMIValidator.Request();
        req.loanAccountId = 'a00000000000000AAA'; // fake Id

        List<OverdueEMIValidator.Response> result =
            OverdueEMIValidator.flagOverdueEMIs(
                new List<OverdueEMIValidator.Request>{req}
            );

        System.assertEquals(0, result[0].overdueCount);
        System.assertEquals('No loan account found.', result[0].overdueMessage);
    }
}