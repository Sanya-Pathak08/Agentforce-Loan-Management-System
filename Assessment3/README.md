# Agentforce Loan Management System - Assessment 3 Full Backup

## Overview
This repository backup contains the complete, production-ready implementation of the **Agentforce Loan Management System** developed across all assessments of the Agentforce DevLabs Series.

## Project Structure
- `force-app/main/default/`:
  - `objects/`:
    - `Customer__c`: Customer profile, financial metrics, and personalized offer fields.
    - `Loan_Application__c`: Loan applications with rejection category, notes, and AI rejection suggestions.
    - `Loan_Account__c`: Disbursed loan accounts with risk flag, overdue amounts, tenure, and AI account summary.
    - `EMI_Schedule__c`: Monthly EMI schedule with status tracking.
    - `Loan_Document__c`: Document storage linked to customers, applications, and accounts.
  - `classes/`:
    - `LoanEligibilityCalculator.cls`: Calculates tier (Gold/Silver/Standard/Not Eligible) and max loan amount.
    - `OverdueEMIValidator.cls`: Identifies overdue EMIs and flags accounts.
    - `EMIScheduleSummaryService.cls`: Aggregates EMI schedule statistics.
    - `LoanOfferContextBuilder.cls`: Prepares formatted Indian currency loan offer context.
    - `PredictLoanAmount.cls`: AI/rule-calibrated loan estimate prediction.
    - `LoanApplicationProcessingService.cls`: Automated trigger processing for loan applications.
    - Corresponding unit test classes with 100% test pass rate and high coverage.
  - `triggers/`:
    - `LoanApplicationTrigger.trigger`: Automatically approves/rejects loan applications based on credit score.
  - `flows/`:
    - `Auto_Refresh_Loan_Account_Summary`: Record-Triggered flow auto-updating AI summary when status, risk flag, or overdue amount changes.
    - `Show_Loan_Account_Summary`: Interactive Screen Flow with Save to Record vs Discard options.
    - `Generate_Loan_Account_Summary`: Autolaunched flow providing agent action for loan account summaries.
    - `Generate_Loan_Rejection_Reason`: Autolaunched flow generating rejection suggestions via prompt template.
    - `Send_Personalised_Loan_Offer`: Autolaunched flow orchestrating Apex context builder and personalized offer prompt.
    - `Check_Loan_Application_Status`: Flow checking application status by number or ID.
    - `Generate_EMI_Schedule_Summary`: Flow returning detailed EMI breakdown.
  - `genAiPromptTemplates/`:
    - `Loan_Account_360_Summary`: Record summary template (GPT-4o) with 12 merge fields.
    - `Loan_Rejection_Reason_Generator`: Flex prompt template generating 2-3 sentence rejection guidance.
    - `Personalised_Loan_Offer_Message`: Flex prompt template generating personalized loan offer proposals.
    - `Generate_Personalized_Schedule`: Schedule summary template.
  - `quickActions/`:
    - `Loan_Account__c.Generate_AI_Summary`: Flow quick action placed on Loan Account page layout.
  - `layouts/`:
    - `Loan_Account__c-Loan Account Layout`: Enhanced layout with Quick Action, Risk & Overdue section, and AI Summary section.
  - `genAiPlannerBundles/`:
    - `Loan_Management_Agent`: Configured planner with `Loan_Servicing_Topic` and grounded actions.
  - `permissionsets/`:
    - `Loan_Management_Admin`: Full CRUD, FLS, Apex class, and tab permissions.
- `manifest/package.xml`: Complete package manifest for deployments.
- `scripts/apex/`: Comprehensive suite of anonymous Apex test scripts.

## Deployment Instructions
```bash
sf project deploy start -x manifest/package.xml -o <YourOrgAlias>
```

## Verification Scenarios
1. **Screen Flow Save Path**: Open Loan Account -> 'Generate AI Summary' -> 'Save to Record' -> Verify AI Summary and timestamp update.
2. **Screen Flow Discard Path**: Open Loan Account -> 'Generate AI Summary' -> 'Discard' -> Confirm fields remain untouched.
3. **Agentforce Query**: Customer asks *"Can you summarise my loan account LA-009?"* -> Agent invokes `Generate_Loan_Account_Summary` and returns 360 summary.
4. **Auto-Refresh Automation**: Update `Risk_Flag__c` on a Loan Account -> `Auto_Refresh_Loan_Account_Summary` triggers and refreshes the summary.
