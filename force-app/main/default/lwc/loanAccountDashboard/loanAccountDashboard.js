import { LightningElement, api, wire, track } from 'lwc';
import getBorrowerLoanAccount from '@salesforce/apex/LoanPortalController.getBorrowerLoanAccount';

export default class LoanAccountDashboard extends LightningElement {
    @api recordId;
    @api accountKey = '';
    @track loanData;

    @wire(getBorrowerLoanAccount, { accountKey: '$accountKey' })
    wiredLoanAccount({ error, data }) {
        if (data) {
            this.loanData = data;
        } else if (error) {
            console.error('Error loading loan account data:', error);
        }
    }

    get account() {
        return this.loanData ? this.loanData.account : null;
    }

    get loanNumber() {
        return this.account ? (this.account.Loan_Number__c || this.account.Name) : 'LA-048';
    }

    get customerName() {
        return this.account && this.account.Customer__r ? this.account.Customer__r.Name : 'Rajesh Sharma';
    }

    get sanctionedAmount() {
        return this.account && this.account.Loan_Amount__c ? this.account.Loan_Amount__c.toLocaleString('en-IN') : '12,00,000';
    }

    get emiAmount() {
        return this.account && this.account.EMI_Amount__c ? this.account.EMI_Amount__c.toLocaleString('en-IN') : '24,000';
    }

    get interestRate() {
        return this.account && this.account.Interest_Rate__c ? this.account.Interest_Rate__c : '13.5';
    }

    get tenure() {
        return this.account && this.account.Tenure_Months__c ? this.account.Tenure_Months__c : (this.account?.Tenure__c || 60);
    }

    get defaultRisk() {
        return this.account && this.account.Default_Risk__c ? this.account.Default_Risk__c : 'High';
    }

    get overdueAmount() {
        return this.loanData && this.loanData.totalOverdueAmount ? this.loanData.totalOverdueAmount.toLocaleString('en-IN') : '48,000';
    }

    get nextDueDate() {
        return this.loanData ? this.loanData.nextEMIDueDate : '15 Oct 2026';
    }

    get remainingTenure() {
        return this.loanData ? this.loanData.remainingTenureMonths : 48;
    }

    get statusBannerClass() {
        if (!this.loanData) return 'status-banner slds-theme_success';
        return this.loanData.isOverdue
            ? 'status-banner slds-theme_error alert-overdue'
            : 'status-banner slds-theme_success alert-good';
    }

    get statusIconName() {
        return this.loanData && this.loanData.isOverdue ? 'utility:warning' : 'utility:success';
    }

    get statusBadgeClass() {
        return this.loanData && this.loanData.isOverdue ? 'slds-badge slds-theme_error' : 'slds-badge slds-theme_success';
    }

    get riskBadgeClass() {
        return this.defaultRisk === 'High' ? 'slds-badge slds-theme_error' : 'slds-badge slds-theme_inverse';
    }

    handleOpenAgentChat() {
        this.triggerChatLaunch();
    }

    triggerChatLaunch() {
        // 1. Try official Salesforce Embedded Messaging utilAPI
        if (window.embeddedservice_bootstrap && window.embeddedservice_bootstrap.utilAPI) {
            try {
                window.embeddedservice_bootstrap.utilAPI.launchChat()
                    .catch((e) => {
                        this.fallbackDomClick();
                    });
                return;
            } catch (e) {
                // proceed to fallback
            }
        }

        // 2. DOM / Shadow DOM Click
        this.fallbackDomClick();
    }

    fallbackDomClick() {
        const findButton = (root) => {
            if (!root) return null;
            const btn = root.querySelector && root.querySelector(
                'button.embeddedMessagingConversationButton, button.embeddedMessagingIconContainer, button[class*="embeddedMessaging"], button[aria-label*="Chat" i], button[aria-label*="Loan Advisor" i], button[title*="Chat" i], button[title*="Loan Advisor" i], .embeddedServiceHelpButton button, .embeddedServiceSidebarMinimizedDefaultUI'
            );
            if (btn) return btn;

            const all = root.querySelectorAll ? Array.from(root.querySelectorAll('*')) : [];
            for (const el of all) {
                if (el.shadowRoot) {
                    const found = findButton(el.shadowRoot);
                    if (found) return found;
                }
            }
            return null;
        };

        const targetBtn = findButton(document);
        if (targetBtn) {
            targetBtn.click();
        } else {
            setTimeout(() => {
                if (window.embeddedservice_bootstrap && window.embeddedservice_bootstrap.utilAPI) {
                    window.embeddedservice_bootstrap.utilAPI.launchChat().catch(() => {});
                } else {
                    const retryBtn = findButton(document);
                    if (retryBtn) retryBtn.click();
                }
            }, 400);
        }

        window.dispatchEvent(new CustomEvent('openAgentforceChat', {
            detail: { loanNumber: this.loanNumber }
        }));
    }
}