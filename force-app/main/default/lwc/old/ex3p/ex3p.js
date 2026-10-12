import { LightningElement } from 'lwc';

export default class Ex3p extends LightningElement {
    receivedMessage = '';

    handleChildData(event) {
        this.receivedMessage = event.detail;
        console.log('Received data:', this.receivedMessage);
    }
}
