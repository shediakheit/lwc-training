import { LightningElement } from 'lwc';

export default class ex3Parent extends LightningElement {
    parentTrackedStatus = 'Deselected';

    handleChildToggle(event) {
        this.parentTrackedStatus = event.detail.isSelected ? 'Selected' : 'Deselected';
    }
}
