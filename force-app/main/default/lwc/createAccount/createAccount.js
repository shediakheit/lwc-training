import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import createNewAccount from '@salesforce/apex/AccountController.createNewAccount';
import { refreshApex } from '@salesforce/apex';
import {NavigationMixin} from 'lightning/navigation';

export default class CreateAccount extends LightningElement {
    accounts;
    maxRecords = 10; 
    newAccountName = ''; 
    errors;
    wiredAccountsResult; 

    @wire(getAccounts, { maxRecords: "$maxRecords" }) 
    wiredGetAccounts(result) {
        this.wiredAccountsResult = result; 
        const { error, data } = result;
        if (data) {
            this.accounts = data;
            this.errors = undefined;
        } else if (error) {
            this.accounts = undefined;
            this.errors = error;
        }
    }

    handleMaxAccountsChange(event) {
        this.maxRecords = event.target.value;
    }

    handleNameChange(event) {
        this.newAccountName = event.target.value;
    }

    handleCreateAccount() {
        if (!this.newAccountName) {
            return;
        }
        // this.newAccountName = ''; 
        //         return refreshApex(this.wiredAccountsResult); 
        createNewAccount({ accountName: this.newAccountName })
            .then(() => {
                console.log('result: ', result)
            })
            
            .catch((error) => {
                this.errors = error;
            });
            
    }
}
