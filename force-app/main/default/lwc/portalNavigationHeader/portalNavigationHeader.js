import { LightningElement, wire } from 'lwc';
import isGuest from '@salesforce/user/isGuest';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import getCurrentUserInfo from '@salesforce/apex/LoanPortalController.getCurrentUserInfo';

export default class PortalNavigationHeader extends LightningElement {
    isGuestUser = isGuest;
    userId = userId;
    userName = '';

    connectedCallback() {
        if (!this.isGuestUser) {
            getCurrentUserInfo()
                .then(data => {
                    if (data && data.userName) {
                        this.userName = data.userName;
                    }
                })
                .catch(err => {
                    console.warn('Error fetching user info imperatively:', err);
                });
        }
    }

    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD] })
    wiredUserRecord({ data, error }) {
        if (data) {
            const name = getFieldValue(data, NAME_FIELD);
            if (name) {
                this.userName = name;
            }
        }
    }

    @wire(getCurrentUserInfo)
    wiredUserInfo({ data, error }) {
        if (data) {
            this.isGuestUser = Boolean(data.isGuest);
            if (data.userName) {
                this.userName = data.userName;
            }
        }
    }

    get isAuthenticated() {
        return !this.isGuestUser;
    }

    get displayName() {
        return this.userName || 'Customer';
    }
}
