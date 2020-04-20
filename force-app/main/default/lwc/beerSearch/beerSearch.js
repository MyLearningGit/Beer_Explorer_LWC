import { LightningElement, track } from 'lwc';

export default class BeerSearch extends LightningElement {

    @track searchVal;

    handleChange(event) {
        this.searchVal = event.target.value;
        const searchEvent = new CustomEvent('search', { detail: this.searchVal });
        this.dispatchEvent(searchEvent);
    }

}