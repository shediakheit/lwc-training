import { LightningElement } from 'lwc';

export default class Ex3c2 extends LightningElement {
    childVariable = 'Hello from Child!';

    sendDataToParent() {
        const customEvent = new CustomEvent('myevent', {
            detail: this.childVariable
        });
        
        this.dispatchEvent(customEvent);
    }
}
