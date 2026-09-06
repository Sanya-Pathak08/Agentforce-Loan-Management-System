// 1. Test Loan Eligibility Calculator
LoanEligibilityCalculator.Request reqElig = new LoanEligibilityCalculator.Request();
reqElig.monthlyIncome = 60000;
reqElig.creditScore = 760;
List<LoanEligibilityCalculator.Response> resElig = LoanEligibilityCalculator.calculateEligibility(new List<LoanEligibilityCalculator.Request>{reqElig});
System.debug('TEST LOG -> Eligibility Tier: ' + resElig[0].eligibilityTier + ' | Max Loan: ' + resElig[0].maxLoanAmount);

// 2. Test EMI Schedule Summary
Loan_Account__c acc = [SELECT Id, Name FROM Loan_Account__c ORDER BY CreatedDate DESC LIMIT 1];
EMIScheduleSummaryService.Request reqSummary = new EMIScheduleSummaryService.Request();
reqSummary.loanAccountId = acc.Id;
List<EMIScheduleSummaryService.Response> resSummary = EMIScheduleSummaryService.getSummary(new List<EMIScheduleSummaryService.Request>{reqSummary});
System.debug('TEST LOG -> Total EMIs: ' + resSummary[0].totalEMIs + ' | Pending: ' + resSummary[0].pendingEMIs + ' | Next Due: ' + resSummary[0].nextDueDate);

// 3. Test Overdue Validator
OverdueEMIValidator.Request reqOverdue = new OverdueEMIValidator.Request();
reqOverdue.loanAccountId = acc.Id;
List<OverdueEMIValidator.Response> resOverdue = OverdueEMIValidator.flagOverdueEMIs(new List<OverdueEMIValidator.Request>{reqOverdue});
System.debug('TEST LOG -> Overdue Message: ' + resOverdue[0].overdueMessage);
