public with sharing class BeerController {
    public BeerController() {

    }

    public static String generateCartId(){
        String CharList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
        Integer position;
        Integer LengthRequired = 30;
        String Res = '';
        for(Integer i = 0; i <= LengthRequired; i++) {
            position = Integer.valueof(String.valueof(Math.roundToLong(CharList.length()*Math.random()))) -1;
            Res += CharList.substring(position,position+1);
        }
        return res;
    }

    public static String getCouponInformation(String name){
        Coupon__c couponRec = [SELECT Id, Name, Price__c FROM Coupon__c WHERE Name = :name AND Expired__c = false];
        return couponRec.Id;
    }

    @AuraEnabled(Cacheable = false)
    public static string getCartId(){
        List<Cart__c> cartInfo = [SELECT Id, Name FROM Cart__c WHERE User__c = :UserInfo.getUserId() AND Cart_Status__c = 'Open'
        AND Is_Active__c = true];
        if(cartInfo != null && cartInfo.size()>0){
            List<Cart_Item__c> cartItems = [SELECT Id, Beer__c, Cart__c, Item_Amount__c, Item_Quantity__c	, Name, Total_Amount__c FROM Cart_Item__c WHERE Cart__c = :cartInfo.get(0).Id];
            Decimal cartItemsCount = 0;
            for(Cart_Item__c item : cartItems){
                cartItemsCount += item.Item_Quantity__c;
            }
            WrapperClass wrapper = new WrapperClass();
            wrapper.cartId = cartInfo.get(0).Id;
            wrapper.count = cartItemsCount;
            wrapper.items = cartItems;
            return JSON.serialize(wrapper);
        }else{
            Cart__c defaultCart = new Cart__c();
            defaultCart.Cart_Id__c = String.valueOf(Math.random());
            defaultCart.Cart_Status__c = 'Open';
            defaultCart.Is_Active__c = true;
            defaultCart.Coupon__c = getCouponInformation('Default');
            defaultCart.User__c = UserInfo.getUserId();
            insert defaultCart;
            WrapperClass wrapper = new WrapperClass();
            wrapper.cartId = defaultCart.Id;
            wrapper.count = 0;
            wrapper.items = null;
            return JSON.serialize(wrapper);
        }
    }

    public static Map<Id,Cart_Item__c> getCartItems(String cartId){
        Map<Id,Cart_Item__c> cartItems = new Map<Id,Cart_Item__c>();
        for(Cart_Item__c cart : [SELECT Id, Beer__c, Cart__c, Item_Amount__c, Item_Quantity__c	, Name, Total_Amount__c FROM Cart_Item__c WHERE Cart__c = :cartId]){
            cartItems.put(cart.Beer__c, cart);
        }
        return cartItems;
    }

    @AuraEnabled
    public static void createCartItems(String cartId, String beerId, Decimal amount){
        Cart_Item__c cartItem = new Cart_Item__c();
        Map<Id,Cart_Item__c> cartItems = getCartItems(cartId);
        if(cartItems.containsKey(beerId)){
            Cart_Item__c item = cartItems.get(beerId);
            item.Item_Amount__c = item.Item_Amount__c + amount;
            item.Item_Quantity__c = item.Item_Quantity__c + 1;
            update item;
        }else{
            cartItem.Cart__c = cartId;
            cartItem.Beer__c = beerId;
            cartItem.Item_Amount__c = amount;
            cartItem.Item_Quantity__c = 1;
            insert cartItem;
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<SObject> searchBeer(String searchParam){
        String likeParam = '%'+searchParam+'%';
        String Query = '';
        if(searchParam!=null){
            Query = 'SELECT Id, Name, Alcohol__c, brewery_id__c, brewery_Name__c, Consumed_Quantity__c, Id__c, Image__c, Price__c, Remaining_Quantity__c, Tags__c, Total_Quantity__c FROM Beer__c WHERE Name LIKE :likeParam LIMIT 50';
        }else{
            Query = 'SELECT Id, Name, Alcohol__c, brewery_id__c, brewery_Name__c, Consumed_Quantity__c, Id__c, Image__c, Price__c, Remaining_Quantity__c, Tags__c, Total_Quantity__c FROM Beer__c  LIMIT 50';
        }
        List<SObject> beerRecords = Database.query(Query);
        return beerRecords;
    }

    @AuraEnabled
    public static string getItems(String cartId){
        List<Cart_Item__c> cartItems = [SELECT Id, Beer__c, Cart__c, Item_Amount__c, Item_Quantity__c, Name, Total_Amount__c FROM Cart_Item__c WHERE Cart__c = :cartId];
        return JSON.serialize(cartItems);
    }

    public class WrapperClass{

        @AuraEnabled
        public Decimal count {get; set;}
        @AuraEnabled
        public String cartId {get; set;}
        @AuraEnabled
        public List<Cart_Item__c> items {get; set;}
        
    }
}
