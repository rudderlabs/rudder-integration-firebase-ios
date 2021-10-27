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
        _RESERVED_PARAM_NAMES = [[NSArray alloc] initWithObjects:@"product_id", @"name", @"category", @"quantity", @"price", @"currency", @"value", @"revenue", @"total", @"order_id", @"tax", @"shipping", @"coupon", @"cart_id", @"payment_method", @"query", @"list_id", @"promotion_id", @"creative", @"affiliation", @"share_via", @"products", kFIRParameterScreenName, kFIREventScreenView, nil];
        
        _EVENTS_MAPPING = @{
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
                          kFIREventSelectContent,
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
            NSString *screenName = message.event;
            if (screenName == nil || [screenName isEqualToString:@""]) {
                return;
            }
            params = [[NSMutableDictionary alloc] init];
            [params setValue:screenName forKey:kFIRParameterScreenName];
            [self attachAllCustomProperties:params properties:properties];
            [FIRAnalytics logEventWithName:kFIREventScreenView parameters:params];
        } else if ([type isEqualToString:@"track"]) {
            NSString *eventName = message.event;
            if (eventName != nil && ![eventName isEqualToString:@""]) {
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
                        else if ([eventName isEqualToString:ECommProductShared] || [firebaseEvent isEqualToString:kFIREventSelectContent]) {
                            [params setValue:@"product" forKey:kFIRParameterContentType];
                        }
                        else if ([eventName isEqualToString:ECommCartShared]) {
                            [params setValue:@"cart" forKey:kFIRParameterContentType];
                        }
                        [self handleECommerce:params properties:properties firebaseEvent:firebaseEvent];
                    }
                }
                else {
                    firebaseEvent = [[[eventName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                    if([firebaseEvent length] > 40) {
                        firebaseEvent = [firebaseEvent substringToIndex:[@40 unsignedIntegerValue]];
                    }
                }
                if (![firebaseEvent isEqualToString:@""]) {
                    [self attachAllCustomProperties:params properties:properties];
                    [RSLogger logDebug:[NSString stringWithFormat:@"Logged \"%@\" to Firebase", firebaseEvent]];
                    [FIRAnalytics logEventWithName:firebaseEvent parameters:params];
                }
            }
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
        [params setValue:[NSNumber numberWithDouble:[properties[@"shipping"] doubleValue]] forKey:kFIRParameterShipping];
    }
    if (properties[@"tax"]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"tax"] doubleValue]] forKey:kFIRParameterTax];
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
    if (properties[@"products"]){
        NSDictionary *products = [properties objectForKey:@"products"];
        if ([products isKindOfClass:[NSArray class]]) {
            NSMutableArray *mappedProduct = [[NSMutableArray alloc] init];
            for (NSDictionary *product  in products) {
                NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
                for (NSString *key in _PRODUCTS_MAPPING) {
                    if (product[key]) {
                        [self putProductValue:productBundle firebaseKey:_PRODUCTS_MAPPING[key] value:product[key]];
                    }
                }
                if ([productBundle count]) {
                    [mappedProduct addObject:productBundle];
                }
            }
            if ([mappedProduct count]) {
                [params setValue:mappedProduct forKey:kFIRParameterItems];
            }
        }
    }
    // If product is present at the root level
    else {
        NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
        for (NSString *key in _PRODUCTS_MAPPING) {
            if (properties[key]) {
                [self putProductValue:productBundle firebaseKey:_PRODUCTS_MAPPING[key] value:properties[key]];
            }
        }
        NSArray *mappedProduct = [[NSArray alloc] initWithObjects:productBundle, nil];
        if ([mappedProduct count]) {
            [params setValue:mappedProduct forKey:kFIRParameterItems];
        }
    }
}

-(void) putProductValue:(NSMutableDictionary *) params firebaseKey:(NSString *) firebaseKey value:(NSObject *) value {
    if (value != nil) {
        if ([firebaseKey isEqualToString:kFIRParameterItemID] || [firebaseKey isEqualToString:kFIRParameterItemName] || [firebaseKey isEqualToString:kFIRParameterItemCategory]) {
            [params setValue:value forKey:firebaseKey];
            return;
        }
        if ([firebaseKey isEqualToString:kFIRParameterQuantity]) {
            [params setValue:value forKey:firebaseKey];
            return;
        }
        if ([firebaseKey isEqualToString:kFIRParameterPrice]) {
            [params setValue:value forKey:firebaseKey];
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

/*
- (void) attachAllCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(properties != nil &&  [properties count] && params != nil) {
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
*/

- (void) attachAllCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(properties != nil &&  [properties count] && params != nil) {
        for (NSString *key in [properties keyEnumerator]) {
            NSString* firebaseKey = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            if([firebaseKey length] > 40) { // 40: maximum supported key length by Firebase
                firebaseKey = [firebaseKey substringToIndex:[@40 unsignedIntegerValue]];
            }
            id value = properties[key];
            if (![_RESERVED_PARAM_NAMES containsObject:firebaseKey]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    [params setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:firebaseKey];
                    return;
                }
                else if([value isKindOfClass:[NSString class]] && [value length] > 100) {
                    value = [value substringToIndex:[@100 unsignedIntegerValue]];
                }
                else {
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

- (void)reset {
    // Firebase doesn't support reset functionality
}

- (void)flush {
    // Firebase doesn't support flush functionality
}


@end

