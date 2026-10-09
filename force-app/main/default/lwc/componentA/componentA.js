import COMPONENT_COMMUNICATION_CHANNEL from '@salesforce/messageChannel/ComponentCommunication'
import {publish, MessageContext} from 'lightning/messageService';
import {LightningElement, wire} from 'lwc';
export default class ComponentA extends LightningElement {
    @wire(MessageContext) messageContext;
    handleButtonClicked() {
        const msgInput = this.template.querySelector('lightning-input').value;
        const payload = {message: msgInput};
        console.log('payload: ', JSON.stringify(payload));
        publish(this.messageContext, COMPONENT_COMMUNICATION_CHANNEL,payload);
    }
}