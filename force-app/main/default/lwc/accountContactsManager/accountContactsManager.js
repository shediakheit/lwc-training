import { LightningElement, api, wire, track } from 'lwc';
import getRelatedContacts from '@salesforce/apex/AccountContactController.getRelatedContacts';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class AccountContactsManager extends LightningElement {
    @api recordId;
    @track contacts = [];
    
    isCreateMode = false;
    wiredContactsResult;

    @wire(getRelatedContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading contacts', 'error');
        }
    }

    // Dynamic title for the main card
    get cardTitle() {
        return this.isCreateMode ? 'Create New Contact' : 'Related Contacts';
    }

    get isTableEmpty() {
        return this.contacts && this.contacts.length === 0;
    }

    switchToCreateMode() {
        this.isCreateMode = true;
    }

    switchToTableMode() {
        this.isCreateMode = false;
    }

    handleDeleteContact(event) {
        const contactId = event.target.dataset.id;
        this.deleteContact(contactId);
    }

    deleteContact(contactId) {
        deleteRecord(contactId)
            .then(() => {
                this.showToast('Success', 'Contact deleted', 'success');
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {
                this.showToast('Error', 'Error deleting contact', 'error');
            });
    }

    handleSuccess(event) {
        this.showToast('Success', 'New contact created', 'success');
        this.switchToTableMode();
        refreshApex(this.wiredContactsResult);
    }
    
    handleError(event) {
         this.showToast('Error', 'Error creating contact', 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
