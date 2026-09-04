// Phase 9 End-to-End Test Script
System.debug('=== STARTING PHASE 9 END-TO-END SCENARIO TESTS ===');

// --- 1. SETUP / UPSERT TEST CUSTOMERS ---
// Scenario 1: Gold - Aarav Sharma
Customer__c c1 = new Customer__c(
    Name = 'Aarav Sharma',
    Eligibility_Tier__c = 'Gold',
    Max_Loan_Amount__c = 3900000,
    Preferred_Loan_Type__c = 'Home',
    Credit_Score__c = 780,
    Income__c = 85000,
    Offer_Expiry_Days__c = null,
    Offer_Headline__c = null,
    Tier_Badge__c = null,
    Last_Offer_Sent__c = null
);
List<Customer__c> existing1 = [SELECT Id FROM Customer__c WHERE Name = 'Aarav Sharma' LIMIT 1];
if (!existing1.isEmpty()) {
    c1.Id = existing1[0].Id;
    update c1;
} else {
    insert c1;
}

// Scenario 2: Silver - Priya Patel
Customer__c c2 = new Customer__c(
    Name = 'Priya Patel',
    Eligibility_Tier__c = 'Silver',
    Max_Loan_Amount__c = 1400000,
    Preferred_Loan_Type__c = 'Personal',
    Credit_Score__c = 720,
    Income__c = 35000,
    Offer_Expiry_Days__c = null,
    Offer_Headline__c = null,
    Tier_Badge__c = null,
    Last_Offer_Sent__c = null
);
List<Customer__c> existing2 = [SELECT Id FROM Customer__c WHERE Name = 'Priya Patel' LIMIT 1];
if (!existing2.isEmpty()) {
    c2.Id = existing2[0].Id;
    update c2;
} else {
    insert c2;
}

// Scenario 3: Not Eligible - Rohan Verma
Customer__c c3 = new Customer__c(
    Name = 'Rohan Verma',
    Eligibility_Tier__c = 'Not Eligible',
    Max_Loan_Amount__c = 0,
    Preferred_Loan_Type__c = 'Personal',
    Credit_Score__c = 630,
    Income__c = 20000,
    Offer_Expiry_Days__c = null,
    Offer_Headline__c = null,
    Tier_Badge__c = null,
    Last_Offer_Sent__c = null
);
List<Customer__c> existing3 = [SELECT Id FROM Customer__c WHERE Name = 'Rohan Verma' LIMIT 1];
if (!existing3.isEmpty()) {
    c3.Id = existing3[0].Id;
    update c3;
} else {
    insert c3;
}

System.debug('Test records created/reset:');
System.debug('Scenario 1 Id: ' + c1.Id);
System.debug('Scenario 2 Id: ' + c2.Id);
System.debug('Scenario 3 Id: ' + c3.Id);

// --- 2. EXECUTE FLOW FOR SCENARIO 1 (Gold Home Loan) ---
System.debug('--- EXECUTING SCENARIO 1 (Gold Home Loan) ---');
Map<String, Object> inputs1 = new Map<String, Object>{
    'customerId' => c1.Id
};
Flow.Interview.Send_Personalised_Loan_Offer flow1 = new Flow.Interview.Send_Personalised_Loan_Offer(inputs1);
flow1.start();
String response1 = (String) flow1.getVariableValue('generatedMessage');
System.debug('Scenario 1 Flow generatedMessage output: ' + response1);

// --- 3. EXECUTE FLOW FOR SCENARIO 2 (Silver Personal Loan) ---
System.debug('--- EXECUTING SCENARIO 2 (Silver Personal Loan) ---');
Map<String, Object> inputs2 = new Map<String, Object>{
    'customerId' => c2.Id
};
Flow.Interview.Send_Personalised_Loan_Offer flow2 = new Flow.Interview.Send_Personalised_Loan_Offer(inputs2);
flow2.start();
String response2 = (String) flow2.getVariableValue('generatedMessage');
System.debug('Scenario 2 Flow generatedMessage output: ' + response2);

// --- 4. EXECUTE FLOW FOR SCENARIO 3 (Not Eligible) ---
System.debug('--- EXECUTING SCENARIO 3 (Not Eligible) ---');
Map<String, Object> inputs3 = new Map<String, Object>{
    'customerId' => c3.Id
};
Flow.Interview.Send_Personalised_Loan_Offer flow3 = new Flow.Interview.Send_Personalised_Loan_Offer(inputs3);
flow3.start();
String response3 = (String) flow3.getVariableValue('generatedMessage');
System.debug('Scenario 3 Flow generatedMessage output: ' + response3);

// --- 5. VERIFY DATABASE RECORDS ---
System.debug('=== VERIFYING DATABASE RECORDS ===');
List<Customer__c> results = [
    SELECT Id, Name, Eligibility_Tier__c, Max_Loan_Amount__c, Preferred_Loan_Type__c,
           Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c, Last_Offer_Sent__c
    FROM Customer__c
    WHERE Id IN (:c1.Id, :c2.Id, :c3.Id)
    ORDER BY Name ASC
];

for (Customer__c cust : results) {
    System.debug('----------------------------------------');
    System.debug('Customer: ' + cust.Name);
    System.debug('Tier: ' + cust.Eligibility_Tier__c);
    System.debug('Offer Expiry Days: ' + cust.Offer_Expiry_Days__c);
    System.debug('Offer Headline: ' + cust.Offer_Headline__c);
    System.debug('Tier Badge: ' + cust.Tier_Badge__c);
    System.debug('Last Offer Sent: ' + cust.Last_Offer_Sent__c);
}
System.debug('=== FINISHED PHASE 9 END-TO-END SCENARIO TESTS ===');
