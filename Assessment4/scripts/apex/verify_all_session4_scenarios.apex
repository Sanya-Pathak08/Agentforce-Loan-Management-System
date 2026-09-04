System.debug('==================== RUNNING SESSION 4 VERIFICATION ====================');

// Step 1: Predict Loan Amount & Eligibility
System.debug('--- Step 1: Eligibility & Amount Prediction ---');
LoanEligibilityCalculator.Request eligReq = new LoanEligibilityCalculator.Request();
eligReq.monthlyIncome = 52000;
eligReq.creditScore = 760;
List<LoanEligibilityCalculator.Response> eligRes = LoanEligibilityCalculator.calculateEligibility(new List<LoanEligibilityCalculator.Request>{eligReq});
System.debug('Step 1 Eligibility: Tier=' + eligRes[0].eligibilityTier + ', MaxAmount=' + eligRes[0].maxLoanAmount);

PredictLoanAmount.Request predReq = new PredictLoanAmount.Request();
predReq.monthlyIncome = 52000;
predReq.creditScore = 760;
List<PredictLoanAmount.Response> predRes = PredictLoanAmount.predictLoanAmount(new List<PredictLoanAmount.Request>{predReq});
System.debug('Step 1 Prediction: Amount=' + predRes[0].predictedLoanAmount + ', Summary=' + predRes[0].predictionSummary);

// Step 2: Loan FAQ Answer Generator (Home Loan Docs & Gold Tier)
System.debug('--- Step 2: Loan FAQ Answer Generator ---');
Map<String, Object> faqInputs = new Map<String, Object>{'customerId' => 'John Doe', 'preferredLoanType' => 'Home Loan'};
Flow.Interview.Get_Loan_FAQ_Answer faqFlow = new Flow.Interview.Get_Loan_FAQ_Answer(faqInputs);
faqFlow.start();
String faqAns = (String) faqFlow.getVariableValue('faqAnswer');
System.debug('Step 2 FAQ Answer: ' + faqAns);

// Step 3: Check Loan Default Risk (LA-009)
System.debug('--- Step 3: Default Risk for LA-009 ---');
LoanDefaultRiskService.Request riskReq = new LoanDefaultRiskService.Request();
riskReq.loanAccountId = 'LA-009';
List<LoanDefaultRiskService.Response> riskRes = LoanDefaultRiskService.checkLoanDefaultRisk(new List<LoanDefaultRiskService.Request>{riskReq});
System.debug('Step 3 Default Risk: RiskLevel=' + riskRes[0].riskLevel + ', Probability=' + riskRes[0].probabilityScore + '%, Message=' + riskRes[0].defaultRiskMessage);

// Step 4: Overdue EMI Validator + Loan Hardship Support Message
System.debug('--- Step 4: Missed EMIs & Hardship Support ---');
OverdueEMIValidator.Request ovReq = new OverdueEMIValidator.Request();
ovReq.loanAccountId = 'LA-009';
List<OverdueEMIValidator.Response> ovRes = OverdueEMIValidator.flagOverdueEMIs(new List<OverdueEMIValidator.Request>{ovReq});
System.debug('Step 4 Overdue Validator: ' + ovRes[0].overdueMessage);

Map<String, Object> hardInputs = new Map<String, Object>{'loanAccountId' => 'LA-048'};
Flow.Interview.Send_Loan_Hardship_Message hardFlow = new Flow.Interview.Send_Loan_Hardship_Message(hardInputs);
hardFlow.start();
String hardMsg = (String) hardFlow.getVariableValue('hardshipMessage');
System.debug('Step 4 Hardship Message: ' + hardMsg);

// Step 6: Personalised Loan Offer Message
System.debug('--- Step 6: Personalised Loan Offer ---');
Map<String, Object> offerInputs = new Map<String, Object>{'customerId' => 'John Doe'};
Flow.Interview.Send_Personalised_Loan_Offer offerFlow = new Flow.Interview.Send_Personalised_Loan_Offer(offerInputs);
offerFlow.start();
String offerMsg = (String) offerFlow.getVariableValue('generatedMessage');
System.debug('Step 6 Personalised Offer: ' + offerMsg);

System.debug('==================== VERIFICATION COMPLETED SUCCESSFULLY ====================');