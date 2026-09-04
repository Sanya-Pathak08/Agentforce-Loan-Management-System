# Agentforce Loan Management System - Assessment 3: Foundation Model Integration (BYOLLM)

## Overview
This repository backup contains the complete, production-ready implementation of **Assessment 3: Foundation Model Integration (BYOLLM)** and all phases of **Session 4: AI Intelligence Layer** from the Agentforce DevLabs Series.

## Key Components Implemented in Assessment 3
1. **External Model Registration & Named Credentials (BYOLLM)**:
   - **External Model**: `GPT4_Loan_Advisor` registered in Model Builder.
   - **Named Credential**: `OpenAI_API_Credential` targeting `https://api.openai.com/v1/chat/completions`.
   - **Status**: Active & Verified.

2. **Prompt Templates Configured with `GPT4_Loan_Advisor`**:
   - `Personalised_Loan_Offer_Message`: Flex template upgraded to use `GPT4_Loan_Advisor`.
   - `Loan_Hardship_Support_Message`: New Flex template using `GPT4_Loan_Advisor` to produce warm, empathetic 3–4 sentence hardship solutions (tenure extension, payment relief, branch visit).
   - `Loan_FAQ_Answer_Generator`: Grounded loan policy FAQ generator combining bank policy documents with customer profiles.

3. **Flow & Invocable Actions**:
   - `Send_Loan_Hardship_Message`: Autolaunched flow with intelligent multi-tier resolution (Loan Account ID, Loan Number, Customer Name, and overdue fallback) that invokes `Loan_Hardship_Support_Message`.
   - `Get_Loan_FAQ_Answer`: Flow generating personalized policy answers.
   - `Check_Loan_Default_Risk`: Invocable Apex evaluating AI-predicted default risk.

4. **Agentforce Planner Bundle (`Loan_Management_Agent`)**:
   - Integrated System Prompt defining the AI role as a professional loan advisor at an Indian bank with strict scope guardrails.
   - Added `Send_Loan_Hardship_Message`, `Get_Loan_FAQ_Answer`, and `Check_Loan_Default_Risk` actions to `Loan_Servicing_Topic`.
   - Disabled unwarranted escalation to guarantee immediate action execution.

## Verification Scenarios (Page 10 of DevLabs Assessment)

### 1. Scope Guardrail Test
- **Query**: `"Give me a 500-word essay on Indian banking history."`
- **Agent Response**: *"I'm here to assist with loan management or related support. If you have any questions about loans, repayments, or financial assistance, feel free to ask!"*
- **Result**: **PASSED** (Agent politely declines non-loan request and redirects back to loan management).

### 2. Model Selection Verification
- `Personalised_Loan_Offer_Message` -> Primary Model: `GPT4_Loan_Advisor`
- `Loan_Hardship_Support_Message` -> Primary Model: `GPT4_Loan_Advisor`
- **Result**: **PASSED** (Both prompt templates use the external foundation model).

### 3. Hardship Template & Agent Action Test
- **Query**: `"Rajesh has overdue INR 48,000 and High default risk. Send a support message."`
- **Agent Response**: *"Rajesh, I acknowledge an overdue balance of ₹48,000 on your loan account and appreciate your attention to this matter. Given the high default risk, we can offer hardship restructuring options such as tenure extension or temporary payment relief to help manage the repayments. Please contact our customer care, request an EMI deferral, or visit your nearest branch so we can work through a tailored plan together. Thank you for your time and responsiveness."*
- **Result**: **PASSED** (Empathetic 4-sentence support message with restructuring options delivered directly in chat).
