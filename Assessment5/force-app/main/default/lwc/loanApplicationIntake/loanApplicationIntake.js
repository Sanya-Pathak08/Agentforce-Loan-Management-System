import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LoanApplicationIntake extends LightningElement {
    @track isSubmitted = false;
    @track submittedAppNumber = '';

    handleSuccess(event) {
        this.isSubmitted = true;
        this.submittedAppNumber = event.detail.fields?.Name?.value || event.detail.id;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Application Submitted',
                message: 'Your application has been submitted. A loan specialist will contact you within 24 hours.',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Submission Error',
                message: event.detail.detail || 'Please complete all required fields.',
                variant: 'error'
            })
        );
    }

    handleReset() {
        this.isSubmitted = false;
        this.submittedAppNumber = '';
    }
}