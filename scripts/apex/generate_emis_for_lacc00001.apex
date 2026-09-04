Loan_Account__c acc = [SELECT Id, Tenure_Months__c, EMI_Amount__c FROM Loan_Account__c WHERE Name = 'LACC-00001' LIMIT 1];

List<EMI_Schedule__c> existing = [SELECT Id FROM EMI_Schedule__c WHERE Loan_Account__c = :acc.Id];
if (existing.isEmpty()) {
    List<EMI_Schedule__c> emisToInsert = new List<EMI_Schedule__c>();
    Integer tenure = acc.Tenure_Months__c != null ? Integer.valueOf(acc.Tenure_Months__c) : 12;
    Decimal emiAmount = acc.EMI_Amount__c != null ? acc.EMI_Amount__c : 5000;

    for (Integer i = 1; i <= tenure; i++) {
        emisToInsert.add(new EMI_Schedule__c(
            Loan_Account__c = acc.Id,
            EMI_Amount__c = emiAmount,
            Due_Date__c = Date.today().addMonths(i),
            Payment_Status__c = 'Pending',
            Payment_Date__c = 'N/A'
        ));
    }
    insert emisToInsert;
    System.debug('TEST LOG -> Created ' + emisToInsert.size() + ' EMI schedules for LACC-00001');
} else {
    System.debug('TEST LOG -> EMI schedules already exist: ' + existing.size());
}
