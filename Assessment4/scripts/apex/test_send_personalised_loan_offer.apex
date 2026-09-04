Map<String, Object> inputs = new Map<String, Object>{
    'customerId' => 'Aarav Sharma'
};

Flow.Interview flowInterview = Flow.Interview.createInterview('Send_Personalised_Loan_Offer', inputs);
flowInterview.start();

String msg = (String)flowInterview.getVariableValue('generatedMessage');
System.debug('Flow Output with Customer Name: ' + msg);

Customer__c updated = [
    SELECT Id, Name, Eligibility_Tier__c, Max_Loan_Amount__c, Offer_Expiry_Days__c, 
           Offer_Headline__c, Tier_Badge__c, Last_Offer_Sent__c 
    FROM Customer__c 
    WHERE Name = 'Aarav Sharma'
    LIMIT 1
];

System.debug('Customer ID: ' + updated.Id);
System.debug('Updated Last_Offer_Sent__c: ' + updated.Last_Offer_Sent__c);
