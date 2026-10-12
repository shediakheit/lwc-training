import { LightningElement, api, wire, track } from 'lwc';
import getRelatedContacts from '@salesforce/apex/AccountContactController.getRelatedContacts';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    { label: 'First Name', fieldName: 'FirstName' },
    { label: 'Last Name', fieldName: 'LastName' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    {
        type: 'button-icon',
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error',
            title: 'Delete'
        }
    }
];

export default class AccountManager extends LightningElement {
    @api recordId; // Automatically gets the Account Id
    @track contacts = [];
    columns = COLUMNS;
    
    isModalOpen = false;
    isCreateMode = false;
    wiredContactsResult; // Holds the wired result for refreshing

    // Fetch Contacts
    @wire(getRelatedContacts, { accountId: '$recordId' })
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
        } else if (result.error) {
            this.showToast('Error', 'Error loading contacts', 'error');
        }
    }

    get modalTitle() {
        return this.isCreateMode ? 'Create New Contact' : 'Related Contacts';
    }

    get isTableEmpty() {
        return this.contacts && this.contacts.length === 0;
    }

    // Modal Control
    openModal() {
        this.isModalOpen = true;
        this.isCreateMode = false; // Always start on table view
    }

    closeModal() {
        this.isModalOpen = false;
    }

    switchToCreateMode() {
        this.isCreateMode = true;
    }

    switchToTableMode() {
        this.isCreateMode = false;
    }

    // Handle Delete Action
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.deleteContact(row.Id);
        }
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

    // Handle Create Success
    handleSuccess(event) {
        this.showToast('Success', 'New contact created', 'success');
        this.switchToTableMode();
        refreshApex(this.wiredContactsResult); // Refresh the table
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
