import { LightningElement } from 'lwc';

export default class ex3Child extends LightningElement {
    isSelected = false;

    get status() {
        return this.isSelected ? 'Selected' : 'Deselected';
    }

    handleToggle() {
        this.isSelected = !this.isSelected;
        this.dispatchEvent(new CustomEvent('childtoggle', {
            detail: { isSelected: this.isSelected }
        }));
    }
}
