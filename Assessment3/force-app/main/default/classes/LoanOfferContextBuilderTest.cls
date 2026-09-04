@isTest
private class LoanOfferContextBuilderTest {

    @isTest
    static void testGoldTierContext() {
        Customer__c cust = new Customer__c(
            Name = 'Aarav Sharma',
            Eligibility_Tier__c = 'Gold',
            Max_Loan_Amount__c = 3900000,
            Credit_Score__c = 780
        );
        insert cust;

        LoanOfferContextBuilder.InputWrapper input = new LoanOfferContextBuilder.InputWrapper();
        input.customerId = cust.Id;

        Test.startTest();
        List<LoanOfferContextBuilder.OutputWrapper> outputs = 
            LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>{ input });
        Test.stopTest();

        Assert.areEqual(1, outputs.size(), 'Should return 1 output wrapper');
        Assert.areEqual(90, outputs[0].offerExpiryDays, 'Gold tier offer should expire in 90 days');
        Assert.areEqual('Gold Partner', outputs[0].tierBadge, 'Gold tier badge should be Gold Partner');
        Assert.isTrue(outputs[0].offerHeadline.contains('INR 39,00,000'), 'Headline must contain Indian formatted amount INR 39,00,000');

        Customer__c updated = [
            SELECT Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c 
            FROM Customer__c 
            WHERE Id = :cust.Id
        ];
        Assert.areEqual(90, updated.Offer_Expiry_Days__c);
        Assert.areEqual('Gold Partner', updated.Tier_Badge__c);
        Assert.isTrue(updated.Offer_Headline__c.contains('INR 39,00,000'));
    }

    @isTest
    static void testNotEligibleContext() {
        Customer__c cust = new Customer__c(
            Name = 'Rahul Verma',
            Eligibility_Tier__c = 'Not Eligible',
            Max_Loan_Amount__c = 0,
            Credit_Score__c = 630
        );
        insert cust;

        LoanOfferContextBuilder.InputWrapper input = new LoanOfferContextBuilder.InputWrapper();
        input.customerId = cust.Id;

        Test.startTest();
        List<LoanOfferContextBuilder.OutputWrapper> outputs = 
            LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>{ input });
        Test.stopTest();

        Assert.areEqual(1, outputs.size(), 'Should return 1 output wrapper');
        Assert.areEqual(0, outputs[0].offerExpiryDays, 'Not Eligible expiry days should be 0');
        Assert.areEqual('Let\'s Help You Get Loan Ready', outputs[0].offerHeadline, 'Headline must match exactly');
        Assert.areEqual('Improvement Plan', outputs[0].tierBadge, 'Tier badge should be Improvement Plan');

        Customer__c updated = [
            SELECT Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c 
            FROM Customer__c 
            WHERE Id = :cust.Id
        ];
        Assert.areEqual(0, updated.Offer_Expiry_Days__c);
        Assert.areEqual('Let\'s Help You Get Loan Ready', updated.Offer_Headline__c);
        Assert.areEqual('Improvement Plan', updated.Tier_Badge__c);
    }

    @isTest
    static void testStandardTierContext() {
        Customer__c cust = new Customer__c(
            Name = 'Priya Patel',
            Eligibility_Tier__c = 'Standard',
            Max_Loan_Amount__c = 800000,
            Credit_Score__c = 710
        );
        insert cust;

        LoanOfferContextBuilder.InputWrapper input = new LoanOfferContextBuilder.InputWrapper();
        input.customerId = cust.Id;

        Test.startTest();
        List<LoanOfferContextBuilder.OutputWrapper> outputs = 
            LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>{ input });
        Test.stopTest();

        Assert.areEqual(1, outputs.size(), 'Should return 1 output wrapper');
        Assert.areEqual(30, outputs[0].offerExpiryDays, 'Standard tier offer should expire in 30 days');
        Assert.areEqual('Standard', outputs[0].tierBadge, 'Standard tier badge should be Standard');
        Assert.isTrue(outputs[0].offerHeadline.contains('Pre-Qualified'), 'Headline should contain Pre-Qualified');
        Assert.isTrue(outputs[0].offerHeadline.contains('INR 8,00,000'), 'Headline should contain INR 8,00,000');

        Customer__c updated = [
            SELECT Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c 
            FROM Customer__c 
            WHERE Id = :cust.Id
        ];
        Assert.areEqual(30, updated.Offer_Expiry_Days__c);
        Assert.areEqual('Standard', updated.Tier_Badge__c);
        Assert.isTrue(updated.Offer_Headline__c.contains('Pre-Qualified'));
    }

    @isTest
    static void testSilverTierContext() {
        Customer__c cust = new Customer__c(
            Name = 'Neha Gupta',
            Eligibility_Tier__c = 'Silver',
            Max_Loan_Amount__c = 1400000,
            Credit_Score__c = 730
        );
        insert cust;

        LoanOfferContextBuilder.InputWrapper input = new LoanOfferContextBuilder.InputWrapper();
        input.customerId = cust.Id;

        Test.startTest();
        List<LoanOfferContextBuilder.OutputWrapper> outputs = 
            LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>{ input });
        Test.stopTest();

        Assert.areEqual(1, outputs.size());
        Assert.areEqual(60, outputs[0].offerExpiryDays);
        Assert.areEqual('Silver Partner', outputs[0].tierBadge);
        Assert.isTrue(outputs[0].offerHeadline.contains('INR 14,00,000'));
    }

    @isTest
    static void testEdgeCasesAndFormatting() {
        // Test null and empty inputs
        Assert.areEqual(0, LoanOfferContextBuilder.buildOfferContext(null).size());
        Assert.areEqual(0, LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>()).size());

        // Test invalid/non-existent Customer ID
        LoanOfferContextBuilder.InputWrapper badInput = new LoanOfferContextBuilder.InputWrapper();
        badInput.customerId = 'INVALID_ID';
        List<LoanOfferContextBuilder.OutputWrapper> badOutputs = 
            LoanOfferContextBuilder.buildOfferContext(new List<LoanOfferContextBuilder.InputWrapper>{ badInput });
        Assert.areEqual(1, badOutputs.size());
        Assert.areEqual(0, badOutputs[0].offerExpiryDays);

        // Test Indian Number Formatting directly
        Assert.areEqual('INR 0', LoanOfferContextBuilder.formatIndianCurrency(null));
        Assert.areEqual('INR 0', LoanOfferContextBuilder.formatIndianCurrency(0));
        Assert.areEqual('INR 500', LoanOfferContextBuilder.formatIndianCurrency(500));
        Assert.areEqual('INR 1,000', LoanOfferContextBuilder.formatIndianCurrency(1000));
        Assert.areEqual('INR 50,000', LoanOfferContextBuilder.formatIndianCurrency(50000));
        Assert.areEqual('INR 1,00,000', LoanOfferContextBuilder.formatIndianCurrency(100000));
        Assert.areEqual('INR 1,00,00,000', LoanOfferContextBuilder.formatIndianCurrency(10000000));
    }
}
