Customer__c testCust = new Customer__c(
    Name = 'Test Context Gold',
    Eligibility_Tier__c = 'Gold',
    Max_Loan_Amount__c = 3900000,
    Credit_Score__c = 780
);
insert testCust;

LoanOfferContextBuilder.InputWrapper req = new LoanOfferContextBuilder.InputWrapper();
req.customerId = testCust.Id;

List<LoanOfferContextBuilder.OutputWrapper> resList = LoanOfferContextBuilder.buildOfferContext(
    new List<LoanOfferContextBuilder.InputWrapper>{ req }
);

LoanOfferContextBuilder.OutputWrapper res = resList[0];
System.debug('TEST LOG -> Expiry: ' + res.offerExpiryDays);
System.debug('TEST LOG -> Badge: ' + res.tierBadge);
System.debug('TEST LOG -> Headline: ' + res.offerHeadline);

Customer__c updatedCust = [
    SELECT Id, Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c 
    FROM Customer__c 
    WHERE Id = :testCust.Id
];
System.debug('TEST LOG -> DB Expiry: ' + updatedCust.Offer_Expiry_Days__c);
System.debug('TEST LOG -> DB Headline: ' + updatedCust.Offer_Headline__c);
System.debug('TEST LOG -> DB Badge: ' + updatedCust.Tier_Badge__c);

// Clean up
delete testCust;
