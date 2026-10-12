import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateContactModal extends LightningModal {
    @api accountId;

    handleCancel() {
        this.close('cancel');
    }

    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contact created successfully!',
                variant: 'success',
            })
        );
        this.close('success'); // Sends result status back to parent component
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating record',
                message: event.detail.detail,
                variant: 'error',
            })
        );
    }
}
