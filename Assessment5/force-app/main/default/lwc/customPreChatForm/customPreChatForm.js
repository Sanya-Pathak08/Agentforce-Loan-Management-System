import { LightningElement, api, track } from 'lwc';

export default class CustomPreChatForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track loanAccountNumber = '';
    @track queryType = 'Policy Question';

    get queryTypeOptions() {
        return [
            { label: 'Policy Question', value: 'Policy Question' },
            { label: 'New Loan', value: 'New Loan' },
            { label: 'Existing Loan', value: 'Existing Loan' },
            { label: 'EMI Query', value: 'EMI Query' }
        ];
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'FirstName') {
            this.firstName = event.target.value;
        } else if (field === 'LastName') {
            this.lastName = event.target.value;
        } else if (field === 'Email') {
            this.email = event.target.value;
        } else if (field === 'LoanAccountNumber') {
            this.loanAccountNumber = event.target.value;
        } else if (field === 'QueryType') {
            this.queryType = event.target.value;
        }
    }

    handleStartConversation() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
        let isValid = true;
        inputs.forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            return;
        }

        const prechatData = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Email: this.email,
            _firstName: this.firstName,
            _lastName: this.lastName,
            _email: this.email,
            LoanAccountNumber: this.loanAccountNumber,
            Loan_Account_Number__c: this.loanAccountNumber,
            QueryType: this.queryType,
            Query_Type__c: this.queryType
        };

        // Standard MIAW custom pre-chat submit event
        this.dispatchEvent(new CustomEvent('prechatsubmit', {
            detail: { value: prechatData },
            bubbles: true,
            composed: true
        }));
    }
}
