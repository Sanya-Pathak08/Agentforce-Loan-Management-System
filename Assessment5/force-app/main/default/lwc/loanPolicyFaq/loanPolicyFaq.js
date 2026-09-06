import { LightningElement, track } from 'lwc';

export default class LoanPolicyFaq extends LightningElement {
    @track activeSections = ['personal', 'home', 'emi'];

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
            detail: { topic: 'PolicyFAQ' }
        }));
    }
}
