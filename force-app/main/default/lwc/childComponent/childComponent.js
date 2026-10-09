import { LightningElement, api } from 'lwc';

export default class childComponent extends LightningElement {
    _counter = 0;

    @api
    incrementCounter() {
        this._counter++;
    }
}
