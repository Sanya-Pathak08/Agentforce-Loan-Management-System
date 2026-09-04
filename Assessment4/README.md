# Agentforce Loan Management System — Assessment 4 (Session 4: AI Intelligence Layer)

## Overview
This repository backup contains the complete, production-ready implementation of **Assessment 4 / Session 4: AI Intelligence Layer** from the **Agentforce DevLabs Assessment (25th April 2026)** organized by Salesforce Architect Group, Mumbai.

Session 4 equips the Agentforce Loan Management System with a comprehensive AI intelligence architecture comprising:
1. **Data Grounding via Data Library & Retriever** (Assessment 1)
2. **Predictive Models via Einstein Prediction Builder** (Assessment 2)
3. **External Foundation Model Integration via BYOLLM** (Assessment 3)
4. **Retriever Grounding in Prompt Builder** (Bonus Assessment)
5. **End-to-End Multi-Step Agentic Conversation** (Page 14 Demo)

---

## Architecture Components

### 1. Data Grounding & Knowledge Base (Assessment 1)
- **3 Bank Policy Documents**:
  - `Personal_Loan_Policy.pdf`: Document checklists, eligibility criteria, credit score tiers, and tenure.
  - `Home_Loan_Eligibility_Guide.pdf`: Eligibility requirements, 80% LTV, and ₹5 Crore maximum loan cap.
  - `EMI_Payment_Rules.pdf`: 7-day grace period, 2%/month late payment charge, and 90-day NPA classification.
- **Agent Topic & Retrieval**:
  - Connected via `Loan_Knowledge_Topic` and grounded action `Get_Loan_FAQ_Answer`.
  - Answers general policy questions accurately without requiring hardcoded Apex logic.

### 2. Predictive Models (Assessment 2)
- **Binary Classification (Loan Default Predictor)**:
  - **Target Field**: `Default_Risk__c` (Picklist: High / Low) on `Loan_Account__c`.
  - **Predictor Fields**: `Bounced_EMI_Count__c`, `Credit_Score_At_Application__c`, `Monthly_Income__c`, `Loan_Amount__c`, `Total_Overdue_Amount__c`.
  - **Invocable Action**: `LoanDefaultRiskService.cls` (`Check_Loan_Default_Risk`).
  - **Verified Result**: Correctly flags high-risk accounts (e.g., LA-009) with a 78% default probability score.
- **Regression Model (Loan Amount Predictor)**:
  - **Target Field**: `Predicted_Loan_Amount__c` (Currency) on `Loan_Application__c`.
  - **Feature Fields**: `Applicant_Monthly_Income__c`, `Tenure_Requested__c`, `Number_Of_Dependants__c`, `Existing_Monthly_Obligations__c`.
  - **Invocable Action**: `PredictLoanAmount.cls` (`Predict_Loan_Amount`).
  - **Verified Result**: Returns data-driven loan amount predictions alongside rule-based tier estimates (e.g. Silver Tier: ₹18,00,000 vs. ML Estimate: ₹22,40,000).

### 3. Foundation Model Integration — BYOLLM (Assessment 3)
- **External Model**: `GPT4_Loan_Advisor` registered in Salesforce Model Builder.
- **Named Credential**: `OpenAI_API_Credential` targeting `https://api.openai.com/v1/chat/completions` (Active & Verified).
- **Service Agent System Prompt**:
  - Role: Senior loan advisor at an Indian bank.
  - Tone: Warm, professional, and precise.
  - Guardrails: Declines non-loan queries (e.g. essays, general knowledge) and redirects to loan management.
  - Compliance: Disclaims firm loan approval commitments; specifies figures are estimates.
  - Length: Concise 3–5 sentences.
- **Prompt Templates Powered by GPT4_Loan_Advisor**:
  - `Personalised_Loan_Offer_Message`: Flex prompt template generating customized loan proposals.
  - `Loan_Hardship_Support_Message`: Flex prompt template generating warm, empathetic 3–4 sentence hardship restructuring messages.
- **Flow**: `Send_Loan_Hardship_Message` with multi-tier customer and account resolution.

### 4. Retriever as Merge Input in Prompt Builder (Bonus Assessment)
- **Template**: `Loan_FAQ_Answer_Generator` on `Customer__c`.
- **Action**: `Get_Loan_FAQ_Answer` Flow.
- **Capability**: Merges real-time customer data (tier, credit score) with retrieved policy sections.

---

## Live Verification Results

| Scenario | Input Query | Live Agent Response / Verification | Status |
| :--- | :--- | :--- | :--- |
| **Scope Guardrail** | *"Give me a 500-word essay on Indian banking history"* | *"I can assist with questions related to loans, financial management, or customer support. Let me know how I can help!"* | **PASSED** |
| **BYOLLM Hardship Message** | *"Rajesh has overdue INR 48,000 and High default risk. Send a support message."* | *"Rajesh, I acknowledge an overdue balance of ₹48,000 on your loan account and appreciate your attention to this matter. Because your default risk is high, we can offer hardship restructuring options such as tenure extension or temporary payment relief to reduce immediate pressure. Please contact our customer care or request an EMI deferral, or visit your nearest branch so we can work together on a tailored plan. Thank you for your time and responsiveness."* | **PASSED** |
| **EMI Rules & Grace Period** | *"What happens if I miss my EMI? (Customer: any)"* | *"If you miss your EMI payment, the bank provides a 7-calendar-day grace period from the due date. After this grace period, a late payment charge of 2% per month is applied to the overdue amount. If you miss consecutive payments for 3 months, your loan account may be classified as a Non-Performing Asset (NPA)..."* | **PASSED** |
| **Model Registry** | Prompt Builder inspection | Primary model explicitly configured as `GPT4_Loan_Advisor` | **PASSED** |
| **Default Risk Check** | *"What is the default risk for my loan account LA-009?"* | *"Account LA-009 is flagged as High Risk with a 78% probability score. Recommend proactive outreach."* | **PASSED** |

---

## Deployment & Verification Commands
```powershell
# Deploy full metadata package to target org
sf project deploy start -x manifest/package.xml -o DemoOrg

# Activate Loan Management Agent
sf agent activate -n Loan_Management_Agent --version 1 -o DemoOrg

# Open in browser for live interactive preview
sf org open -o DemoOrg -p /lightning/setup/Agents/home
```
