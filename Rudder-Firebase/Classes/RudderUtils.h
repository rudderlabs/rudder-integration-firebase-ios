//
//  RudderUtils.h
//  Rudder-Firebase
//
//  Created by Abhishek Pandey on 28/10/21.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>

@import FirebaseCore;
@import FirebaseAnalytics;



NS_ASSUME_NONNULL_BEGIN

@interface RudderUtils : NSObject


extern NSArray const* IDENTIFY_RESERVED_KEYWORDS;
extern NSArray const* TRACK_RESERVED_KEYWORDS;
extern NSDictionary const* ECOMMERCE_EVENTS_MAPPING;
extern NSDictionary const* PRODUCT_PROPERTIES_MAPPING;
extern NSArray const* EVENT_WITH_PRODUCTS;
extern NSDictionary const* ECOMMERCE_PROPERTY_MAPPING;

- (id)init;
+(BOOL) isEmpty:(NSObject *) value;
+(NSString *) getTrimKey:(NSString *) key;
+(BOOL) isNumber:(NSObject *)value;

@end

NS_ASSUME_NONNULL_END
