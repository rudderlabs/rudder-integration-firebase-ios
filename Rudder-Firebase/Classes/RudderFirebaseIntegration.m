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
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([FIRApp defaultApp] == nil){
                [FIRApp configure];
                [RSLogger  logDebug:@"Rudder-Firebase is initialized"];
            } else {
                [RSLogger  logDebug:@"Firebase core already initialized - skipping on Rudder-Firebase"];
            }
            // Initialise RudderUtils class
            _rudderUtils = [[RudderUtils alloc] init];
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
            if (![_rudderUtils isEmpty:userId]) {
                [RSLogger logDebug:@"Setting userId to firebase"];
                [FIRAnalytics setUserID:userId];
            }
            NSDictionary *traits = message.context.traits;
            if (traits != nil) {
                for (NSString *key in [traits keyEnumerator]) {
                    if([key isEqualToString:@"userId"]) continue;
                    NSString* firebaseKey = [_rudderUtils getTrimStringKey:key maxLength:[@24 unsignedIntegerValue]];
                    if (![IDENTIFY_RESERVED_KEYWORDS containsObject:firebaseKey]) {
                        [RSLogger logDebug:[NSString stringWithFormat:@"Setting userProperty to Firebase: %@", firebaseKey]];
                        [FIRAnalytics setUserPropertyString:traits[key] forName:firebaseKey];
                    }
                }
            }
        } else if ([type isEqualToString:@"screen"]) {
            NSString *screenName = message.event;
            if ([_rudderUtils isEmpty:screenName]) {
                return;
            }
            params = [[NSMutableDictionary alloc] init];
            [params setValue:screenName forKey:kFIRParameterScreenName];
            [self attachAllCustomProperties:params properties:properties];
            [FIRAnalytics logEventWithName:kFIREventScreenView parameters:params];
        } else if ([type isEqualToString:@"track"]) {
            NSString *eventName = message.event;
            if (![_rudderUtils isEmpty:eventName]) {
                NSString *firebaseEvent;
                properties = message.properties;
                params = [[NSMutableDictionary alloc] init];
                if ([eventName isEqualToString:@"Application Opened"]) {
                    firebaseEvent = kFIREventAppOpen;
                }
                // Handle E-Commerce event
                else if (ECOMMERCE_EVENTS_MAPPING[eventName]){
                    firebaseEvent = ECOMMERCE_EVENTS_MAPPING[eventName];
                    if (![_rudderUtils isEmpty:properties]) {
                        if ([firebaseEvent isEqualToString:kFIREventShare]) {
                            if (![_rudderUtils isEmpty:properties[@"cart_id"]]) {
                                [params setValue:properties[@"cart_id"] forKey:kFIRParameterItemID];
                            } else if (![_rudderUtils isEmpty:properties[@"product_id"]]) {
                                [params setValue:properties[@"product_id"] forKey:kFIRParameterItemID];
                            }
                        }
                        if ([firebaseEvent isEqualToString:kFIREventViewPromotion] || [firebaseEvent isEqualToString:kFIREventSelectPromotion]) {
                            if (![_rudderUtils isEmpty:properties[@"name"]]) {
                                [params setValue:properties[@"name"] forKey:kFIRParameterPromotionName];
                            }
                        }
                        if ([eventName isEqualToString:ECommProductShared] || [firebaseEvent isEqualToString:kFIREventSelectContent]) {
                            [params setValue:@"product" forKey:kFIRParameterContentType];
                        }
                        if ([eventName isEqualToString:ECommCartShared]) {
                            [params setValue:@"cart" forKey:kFIRParameterContentType];
                        }
                        [self handleECommerce:params properties:properties firebaseEvent:firebaseEvent];
                    }
                }
                // Custom track event
                else {
                    firebaseEvent = [_rudderUtils getTrimStringKey:eventName maxLength:[@40 unsignedIntegerValue]];
                }
                if (![_rudderUtils isEmpty:firebaseEvent]) {
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
    if (![_rudderUtils isEmpty:properties[@"revenue"]] && [_rudderUtils isNumber:properties[@"revenue"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"revenue"] doubleValue]] forKey:kFIRParameterValue];
    } else if (![_rudderUtils isEmpty:properties[@"value"]] && [_rudderUtils isNumber:properties[@"value"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"value"] doubleValue]] forKey:kFIRParameterValue];
    } else if (![_rudderUtils isEmpty:properties[@"total"]] && [_rudderUtils isNumber:properties[@"total"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"total"] doubleValue]] forKey:kFIRParameterValue];
    }
    // Handle Products array or Product at the root level for allowed events
    if ([EVENT_WITH_PRODUCTS containsObject:firebaseEvent]) {
        [self handleProducts:params properties:properties];
    }
    if (![_rudderUtils isEmpty:properties[@"currency"]]) {
        [params setValue:[NSString stringWithFormat:@"%@", properties[@"currency"]] forKey:kFIRParameterCurrency];
    } else {
        [params setValue:properties[@"currency"] forKey:@"USD"];
    }
    for (NSString *propertyKey in properties) {
        if (ECOMMERCE_PROPERTY_MAPPING[propertyKey] && ![_rudderUtils isEmpty:properties[propertyKey]]) {
            [params setValue:[NSString stringWithFormat:@"%@", properties[propertyKey]] forKey:ECOMMERCE_PROPERTY_MAPPING[propertyKey]];
        }
    }
    if (![_rudderUtils isEmpty:properties[@"shipping"]] && [_rudderUtils isNumber:properties[@"shipping"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"shipping"] doubleValue]] forKey:kFIRParameterShipping];
    }
    if (![_rudderUtils isEmpty:properties[@"tax"]] && [_rudderUtils isNumber:properties[@"tax"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"tax"] doubleValue]] forKey:kFIRParameterTax];
    }
}

-(void) handleProducts:(NSMutableDictionary *) params properties: (NSDictionary *) properties {
    NSMutableArray *mappedProduct;
    // If Products array is present
    if (![_rudderUtils isEmpty:properties[@"products"]]){
        NSDictionary *products = [properties objectForKey:@"products"];
        if ([products isKindOfClass:[NSArray class]]) {
            mappedProduct = [[NSMutableArray alloc] init];
            for (NSDictionary *product  in products) {
                NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
                [self putProductValue:productBundle properties:product];
                if ([productBundle count]) {
                    [mappedProduct addObject:productBundle];
                }
            }
        }
    }
    // If product is present at the root level
    else {
        NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
        [self putProductValue:productBundle properties:properties];
        mappedProduct = [[NSMutableArray alloc] init];
        [mappedProduct addObject:productBundle];
    }
    if (![_rudderUtils isEmpty:mappedProduct]) {
        [params setValue:mappedProduct forKey:kFIRParameterItems];
    }
}

-(void) putProductValue:(NSMutableDictionary *) params properties:(NSDictionary *) properties {
    for (NSString *key in PRODUCT_PROPERTIES_MAPPING) {
        if (![_rudderUtils isEmpty:properties[key]]) {
            NSString *firebaseKey = PRODUCT_PROPERTIES_MAPPING[key];
            if ([firebaseKey isEqualToString:kFIRParameterItemID] || [firebaseKey isEqualToString:kFIRParameterItemName] || [firebaseKey isEqualToString:kFIRParameterItemCategory]) {
                [params setValue:[NSString stringWithFormat:@"%@", properties[key]] forKey:firebaseKey];
                continue;;
            }
            if ([_rudderUtils isNumber:properties[key]]) {
                if ([firebaseKey isEqualToString:kFIRParameterQuantity]) {
                    [params setValue:[NSNumber numberWithInteger:[(NSNumber *)properties[key] intValue]] forKey:firebaseKey];
                    continue;;
                }
                if ([firebaseKey isEqualToString:kFIRParameterPrice]) {
                    [params setValue:[NSNumber numberWithDouble:[(NSNumber *)properties[key] doubleValue]] forKey:firebaseKey];
                }
            }
        }
    }
}

- (void) attachAllCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if(![_rudderUtils isEmpty:properties] && params != nil) {
        for (NSString *key in [properties keyEnumerator]) {
            NSString* firebaseKey = [_rudderUtils getTrimStringKey:key maxLength:[@40 unsignedIntegerValue]];
            id value = properties[key];
            if ([TRACK_RESERVED_KEYWORDS containsObject:firebaseKey] || [_rudderUtils isEmpty:value]) {
                continue;
            }
            if ([value isKindOfClass:[NSNumber class]]) {
                [params setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:firebaseKey];
                continue;
            }
            else if([value isKindOfClass:[NSString class]]) {
                if ([value length] > 100) {
                    value = [value substringToIndex:[@100 unsignedIntegerValue]];
                }
                [params setValue:[NSString stringWithFormat:@"%@", properties[key]] forKey:firebaseKey];
                continue;
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

