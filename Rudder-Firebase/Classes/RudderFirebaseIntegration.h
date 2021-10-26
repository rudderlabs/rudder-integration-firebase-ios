//
//  RudderAdjustIntegration.h
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
//#import <FirebaseCore/FirebaseCore.h>
//#import <FirebaseAnalytics/FirebaseAnalytics.h>

@import FirebaseCore;
@import FirebaseAnalytics;

NS_ASSUME_NONNULL_BEGIN

@interface RudderFirebaseIntegration : NSObject<RSIntegration>

@property NSArray* GOOGLE_RESERVED_KEYWORDS;
@property NSArray* RESERVED_PARAM_NAMES;
@property NSDictionary *EVENTS_MAPPING;
@property NSDictionary *PRODUCTS_MAPPING;
@property NSSet *PRODUCT_EVENT;

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client withRudderConfig:(RSConfig*) rudderConfig;

@end

NS_ASSUME_NONNULL_END
