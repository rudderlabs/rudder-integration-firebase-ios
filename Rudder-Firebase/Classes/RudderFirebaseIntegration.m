//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderFirebaseIntegration.h"

@implementation RudderFirebaseIntegration

#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RSClient *)client  withRudderConfig:(nonnull RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        _GOOGLE_RESERVED_KEYWORDS = [[NSArray alloc] initWithObjects:@"age", @"gender", @"interest", nil];
        _RESERVED_PARAM_NAMES = [[NSArray alloc] initWithObjects:@"product_id", @"name", @"category", @"quantity", @"price", @"currency", @"value", @"revenue", @"total", @"order_id", @"tax", @"shipping", @"coupon", @"cart_id", @"payment_method", @"query", @"list_id", @"promotion_id", @"creative", @"affiliation", @"share_via", kFIRParameterScreenName, kFIREventScreenView, nil];
        
        _EVENTS_MAPPING = @{
            ECommPaymentInfoEntered : kFIREventAddPaymentInfo,
            ECommProductAdded : kFIREventAddToCart,
            ECommProductAddedToWishList : kFIREventAddToWishlist,
            ECommCheckoutStarted : kFIREventBeginCheckout,
//            ECommOrderCompleted : kFIREventEcommercePurchase,
            ECommOrderCompleted : kFIREventPurchase,
//            ECommOrderRefunded : kFIREventPurchaseRefund,
            ECommOrderRefunded : kFIREventRefund,
            ECommProductsSearched : kFIREventSearch,
            ECommCartShared : kFIREventShare,
            ECommProductShared : kFIREventShare,
            ECommProductViewed : kFIREventViewItem,
            ECommProductListViewed : kFIREventViewItemList,
            ECommProductRemoved : kFIREventRemoveFromCart,
            ECommProductClicked : kFIREventSelectContent,
//            ECommPromotionViewed : kFIREventPresentOffer,
            ECommPromotionViewed : kFIREventViewPromotion,
            ECommPromotionClicked : kFIREventSelectPromotion,
            ECommCartViewed : kFIREventViewCart
        };
        
        _PRODUCTS_MAPPING = @{
            @"product_id" : kFIRParameterItemID,
            @"id" : kFIRParameterItemID,
            @"name" : kFIRParameterItemName,
            @"category" : kFIRParameterItemCategory,
            @"quantity" : kFIRParameterQuantity,
            @"price" : kFIRParameterPrice
        };

        _PRODUCT_EVENT = [NSSet setWithObjects:
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
                                nil];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([FIRApp defaultApp] == nil){
                [FIRApp configure];
                [RSLogger  logDebug:@"Rudder-Firebase is initialized"];
            } else {
                [RSLogger  logDebug:@"Firebase core already initialized - skipping on Rudder-Firebase"];
            }
        });
    }
    return self;
}

- (NSString*)getStringValue:(NSObject *)value withError:(NSString**)error{
    NSString* jsonString = nil;
    if (value != nil) {
        NSError* err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                     options:kNilOptions
                                                     error:&err];

        if (! jsonData) {
            if (error != NULL) {
                *error = err.localizedDescription;
            }
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if([jsonString length] > 100) {
                if (error != NULL) {
                    *error = @"property value's length is greater than 100";
                }
                jsonString = nil;
            }
        }
    }
    return jsonString;
}


- (void)dump:(RSMessage *)message {
    if (message != nil) {
        [self processRudderEvent:message];
    }
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if (type != nil) {
        NSDictionary *properties;
        NSMutableDictionary *params;
        if ([type  isEqualToString: @"identify"]) {
            NSString *userId = message.userId;
            if (userId != nil && ![userId isEqualToString:@""]) {
                [RSLogger logDebug:@"Setting userId to firebase"];
                [FIRAnalytics setUserID:userId];
            }
            NSDictionary *traits = message.context.traits;
            if (traits != nil) {
                for (NSString *key in [traits keyEnumerator]) {
                    if([key isEqualToString:@"userId"]) continue;
                    NSString* firebaseKey = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                    if([firebaseKey length] > 24) {
                        firebaseKey = [firebaseKey substringToIndex:[@24 unsignedIntegerValue]];
                    }
                    if (![_GOOGLE_RESERVED_KEYWORDS containsObject:firebaseKey]) {
                        [RSLogger logDebug:[NSString stringWithFormat:@"Setting userProperty to Firebase: %@", firebaseKey]];
                        [FIRAnalytics setUserPropertyString:traits[key] forName:firebaseKey];
                    }
                }
            }
        } else if ([type isEqualToString:@"screen"]) {
            [RSLogger logInfo:@"Rudder doesn't support screen calls for Firebase Native SDK mode as screen recording in Firebase works out of the box"];
        } else if ([type isEqualToString:@"track"]) {
            NSString *eventName = message.event;
            if (!isEmpty(eventName)) {
                NSString *firebaseEvent;
                properties = message.properties;
                params = [[NSMutableDictionary alloc] init];
                if ([eventName isEqualToString:@"Application Opened"]) {
                    firebaseEvent = kFIREventAppOpen;
                }
                // Handle E-Commerce event
                else if (_EVENTS_MAPPING[eventName]){
                    firebaseEvent = _EVENTS_MAPPING[eventName];
                    if (properties != nil && [properties count]) {
                        if ([firebaseEvent isEqualToString:kFIREventShare]) {
                            if (properties[@"cart_id"]) {
                                [params setValue:properties[@"cart_id"] forKey:kFIRParameterItemID];
                            } else if (properties[@"product_id"]) {
                                [params setValue:properties[@"product_id"] forKey:kFIRParameterItemID];
                            }
                        }
                        else if ([firebaseEvent isEqualToString:kFIREventViewPromotion] || [firebaseEvent isEqualToString:kFIREventSelectPromotion]) {
                            if (properties[@"name"]) {
                                [params setValue:properties[@"name"] forKey:kFIRParameterPromotionName];
                            }
                        }
                        else if ([firebaseEvent isEqualToString:kFIREventSelectContent]) {
                            if (properties[@"product_id"]) {
                                [params setValue:properties[@"product_id"] forKey:kFIRParameterItemID];
                            }
                        }
                        else if ([eventName isEqualToString:ECommProductShared]) {
                            [params setValue:properties[@"product"] forKey:kFIRParameterContentType];
                        }
                        else if ([eventName isEqualToString:ECommCartShared]) {
                            [params setValue:properties[@"cart"] forKey:kFIRParameterContentType];
                        }
                        [self handleECommerce:params properties:properties firebaseEvent:firebaseEvent];
                    }
                }
            }
            
            /*
            NSString *eventName = message.event;
            NSDictionary *properties = message.properties;
            if (eventName != nil && ![eventName isEqualToString:@""]) {
                NSString *firebaseEvent = @"";
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                if ([eventName isEqualToString:ECommPaymentInfoEntered]) {
                    firebaseEvent = kFIREventAddPaymentInfo;
                } else if ([eventName isEqualToString:ECommProductAdded]) {
                    firebaseEvent = kFIREventAddToCart;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductAddedToWishList]) {
                    firebaseEvent = kFIREventAddToWishlist;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:@"Application Opened"]) {
                    firebaseEvent = kFIREventAppOpen;
                } else if ([eventName isEqualToString:ECommCheckoutStarted]) {
                    firebaseEvent = kFIREventBeginCheckout;
                    [self addOrderProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommOrderCompleted]) {
                    firebaseEvent = kFIREventEcommercePurchase;
                    [self addOrderProperties:params properties:properties];
                    [self addProductProperties:params properties:properties[@"products"]];
                } else if ([eventName isEqualToString:ECommOrderRefunded]) {
                    firebaseEvent = kFIREventPurchaseRefund;
                    [self addOrderProperties:params properties:properties];
                    [self addProductProperties:params properties:properties[@"products"]];
                } else if ([eventName isEqualToString:ECommProductsSearched]) {
                    firebaseEvent = kFIREventSearch;
                    [self addSearchProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductShared]) {
                    firebaseEvent = kFIREventShare;
                    [self addShareProperties:params properties:properties];
                    params[kFIRParameterContentType] = @"product";
                } else if ([eventName isEqualToString:ECommCartShared]) {
                    firebaseEvent = kFIREventShare;
                    [self addShareProperties:params properties:properties];
                    params[kFIRParameterContentType] = @"cart";
                } else if ([eventName isEqualToString:ECommProductViewed]) {
                    firebaseEvent = kFIREventViewItem;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductListViewed]) {
                    firebaseEvent = kFIREventViewItemList;
                    [self addProductListProperty:params properties:properties];
                    [self addProductProperties:params properties:properties[@"products"]];
                } else if ([eventName isEqualToString:ECommProductRemoved]) {
                    firebaseEvent = kFIREventRemoveFromCart;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommCheckoutStepViewed]) {
                    firebaseEvent = kFIREventCheckoutProgress;
                    [self addCheckoutProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommProductClicked]) {
                    firebaseEvent = kFIREventSelectContent;
                    [self addProductProperties:params properties:properties];
                } else if ([eventName isEqualToString:ECommPromotionViewed]) {
                    firebaseEvent = kFIREventPresentOffer;
                } else {
                    firebaseEvent = [[[eventName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                    if([firebaseEvent length] > 40) {
                        firebaseEvent = [firebaseEvent substringToIndex:[@40 unsignedIntegerValue]];
                    }
                }
                if(![firebaseEvent isEqualToString:@""]) {
                    if ([params count] == 0) {
                        [self attachAllCustomProperties:params properties:properties];
                    } else {
                        [self attachUnreservedCustomProperties:params properties:properties];
                    }
                    [RSLogger logDebug:[NSString stringWithFormat:@"Logged \"%@\" to Firebase", firebaseEvent]];
                    [FIRAnalytics logEventWithName:firebaseEvent parameters:params];
                }
            }
             */
        } else {
            [RSLogger logWarn:@"Message type is not recognized"];
        }
    }
}

-(void) handleECommerce:(NSMutableDictionary *) params properties: (NSDictionary *) properties firebaseEvent:(NSString *) firebaseEvent {
    if (properties[@"revenue"] && [self isCompatibleWithRevenue:properties[@"revenue"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"revenue"] doubleValue]] forKey:kFIRParameterValue];
    } else if (properties[@"value"] && [self isCompatibleWithRevenue:properties[@"value"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"value"] doubleValue]] forKey:kFIRParameterValue];
    } else if (properties[@"total"] && [self isCompatibleWithRevenue:properties[@"total"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"total"] doubleValue]] forKey:kFIRParameterValue];
    }
    // Handle Products array or Product at the root level for the allowed events
    if ([_PRODUCT_EVENT containsObject:firebaseEvent]) {
        [self handleProducts:params properties:properties];
    }
    if (properties[@"payment_method"]) {
        [params setValue:properties[@"payment_method"] forKey:kFIRParameterPaymentType];
    }
    
    
    
    
    if (properties[@"coupon"]) {
        [params setValue:properties[@"coupon"] forKey:kFIRParameterCoupon];
    }
    if (properties[@"currency"]) {
        [params setValue:properties[@"currency"] forKey:kFIRParameterCurrency];
    } else {
        [params setValue:properties[@"currency"] forKey:@"USD"];
    }
    if (properties[@"query"]) {
        [params setValue:properties[@"query"] forKey:kFIRParameterSearchTerm];
    }
    if (properties[@"list_id"]) {
        [params setValue:properties[@"list_id"] forKey:kFIRParameterItemListID];
    }
    if (properties[@"promotion_id"]) {
        [params setValue:properties[@"promotion_id"] forKey:kFIRParameterPromotionID];
    }
    if (properties[@"creative"]) {
        [params setValue:properties[@"creative"] forKey:kFIRParameterCreativeName];
    }
    if (properties[@"affiliation"]) {
        [params setValue:properties[@"affiliation"] forKey:kFIRParameterAffiliation];
    }
    if (properties[@"shipping"]) {
        [params setValue:properties[@"shipping"] forKey:kFIRParameterShipping];
    }
    if (properties[@"tax"]) {
        [params setValue:properties[@"tax"] forKey:kFIRParameterTax];
    }
    if (properties[@"order_id"]) {
        [params setValue:properties[@"order_id"] forKey:kFIRParameterTransactionID];
    }
    if (properties[@"share_via"]) {
        [params setValue:properties[@"share_via"] forKey:kFIRParameterMethod];
    }
}

-(void) handleProducts:(NSMutableDictionary *) params properties: (NSDictionary *) properties {
    // If Products array is present
    if (properties[@"products"]) {
        
    }
    
}

BOOL isEmpty(NSString *value) {
//    if (value == nil) {
//        return true;
//    }
//    if ([value isKindOfClass:[NSString class]]) {
//        NSString *valueType = [NSString stringWithFormat:@"%@", value];
        return value == nil || [value isEqualToString:@""];
//    }
//    if ([value isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *valueType = [[NSDictionary alloc] initWithDictionary:value];
//        return [valueType count] == 0;
//    }
//    return false;
}

- (void) addCheckoutProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSNumber *step = properties[@"step"];
        if (step != nil) {
            [params setValue:step forKey:kFIRParameterCheckoutStep];
        }
    }
}

- (void) addProductListProperty: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *category = properties[@"category"];
        if (category != nil) {
            [params setValue:category forKey:kFIRParameterItemCategory];
        }
    }
}

- (void) addShareProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *cart_id = properties[@"cart_id"];
        NSString *product_id = properties[@"product_id"];
        if (cart_id != nil) {
            [params setValue:cart_id forKey:kFIRParameterItemID];
        } else if (product_id != nil) {
            [params setValue:product_id forKey:kFIRParameterItemID];
        }
        NSString *share_via = properties[@"share_via"];
        if (share_via != nil) {
            [params setValue:share_via forKey:kFIRParameterMethod];
        }
    }
}

- (void) addSearchProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *query = properties[@"query"];
        if (query != nil) {
            [params setValue:query forKey:kFIRParameterSearchTerm];
        }
    }
}

- (void) addOrderProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        if (properties[@"revenue"] && [self isCompatibleWithRevenue:properties[@"revenue"]]) {
            [params setValue:[NSNumber numberWithDouble:[properties[@"revenue"] doubleValue]] forKey:kFIRParameterValue];
        } else if (properties[@"value"] && [self isCompatibleWithRevenue:properties[@"value"]]) {
            [params setValue:[NSNumber numberWithDouble:[properties[@"value"] doubleValue]] forKey:kFIRParameterValue];
        } else if (properties[@"total"] && [self isCompatibleWithRevenue:properties[@"total"]]) {
            [params setValue:[NSNumber numberWithDouble:[properties[@"total"] doubleValue]] forKey:kFIRParameterValue];
        }
        NSString *currency = properties[@"currency"];
        if (currency != nil) {
            [params setValue:currency forKey:kFIRParameterCurrency];
        } else {
            [params setValue:@"USD" forKey:kFIRParameterCurrency];
        }
        NSString *order_id = properties[@"order_id"];
        if (order_id != nil) {
            [params setValue:order_id forKey:kFIRParameterTransactionID];
        }
        NSNumber *tax = properties[@"tax"];
        if (tax != nil) {
            [params setValue:tax forKey:kFIRParameterTax];
        }
        NSNumber *shipping = properties[@"shipping"];
        if (shipping != nil) {
            [params setValue:shipping forKey:kFIRParameterShipping];
        }
        NSString *coupon = properties[@"coupon"];
        if (coupon != nil) {
            [params setValue:coupon forKey:kFIRParameterCoupon];
        }
    }
}

-(BOOL) isCompatibleWithRevenue:(NSObject *)value {
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

- (void) addProductProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if (params != nil && properties != nil) {
        NSString *product_id = properties[@"product_id"];
        if (product_id != nil) {
            [params setValue:product_id forKey:kFIRParameterItemID];
        }
        NSString *name = properties[@"name"];
        if (name != nil) {
            [params setValue:name forKey:kFIRParameterItemName];
        }
        NSString *category = properties[@"category"];
        if (category != nil) {
            [params setValue:category forKey:kFIRParameterItemCategory];
        }
        NSNumber *quantity = properties[@"quantity"];
        if (quantity != nil) {
            [params setValue:quantity forKey:kFIRParameterQuantity];
        }
        NSNumber *price = properties[@"price"];
        if (price != nil) {
            [params setValue:price forKey:kFIRParameterPrice];
        }
        NSString *currency = properties[@"currency"];
        if (currency != nil) {
            [params setValue:currency forKey:kFIRParameterCurrency];
        }
    }
}

- (void) attachUnreservedCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(properties != nil && params != nil) {
        for (NSString *key in [properties keyEnumerator]) {
            NSString* firebaseKey = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if([firebaseKey length] > 40) { // 40: maximum supported key length by Firebase
                firebaseKey = [firebaseKey substringToIndex:[@40 unsignedIntegerValue]];
            }
            id value = properties[key];
            if (![_RESERVED_PARAM_NAMES containsObject:firebaseKey]) {
                if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    // value is a valid type
                    // Firebase supports only NSString and NSNumber parameter types
                    if([value isKindOfClass:[NSString class]]) {
                        if([value length] > 100) value = [value substringToIndex:[@100 unsignedIntegerValue]];
                    }
                } else {
                    // converting paramter's type to NSString
                    NSString* error;
                    NSString* jsonString = [self getStringValue:value withError:&error];
                    if(jsonString == nil) {
                        [RSLogger logError:[NSString stringWithFormat:@"RudderFirebaseIntegration: track: properties: key - \'%@\': %@", key, error]];
                        continue;// drop the current property
                    }
                    value = jsonString;
                }
                [params setValue:value forKey:firebaseKey];
            }
        }
    }
}

- (void) attachAllCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(properties != nil && params != nil) {
        for (NSString *key in [properties keyEnumerator]) {
            NSString* firebaseKey = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if([firebaseKey length] > 40) { // 40: maximum supported key length by Firebase
                firebaseKey = [firebaseKey substringToIndex:[@40 unsignedIntegerValue]];
            }
            id value = properties[key];
            if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                // value is a valid type
                // Firebase supports only NSString and NSNumber parameter types
                if([value isKindOfClass:[NSString class]]) {
                    if([value length] > 100) value = [value substringToIndex:[@100 unsignedIntegerValue]];
                }
            } else {
                // converting paramter's type to NSString
                NSString* error;
                NSString* jsonString = [self getStringValue:value withError:&error];
                if(jsonString == nil) {
                    [RSLogger logError:[NSString stringWithFormat:@"RudderFirebaseIntegration: track: properties: key - \'%@\': %@", key, error]];
                    continue;// drop the current property
                }
                value = jsonString;
            }
            [params setValue:value forKey:firebaseKey];
        }
    }
}

- (void)reset {
    // Firebase doesn't support reset functionality
}

- (void)flush {
    // Firebase doesn't support flush functionality
}


@end

