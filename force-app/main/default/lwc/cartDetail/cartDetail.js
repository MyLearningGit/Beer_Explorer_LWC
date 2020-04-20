import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getItems from '@salesforce/apex/BeerController.getItems';

export default class CartDetail extends LightningElement {

    @track cartId;
    @track items;
    @track totalAmount = 0.0;
    @track totalItems;
    @track errors;

    @wire(CurrentPageReference) setCurrentPageReference(data) {
        if (data) {
            this.cartId = data.state.c__cartId;
        }
    }

    connectedCallback() {
        this.cartItems();
    }

    cartItems() {
        getItems({
            cartId: this.cartId
        }).then(result => {
            const cartItems = JSON.parse(result);
            console.log(cartItems)
            this.errors = undefined;
            this.items = cartItems;
            this.totalItems = cartItems.length;
            cartItems.forEach(item => {
                this.totalAmount = this.totalAmount + item.Item_Amount__c
            });
        }).catch(error => {
            this.errors = error;
            this.items = undefined;
        });
    }

}