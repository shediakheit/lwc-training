import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// 1. Added these imports for dynamic picklist mapping
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

import getCases from '@salesforce/apex/CaseController.getCases';
import createCaseRecord from '@salesforce/apex/CaseController.createCaseRecord';

const COLUMNS = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Description', fieldName: 'Description', type: 'text' },
    { label: 'Status', fieldName: 'Status', type: 'text' }  
];

export default class CaseManager extends LightningElement {
    columns = COLUMNS;
    searchKey = '';
    
    // 2. Added reactive tracks for handling status filters locally
    selectedStatus = ''; 
    statusOptions = [];  

    @track newSubject = '';
    @track newDescription = '';
    
    wiredCasesResult;
    cases = [];
    error;

    // 3. Added the wire to pull picklist choices dynamically from Salesforce
    @wire(getPicklistValuesByRecordType, {
        objectApiName: CASE_OBJECT,
        recordTypeId: '012000000000000AAA' 
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            const statusValues = data.picklistFieldValues.Status.values;
            this.statusOptions = [
                { label: 'All Statuses', value: '' },
                ...statusValues.map(picklist => ({
                    label: picklist.label,
                    value: picklist.value
                }))
            ];
        } else if (error) {
            this.error = error;
        }
    }

    // 4. Apex wire stays simple (Only watches searchKey)
    @wire(getCases, { searchKey: '$searchKey' })
    wiredCases(result) {
        this.wiredCasesResult = result;
        if (result.data) {
            this.cases = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.cases = undefined;
        }
    }

    // 5. Added client-side Javascript filtering logic
    get filteredCases() {
        if (!this.selectedStatus) {
            return this.cases; // If 'All Statuses' is selected, return everything Apex found
        }
        return this.cases.filter(item => item.Status === this.selectedStatus);
    }

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    // 6. Added handler to update selected status locally
    handleStatusChange(event) {
        this.selectedStatus = event.target.value;
    }

    handleFormChange(event) {
        const field = event.target.dataset.field;
        if (field === 'subject') {
            this.newSubject = event.target.value;
        } else if (field === 'description') {
            this.newDescription = event.target.value;
        }
    }

    async handleCreateCase() {
        if (!this.newSubject) {
            this.showToast('Error', 'Subject is required to create a case', 'error');
            return;
        }
        try {
            await createCaseRecord({ 
                subject: this.newSubject, 
                description: this.newDescription 
            });
            this.showToast('Success', 'Case created successfully', 'success');
            this.newSubject = '';
            this.newDescription = '';
            return refreshApex(this.wiredCasesResult);
        } catch (error) {
            this.showToast('Error creating record', error.body.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
