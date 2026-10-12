import { LightningElement } from 'lwc';

export default class parentComponent extends LightningElement {
    
    handleIncrement() {
        const childComponentRef = this.template.querySelector('.child-comp');
         
        if (childComponentRef) {
            childComponentRef.incrementCounter();
        }
    }
}
