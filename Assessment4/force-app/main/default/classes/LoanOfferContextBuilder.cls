public with sharing class LoanOfferContextBuilder {

    public class InputWrapper {
        @InvocableVariable(required=true description='Customer Record ID')
        public String customerId;
    }

    public class OutputWrapper {
        @InvocableVariable(description='Number of days this offer remains valid')
        public Integer offerExpiryDays;

        @InvocableVariable(description='Pre-formatted offer headline with amount')
        public String offerHeadline;

        @InvocableVariable(description='Display label e.g. Gold Partner')
        public String tierBadge;

        @InvocableVariable(description='Customer 18-character Record ID')
        public String customerRecordId;
    }

    @InvocableMethod(label='Build Loan Offer Context' description='Use this action BEFORE generating the personalised loan offer message. It computes offer expiry, headline, and tier badge for a Customer record. Requires Customer ID.' category='Loan Management')
    public static List<OutputWrapper> buildOfferContext(List<InputWrapper> inputs) {
        List<OutputWrapper> outputs = new List<OutputWrapper>();
        if (inputs == null || inputs.isEmpty()) {
            return outputs;
        }

        Set<Id> customerIds = new Set<Id>();
        Set<String> customerNames = new Set<String>();

        for (InputWrapper input : inputs) {
            if (String.isNotBlank(input.customerId)) {
                String val = input.customerId.trim();
                if ((val.length() == 15 || val.length() == 18) && !val.contains('-') && !val.contains(' ')) {
                    try {
                        customerIds.add((Id)val);
                    } catch (Exception e) {
                        customerNames.add(val);
                    }
                } else {
                    customerNames.add(val);
                }
            }
        }

        Map<String, Customer__c> customerMapById = new Map<String, Customer__c>();
        Map<String, Customer__c> customerMapByName = new Map<String, Customer__c>();

        List<Customer__c> queriedCustomers = [
            SELECT Id, Name, Eligibility_Tier__c, Max_Loan_Amount__c, Credit_Score__c,
                   Offer_Expiry_Days__c, Offer_Headline__c, Tier_Badge__c
            FROM Customer__c
            WHERE Id IN :customerIds OR Name IN :customerNames
        ];

        for (Customer__c c : queriedCustomers) {
            customerMapById.put(String.valueOf(c.Id), c);
            customerMapById.put(((String)c.Id).substring(0, 15), c);
            customerMapByName.put(c.Name, c);
        }

        Map<Id, Customer__c> customersToUpdateMap = new Map<Id, Customer__c>();

        for (InputWrapper input : inputs) {
            OutputWrapper out = new OutputWrapper();
            Customer__c cust = null;

            if (String.isNotBlank(input.customerId)) {
                String val = input.customerId.trim();
                if (customerMapById.containsKey(val)) {
                    cust = customerMapById.get(val);
                } else if (customerMapByName.containsKey(val)) {
                    cust = customerMapByName.get(val);
                }
            }

            if (cust != null) {
                String tier = String.isNotBlank(cust.Eligibility_Tier__c) ? cust.Eligibility_Tier__c : 'Not Eligible';
                Decimal maxAmount = cust.Max_Loan_Amount__c != null ? cust.Max_Loan_Amount__c : 0;
                String formattedAmount = formatIndianCurrency(maxAmount);

                if (tier.equalsIgnoreCase('Gold')) {
                    out.offerExpiryDays = 90;
                    out.offerHeadline = 'Exclusive Gold Tier Loan Offer — Up to ' + formattedAmount;
                    out.tierBadge = 'Gold Partner';
                } else if (tier.equalsIgnoreCase('Silver')) {
                    out.offerExpiryDays = 60;
                    out.offerHeadline = 'Silver Tier Pre-Approved Offer — Up to ' + formattedAmount;
                    out.tierBadge = 'Silver Partner';
                } else if (tier.equalsIgnoreCase('Standard')) {
                    out.offerExpiryDays = 30;
                    out.offerHeadline = 'You Are Pre-Qualified — Up to ' + formattedAmount;
                    out.tierBadge = 'Standard';
                } else {
                    // Not Eligible or default
                    out.offerExpiryDays = 0;
                    out.offerHeadline = 'Let\'s Help You Get Loan Ready';
                    out.tierBadge = 'Improvement Plan';
                }

                // Update fields on the customer record
                out.customerRecordId = String.valueOf(cust.Id);
                cust.Offer_Expiry_Days__c = out.offerExpiryDays;
                cust.Offer_Headline__c = out.offerHeadline;
                cust.Tier_Badge__c = out.tierBadge;
                customersToUpdateMap.put(cust.Id, cust);
            } else {
                // Fallback for null / unfound customer
                out.customerRecordId = null;
                out.offerExpiryDays = 0;
                out.offerHeadline = 'Let\'s Help You Get Loan Ready';
                out.tierBadge = 'Improvement Plan';
            }

            outputs.add(out);
        }

        if (!customersToUpdateMap.isEmpty()) {
            update customersToUpdateMap.values();
        }

        return outputs;
    }

    public static String formatIndianCurrency(Decimal amount) {
        if (amount == null) {
            return 'INR 0';
        }
        Long wholeNumber = Math.abs(amount.longValue());
        String numStr = String.valueOf(wholeNumber);

        if (numStr.length() <= 3) {
            return 'INR ' + (amount < 0 ? '-' : '') + numStr;
        }

        String lastThree = numStr.substring(numStr.length() - 3);
        String remaining = numStr.substring(0, numStr.length() - 3);

        List<String> groups = new List<String>();
        while (remaining.length() > 2) {
            groups.add(remaining.substring(remaining.length() - 2));
            remaining = remaining.substring(0, remaining.length() - 2);
        }
        if (remaining.length() > 0) {
            groups.add(remaining);
        }

        String result = '';
        for (Integer i = groups.size() - 1; i >= 0; i--) {
            result += groups[i] + ',';
        }
        result += lastThree;

        return 'INR ' + (amount < 0 ? '-' : '') + result;
    }
}
