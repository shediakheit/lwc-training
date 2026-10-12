import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAccountOpportunities from '@salesforce/apex/AccountOpportunityController.getAccountOpportunities';
import updateOpportunityStage from '@salesforce/apex/AccountOpportunityController.updateOpportunityStage';

export default class AccountOpportunityMonitor extends LightningElement {
    @track accountData;
    @track error;
    
    // Modal & Selection States
    @track isModalOpen = false;
    @track selectedOppId;
    @track selectedStage = '';
    
    wiredResult;

    stageOptions = [
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    @wire(getAccountOpportunities)
    wiredAccounts(result) {
        this.wiredResult = result;
        if (result.data) {
            this.accountData = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.accountData = undefined;
        }
    }

    get isUpdateDisabled() {
        return !this.selectedStage;
    }

    handleMarkAsClosed(event) {
        this.selectedOppId = event.target.dataset.id;
        this.selectedStage = '';
        this.isModalOpen = true;
    }

    handleStageChange(event) {
        this.selectedStage = event.detail.value;
    }

    closeModal() {
        this.isModalOpen = false;
        this.selectedOppId = null;
        this.selectedStage = '';
    }

    async handleSaveStage() {
        try {
            await updateOpportunityStage({ 
                opportunityId: this.selectedOppId, 
                stageName: this.selectedStage 
            });
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Opportunity updated successfully',
                    variant: 'success'
                })
            );
            
            this.closeModal();
            return refreshApex(this.wiredResult);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        }
    }
}
