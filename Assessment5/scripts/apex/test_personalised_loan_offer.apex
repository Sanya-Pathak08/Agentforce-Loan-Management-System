Customer__c cust = [SELECT Id, Name, Eligibility_Tier__c, Max_Loan_Amount__c, Preferred_Loan_Type__c FROM Customer__c WHERE Id = 'a0ANS00000DR6Hx2AL' LIMIT 1];
System.debug('Testing Send_Personalised_Loan_Offer for Customer: ' + cust.Id + ' (' + cust.Name + ')');

Map<String, Object> inputs = new Map<String, Object>{
    'customerId' => cust.Id
};
Flow.Interview.Send_Personalised_Loan_Offer interview = new Flow.Interview.Send_Personalised_Loan_Offer(inputs);
interview.start();

String message = (String) interview.getVariableValue('generatedMessage');
System.debug('=== GENERATED PERSONALISED LOAN OFFER MESSAGE ===');
System.debug(message);

Customer__c custAfter = [SELECT Id, Last_Offer_Sent__c, Offer_Headline__c FROM Customer__c WHERE Id = :cust.Id];
System.debug('=== CUSTOMER RECORD VERIFICATION ===');
System.debug('Last Offer Sent: ' + custAfter.Last_Offer_Sent__c);
System.debug('Offer Headline: ' + custAfter.Offer_Headline__c);
