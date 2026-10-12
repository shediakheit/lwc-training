import { LightningElement, api, wire, track } from 'lwc';
import getOpportunityLeaseType from '@salesforce/apex/QuoteController.getOpportunityLeaseType';
import saveQuote from '@salesforce/apex/QuoteController.saveQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateQuote extends LightningElement {
    @api recordId; 
    @track leaseType;
    @track quoteRecord = {};
    
    isLoading = true;
    error;
 
    get retailOptions() {
        return [
            { label: 'Apparel and Accessories', value: 'Apparel and Accessories' },
            { label: 'Food and Beverages', value: 'Food and Beverages' },
            { label: 'Books & Stationary', value: 'Books & Stationary' },
            { label: 'Family Entertainment Center', value: 'Family Entertainment Center' }
        ];
    }
 
    @wire(getOpportunityLeaseType, { recordId: '$recordId' })
    wiredOpp({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.leaseType = data;
            
            if (this.leaseType === 'Land') {
                this.quoteRecord.Payment_Terms__c = 4;
            }
        } else if (error) {
            this.showToast('Error', 'Could not load Opportunity details', 'error');
        }
    }
 
    get isOfficeOrRetail() {
        return this.leaseType === 'Office' || this.leaseType === 'Retail';
    }

    get isRetail() {
        return this.leaseType === 'Retail';
    }

    get isLand() {
        return this.leaseType === 'Land';
    }

    get landPaymentTerms() {
        return 4;
    }

    get calculatedEndDate() {
        return this.quoteRecord.Proposed_End_Date__c;
    }
 
    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this.quoteRecord[field] = event.target.value;
    }

    handleLandStartChange(event) {
        this.quoteRecord.Proposed_Start_Date__c = event.target.value;
        this.calculateLandEndDate();
    }

    // Specific handler for Land Duration (triggers recalc)
    handleDurationChange(event) {
        this.quoteRecord.Proposed_Duration__c = event.target.value;
        this.calculateLandEndDate();
    }

   calculateLandEndDate() {
    const startDateStr = this.quoteRecord.Proposed_Start_Date__c;
    const duration = parseInt(this.quoteRecord.Proposed_Duration__c, 10);

    if (startDateStr && duration) {
        
        let startDate = new Date(startDateStr);
        let endYear = startDate.getFullYear() + duration;
        startDate.setFullYear(endYear);
         
        this.quoteRecord.Proposed_End_Date__c = startDate.toISOString().split('T')[0];
    }
}

    handleSave() {
         
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid) {
            this.isLoading = true;
            saveQuote({ quoteRec: this.quoteRecord, oppId: this.recordId })
                .then(() => {
                    this.showToast('Success', 'Quote created successfully', 'success');
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
