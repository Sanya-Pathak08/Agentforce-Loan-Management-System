# Agentforce Loan Management System — Assessment 5 (Experience Cloud & Embedded Service Agent)

## Overview
This repository backup contains the complete, production-ready implementation of **Assessment 5: Experience Cloud Loan Engagement Portal & Embedded Service Agent (ESA)**.

### Key Features & Implementations
1. **Experience Cloud Site (LWR)**:
   - Site: `Loan Engagement Portal`
   - Custom branding, high-contrast navigation bar, and responsive layout.
2. **Dynamic Header LWC (`portalNavigationHeader`)**:
   - Displays all 6 core navigation items for all visitors (`Home`, `Apply for a Loan`, `My Loan Dashboard`, `EMI Tracker`, `Loan Policies & FAQs`, `Contact Support`).
   - Guest Mode: Prominent `👤 Log In` button; user details and logout hidden.
   - Authenticated Customer Mode: Displays customer profile greeting (`👤 Sofia Rodriguez`) and `Log Out` action; login button hidden.
3. **Embedded Service Agent Integration**:
   - Pre-chat deployment `Loan Advisor Chat` (`ESA_Web_Deployment`).
   - Connected with `Loan_Management_Agent` and Agentforce Service Agent topics.
   - Floating chat bubble enabled and verified for guest and authenticated portal users.
4. **Apex Controllers & Permissions**:
   - `LoanPortalController.cls`: Secure guest and authenticated user operations.
   - `Borrower360Service.cls`: 360-degree customer financial profile for Agentforce grounding.
   - `GenerateEMIStatementAction.cls`: Dynamic PDF and statement generation invocable action.
   - Permission sets `Loan_Portal_Guest_Permissions` and `Loan_Portal_Member_Permissions`.

---

## Verification
- Verified guest navigation and chat bubble visibility via headless Chrome.
- Verified authenticated customer login (Sofia Rodriguez) and header greeting.