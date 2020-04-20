declare module "@salesforce/apex/BeerController.getCartId" {
  export default function getCartId(): Promise<any>;
}
declare module "@salesforce/apex/BeerController.createCartItems" {
  export default function createCartItems(param: {cartId: any, beerId: any, amount: any}): Promise<any>;
}
declare module "@salesforce/apex/BeerController.searchBeer" {
  export default function searchBeer(param: {searchParam: any}): Promise<any>;
}
declare module "@salesforce/apex/BeerController.getItems" {
  export default function getItems(param: {cartId: any}): Promise<any>;
}
