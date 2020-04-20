import { LightningElement, track, wire } from 'lwc';
import searchBeer from '@salesforce/apex/BeerController.searchBeer';
import cartIcon from '@salesforce/resourceUrl/cart';
import getCartId from '@salesforce/apex/BeerController.getCartId';
import createCartItems from '@salesforce/apex/BeerController.createCartItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class BeerList extends NavigationMixin(LightningElement) {

    @track beerRecords;
    @track errors;
    @track cart = cartIcon;
    @track itemsInCart = 0;
    @track cartId;

    connectedCallback() {
        this.defaultCartId();
    }

    defaultCartId() {
        getCartId().then(result => {
            const wrapper = JSON.parse(result);
            this.cartId = wrapper.cartId;
            this.itemsInCart = wrapper.count;
        }).catch(error => {
            console.log(error);
            this.cartId = undefined;
        });
    }

    navigateToCartDetail() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Cart_Detail'
            },
            state: {
                c__cartId: this.cartId
            }
        }, true);
    }

    addToCart(event) {
        const selectedBeerId = event.detail;
        const beer = this.beerRecords.find(beer => beer.Id === selectedBeerId);
        const beerId = beer.Id;
        const amount = beer.Price__c;
        createCartItems(
            {
                cartId: this.cartId,
                beerId: beerId,
                amount: amount
            }
        ).then(result => {
            const showToast = new ShowToastEvent({
                title: 'SUCCESS',
                message: beer.Name + ' is succesfully added to the cart.',
                variant: 'success'
            });
            this.dispatchEvent(showToast);
            this.itemsInCart = this.itemsInCart + 1;
        }).catch(error => {
            const showToast = new ShowToastEvent({
                title: 'ERROR',
                message: 'Unable to add ' + beer.Name + ' to the cart.',
                variant: 'error'
            });
            console.log(error);
        });
    }

    @wire(searchBeer) wiredBeerRecords({ error, data }) {
        this.beerRecords = data;
        this.errors = error;
    }

    handleEvent(event) {
        const searchVal = event.detail;
        searchBeer({ searchParam: searchVal }).then(result => {
            this.errors = undefined;
            this.beerRecords = result;
        }).catch(error => {
            console.log(error)
            this.errors = error;
            this.beerRecords = undefined;
        });
    }

}