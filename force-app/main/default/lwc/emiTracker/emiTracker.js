import { LightningElement, api, wire, track } from 'lwc';
import getEMISchedules from '@salesforce/apex/LoanPortalController.getEMISchedules';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Due Date', fieldName: 'formattedDueDate', type: 'text', sortable: true },
    { label: 'EMI Amount', fieldName: 'formattedAmount', type: 'text' },
    {
        label: 'Payment Status',
        fieldName: 'Payment_Status__c',
        type: 'text',
        cellAttributes: { class: { fieldName: 'statusClass' } }
    },
    { label: 'Payment Date', fieldName: 'formattedPaymentDate', type: 'text' }
];

export default class EmiTracker extends LightningElement {
    @api recordId;
    @api loanAccountId = '';
    @track activeTab = 'All';
    @track allRecords = [];
    @track isDownloading = false;
    columns = COLUMNS;

    @wire(getEMISchedules, { loanAccountId: '$loanAccountId' })
    wiredEMIs({ error, data }) {
        if (data) {
            this.allRecords = data.map(item => {
                let formattedDue = item.Due_Date__c ? item.Due_Date__c : 'N/A';
                let formattedAmt = item.EMI_Amount__c ? '₹' + Number(item.EMI_Amount__c).toLocaleString('en-IN') : '₹0';
                let statusClass = 'slds-badge ';

                if (item.Payment_Status__c === 'Paid') statusClass += 'slds-theme_success';
                else if (item.Payment_Status__c === 'Overdue') statusClass += 'slds-theme_error';
                else statusClass += 'slds-theme_warning';

                return {
                    id: item.Id,
                    formattedDueDate: formattedDue,
                    formattedAmount: formattedAmt,
                    Payment_Status__c: item.Payment_Status__c || 'Pending',
                    statusClass: statusClass,
                    formattedPaymentDate: item.Payment_Date__c ? item.Payment_Date__c : '—'
                };
            });
        } else if (error) {
            console.error('Error loading EMI schedules:', error);
        }
    }

    get filteredRecords() {
        if (this.activeTab === 'All') {
            return this.allRecords;
        } else if (this.activeTab === 'Paid') {
            return this.allRecords.filter(r => r.Payment_Status__c === 'Paid');
        } else if (this.activeTab === 'Upcoming') {
            return this.allRecords.filter(r => r.Payment_Status__c === 'Pending');
        } else if (this.activeTab === 'Overdue') {
            return this.allRecords.filter(r => r.Payment_Status__c === 'Overdue');
        }
        return this.allRecords;
    }

    get hasRecords() {
        return this.filteredRecords && this.filteredRecords.length > 0;
    }

    get allTabLabel() {
        return 'All (' + this.allRecords.length + ')';
    }

    get paidTabLabel() {
        const count = this.allRecords.filter(r => r.Payment_Status__c === 'Paid').length;
        return 'Paid (' + count + ')';
    }

    get upcomingTabLabel() {
        const count = this.allRecords.filter(r => r.Payment_Status__c === 'Pending').length;
        return 'Upcoming (' + count + ')';
    }

    get overdueTabLabel() {
        const count = this.allRecords.filter(r => r.Payment_Status__c === 'Overdue').length;
        return 'Overdue (' + count + ')';
    }

    handleTabSelect(event) {
        this.activeTab = event.target.value;
    }

    handleDownloadStatement() {
        this.isDownloading = true;

        let csvContent = 'data:text/csv;charset=utf-8,';
        csvContent += 'Due Date,EMI Amount,Payment Status,Payment Date\n';
        this.allRecords.forEach(r => {
            csvContent += r.formattedDueDate + ',"' + r.formattedAmount + '",' + r.Payment_Status__c + ',"' + r.formattedPaymentDate + '"\n';
        });

        const encodedUri = encodeURI(csvContent);
        const link = document.createElement('a');
        link.setAttribute('href', encodedUri);
        link.setAttribute('download', 'EMI_Statement.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Statement Exported',
                message: 'Your official EMI schedule statement has been exported successfully.',
                variant: 'success'
            })
        );

        this.isDownloading = false;
    }
}