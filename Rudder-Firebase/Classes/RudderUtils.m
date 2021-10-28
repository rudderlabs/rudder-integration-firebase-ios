//
//  RudderUtils.h
//  Rudder-Firebase
//
//  Created by Abhishek Pandey on 28/10/21.
//

#import "RudderUtils.h"

@implementation RudderUtils

NSArray * IDENTIFY_RESERVED_KEYWORDS;
NSArray *TRACK_RESERVED_KEYWORDS;
NSDictionary *ECOMMERCE_EVENTS_MAPPING;
NSDictionary *PRODUCT_PROPERTIES_MAPPING;
NSArray *EVENT_WITH_PRODUCTS;
NSDictionary *ECOMMERCE_PROPERTY_MAPPING;

+ (void)initialize {
    
    if(!IDENTIFY_RESERVED_KEYWORDS) {
        IDENTIFY_RESERVED_KEYWORDS =  [[NSArray alloc] initWithObjects:@"age", @"gender", @"interest", nil];
        TRACK_RESERVED_KEYWORDS = [[NSArray alloc] initWithObjects:@"product_id", @"name", @"category", @"quantity", @"price", @"currency", @"value", @"revenue", @"total", @"order_id", @"tax", @"shipping", @"coupon", @"cart_id", @"payment_method", @"query", @"list_id", @"promotion_id", @"creative", @"affiliation", @"share_via", @"products", kFIRParameterScreenName, kFIREventScreenView,
                                                  nil];
        
        ECOMMERCE_EVENTS_MAPPING = @{
            ECommPaymentInfoEntered : kFIREventAddPaymentInfo,
            ECommProductAdded : kFIREventAddToCart,
            ECommProductAddedToWishList : kFIREventAddToWishlist,
            ECommCheckoutStarted : kFIREventBeginCheckout,
            ECommOrderCompleted : kFIREventPurchase,
            ECommOrderRefunded : kFIREventRefund,
            ECommProductsSearched : kFIREventSearch,
            ECommCartShared : kFIREventShare,
            ECommProductShared : kFIREventShare,
            ECommProductViewed : kFIREventViewItem,
            ECommProductListViewed : kFIREventViewItemList,
            ECommProductRemoved : kFIREventRemoveFromCart,
            ECommProductClicked : kFIREventSelectContent,
            ECommPromotionViewed : kFIREventViewPromotion,
            ECommPromotionClicked : kFIREventSelectPromotion,
            ECommCartViewed : kFIREventViewCart
        };

        PRODUCT_PROPERTIES_MAPPING = @{
            @"product_id" : kFIRParameterItemID,
            @"id" : kFIRParameterItemID,
            @"name" : kFIRParameterItemName,
            @"category" : kFIRParameterItemCategory,
            @"quantity" : kFIRParameterQuantity,
            @"price" : kFIRParameterPrice
        };

        EVENT_WITH_PRODUCTS = [[NSArray alloc] initWithObjects:
                               kFIREventAddPaymentInfo,
                               kFIREventAddToCart,
                               kFIREventAddToWishlist,
                               kFIREventBeginCheckout,
                               kFIREventRemoveFromCart,
                               kFIREventViewItem,
                               kFIREventViewItemList,
                               kFIREventPurchase,
                               kFIREventRefund,
                               kFIREventViewCart,
                               kFIREventSelectContent,
                               nil];
        
        ECOMMERCE_PROPERTY_MAPPING = @{
            @"payment_method" : kFIRParameterPaymentType,
            @"coupon" : kFIRParameterCoupon,
            @"query" : kFIRParameterSearchTerm,
            @"list_id" : kFIRParameterItemListID,
            @"promotion_id" : kFIRParameterPromotionID,
            @"creative" : kFIRParameterCreativeName,
            @"affiliation" : kFIRParameterAffiliation,
            @"order_id" : kFIRParameterTransactionID,
            @"share_via" : kFIRParameterMethod
        };;

    }
        
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }

    return self;
}

-(NSString *) getTrimStringKey:(NSString *) key maxLength:(NSUInteger)trimLength {
    NSString * event = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    if([event length] > trimLength) {
        event = [event substringToIndex:trimLength];
    }
    return event;
}

-(BOOL) isEmpty:(NSObject *) value {
    if (value == nil) {
        return true;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value isEqualToString:@""];
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)value count] == 0;
    }
    if ([value isKindOfClass:[NSMutableArray class]]) {
        return [(NSMutableArray *)value count] == 0;
    }
    return false;
}

-(BOOL) isNumber:(NSObject *)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        return true;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [formatter numberFromString:[NSString stringWithFormat:@"%@", value]];
        return !!number; // If the string is not numeric, number will be nil
    }
    return false;
}

@end
